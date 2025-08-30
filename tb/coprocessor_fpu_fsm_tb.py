#!/usr/bin/env python3
"""
Simple Coprocessor FPU FSM Testbench
Basic functionality test - just verify it works
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_fpu_fsm_basic(dut):
    """Basic FPU FSM functionality test"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    dut.fpu_start.value = 0
    dut.fpu_operation.value = 0
    dut.fpu_format.value = 0
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing FPU FSM basic operation")
    
    # Test basic FPU FSM operation
    dut.fpu_start.value = 1
    dut.fpu_operation.value = 1  # Some FP operation
    dut.fpu_format.value = 0     # Single precision
    
    await ClockCycles(dut.clk, 1)
    dut.fpu_start.value = 0
    
    await ClockCycles(dut.clk, 10)
    
    # Should complete operation
    assert int(dut.fpu_ready.value) == 1, "FPU FSM should be ready"
    
    dut._log.info("FPU FSM basic test passed")

if __name__ == "__main__":
    import sys
    import pytest
    pytest.main([__file__] + sys.argv[1:])
