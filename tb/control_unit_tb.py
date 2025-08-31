import cocotb
import random
from cocotb.triggers import Timer

# --- You can adjust these constants to match your ALU's operation codes ---
ALU_ADD = 0b00000
ALU_SUB = 0b00001
ALU_SLL = 0b00010
ALU_SLT = 0b00011
ALU_SLTU = 0b00100
ALU_XOR = 0b00101
ALU_SRL = 0b00110
ALU_SRA = 0b00111
ALU_OR = 0b01000
ALU_AND = 0b01001
ALU_COPY_B = 0b01010  # Used for LUI to pass immediate through

# --- Immediate Type Constants ---
IMM_TYPE_I = 0b00
IMM_TYPE_S = 0b01
IMM_TYPE_B = 0b10
IMM_TYPE_U = 0b11
IMM_TYPE_J = 0b11  # J-type often reuses U-type's immediate decoder path


# Helper to assemble a 32-bit instruction (unchanged)
def assemble_instruction(fields):
    opcode = fields.get("opcode", 0)
    rd = fields.get("rd", 0)
    rs1 = fields.get("rs1", 0)
    rs2 = fields.get("rs2", 0)
    funct3 = fields.get("funct3", 0)
    funct7 = fields.get("funct7", 0)
    imm = fields.get("imm", 0)
    if opcode in [0b0110111, 0b0010111]:
        return (imm & 0xFFFFF000) | (rd << 7) | opcode
    elif opcode == 0b1101111:
        return (
            (
                ((imm >> 20) & 1) << 31
                | ((imm >> 1) & 0x3FF) << 21
                | ((imm >> 11) & 1) << 20
                | ((imm >> 12) & 0xFF) << 12
            )
            | (rd << 7)
            | opcode
        )
    elif opcode == 0b1100111:
        return (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode
    elif opcode == 0b1100011:
        return (
            (
                ((imm >> 12) & 1) << 31
                | ((imm >> 5) & 0x3F) << 25
                | ((imm >> 1) & 0xF) << 8
                | ((imm >> 11) & 1) << 7
            )
            | (rs2 << 20)
            | (rs1 << 15)
            | (funct3 << 12)
            | opcode
        )
    elif opcode in [0b0000011, 0b0010011, 0b0011011]:
        return (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode
    elif opcode == 0b0100011:
        return (
            (((imm >> 5) & 0x7F) << 25 | (imm & 0x1F) << 7)
            | (rs2 << 20)
            | (rs1 << 15)
            | (funct3 << 12)
            | opcode
        )
    elif opcode in [0b0110011, 0b0111011]:
        return (
            (funct7 << 25)
            | (rs2 << 20)
            | (rs1 << 15)
            | (funct3 << 12)
            | (rd << 7)
            | opcode
        )
    else:
        return opcode


@cocotb.test()
async def test_control_unit_detailed(dut):
    """Randomized test matching the detailed I/O of the provided control unit."""

    # Opcodes for the base RV64I instruction set
    OP_LOAD = 0b0000011
    OP_STORE = 0b0100011
    OP_BRANCH = 0b1100011
    OP_JALR = 0b1100111
    OP_JAL = 0b1101111
    OP_OP_IMM = 0b0010011
    OP_OP_IMM_32 = 0b0011011
    OP_OP = 0b0110011
    OP_OP_32 = 0b0111011
    OP_AUIPC = 0b0010111
    OP_LUI = 0b0110111
    OP_SYSTEM = 0b1110011

    valid_opcodes = [
        OP_LOAD,
        OP_STORE,
        OP_BRANCH,
        OP_JALR,
        OP_JAL,
        OP_OP_IMM,
        OP_OP_IMM_32,
        OP_OP,
        OP_OP_32,
        OP_AUIPC,
        OP_LUI,
        OP_SYSTEM,
    ]

    num_iterations = 10000
    dut._log.info(
        f"---- DETAILED CONTROL UNIT TEST STARTS: {num_iterations} iterations ----"
    )

    # Initial state check: Ensure outputs are idle when inst_valid is low
    dut.inst_valid.value = 0
    await Timer(2, units="ns")
    assert dut.reg_write.value == 0, "reg_write should be 0 when inst_valid is low"
    assert dut.mem_read.value == 0, "mem_read should be 0 when inst_valid is low"
    assert dut.mem_write.value == 0, "mem_write should be 0 when inst_valid is low"

    for i in range(num_iterations):
        # 1. Generate random instruction fields
        opcode = random.choice(valid_opcodes)
        rd = random.randint(0, 31)
        rs1 = random.randint(0, 31)
        rs2 = random.randint(0, 31)
        funct3 = random.randint(0, 7)
        funct7 = random.randint(0, 127)
        imm = random.randint(-2048, 2047)

        # 2. Determine the "golden" or expected control signals based on the opcode
        expected = {
            "reg_write": 0,
            "mem_read": 0,
            "mem_write": 0,
            "alu_op": 0,
            "alu_src": 0,
            "imm_type": 0,
            "branch": 0,
            "jump": 0,
            "jalr": 0,
            "lui": 0,
            "auipc": 0,
            "system": 0,
            "opcode": opcode,
            "funct3": 0,
            "funct7": 0,
            "rd": 0,
            "rs1": 0,
            "rs2": 0,
        }

        # This logic block now sets ALL expected outputs
        if opcode == OP_LUI:
            expected.update(
                {
                    "reg_write": 1,
                    "lui": 1,
                    "alu_src": 1,
                    "imm_type": IMM_TYPE_U,
                    "rd": rd,
                    "alu_op": ALU_COPY_B,
                }
            )
        elif opcode == OP_AUIPC:
            expected.update(
                {
                    "reg_write": 1,
                    "auipc": 1,
                    "alu_src": 1,
                    "imm_type": IMM_TYPE_U,
                    "rd": rd,
                    "alu_op": ALU_ADD,
                }
            )
        elif opcode == OP_JAL:
            expected.update(
                {
                    "reg_write": 1,
                    "jump": 1,
                    "alu_src": 1,
                    "imm_type": IMM_TYPE_J,
                    "rd": rd,
                    "alu_op": ALU_ADD,
                }
            )  # PC+4 stored, not an ALU op
        elif opcode == OP_JALR:
            expected.update(
                {
                    "reg_write": 1,
                    "jalr": 1,
                    "alu_src": 1,
                    "imm_type": IMM_TYPE_I,
                    "rd": rd,
                    "rs1": rs1,
                    "funct3": funct3,
                    "alu_op": ALU_ADD,
                }
            )
        elif opcode == OP_BRANCH:
            expected.update(
                {
                    "branch": 1,
                    "imm_type": IMM_TYPE_B,
                    "rs1": rs1,
                    "rs2": rs2,
                    "funct3": funct3,
                }
            )
            if funct3 == 0b000 or funct3 == 0b001:
                expected["alu_op"] = ALU_SUB  # BEQ, BNE
            elif funct3 == 0b100 or funct3 == 0b101:
                expected["alu_op"] = ALU_SLT  # BLT, BGE
            elif funct3 == 0b110 or funct3 == 0b111:
                expected["alu_op"] = ALU_SLTU  # BLTU, BGEU
        elif opcode == OP_LOAD:
            expected.update(
                {
                    "reg_write": 1,
                    "mem_read": 1,
                    "alu_src": 1,
                    "imm_type": IMM_TYPE_I,
                    "rd": rd,
                    "rs1": rs1,
                    "funct3": funct3,
                    "alu_op": ALU_ADD,
                }
            )
        elif opcode == OP_STORE:
            expected.update(
                {
                    "mem_write": 1,
                    "alu_src": 1,
                    "imm_type": IMM_TYPE_S,
                    "rs1": rs1,
                    "rs2": rs2,
                    "funct3": funct3,
                    "alu_op": ALU_ADD,
                }
            )
        elif opcode in [OP_OP_IMM, OP_OP_IMM_32]:
            expected.update(
                {
                    "reg_write": 1,
                    "alu_src": 1,
                    "imm_type": IMM_TYPE_I,
                    "rd": rd,
                    "rs1": rs1,
                    "funct3": funct3,
                }
            )
            if funct3 == 0b000:
                expected["alu_op"] = ALU_ADD
            elif funct3 == 0b010:
                expected["alu_op"] = ALU_SLT
            elif funct3 == 0b011:
                expected["alu_op"] = ALU_SLTU
            elif funct3 == 0b100:
                expected["alu_op"] = ALU_XOR
            elif funct3 == 0b110:
                expected["alu_op"] = ALU_OR
            elif funct3 == 0b111:
                expected["alu_op"] = ALU_AND
            elif funct3 == 0b001:
                expected["alu_op"] = ALU_SLL
            elif funct3 == 0b101:
                expected["alu_op"] = ALU_SRA if (funct7 >> 5) & 1 else ALU_SRL
        elif opcode in [OP_OP, OP_OP_32]:
            expected.update(
                {
                    "reg_write": 1,
                    "rd": rd,
                    "rs1": rs1,
                    "rs2": rs2,
                    "funct3": funct3,
                    "funct7": funct7,
                }
            )
            if funct3 == 0b000:
                expected["alu_op"] = ALU_SUB if (funct7 >> 5) & 1 else ALU_ADD
            elif funct3 == 0b001:
                expected["alu_op"] = ALU_SLL
            elif funct3 == 0b010:
                expected["alu_op"] = ALU_SLT
            elif funct3 == 0b011:
                expected["alu_op"] = ALU_SLTU
            elif funct3 == 0b100:
                expected["alu_op"] = ALU_XOR
            elif funct3 == 0b101:
                expected["alu_op"] = ALU_SRA if (funct7 >> 5) & 1 else ALU_SRL
            elif funct3 == 0b110:
                expected["alu_op"] = ALU_OR
            elif funct3 == 0b111:
                expected["alu_op"] = ALU_AND
        elif opcode == OP_SYSTEM:
            expected["system"] = 1

        # 3. Assemble and apply the instruction
        instruction = assemble_instruction(
            expected
        )  # Use expected dict which has all fields
        dut.instruction.value = instruction
        dut.inst_valid.value = 1
        await Timer(1, units="ns")

        # 4. Read all DUT outputs for comparison
        dut_outputs = {s: int(getattr(dut, s).value) for s in expected.keys()}

        # 5. Compare and assert
        if dut_outputs != expected:
            dut._log.error(f"Mismatch on iteration {i + 1}:")
            dut._log.error(f"Instruction: {instruction:032b} (Opcode: {opcode:07b})")
            dut._log.error(f"  Signal      | Expected | DUT Output")
            dut._log.error(f"------------------------------------")
            for sig in expected:
                if expected[sig] != dut_outputs[sig]:
                    dut._log.error(
                        f"> {sig:<12}| {expected[sig]:^8} | {dut_outputs[sig]:^10} <--- MISMATCH"
                    )
                else:
                    dut._log.info(
                        f"  {sig:<12}| {expected[sig]:^8} | {dut_outputs[sig]:^10}"
                    )
            assert False, "Control signal mismatch detected."

        # De-assert valid for next cycle
        dut.inst_valid.value = 0

    dut._log.info(
        f"--- CONTROL UNIT TEST FINISHED: {num_iterations} random instructions verified successfully ---"
    )
