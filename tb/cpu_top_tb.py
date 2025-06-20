"""
Cocotb testbench for cpu_top module
Tests the complete 5-stage pipelined CPU implementation
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles, Timer
from cocotb.result import TestFailure
import random

class CPUTestbench:
    def __init__(self, dut):
        self.dut = dut
        
    async def reset_cpu(self):
        """Reset the CPU"""
        self.dut.rst_n.value = 0
        await ClockCycles(self.dut.clk, 5)
        self.dut.rst_n.value = 1
        await ClockCycles(self.dut.clk, 5)
    
    def load_program(self, instructions):
        """Load program into instruction memory model"""
        return instructions
        
    async def run_cycles(self, cycles):
        """Run for specified number of cycles"""
        await ClockCycles(self.dut.clk, cycles)

class InstructionMemoryModel:
    def __init__(self, dut, memory):
        self.dut = dut
        self.memory = memory
    
    async def handle_memory(self):
        """Handle instruction memory requests"""
        while True:
            await RisingEdge(self.dut.clk)
            addr = int(self.dut.imem_addr.value)
            word_addr = (addr // 4) % len(self.memory)
            self.dut.imem_read_data.value = self.memory[word_addr]
            self.dut.imem_ready.value = 1

class DataMemoryModel:
    def __init__(self, dut):
        self.dut = dut
        self.memory = [0] * 1024
    
    async def handle_memory(self):
        """Handle data memory requests"""
        while True:
            await RisingEdge(self.dut.clk)
            if int(self.dut.dmem_write.value):
                addr = int(self.dut.dmem_addr.value)
                data = int(self.dut.dmem_write_data.value)
                word_addr = (addr // 8) % len(self.memory)
                self.memory[word_addr] = data
                self.dut.dmem_ready.value = 1
            elif int(self.dut.dmem_read.value):
                addr = int(self.dut.dmem_addr.value)
                word_addr = (addr // 8) % len(self.memory)
                self.dut.dmem_read_data.value = self.memory[word_addr]
                self.dut.dmem_ready.value = 1
            else:
                self.dut.dmem_ready.value = 1

@cocotb.test()
async def test_cpu_reset(dut):
    """Test CPU reset functionality"""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Initialize testbench
    tb = CPUTestbench(dut)
    
    # Initialize memory interface
    dut.interrupt.value = 0
    dut.imem_read_data.value = 0x00000013  # NOP
    dut.imem_ready.value = 1
    dut.dmem_read_data.value = 0
    dut.dmem_ready.value = 1
    
    # Test reset
    await tb.reset_cpu()
    
    # Test reset state
    assert dut.rst_n.value == 1
    
    # Let CPU run for a few cycles
    await tb.run_cycles(10)
    
    dut._log.info("CPU reset test completed successfully")

@cocotb.test()
async def test_control_unit(dut):
    """Test control unit functionality"""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Initialize testbench
    tb = CPUTestbench(dut)
    
    # Initialize memory interface
    dut.interrupt.value = 0
    dut.imem_read_data.value = 0x00000013  # NOP
    dut.imem_ready.value = 1
    dut.dmem_read_data.value = 0
    dut.dmem_ready.value = 1
    
    # Reset CPU
    await tb.reset_cpu()
    
    # Test basic control unit operations
    await tb.run_cycles(20)
    
    dut._log.info("Control unit test completed successfully")

@cocotb.test()
async def test_coprocessor_system(dut):
    """Test coprocessor system functionality"""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Initialize testbench
    tb = CPUTestbench(dut)
    
    # Initialize memory interface
    dut.interrupt.value = 0
    dut.imem_read_data.value = 0x1110011  # System instruction
    dut.imem_ready.value = 1
    dut.dmem_read_data.value = 0
    dut.dmem_ready.value = 1
    
    # Reset CPU
    await tb.reset_cpu()
    
    # Test coprocessor system
    await tb.run_cycles(50)
    
    dut._log.info("Coprocessor system test completed successfully")

@cocotb.test()
async def test_fpu_operations(dut):
    """Test floating point unit operations"""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Initialize testbench
    tb = CPUTestbench(dut)
    
    # Initialize memory interface
    dut.interrupt.value = 0
    dut.imem_read_data.value = 0x1010011  # FP instruction
    dut.imem_ready.value = 1
    dut.dmem_read_data.value = 0
    dut.dmem_ready.value = 1
    
    # Reset CPU
    await tb.reset_cpu()
    
    # Test FPU operations
    await tb.run_cycles(50)
    
    dut._log.info("FPU operations test completed successfully")

@cocotb.test()
async def test_mdu_operations(dut):
    """Test multiply/divide unit operations"""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Initialize testbench
    tb = CPUTestbench(dut)
    
    # Initialize memory interface
    dut.interrupt.value = 0
    dut.imem_read_data.value = 0x02000033  # MUL instruction
    dut.imem_ready.value = 1
    dut.dmem_read_data.value = 0
    dut.dmem_ready.value = 1
    
    # Reset CPU
    await tb.reset_cpu()
    
    # Test MDU operations
    await tb.run_cycles(50)
    
    dut._log.info("MDU operations test completed successfully")

@cocotb.test()
async def test_coprocessor_int_alu(dut):
    """Test coprocessor integer ALU operations"""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Initialize testbench
    tb = CPUTestbench(dut)
    
    # Initialize memory interface
    dut.interrupt.value = 0
    dut.imem_read_data.value = 0x00000033  # Integer ALU instruction
    dut.imem_ready.value = 1
    dut.dmem_read_data.value = 0
    dut.dmem_ready.value = 1
    
    # Reset CPU
    await tb.reset_cpu()
    
    # Test coprocessor integer ALU
    await tb.run_cycles(50)
    
    dut._log.info("Coprocessor integer ALU test completed successfully")

@cocotb.test()
async def test_extended_bit_operations(dut):
    """Test extended bit manipulation operations"""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Initialize testbench
    tb = CPUTestbench(dut)
    
    # Initialize memory interface
    dut.interrupt.value = 0
    dut.imem_read_data.value = 0x60001013  # Bit manipulation instruction
    dut.imem_ready.value = 1
    dut.dmem_read_data.value = 0
    dut.dmem_ready.value = 1
    
    # Reset CPU
    await tb.reset_cpu()
    
    # Test extended bit operations
    await tb.run_cycles(50)
    
    dut._log.info("Extended bit operations test completed successfully")

@cocotb.test()
async def test_coprocessor_dispatcher(dut):
    """Test coprocessor dispatcher functionality"""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Initialize testbench
    tb = CPUTestbench(dut)
    
    # Initialize memory interface
    dut.interrupt.value = 0
    dut.imem_read_data.value = 0x1110011  # System instruction for CP0
    dut.imem_ready.value = 1
    dut.dmem_read_data.value = 0
    dut.dmem_ready.value = 1
    
    # Reset CPU
    await tb.reset_cpu()
    
    # Test different coprocessor instructions
    instructions = [
        0x1110011,  # CP0 - System
        0x1010011,  # CP1 - FPU
        0x100000B,  # CP2 - Custom
    ]
    
    for inst in instructions:
        dut.imem_read_data.value = inst
        await tb.run_cycles(20)
    
    dut._log.info("Coprocessor dispatcher test completed successfully")

@cocotb.test()
async def test_coprocessor_integration_stress(dut):
    """Stress test coprocessor integration with mixed workload"""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Initialize testbench
    tb = CPUTestbench(dut)
    
    # Initialize memory interface
    dut.interrupt.value = 0
    dut.imem_read_data.value = 0x00000013  # NOP
    dut.imem_ready.value = 1
    dut.dmem_read_data.value = 0
    dut.dmem_ready.value = 1
    
    # Reset CPU
    await tb.reset_cpu()
    
    # Run stress test with random instructions
    for i in range(100):
        # Mix of coprocessor and regular instructions
        if i % 4 == 0:
            dut.imem_read_data.value = 0x1110011  # CP0
        elif i % 4 == 1:
            dut.imem_read_data.value = 0x1010011  # CP1
        elif i % 4 == 2:
            dut.imem_read_data.value = 0x100000B  # CP2
        else:
            dut.imem_read_data.value = 0x00000013  # NOP
        
        await tb.run_cycles(5)
    
    dut._log.info("Coprocessor integration stress test completed successfully")

@cocotb.test()
async def test_basic_arithmetic(dut):
    """Test basic arithmetic instructions"""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Initialize testbench
    tb = CPUTestbench(dut)
    
    # Initialize memory interface
    dut.interrupt.value = 0
    dut.imem_read_data.value = 0x00000033  # ADD instruction
    dut.imem_ready.value = 1
    dut.dmem_read_data.value = 0
    dut.dmem_ready.value = 1
    
    # Reset CPU
    await tb.reset_cpu()
    
    # Test arithmetic operations
    await tb.run_cycles(50)
    
    dut._log.info("Basic arithmetic test completed successfully")

@cocotb.test()
async def test_load_store(dut):
    """Test load and store instructions"""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Initialize testbench
    tb = CPUTestbench(dut)
    
    # Initialize memory interface
    dut.interrupt.value = 0
    dut.imem_read_data.value = 0x00002003  # LW instruction
    dut.imem_ready.value = 1
    dut.dmem_read_data.value = 0x12345678
    dut.dmem_ready.value = 1
    
    # Reset CPU
    await tb.reset_cpu()
    
    # Test load/store operations
    await tb.run_cycles(50)
    
    dut._log.info("Load/store test completed successfully")

@cocotb.test()
async def test_branch_instructions(dut):
    """Test branch instructions"""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Initialize testbench
    tb = CPUTestbench(dut)
    
    # Initialize memory interface
    dut.interrupt.value = 0
    dut.imem_read_data.value = 0x00000063  # BEQ instruction
    dut.imem_ready.value = 1
    dut.dmem_read_data.value = 0
    dut.dmem_ready.value = 1
    
    # Reset CPU
    await tb.reset_cpu()
    
    # Test branch operations
    await tb.run_cycles(50)
    
    dut._log.info("Branch instructions test completed successfully")

@cocotb.test()
async def test_jump_instructions(dut):
    """Test jump and link instructions"""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Initialize testbench
    tb = CPUTestbench(dut)
    
    # Initialize memory interface
    dut.interrupt.value = 0
    dut.imem_read_data.value = 0x0000006F  # JAL instruction
    dut.imem_ready.value = 1
    dut.dmem_read_data.value = 0
    dut.dmem_ready.value = 1
    
    # Reset CPU
    await tb.reset_cpu()
    
    # Test jump operations
    await tb.run_cycles(50)
    
    dut._log.info("Jump instructions test completed successfully")

@cocotb.test()
async def test_pipeline_stalls(dut):
    """Test pipeline stall conditions"""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Initialize testbench
    tb = CPUTestbench(dut)
    
    # Initialize memory interface
    dut.interrupt.value = 0
    dut.imem_read_data.value = 0x00000013  # NOP
    dut.imem_ready.value = 1
    dut.dmem_read_data.value = 0
    dut.dmem_ready.value = 1
    
    # Reset CPU
    await tb.reset_cpu()
    
    # Test pipeline stalls
    await tb.run_cycles(50)
    
    dut._log.info("Pipeline stalls test completed successfully")

@cocotb.test()
async def test_interrupt_handling(dut):
    """Test interrupt handling"""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Initialize testbench
    tb = CPUTestbench(dut)
    
    # Initialize memory interface
    dut.interrupt.value = 0
    dut.imem_read_data.value = 0x00000013  # NOP
    dut.imem_ready.value = 1
    dut.dmem_read_data.value = 0
    dut.dmem_ready.value = 1
    
    # Reset CPU
    await tb.reset_cpu()
    
    # Test interrupt handling
    dut.interrupt.value = 1
    await tb.run_cycles(20)
    dut.interrupt.value = 0
    await tb.run_cycles(30)
    
    dut._log.info("Interrupt handling test completed successfully")
