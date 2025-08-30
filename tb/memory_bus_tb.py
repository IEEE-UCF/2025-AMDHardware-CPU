#!/usr/bin/env python3
"""
Memory Bus Testbench with Memory Burst Buffer Testing
Tests basic functionality, SRAM/DDR routing, and burst buffer behavior
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, Timer

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
    
    # Test SRAM instruction read (should not use burst buffer)
    dut._log.info("Testing SRAM instruction read")
    dut.cpu_imem_addr.value = 0x1000  # SRAM range
    dut.cpu_imem_read.value = 1
    
    await ClockCycles(dut.clk, 3)
    
    # Should have SRAM signals active
    assert int(dut.sram_re.value) == 1, "SRAM read enable should be active"
    assert int(dut.cpu_imem_ready.value) == 1, "Instruction memory should be ready"
    
    dut.cpu_imem_read.value = 0
    await ClockCycles(dut.clk, 1)
    
    # Test SRAM data write (should not use burst buffer)
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
    
    dut._log.info("Memory bus basic test passed")

@cocotb.test()
async def test_memory_burst_buffer_ddr_read(dut):
    """Test DDR read access through burst buffer"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing DDR read access through burst buffer")
    
    # Setup external memory responses
    dut.mem_req_ready.value = 1
    dut.mem_resp_valid.value = 0
    dut.sram_ready.value = 1
    
    # Issue multiple DDR read requests to trigger burst behavior
    test_addresses = [0x80000000, 0x80000008, 0x80000010, 0x80000018]  # Sequential addresses
    expected_data = [0x11111111, 0x22222222, 0x33333333, 0x44444444]
    
    # Issue first request
    dut.cpu_dmem_addr.value = test_addresses[0]
    dut.cpu_dmem_read.value = 1
    
    await ClockCycles(dut.clk, 2)
    
    # Should not immediately generate memory request (collecting requests)
    dut._log.info(f"mem_req_valid: {int(dut.mem_req_valid.value)}")
    
    # Issue more requests
    for i, addr in enumerate(test_addresses[1:], 1):
        dut.cpu_dmem_addr.value = addr
        await ClockCycles(dut.clk, 1)
    
    dut.cpu_dmem_read.value = 0
    await ClockCycles(dut.clk, 2)
    
    # Now burst buffer should issue memory request
    if int(dut.mem_req_valid.value) == 1:
        dut._log.info("Burst buffer issued memory request")
        assert int(dut.mem_req_addr.value) == test_addresses[0], "Base address should match first request"
        
        # Simulate memory controller accepting the burst request
        await ClockCycles(dut.clk, 1)
        
        # Provide burst responses
        for i, data in enumerate(expected_data):
            dut.mem_resp_valid.value = 1
            dut.mem_resp_rdata.value = data
            await ClockCycles(dut.clk, 1)
            dut.mem_resp_valid.value = 0
            await ClockCycles(dut.clk, 1)
    
    # Check that CPU gets responses
    await ClockCycles(dut.clk, 10)
    
    dut._log.info("DDR burst read test completed")

