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
    
    // Page Table Entry (PTE) format for Sv39 - simplified for Icarus
    logic [9:0]  pte_reserved;
    logic [43:0] pte_ppn;      // Physical page number
    logic [1:0]  pte_rsw;      // Reserved for software
    logic        pte_d;        // Dirty
    logic        pte_a;        // Accessed
    logic        pte_g;        // Global
    logic        pte_u;        // User
    logic        pte_x;        // Execute
    logic        pte_w;        // Write
    logic        pte_r;        // Read
    logic        pte_v;        // Valid
    
    // TLB Entry - simplified structure
    logic              tlb_valid [TLB_ENTRIES-1:0];
    logic [26:0]       tlb_vpn [TLB_ENTRIES-1:0];      // Virtual page number
    logic [43:0]       tlb_ppn [TLB_ENTRIES-1:0];      // Physical page number
    logic              tlb_g [TLB_ENTRIES-1:0];        // Global
    logic              tlb_u [TLB_ENTRIES-1:0];        // User accessible
    logic              tlb_x [TLB_ENTRIES-1:0];        // Execute permission
    logic              tlb_w [TLB_ENTRIES-1:0];        // Write permission
    logic              tlb_r [TLB_ENTRIES-1:0];        // Read permission
    logic              tlb_d [TLB_ENTRIES-1:0];        // Dirty
    logic              tlb_a [TLB_ENTRIES-1:0];        // Accessed
    logic [1:0]        tlb_level [TLB_ENTRIES-1:0];    // Page level (0=4KB, 1=2MB, 2=1GB)
    
    logic [$clog2(TLB_ENTRIES)-1:0] tlb_replace_idx;
    
    // Address breakdown
    logic [8:0]  vpn2, vpn1, vpn0;  // Virtual page number components
    logic [11:0] page_offset;
    
    assign vpn2 = vaddr[38:30];
    assign vpn1 = vaddr[29:21];
    assign vpn0 = vaddr[20:12];
    assign page_offset = vaddr[11:0];
    
    // TLB lookup
    logic tlb_hit;
    logic [$clog2(TLB_ENTRIES)-1:0] tlb_hit_idx;
    logic              tlb_hit_valid;
    logic [26:0]       tlb_hit_vpn;
    logic [43:0]       tlb_hit_ppn;
    logic              tlb_hit_g;
    logic              tlb_hit_u;
    logic              tlb_hit_x;
    logic              tlb_hit_w;
    logic              tlb_hit_r;
    logic              tlb_hit_d;
    logic              tlb_hit_a;
    logic [1:0]        tlb_hit_level;
    
    integer i;
    
    always_comb begin
        tlb_hit = 1'b0;
        tlb_hit_idx = '0;
        tlb_hit_valid = 1'b0;
        tlb_hit_vpn = '0;
        tlb_hit_ppn = '0;
        tlb_hit_g = 1'b0;
        tlb_hit_u = 1'b0;
        tlb_hit_x = 1'b0;
        tlb_hit_w = 1'b0;
        tlb_hit_r = 1'b0;
        tlb_hit_d = 1'b0;
        tlb_hit_a = 1'b0;
        tlb_hit_level = 2'b00;
        
        for (i = 0; i < TLB_ENTRIES; i = i + 1) begin
            if (tlb_valid[i] && !tlb_hit) begin
                logic vpn_match;
                
                // Check VPN based on page size
                case (tlb_level[i])
                    2'd0: vpn_match = (tlb_vpn[i] == {vpn2, vpn1, vpn0}); // 4KB page
                    2'd1: vpn_match = (tlb_vpn[i][26:9] == {vpn2, vpn1}); // 2MB page
                    2'd2: vpn_match = (tlb_vpn[i][26:18] == vpn2);        // 1GB page
                    default: vpn_match = 1'b0;
                endcase
                
                if (vpn_match) begin
                    tlb_hit = 1'b1;
                    tlb_hit_idx = i[$clog2(TLB_ENTRIES)-1:0];
                    tlb_hit_valid = tlb_valid[i];
                    tlb_hit_vpn = tlb_vpn[i];
                    tlb_hit_ppn = tlb_ppn[i];
                    tlb_hit_g = tlb_g[i];
                    tlb_hit_u = tlb_u[i];
                    tlb_hit_x = tlb_x[i];
                    tlb_hit_w = tlb_w[i];
                    tlb_hit_r = tlb_r[i];
                    tlb_hit_d = tlb_d[i];
                    tlb_hit_a = tlb_a[i];
                    tlb_hit_level = tlb_level[i];
                end
            end
        end
    end
    
    // Permission checking
    logic perm_valid;
    
    always_comb begin
        perm_valid = 1'b0;
        
        if (tlb_hit) begin
            // Check if page is accessible at current privilege level
            logic priv_ok;
            if (req_priv == 2'b11) // Machine mode
                priv_ok = 1'b1;
            else if (req_priv == 2'b01) // Supervisor mode
                priv_ok = !tlb_hit_u;
            else // User mode
                priv_ok = tlb_hit_u;
            
            // Check read/write/execute permissions
            logic perm_ok;
            if (req_write)
                perm_ok = tlb_hit_w;
            else
                perm_ok = tlb_hit_r;
            
            perm_valid = priv_ok && perm_ok;
        end
    end

    // Page table walk state machine - simplified
    typedef enum logic [2:0] {
        IDLE,
        PTW_L2,     // Level 2 (1GB pages)
        PTW_L1,     // Level 1 (2MB pages)
        PTW_L0,     // Level 0 (4KB pages)
        PTW_WAIT,
        UPDATE_TLB,
        FAULT
    } ptw_state_t;
    
    ptw_state_t ptw_state, ptw_next_state;
    logic [63:0] pte_data;
    logic [1:0] ptw_level;
    logic [PADDR_WIDTH-1:0] ptw_base;
    
    // Extract PTE fields from data
    always_comb begin
        pte_reserved = ptw_data[63:54];
        pte_ppn      = ptw_data[53:10];
        pte_rsw      = ptw_data[9:8];
        pte_d        = ptw_data[7];
        pte_a        = ptw_data[6];
        pte_g        = ptw_data[5];
        pte_u        = ptw_data[4];
        pte_x        = ptw_data[3];
        pte_w        = ptw_data[2];
        pte_r        = ptw_data[1];
        pte_v        = ptw_data[0];
    end
    
    // State machine
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ptw_state <= IDLE;
            ptw_level <= '0;
            ptw_base <= '0;
            pte_data <= '0;
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
                    ptw_addr <= (pte_ppn << 12) + (vpn1 << 3);
                    ptw_level <= 2'd1;
                end
                
                PTW_L0: begin
                    ptw_addr <= (pte_ppn << 12) + (vpn0 << 3);
                    ptw_level <= 2'd0;
                end
                
                PTW_WAIT: begin
                    if (ptw_ready) begin
                        pte_data <= ptw_data;
                    end
                end
                
                UPDATE_TLB: begin
                    // Update TLB with new entry
                    tlb_valid[tlb_replace_idx] <= 1'b1;
                    tlb_vpn[tlb_replace_idx] <= {vpn2, vpn1, vpn0};
                    tlb_ppn[tlb_replace_idx] <= pte_ppn;
                    tlb_g[tlb_replace_idx] <= pte_g;
                    tlb_u[tlb_replace_idx] <= pte_u;
                    tlb_x[tlb_replace_idx] <= pte_x;
                    tlb_w[tlb_replace_idx] <= pte_w;
                    tlb_r[tlb_replace_idx] <= pte_r;
                    tlb_d[tlb_replace_idx] <= pte_d;
                    tlb_a[tlb_replace_idx] <= pte_a;
                    tlb_level[tlb_replace_idx] <= ptw_level;
                    
                    // Simple round-robin replacement
                    tlb_replace_idx <= tlb_replace_idx + 1;
                end
            endcase
        end
    end
    
    // Next state logic
    always_comb begin
        ptw_next_state = ptw_state;
        ptw_req = 1'b0;
        
        case (ptw_state)
            IDLE: begin
                if (!tlb_hit && req_valid && vm_enable) begin
                    ptw_next_state = PTW_L2;
                end
            end
            
            PTW_L2, PTW_L1, PTW_L0: begin
                ptw_req = 1'b1;
                ptw_next_state = PTW_WAIT;
            end
            
            PTW_WAIT: begin
                if (ptw_ready) begin
                    if (!pte_v || (!pte_r && !pte_w && !pte_x)) begin
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

    // TLB management
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < TLB_ENTRIES; i = i + 1) begin
                tlb_valid[i] <= 1'b0;
            end
            tlb_replace_idx <= '0;
        end else begin
            if (tlb_flush) begin
                if (tlb_flush_vaddr) begin
                    // Flush specific address
                    for (i = 0; i < TLB_ENTRIES; i = i + 1) begin
                        if (tlb_valid[i] && tlb_vpn[i] == tlb_flush_addr[38:12]) begin
                            tlb_valid[i] <= 1'b0;
                        end
                    end
                end else begin
                    // Flush entire TLB
                    for (i = 0; i < TLB_ENTRIES; i = i + 1) begin
                        tlb_valid[i] <= 1'b0;
                    end
                end
            end
        end
    end
    
    // Address translation
    always_comb begin
        if (!vm_enable) begin
            // Virtual memory disabled - direct mapping
            paddr = vaddr;
            trans_valid = req_valid;
            page_fault = 1'b0;
            access_fault = 1'b0;
        end else if (tlb_hit) begin
            // TLB hit - translate address
            case (tlb_hit_level)
                2'd0: paddr = {tlb_hit_ppn, page_offset};
                2'd1: paddr = {tlb_hit_ppn[43:9], vpn0, page_offset};
                2'd2: paddr = {tlb_hit_ppn[43:18], vpn1, vpn0, page_offset};
                default: paddr = '0;
            endcase
            trans_valid = perm_valid;
            page_fault = !tlb_hit_valid;
            access_fault = !perm_valid;
        end else if (ptw_state == UPDATE_TLB) begin
            // Just completed page table walk
            case (ptw_level)
                2'd0: paddr = {pte_ppn, page_offset};
                2'd1: paddr = {pte_ppn[43:9], vpn0, page_offset};
                2'd2: paddr = {pte_ppn[43:18], vpn1, vpn0, page_offset};
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
