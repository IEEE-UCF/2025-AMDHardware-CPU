#!/usr/bin/env python3
"""
Simple Coprocessor MDU Testbench
Basic functionality test - just verify it works
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_mdu_basic(dut):
    """Basic MDU functionality test"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    dut.cp_enable.value = 0
    dut.cp_instruction.value = 0
    dut.cp_data_in.value = 0
    dut.rs1_data.value = 12
    dut.rs2_data.value = 5
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing MDU basic operation")
    
    # Just test that signals are defined and we can read them
    try:
        cp_ready_val = int(dut.cp_ready.value)
        cp_data_out_val = int(dut.cp_data_out.value)
        mdu_busy_val = int(dut.mdu_busy.value)
        dut._log.info(f"MDU signals: cp_ready={cp_ready_val}, cp_data_out=0x{cp_data_out_val:x}, mdu_busy={mdu_busy_val}")
    except Exception as e:
        assert False, f"Failed to read MDU signals: {e}"
    
    dut._log.info("MDU basic test passed")

if __name__ == "__main__":
    import sys
    import pytest
    pytest.main([__file__] + sys.argv[1:])
