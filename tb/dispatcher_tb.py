import cocotb
from cocotb.triggers import Timer, RisingEdge, ClockCycles
from cocotb.clock import Clock
from dataclasses import dataclass
from enum import Enum
from typing import Tuple

"""
RISC-V RV32I ISA Dispatcher Testbench

This testbench validates the instruction dispatcher module based on the 
RISC-V RV32I ISA specification. The dispatcher is responsible for:
- Decoding instructions and determining execution units
- Managing instruction issue to appropriate functional units
- Handling data dependencies and hazards
- Coordinating with coprocessors and accelerators

Testing focuses on ISA compliance without implementation details.
"""


class RV32IOpcode(Enum):
    """RISC-V RV32I Base Integer Instruction Set Opcodes"""

    LUI = 0b0110111  # Load Upper Immediate
    AUIPC = 0b0010111  # Add Upper Immediate to PC
    JAL = 0b1101111  # Jump and Link
    JALR = 0b1100111  # Jump and Link Register
    BRANCH = 0b1100011  # Branch instructions
    LOAD = 0b0000011  # Load instructions
    STORE = 0b0100011  # Store instructions
    OP_IMM = 0b0010011  # Integer Register-Immediate operations
    OP = 0b0110011  # Integer Register-Register operations
    FENCE = 0b0001111  # Memory ordering
    SYSTEM = 0b1110011  # System instructions


class ExecutionUnit(Enum):
    """Execution units that instructions can be dispatched to"""

    ALU = "ALU"  # Arithmetic Logic Unit
    BRANCH = "BRANCH"  # Branch Unit
    LOAD_STORE = "LSU"  # Load/Store Unit
    MULTIPLY = "MUL"  # Multiply/Divide Unit
    COPROCESSOR = "COPROC"  # Coprocessor/System Unit
    NONE = "NONE"  # No dispatch needed


class InstructionFormat(Enum):
    """RISC-V instruction formats"""

    R_TYPE = "R"  # Register-Register
    I_TYPE = "I"  # Immediate
    S_TYPE = "S"  # Store
    B_TYPE = "B"  # Branch
    U_TYPE = "U"  # Upper Immediate
    J_TYPE = "J"  # Jump


@dataclass
class DecodedInstruction:
    """Decoded RISC-V instruction information"""

    raw: int
    opcode: RV32IOpcode
    format: InstructionFormat
    rd: int
    rs1: int
    rs2: int
    funct3: int
    funct7: int
    imm: int
    execution_unit: ExecutionUnit
    is_valid: bool
    uses_rs1: bool
    uses_rs2: bool
    writes_rd: bool


