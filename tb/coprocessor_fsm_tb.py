#!/usr/bin/env python3
"""
Simple Coprocessor FSM Testbench
Basic functionality test - just verify it works
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_fsm_basic(dut):
    """Basic FSM functionality test"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    dut.cp_start.value = 0
    dut.cp_operation.value = 0
    dut.cp_stall.value = 0
    dut.exception_request.value = 0
    dut.exception_code.value = 0
    dut.required_cycles.value = 3
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing coprocessor FSM basic operation")
    
    # Test basic FSM operation
    dut.cp_start.value = 1
    dut.cp_operation.value = 5
    
    await ClockCycles(dut.clk, 1)
    dut.cp_start.value = 0
    
    await ClockCycles(dut.clk, 10)
    
    # Should complete operation
    assert int(dut.cp_ready.value) == 1, "FSM should be ready"
    
    dut._log.info("Coprocessor FSM basic test passed")

if __name__ == "__main__":
    import sys
    import pytest
    pytest.main([__file__] + sys.argv[1:])
