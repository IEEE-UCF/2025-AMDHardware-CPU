import cocotb
import random
from cocotb.triggers import Timer

@cocotb.test()
async def test_stage_wb(dut):
    """Testing write-back stage MUX functionality"""
    
    # Stage WB is a pure combinational module, no clock needed
    
    # Constraints:
    # Arbitrary ALU value
    WALU = 0x12345678
    # Arbitrary MEM value  
    WMEM = 0xDEADBEEF
    
    dut._log.info("Testing Write-Back Stage MUX")
    
    # Testing MUX - select ALU data
    dut.walu.value = WALU
    dut.wmem.value = WMEM
    dut.wmem2reg.value = 0  # Select ALU
    
    await Timer(1, units="ns")  # Allow combinational logic to settle
    
    assert dut.wdata.value.integer == WALU, f"ALU select failed: expected {WALU:08x}, got {dut.wdata.value.integer:08x}"
    
    # Testing MUX - select MEM data
    dut.wmem2reg.value = 1  # Select MEM
    
    await Timer(1, units="ns")  # Allow combinational logic to settle
    
    assert dut.wdata.value.integer == WMEM, f"MEM select failed: expected {WMEM:08x}, got {dut.wdata.value.integer:08x}"
    
    dut._log.info("Write-Back Stage test completed successfully")