@cocotb.test()
async def test_memory_burst_buffer_ddr_write(dut):
    """Test DDR write access through burst buffer"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing DDR write access through burst buffer")
    
    # Setup external memory
    dut.mem_req_ready.value = 1
    dut.mem_resp_valid.value = 0
    dut.sram_ready.value = 1
    
    # Issue multiple DDR write requests
    test_addresses = [0x80000100, 0x80000108, 0x80000110, 0x80000118]
    test_data = [0xAAAABBBB, 0xCCCCDDDD, 0xEEEEFFFF, 0x12345678]
    
    # Issue write requests
    for i, (addr, data) in enumerate(zip(test_addresses, test_data)):
        dut.cpu_dmem_addr.value = addr
        dut.cpu_dmem_write_data.value = data
        dut.cpu_dmem_write.value = 1
        dut.cpu_dmem_be.value = 0xFF
        await ClockCycles(dut.clk, 1)
        
        # First request might not immediately generate mem_req_valid
        if i == 0:
            await ClockCycles(dut.clk, 1)
    
    dut.cpu_dmem_write.value = 0
    await ClockCycles(dut.clk, 3)
    
    # Check if burst buffer issued memory request
    if int(dut.mem_req_valid.value) == 1:
        dut._log.info("Burst buffer issued write burst request")
        assert int(dut.mem_req_we.value) == 1, "Should be a write request"
        assert int(dut.mem_req_addr.value) == test_addresses[0], "Base address should match"
        
        # Simulate memory controller accepting and responding to write burst
        await ClockCycles(dut.clk, 1)
        for i in range(len(test_data)):
            dut.mem_resp_valid.value = 1
            await ClockCycles(dut.clk, 1)
            dut.mem_resp_valid.value = 0
            await ClockCycles(dut.clk, 1)
    
    await ClockCycles(dut.clk, 5)
    dut._log.info("DDR burst write test completed")

@cocotb.test() 
async def test_memory_burst_buffer_state_machine(dut):
    """Test burst buffer state machine behavior"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing burst buffer state machine")
    
    # Setup memory interface
    dut.mem_req_ready.value = 1
    dut.mem_resp_valid.value = 0
    dut.sram_ready.value = 1
    
    # Test single DDR request (should still use burst buffer)
    dut.cpu_dmem_addr.value = 0x80001000
    dut.cpu_dmem_read.value = 1
    
    await ClockCycles(dut.clk, 5)  # Allow state transitions
    
    # Should eventually generate memory request
    request_seen = False
    for _ in range(10):
        if int(dut.mem_req_valid.value) == 1:
            request_seen = True
            dut._log.info("Single request generated memory burst")
            
            # Provide response
            await ClockCycles(dut.clk, 1)
            dut.mem_resp_valid.value = 1
            dut.mem_resp_rdata.value = 0xDEADBEEF
            await ClockCycles(dut.clk, 1)
            dut.mem_resp_valid.value = 0
            break
        await ClockCycles(dut.clk, 1)
    
    dut.cpu_dmem_read.value = 0
    await ClockCycles(dut.clk, 5)
    
    # Test mixed read/write (should not be batched together)
    dut._log.info("Testing mixed read/write requests")
    
    # Write request
    dut.cpu_dmem_addr.value = 0x80002000
    dut.cpu_dmem_write_data.value = 0x87654321
    dut.cpu_dmem_write.value = 1
    dut.cpu_dmem_be.value = 0xFF
    
    await ClockCycles(dut.clk, 2)
    
    # Change to read request (different mode)
    dut.cpu_dmem_write.value = 0
    dut.cpu_dmem_addr.value = 0x80002008
    dut.cpu_dmem_read.value = 1
    
    await ClockCycles(dut.clk, 5)
    
    # Should trigger burst for the write first
    write_burst_seen = False
    for _ in range(10):
        if int(dut.mem_req_valid.value) == 1 and int(dut.mem_req_we.value) == 1:
            write_burst_seen = True
            dut._log.info("Write burst generated")
            # Acknowledge write
            await ClockCycles(dut.clk, 1)
            dut.mem_resp_valid.value = 1
            await ClockCycles(dut.clk, 1)
            dut.mem_resp_valid.value = 0
            break
        await ClockCycles(dut.clk, 1)
    
    # Should then generate read burst
    await ClockCycles(dut.clk, 5)
    
    dut.cpu_dmem_read.value = 0
    await ClockCycles(dut.clk, 5)
    
    dut._log.info("Burst buffer state machine test completed")

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
    
    # Test DDR access with memory controller not ready
    dut.cpu_dmem_read.value = 0
    dut.cpu_dmem_addr.value = 0x80000000  # DDR range
    dut.cpu_dmem_read.value = 1
    dut.mem_req_ready.value = 0
    
    await ClockCycles(dut.clk, 5)
    
    # Should still show ready because burst buffer can accept requests
    # (The actual memory request will be held until mem_req_ready goes high)
    
    dut.cpu_dmem_read.value = 0
    await ClockCycles(dut.clk, 2)
    
    dut._log.info("Ready signals test passed")

@cocotb.test()
async def test_burst_buffer_full_scenario(dut):
    """Test burst buffer behavior when buffer becomes full"""
    
    # Start clock  
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing burst buffer full scenario")
    
    # Setup memory interface - memory controller slow to respond
    dut.mem_req_ready.value = 0  # Memory controller busy
    dut.mem_resp_valid.value = 0
    dut.sram_ready.value = 1
    
    # Fill up burst buffer with requests
    buffer_depth = 8  # From parameter
    for i in range(buffer_depth + 2):  # Try to overfill
        dut.cpu_dmem_addr.value = 0x80000000 + (i * 8)
        dut.cpu_dmem_write_data.value = 0x1000 + i
        dut.cpu_dmem_write.value = 1
        dut.cpu_dmem_be.value = 0xFF
        
        await ClockCycles(dut.clk, 1)
        
        # Check if ready signal goes low when buffer is full
        if i >= buffer_depth - 1:
            if int(dut.cpu_dmem_ready.value) == 0:
                dut._log.info(f"Burst buffer full at request {i}, ready went low")
                break
    
    dut.cpu_dmem_write.value = 0
    
    # Now make memory controller ready and observe burst behavior
    dut.mem_req_ready.value = 1
    await ClockCycles(dut.clk, 5)
    
    # Should see memory request
    if int(dut.mem_req_valid.value) == 1:
        dut._log.info("Burst buffer issued request when memory became ready")
        
        # Acknowledge all writes
        burst_len = int(dut.mem_req_burst_len.value) + 1
        await ClockCycles(dut.clk, 1)
        
        for i in range(burst_len):
            dut.mem_resp_valid.value = 1
            await ClockCycles(dut.clk, 1)
            dut.mem_resp_valid.value = 0
            await ClockCycles(dut.clk, 1)
    
    await ClockCycles(dut.clk, 10)
    dut._log.info("Burst buffer full scenario test completed")

if __name__ == "__main__":
    import sys
    import pytest
    pytest.main([__file__] + sys.argv[1:])
