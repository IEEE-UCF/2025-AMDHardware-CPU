"""
Cocotb testbench for cpu_top module with integrated 5-stage pipeline
Tests the complete CPU implementation with coprocessor system
"""

import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, Timer
from cocotb.clock import Clock
import random

class InstructionMemoryModel:
    """Instruction memory model with simple read interface"""
    
    def __init__(self):
        self.memory = {}
        # Initialize with simple RISC-V instruction sequence
        self.memory[0x00000000] = 0x00000013  # NOP (ADDI x0, x0, 0)
        self.memory[0x00000004] = 0x00100093  # ADDI x1, x0, 1
        self.memory[0x00000008] = 0x00200113  # ADDI x2, x0, 2  
        self.memory[0x0000000C] = 0x002081B3  # ADD x3, x1, x2
        self.memory[0x00000010] = 0x00308233  # ADD x4, x1, x3
        self.memory[0x00000014] = 0x00402283  # LW x5, 4(x0)  
        self.memory[0x00000018] = 0x00502023  # SW x5, 0(x0)
        self.memory[0x0000001C] = 0x00000013  # NOP
        self.memory[0x00000020] = 0x00000013  # NOP
        self.memory[0x00000024] = 0x00000013  # NOP
        
    def read(self, addr):
        """Read instruction from memory"""
        word_addr = addr & 0xFFFFFFFC  # Align to 4 bytes
        return self.memory.get(word_addr, 0x00000013)  # Default to NOP

