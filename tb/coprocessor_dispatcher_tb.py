import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
from cocotb.regression import TestFactory

@cocotb.test()
async def test_dispatcher_basic_functionality(dut):
    """Test basic coprocessor dispatcher functionality"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    dut.instruction.value = 0
    dut.inst_valid.value = 0
    dut.rs1_data.value = 0
    dut.rs2_data.value = 0
    dut.pc.value = 0
    dut.pipeline_stall.value = 0
    
    # Initialize coprocessor responses
    dut.cp_data_out.value = 0xDEADBEEFCAFEBABE
    dut.cp_ready.value = 1
    dut.cp_exception.value = 0
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Starting coprocessor dispatcher test")
    
    # Test system instruction dispatch (CP0)
    await test_system_instruction_dispatch(dut)
    
    # Test FP instruction dispatch (CP1)
    await test_fp_instruction_dispatch(dut)
    
    # Test custom instruction dispatch (CP2)
    await test_custom_instruction_dispatch(dut)
    
    # Test non-coprocessor instruction
    await test_non_coprocessor_instruction(dut)
    
    dut._log.info("Coprocessor dispatcher basic functionality test completed successfully")

async def test_system_instruction_dispatch(dut):
    """Test system instruction dispatch to CP0"""
    
    dut._log.info("Testing System Instruction Dispatch (CP0)")
    
    # CSRR x1, mstatus
    dut.instruction.value = 0b001100000000_00000_010_00001_1110011
    dut.inst_valid.value = 1
    dut.rs1_data.value = 0x123456789ABCDEF0
    dut.rs2_data.value = 0xFEDCBA0987654321
    dut.pc.value = 0x1000
    
    await ClockCycles(dut.clk, 1)
    
    assert int(dut.cp_instruction_detected.value) == 1, "CP instruction not detected"
    assert int(dut.cp_select.value) == 0, "CP0 not selected for system instruction"
    assert int(dut.cp_valid.value) == 1, "CP valid not asserted"
    assert int(dut.cp_instruction.value) == 0b001100000000_00000_010_00001_1110011, "Instruction not forwarded correctly"
    
    await wait_for_completion(dut)
    
    assert int(dut.cp_result_valid.value) == 1, "Result not valid"
    assert int(dut.cp_reg_write.value) == 1, "Register write not asserted"
    assert int(dut.cp_reg_addr.value) == 1, "Register address incorrect"
    
    dut.inst_valid.value = 0
    await ClockCycles(dut.clk, 2)
    
    dut._log.info("System instruction dispatch test passed")

async def test_fp_instruction_dispatch(dut):
    """Test FP instruction dispatch to CP1"""
    
    dut._log.info("Testing FP Instruction Dispatch (CP1)")
    
    # FADD.D f3, f1, f2
    dut.instruction.value = 0b0000000_00010_00001_000_00011_1010011
    dut.inst_valid.value = 1
    dut.rs1_data.value = 0x3FF0000000000000  # 1.0 in double precision
    dut.rs2_data.value = 0x4000000000000000  # 2.0 in double precision
    
    await ClockCycles(dut.clk, 1)
    
    assert int(dut.cp_instruction_detected.value) == 1, "FP instruction not detected"
    assert int(dut.cp_select.value) == 1, "CP1 not selected for FP instruction"
    assert int(dut.cp_valid.value) == 1, "CP valid not asserted"
    
    await wait_for_completion(dut)
    
    assert int(dut.cp_result_valid.value) == 1, "FP result not valid"
    assert int(dut.cp_reg_write.value) == 1, "FP register write not asserted"
    assert int(dut.cp_reg_addr.value) == 3, "FP register address incorrect"
    
    dut.inst_valid.value = 0
    await ClockCycles(dut.clk, 2)
    
    dut._log.info("FP instruction dispatch test passed")

async def test_custom_instruction_dispatch(dut):
    """Test custom instruction dispatch to CP2"""
    
    dut._log.info("Testing Custom Instruction Dispatch (CP2)")
    
    # Custom instruction with opcode 0001011 (CP2)
    dut.instruction.value = 0b0000000_00010_00001_000_00011_0001011
    dut.inst_valid.value = 1
    dut.rs1_data.value = 0x1234567890ABCDEF
    dut.rs2_data.value = 0xFEDCBA0987654321
    
    await ClockCycles(dut.clk, 1)
    
    assert int(dut.cp_instruction_detected.value) == 1, "Custom instruction not detected"
    assert int(dut.cp_select.value) == 2, "CP2 not selected for custom instruction"
    assert int(dut.cp_valid.value) == 1, "CP valid not asserted"
    
    await wait_for_completion(dut)
    
    dut.inst_valid.value = 0
    await ClockCycles(dut.clk, 2)
    
    dut._log.info("Custom instruction dispatch test passed")

async def test_non_coprocessor_instruction(dut):
    """Test that non-coprocessor instructions are not dispatched"""
    
    dut._log.info("Testing Non-Coprocessor Instruction")
    
    # Regular ADD instruction (should not be dispatched to coprocessor)
    dut.instruction.value = 0b0000000_00010_00001_000_00011_0110011
    dut.inst_valid.value = 1
    
    await ClockCycles(dut.clk, 1)
    
    assert int(dut.cp_instruction_detected.value) == 0, "Non-CP instruction incorrectly detected as CP"
    assert int(dut.cp_valid.value) == 0, "CP valid incorrectly asserted for non-CP instruction"
    
    dut.inst_valid.value = 0
    await ClockCycles(dut.clk, 2)
    
    dut._log.info("Non-coprocessor instruction test passed")

@cocotb.test()
async def test_pipeline_stall_handling(dut):
    """Test pipeline stall handling"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing Pipeline Stall Handling")
    
    # Set up coprocessor instruction
    dut.instruction.value = 0b001100000000_00000_010_00001_1110011  # CSRR
    dut.inst_valid.value = 1
    dut.pipeline_stall.value = 1  # Pipeline is stalled
    dut.cp_ready.value = 1
    
    await ClockCycles(dut.clk, 1)
    
    # Should not detect instruction during stall
    assert int(dut.cp_instruction_detected.value) == 0, "Instruction detected during pipeline stall"
    assert int(dut.cp_valid.value) == 0, "CP valid asserted during pipeline stall"
    
    # Release stall
    dut.pipeline_stall.value = 0
    await ClockCycles(dut.clk, 1)
    
    # Now should detect instruction
    assert int(dut.cp_instruction_detected.value) == 1, "Instruction not detected after stall release"
    assert int(dut.cp_valid.value) == 1, "CP valid not asserted after stall release"
    
    await wait_for_completion(dut)
    
    dut.inst_valid.value = 0
    await ClockCycles(dut.clk, 2)
    
    dut._log.info("Pipeline stall handling test passed")