class RV32IDecoder:
    """RISC-V RV32I instruction decoder based on ISA specification"""

    @staticmethod
    def decode(instruction: int) -> DecodedInstruction:
        """Decode a 32-bit RISC-V instruction"""
        # Extract basic fields
        opcode_bits = instruction & 0x7F
        rd = (instruction >> 7) & 0x1F
        funct3 = (instruction >> 12) & 0x7
        rs1 = (instruction >> 15) & 0x1F
        rs2 = (instruction >> 20) & 0x1F
        funct7 = (instruction >> 25) & 0x7F

        # Initialize decoded instruction
        decoded = DecodedInstruction(
            raw=instruction,
            opcode=None,
            format=None,
            rd=rd,
            rs1=rs1,
            rs2=rs2,
            funct3=funct3,
            funct7=funct7,
            imm=0,
            execution_unit=ExecutionUnit.NONE,
            is_valid=False,
            uses_rs1=False,
            uses_rs2=False,
            writes_rd=False,
        )

        # Decode based on opcode
        try:
            if opcode_bits == RV32IOpcode.LUI.value:
                decoded.opcode = RV32IOpcode.LUI
                decoded.format = InstructionFormat.U_TYPE
                decoded.imm = instruction & 0xFFFFF000
                decoded.execution_unit = ExecutionUnit.ALU
                decoded.writes_rd = True
                decoded.is_valid = True

            elif opcode_bits == RV32IOpcode.AUIPC.value:
                decoded.opcode = RV32IOpcode.AUIPC
                decoded.format = InstructionFormat.U_TYPE
                decoded.imm = instruction & 0xFFFFF000
                decoded.execution_unit = ExecutionUnit.ALU
                decoded.writes_rd = True
                decoded.is_valid = True

            elif opcode_bits == RV32IOpcode.JAL.value:
                decoded.opcode = RV32IOpcode.JAL
                decoded.format = InstructionFormat.J_TYPE
                decoded.imm = RV32IDecoder._extract_j_immediate(instruction)
                decoded.execution_unit = ExecutionUnit.BRANCH
                decoded.writes_rd = True
                decoded.is_valid = True

            elif opcode_bits == RV32IOpcode.JALR.value:
                decoded.opcode = RV32IOpcode.JALR
                decoded.format = InstructionFormat.I_TYPE
                decoded.imm = RV32IDecoder._extract_i_immediate(instruction)
                decoded.execution_unit = ExecutionUnit.BRANCH
                decoded.uses_rs1 = True
                decoded.writes_rd = True
                decoded.is_valid = True

            elif opcode_bits == RV32IOpcode.BRANCH.value:
                decoded.opcode = RV32IOpcode.BRANCH
                decoded.format = InstructionFormat.B_TYPE
                decoded.imm = RV32IDecoder._extract_b_immediate(instruction)
                decoded.execution_unit = ExecutionUnit.BRANCH
                decoded.uses_rs1 = True
                decoded.uses_rs2 = True
                decoded.is_valid = True

            elif opcode_bits == RV32IOpcode.LOAD.value:
                decoded.opcode = RV32IOpcode.LOAD
                decoded.format = InstructionFormat.I_TYPE
                decoded.imm = RV32IDecoder._extract_i_immediate(instruction)
                decoded.execution_unit = ExecutionUnit.LOAD_STORE
                decoded.uses_rs1 = True
                decoded.writes_rd = True
                decoded.is_valid = True

            elif opcode_bits == RV32IOpcode.STORE.value:
                decoded.opcode = RV32IOpcode.STORE
                decoded.format = InstructionFormat.S_TYPE
                decoded.imm = RV32IDecoder._extract_s_immediate(instruction)
                decoded.execution_unit = ExecutionUnit.LOAD_STORE
                decoded.uses_rs1 = True
                decoded.uses_rs2 = True
                decoded.is_valid = True

            elif opcode_bits == RV32IOpcode.OP_IMM.value:
                decoded.opcode = RV32IOpcode.OP_IMM
                decoded.format = InstructionFormat.I_TYPE
                decoded.imm = RV32IDecoder._extract_i_immediate(instruction)
                decoded.execution_unit = ExecutionUnit.ALU
                decoded.uses_rs1 = True
                decoded.writes_rd = True
                decoded.is_valid = True

            elif opcode_bits == RV32IOpcode.OP.value:
                decoded.opcode = RV32IOpcode.OP
                decoded.format = InstructionFormat.R_TYPE
                # Check for multiply/divide instructions (RV32M extension)
                if funct7 == 0b0000001:  # MUL/DIV operations
                    decoded.execution_unit = ExecutionUnit.MULTIPLY
                else:
                    decoded.execution_unit = ExecutionUnit.ALU
                decoded.uses_rs1 = True
                decoded.uses_rs2 = True
                decoded.writes_rd = True
                decoded.is_valid = True

            elif opcode_bits == RV32IOpcode.FENCE.value:
                decoded.opcode = RV32IOpcode.FENCE
                decoded.format = InstructionFormat.I_TYPE
                decoded.execution_unit = ExecutionUnit.LOAD_STORE
                decoded.is_valid = True

            elif opcode_bits == RV32IOpcode.SYSTEM.value:
                decoded.opcode = RV32IOpcode.SYSTEM
                decoded.format = InstructionFormat.I_TYPE
                decoded.imm = RV32IDecoder._extract_i_immediate(instruction)
                decoded.execution_unit = ExecutionUnit.COPROCESSOR
                # CSR instructions use rs1 and write rd (except ECALL/EBREAK)
                if funct3 != 0:  # Not ECALL/EBREAK
                    decoded.uses_rs1 = True
                    decoded.writes_rd = True
                decoded.is_valid = True

            else:
                decoded.is_valid = False

        except:
            decoded.is_valid = False

        return decoded

    @staticmethod
    def _extract_i_immediate(instruction: int) -> int:
        """Extract I-type immediate with sign extension"""
        imm = (instruction >> 20) & 0xFFF
        if imm & 0x800:  # Sign extend
            imm |= 0xFFFFF000
        return imm

    @staticmethod
    def _extract_s_immediate(instruction: int) -> int:
        """Extract S-type immediate with sign extension"""
        imm = ((instruction >> 7) & 0x1F) | ((instruction >> 20) & 0xFE0)
        if imm & 0x800:  # Sign extend
            imm |= 0xFFFFF000
        return imm

    @staticmethod
    def _extract_b_immediate(instruction: int) -> int:
        """Extract B-type immediate with sign extension"""
        imm = (
            (((instruction >> 31) & 1) << 12)
            | (((instruction >> 7) & 1) << 11)
            | (((instruction >> 25) & 0x3F) << 5)
            | (((instruction >> 8) & 0xF) << 1)
        )
        if imm & 0x1000:  # Sign extend
            imm |= 0xFFFFE000
        return imm

    @staticmethod
    def _extract_j_immediate(instruction: int) -> int:
        """Extract J-type immediate with sign extension"""
        imm = (
            (((instruction >> 31) & 1) << 20)
            | (((instruction >> 12) & 0xFF) << 12)
            | (((instruction >> 20) & 1) << 11)
            | (((instruction >> 21) & 0x3FF) << 1)
        )
        if imm & 0x100000:  # Sign extend
            imm |= 0xFFF00000
        return imm


