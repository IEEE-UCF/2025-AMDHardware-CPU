#!/usr/bin/env python3
"""
Simple Coprocessor CP3 Testbench
Basic functionality test - just verify it works
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_cp3_basic(dut):
    """Basic CP3 functionality test"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    dut.cp_enable.value = 0
    dut.cp_instruction.value = 0
    dut.cp_data_in.value = 0
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing CP3 basic operation")
    
    # Test without enabling - should be ready when idle
    await ClockCycles(dut.clk, 5)
    dut._log.info(f"CP3 ready without enable: {dut.cp_ready.value}")
    
    # Just check that the module responds at all
    assert dut.cp_ready.value.is_resolvable, "CP3 cp_ready should be resolvable"
    assert dut.cp_data_out.value.is_resolvable, "CP3 cp_data_out should be resolvable"
    assert dut.cp_exception.value.is_resolvable, "CP3 cp_exception should be resolvable"
    
    dut._log.info("CP3 basic test passed")

if __name__ == "__main__":
    import sys
    import pytest
    pytest.main([__file__] + sys.argv[1:])