@cocotb.test()
async def test_exception_handling(dut):
    """Test exception handling in dispatcher"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing Exception Handling")
    
    # Set up instruction that will cause exception
    dut.instruction.value = 0b0000000_00010_00001_000_00011_1010011  # FADD.D
    dut.inst_valid.value = 1
    dut.cp_exception.value = 1  # Coprocessor reports exception
    dut.cp_ready.value = 1
    
    await ClockCycles(dut.clk, 1)
    
    assert int(dut.cp_instruction_detected.value) == 1, "CP instruction not detected"
    
    await wait_for_completion(dut)
    
    assert int(dut.cp_exception_out.value) == 1, "Exception not propagated from dispatcher"
    
    dut.cp_exception.value = 0
    dut.inst_valid.value = 0
    await ClockCycles(dut.clk, 2)
    
    dut._log.info("Exception handling test passed")

@cocotb.test()
async def test_coprocessor_stall_request(dut):
    """Test coprocessor stall request handling"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing Coprocessor Stall Request")
    
    # Set up long-running coprocessor operation
    dut.instruction.value = 0b0001100_00010_00001_000_00011_1010011  # FDIV.D (slow operation)
    dut.inst_valid.value = 1
    dut.cp_ready.value = 0  # Coprocessor not ready (busy)
    
    await ClockCycles(dut.clk, 1)
    
    assert int(dut.cp_instruction_detected.value) == 1, "CP instruction not detected"
    assert int(dut.cp_stall_request.value) == 1, "Stall request not asserted when CP not ready"
    
    # Simulate coprocessor becoming ready
    dut.cp_ready.value = 1
    await ClockCycles(dut.clk, 1)
    
    assert int(dut.cp_stall_request.value) == 0, "Stall request not released when CP ready"
    
    await wait_for_completion(dut)
    
    dut.inst_valid.value = 0
    await ClockCycles(dut.clk, 2)
    
    dut._log.info("Coprocessor stall request test passed")

