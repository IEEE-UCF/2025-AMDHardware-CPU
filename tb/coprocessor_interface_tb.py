import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
from cocotb.regression import TestFactory

@cocotb.test()
async def test_coprocessor_interface_basic(dut):
    """Test basic coprocessor interface functionality"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    dut.cp_valid.value = 0
    dut.cp_instruction.value = 0
    dut.cp_data_in.value = 0
    dut.cp_select.value = 0
    
    # Initialize coprocessor responses
    dut.cp_ready_in.value = 0xF  # All CPs ready
    dut.cp_exception_in.value = 0x0  # No exceptions
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Starting coprocessor interface test")
    
    # Test CP0 selection
    await test_cp_selection(dut, 0, "CP0")
    
    # Test CP1 selection
    await test_cp_selection(dut, 1, "CP1")
    
    # Test CP2 selection
    await test_cp_selection(dut, 2, "CP2")
    
    # Test CP3 selection
    await test_cp_selection(dut, 3, "CP3")
    
    dut._log.info("Coprocessor interface test completed successfully")

async def test_cp_selection(dut, cp_num, cp_name):
    """Test selection of specific coprocessor"""
    
    dut._log.info(f"Testing {cp_name} selection")
    
    dut.cp_select.value = cp_num
    dut.cp_instruction.value = 0x12345678
    dut.cp_data_in.value = 0xABCDEF0123456789
    dut.cp_valid.value = 1
    
    await ClockCycles(dut.clk, 1)
    
    # Check outputs
    cp_enable_val = int(dut.cp_enable.value)
    assert cp_enable_val & (1 << cp_num), f"CP{cp_num} not enabled"
    assert int(dut.cp_inst_out.value) == 0x12345678, "Instruction not forwarded"
    assert int(dut.cp_data_to_cp.value) == 0xABCDEF0123456789, "Data not forwarded"
    assert int(dut.cp_ready.value) == 1, "Ready signal incorrect"
    
    dut.cp_valid.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info(f"{cp_name} test passed")

@cocotb.test()
async def test_exception_handling(dut):
    """Test exception handling in coprocessor interface"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    dut.cp_valid.value = 0
    dut.cp_ready_in.value = 0xF
    dut.cp_exception_in.value = 0x0
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing exception handling")
    
    dut.cp_select.value = 0
    dut.cp_valid.value = 1
    dut.cp_exception_in.value = 0x1  # Exception from CP0
    
    await ClockCycles(dut.clk, 1)
    
    assert int(dut.cp_exception.value) == 1, "Exception not propagated"
    
    dut.cp_exception_in.value = 0x0
    dut.cp_valid.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Exception handling test passed")

@cocotb.test()
async def test_ready_signal_propagation(dut):
    """Test ready signal propagation from coprocessors"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing ready signal propagation")
    
    # Test when all coprocessors are ready
    dut.cp_ready_in.value = 0xF
    dut.cp_select.value = 0
    dut.cp_valid.value = 1
    
    await ClockCycles(dut.clk, 1)
    assert int(dut.cp_ready.value) == 1, "Ready not propagated when CP ready"
    
    # Test when selected coprocessor is not ready
    dut.cp_ready_in.value = 0xE  # CP0 not ready
    await ClockCycles(dut.clk, 1)
    assert int(dut.cp_ready.value) == 0, "Ready incorrectly propagated when CP not ready"
    
    dut.cp_valid.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Ready signal propagation test passed")