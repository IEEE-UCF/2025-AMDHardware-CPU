#!/usr/bin/env python3
"""
Simple Coprocessor Integer ALU Testbench
Basic functionality test - just verify it works
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_int_alu_basic(dut):
    """Basic integer ALU functionality test"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    dut.alu_enable.value = 0
    dut.alu_operation.value = 0
    dut.alu_format.value = 0
    dut.operand_a.value = 0x12345678
    dut.operand_b.value = 0x87654321
    dut.operand_c.value = 0
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing integer ALU basic operation")
    
    # Test basic addition
    dut.alu_enable.value = 1
    dut.alu_operation.value = 0  # ALU_ADD
    
    await ClockCycles(dut.clk, 5)
    
    # Should have some response
    assert int(dut.alu_ready.value) == 1, "ALU should be ready"
    assert int(dut.result_valid.value) == 1, "ALU result should be valid"
    
    dut._log.info("Integer ALU basic test passed")

if __name__ == "__main__":
    import sys
    import pytest
    pytest.main([__file__] + sys.argv[1:])
