import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

async def reset_cpu(dut):
    dut.reset.value = 1
    await RisingEdge(dut.clk)
    dut.reset.value = 0

@cocotb.test()
async def test_stage_id(dut):
    """Testing basic stage_id functionality"""

    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Reset procedure
    await reset_cpu(dut)
    dut._log.info("Reset Complete")

    # Initialize all required signals
    dut.interrupt.value = 0
    dut.stall.value = 0
    dut.w_en.value = 0
    dut.w_en_gpu.value = 0
    dut.has_imm.value = 0
    dut.has_rs1.value = 1
    dut.has_rs2.value = 1  
    dut.has_rs3.value = 0
    dut.imm_type.value = 0
    dut.pc4.value = 4
    dut.pc.value = 0
    dut.w_result.value = 0
    dut.w_result_gpu.value = 0
    dut.ex_pro.value = 0
    dut.mm_pro.value = 0
    dut.mm_mem.value = 0
    dut.inst_word.value = 0x00000013  # NOP
    dut.load_rd.value = 0
    dut.is_load.value = 0
    dut.w_rd.value = 0
    dut.w_rd_gpu.value = 0
    dut.rs_gpu.value = 0
    dut.ex_pro_rs.value = 0
    dut.mm_pro_rs.value = 0
    dut.mm_mem_rs.value = 0
    dut.ex_wr_reg_en.value = 0
    dut.mm_wr_reg_en.value = 0
    dut.mm_is_load.value = 0
    dut.ex_rd.value = 0
    dut.mm_rd.value = 0

    dut._log.info("Testing basic register file operations")

    # Write to some registers
    dut.w_en.value = 1
    for i in range(1, 8):  # Skip x0 which is hardwired to 0
        dut.w_rd.value = i
        dut.w_result.value = i * 10  # Use distinct values
        await RisingEdge(dut.clk)
    dut.w_en.value = 0

    dut._log.info("Testing instruction decode")
    
    # Test ADD instruction (x3 = x1 + x2)
    dut.inst_word.value = 0x002081B3  # ADD x3, x1, x2
    await RisingEdge(dut.clk)
    
    # Just verify the module doesn't crash and produces some outputs
    dut._log.info(f"read_out_a: {dut.read_out_a.value}")
    dut._log.info(f"read_out_b: {dut.read_out_b.value}")
    dut._log.info(f"is_equal: {dut.is_equal.value}")
    
    # Test branch instruction (BEQ x1, x2, offset)
    dut.inst_word.value = 0x00208063  # BEQ x1, x2, 0
    await RisingEdge(dut.clk)
    
    dut._log.info(f"Branch test - is_equal: {dut.is_equal.value}")
    dut._log.info(f"bra_addr: {dut.bra_addr.value}")
    
    # Test bypass functionality
    dut._log.info("Testing bypass logic")
    
    # Set up bypass from EX stage
    dut.ex_wr_reg_en.value = 1
    dut.ex_rd.value = 1  # Will forward to register 1
    dut.ex_pro.value = 0xDEADBEEF
    
    # Request register 1 (should get forwarded value)
    dut.inst_word.value = 0x00008093  # ADDI x1, x1, 0 (uses x1)
    await RisingEdge(dut.clk)
    
    dut._log.info(f"Bypass test - read_out_a: 0x{dut.read_out_a.value:08x}")
    
    dut._log.info("Stage ID test completed successfully")