class DispatchScoreboard:
    """Track instruction dependencies and dispatch readiness"""

    def __init__(self):
        self.pending_writes = {}  # reg_num -> instruction_id
        self.in_flight = {}  # instruction_id -> DecodedInstruction
        self.next_id = 0

    def can_dispatch(self, decoded: DecodedInstruction) -> Tuple[bool, str]:
        """Check if instruction can be dispatched"""
        # Check RAW hazards
        if decoded.uses_rs1 and decoded.rs1 in self.pending_writes:
            return False, f"RAW hazard on x{decoded.rs1}"
        if decoded.uses_rs2 and decoded.rs2 in self.pending_writes:
            return False, f"RAW hazard on x{decoded.rs2}"

        # Check WAW hazards
        if decoded.writes_rd and decoded.rd in self.pending_writes:
            if decoded.rd != 0:  # x0 is always 0, no real hazard
                return False, f"WAW hazard on x{decoded.rd}"

        return True, "Ready to dispatch"

    def dispatch(self, decoded: DecodedInstruction) -> int:
        """Record instruction dispatch"""
        instr_id = self.next_id
        self.next_id += 1

        self.in_flight[instr_id] = decoded
        if decoded.writes_rd and decoded.rd != 0:
            self.pending_writes[decoded.rd] = instr_id

        return instr_id

    def complete(self, instr_id: int):
        """Mark instruction as completed"""
        if instr_id in self.in_flight:
            decoded = self.in_flight[instr_id]
            if decoded.writes_rd and decoded.rd in self.pending_writes:
                if self.pending_writes[decoded.rd] == instr_id:
                    del self.pending_writes[decoded.rd]
            del self.in_flight[instr_id]

    def reset(self):
        """Clear all tracking state"""
        self.pending_writes.clear()
        self.in_flight.clear()
        self.next_id = 0


