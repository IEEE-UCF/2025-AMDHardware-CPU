import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock

@cocotb.test()
async def test_interconnect_basic(dut):
    """Test basic interconnect functionality"""
    
    # Start the clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Initialize signals
    dut.rst_n.value = 0
    dut.master_req.value = 0
    dut.master_addr.value = 0
    dut.master_wdata.value = 0
    dut.master_we.value = 0
    dut.slave_rdata.value = 0
    dut.slave_ready.value = 0
    
    # Reset
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    
    # Test read operation
    dut.master_req.value = 1
    dut.master_addr.value = 0x1000
    dut.master_we.value = 0
    dut.slave_rdata.value = 0xDEADBEEF
    dut.slave_ready.value = 1
    
    await RisingEdge(dut.clk)
    
    # Check pass-through
    assert dut.slave_req.value == 1
    assert dut.slave_addr.value == 0x1000
    assert dut.slave_we.value == 0
    assert dut.master_rdata.value == 0xDEADBEEF
    assert dut.master_ready.value == 1
    
    dut._log.info("Interconnect basic test completed successfully")
