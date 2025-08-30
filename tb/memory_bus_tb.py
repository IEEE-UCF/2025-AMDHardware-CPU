#!/usr/bin/env python3
"""
Simple Memory Bus Testbench
Basic functionality test - instruction/data access, SRAM/DDR routing
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

@cocotb.test()
async def test_memory_bus_basic(dut):
    """Basic memory bus functionality test"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    dut.cpu_imem_addr.value = 0
    dut.cpu_imem_read.value = 0
    dut.cpu_dmem_addr.value = 0
    dut.cpu_dmem_write_data.value = 0
    dut.cpu_dmem_read.value = 0
    dut.cpu_dmem_write.value = 0
    dut.cpu_dmem_be.value = 0
    dut.mem_req_ready.value = 1
    dut.mem_resp_valid.value = 0
    dut.mem_resp_rdata.value = 0
    dut.sram_rdata.value = 0xDEADBEEF
    dut.sram_ready.value = 1
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing memory bus basic functionality")
    
    # Test SRAM instruction read
    dut._log.info("Testing SRAM instruction read")
    dut.cpu_imem_addr.value = 0x1000  # SRAM range
    dut.cpu_imem_read.value = 1
    
    await ClockCycles(dut.clk, 3)
    
    # Should have SRAM signals active
    assert int(dut.sram_re.value) == 1, "SRAM read enable should be active"
    assert int(dut.cpu_imem_ready.value) == 1, "Instruction memory should be ready"
    
    dut.cpu_imem_read.value = 0
    await ClockCycles(dut.clk, 1)
    
    # Test SRAM data write
    dut._log.info("Testing SRAM data write")
    dut.cpu_dmem_addr.value = 0x2000  # SRAM range
    dut.cpu_dmem_write_data.value = 0x12345678
    dut.cpu_dmem_write.value = 1
    dut.cpu_dmem_be.value = 0xFF
    
    await ClockCycles(dut.clk, 3)
    
    # Should have SRAM write signals active
    assert int(dut.sram_we.value) == 1, "SRAM write enable should be active"
    assert int(dut.sram_wdata.value) == 0x12345678, "SRAM write data should match"
    
    dut.cpu_dmem_write.value = 0
    await ClockCycles(dut.clk, 1)
    
    # Test DDR access (should use external memory interface)
    dut._log.info("Testing DDR access")
    dut.cpu_dmem_addr.value = 0x80000000  # DDR range
    dut.cpu_dmem_read.value = 1
    
    await ClockCycles(dut.clk, 5)
    
    # Should generate external memory request
    assert int(dut.mem_req_valid.value) == 1, "External memory request should be valid"
    
    dut.cpu_dmem_read.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Memory bus basic test passed")

@cocotb.test()
async def test_memory_bus_ready_signals(dut):
    """Test ready signal behavior"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing ready signals")
    
    # Setup external memory not ready
    dut.mem_req_ready.value = 0
    dut.sram_ready.value = 0
    
    # Try SRAM access when not ready
    dut.cpu_dmem_addr.value = 0x1000
    dut.cpu_dmem_read.value = 1
    
    await ClockCycles(dut.clk, 2)
    assert int(dut.cpu_dmem_ready.value) == 0, "Should not be ready when SRAM not ready"
    
    # Make SRAM ready
    dut.sram_ready.value = 1
    await ClockCycles(dut.clk, 2)
    assert int(dut.cpu_dmem_ready.value) == 1, "Should be ready when SRAM ready"
    
    dut._log.info("Ready signals test passed")

if __name__ == "__main__":
    import sys
    import pytest
    pytest.main([__file__] + sys.argv[1:])
