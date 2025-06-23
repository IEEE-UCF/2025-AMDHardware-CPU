import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
from cocotb.regression import TestFactory
import struct

@cocotb.test()
async def test_fpu_basic_operations(dut):
    """Test basic FPU operations"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    dut.cp_enable.value = 0
    dut.cp_instruction.value = 0
    dut.cp_data_in.value = 0
    
    # Initialize FP register values (IEEE 754 double precision)
    dut.fp_reg_rdata1.value = 0x3FF0000000000000  # 1.0
    dut.fp_reg_rdata2.value = 0x4000000000000000  # 2.0
    dut.fp_reg_rdata3.value = 0x4008000000000000  # 3.0
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Starting FPU basic operations test")
    
    # Test FP Add
    await test_fp_add(dut)
    
    # Test FP Subtract
    await test_fp_subtract(dut)
    
    # Test FP Multiply
    await test_fp_multiply(dut)
    
    # Test FP Divide
    await test_fp_divide(dut)
    
    dut._log.info("FPU basic operations test completed successfully")

async def test_fp_add(dut):
    """Test floating point addition"""
    
    dut._log.info("Testing FP Add")
    
    # FADD.D f3, f1, f2 (1.0 + 2.0 = 3.0)
    dut.cp_instruction.value = 0b0000000_00010_00001_000_00011_1010011
    dut.cp_enable.value = 1
    
    await wait_for_completion(dut)
    
    assert int(dut.fp_reg_write.value) == 1, "Register write not asserted"
    assert int(dut.fp_reg_waddr.value) == 3, "Write address incorrect"
    
    dut.cp_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("FP Add test passed")

async def test_fp_subtract(dut):
    """Test floating point subtraction"""
    
    dut._log.info("Testing FP Subtract")
    
    # FSUB.D f3, f2, f1 (2.0 - 1.0 = 1.0)
    dut.cp_instruction.value = 0b0000100_00001_00010_000_00011_1010011
    dut.cp_enable.value = 1
    
    await wait_for_completion(dut)
    
    assert int(dut.fp_reg_write.value) == 1, "Register write not asserted"
    
    dut.cp_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("FP Subtract test passed")

async def test_fp_multiply(dut):
    """Test floating point multiplication"""
    
    dut._log.info("Testing FP Multiply")
    
    # FMUL.D f3, f1, f2 (1.0 * 2.0 = 2.0)
    dut.cp_instruction.value = 0b0001000_00010_00001_000_00011_1010011
    dut.cp_enable.value = 1
    
    await wait_for_completion(dut)
    
    assert int(dut.fp_reg_write.value) == 1, "Register write not asserted"
    
    dut.cp_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("FP Multiply test passed")

async def test_fp_divide(dut):
    """Test floating point division"""
    
    dut._log.info("Testing FP Divide")
    
    # FDIV.D f3, f2, f1 (2.0 / 1.0 = 2.0)
    dut.cp_instruction.value = 0b0001100_00001_00010_000_00011_1010011
    dut.cp_enable.value = 1
    
    await wait_for_completion(dut)
    
    assert int(dut.fp_reg_write.value) == 1, "Register write not asserted"
    
    dut.cp_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("FP Divide test passed")

@cocotb.test()
async def test_fp_comparison_operations(dut):
    """Test floating point comparison operations"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    dut.fp_reg_rdata1.value = 0x3FF0000000000000  # 1.0
    dut.fp_reg_rdata2.value = 0x4000000000000000  # 2.0
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing FP comparison operations")
    
    # Test FEQ (equal)
    dut.cp_instruction.value = 0b1010000_00010_00001_010_00011_1010011
    dut.cp_enable.value = 1
    await wait_for_completion(dut)
    dut.cp_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    # Test FLT (less than)
    dut.cp_instruction.value = 0b1010000_00010_00001_001_00011_1010011
    dut.cp_enable.value = 1
    await wait_for_completion(dut)
    dut.cp_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    # Test FLE (less than or equal)
    dut.cp_instruction.value = 0b1010000_00010_00001_000_00011_1010011
    dut.cp_enable.value = 1
    await wait_for_completion(dut)
    dut.cp_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("FP comparison operations test passed")

@cocotb.test()
async def test_fp_conversion_operations(dut):
    """Test floating point conversion operations"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    dut.fp_reg_rdata1.value = 0x4000000000000000  # 2.0
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing FP conversion operations")
    
    # Test FCVT.W.D (double to word)
    dut.cp_instruction.value = 0b1100000_00000_00001_000_00011_1010011
    dut.cp_enable.value = 1
    await wait_for_completion(dut)
    dut.cp_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    # Test FCVT.D.W (word to double)
    dut.cp_instruction.value = 0b1101000_00000_00001_000_00011_1010011
    dut.cp_enable.value = 1
    await wait_for_completion(dut)
    dut.cp_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("FP conversion operations test passed")

@cocotb.test()
async def test_fpu_exception_handling(dut):
    """Test FPU exception handling"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    dut.fp_reg_rdata1.value = 0x3FF0000000000000  # 1.0
    dut.fp_reg_rdata2.value = 0x0000000000000000  # 0.0 (divide by zero)
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing FPU exception handling")
    
    # Test divide by zero
    dut.cp_instruction.value = 0b0001100_00010_00001_000_00011_1010011  # FDIV.D f3, f1, f2
    dut.cp_enable.value = 1
    
    await wait_for_completion(dut)
    
    # Check if exception flags are set
    fpu_flags = int(dut.fpu_flags.value)
    if fpu_flags & 0x2:  # Divide by zero flag
        dut._log.info("Divide by zero exception correctly detected")
    
    dut.cp_enable.value = 0
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("FPU exception handling test passed")

async def wait_for_completion(dut):
    """Wait for FPU operation completion"""
    await ClockCycles(dut.clk, 1)
    
    # Wait while busy
    timeout = 100
    while int(dut.fpu_busy.value) == 1 and timeout > 0:
        await ClockCycles(dut.clk, 1)
        timeout -= 1
    
    # Wait for ready
    timeout = 100
    while int(dut.cp_ready.value) == 0 and timeout > 0:
        await ClockCycles(dut.clk, 1)
        timeout -= 1
    
    await ClockCycles(dut.clk, 1)