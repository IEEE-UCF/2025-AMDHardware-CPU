import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
from cocotb.regression import TestFactory
import random

@cocotb.test()
async def test_gpu_result_buffer_basic(dut):
    """Test basic GPU result buffer functionality"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    dut.gpu_result_valid.value = 0
    dut.gpu_result_data.value = 0
    dut.gpu_result_addr.value = 0
    dut.gpu_result_reg.value = 0
    dut.gpu_exception.value = 0
    dut.result_ack.value = 0
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Starting GPU result buffer basic test")
    
    # Test initial state
    assert int(dut.buffer_empty.value) == 1, "Buffer should be empty initially"
    assert int(dut.buffer_full.value) == 0, "Buffer should not be full initially"
    assert int(dut.buffer_count.value) == 0, "Buffer count should be 0"
    assert int(dut.result_ready.value) == 0, "No result ready when empty"
    
    # Test single result store
    await store_result(dut, 0xDEADBEEFCAFEBABE, 0x8000000000001000, 10, False)
    
    assert int(dut.buffer_empty.value) == 0, "Buffer should not be empty after store"
    assert int(dut.buffer_count.value) == 1, "Buffer count should be 1"
    assert int(dut.result_ready.value) == 1, "Should have result ready"
    
    # Verify output values
    assert int(dut.result_data.value) == 0xDEADBEEFCAFEBABE, "Result data mismatch"
    assert int(dut.result_addr.value) == 0x8000000000001000, "Result address mismatch"
    assert int(dut.result_reg.value) == 10, "Result register mismatch"
    assert int(dut.result_exception.value) == 0, "Exception flag mismatch"
    
    # Test result retrieve
    await retrieve_result(dut)
    
    assert int(dut.buffer_empty.value) == 1, "Buffer should be empty after retrieve"
    assert int(dut.buffer_count.value) == 0, "Buffer count should be 0"
    assert int(dut.result_ready.value) == 0, "No result ready when empty"
    
    dut._log.info("GPU result buffer basic test completed successfully")

@cocotb.test()
async def test_gpu_result_buffer_exception(dut):
    """Test GPU result buffer with exception handling"""
    
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    await reset_dut(dut)
    
    dut._log.info("Testing exception handling")
    
    # Store result with exception
    await store_result(dut, 0x0000000000000000, 0x1000, 5, True)
    
    assert int(dut.result_ready.value) == 1, "Should have result ready"
    assert int(dut.result_exception.value) == 1, "Exception flag should be set"
    assert int(dut.result_data.value) == 0, "Exception result data"
    assert int(dut.result_addr.value) == 0x1000, "Exception result address"
    assert int(dut.result_reg.value) == 5, "Exception result register"
    
    # Retrieve exception result
    await retrieve_result(dut)
    
    dut._log.info("Exception handling test completed successfully")

@cocotb.test()
async def test_gpu_result_buffer_full_empty(dut):
    """Test buffer full and empty conditions"""
    
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    await reset_dut(dut)
    
    dut._log.info("Testing buffer full/empty conditions")
    
    # Fill the buffer (assuming default depth of 8)
    buffer_depth = 8
    for i in range(buffer_depth):
        await store_result(dut, i*0x1000000000000000, i*0x1000, i%32, i%2 == 1)
        assert int(dut.buffer_count.value) == i + 1, f"Buffer count should be {i+1}"
    
    # Buffer should now be full
    assert int(dut.buffer_full.value) == 1, "Buffer should be full"
    assert int(dut.buffer_count.value) == buffer_depth, f"Buffer count should be {buffer_depth}"
    
    # Try to store when full (should be ignored)
    dut.gpu_result_valid.value = 1
    dut.gpu_result_data.value = 0xFFFFFFFFFFFFFFFF
    await ClockCycles(dut.clk, 1)
    dut.gpu_result_valid.value = 0
    
    assert int(dut.buffer_count.value) == buffer_depth, "Buffer count should not change when full"
    
    # Empty the buffer
    for i in range(buffer_depth):
        await retrieve_result(dut)
        assert int(dut.buffer_count.value) == buffer_depth - i - 1, f"Buffer count should be {buffer_depth - i - 1}"
    
    assert int(dut.buffer_empty.value) == 1, "Buffer should be empty"
    
    dut._log.info("Buffer full/empty test completed successfully")

@cocotb.test()
async def test_gpu_result_buffer_concurrent(dut):
    """Test concurrent store and retrieve operations"""
    
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    await reset_dut(dut)
    
    dut._log.info("Testing concurrent store/retrieve")
    
    # Perform concurrent store/retrieve operations
    for i in range(20):
        # Randomly decide to store
        if random.random() > 0.3 and int(dut.buffer_full.value) == 0:
            await store_result(dut, i*0x1111111111111111, i*0x2000, i%32, i%3 == 0)
        
        # Randomly decide to retrieve
        if random.random() > 0.4 and int(dut.buffer_empty.value) == 0:
            await retrieve_result(dut)
        
        await ClockCycles(dut.clk, 1)
        
        # Verify buffer is functioning
        count = int(dut.buffer_count.value)
        empty = int(dut.buffer_empty.value)
        full = int(dut.buffer_full.value)
        
        assert (count == 0) == (empty == 1), "Empty flag should match count"
        assert (count == 8) == (full == 1), "Full flag should match count"
    
    dut._log.info("Concurrent operations test completed successfully")

@cocotb.test()
async def test_gpu_result_buffer_fifo_order(dut):
    """Test FIFO ordering of results"""
    
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    await reset_dut(dut)
    
    dut._log.info("Testing FIFO ordering")
    
    # Store multiple results
    test_data = [
        (0x1111111111111111, 0x1000, 1),
        (0x2222222222222222, 0x2000, 2),
        (0x3333333333333333, 0x3000, 3),
        (0x4444444444444444, 0x4000, 4)
    ]
    
    for data, addr, reg in test_data:
        await store_result(dut, data, addr, reg, False)
    
    # Retrieve and verify order
    for expected_data, expected_addr, expected_reg in test_data:
        assert int(dut.result_ready.value) == 1, "Should have result ready"
        assert int(dut.result_data.value) == expected_data, f"Data mismatch: got {hex(int(dut.result_data.value))}, expected {hex(expected_data)}"
        assert int(dut.result_addr.value) == expected_addr, f"Address mismatch: got {hex(int(dut.result_addr.value))}, expected {hex(expected_addr)}"
        assert int(dut.result_reg.value) == expected_reg, f"Register mismatch: got {int(dut.result_reg.value)}, expected {expected_reg}"
        
        await retrieve_result(dut)
    
    dut._log.info("FIFO ordering test completed successfully")

async def store_result(dut, data, addr, reg, exception):
    """Helper function to store a GPU result"""
    dut.gpu_result_valid.value = 1
    dut.gpu_result_data.value = data
    dut.gpu_result_addr.value = addr
    dut.gpu_result_reg.value = reg
    dut.gpu_exception.value = exception
    
    await ClockCycles(dut.clk, 1)
    dut.gpu_result_valid.value = 0

async def retrieve_result(dut):
    """Helper function to retrieve a GPU result"""
    dut.result_ack.value = 1
    await ClockCycles(dut.clk, 1)
    dut.result_ack.value = 0

async def reset_dut(dut):
    """Helper function to reset the DUT"""
    dut.rst_n.value = 0
    dut.gpu_result_valid.value = 0
    dut.gpu_result_data.value = 0
    dut.gpu_result_addr.value = 0
    dut.gpu_result_reg.value = 0
    dut.gpu_exception.value = 0
    dut.result_ack.value = 0
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
