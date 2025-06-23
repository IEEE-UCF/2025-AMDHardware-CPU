import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
from cocotb.regression import TestFactory

@cocotb.test()
async def test_mdu_basic_operations(dut):
    """Test basic MDU operations"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    dut.cp_enable.value = 0
    dut.cp_instruction.value = 0
    dut.cp_data_in.value = 0
    dut.rs1_data.value = 0
    dut.rs2_data.value = 0
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Starting MDU basic operations test")
    
    # Test Multiply
    await test_multiply(dut)
    
    # Test Multiply High
    await test_multiply_high(dut)
    
    # Test Divide
    await test_divide(dut)
    
    # Test Remainder
    await test_remainder(dut)
    
    dut._log.info("MDU basic operations test completed successfully")

async def test_multiply(dut):
    """Test multiply operation"""
    
    dut._log.info("Testing Multiply")
    
    dut.rs1_data.value = 123
    dut.rs2_data.value = 456
    
    # MUL x3, x1, x2
    dut.cp_instruction.value = 0b0000001_00010_00001_000_00011_0110011
    dut.cp_enable.value = 1
    
    await wait_for_completion(dut)
    
    assert int(dut.reg_write.value) == 1, "Register write not asserted"
    assert int(dut.reg_addr.value) == 3, "Write address incorrect"
    
    expected_result = 123 * 456
    actual_result = int(dut.reg_data.value)
    assert actual_result == expected_result, f"Multiply result incorrect: expected {expected_result}, got {actual_result}"
    
    dut.cp_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Multiply test passed")

async def test_multiply_high(dut):
    """Test multiply high operation"""
    
    dut._log.info("Testing Multiply High")
    
    dut.rs1_data.value = 0xFFFFFFFFFFFFFFFF
    dut.rs2_data.value = 0xFFFFFFFFFFFFFFFF
    
    # MULH x3, x1, x2
    dut.cp_instruction.value = 0b0000001_00010_00001_001_00011_0110011
    dut.cp_enable.value = 1
    
    await wait_for_completion(dut)
    
    assert int(dut.reg_write.value) == 1, "Register write not asserted"
    
    dut.cp_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Multiply High test passed")

async def test_divide(dut):
    """Test divide operation"""
    
    dut._log.info("Testing Divide")
    
    dut.rs1_data.value = 1000
    dut.rs2_data.value = 25
    
    # DIV x3, x1, x2
    dut.cp_instruction.value = 0b0000001_00010_00001_100_00011_0110011
    dut.cp_enable.value = 1
    
    await wait_for_completion(dut)
    
    assert int(dut.reg_write.value) == 1, "Register write not asserted"
    
    expected_result = 1000 // 25
    actual_result = int(dut.reg_data.value)
    assert actual_result == expected_result, f"Divide result incorrect: expected {expected_result}, got {actual_result}"
    
    dut.cp_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Divide test passed")

async def test_remainder(dut):
    """Test remainder operation"""
    
    dut._log.info("Testing Remainder")
    
    dut.rs1_data.value = 1000
    dut.rs2_data.value = 23
    
    # REM x3, x1, x2
    dut.cp_instruction.value = 0b0000001_00010_00001_110_00011_0110011
    dut.cp_enable.value = 1
    
    await wait_for_completion(dut)
    
    assert int(dut.reg_write.value) == 1, "Register write not asserted"
    
    expected_result = 1000 % 23
    actual_result = int(dut.reg_data.value)
    assert actual_result == expected_result, f"Remainder result incorrect: expected {expected_result}, got {actual_result}"
    
    dut.cp_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Remainder test passed")

@cocotb.test()
async def test_divide_by_zero(dut):
    """Test division by zero handling"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing Division by Zero")
    
    dut.rs1_data.value = 100
    dut.rs2_data.value = 0
    
    # DIV x3, x1, x2
    dut.cp_instruction.value = 0b0000001_00010_00001_100_00011_0110011
    dut.cp_enable.value = 1
    
    await wait_for_completion(dut)
    
    # Check MDU flags for divide by zero
    mdu_flags = int(dut.mdu_flags.value)
    assert mdu_flags & 0x8, "Divide by zero flag not set"  # Bit 3 is div_zero flag
    
    # Result should be -1 (all 1s)
    actual_result = int(dut.reg_data.value)
    assert actual_result == 0xFFFFFFFFFFFFFFFF, f"Divide by zero result incorrect: expected -1, got {actual_result}"
    
    dut.cp_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Division by Zero test passed")

@cocotb.test()
async def test_32bit_operations(dut):
    """Test 32-bit MDU operations"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing 32-bit Operations")
    
    dut.rs1_data.value = 0x12345678
    dut.rs2_data.value = 0x123
    
    # MULW x3, x1, x2
    dut.cp_instruction.value = 0b0000001_00010_00001_000_00011_0111011
    dut.cp_enable.value = 1
    
    await wait_for_completion(dut)
    
    assert int(dut.reg_write.value) == 1, "Register write not asserted"
    
    dut.cp_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("32-bit Operations test passed")

@cocotb.test()
async def test_unsigned_operations(dut):
    """Test unsigned MDU operations"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing Unsigned Operations")
    
    dut.rs1_data.value = 0xFFFFFFFFFFFFFFFF
    dut.rs2_data.value = 2
    
    # DIVU x3, x1, x2
    dut.cp_instruction.value = 0b0000001_00010_00001_101_00011_0110011
    dut.cp_enable.value = 1
    
    await wait_for_completion(dut)
    
    assert int(dut.reg_write.value) == 1, "Register write not asserted"
    
    # Test REMU
    dut.cp_instruction.value = 0b0000001_00010_00001_111_00011_0110011
    dut.cp_enable.value = 1
    
    await wait_for_completion(dut)
    dut.cp_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Unsigned Operations test passed")

async def wait_for_completion(dut):
    """Wait for MDU operation completion"""
    await ClockCycles(dut.clk, 1)
    
    # Wait while busy
    timeout = 100
    while int(dut.mdu_busy.value) == 1 and timeout > 0:
        await ClockCycles(dut.clk, 1)
        timeout -= 1
    
    # Wait for ready
    timeout = 100
    while int(dut.cp_ready.value) == 0 and timeout > 0:
        await ClockCycles(dut.clk, 1)
        timeout -= 1
    
    await ClockCycles(dut.clk, 1)