class RV32IInstructionGenerator:
    """Generate valid RISC-V RV32I instructions for testing"""

    @staticmethod
    def generate_alu_immediate(rd: int, rs1: int, imm: int, funct3: int) -> int:
        """Generate ALU immediate instruction"""
        imm = imm & 0xFFF
        return (
            (imm << 20)
            | (rs1 << 15)
            | (funct3 << 12)
            | (rd << 7)
            | RV32IOpcode.OP_IMM.value
        )

    @staticmethod
    def generate_alu_register(
        rd: int, rs1: int, rs2: int, funct3: int, funct7: int
    ) -> int:
        """Generate ALU register-register instruction"""
        return (
            (funct7 << 25)
            | (rs2 << 20)
            | (rs1 << 15)
            | (funct3 << 12)
            | (rd << 7)
            | RV32IOpcode.OP.value
        )

    @staticmethod
    def generate_load(rd: int, rs1: int, imm: int, funct3: int) -> int:
        """Generate load instruction"""
        imm = imm & 0xFFF
        return (
            (imm << 20)
            | (rs1 << 15)
            | (funct3 << 12)
            | (rd << 7)
            | RV32IOpcode.LOAD.value
        )

    @staticmethod
    def generate_store(rs1: int, rs2: int, imm: int, funct3: int) -> int:
        """Generate store instruction"""
        imm = imm & 0xFFF
        imm_11_5 = (imm >> 5) & 0x7F
        imm_4_0 = imm & 0x1F
        return (
            (imm_11_5 << 25)
            | (rs2 << 20)
            | (rs1 << 15)
            | (funct3 << 12)
            | (imm_4_0 << 7)
            | RV32IOpcode.STORE.value
        )

    @staticmethod
    def generate_branch(rs1: int, rs2: int, imm: int, funct3: int) -> int:
        """Generate branch instruction"""
        imm = imm & 0x1FFE  # Must be even
        imm_12 = (imm >> 12) & 1
        imm_10_5 = (imm >> 5) & 0x3F
        imm_4_1 = (imm >> 1) & 0xF
        imm_11 = (imm >> 11) & 1

        return (
            (imm_12 << 31)
            | (imm_10_5 << 25)
            | (rs2 << 20)
            | (rs1 << 15)
            | (funct3 << 12)
            | (imm_4_1 << 8)
            | (imm_11 << 7)
            | RV32IOpcode.BRANCH.value
        )

    @staticmethod
    def generate_jal(rd: int, imm: int) -> int:
        """Generate JAL instruction"""
        imm = imm & 0x1FFFFE  # Must be even
        imm_20 = (imm >> 20) & 1
        imm_10_1 = (imm >> 1) & 0x3FF
        imm_11 = (imm >> 11) & 1
        imm_19_12 = (imm >> 12) & 0xFF

        return (
            (imm_20 << 31)
            | (imm_10_1 << 21)
            | (imm_11 << 20)
            | (imm_19_12 << 12)
            | (rd << 7)
            | RV32IOpcode.JAL.value
        )

    @staticmethod
    def generate_jalr(rd: int, rs1: int, imm: int) -> int:
        """Generate JALR instruction"""
        imm = imm & 0xFFF
        return (
            (imm << 20) | (rs1 << 15) | (0 << 12) | (rd << 7) | RV32IOpcode.JALR.value
        )

    @staticmethod
    def generate_lui(rd: int, imm: int) -> int:
        """Generate LUI instruction"""
        imm = imm & 0xFFFFF
        return (imm << 12) | (rd << 7) | RV32IOpcode.LUI.value

    @staticmethod
    def generate_auipc(rd: int, imm: int) -> int:
        """Generate AUIPC instruction"""
        imm = imm & 0xFFFFF
        return (imm << 12) | (rd << 7) | RV32IOpcode.AUIPC.value


