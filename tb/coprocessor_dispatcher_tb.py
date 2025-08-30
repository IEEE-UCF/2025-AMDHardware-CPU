#!/usr/bin/env python3
"""
Simple Coprocessor Dispatcher Testbench
Basic functionality test - instruction detection and routing
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_dispatcher_basic(dut):
    """Basic dispatcher functionality test"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    dut.instruction.value = 0
    dut.inst_valid.value = 0
    dut.rs1_data.value = 0x12345678
    dut.rs2_data.value = 0x87654321
    dut.pc.value = 0x1000
    dut.pipeline_stall.value = 0
    dut.cp_data_out.value = 0xDEADBEEF
    dut.cp_ready.value = 1
    dut.cp_exception.value = 0
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing dispatcher basic operation")
    
    # Test 1: System instruction (CSR) -> should route to CP0
    dut._log.info("Testing system instruction routing to CP0")
    dut.instruction.value = 0x300F2073  # CSRRS x0, mstatus, x30 (opcode 1110011)
    dut.inst_valid.value = 1
    
    await ClockCycles(dut.clk, 2)
    
    # Should detect coprocessor instruction and route to CP0
    assert int(dut.cp_instruction_detected.value) == 1, "Should detect coprocessor instruction"
    assert int(dut.cp_valid.value) == 1, "CP valid should be asserted"
    assert int(dut.cp_select.value) == 0, "Should select CP0 for system instructions"
    assert int(dut.cp_instruction.value) == 0x300F2073, "Should pass through instruction"
    assert int(dut.cp_data_in.value) == 0x12345678, "Should pass rs1_data as input"
    
    # Test 2: Floating point instruction -> should route to CP1
    dut._log.info("Testing floating point instruction routing to CP1")
    dut.instruction.value = 0x00208053  # FADD.S f0, f1, f2 (opcode 1010011)
    
    await ClockCycles(dut.clk, 2)
    
    # Should route to CP1
    assert int(dut.cp_instruction_detected.value) == 1, "Should detect coprocessor instruction"
    assert int(dut.cp_select.value) == 1, "Should select CP1 for FP instructions"
    
    # Test 3: Custom instruction -> should route to CP2
    dut._log.info("Testing custom instruction routing to CP2")
    dut.instruction.value = 0x0020A00B  # Custom instruction (opcode 0001011)
    
    await ClockCycles(dut.clk, 2)
    
    # Should route to CP2
    assert int(dut.cp_instruction_detected.value) == 1, "Should detect coprocessor instruction"
    assert int(dut.cp_select.value) == 2, "Should select CP2 for custom instructions"
    
    # Test 4: Regular instruction -> should not route to coprocessor
    dut._log.info("Testing regular instruction (no coprocessor)")
    dut.instruction.value = 0x00208033  # ADD x0, x1, x2 (opcode 0110011)
    
    await ClockCycles(dut.clk, 2)
    
    # Should not detect coprocessor instruction
    assert int(dut.cp_instruction_detected.value) == 0, "Should not detect coprocessor instruction"
    assert int(dut.cp_valid.value) == 0, "CP valid should not be asserted"
    
    # Test 5: Stall behavior when coprocessor not ready
    dut._log.info("Testing stall behavior")
    dut.instruction.value = 0x300F2073  # CSR instruction again
    dut.cp_ready.value = 0  # Coprocessor not ready
    
    await ClockCycles(dut.clk, 2)
    
    # Should request stall
    assert int(dut.cp_instruction_detected.value) == 1, "Should detect coprocessor instruction"
    assert int(dut.cp_stall_request.value) == 1, "Should request stall when CP not ready"
    
    # Make coprocessor ready again
    dut.cp_ready.value = 1
    
    await ClockCycles(dut.clk, 2)
    
    # Should not request stall anymore
    assert int(dut.cp_stall_request.value) == 0, "Should not request stall when CP ready"
    
    # Test 6: Result handling
    dut._log.info("Testing result handling")
    dut.instruction.value = 0x300F2073  # CSR instruction with rd=0 (x0)
    dut.cp_data_out.value = 0xCAFEBABE
    
    await ClockCycles(dut.clk, 2)
    
    # Should handle results correctly
    assert int(dut.cp_result.value) == 0xCAFEBABE, "Should pass through coprocessor result"
    assert int(dut.cp_result_valid.value) == 1, "Result should be valid when cp_valid and cp_ready"
    assert int(dut.cp_reg_write.value) == 0, "Should not write to x0 register"
    
    # Test with non-zero rd
    dut.instruction.value = 0x300F20F3  # CSR instruction with rd=1 (x1)
    
    await ClockCycles(dut.clk, 2)
    
    assert int(dut.cp_reg_write.value) == 1, "Should write to non-zero register"
    assert int(dut.cp_reg_addr.value) == 1, "Should write to correct register address"
    assert int(dut.cp_reg_data.value) == 0xCAFEBABE, "Should write correct data"
    
    # Test 7: Pipeline stall behavior
    dut._log.info("Testing pipeline stall behavior")
    dut.pipeline_stall.value = 1
    dut.instruction.value = 0x300F2073  # CSR instruction
    
    await ClockCycles(dut.clk, 2)
    
    # Should not detect coprocessor instruction during pipeline stall
    assert int(dut.cp_instruction_detected.value) == 0, "Should not detect CP instruction during pipeline stall"
    assert int(dut.cp_valid.value) == 0, "CP valid should not be asserted during pipeline stall"
    
    # Test 8: Invalid instruction handling
    dut._log.info("Testing invalid instruction handling")
    dut.pipeline_stall.value = 0
    dut.inst_valid.value = 0  # Invalid instruction
    dut.instruction.value = 0x300F2073  # CSR instruction
    
    await ClockCycles(dut.clk, 2)
    
    # Should not detect coprocessor instruction when inst_valid is low
    assert int(dut.cp_instruction_detected.value) == 0, "Should not detect CP instruction when inst_valid=0"
    assert int(dut.cp_valid.value) == 0, "CP valid should not be asserted when inst_valid=0"
    
    dut._log.info("Dispatcher basic test passed")

@cocotb.test()
async def test_dispatcher_exception_handling(dut):
    """Test exception handling"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset and setup
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    
    # Setup basic inputs
    dut.instruction.value = 0x300F2073  # CSR instruction
    dut.inst_valid.value = 1
    dut.pipeline_stall.value = 0
    dut.rs1_data.value = 0x12345678
    dut.rs2_data.value = 0x87654321
    dut.pc.value = 0x1000
    dut.cp_data_out.value = 0xDEADBEEF
    dut.cp_ready.value = 1
    
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing exception handling")
    
    # Test coprocessor exception propagation
    dut.cp_exception.value = 1
    
    await ClockCycles(dut.clk, 2)
    
    # Should propagate exception
    assert int(dut.cp_exception_out.value) == 1, "Should propagate coprocessor exception"
    
    # Clear exception
    dut.cp_exception.value = 0
    
    await ClockCycles(dut.clk, 2)
    
    assert int(dut.cp_exception_out.value) == 0, "Exception should be cleared"
    
    dut._log.info("Exception handling test passed")

if __name__ == "__main__":
    import sys
    import pytest
    pytest.main([__file__] + sys.argv[1:])
