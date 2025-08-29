import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
from cocotb.regression import TestFactory

@cocotb.test()
async def test_int_alu_basic_operations(dut):
    """Test basic integer ALU operations"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    dut.alu_enable.value = 0
    dut.alu_operation.value = 0
    dut.alu_format.value = 1  # 64-bit operation
    dut.operand_a.value = 0
    dut.operand_b.value = 0
    dut.operand_c.value = 0
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Starting integer ALU basic operations test")
    
    # Test arithmetic operations
    await test_add_operation(dut)
    await test_sub_operation(dut)
    await test_mul_operation(dut)
    await test_div_operation(dut)
    
    dut._log.info("Integer ALU basic operations test completed successfully")

async def test_add_operation(dut):
    """Test ADD operation"""
    
    dut._log.info("Testing ADD Operation")
    
    dut.operand_a.value = 100
    dut.operand_b.value = 50
    dut.alu_operation.value = 0  # ALU_ADD
    dut.alu_enable.value = 1
    
    await wait_for_completion(dut)
    
    expected_result = 150
    actual_result = int(dut.result.value)
    assert actual_result == expected_result, f"ADD result incorrect: expected {expected_result}, got {actual_result}"
    assert int(dut.zero_flag.value) == 0, "Zero flag incorrect"
    assert int(dut.negative_flag.value) == 0, "Negative flag incorrect"
    
    dut.alu_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("ADD operation test passed")

async def test_sub_operation(dut):
    """Test SUB operation"""
    
    dut._log.info("Testing SUB Operation")
    
    dut.operand_a.value = 100
    dut.operand_b.value = 50
    dut.alu_operation.value = 1  # ALU_SUB
    dut.alu_enable.value = 1
    
    await wait_for_completion(dut)
    
    expected_result = 50
    actual_result = int(dut.result.value)
    assert actual_result == expected_result, f"SUB result incorrect: expected {expected_result}, got {actual_result}"
    
    dut.alu_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("SUB operation test passed")

async def test_mul_operation(dut):
    """Test MUL operation"""
    
    dut._log.info("Testing MUL Operation")
    
    dut.operand_a.value = 12
    dut.operand_b.value = 13
    dut.alu_operation.value = 10  # ALU_MUL
    dut.alu_enable.value = 1
    
    await wait_for_completion(dut)
    
    expected_result = 156
    actual_result = int(dut.result.value)
    assert actual_result == expected_result, f"MUL result incorrect: expected {expected_result}, got {actual_result}"
    
    dut.alu_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("MUL operation test passed")

async def test_div_operation(dut):
    """Test DIV operation"""
    
    dut._log.info("Testing DIV Operation")
    
    dut.operand_a.value = 144
    dut.operand_b.value = 12
    dut.alu_operation.value = 14  # ALU_DIV
    dut.alu_enable.value = 1
    
    await wait_for_completion(dut)
    
    expected_result = 12
    actual_result = int(dut.result.value)
    assert actual_result == expected_result, f"DIV result incorrect: expected {expected_result}, got {actual_result}"
    
    dut.alu_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("DIV operation test passed")

@cocotb.test()
async def test_logical_operations(dut):
    """Test logical operations"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing logical operations")
    
    # Test AND operation
    dut.operand_a.value = 0xFF00FF00FF00FF00
    dut.operand_b.value = 0x0F0F0F0F0F0F0F0F
    dut.alu_operation.value = 2  # ALU_AND
    dut.alu_enable.value = 1
    
    await wait_for_completion(dut)
    
    expected_result = 0x0F000F000F000F00
    actual_result = int(dut.result.value)
    assert actual_result == expected_result, f"AND result incorrect: expected 0x{expected_result:016x}, got 0x{actual_result:016x}"
    
    dut.alu_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    # Test OR operation
    dut.operand_a.value = 0xFF00FF00FF00FF00
    dut.operand_b.value = 0x0F0F0F0F0F0F0F0F
    dut.alu_operation.value = 3  # ALU_OR
    dut.alu_enable.value = 1
    
    await wait_for_completion(dut)
    
    expected_result = 0xFF0FFF0FFF0FFF0F
    actual_result = int(dut.result.value)
    assert actual_result == expected_result, f"OR result incorrect: expected 0x{expected_result:016x}, got 0x{actual_result:016x}"
    
    dut.alu_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    # Test XOR operation
    dut.operand_a.value = 0xAAAAAAAAAAAAAAAA
    dut.operand_b.value = 0x5555555555555555
    dut.alu_operation.value = 4  # ALU_XOR
    dut.alu_enable.value = 1
    
    await wait_for_completion(dut)
    
    expected_result = 0xFFFFFFFFFFFFFFFF
    actual_result = int(dut.result.value)
    assert actual_result == expected_result, f"XOR result incorrect: expected 0x{expected_result:016x}, got 0x{actual_result:016x}"
    
    dut.alu_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Logical operations test passed")