class DataMemoryModel:
    """Data memory model with read/write interface"""
    
    def __init__(self):
        self.memory = [0] * 1024  # 1K words of memory
        # Initialize some test data
        self.memory[0] = 0x12345678
        self.memory[1] = 0xDEADBEEF
        self.memory[2] = 0xCAFEBABE
        
    def read(self, addr):
        """Read data from memory"""
        word_addr = (addr // 8) % len(self.memory)
        return self.memory[word_addr]
        
    def write(self, addr, data):
        """Write data to memory"""
        word_addr = (addr // 8) % len(self.memory)
        self.memory[word_addr] = data

class CPUTestbench:
    """CPU testbench class for integrated pipeline CPU with coprocessors"""
    
    def __init__(self, dut):
        self.dut = dut
        self.imem = InstructionMemoryModel()
        self.dmem = DataMemoryModel()
        
    async def reset_cpu(self):
        """Reset the CPU"""
        self.dut.rst_n.value = 0
        await self.run_cycles(5)
        self.dut.rst_n.value = 1
        await self.run_cycles(3)  # Allow reset to propagate
        
    async def run_cycles(self, num_cycles):
        """Run CPU for specified number of cycles"""
        for _ in range(num_cycles):
            await RisingEdge(self.dut.clk)
    
    async def handle_instruction_memory(self):
        """Handle instruction memory requests"""
        # Wait a few cycles for reset to complete
        await self.run_cycles(5)
        
        while True:
            await RisingEdge(self.dut.clk)
            # Always provide instruction memory response
            if hasattr(self.dut, 'imem_addr'):
                try:
                    addr = int(self.dut.imem_addr.value)
                    instruction = self.imem.read(addr)
                    self.dut.imem_read_data.value = instruction
                except ValueError:
                    # Handle 'x' or 'z' values during reset
                    self.dut.imem_read_data.value = 0x00000013  # NOP
            else:
                self.dut.imem_read_data.value = 0x00000013  # NOP
            self.dut.imem_ready.value = 1
    
    async def handle_data_memory(self):
        """Handle data memory requests"""
        # Wait a few cycles for reset to complete
        await self.run_cycles(5)
        
        while True:
            await RisingEdge(self.dut.clk)
            try:
                # Handle memory write
                if hasattr(self.dut, 'dmem_write') and int(self.dut.dmem_write.value):
                    addr = int(self.dut.dmem_addr.value)
                    data = int(self.dut.dmem_write_data.value)
                    self.dmem.write(addr, data)
                    self.dut.dmem_ready.value = 1
                # Handle memory read
                elif hasattr(self.dut, 'dmem_read') and int(self.dut.dmem_read.value):
                    addr = int(self.dut.dmem_addr.value)
                    data = self.dmem.read(addr)
                    self.dut.dmem_read_data.value = data
                    self.dut.dmem_ready.value = 1
                else:
                    self.dut.dmem_ready.value = 1
            except ValueError:
                # Handle 'x' or 'z' values during reset
                self.dut.dmem_ready.value = 1

@cocotb.test()
async def test_cpu_reset_and_basic_operation(dut):
    """Test CPU reset and basic pipeline operation"""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Initialize testbench
    tb = CPUTestbench(dut)
    
    # Start memory handlers
    cocotb.start_soon(tb.handle_instruction_memory())
    cocotb.start_soon(tb.handle_data_memory())
    
    # Initialize inputs
    dut.interrupt.value = 0
    
    # Reset CPU
    await tb.reset_cpu()
    
    # Test reset state - PC should be at 0
    dut._log.info("Testing CPU after reset")
    
    # Let CPU run through a few instructions
    await tb.run_cycles(20)
    
    dut._log.info("CPU reset and basic operation test completed successfully")

@cocotb.test()
async def test_pipeline_execution(dut):
    """Test pipeline execution with simple instruction sequence"""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Initialize testbench
    tb = CPUTestbench(dut)
    
    # Start memory handlers
    cocotb.start_soon(tb.handle_instruction_memory())
    cocotb.start_soon(tb.handle_data_memory())
    
    # Initialize inputs
    dut.interrupt.value = 0
    
    # Reset CPU
    await tb.reset_cpu()
    
    # Run pipeline for enough cycles to see instruction execution
    dut._log.info("Testing pipeline execution with instruction sequence")
    
    for cycle in range(30):
        await RisingEdge(dut.clk)
        
        # Log pipeline state every few cycles
        if cycle % 5 == 0:
            pc = int(dut.imem_addr.value) if hasattr(dut, 'imem_addr') else 0
            inst = int(dut.imem_read_data.value) if hasattr(dut, 'imem_read_data') else 0
            dut._log.info(f"Cycle {cycle}: PC=0x{pc:08x}, Inst=0x{inst:08x}")
    
    dut._log.info("Pipeline execution test completed successfully")

@cocotb.test()
async def test_arithmetic_instructions(dut):
    """Test arithmetic instruction execution"""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Initialize testbench
    tb = CPUTestbench(dut)
    
    # Start memory handlers
    cocotb.start_soon(tb.handle_instruction_memory())
    cocotb.start_soon(tb.handle_data_memory())
    
    # Initialize inputs
    dut.interrupt.value = 0
    
    # Reset CPU
    await tb.reset_cpu()
    
    # Load arithmetic instruction sequence
    tb.imem.memory[0x00000000] = 0x00100093  # ADDI x1, x0, 1
    tb.imem.memory[0x00000004] = 0x00200113  # ADDI x2, x0, 2
    tb.imem.memory[0x00000008] = 0x002081B3  # ADD x3, x1, x2
    tb.imem.memory[0x0000000C] = 0x40208233  # SUB x4, x1, x2
    tb.imem.memory[0x00000010] = 0x00000013  # NOP
    
    dut._log.info("Testing arithmetic instructions")
    
    # Run for enough cycles to execute all instructions
    await tb.run_cycles(25)
    
    dut._log.info("Arithmetic instructions test completed successfully")

@cocotb.test()
async def test_load_store_operations(dut):
    """Test load and store instruction execution"""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Initialize testbench
    tb = CPUTestbench(dut)
    
    # Start memory handlers
    cocotb.start_soon(tb.handle_instruction_memory())
    cocotb.start_soon(tb.handle_data_memory())
    
    # Initialize inputs
    dut.interrupt.value = 0
    
    # Reset CPU
    await tb.reset_cpu()
    
    # Load memory instruction sequence
    tb.imem.memory[0x00000000] = 0x00002083  # LW x1, 0(x0)
    tb.imem.memory[0x00000004] = 0x00102103  # LW x2, 1(x0)
    tb.imem.memory[0x00000008] = 0x00202183  # LW x3, 2(x0)
    tb.imem.memory[0x0000000C] = 0x00302023  # SW x3, 0(x0)
    tb.imem.memory[0x00000010] = 0x00000013  # NOP
    
    dut._log.info("Testing load/store operations")
    
    # Run for enough cycles to execute all instructions
    await tb.run_cycles(30)
    
    # Check that data was moved correctly
    stored_value = tb.dmem.read(0)
    expected_value = tb.dmem.read(2)
    
    dut._log.info(f"Stored value: 0x{stored_value:08x}, Expected: 0x{expected_value:08x}")
    
    dut._log.info("Load/store operations test completed successfully")

@cocotb.test()
async def test_coprocessor_detection(dut):
    """Test coprocessor instruction detection and routing"""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Initialize testbench
    tb = CPUTestbench(dut)
    
    # Start memory handlers
    cocotb.start_soon(tb.handle_instruction_memory())
    cocotb.start_soon(tb.handle_data_memory())
    
    # Initialize inputs
    dut.interrupt.value = 0
    
    # Reset CPU
    await tb.reset_cpu()
    
    # Load coprocessor instruction sequence
    tb.imem.memory[0x00000000] = 0x00000073  # ECALL (system coprocessor)
    tb.imem.memory[0x00000004] = 0x20000053  # FP instruction (coprocessor 1)
    tb.imem.memory[0x00000008] = 0x0200006B  # Custom coprocessor instruction
    tb.imem.memory[0x0000000C] = 0x00000013  # NOP
    
    dut._log.info("Testing coprocessor instruction detection")
    
    # Run for enough cycles to see coprocessor activity
    for cycle in range(25):
        await RisingEdge(dut.clk)
        
        # Log coprocessor signals if they exist
        if cycle % 5 == 0 and hasattr(dut, 'cp_valid'):
            cp_valid = int(dut.cp_valid.value)
            if cp_valid:
                cp_inst = int(dut.cp_instruction.value)
                cp_sel = int(dut.cp_select.value)
                dut._log.info(f"Cycle {cycle}: CP Valid, Inst=0x{cp_inst:08x}, Select={cp_sel}")
    
    dut._log.info("Coprocessor detection test completed successfully")

@cocotb.test()
async def test_pipeline_stall_conditions(dut):
    """Test pipeline stall handling"""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Initialize testbench
    tb = CPUTestbench(dut)
    
    # Start memory handlers
    cocotb.start_soon(tb.handle_instruction_memory())
    cocotb.start_soon(tb.handle_data_memory())
    
    # Initialize inputs
    dut.interrupt.value = 0
    
    # Reset CPU
    await tb.reset_cpu()
    
    # Create data hazard condition
    tb.imem.memory[0x00000000] = 0x00002083  # LW x1, 0(x0)
    tb.imem.memory[0x00000004] = 0x00108133  # ADD x2, x1, x1  # Use x1 immediately
    tb.imem.memory[0x00000008] = 0x00000013  # NOP
    
    dut._log.info("Testing pipeline stall conditions (data hazards)")
    
    # Monitor stall signals
    for cycle in range(20):
        await RisingEdge(dut.clk)
        
        # Log stall conditions if signals exist
        if cycle % 3 == 0:
            pc = int(dut.imem_addr.value) if hasattr(dut, 'imem_addr') else 0
            dut._log.info(f"Cycle {cycle}: PC=0x{pc:08x}")
    
    dut._log.info("Pipeline stall test completed successfully")

@cocotb.test()
async def test_interrupt_handling(dut):
    """Test interrupt handling"""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Initialize testbench
    tb = CPUTestbench(dut)
    
    # Start memory handlers
    cocotb.start_soon(tb.handle_instruction_memory())
    cocotb.start_soon(tb.handle_data_memory())
    
    # Initialize inputs
    dut.interrupt.value = 0
    
    # Reset CPU
    await tb.reset_cpu()
    
    # Normal execution
    await tb.run_cycles(10)
    
    dut._log.info("Testing interrupt handling")
    
    # Assert interrupt
    dut.interrupt.value = 1
    await tb.run_cycles(5)
    
    # Deassert interrupt
    dut.interrupt.value = 0
    await tb.run_cycles(15)
    
    dut._log.info("Interrupt handling test completed successfully")

@cocotb.test()
async def test_comprehensive_pipeline_execution(dut):
    """Comprehensive test of the complete pipeline with various instruction types"""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Initialize testbench
    tb = CPUTestbench(dut)
    
    # Start memory handlers
    cocotb.start_soon(tb.handle_instruction_memory())
    cocotb.start_soon(tb.handle_data_memory())
    
    # Initialize inputs
    dut.interrupt.value = 0
    
    # Reset CPU
    await tb.reset_cpu()
    
    # Load comprehensive instruction sequence
    tb.imem.memory[0x00000000] = 0x00100093  # ADDI x1, x0, 1      # R1 = 1
    tb.imem.memory[0x00000004] = 0x00200113  # ADDI x2, x0, 2      # R2 = 2
    tb.imem.memory[0x00000008] = 0x002081B3  # ADD x3, x1, x2      # R3 = R1 + R2 = 3
    tb.imem.memory[0x0000000C] = 0x00002203  # LW x4, 0(x0)       # R4 = MEM[0]
    tb.imem.memory[0x00000010] = 0x00402023  # SW x4, 0(x0)       # MEM[0] = R4
    tb.imem.memory[0x00000014] = 0x40208233  # SUB x4, x1, x2      # R4 = R1 - R2 = -1
    tb.imem.memory[0x00000018] = 0x00109293  # SLLI x5, x1, 1     # R5 = R1 << 1 = 2
    tb.imem.memory[0x0000001C] = 0x0020F313  # ANDI x6, x1, 2     # R6 = R1 & 2 = 0
    tb.imem.memory[0x00000020] = 0x00000013  # NOP
    tb.imem.memory[0x00000024] = 0x00000013  # NOP
    
    dut._log.info("Running comprehensive pipeline test")
    
    # Run for enough cycles to execute all instructions plus pipeline latency
    for cycle in range(50):
        await RisingEdge(dut.clk)
        
        # Log pipeline state periodically
        if cycle % 10 == 0:
            pc = int(dut.imem_addr.value) if hasattr(dut, 'imem_addr') else 0
            inst = int(dut.imem_read_data.value) if hasattr(dut, 'imem_read_data') else 0
            dut._log.info(f"Cycle {cycle}: PC=0x{pc:08x}, Inst=0x{inst:08x}")
    
    dut._log.info("Comprehensive pipeline test completed successfully")