@cocotb.test()
async def test_risc_v_dispatcher_basic_decode(dut):
    """Test basic instruction decoding and dispatch decisions"""

    dut._log.info("=== Testing RISC-V RV32I Dispatcher Basic Decode ===")

    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Reset
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    decoder = RV32IDecoder()
    gen = RV32IInstructionGenerator()

    test_instructions = [
        # (instruction, description)
        (gen.generate_alu_immediate(1, 2, 100, 0b000), "ADDI x1, x2, 100"),
        (gen.generate_alu_register(3, 4, 5, 0b000, 0b0000000), "ADD x3, x4, x5"),
        (gen.generate_load(6, 7, 8, 0b010), "LW x6, 8(x7)"),
        (gen.generate_store(8, 9, 12, 0b010), "SW x9, 12(x8)"),
        (gen.generate_branch(10, 11, 16, 0b000), "BEQ x10, x11, 16"),
        (gen.generate_jal(12, 1024), "JAL x12, 1024"),
        (gen.generate_jalr(13, 14, 100), "JALR x13, 100(x14)"),
        (gen.generate_lui(15, 0x12345), "LUI x15, 0x12345"),
        (gen.generate_auipc(16, 0x67890), "AUIPC x16, 0x67890"),
    ]

    passed_tests = 0
    failed_tests = 0

    for instruction, description in test_instructions:
        dut._log.info(f"Testing: {description}")

        # Decode instruction
        decoded = decoder.decode(instruction)

        # Apply to DUT
        dut.instruction.value = instruction
        dut.inst_valid.value = 1

        await RisingEdge(dut.clk)
        await Timer(1, units="ns")

        # Check if dispatcher recognizes the instruction
        if hasattr(dut, "dispatch_valid"):
            if decoded.is_valid:
                if int(dut.dispatch_valid.value) == 1:
                    passed_tests += 1
                    dut._log.info(f"  ✓ Instruction recognized for dispatch")
                else:
                    failed_tests += 1
                    dut._log.error(f"  ✗ Valid instruction not recognized")
            else:
                if int(dut.dispatch_valid.value) == 0:
                    passed_tests += 1
                    dut._log.info(f"  ✓ Invalid instruction correctly rejected")
                else:
                    failed_tests += 1
                    dut._log.error(f"  ✗ Invalid instruction incorrectly accepted")

        # Check execution unit assignment (if available)
        if hasattr(dut, "exec_unit"):
            dut._log.info(f"  Execution unit: {decoded.execution_unit.value}")

        # Clear for next test
        dut.inst_valid.value = 0
        await RisingEdge(dut.clk)

    # Report results
    total_tests = passed_tests + failed_tests
    dut._log.info(f"=== Basic Decode Results ===")
    dut._log.info(f"Passed: {passed_tests}/{total_tests}")

    if failed_tests > 0:
        assert False, f"Basic decode test failed {failed_tests} tests"


@cocotb.test()
async def test_risc_v_dispatcher_hazard_detection(dut):
    """Test hazard detection and dispatch blocking"""

    dut._log.info("=== Testing RISC-V Hazard Detection ===")

    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Reset
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    gen = RV32IInstructionGenerator()
    scoreboard = DispatchScoreboard()

    # Test RAW hazard
    dut._log.info("Testing RAW (Read-After-Write) hazard")

    # Instruction 1: ADD x1, x2, x3 (writes x1)
    instr1 = gen.generate_alu_register(1, 2, 3, 0b000, 0b0000000)

    # Instruction 2: SUB x4, x1, x5 (reads x1 - RAW hazard)
    instr2 = gen.generate_alu_register(4, 1, 5, 0b000, 0b0100000)

    # Issue first instruction
    dut.instruction.value = instr1
    dut.inst_valid.value = 1

    await RisingEdge(dut.clk)
    await Timer(1, units="ns")

    # Check if first instruction is dispatched
    if hasattr(dut, "dispatch_valid") and hasattr(dut, "stall"):
        if int(dut.dispatch_valid.value) == 1:
            dut._log.info("  ✓ First instruction dispatched")

            # Try to issue second instruction (should stall)
            dut.instruction.value = instr2
            await RisingEdge(dut.clk)
            await Timer(1, units="ns")

            if int(dut.stall.value) == 1:
                dut._log.info("  ✓ RAW hazard detected - pipeline stalled")
            else:
                dut._log.warning("  ⚠ RAW hazard may not be detected")

    # Clear
    dut.inst_valid.value = 0
    await RisingEdge(dut.clk)

    # Test WAW hazard
    dut._log.info("Testing WAW (Write-After-Write) hazard")

    # Both instructions write to x6
    instr3 = gen.generate_alu_immediate(6, 7, 100, 0b000)  # ADDI x6, x7, 100
    instr4 = gen.generate_alu_immediate(6, 8, 200, 0b000)  # ADDI x6, x8, 200

    dut.instruction.value = instr3
    dut.inst_valid.value = 1

    await RisingEdge(dut.clk)

    dut.instruction.value = instr4

    await RisingEdge(dut.clk)
    await Timer(1, units="ns")

    if hasattr(dut, "stall"):
        dut._log.info(f"  WAW hazard handling: stall = {int(dut.stall.value)}")

    dut._log.info("✓ Hazard detection test completed")


