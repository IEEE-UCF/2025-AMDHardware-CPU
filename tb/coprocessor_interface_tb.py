#!/usr/bin/env python3
"""
Simple Coprocessor Interface Testbench
Basic functionality test - just verify it works
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_interface_basic(dut):
    """Basic interface functionality test"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    dut.cp_valid.value = 0
    dut.cp_instruction.value = 0
    dut.cp_data_in.value = 0
    dut.cp_select.value = 0
    
    # Set coprocessor ready signals as vectors
    dut.cp_ready_in.value = 0b1111  # All 4 coprocessors ready
    dut.cp_exception_in.value = 0b0000  # No exceptions
    # Set individual data from each coprocessor
    dut.cp_data_from_cp.value = [0xDEADBEEF, 0xCAFEBABE, 0xFEEDFACE, 0xBADDCAFE]
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing coprocessor interface basic operation")
    
    # Test basic coprocessor selection
    dut.cp_valid.value = 1
    dut.cp_instruction.value = 0x300F2073
    dut.cp_data_in.value = 0x1234
    dut.cp_select.value = 1  # Select CP1
    
    await ClockCycles(dut.clk, 5)
    
    # Should route to selected coprocessor
    assert int(dut.cp_ready.value) == 1, "Interface should be ready"
    
    dut._log.info("Coprocessor interface basic test passed")

if __name__ == "__main__":
    import sys
    import pytest
    pytest.main([__file__] + sys.argv[1:])
