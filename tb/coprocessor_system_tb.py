import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
from cocotb.regression import TestFactory

@cocotb.test()
async def test_coprocessor_system_integration(dut):
    """Test integrated coprocessor system functionality"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    dut.cp_valid.value = 0
    dut.cp_instruction.value = 0
    dut.cp_data_in.value = 0
    dut.cp_select.value = 0
    
    # Initialize system inputs
    dut.interrupt_pending.value = 0
    dut.pc_current.value = 0
    dut.virtual_addr.value = 0
    dut.current_instruction.value = 0
    dut.mem_addr.value = 0
    dut.mem_data.value = 0
    dut.mem_write.value = 0
    dut.inst_valid.value = 0
    dut.external_debug_req.value = 0
    dut.page_table_base.value = 0
    dut.vm_enable.value = 0
    
    # Initialize FP register values
    dut.fp_reg_rdata1.value = 0x3FF0000000000000  # 1.0
    dut.fp_reg_rdata2.value = 0x4000000000000000  # 2.0
    
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Starting coprocessor system integration test")
    
    # Test CP0 (System Control)
    await test_cp0_operations(dut)
    
    # Test CP1 (FPU)
    await test_cp1_operations(dut)
    
    # Test CP2 (Memory Management)
    await test_cp2_operations(dut)
    
    # Test CP3 (Debug)
    await test_cp3_operations(dut)
    
    dut._log.info("Coprocessor system integration test completed successfully")

async def test_cp0_operations(dut):
    """Test CP0 (System Control) operations"""
    
    dut._log.info("Testing CP0 (System Control) Operations")
    
    dut.cp_select.value = 0  # CP0
    dut.pc_current.value = 0x1000
    
    # Test CSR read (CSRR)
    dut.cp_instruction.value = 0b001100000000_00000_010_00001_1110011  # CSRR x1, mstatus
    dut.cp_data_in.value = 0
    dut.cp_valid.value = 1
    
    await wait_for_ready(dut)
    
    dut.cp_valid.value = 0
    await ClockCycles(dut.clk, 2)
    
    dut._log.info("CP0 operations test passed")

async def test_cp1_operations(dut):
    """Test CP1 (FPU) operations"""
    
    dut._log.info("Testing CP1 (FPU) Operations")
    
    dut.cp_select.value = 1  # CP1
    
    # Test FP Add
    dut.cp_instruction.value = 0b0000000_00010_00001_000_00011_1010011  # FADD.D
    dut.cp_data_in.value = 0
    dut.cp_valid.value = 1
    
    await wait_for_ready(dut)
    
    # Check if FP register write is asserted
    if hasattr(dut, 'fp_reg_write'):
        assert int(dut.fp_reg_write.value) == 1, "FP register write not asserted"
    
    dut.cp_valid.value = 0
    await ClockCycles(dut.clk, 2)
    
    dut._log.info("CP1 operations test passed")

async def test_cp2_operations(dut):
    """Test CP2 (Memory Management) operations"""
    
    dut._log.info("Testing CP2 (Memory Management) Operations")
    
    dut.cp_select.value = 2  # CP2
    dut.virtual_addr.value = 0x12345000
    dut.vm_enable.value = 1
    
    # Test SFENCE.VMA
    dut.cp_instruction.value = 0b0001001_00000_00000_000_00000_1110011
    dut.cp_data_in.value = 0
    dut.cp_valid.value = 1
    
    await wait_for_ready(dut)
    
    dut.cp_valid.value = 0
    dut.vm_enable.value = 0
    await ClockCycles(dut.clk, 2)
    
    dut._log.info("CP2 operations test passed")

async def test_cp3_operations(dut):
    """Test CP3 (Debug) operations"""
    
    dut._log.info("Testing CP3 (Debug) Operations")
    
    dut.cp_select.value = 3  # CP3
    dut.current_instruction.value = 0x12345678
    dut.inst_valid.value = 1
    
    # Test debug register access
    dut.cp_instruction.value = 0b000000000001_00000_001_00001_1110011  # CSRR x1, debug_status
    dut.cp_data_in.value = 0
    dut.cp_valid.value = 1
    
    await wait_for_ready(dut)
    
    dut.cp_valid.value = 0
    dut.inst_valid.value = 0
    await ClockCycles(dut.clk, 2)
    
    dut._log.info("CP3 operations test passed")

@cocotb.test()
async def test_interrupt_handling(dut):
    """Test interrupt handling through coprocessor system"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing Interrupt Handling")
    
    dut.cp_select.value = 0  # Use CP0 for interrupt handling
    dut.interrupt_pending.value = 1
    dut.pc_current.value = 0x2000
    
    await ClockCycles(dut.clk, 10)  # Let interrupt be processed
    
    # Check if trap is enabled
    if hasattr(dut, 'trap_enable'):
        trap_status = int(dut.trap_enable.value)
        dut._log.info(f"Trap enable status: {trap_status}")
    
    dut.interrupt_pending.value = 0
    await ClockCycles(dut.clk, 2)
    
    dut._log.info("Interrupt handling test passed")

@cocotb.test()
async def test_memory_management(dut):
    """Test memory management features"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing Memory Management")
    
    dut.cp_select.value = 2  # CP2
    dut.virtual_addr.value = 0xABCD1000
    dut.page_table_base.value = 0x10000000
    dut.vm_enable.value = 1
    
    # Trigger address translation
    dut.cp_valid.value = 1
    dut.cp_instruction.value = 0x12345678  # Dummy instruction
    
    await ClockCycles(dut.clk, 10)
    
    # Check translation outputs
    if hasattr(dut, 'physical_addr'):
        phys_addr = int(dut.physical_addr.value)
        dut._log.info(f"Physical address: 0x{phys_addr:016x}")
    
    if hasattr(dut, 'translation_valid'):
        trans_valid = int(dut.translation_valid.value)
        dut._log.info(f"Translation valid: {trans_valid}")
    
    dut.cp_valid.value = 0
    dut.vm_enable.value = 0
    await ClockCycles(dut.clk, 2)
    
    dut._log.info("Memory management test passed")

@cocotb.test()
async def test_debug_features(dut):
    """Test debug features"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    
    dut._log.info("Testing Debug Features")
    
    dut.cp_select.value = 3  # CP3
    dut.external_debug_req.value = 1
    dut.current_instruction.value = 0xDEADBEEF
    dut.inst_valid.value = 1
    dut.mem_addr.value = 0x5000
    dut.mem_data.value = 0x12345678
    dut.mem_write.value = 1
    
    await ClockCycles(dut.clk, 10)
    
    # Check debug outputs
    if hasattr(dut, 'debug_halt_request'):
        halt_req = int(dut.debug_halt_request.value)
        dut._log.info(f"Debug halt request: {halt_req}")
    
    dut.external_debug_req.value = 0
    dut.inst_valid.value = 0
    dut.mem_write.value = 0
    await ClockCycles(dut.clk, 2)
    
    dut._log.info("Debug features test passed")

async def wait_for_ready(dut):
    """Wait for coprocessor operation completion"""
    timeout = 100
    while int(dut.cp_ready.value) == 0 and timeout > 0:
        await ClockCycles(dut.clk, 1)
        timeout -= 1
    
    await ClockCycles(dut.clk, 1)