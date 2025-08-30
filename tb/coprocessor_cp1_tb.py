#!/usr/bin/env python3
"""
Simple Coprocessor CP1 Testbench
Basic functionality test - just verify it works
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_cp1_basic(dut):
    """Basic CP1 functionality test"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    dut.cp_enable.value = 0
    dut.cp_instruction.value = 0
    dut.cp_data_in.value = 0
    dut.fp_reg_rdata1.value = 0x40000000  # 2.0 in single precision
    dut.fp_reg_rdata2.value = 0x40400000  # 3.0 in single precision
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing CP1 basic operation")
    
    # Test without enabling - should be ready when idle and no FP instruction
    await ClockCycles(dut.clk, 5)
    dut._log.info(f"CP1 ready without enable: {dut.cp_ready.value}")
    
    # Just check that the module responds at all
    assert dut.cp_ready.value.is_resolvable, "CP1 cp_ready should be resolvable"
    assert dut.cp_data_out.value.is_resolvable, "CP1 cp_data_out should be resolvable"
    assert dut.cp_exception.value.is_resolvable, "CP1 cp_exception should be resolvable"
    
    dut._log.info("CP1 basic test passed")

if __name__ == "__main__":
    import sys
    import pytest
    pytest.main([__file__] + sys.argv[1:])
