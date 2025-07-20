import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock

async def reset_cpu(dut):
    dut.reset.value = 1
    await RisingEdge(dut.clk)
    dut.reset.value = 0

@cocotb.test()
async def test_stage_id(dut):
    """Testing instruct interpretation, registers, and branch control outputs from decode"""

    REG_NUM = 32
    IMM_TYPE_NUM = 4
    EX_PRO_VALUE = 8
    MM_PRO_VALUE = 9
    MM_MEM_VALUE = 10

    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Reset procedure
    await reset_cpu(dut)
    dut._log.info("Reset Complete")

    dut._log.info("Initializing Registers")

    main_registers = []

    dut.w_en.value = 1
    for i in range(REG_NUM):
        main_registers.append(i)
        dut.w_rd.value = i
        dut.w_in.value = i % 16 # Modulo allows for equivalent values to compare in Register Value Equality Test
        await RisingEdge(dut.clk)
    dut.w_en.value = 0

    # Instruction Setup
    # Note: All instruction encodings taken from https://luplab.gitlab.io/rvcodecjs/#q=jal+x1,+20&abi=false&isa=AUTO
    instructions = [0b00000001010000000000000011100111, # jalr x1, 20(x0)
                    0b00000011001000010000000001100011, # beq x2, x18, 32
                    0b00000011011101011001000001100011, # bne x11, x23, 32
                    0b00000010000100000010100000100011, # sw x3, 48(x0)
                    0b00000001010011110001111110010011, # slli x31, x30, 20
                    0b11111011110100100000001010010011, # addi x5, x4, -67
                    0b11111111111111110110100000110111, # lui x16, -10
                    0b01000000011000111000010000110011, # sub x8, x7, x7
                   ]
    instructions.reverse()

    # Immediate values from sq, slli, addi, and lui for Immediate Calculation Test
    immediates = [48,
                  20,
                  -67,
                  -10
                 ]
    immediates.reverse()

    dut._log.info("PC Next Calculation Test")
    # Determine if JALR address calculation is given correctly
    dut.d_inst.value = instructions.pop()
    dut.pc_unstable_type.value = 1
    await RisingEdge(dut.clk)

    assert dut.pc_next_correct.value.integer == 20, "Address calc fail from JALR instruction!"

    # Determine if BRA address calculation is given correctly
    dut.d_inst.value = instructions.pop()
    dut.pc_unstable_type.value = 0
    dut.d_pc.value = 0
    await RisingEdge(dut.clk)

    assert dut.pc_next_correct.value.integer == 32, "Address calc fail from BEQ instruction!"

    dut._log.info("Register Value Equality Test")
    # Check comparison of equivalent register values
    assert dut.is_equal.value.integer == 1, "Equality fail from BEQ instruction!"

    # Check comparison of non-equivalent register values
    dut.d_inst.value = instructions.pop()
    await RisingEdge(dut.clk)

    assert dut.is_equal.value.integer == 0, "Inequality fail from BNE instruction!"

    dut._log.info("Immediate Calculation Test")

    dut.has_imm.value = 1

    # For each immediate type, run an instruction of that type and verify its immediate value is correctly output from the stage
    for i in range(IMM_TYPE_NUM):
        dut.imm_type.value = i
        dut.d_inst.value = instructions.pop()
        await RisingEdge(dut.clk)
        assert dut.read_out_b.value.integer == immediates.pop(), f"Immediate value fail for type {dut.imm_type.value.integer}"
    
    dut.has_imm.value = 0

    dut._log.info("Bypass Test")
    # Verify that the bypass mux correctly compares register numbers and returns the appropriate register value
    dut.d_inst.value = instructions.pop()

    dut.ex_pro.value = EX_PRO_VALUE
    dut.mm_pro.value = MM_PRO_VALUE
    dut.mm_mem.value = MM_MEM_VALUE

    # Check unequal register number behavior
    dut.ex_rd.value = 6
    await RisingEdge(dut.clk)

    assert dut.read_out_a.value.integer == 7, "EX_PRO Bypass Failure: unequal register numbers yet bypassed!"

    # Check equal register number behavior
    dut.ex_rd.value = 7
    await RisingEdge(dut.clk)
    assert dut.read_out_a.value.integer == EX_PRO_VALUE, "Bypass Failure: equal register numbers yet not bypassed!"

    dut.ex_rd.value = 6
    dut.mm_rd.value = 6
    await RisingEdge(dut.clk)

    assert dut.read_out_a.value.integer == 7, "MM_PRO Bypass Failure: unequal register numbers yet bypassed!"

    dut.mm_rd.value = 7
    dut.mm_is_load.value = 0
    await RisingEdge(dut.clk)

    assert dut.read_out_a.value.integer == MM_PRO_VALUE, "MM_PRO Bypass Failure: equal register numbers yet not bypassed!"

    dut.mm_is_load.value = 1
    await RisingEdge(dut.clk)

    assert dut.read_out_a.value.integer == MM_MEM_VALUE, "MM_MEM Bypass Failure: is_load yet not bypassed!"

    dut.mm_is_load.value = 0
    dut.mm_rd.value = 0
    dut.ex_rd.value = 0

    dut._log.info("Shadow Register Test")
    # Check if shadow register holds same expected value as main register before interrupt
    dut.interrupt.value = 1

    await RisingEdge(dut.clk)

    assert dut.read_out_a.value.integer == main_registers[i], "Shadow Failure: shadow & main registers have different values before interrupt!"

    # Rewrite shadow register and check if main register's expected value now differs
    dut.w_en.value = 1
    dut.w_rd.value = 7
    dut.w_in.value = -17

    await RisingEdge(dut.clk)

    assert dut.read_out_a.value.integer != main_registers[i], "Shadow Failure: shadow & main registers have same values after interrupt!"

    # Read actual main register and compare to its expected value
    dut.w_en.value = 0
    dut.interrupt.value = 0

    await RisingEdge(dut.clk)

    assert dut.read_out_a.value.integer == main_registers[i], "Shadow Failure: main register does not have expected value!"

