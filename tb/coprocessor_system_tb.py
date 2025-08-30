#!/usr/bin/env python3
"""
Simple Coprocessor System Testbench
Basic functionality test - just verify it works
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_system_basic(dut):
    """Basic system functionality test"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    dut.cp_valid.value = 0
    dut.cp_instruction.value = 0
    dut.cp_data_in.value = 0
    dut.cp_select.value = 0
    dut.interrupt_pending.value = 0
    dut.pc_current.value = 0x1000
    dut.virtual_addr.value = 0x2000
    dut.current_instruction.value = 0
    dut.mem_addr.value = 0
    dut.mem_data.value = 0
    dut.mem_write.value = 0
    dut.inst_valid.value = 0
    dut.external_debug_req.value = 0
    dut.page_table_base.value = 0
    dut.vm_enable.value = 0
    dut.fp_reg_rdata1.value = 0
    dut.fp_reg_rdata2.value = 0
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing coprocessor system basic operation")
    
    # Test basic system operation
    dut.cp_valid.value = 1
    dut.cp_instruction.value = 0x300F2073  # CSR instruction
    dut.cp_data_in.value = 0x1234
    dut.cp_select.value = 0  # CP0
    
    await ClockCycles(dut.clk, 5)
    
    # Should have some response
    assert int(dut.cp_ready.value) == 1, "System should be ready"
    
    dut._log.info("Coprocessor system basic test passed")

if __name__ == "__main__":
    import sys
    import pytest
    pytest.main([__file__] + sys.argv[1:])
