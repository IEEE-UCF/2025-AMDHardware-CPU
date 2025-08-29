import cocotb
import random
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock

async def reset_cpu(dut):
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1

@cocotb.test()
async def test_stage_mm(dut):
    """Testing memory writing and reading"""
    
    # Clock start
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Reset procedure
    await reset_cpu(dut)
    dut._log.info("Reset Complete\n")
    
    # Constraints:
    # Arbitrary value for RD
    RD = 3
    # Number of addresses to use during test
    ADDRS = 16
    
    # Define data input values
    dut.ex_mem_alu_result.value = 0
    dut.ex_mem_write_data.value = 0
    dut.ex_mem_rd.value = RD
    
    # Write to each memory address
    dut._log.info("Writing Addresses...")
    dut.ex_mem_mem_write.value = 1
    
    for i in range(ADDRS):
        dut.ex_mem_alu_result.value = i
        dut.ex_mem_write_data.value = i
        await RisingEdge(dut.clk)
    
    dut.ex_mem_mem_write.value = 0
    
    # Read each memory address
    dut._log.info("Reading Addresses...")
    for i in range(ADDRS + 1):
        dut.ex_mem_alu_result.value = i
        await RisingEdge(dut.clk)
        if (i != 0):    
            assert dut.ex_mem_read_data.value.integer == i, f"Read failed!\nExpected: {i}\nActual: {dut.ex_mem_read_data.value.integer}"
