import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock

async def run_instructions(dut, pc_prev, INST_AMOUNT, START_INST):
    CYCLES_REM = INST_AMOUNT - START_INST
    for cycle in range (CYCLES_REM):
        pc_prev = dut.pc.value.integer
        await RisingEdge(dut.clk)
        exp_inst_valid = 0
        if (dut.pc_sel.value.integer == 0):
            exp_inst_valid = 1
        dut._log.info("PC value: %s", dut.pc.value)
        dut._log.info("Inst value: %s", dut.inst_word.value)
        dut._log.info("Expected valid: %s", exp_inst_valid)
        dut._log.info("Actual valid: %s", dut.inst_valid.value.integer)
        assert dut.inst_valid.value.integer == exp_inst_valid, "Instruction valid fail!"
        if cycle == 0:
            dut.pc_sel.value = 0
        else:
            assert pc_prev == dut.inst_word.value.integer, "Incorrect instruction output!"


async def reset_cpu(dut):
    dut.reset.value = 1
    await RisingEdge(dut.clk)
    dut.reset.value = 0

@cocotb.test()
async def test_stage_if(dut):
    """Testing instruction output from fetch"""

    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut._log.info("PC value: %s", dut.pc.value)

    # Reset procedure
    await reset_cpu(dut)
    dut._log.info("Reset Complete")

    dut.pc_sel.value = 0
    dut.bra_addr.value = 8
    dut.jal_addr.value = 12
    dut.jar_addr.value = 16

    # Constants for testing
    PC_SEL_MAX = 4
    INSTRUCTION_AMOUNT = 8
    INSTRUCTION_START = 0

    # Instruction flash to memory
    dut.inst_w_en.value = 1
    dut._log.info("Instruction Flash Memory")
    # The additional instruction is for when PC is compared to an instruction after branch in testbench
    for i in range(INSTRUCTION_AMOUNT + 1):
        dut.inst_w_in.value = i * 4
        await RisingEdge(dut.clk)
        dut._log.info("PC value: %s", dut.pc.value)
    
    dut.inst_w_en.value = 0

    await RisingEdge(dut.clk)
    dut._log.info("PC value: %s", dut.pc.value)

    # Reset PC to prepare for reading instructions
    await reset_cpu(dut)

    # Branch control values to check
    
    # Check if instruction output matches expected output for each PC
    # i = 0, pc+4; i = 1, bra_addr; etc.
    dut._log.info("Begin Program Execution")
    for i in range(PC_SEL_MAX):
        dut._log.info("Next Loop")
        dut.pc_sel.value = i
        match i:
            case 0: INSTRUCTION_START = 0
            case 1: INSTRUCTION_START = dut.bra_addr.value.integer//4 - 1
            case 2: INSTRUCTION_START = dut.jal_addr.value.integer//4 - 1
            case 3: INSTRUCTION_START = dut.jar_addr.value.integer//4 - 1
        pc_prev = dut.pc.value.integer
        await run_instructions(dut, pc_prev, INSTRUCTION_AMOUNT, INSTRUCTION_START)
    
    dut._log.info("Stall Check")
    dut.stall.value = 1
    await RisingEdge(dut.clk)
    pc_stall_prev = dut.pc.value
    await RisingEdge(dut.clk)
    dut._log.info("PC Prev: %s", pc_stall_prev)
    dut._log.info("PC Curr: %s", dut.pc.value)
    assert pc_stall_prev == dut.pc.value, "Stall failed, PC values do not match!"