module mmu #(
    parameter VADDR_WIDTH = 32,  // Changed to 32-bit virtual addresses
    parameter PADDR_WIDTH = 32,  // Changed to 32-bit physical addresses
    parameter DATA_WIDTH = 64,
    parameter TLB_ENTRIES = 16,  // Reduced TLB size to save resources
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

    // For Sv32 (32-bit addressing)
    localparam VPN_WIDTH = 20;   // Virtual Page Number width (32-bit VA / 4KB pages)
    localparam PPN_WIDTH = 20;   // Physical Page Number width (32-bit PA / 4KB pages)
    localparam OFFSET_WIDTH = 12; // Page offset (4KB)
    
    // Page Table Entry (PTE) format for Sv32
    typedef struct packed {
        logic [11:0] ppn1;     // Physical page number[31:20]
        logic [9:0]  ppn0;     // Physical page number[19:10]
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
        logic [19:0]       vpn;      // Virtual page number
        logic [19:0]       ppn;      // Physical page number
        logic              g;        // Global
        logic              u;        // User accessible
        logic              x;        // Execute permission
        logic              w;        // Write permission
        logic              r;        // Read permission
        logic              d;        // Dirty
        logic              a;        // Accessed
        logic              level;    // Page level (0=4KB, 1=4MB megapage)
    } tlb_entry_t;
    
    // TLB storage
    tlb_entry_t tlb [TLB_ENTRIES-1:0];
    logic [$clog2(TLB_ENTRIES)-1:0] tlb_replace_idx;
    
    // VPN extraction for Sv32
    logic [9:0]  vpn1, vpn0;  // Virtual page number components
    logic [11:0] page_offset;
    
    assign vpn1 = vaddr[31:22];
    assign vpn0 = vaddr[21:12];
    assign page_offset = vaddr[11:0];
    
    // TLB lookup
    logic tlb_hit;
    logic [$clog2(TLB_ENTRIES)-1:0] tlb_hit_idx;
    tlb_entry_t tlb_hit_entry;
    
    always_comb begin
        tlb_hit = 1'b0;
        tlb_hit_idx = '0;
        tlb_hit_entry = '0;
        
        for (int i = 0; i < TLB_ENTRIES; i++) begin
            if (tlb[i].valid) begin
                logic vpn_match;
                
                // Check VPN based on page size
                if (tlb[i].level) begin
                    // 4MB megapage - only check vpn1
                    vpn_match = (tlb[i].vpn[19:10] == vpn1);
                end else begin
                    // 4KB page - check both vpn1 and vpn0
                    vpn_match = (tlb[i].vpn == {vpn1, vpn0});
                end
                
                if (vpn_match && !tlb_hit) begin
                    tlb_hit = 1'b1;
                    tlb_hit_idx = i[$clog2(TLB_ENTRIES)-1:0];
                    tlb_hit_entry = tlb[i];
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
                priv_ok = !tlb_hit_entry.u;
            else // User mode
                priv_ok = tlb_hit_entry.u;
            
            // Check read/write/execute permissions
            logic perm_ok;
            if (req_write)
                perm_ok = tlb_hit_entry.w && tlb_hit_entry.d;  // Write requires dirty bit
            else
                perm_ok = tlb_hit_entry.r;
            
            perm_valid = priv_ok && perm_ok && tlb_hit_entry.a;  // Also check accessed bit
        end
    end

    // Page table walker state machine
    typedef enum logic [2:0] {
        IDLE,
        PTW_L1,     // Level 1 (4MB pages)
        PTW_L0,     // Level 0 (4KB pages)
        PTW_WAIT,
        UPDATE_TLB,
        FAULT
    } ptw_state_t;
    
    ptw_state_t ptw_state, ptw_next_state;
    pte_t pte;
    logic ptw_level;
    logic [PADDR_WIDTH-1:0] ptw_base;
    
    // State machine
    always_ff @(posedge clk or negedge rst_n) begin
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
                        // Extract page table base from satp (bits 31:12 contain PPN)
                        ptw_base <= {satp[31:12], 12'b0};
                        ptw_level <= 1'b1; // Start at level 1
                    end
                end
                
                PTW_L1: begin
                    // Index into first-level page table
                    ptw_addr <= ptw_base + (vpn1 << 2);  // Each PTE is 4 bytes
                end
                
                PTW_L0: begin
                    // Index into second-level page table
                    ptw_addr <= {pte.ppn1, pte.ppn0, 12'b0} + (vpn0 << 2);
                    ptw_level <= 1'b0;
                end
                
                PTW_WAIT: begin
                    if (ptw_ready) begin
                        pte <= ptw_data[31:0];  // PTE is 32 bits in Sv32
                    end
                end
                
                UPDATE_TLB: begin
                    // Update TLB with new entry
                    tlb[tlb_replace_idx].valid <= 1'b1;
                    tlb[tlb_replace_idx].vpn <= {vpn1, vpn0};
                    tlb[tlb_replace_idx].ppn <= {pte.ppn1, pte.ppn0};
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
    always_comb begin
        ptw_next_state = ptw_state;
        ptw_req = 1'b0;
        
        case (ptw_state)
            IDLE: begin
                if (!tlb_hit && req_valid && vm_enable) begin
                    ptw_next_state = PTW_L1;
                end
            end
            
            PTW_L1, PTW_L0: begin
                ptw_req = 1'b1;
                ptw_next_state = PTW_WAIT;
            end
            
            PTW_WAIT: begin
                if (ptw_ready) begin
                    if (!pte.v) begin
                        // Invalid PTE
                        ptw_next_state = FAULT;
                    end else if (!pte.r && !pte.w && !pte.x) begin
                        // Pointer to next level
                        if (ptw_level == 1'b1) begin
                            ptw_next_state = PTW_L0;
                        end else begin
                            ptw_next_state = FAULT;  // Invalid at level 0
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

    // TLB flush logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < TLB_ENTRIES; i++) begin
                tlb[i].valid <= 1'b0;
            end
            tlb_replace_idx <= '0;
        end else begin
            if (tlb_flush) begin
                if (tlb_flush_vaddr) begin
                    // Flush specific address
                    for (int i = 0; i < TLB_ENTRIES; i++) begin
                        if (tlb[i].valid && tlb[i].vpn == tlb_flush_addr[31:12]) begin
                            tlb[i].valid <= 1'b0;
                        end
                    end
                end else begin
                    // Flush entire TLB
                    for (int i = 0; i < TLB_ENTRIES; i++) begin
                        tlb[i].valid <= 1'b0;
                    end
                end
            end
        end
    end
    
    // Output logic
    always_comb begin
        if (!vm_enable) begin
            // Virtual memory disabled - direct mapping
            paddr = vaddr;
            trans_valid = req_valid;
            page_fault = 1'b0;
            access_fault = 1'b0;
        end else if (tlb_hit) begin
            // TLB hit - translate address
            if (tlb_hit_entry.level) begin
                // 4MB megapage
                paddr = {tlb_hit_entry.ppn[19:10], vpn0, page_offset};
            end else begin
                // 4KB page
                paddr = {tlb_hit_entry.ppn, page_offset};
            end
            trans_valid = perm_valid;
            page_fault = !tlb_hit_entry.valid;
            access_fault = !perm_valid;
        end else if (ptw_state == UPDATE_TLB) begin
            // Just completed page table walk
            if (ptw_level) begin
                // 4MB megapage
                paddr = {pte.ppn1, vpn0, page_offset};
            end else begin
                // 4KB page
                paddr = {pte.ppn1, pte.ppn0, page_offset};
            end
            trans_valid = 1'b1;
            page_fault = 1'b0;
            access_fault = 1'b0;
        end else if (ptw_state == FAULT) begin
            // Page table walk failed
            paddr = '0;
            trans_valid = 1'b0;
            page_fault = 1'b1;
            access_fault = 1'b0;
        end else begin
            // Miss or walking
            paddr = '0;
            trans_valid = 1'b0;
            page_fault = 1'b0;
            access_fault = 1'b0;
        end
    end
    
    // Debug counters
    `ifdef DEBUG
    logic [31:0] tlb_hits;
    logic [31:0] tlb_misses;
    logic [31:0] page_faults_count;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tlb_hits <= '0;
            tlb_misses <= '0;
            page_faults_count <= '0;
        end else begin
            if (req_valid && vm_enable) begin
                if (tlb_hit)
                    tlb_hits <= tlb_hits + 1;
                else
                    tlb_misses <= tlb_misses + 1;
            end
            if (page_fault)
                page_faults_count <= page_faults_count + 1;
        end
    end
    `endif

endmodule