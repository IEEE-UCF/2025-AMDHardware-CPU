import cocotb
import random
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock

async def reset_cpu(dut):
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    dut.rst_n.value = 0

@cocotb.test()
async def test_stage_ex(dut):
    """Testing memory writing and reading"""
    
    # Clock start
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Reset procedure 
    """
    await reset_cpu(dut)
    dut._log.info("Reset Complete\n")
    """
    
    # Constraints:
    # Arbitrary ALU value
    WALU = 0
    # Arbitrary MEM value
    WMEM = 1
    
    # Testing MUX
    dut._log.info("Testing MUX")
    dut.walu.value = WALU
    dut.wmem.value = WMEM
    
    # MUX at 1
    dut.wdata.value = 1
    await RisingEdge(dut.clk)
    
    assert dut.wmem2reg.value.integer == WMEM, "Mux failure!\nExpected: %s\nActual: %s", WMEM, dut.wmem2reg.value.integer
    
    # MUX at 0
    dut.wdata.value = 0
    await RisingEdge(dut.clk)
    
    assert dut.wmem2reg.value.integer == WALU, "Mux failure!\nExpected: %s\nActual: %s", WALU, dut.wmem2reg.value.integer