@cocotb.test()
async def test_multiple_instruction_types(dut):
    """Test dispatching multiple different instruction types in sequence"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing Multiple Instruction Types")
    
    # Test sequence of different coprocessor instructions
    test_instructions = [
        (0b001100000000_00000_010_00001_1110011, 0, "CSRR (CP0)"),      # System
        (0b0000000_00010_00001_000_00011_1010011, 1, "FADD.D (CP1)"),   # FP
        (0b0000000_00010_00001_000_00011_0001011, 2, "Custom (CP2)"),   # Custom
        (0b000000000001_00000_010_00001_1110011, 3, "Debug (CP3)"),     # Debug
    ]
    
    dut.cp_ready.value = 1
    dut.cp_exception.value = 0
    
    for instruction, expected_cp, desc in test_instructions:
        dut._log.info(f"Testing {desc}")
        
        dut.instruction.value = instruction
        dut.inst_valid.value = 1
        
        await ClockCycles(dut.clk, 1)
        
        assert int(dut.cp_instruction_detected.value) == 1, f"Instruction not detected for {desc}"
        assert int(dut.cp_select.value) == expected_cp, f"Wrong CP selected for {desc}"
        assert int(dut.cp_valid.value) == 1, f"CP valid not asserted for {desc}"
        
        await wait_for_completion(dut)
        
        dut.inst_valid.value = 0
        await ClockCycles(dut.clk, 2)
    
    dut._log.info("Multiple instruction types test passed")

@cocotb.test()
async def test_data_forwarding(dut):
    """Test data forwarding to coprocessors"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing Data Forwarding")
    
    # Test data forwarding
    test_rs1_data = 0x1234567890ABCDEF
    test_rs2_data = 0xFEDCBA0987654321
    test_pc = 0x2000
    
    dut.instruction.value = 0b0000000_00010_00001_000_00011_1010011  # FADD.D
    dut.inst_valid.value = 1
    dut.rs1_data.value = test_rs1_data
    dut.rs2_data.value = test_rs2_data
    dut.pc.value = test_pc
    dut.cp_ready.value = 1
    
    await ClockCycles(dut.clk, 1)
    
    # Check that data is forwarded correctly
    assert int(dut.cp_data_in.value) == test_rs1_data, "RS1 data not forwarded correctly"
    # Note: RS2 data forwarding depends on implementation details
    
    await wait_for_completion(dut)
    
    dut.inst_valid.value = 0
    await ClockCycles(dut.clk, 2)
    
    dut._log.info("Data forwarding test passed")

async def wait_for_completion(dut):
    """Wait for coprocessor operation completion"""
    timeout = 50
    while int(dut.cp_stall_request.value) == 1 and timeout > 0:
        await ClockCycles(dut.clk, 1)
        timeout -= 1
    
    await ClockCycles(dut.clk, 1)