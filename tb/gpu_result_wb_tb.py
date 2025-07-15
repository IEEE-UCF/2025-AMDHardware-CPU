import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
from cocotb.regression import TestFactory

@cocotb.test()
async def test_gpu_result_wb_basic(dut):
    """Test basic GPU result writeback functionality"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset and initialize
    await reset_dut(dut)
    
    dut._log.info("Starting GPU result writeback basic test")
    
    # Test initial state
    assert int(dut.wb_busy.value) == 0, "Writeback should not be busy initially"
    assert int(dut.reg_write_en.value) == 0, "Register write should be disabled"
    assert int(dut.mem_write_en.value) == 0, "Memory write should be disabled"
    assert int(dut.gpu_wb_exception.value) == 0, "No exception initially"
    
    # Test register writeback
    await test_register_writeback(dut)
    
    # Test memory writeback
    await test_memory_writeback(dut)
    
    # Test exception handling
    await test_exception_handling(dut)
    
    dut._log.info("GPU result writeback basic test completed successfully")

async def test_register_writeback(dut):
    """Test register writeback functionality"""
    
    dut._log.info("Testing register writeback")
    
    # Present a register writeback request
    dut.result_ready.value = 1
    dut.result_data.value = 0xDEADBEEFCAFEBABE
    dut.result_addr.value = 0  # No memory address = register write
    dut.result_reg.value = 10
    dut.result_exception.value = 0
    
    await ClockCycles(dut.clk, 1)
    
    # Should transition to register write state
    assert int(dut.wb_busy.value) == 1, "Writeback should be busy"
    
    await ClockCycles(dut.clk, 1)
    
    # Check register write outputs
    assert int(dut.reg_write_en.value) == 1, "Register write should be enabled"
    assert int(dut.reg_write_addr.value) == 10, "Register address should match"
    assert int(dut.reg_write_data.value) == 0xDEADBEEFCAFEBABE, "Register data should match"
    
    await ClockCycles(dut.clk, 1)
    
    # Should complete and acknowledge
    assert int(dut.result_ack.value) == 1, "Should acknowledge result"
    
    await ClockCycles(dut.clk, 1)
    
    # Should return to idle
    dut.result_ready.value = 0
    await ClockCycles(dut.clk, 1)
    assert int(dut.wb_busy.value) == 0, "Should return to idle"
    
    dut._log.info("Register writeback test passed")

async def test_memory_writeback(dut):
    """Test memory writeback functionality"""
    
    dut._log.info("Testing memory writeback")
    
    # Present a memory writeback request
    dut.result_ready.value = 1
    dut.result_data.value = 0x1234567890ABCDEF
    dut.result_addr.value = 0x8000000000001000  # Non-zero = memory write
    dut.result_reg.value = 0
    dut.result_exception.value = 0
    dut.mem_write_ready.value = 0  # Memory not ready initially
    
    await ClockCycles(dut.clk, 1)
    
    # Should transition to memory write state
    assert int(dut.wb_busy.value) == 1, "Writeback should be busy"
    
    await ClockCycles(dut.clk, 1)
    
    # Check memory write outputs
    assert int(dut.mem_write_en.value) == 1, "Memory write should be enabled"
    assert int(dut.mem_write_addr.value) == 0x8000000000001000, "Memory address should match"
    assert int(dut.mem_write_data.value) == 0x1234567890ABCDEF, "Memory data should match"
    assert int(dut.mem_write_strb.value) == 0xFF, "Write strobe should be full"
    
    # Should request stall while memory not ready
    assert int(dut.wb_stall_request.value) == 1, "Should request stall when memory not ready"
    
    # Make memory ready
    dut.mem_write_ready.value = 1
    await ClockCycles(dut.clk, 1)
    
    # Should complete and acknowledge
    assert int(dut.result_ack.value) == 1, "Should acknowledge result"
    assert int(dut.wb_stall_request.value) == 0, "Should not request stall when complete"
    
    await ClockCycles(dut.clk, 1)
    
    # Should return to idle
    dut.result_ready.value = 0
    dut.mem_write_ready.value = 0
    await ClockCycles(dut.clk, 1)
    assert int(dut.wb_busy.value) == 0, "Should return to idle"
    
    dut._log.info("Memory writeback test passed")

async def test_exception_handling(dut):
    """Test exception handling functionality"""
    
    dut._log.info("Testing exception handling")
    
    # Present an exception
    dut.result_ready.value = 1
    dut.result_data.value = 0x0000000000000000
    dut.result_addr.value = 0x4000  # Exception PC context
    dut.result_reg.value = 5
    dut.result_exception.value = 1
    
    await ClockCycles(dut.clk, 1)
    
    # Should transition to exception state
    assert int(dut.wb_busy.value) == 1, "Writeback should be busy"
    
    await ClockCycles(dut.clk, 1)
    
    # Check exception outputs
    assert int(dut.gpu_wb_exception.value) == 1, "Exception flag should be set"
    assert int(dut.exception_pc.value) == 0x4000, "Exception PC should match"
    assert int(dut.reg_write_en.value) == 0, "Register write should be disabled during exception"
    assert int(dut.mem_write_en.value) == 0, "Memory write should be disabled during exception"
    
    await ClockCycles(dut.clk, 1)
    
    # Should complete and acknowledge
    assert int(dut.result_ack.value) == 1, "Should acknowledge result"
    
    await ClockCycles(dut.clk, 1)
    
    # Should return to idle
    dut.result_ready.value = 0
    await ClockCycles(dut.clk, 1)
    assert int(dut.wb_busy.value) == 0, "Should return to idle"
    assert int(dut.gpu_wb_exception.value) == 0, "Exception flag should clear"
    
    dut._log.info("Exception handling test passed")

@cocotb.test()
async def test_gpu_result_wb_pipeline_stall(dut):
    """Test pipeline stall handling"""
    
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    await reset_dut(dut)
    
    dut._log.info("Testing pipeline stall handling")
    
    # Start a register writeback
    dut.result_ready.value = 1
    dut.result_data.value = 0x5555555555555555
    dut.result_addr.value = 0
    dut.result_reg.value = 15
    dut.result_exception.value = 0
    
    await ClockCycles(dut.clk, 1)
    
    # Assert pipeline stall
    dut.pipeline_stall.value = 1
    
    # Should remain in current state due to stall
    current_busy = int(dut.wb_busy.value)
    await ClockCycles(dut.clk, 3)
    assert int(dut.wb_busy.value) == current_busy, "State should not change during stall"
    
    # Release stall
    dut.pipeline_stall.value = 0
    await ClockCycles(dut.clk, 2)
    
    # Should complete normally
    assert int(dut.result_ack.value) == 1, "Should acknowledge after stall release"
    
    dut.result_ready.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Pipeline stall test completed successfully")

@cocotb.test()
async def test_gpu_result_wb_register_zero(dut):
    """Test writeback to register 0 (should be ignored)"""
    
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    await reset_dut(dut)
    
    dut._log.info("Testing register 0 writeback (should be ignored)")
    
    # Try to write to register 0
    dut.result_ready.value = 1
    dut.result_data.value = 0xAAAAAAAAAAAAAAAA
    dut.result_addr.value = 0
    dut.result_reg.value = 0  # Register 0
    dut.result_exception.value = 0
    
    await ClockCycles(dut.clk, 2)
    
    # Register write should be disabled for register 0
    assert int(dut.reg_write_en.value) == 0, "Register write should be disabled for register 0"
    
    # Should still complete
    await ClockCycles(dut.clk, 1)
    assert int(dut.result_ack.value) == 1, "Should still acknowledge"
    
    dut.result_ready.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Register 0 writeback test completed successfully")

async def reset_dut(dut):
    """Helper function to reset the DUT"""
    dut.rst_n.value = 0
    dut.result_ready.value = 0
    dut.result_data.value = 0
    dut.result_addr.value = 0
    dut.result_reg.value = 0
    dut.result_exception.value = 0
    dut.mem_write_ready.value = 0
    dut.pipeline_stall.value = 0
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