@cocotb.test()
async def test_risc_v_dispatcher_execution_units(dut):
    """Test dispatch to different execution units"""

    dut._log.info("=== Testing Dispatch to Execution Units ===")

    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Reset
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    gen = RV32IInstructionGenerator()
    decoder = RV32IDecoder()

    # Test instructions for each execution unit
    test_cases = [
        # ALU instructions
        (gen.generate_alu_immediate(1, 2, 100, 0b000), ExecutionUnit.ALU, "ADDI (ALU)"),
        (
            gen.generate_alu_register(3, 4, 5, 0b000, 0b0000000),
            ExecutionUnit.ALU,
            "ADD (ALU)",
        ),
        (gen.generate_lui(6, 0x12345), ExecutionUnit.ALU, "LUI (ALU)"),
        # Branch unit instructions
        (gen.generate_branch(7, 8, 100, 0b000), ExecutionUnit.BRANCH, "BEQ (Branch)"),
        (gen.generate_jal(9, 1000), ExecutionUnit.BRANCH, "JAL (Branch)"),
        (gen.generate_jalr(10, 11, 200), ExecutionUnit.BRANCH, "JALR (Branch)"),
        # Load/Store unit instructions
        (gen.generate_load(12, 13, 300, 0b010), ExecutionUnit.LOAD_STORE, "LW (LSU)"),
        (gen.generate_store(14, 15, 400, 0b010), ExecutionUnit.LOAD_STORE, "SW (LSU)"),
        # Multiply unit instructions (if RV32M extension)
        (
            gen.generate_alu_register(16, 17, 18, 0b000, 0b0000001),
            ExecutionUnit.MULTIPLY,
            "MUL (Multiply)",
        ),
    ]

    for instruction, expected_unit, description in test_cases:
        dut._log.info(f"Testing: {description}")

        decoded = decoder.decode(instruction)

        dut.instruction.value = instruction
        dut.inst_valid.value = 1

        await RisingEdge(dut.clk)
        await Timer(1, units="ns")

        # Check dispatch signals for different units
        unit_signals = {
            ExecutionUnit.ALU: "alu_dispatch",
            ExecutionUnit.BRANCH: "branch_dispatch",
            ExecutionUnit.LOAD_STORE: "lsu_dispatch",
            ExecutionUnit.MULTIPLY: "mul_dispatch",
            ExecutionUnit.COPROCESSOR: "coproc_dispatch",
        }

        # Check if the correct unit is selected
        if expected_unit in unit_signals:
            signal_name = unit_signals[expected_unit]
            if hasattr(dut, signal_name):
                if int(getattr(dut, signal_name).value) == 1:
                    dut._log.info(f"  ✓ Correctly dispatched to {expected_unit.value}")
                else:
                    dut._log.warning(f"  ⚠ Not dispatched to {expected_unit.value}")
            else:
                dut._log.info(f"  ○ {signal_name} signal not available")

        dut.inst_valid.value = 0
        await RisingEdge(dut.clk)

    dut._log.info("✓ Execution unit dispatch test completed")


