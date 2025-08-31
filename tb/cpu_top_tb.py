import cocotb
from cocotb.triggers import RisingEdge, ClockCycles
from cocotb.clock import Clock


# RISC-V Instruction encodings
def encode_r_type(opcode, rd, funct3, rs1, rs2, funct7):
    """Encode R-type RISC-V instruction"""
    return (
        (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode
    )


def encode_i_type(opcode, rd, funct3, rs1, imm):
    """Encode I-type RISC-V instruction"""
    return ((imm & 0xFFF) << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode


def encode_s_type(opcode, funct3, rs1, rs2, imm):
    """Encode S-type RISC-V instruction"""
    imm_11_5 = (imm >> 5) & 0x7F
    imm_4_0 = imm & 0x1F
    return (
        (imm_11_5 << 25)
        | (rs2 << 20)
        | (rs1 << 15)
        | (funct3 << 12)
        | (imm_4_0 << 7)
        | opcode
    )


def encode_b_type(opcode, funct3, rs1, rs2, imm):
    """Encode B-type RISC-V instruction"""
    imm_12 = (imm >> 12) & 0x1
    imm_10_5 = (imm >> 5) & 0x3F
    imm_4_1 = (imm >> 1) & 0xF
    imm_11 = (imm >> 11) & 0x1
    return (
        (imm_12 << 31)
        | (imm_10_5 << 25)
        | (rs2 << 20)
        | (rs1 << 15)
        | (funct3 << 12)
        | (imm_4_1 << 8)
        | (imm_11 << 7)
        | opcode
    )


def encode_u_type(opcode, rd, imm):
    """Encode U-type RISC-V instruction"""
    return ((imm & 0xFFFFF) << 12) | (rd << 7) | opcode


def encode_j_type(opcode, rd, imm):
    """Encode J-type RISC-V instruction"""
    imm_20 = (imm >> 20) & 0x1
    imm_10_1 = (imm >> 1) & 0x3FF
    imm_11 = (imm >> 11) & 0x1
    imm_19_12 = (imm >> 12) & 0xFF
    return (
        (imm_20 << 31)
        | (imm_10_1 << 21)
        | (imm_11 << 20)
        | (imm_19_12 << 12)
        | (rd << 7)
        | opcode
    )


# RISC-V Opcodes
OPCODE_R_TYPE = 0b0110011  # R-type ALU operations
OPCODE_I_TYPE = 0b0010011  # I-type ALU operations
OPCODE_LOAD = 0b0000011  # Load instructions
OPCODE_STORE = 0b0100011  # Store instructions
OPCODE_BRANCH = 0b1100011  # Branch instructions
OPCODE_JAL = 0b1101111  # Jump and link
OPCODE_JALR = 0b1100111  # Jump and link register
OPCODE_LUI = 0b0110111  # Load upper immediate
OPCODE_AUIPC = 0b0010111  # Add upper immediate to PC
OPCODE_SYSTEM = 0b1110011  # System instructions

# Common RISC-V Instructions
NOP = 0x00000013  # ADDI x0, x0, 0


class MemoryModel:
    """Simple memory model for instruction and data"""

    def __init__(self, size=4096):
        self.memory = {}
        self.size = size
        self.pending_read = None
        self.read_delay = 1

    def write(self, addr, data):
        """Write data to memory"""
        if addr < self.size:
            self.memory[addr] = data

    def read(self, addr):
        """Read data from memory"""
        if addr < self.size:
            return self.memory.get(addr, 0)
        return 0

    def load_program(self, program, start_addr=0):
        """Load a program into memory"""
        for i, inst in enumerate(program):
            self.write(start_addr + i * 4, inst)


async def reset_dut(dut):
    """Reset the DUT"""
    dut.rst_n.value = 0
    dut.interr.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)


@cocotb.test()
async def test_basic_alu_operations(dut):
    """Test basic ALU operations (ADD, SUB, etc.)"""

    # Start clock
    clock = Clock(dut.clk, 10, units="ns")  # 100 MHz clock
    cocotb.start_soon(clock.start())

    # Reset DUT
    await reset_dut(dut)

    # Initialize memory models
    imem = MemoryModel()
    dmem = MemoryModel()

    dut._log.info("Testing basic ALU operations...")

    # Create a simple program with ALU operations
    program = [
        encode_i_type(OPCODE_I_TYPE, 1, 0b000, 0, 10),  # ADDI x1, x0, 10
        encode_i_type(OPCODE_I_TYPE, 2, 0b000, 0, 20),  # ADDI x2, x0, 20
        encode_r_type(OPCODE_R_TYPE, 3, 0b000, 1, 2, 0),  # ADD x3, x1, x2
        encode_r_type(OPCODE_R_TYPE, 4, 0b000, 2, 1, 0x20),  # SUB x4, x2, x1
        encode_r_type(OPCODE_R_TYPE, 5, 0b100, 1, 2, 0),  # XOR x5, x1, x2
        encode_r_type(OPCODE_R_TYPE, 6, 0b110, 1, 2, 0),  # OR x6, x1, x2
        encode_r_type(OPCODE_R_TYPE, 7, 0b111, 1, 2, 0),  # AND x7, x1, x2
        NOP,
        NOP,
    ]

    # Load program into instruction memory
    imem.load_program(program)

    # Initialize memory interface signals
    dut.imem_ready.value = 0
    dut.dmem_ready.value = 0
    dut.cp_stall_external.value = 0

    # Run the program
    for cycle in range(50):
        # Handle instruction memory requests
        if dut.imem_read.value:
            addr = int(dut.imem_addr.value)
            dut.imem_read_data.value = imem.read(addr)
            dut.imem_ready.value = 1
        else:
            dut.imem_ready.value = 0

        # Handle data memory requests
        if dut.dmem_read.value:
            addr = int(dut.dmem_addr.value)
            dut.dmem_read_data.value = dmem.read(addr)
            dut.dmem_ready.value = 1
        elif dut.dmem_write.value:
            addr = int(dut.dmem_addr.value)
            data = int(dut.dmem_write_data.value)
            dmem.write(addr, data)
            dut.dmem_ready.value = 1
        else:
            dut.dmem_ready.value = 0

        await RisingEdge(dut.clk)

        # Log PC and state for debugging
        if cycle % 5 == 0:
            pc = int(dut.debug_pc.value)
            state = int(dut.debug_state.value)
            dut._log.info(f"Cycle {cycle}: PC=0x{pc:08x}, State={state}")

    dut._log.info("ALU operations test completed!")


@cocotb.test()
async def test_load_store_operations(dut):
    """Test load and store operations"""

    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset DUT
    await reset_dut(dut)

    # Initialize memory models
    imem = MemoryModel()
    dmem = MemoryModel()

    dut._log.info("Testing load/store operations...")

    # Create a program with load/store operations
    program = [
        encode_i_type(OPCODE_I_TYPE, 1, 0b000, 0, 100),  # ADDI x1, x0, 100 (base addr)
        encode_i_type(OPCODE_I_TYPE, 2, 0b000, 0, 0x42),  # ADDI x2, x0, 0x42 (data)
        encode_s_type(OPCODE_STORE, 0b010, 1, 2, 0),  # SW x2, 0(x1)
        encode_i_type(OPCODE_LOAD, 3, 0b010, 1, 0),  # LW x3, 0(x1)
        encode_i_type(OPCODE_I_TYPE, 4, 0b000, 0, 200),  # ADDI x4, x0, 200
        encode_s_type(OPCODE_STORE, 0b010, 4, 3, 0),  # SW x3, 0(x4)
        NOP,
        NOP,
    ]

    imem.load_program(program)

    # Initialize interface signals
    dut.imem_ready.value = 0
    dut.dmem_ready.value = 0
    dut.cp_stall_external.value = 0

    # Run the program
    for cycle in range(60):
        # Handle instruction memory
        if dut.imem_read.value:
            addr = int(dut.imem_addr.value)
            dut.imem_read_data.value = imem.read(addr)
            dut.imem_ready.value = 1
        else:
            dut.imem_ready.value = 0

        # Handle data memory
        if dut.dmem_read.value:
            addr = int(dut.dmem_addr.value)
            data = dmem.read(addr)
            dut.dmem_read_data.value = data
            dut.dmem_ready.value = 1
            dut._log.info(f"Memory read: addr=0x{addr:08x}, data=0x{data:08x}")
        elif dut.dmem_write.value:
            addr = int(dut.dmem_addr.value)
            data = int(dut.dmem_write_data.value)
            dmem.write(addr, data)
            dut.dmem_ready.value = 1
            dut._log.info(f"Memory write: addr=0x{addr:08x}, data=0x{data:08x}")
        else:
            dut.dmem_ready.value = 0

        await RisingEdge(dut.clk)

    # Verify memory contents
    assert dmem.read(100) == 0x42, (
        f"Memory at 100 should be 0x42, got 0x{dmem.read(100):08x}"
    )
    assert dmem.read(200) == 0x42, (
        f"Memory at 200 should be 0x42, got 0x{dmem.read(200):08x}"
    )

    dut._log.info("Load/store operations test PASSED!")


@cocotb.test()
async def test_branch_operations(dut):
    """Test branch operations"""

    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset DUT
    await reset_dut(dut)

    # Initialize memory models
    imem = MemoryModel()
    dmem = MemoryModel()

    dut._log.info("Testing branch operations...")

    # Create a program with branch operations
    program = [
        encode_i_type(OPCODE_I_TYPE, 1, 0b000, 0, 5),  # ADDI x1, x0, 5
        encode_i_type(OPCODE_I_TYPE, 2, 0b000, 0, 5),  # ADDI x2, x0, 5
        encode_b_type(OPCODE_BRANCH, 0b000, 1, 2, 8),  # BEQ x1, x2, +8 (should branch)
        encode_i_type(
            OPCODE_I_TYPE, 3, 0b000, 0, 0xFF
        ),  # ADDI x3, x0, 0xFF (should skip)
        encode_i_type(OPCODE_I_TYPE, 4, 0b000, 0, 0xAA),  # ADDI x4, x0, 0xAA (target)
        encode_b_type(
            OPCODE_BRANCH, 0b001, 1, 2, 8
        ),  # BNE x1, x2, +8 (should not branch)
        encode_i_type(OPCODE_I_TYPE, 5, 0b000, 0, 0xBB),  # ADDI x5, x0, 0xBB
        NOP,
        NOP,
    ]

    imem.load_program(program)

    # Initialize interface signals
    dut.imem_ready.value = 0
    dut.dmem_ready.value = 0
    dut.cp_stall_external.value = 0

    # Track PC values to verify branches
    pc_history = []

    # Run the program
    for cycle in range(50):
        # Handle instruction memory
        if dut.imem_read.value:
            addr = int(dut.imem_addr.value)
            dut.imem_read_data.value = imem.read(addr)
            dut.imem_ready.value = 1
        else:
            dut.imem_ready.value = 0

        # Handle data memory
        if dut.dmem_read.value:
            addr = int(dut.dmem_addr.value)
            dut.dmem_read_data.value = dmem.read(addr)
            dut.dmem_ready.value = 1
        elif dut.dmem_write.value:
            addr = int(dut.dmem_addr.value)
            data = int(dut.dmem_write_data.value)
            dmem.write(addr, data)
            dut.dmem_ready.value = 1
        else:
            dut.dmem_ready.value = 0

        # Track PC
        pc = int(dut.debug_pc.value)
        if cycle > 0 and pc not in pc_history:
            pc_history.append(pc)

        await RisingEdge(dut.clk)

        if cycle % 5 == 0:
            state = int(dut.debug_state.value)
            dut._log.info(f"Cycle {cycle}: PC=0x{pc:08x}, State={state}")

    dut._log.info(f"PC history: {[hex(pc) for pc in pc_history]}")
    dut._log.info("Branch operations test completed!")


@cocotb.test()
async def test_jump_operations(dut):
    """Test JAL and JALR operations"""

    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset DUT
    await reset_dut(dut)

    # Initialize memory models
    imem = MemoryModel()
    dmem = MemoryModel()

    dut._log.info("Testing jump operations...")

    # Create a program with jump operations
    program = [
        encode_j_type(OPCODE_JAL, 1, 12),  # JAL x1, +12 (jump forward)
        encode_i_type(
            OPCODE_I_TYPE, 2, 0b000, 0, 0xFF
        ),  # ADDI x2, x0, 0xFF (should skip)
        encode_i_type(
            OPCODE_I_TYPE, 3, 0b000, 0, 0xFF
        ),  # ADDI x3, x0, 0xFF (should skip)
        encode_i_type(OPCODE_I_TYPE, 4, 0b000, 0, 0xAA),  # ADDI x4, x0, 0xAA (target)
        encode_i_type(OPCODE_I_TYPE, 5, 0b000, 0, 32),  # ADDI x5, x0, 32
        encode_i_type(OPCODE_JALR, 6, 0b000, 5, 0),  # JALR x6, 0(x5)
        NOP,
        NOP,
    ]

    # Add code at address 32
    program.extend([NOP] * 4)  # Padding
    program[8] = encode_i_type(OPCODE_I_TYPE, 7, 0b000, 0, 0xCC)  # ADDI x7, x0, 0xCC

    imem.load_program(program)

    # Initialize interface signals
    dut.imem_ready.value = 0
    dut.dmem_ready.value = 0
    dut.cp_stall_external.value = 0

    # Run the program
    for cycle in range(60):
        # Handle instruction memory
        if dut.imem_read.value:
            addr = int(dut.imem_addr.value)
            dut.imem_read_data.value = imem.read(addr)
            dut.imem_ready.value = 1
        else:
            dut.imem_ready.value = 0

        # Handle data memory
        if dut.dmem_read.value or dut.dmem_write.value:
            dut.dmem_ready.value = 1
        else:
            dut.dmem_ready.value = 0

        await RisingEdge(dut.clk)

        if cycle % 5 == 0:
            pc = int(dut.debug_pc.value)
            state = int(dut.debug_state.value)
            dut._log.info(f"Cycle {cycle}: PC=0x{pc:08x}, State={state}")

    dut._log.info("Jump operations test completed!")


@cocotb.test()
async def test_lui_auipc_operations(dut):
    """Test LUI and AUIPC operations"""

    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset DUT
    await reset_dut(dut)

    # Initialize memory models
    imem = MemoryModel()
    dmem = MemoryModel()

    dut._log.info("Testing LUI and AUIPC operations...")

    # Create a program with LUI and AUIPC
    program = [
        encode_u_type(OPCODE_LUI, 1, 0x12345),  # LUI x1, 0x12345
        encode_u_type(OPCODE_AUIPC, 2, 0x1000),  # AUIPC x2, 0x1000
        encode_i_type(OPCODE_I_TYPE, 3, 0b000, 1, 0x678),  # ADDI x3, x1, 0x678
        NOP,
        NOP,
    ]

    imem.load_program(program)

    # Initialize interface signals
    dut.imem_ready.value = 0
    dut.dmem_ready.value = 0
    dut.cp_stall_external.value = 0

    # Run the program
    for cycle in range(40):
        # Handle instruction memory
        if dut.imem_read.value:
            addr = int(dut.imem_addr.value)
            dut.imem_read_data.value = imem.read(addr)
            dut.imem_ready.value = 1
        else:
            dut.imem_ready.value = 0

        # Handle data memory
        dut.dmem_ready.value = 1

        await RisingEdge(dut.clk)

        if cycle % 5 == 0:
            pc = int(dut.debug_pc.value)
            state = int(dut.debug_state.value)
            dut._log.info(f"Cycle {cycle}: PC=0x{pc:08x}, State={state}")

    dut._log.info("LUI/AUIPC operations test completed!")


@cocotb.test()
async def test_pipeline_stalls(dut):
    """Test pipeline stalls and hazard detection"""

    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset DUT
    await reset_dut(dut)

    # Initialize memory models
    imem = MemoryModel()
    dmem = MemoryModel()

    dut._log.info("Testing pipeline stalls...")

    # Create a program with data hazards
    program = [
        encode_i_type(OPCODE_I_TYPE, 1, 0b000, 0, 10),  # ADDI x1, x0, 10
        encode_i_type(OPCODE_I_TYPE, 2, 0b000, 1, 20),  # ADDI x2, x1, 20 (RAW hazard)
        encode_i_type(OPCODE_LOAD, 3, 0b010, 0, 100),  # LW x3, 100(x0)
        encode_r_type(
            OPCODE_R_TYPE, 4, 0b000, 3, 1, 0
        ),  # ADD x4, x3, x1 (load-use hazard)
        NOP,
        NOP,
    ]

    imem.load_program(program)
    dmem.write(100, 0x42)

    # Initialize interface signals
    dut.imem_ready.value = 0
    dut.dmem_ready.value = 0
    dut.cp_stall_external.value = 0

    stall_count = 0

    # Run the program
    for cycle in range(60):
        # Handle instruction memory with occasional delays
        if dut.imem_read.value:
            addr = int(dut.imem_addr.value)
            dut.imem_read_data.value = imem.read(addr)
            # Simulate occasional memory delays
            if cycle % 10 == 0:
                dut.imem_ready.value = 0
            else:
                dut.imem_ready.value = 1
        else:
            dut.imem_ready.value = 0

        # Handle data memory
        if dut.dmem_read.value:
            addr = int(dut.dmem_addr.value)
            dut.dmem_read_data.value = dmem.read(addr)
            dut.dmem_ready.value = 1
        elif dut.dmem_write.value:
            addr = int(dut.dmem_addr.value)
            data = int(dut.dmem_write_data.value)
            dmem.write(addr, data)
            dut.dmem_ready.value = 1
        else:
            dut.dmem_ready.value = 0

        # Count stalls
        if dut.debug_stall.value:
            stall_count += 1

        await RisingEdge(dut.clk)

        if cycle % 5 == 0:
            pc = int(dut.debug_pc.value)
            state = int(dut.debug_state.value)
            stall = int(dut.debug_stall.value)
            dut._log.info(f"Cycle {cycle}: PC=0x{pc:08x}, State={state}, Stall={stall}")

    dut._log.info(f"Total stalls: {stall_count}")
    dut._log.info("Pipeline stall test completed!")


@cocotb.test()
async def test_interrupt_handling(dut):
    """Test interrupt signal handling"""

    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset DUT
    await reset_dut(dut)

    # Initialize memory models
    imem = MemoryModel()
    dmem = MemoryModel()

    dut._log.info("Testing interrupt handling...")

    # Simple program
    program = [
        encode_i_type(OPCODE_I_TYPE, 1, 0b000, 0, 1),  # ADDI x1, x0, 1
        encode_i_type(OPCODE_I_TYPE, 2, 0b000, 1, 1),  # ADDI x2, x1, 1
        encode_i_type(OPCODE_I_TYPE, 3, 0b000, 2, 1),  # ADDI x3, x2, 1
        encode_i_type(OPCODE_I_TYPE, 4, 0b000, 3, 1),  # ADDI x4, x3, 1
        NOP,
        NOP,
    ]

    imem.load_program(program)

    # Initialize interface signals
    dut.imem_ready.value = 1
    dut.dmem_ready.value = 1
    dut.cp_stall_external.value = 0

    # Run the program with interrupts
    for cycle in range(50):
        # Handle instruction memory
        if dut.imem_read.value:
            addr = int(dut.imem_addr.value)
            dut.imem_read_data.value = imem.read(addr)

        # Assert interrupt at cycle 20
        if cycle == 20:
            dut._log.info("Asserting interrupt...")
            dut.interr.value = 1
        elif cycle == 25:
            dut.interr.value = 0

        await RisingEdge(dut.clk)

        if cycle % 5 == 0:
            pc = int(dut.debug_pc.value)
            state = int(dut.debug_state.value)
            dut._log.info(
                f"Cycle {cycle}: PC=0x{pc:08x}, State={state}, INT={int(dut.interr.value)}"
            )

    dut._log.info("Interrupt handling test completed!")


@cocotb.test()
async def test_coprocessor_interface(dut):
    """Test coprocessor interface signals"""

    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset DUT
    await reset_dut(dut)

    # Initialize memory models
    imem = MemoryModel()
    dmem = MemoryModel()

    dut._log.info("Testing coprocessor interface...")

    # Create a program with system instructions (triggers coprocessor)
    program = [
        encode_i_type(OPCODE_I_TYPE, 1, 0b000, 0, 10),  # ADDI x1, x0, 10
        encode_i_type(OPCODE_SYSTEM, 0, 0b000, 0, 0),  # ECALL (system instruction)
        encode_i_type(OPCODE_I_TYPE, 2, 0b000, 0, 20),  # ADDI x2, x0, 20
        encode_i_type(OPCODE_SYSTEM, 0, 0b000, 0, 1),  # EBREAK (system instruction)
        NOP,
        NOP,
    ]

    imem.load_program(program)

    # Initialize interface signals
    dut.imem_ready.value = 1
    dut.dmem_ready.value = 1
    dut.cp_stall_external.value = 0

    cp_detected_count = 0

    # Run the program
    for cycle in range(50):
        # Handle instruction memory
        if dut.imem_read.value:
            addr = int(dut.imem_addr.value)
            dut.imem_read_data.value = imem.read(addr)

        # Simulate coprocessor delay
        if dut.cp_instruction_detected.value:
            cp_detected_count += 1
            dut._log.info(f"Coprocessor instruction detected at cycle {cycle}")
            if cycle % 3 == 0:
                dut.cp_stall_external.value = 1
            else:
                dut.cp_stall_external.value = 0
        else:
            dut.cp_stall_external.value = 0

        await RisingEdge(dut.clk)

        if cycle % 5 == 0:
            pc = int(dut.debug_pc.value)
            state = int(dut.debug_state.value)
            cp_det = int(dut.cp_instruction_detected.value)
            dut._log.info(
                f"Cycle {cycle}: PC=0x{pc:08x}, State={state}, CP_DET={cp_det}"
            )

    dut._log.info(f"Coprocessor instructions detected: {cp_detected_count}")
    dut._log.info("Coprocessor interface test completed!")


# Run all tests
if __name__ == "__main__":
    import sys
    import os

    # Set default test runner behavior
    os.environ["COCOTB_REDUCED_LOG_FMT"] = "1"

    # Run the tests
    import cocotb.runner

    cocotb.runner.get_runner().test()
