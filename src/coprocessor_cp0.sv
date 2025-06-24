// System Control Coprocessor (CP0)
// Handles system-level operations like CSR access, exceptions, and privileged instructions

module coprocessor_cp0 #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64,
    parameter INST_WIDTH = 32
)(
    input  logic                    clk,
    input  logic                    rst_n,
    
    // Coprocessor Interface
    input  logic                    cp_enable,
    input  logic [INST_WIDTH-1:0]  cp_instruction,
    input  logic [DATA_WIDTH-1:0]  cp_data_in,
    output logic [DATA_WIDTH-1:0]  cp_data_out,
    output logic                    cp_ready,
    output logic                    cp_exception,
    
    // System Interface
    input  logic                    interrupt_pending,
    input  logic [DATA_WIDTH-1:0]  pc_current,
    output logic                    trap_enable,
    output logic [DATA_WIDTH-1:0]  trap_vector,
    output logic                    privilege_mode,  // 0=user, 1=supervisor
    
    // Debug Interface
    output logic                    debug_mode,
    output logic [DATA_WIDTH-1:0]  debug_pc
);

    // CSR (Control and Status Register) definitions
    typedef enum logic [11:0] {
        CSR_MSTATUS   = 12'h300,  // Machine status
        CSR_MISA      = 12'h301,  // Machine ISA
        CSR_MIE       = 12'h304,  // Machine interrupt enable
        CSR_MTVEC     = 12'h305,  // Machine trap vector
        CSR_MSCRATCH  = 12'h340,  // Machine scratch
        CSR_MEPC      = 12'h341,  // Machine exception PC
        CSR_MCAUSE    = 12'h342,  // Machine cause
        CSR_MTVAL     = 12'h343,  // Machine trap value
        CSR_MIP       = 12'h344,  // Machine interrupt pending
        CSR_CYCLE     = 12'hC00,  // Cycle counter
        CSR_INSTRET   = 12'hC02   // Instructions retired
    } csr_addr_t;

    // CSR registers
    logic [DATA_WIDTH-1:0] csr_mstatus;
    logic [DATA_WIDTH-1:0] csr_misa;
    logic [DATA_WIDTH-1:0] csr_mie;
    logic [DATA_WIDTH-1:0] csr_mtvec;
    logic [DATA_WIDTH-1:0] csr_mscratch;
    logic [DATA_WIDTH-1:0] csr_mepc;
    logic [DATA_WIDTH-1:0] csr_mcause;
    logic [DATA_WIDTH-1:0] csr_mtval;
    logic [DATA_WIDTH-1:0] csr_mip;
    logic [DATA_WIDTH-1:0] csr_cycle;
    logic [DATA_WIDTH-1:0] csr_instret;
    
    // Instruction decode
    logic [6:0]  opcode;
    logic [2:0]  funct3;
    logic [11:0] csr_addr;
    logic [4:0]  rs1;
    logic [4:0]  rd;
    logic [4:0]  zimm;
    
    assign opcode = cp_instruction[6:0];
    assign funct3 = cp_instruction[14:12];
    assign csr_addr = cp_instruction[31:20];
    assign rs1 = cp_instruction[19:15];
    assign rd = cp_instruction[11:7];
    assign zimm = cp_instruction[19:15]; // Zero-extended immediate for CSRR*I
    
    // CSR operation types
    typedef enum logic [2:0] {
        CSR_RW   = 3'b001,  // CSRRW
        CSR_RS   = 3'b010,  // CSRRS
        CSR_RC   = 3'b011,  // CSRRC
        CSR_RWI  = 3'b101,  // CSRRWI
        CSR_RSI  = 3'b110,  // CSRRSI
        CSR_RCI  = 3'b111   // CSRRCI
    } csr_op_t;
    
    // Internal signals
    logic csr_write_enable;
    logic [DATA_WIDTH-1:0] csr_write_data;
    logic [DATA_WIDTH-1:0] csr_read_data;
    logic csr_valid;
    logic is_csr_instruction;
    logic is_immediate_op;
    
    // Detect CSR instructions (SYSTEM opcode)
    assign is_csr_instruction = cp_enable && (opcode == 7'b1110011) && (funct3 != 3'b000);
    assign is_immediate_op = funct3[2]; // Bit 2 indicates immediate operation
    assign csr_valid = is_csr_instruction;
    
    // CSR read logic
    always_comb begin
        csr_read_data = '0;
        case (csr_addr)
            CSR_MSTATUS:  csr_read_data = csr_mstatus;
            CSR_MISA:     csr_read_data = csr_misa;
            CSR_MIE:      csr_read_data = csr_mie;
            CSR_MTVEC:    csr_read_data = csr_mtvec;
            CSR_MSCRATCH: csr_read_data = csr_mscratch;
            CSR_MEPC:     csr_read_data = csr_mepc;
            CSR_MCAUSE:   csr_read_data = csr_mcause;
            CSR_MTVAL:    csr_read_data = csr_mtval;
            CSR_MIP:      csr_read_data = csr_mip;
            CSR_CYCLE:    csr_read_data = csr_cycle;
            CSR_INSTRET:  csr_read_data = csr_instret;
            default:      csr_read_data = '0;
        endcase
    end
    
    // CSR write data calculation
    always_comb begin
        csr_write_enable = 1'b0;
        csr_write_data = '0;
        
        if (csr_valid) begin
            case (funct3)
                CSR_RW, CSR_RWI: begin
                    csr_write_enable = 1'b1;
                    csr_write_data = is_immediate_op ? {{(DATA_WIDTH-5){1'b0}}, zimm} : cp_data_in;
                end
                CSR_RS, CSR_RSI: begin
                    csr_write_enable = (is_immediate_op ? (zimm != 0) : (rs1 != 0));
                    csr_write_data = csr_read_data | (is_immediate_op ? {{(DATA_WIDTH-5){1'b0}}, zimm} : cp_data_in);
                end
                CSR_RC, CSR_RCI: begin
                    csr_write_enable = (is_immediate_op ? (zimm != 0) : (rs1 != 0));
                    csr_write_data = csr_read_data & ~(is_immediate_op ? {{(DATA_WIDTH-5){1'b0}}, zimm} : cp_data_in);
                end
                default: begin
                    csr_write_enable = 1'b0;
                    csr_write_data = '0;
                end
            endcase
        end
    end
    
    // CSR register updates
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            csr_mstatus <= '0;
            csr_misa <= 64'h8000000000141101; // RV64I with some extensions
            csr_mie <= '0;
            csr_mtvec <= '0;
            csr_mscratch <= '0;
            csr_mepc <= '0;
            csr_mcause <= '0;
            csr_mtval <= '0;
            csr_mip <= '0;
            csr_cycle <= '0;
            csr_instret <= '0;
        end else begin
            // Update cycle and instruction counters
            csr_cycle <= csr_cycle + 1;
            if (cp_enable) begin
                csr_instret <= csr_instret + 1;
            end
            
            // Handle interrupt pending
            csr_mip[7] <= interrupt_pending; // Machine timer interrupt
            
            // CSR writes
            if (csr_write_enable) begin
                case (csr_addr)
                    CSR_MSTATUS:  csr_mstatus <= csr_write_data;
                    CSR_MIE:      csr_mie <= csr_write_data;
                    CSR_MTVEC:    csr_mtvec <= csr_write_data;
                    CSR_MSCRATCH: csr_mscratch <= csr_write_data;
                    CSR_MEPC:     csr_mepc <= csr_write_data;
                    CSR_MCAUSE:   csr_mcause <= csr_write_data;
                    CSR_MTVAL:    csr_mtval <= csr_write_data;
                    default: ; // Read-only or invalid CSR
                endcase
            end
        end
    end
    
    // Output assignments
    assign cp_data_out = csr_read_data;
    assign cp_ready = 1'b1; // CSR operations complete in one cycle
    assign cp_exception = csr_valid && (csr_addr == 12'h000); // Invalid CSR address
    
    // System control outputs
    assign trap_enable = interrupt_pending && csr_mie[7] && csr_mstatus[3]; // Machine interrupt enable
    assign trap_vector = csr_mtvec;
    assign privilege_mode = csr_mstatus[3]; // Machine mode
    assign debug_mode = 1'b0; // Not implemented in this basic version
    assign debug_pc = pc_current;

endmodule