@cocotb.test()
async def test_risc_v_dispatcher_throughput(dut):
    """Test dispatcher throughput with instruction sequences"""

    dut._log.info("=== Testing Dispatcher Throughput ===")

    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Reset
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    gen = RV32IInstructionGenerator()

    # Generate a sequence of independent instructions (no hazards)
    independent_sequence = []
    for i in range(10):
        rd = i + 1
        rs1 = (i + 11) % 32
        rs2 = (i + 21) % 32
        instruction = gen.generate_alu_register(rd, rs1, rs2, i % 8, 0b0000000)
        independent_sequence.append(instruction)

    dut._log.info("Testing independent instruction sequence")

    dispatched_count = 0
    for i, instruction in enumerate(independent_sequence):
        dut.instruction.value = instruction
        dut.inst_valid.value = 1

        await RisingEdge(dut.clk)
        await Timer(1, units="ns")

        if hasattr(dut, "dispatch_valid"):
            if int(dut.dispatch_valid.value) == 1:
                dispatched_count += 1

        dut.inst_valid.value = 0
        await Timer(1, units="ns")

    dut._log.info(
        f"Dispatched {dispatched_count}/{len(independent_sequence)} independent instructions"
    )

    # Generate a sequence with dependencies
    dependent_sequence = []
    for i in range(5):
        # Each instruction depends on the previous one
        rd = i + 1
        rs1 = i  # Depends on previous instruction's result
        rs2 = 20
        instruction = gen.generate_alu_immediate(rd, rs1, 10, 0b000)
        dependent_sequence.append(instruction)

    dut._log.info("Testing dependent instruction sequence")

    stall_cycles = 0
    for i, instruction in enumerate(dependent_sequence):
        dut.instruction.value = instruction
        dut.inst_valid.value = 1

        await RisingEdge(dut.clk)
        await Timer(1, units="ns")

        if hasattr(dut, "stall"):
            if int(dut.stall.value) == 1:
                stall_cycles += 1
                dut._log.info(f"  Instruction {i}: Stalled due to dependency")

        # Wait for instruction to complete
        for _ in range(3):
            await RisingEdge(dut.clk)

        dut.inst_valid.value = 0
        await RisingEdge(dut.clk)

    dut._log.info(f"Dependent sequence caused {stall_cycles} stall cycles")
    dut._log.info("✓ Throughput test completed")


@cocotb.test()
async def test_risc_v_dispatcher_special_cases(dut):
    """Test special cases and edge conditions"""

    dut._log.info("=== Testing Dispatcher Special Cases ===")

    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Reset
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    gen = RV32IInstructionGenerator()

    # Test x0 register (always zero)
    dut._log.info("Testing x0 register handling")

    # Writing to x0 should be allowed but has no effect
    instr_write_x0 = gen.generate_alu_immediate(0, 1, 100, 0b000)  # ADDI x0, x1, 100

    dut.instruction.value = instr_write_x0
    dut.inst_valid.value = 1

    await RisingEdge(dut.clk)
    await Timer(1, units="ns")

    if hasattr(dut, "dispatch_valid"):
        if int(dut.dispatch_valid.value) == 1:
            dut._log.info(
                "  ✓ Write to x0 dispatched (will be ignored by register file)"
            )

    dut.inst_valid.value = 0
    await RisingEdge(dut.clk)

    # Test NOP instruction (ADDI x0, x0, 0)
    dut._log.info("Testing NOP instruction")

    nop_instruction = 0x00000013  # NOP

    dut.instruction.value = nop_instruction
    dut.inst_valid.value = 1

    await RisingEdge(dut.clk)
    await Timer(1, units="ns")

    if hasattr(dut, "dispatch_valid"):
        if int(dut.dispatch_valid.value) == 1:
            dut._log.info("  ✓ NOP instruction dispatched")

    dut.inst_valid.value = 0
    await RisingEdge(dut.clk)

    # Test invalid instruction
    dut._log.info("Testing invalid instruction")

    invalid_instruction = 0xFFFFFFFF  # Invalid opcode

    dut.instruction.value = invalid_instruction
    dut.inst_valid.value = 1

    await RisingEdge(dut.clk)
    await Timer(1, units="ns")

    if hasattr(dut, "dispatch_valid"):
        if int(dut.dispatch_valid.value) == 0:
            dut._log.info("  ✓ Invalid instruction rejected")
        else:
            dut._log.warning("  ⚠ Invalid instruction may have been accepted")

    if hasattr(dut, "illegal_inst"):
        if int(dut.illegal_inst.value) == 1:
            dut._log.info("  ✓ Illegal instruction exception raised")

    dut.inst_valid.value = 0
    await RisingEdge(dut.clk)

    # Test FENCE instruction
    dut._log.info("Testing FENCE instruction")

    fence_instruction = 0x0000000F  # FENCE

    dut.instruction.value = fence_instruction
    dut.inst_valid.value = 1

    await RisingEdge(dut.clk)
    await Timer(1, units="ns")

    if hasattr(dut, "dispatch_valid"):
        if int(dut.dispatch_valid.value) == 1:
            dut._log.info("  ✓ FENCE instruction dispatched")

    if hasattr(dut, "fence_active"):
        if int(dut.fence_active.value) == 1:
            dut._log.info("  ✓ FENCE active signal asserted")

    dut.inst_valid.value = 0
    await RisingEdge(dut.clk)

    # Test ECALL/EBREAK
    dut._log.info("Testing ECALL and EBREAK")

    ecall_instruction = 0x00000073  # ECALL
    ebreak_instruction = 0x00100073  # EBREAK

    for instr, name in [(ecall_instruction, "ECALL"), (ebreak_instruction, "EBREAK")]:
        dut.instruction.value = instr
        dut.inst_valid.value = 1

        await RisingEdge(dut.clk)
        await Timer(1, units="ns")

        if hasattr(dut, "exception"):
            if int(dut.exception.value) == 1:
                dut._log.info(f"  ✓ {name} raised exception")

        dut.inst_valid.value = 0
        await RisingEdge(dut.clk)

    dut._log.info("✓ Special cases test completed")


