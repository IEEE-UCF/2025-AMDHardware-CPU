module mmu #(
    parameter VADDR_WIDTH = 64,  // Virtual address width
    parameter PADDR_WIDTH = 64,  // Physical address width
    parameter DATA_WIDTH = 64,
    parameter TLB_ENTRIES = 32,  // Number of TLB entries
    parameter PAGE_SIZE = 4096   // 4KB pages
)(
    input  logic                    clk,
    input  logic                    rst_n,
    
    // CPU Interface
    input  logic [VADDR_WIDTH-1:0]  vaddr,
    input  logic                    req_valid,
    input  logic                    req_write,
    input  logic [1:0]              req_priv,      // Privilege level (0=U, 1=S, 3=M)
    output logic [PADDR_WIDTH-1:0] paddr,
    output logic                    trans_valid,
    output logic                    page_fault,
    output logic                    access_fault,
    
    // Page Table Base Register (from CSR)
    input  logic [PADDR_WIDTH-1:0] satp,          // Supervisor Address Translation and Protection
    input  logic                    vm_enable,     // Virtual memory enable
    
    // Memory Interface for page table walks
    output logic                    ptw_req,
    output logic [PADDR_WIDTH-1:0] ptw_addr,
    input  logic [DATA_WIDTH-1:0]  ptw_data,
    input  logic                    ptw_ready,
    
    // TLB Management
    input  logic                    tlb_flush,
    input  logic                    tlb_flush_vaddr,
    input  logic [VADDR_WIDTH-1:0] tlb_flush_addr
);

    
    localparam VPN_WIDTH = 27;  // Virtual Page Number width (39-bit VA / 4KB pages)
    localparam PPN_WIDTH = 44;  // Physical Page Number width (56-bit PA / 4KB pages)
    localparam OFFSET_WIDTH = 12; // Page offset (4KB)
    
    // Page Table Entry (PTE) format for Sv39
    typedef struct packed {
        logic [9:0]  reserved;
        logic [43:0] ppn;      // Physical page number
        logic [1:0]  rsw;      // Reserved for software
        logic        d;        // Dirty
        logic        a;        // Accessed
        logic        g;        // Global
        logic        u;        // User
        logic        x;        // Execute
        logic        w;        // Write
        logic        r;        // Read
        logic        v;        // Valid
    } pte_t;
    
    // TLB Entry
    typedef struct packed {
        logic              valid;
        logic [26:0]       vpn;      // Virtual page number
        logic [43:0]       ppn;      // Physical page number
        logic              g;        // Global
        logic              u;        // User accessible
        logic              x;        // Execute permission
        logic              w;        // Write permission
        logic              r;        // Read permission
        logic              d;        // Dirty
        logic              a;        // Accessed
        logic [1:0]        level;    // Page level (0=4KB, 1=2MB, 2=1GB)
    } tlb_entry_t;
    
    
    tlb_entry_t tlb [TLB_ENTRIES-1:0];
    logic [$clog2(TLB_ENTRIES)-1:0] tlb_replace_idx;
    
    
    logic [8:0]  vpn2, vpn1, vpn0;  // Virtual page number components
    logic [11:0] page_offset;
    
    assign vpn2 = vaddr[38:30];
    assign vpn1 = vaddr[29:21];
    assign vpn0 = vaddr[20:12];
    assign page_offset = vaddr[11:0];
    
    
    logic tlb_hit;
    logic [$clog2(TLB_ENTRIES)-1:0] tlb_hit_idx;
    tlb_entry_t tlb_hit_entry;
    
    always @* begin
        tlb_hit = 1'b0;
        tlb_hit_idx = '0;
        tlb_hit_entry = '0;
        
        integer i;
        for (i = 0; i < TLB_ENTRIES; i = i + 1) begin
            if (tlb[i].valid) begin
                logic vpn_match;
                
                // Check VPN based on page size
                case (tlb[i].level)
                    2'd0: vpn_match = (tlb[i].vpn == {vpn2, vpn1, vpn0}); // 4KB page
                    2'd1: vpn_match = (tlb[i].vpn[26:9] == {vpn2, vpn1}); // 2MB page
                    2'd2: vpn_match = (tlb[i].vpn[26:18] == vpn2);        // 1GB page
                    default: vpn_match = 1'b0;
                endcase
                
                if (vpn_match && !tlb_hit) begin
                    tlb_hit = 1'b1;
                    tlb_hit_idx = i[$clog2(TLB_ENTRIES)-1:0];
                    tlb_hit_entry = tlb[i];
                end
            end
        end
    end
    
    
    logic perm_valid;
    
    always @* begin
        perm_valid = 1'b0;
        
        if (tlb_hit) begin
            // Check if page is accessible at current privilege level
            logic priv_ok;
            if (req_priv == 2'b11) // Machine mode
                priv_ok = 1'b1;
            else if (req_priv == 2'b01) // Supervisor mode
                priv_ok = !tlb_hit_entry.u;
            else // User mode
                priv_ok = tlb_hit_entry.u;
            
            // Check read/write/execute permissions
            logic perm_ok;
            if (req_write)
                perm_ok = tlb_hit_entry.w;
            else
                perm_ok = tlb_hit_entry.r;
            
            perm_valid = priv_ok && perm_ok;
        end
    end

    localparam IDLE       = 3'd0;
    localparam PTW_L2     = 3'd1; // Level 2 (1GB pages)
    localparam PTW_L1     = 3'd2; // Level 1 (2MB pages)
    localparam PTW_L0     = 3'd3; // Level 0 (4KB pages)
    localparam PTW_WAIT   = 3'd4;
    localparam UPDATE_TLB = 3'd5;
    localparam FAULT      = 3'd6;

    logic [2:0] ptw_state, ptw_next_state;
    pte_t pte;
    logic [1:0] ptw_level;
    logic [PADDR_WIDTH-1:0] ptw_base;
    
    // State machine
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ptw_state <= IDLE;
            ptw_level <= '0;
            ptw_base <= '0;
            pte <= '0;
        end else begin
            ptw_state <= ptw_next_state;
            
            case (ptw_state)
                IDLE: begin
                    if (!tlb_hit && req_valid && vm_enable) begin
                        ptw_base <= satp[43:0] << 12; // Page table base
                        ptw_level <= 2'd2; // Start at level 2
                    end
                end
                
                PTW_L2: begin
                    ptw_addr <= ptw_base + (vpn2 << 3);
                end
                
                PTW_L1: begin
                    ptw_addr <= (pte.ppn << 12) + (vpn1 << 3);
                    ptw_level <= 2'd1;
                end
                
                PTW_L0: begin
                    ptw_addr <= (pte.ppn << 12) + (vpn0 << 3);
                    ptw_level <= 2'd0;
                end
                
                PTW_WAIT: begin
                    if (ptw_ready) begin
                        pte <= ptw_data;
                    end
                end
                
                UPDATE_TLB: begin
                    // Update TLB with new entry
                    tlb[tlb_replace_idx].valid <= 1'b1;
                    tlb[tlb_replace_idx].vpn <= {vpn2, vpn1, vpn0};
                    tlb[tlb_replace_idx].ppn <= pte.ppn;
                    tlb[tlb_replace_idx].g <= pte.g;
                    tlb[tlb_replace_idx].u <= pte.u;
                    tlb[tlb_replace_idx].x <= pte.x;
                    tlb[tlb_replace_idx].w <= pte.w;
                    tlb[tlb_replace_idx].r <= pte.r;
                    tlb[tlb_replace_idx].d <= pte.d;
                    tlb[tlb_replace_idx].a <= pte.a;
                    tlb[tlb_replace_idx].level <= ptw_level;
                    
                    // Simple round-robin replacement
                    tlb_replace_idx <= tlb_replace_idx + 1;
                end
            endcase
        end
    end
    
    // Next state logic
    always @* begin
        ptw_next_state = ptw_state;
        ptw_req = 1'b0;
        
        case (ptw_state)
            IDLE: begin
                if (!tlb_hit && req_valid && vm_enable) begin
                    ptw_next_state = PTW_L2;
                end
            end
            
            PTW_L2: begin
                ptw_req = 1'b1;
                ptw_next_state = PTW_WAIT;
            end

            PTW_L1: begin
                ptw_req = 1'b1;
                ptw_next_state = PTW_WAIT;
            end

            PTW_L0: begin
                ptw_req = 1'b1;
                ptw_next_state = PTW_WAIT;
            end
            
            PTW_WAIT: begin
                if (ptw_ready) begin
                    if (!pte.v || (!pte.r && !pte.w && !pte.x)) begin
                        // Invalid PTE or pointer to next level
                        if (ptw_level > 0) begin
                            case (ptw_level)
                                2'd2: ptw_next_state = PTW_L1;
                                2'd1: ptw_next_state = PTW_L0;
                                default: ptw_next_state = FAULT;
                            endcase
                        end else begin
                            ptw_next_state = FAULT;
                        end
                    end else begin
                        // Valid leaf PTE
                        ptw_next_state = UPDATE_TLB;
                    end
                end
            end
            
            UPDATE_TLB: begin
                ptw_next_state = IDLE;
            end
            
            FAULT: begin
                ptw_next_state = IDLE;
            end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            integer i;
            for (i = 0; i < TLB_ENTRIES; i = i + 1) begin
                tlb[i].valid <= 1'b0;
            end
            tlb_replace_idx <= '0;
        end else begin
            if (tlb_flush) begin
                if (tlb_flush_vaddr) begin
                    // Flush specific address
                    integer i;
                    for (i = 0; i < TLB_ENTRIES; i = i + 1) begin
                        if (tlb[i].valid && tlb[i].vpn == tlb_flush_addr[38:12]) begin
                            tlb[i].valid <= 1'b0;
                        end
                    end
                end else begin
                    // Flush entire TLB
                    integer i;
                    for (i = 0; i < TLB_ENTRIES; i = i + 1) begin
                        tlb[i].valid <= 1'b0;
                    end
                end
            end
        end
    end
    
    always @* begin
        if (!vm_enable) begin
            // Virtual memory disabled - direct mapping
            paddr = vaddr;
            trans_valid = req_valid;
            page_fault = 1'b0;
            access_fault = 1'b0;
        end else if (tlb_hit) begin
            // TLB hit - translate address
            case (tlb_hit_entry.level)
                2'd0: paddr = {tlb_hit_entry.ppn, page_offset};
                2'd1: paddr = {tlb_hit_entry.ppn[43:9], vpn0, page_offset};
                2'd2: paddr = {tlb_hit_entry.ppn[43:18], vpn1, vpn0, page_offset};
                default: paddr = '0;
            endcase
            trans_valid = perm_valid;
            page_fault = !tlb_hit_entry.valid;
            access_fault = !perm_valid;
        end else if (ptw_state == UPDATE_TLB) begin
            // Just completed page table walk
            case (ptw_level)
                2'd0: paddr = {pte.ppn, page_offset};
                2'd1: paddr = {pte.ppn[43:9], vpn0, page_offset};
                2'd2: paddr = {pte.ppn[43:18], vpn1, vpn0, page_offset};
                default: paddr = '0;
            endcase
            trans_valid = 1'b1;
            page_fault = 1'b0;
            access_fault = 1'b0;
        end else begin
            // Miss or walking
            paddr = '0;
            trans_valid = 1'b0;
            page_fault = (ptw_state == FAULT);
            access_fault = 1'b0;
        end
    end

endmodule
