import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
from cocotb.regression import TestFactory
import random

@cocotb.test()
async def test_gpu_op_queue_basic(dut):
    """Test basic GPU operation queue functionality"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    dut.enqueue_valid.value = 0
    dut.gpu_opcode.value = 0
    dut.operand_a.value = 0
    dut.operand_b.value = 0
    dut.operand_c.value = 0
    dut.result_addr.value = 0
    dut.result_reg.value = 0
    dut.gpu_ready.value = 0
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Starting GPU operation queue basic test")
    
    # Test initial state
    assert int(dut.queue_empty.value) == 1, "Queue should be empty initially"
    assert int(dut.queue_full.value) == 0, "Queue should not be full initially"
    assert int(dut.queue_count.value) == 0, "Queue count should be 0"
    assert int(dut.dequeue_valid.value) == 0, "No valid output when empty"
    
    # Test single enqueue
    await enqueue_operation(dut, 0x01, 0x1234567890ABCDEF, 0xFEDCBA0987654321, 
                           0x1111222233334444, 0x8000000000000000, 5)
    
    assert int(dut.queue_empty.value) == 0, "Queue should not be empty after enqueue"
    assert int(dut.queue_count.value) == 1, "Queue count should be 1"
    assert int(dut.dequeue_valid.value) == 1, "Should have valid output"
    
    # Verify output values
    assert int(dut.gpu_op_out.value) == 0x01, "GPU opcode mismatch"
    assert int(dut.op_a_out.value) == 0x1234567890ABCDEF, "Operand A mismatch"
    assert int(dut.op_b_out.value) == 0xFEDCBA0987654321, "Operand B mismatch"
    assert int(dut.op_c_out.value) == 0x1111222233334444, "Operand C mismatch"
    assert int(dut.res_addr_out.value) == 0x8000000000000000, "Result address mismatch"
    assert int(dut.res_reg_out.value) == 5, "Result register mismatch"
    
    # Test dequeue
    await dequeue_operation(dut)
    
    assert int(dut.queue_empty.value) == 1, "Queue should be empty after dequeue"
    assert int(dut.queue_count.value) == 0, "Queue count should be 0"
    
    dut._log.info("GPU operation queue basic test completed successfully")

@cocotb.test()
async def test_gpu_op_queue_full_empty(dut):
    """Test queue full and empty conditions"""
    
    # Start clock and reset
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    await reset_dut(dut)
    
    dut._log.info("Testing queue full/empty conditions")
    
    # Fill the queue (assuming default depth of 16)
    queue_depth = 16
    for i in range(queue_depth):
        await enqueue_operation(dut, i, i*100, i*200, i*300, i*1000, i%32)
        assert int(dut.queue_count.value) == i + 1, f"Queue count should be {i+1}"
    
    # Queue should now be full
    assert int(dut.queue_full.value) == 1, "Queue should be full"
    assert int(dut.queue_count.value) == queue_depth, f"Queue count should be {queue_depth}"
    
    # Try to enqueue when full (should be ignored)
    dut.enqueue_valid.value = 1
    dut.gpu_opcode.value = 0xFF
    await ClockCycles(dut.clk, 1)
    dut.enqueue_valid.value = 0
    
    assert int(dut.queue_count.value) == queue_depth, "Queue count should not change when full"
    
    # Empty the queue
    dut.gpu_ready.value = 1
    for i in range(queue_depth):
        await ClockCycles(dut.clk, 1)
        assert int(dut.queue_count.value) == queue_depth - i - 1, f"Queue count should be {queue_depth - i - 1}"
    
    dut.gpu_ready.value = 0
    assert int(dut.queue_empty.value) == 1, "Queue should be empty"
    
    dut._log.info("Queue full/empty test completed successfully")

@cocotb.test()
async def test_gpu_op_queue_concurrent(dut):
    """Test concurrent enqueue and dequeue operations"""
    
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    await reset_dut(dut)
    
    dut._log.info("Testing concurrent enqueue/dequeue")
    
    # Enable GPU ready for concurrent operations
    dut.gpu_ready.value = 1
    
    # Perform concurrent enqueue/dequeue operations
    for i in range(20):
        # Randomly decide to enqueue
        if random.random() > 0.3 and int(dut.queue_full.value) == 0:
            await enqueue_operation(dut, i % 256, i*111, i*222, i*333, i*1000, i%32)
        
        # Wait a cycle for dequeue to happen
        await ClockCycles(dut.clk, 1)
        
        # Verify queue is functioning
        count = int(dut.queue_count.value)
        empty = int(dut.queue_empty.value)
        full = int(dut.queue_full.value)
        
        assert (count == 0) == (empty == 1), "Empty flag should match count"
        assert (count == 16) == (full == 1), "Full flag should match count"
    
    dut._log.info("Concurrent operations test completed successfully")

async def enqueue_operation(dut, opcode, op_a, op_b, op_c, res_addr, res_reg):
    """Helper function to enqueue a GPU operation"""
    dut.enqueue_valid.value = 1
    dut.gpu_opcode.value = opcode
    dut.operand_a.value = op_a
    dut.operand_b.value = op_b
    dut.operand_c.value = op_c
    dut.result_addr.value = res_addr
    dut.result_reg.value = res_reg
    
    await ClockCycles(dut.clk, 1)
    dut.enqueue_valid.value = 0

async def dequeue_operation(dut):
    """Helper function to dequeue a GPU operation"""
    dut.gpu_ready.value = 1
    await ClockCycles(dut.clk, 1)
    dut.gpu_ready.value = 0

async def reset_dut(dut):
    """Helper function to reset the DUT"""
    dut.rst_n.value = 0
    dut.enqueue_valid.value = 0
    dut.gpu_opcode.value = 0
    dut.operand_a.value = 0
    dut.operand_b.value = 0
    dut.operand_c.value = 0
    dut.result_addr.value = 0
    dut.result_reg.value = 0
    dut.gpu_ready.value = 0
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