@cocotb.test()
async def test_shift_operations(dut):
    """Test shift operations"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing shift operations")
    
    # Test SLL (Shift Left Logical)
    dut.operand_a.value = 0x0000000000000001
    dut.operand_b.value = 4
    dut.alu_operation.value = 5  # ALU_SLL
    dut.alu_enable.value = 1
    
    await wait_for_completion(dut)
    
    expected_result = 0x0000000000000010
    actual_result = int(dut.result.value)
    assert actual_result == expected_result, f"SLL result incorrect: expected 0x{expected_result:016x}, got 0x{actual_result:016x}"
    
    dut.alu_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    # Test SRL (Shift Right Logical)
    dut.operand_a.value = 0x0000000000000010
    dut.operand_b.value = 4
    dut.alu_operation.value = 6  # ALU_SRL
    dut.alu_enable.value = 1
    
    await wait_for_completion(dut)
    
    expected_result = 0x0000000000000001
    actual_result = int(dut.result.value)
    assert actual_result == expected_result, f"SRL result incorrect: expected 0x{expected_result:016x}, got 0x{actual_result:016x}"
    
    dut.alu_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Shift operations test passed")

@cocotb.test()
async def test_comparison_operations(dut):
    """Test comparison operations"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing comparison operations")
    
    # Test SLT (Set Less Than)
    dut.operand_a.value = 10
    dut.operand_b.value = 20
    dut.alu_operation.value = 8  # ALU_SLT
    dut.alu_enable.value = 1
    
    await wait_for_completion(dut)
    
    expected_result = 1
    actual_result = int(dut.result.value)
    assert actual_result == expected_result, f"SLT result incorrect: expected {expected_result}, got {actual_result}"
    
    dut.alu_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    # Test SLTU (Set Less Than Unsigned)
    dut.operand_a.value = 20
    dut.operand_b.value = 10
    dut.alu_operation.value = 9  # ALU_SLTU
    dut.alu_enable.value = 1
    
    await wait_for_completion(dut)
    
    expected_result = 0
    actual_result = int(dut.result.value)
    assert actual_result == expected_result, f"SLTU result incorrect: expected {expected_result}, got {actual_result}"
    
    dut.alu_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Comparison operations test passed")

@cocotb.test()
async def test_special_operations(dut):
    """Test special operations"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing special operations")
    
    # Test CLZ (Count Leading Zeros)
    dut.operand_a.value = 0x0000000000000001
    dut.alu_operation.value = 22  # ALU_CLZ
    dut.alu_enable.value = 1
    
    await wait_for_completion(dut)
    
    expected_result = 63
    actual_result = int(dut.result.value)
    assert actual_result == expected_result, f"CLZ result incorrect: expected {expected_result}, got {actual_result}"
    
    dut.alu_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    # Test PCNT (Population Count)
    dut.operand_a.value = 0xFFFFFFFFFFFFFFFF
    dut.alu_operation.value = 24  # ALU_PCNT
    dut.alu_enable.value = 1
    
    await wait_for_completion(dut)
    
    expected_result = 64
    actual_result = int(dut.result.value)
    assert actual_result == expected_result, f"PCNT result incorrect: expected {expected_result}, got {actual_result}"
    
    dut.alu_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    # Test BSWAP (Byte Swap)
    dut.operand_a.value = 0x0123456789ABCDEF
    dut.alu_operation.value = 25  # ALU_BSWAP
    dut.alu_enable.value = 1
    
    await wait_for_completion(dut)
    
    expected_result = 0xEFCDAB8967452301
    actual_result = int(dut.result.value)
    assert actual_result == expected_result, f"BSWAP result incorrect: expected 0x{expected_result:016x}, got 0x{actual_result:016x}"
    
    dut.alu_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Special operations test passed")

@cocotb.test()
async def test_status_flags(dut):
    """Test status flag generation"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing status flags")
    
    # Test zero flag
    dut.operand_a.value = 50
    dut.operand_b.value = 50
    dut.alu_operation.value = 1  # ALU_SUB
    dut.alu_enable.value = 1
    
    await wait_for_completion(dut)
    
    assert int(dut.zero_flag.value) == 1, "Zero flag not set when result is zero"
    assert int(dut.result.value) == 0, "Result should be zero"
    
    dut.alu_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    # Test negative flag
    dut.operand_a.value = 10
    dut.operand_b.value = 20
    dut.alu_operation.value = 1  # ALU_SUB
    dut.alu_enable.value = 1
    
    await wait_for_completion(dut)
    
    assert int(dut.negative_flag.value) == 1, "Negative flag not set when result is negative"
    
    dut.alu_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    # Test carry flag with overflow
    dut.operand_a.value = 0xFFFFFFFFFFFFFFFF
    dut.operand_b.value = 1
    dut.alu_operation.value = 0  # ALU_ADD
    dut.alu_enable.value = 1
    
    await wait_for_completion(dut)
    
    assert int(dut.carry_flag.value) == 1, "Carry flag not set on overflow"
    
    dut.alu_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Status flags test passed")

async def wait_for_completion(dut):
    """Wait for ALU operation completion"""
    await ClockCycles(dut.clk, 1)
    
    # Wait while busy
    timeout = 100
    while int(dut.alu_busy.value) == 1 and timeout > 0:
        await ClockCycles(dut.clk, 1)
        timeout -= 1
    
    # Wait for result valid
    timeout = 100
    while int(dut.result_valid.value) == 0 and timeout > 0:
        await ClockCycles(dut.clk, 1)
        timeout -= 1
    
    await ClockCycles(dut.clk, 1)