#!/usr/bin/env python3
"""
Simple Coprocessor CP0 Testbench
Basic functionality test - just verify it works
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_cp0_basic(dut):
    """Basic CP0 functionality test"""
    
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
    
    dut._log.info("Testing CP0 basic operation")
    
    # Test basic CSR operation
    dut.cp_enable.value = 1
    dut.cp_instruction.value = 0x300F2073  # CSRRS x0, mstatus, x30
    dut.cp_data_in.value = 0x1234
    
    await ClockCycles(dut.clk, 5)
    
    # Should have some response
    assert int(dut.cp_ready.value) == 1, "CP0 should be ready"
    
    dut._log.info("CP0 basic test passed")

if __name__ == "__main__":
    import sys
    import pytest
    pytest.main([__file__] + sys.argv[1:])
