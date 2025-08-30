import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock
import random

@cocotb.test()
async def test_control_unit_basic(dut):
    """Test basic control unit functionality"""
    
    # Initialize signals
    dut.instruction.value = 0
    dut.inst_valid.value = 0
    dut.stall.value = 0
    dut.is_equal.value = 0
    
    # Wait a bit
    await Timer(10, units="ns")
    
    # Test ADD instruction (0x00000033 - add x0, x0, x0)
    dut.instruction.value = 0x00000033
    dut.inst_valid.value = 1
    await Timer(10, units="ns")
    
    # Check some basic outputs are driven
    assert dut.reg_write.value.is_resolvable
    assert dut.mem_read.value.is_resolvable
    assert dut.mem_write.value.is_resolvable
    
    dut._log.info("Control unit basic test completed successfully")
