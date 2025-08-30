#!/usr/bin/env python3
"""
Simple Coprocessor MDU FSM Testbench
Basic functionality test - just verify it works
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_mdu_fsm_basic(dut):
    """Basic MDU FSM functionality test"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    dut.mdu_start.value = 0
    dut.mdu_operation.value = 0
    dut.mdu_format.value = 0
    dut.required_cycles.value = 0
    dut.divide_by_zero.value = 0
    dut.overflow_detected.value = 0
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing MDU FSM basic operation")
    
    # Test basic MDU FSM operation
    dut.mdu_start.value = 1
    dut.mdu_operation.value = 0  # MUL operation
    dut.mdu_format.value = 1     # 64-bit
    dut.required_cycles.value = 5  # Set required cycles for operation
    
    await ClockCycles(dut.clk, 1)
    dut.mdu_start.value = 0
    
    # Wait for operation to complete (setup + compute + normalize + complete)
    await ClockCycles(dut.clk, 10)
    
    # Should complete operation
    assert int(dut.mdu_ready.value) == 1, "MDU FSM should be ready"
    
    dut._log.info("MDU FSM basic test passed")

if __name__ == "__main__":
    import sys
    import pytest
    pytest.main([__file__] + sys.argv[1:])