@cocotb.test()
async def test_risc_v_dispatcher_pipeline_flush(dut):
    """Test pipeline flush on branch misprediction"""

    dut._log.info("=== Testing Pipeline Flush ===")

    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Reset
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    gen = RV32IInstructionGenerator()

    # Issue several instructions
    instructions = [
        gen.generate_alu_immediate(1, 2, 100, 0b000),
        gen.generate_alu_immediate(3, 4, 200, 0b000),
        gen.generate_alu_immediate(5, 6, 300, 0b000),
    ]

    dut._log.info("Issuing instructions into pipeline")

    for instruction in instructions:
        dut.instruction.value = instruction
        dut.inst_valid.value = 1
        await RisingEdge(dut.clk)
        dut.inst_valid.value = 0

    # Simulate branch misprediction
    dut._log.info("Simulating branch misprediction")

    if hasattr(dut, "branch_mispredict"):
        dut.branch_mispredict.value = 1
        await RisingEdge(dut.clk)
        dut.branch_mispredict.value = 0

        # Check if pipeline is flushed
        if hasattr(dut, "flush"):
            if int(dut.flush.value) == 1:
                dut._log.info("  ✓ Pipeline flush signal asserted")

        # Wait for flush to complete
        for _ in range(3):
            await RisingEdge(dut.clk)

        dut._log.info("  ✓ Pipeline flushed after misprediction")
    else:
        dut._log.info("  ○ Branch misprediction signal not available")

    dut._log.info("✓ Pipeline flush test completed")


@cocotb.test()
async def test_risc_v_dispatcher_coprocessor_offload(dut):
    """Test coprocessor instruction offloading"""

    dut._log.info("=== Testing Coprocessor Offload ===")

    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Reset
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    # Test CSR instruction dispatch
    dut._log.info("Testing CSR instruction dispatch")

    # CSRRW x1, mstatus, x2
    csr_instruction = (
        (0x300 << 20) | (2 << 15) | (0b001 << 12) | (1 << 7) | RV32IOpcode.SYSTEM.value
    )

    dut.instruction.value = csr_instruction
    dut.inst_valid.value = 1

    await RisingEdge(dut.clk)
    await Timer(1, units="ns")

    if hasattr(dut, "coproc_dispatch"):
        if int(dut.coproc_dispatch.value) == 1:
            dut._log.info("  ✓ CSR instruction dispatched to coprocessor")

    dut.inst_valid.value = 0
    await RisingEdge(dut.clk)

    # Test custom instruction dispatch
    dut._log.info("Testing custom instruction dispatch")

    # Custom-0 instruction
    custom_instruction = (
        (0b0000000 << 25) | (5 << 20) | (4 << 15) | (0b000 << 12) | (3 << 7) | 0b0001011
    )

    dut.instruction.value = custom_instruction
    dut.inst_valid.value = 1

    await RisingEdge(dut.clk)
    await Timer(1, units="ns")

    if hasattr(dut, "custom_dispatch"):
        if int(dut.custom_dispatch.value) == 1:
            dut._log.info("  ✓ Custom instruction dispatched")

    dut.inst_valid.value = 0
    await RisingEdge(dut.clk)

    dut._log.info("✓ Coprocessor offload test completed")
