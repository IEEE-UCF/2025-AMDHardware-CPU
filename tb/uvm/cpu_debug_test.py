#!/usr/bin/env python3

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles
import logging

# Configure logging for very detailed output
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@cocotb.test()
async def cpu_detailed_debug_test(dut):
    """Detailed debug test with cycle-by-cycle monitoring"""
    print("🔍 Starting detailed CPU debug test")
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset CPU
    dut.rst_n.value = 0
    dut.interr.value = 0
    dut.cp_stall_external.value = 0
    
    await ClockCycles(dut.clk, 5)
    print("🔄 CPU in reset")
    
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)
    print("🚀 CPU reset released")
    
    # Start detailed monitoring for 50 cycles
    print("📊 Starting detailed cycle-by-cycle monitoring...")
    
    for cycle in range(50):
        await RisingEdge(dut.clk)
        
        try:
            # Basic CPU state - use actual signal names from cpu_top.sv
            pc = int(dut.pc.value) if hasattr(dut, 'pc') else "N/A"
            inst = int(dut.instruction.value) if hasattr(dut, 'instruction') else "N/A"
            debug_pc = int(dut.debug_pc.value) if hasattr(dut, 'debug_pc') else "N/A"
            debug_stall = int(dut.debug_stall.value) if hasattr(dut, 'debug_stall') else "N/A"
            
            # Check if this is an interesting cycle
            log_this_cycle = False
            log_msg = f"🔄 Cycle {cycle+1:3d}: "
            
            # Show PC from either signal
            if isinstance(pc, int):
                log_msg += f"PC=0x{pc:08x} "
            elif isinstance(debug_pc, int):
                log_msg += f"PC=0x{debug_pc:08x} "
                pc = debug_pc
            else:
                log_msg += f"PC={pc} "
                
            if isinstance(inst, int) and inst != 0:
                log_msg += f"INST=0x{inst:08x} "
                
                # Decode instruction type
                opcode = inst & 0x7F
                if opcode == 0x33:
                    log_msg += "[R-type] "
                elif opcode == 0x13:
                    log_msg += "[I-type] "
                elif opcode == 0x03:
                    log_msg += "[LOAD] "
                elif opcode == 0x23:
                    log_msg += "[STORE] "
                elif opcode == 0x63:
                    log_msg += "[BRANCH] "
                elif opcode == 0x6F:
                    log_msg += "[JAL] "
                elif opcode == 0x67:
                    log_msg += "[JALR] "
                else:
                    log_msg += f"[OP:0x{opcode:02x}] "
                log_this_cycle = True
            elif isinstance(inst, int):
                log_msg += "[NOP] "
            
            # Always log first 10 cycles or when something interesting happens
            if log_this_cycle or cycle < 10 or cycle % 10 == 0:
                print(log_msg.strip())
                
        except Exception as e:
            print(f"🔄 Cycle {cycle+1:3d}: Error reading signals: {e}")
    
    print("🎯 Detailed debug test completed")

@cocotb.test()
async def cpu_step_by_step_test(dut):
    """Step by step CPU analysis"""
    logger.info("👣 Starting step-by-step CPU test")
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset CPU
    dut.rst_n.value = 0
    dut.interr.value = 0
    dut.cp_stall_external.value = 0
    
    await ClockCycles(dut.clk, 5)
    logger.info("🔄 CPU in reset")
    
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)
    logger.info("🚀 CPU reset released")
    
    # Monitor first 20 cycles in detail
    for cycle in range(20):
        await RisingEdge(dut.clk)
        
        try:
            pc = int(dut.pc_reg.value) if hasattr(dut, 'pc_reg') else 0
            inst = int(dut.instruction.value) if hasattr(dut, 'instruction') else 0
            
            # Try to get pipeline stage info
            if_valid = int(dut.if_valid.value) if hasattr(dut, 'if_valid') else 0
            id_valid = int(dut.id_valid.value) if hasattr(dut, 'id_valid') else 0
            ex_valid = int(dut.ex_valid.value) if hasattr(dut, 'ex_valid') else 0
            mem_valid = int(dut.mem_valid.value) if hasattr(dut, 'mem_valid') else 0
            wb_valid = int(dut.wb_valid.value) if hasattr(dut, 'wb_valid') else 0
            
            stall = int(dut.pipeline_stall.value) if hasattr(dut, 'pipeline_stall') else 0
            
            logger.info(f"Cycle {cycle+1:2d}: PC=0x{pc:08x} INST=0x{inst:08x} "
                       f"Pipeline[{if_valid}{id_valid}{ex_valid}{mem_valid}{wb_valid}] "
                       f"Stall={stall}")
            
            # Decode instruction if it's not NOP
            if inst != 0x00000013:  # Not a NOP
                opcode = inst & 0x7F
                if opcode == 0x33:
                    logger.info(f"         → R-type ALU operation")
                elif opcode == 0x13:
                    logger.info(f"         → I-type ALU operation")
                elif opcode == 0x03:
                    logger.info(f"         → Load operation")
                elif opcode == 0x23:
                    logger.info(f"         → Store operation")
                elif opcode == 0x63:
                    logger.info(f"         → Branch operation")
                elif opcode == 0x6F:
                    logger.info(f"         → JAL jump")
                elif opcode == 0x67:
                    logger.info(f"         → JALR jump")
                else:
                    logger.info(f"         → Unknown opcode: 0x{opcode:02x}")
            else:
                logger.info(f"         → NOP instruction")
                
        except Exception as e:
            logger.info(f"Cycle {cycle+1:2d}: Error reading signals: {e}")
    
    logger.info("✅ Step-by-step analysis completed")

@cocotb.test()
async def cpu_memory_debug_test(dut):
    """Debug memory interface operations"""
    logger.info("💾 Starting memory interface debug test")
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset CPU
    dut.rst_n.value = 0
    dut.interr.value = 0
    dut.cp_stall_external.value = 0
    
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)
    
    # Monitor memory interface for 50 cycles
    for cycle in range(50):
        await RisingEdge(dut.clk)
        
        try:
            # Memory interface signals
            mem_addr = int(dut.mem_addr.value) if hasattr(dut, 'mem_addr') else 0
            mem_wdata = int(dut.mem_wdata.value) if hasattr(dut, 'mem_wdata') else 0
            mem_rdata = int(dut.mem_rdata.value) if hasattr(dut, 'mem_rdata') else 0
            mem_valid = int(dut.mem_valid.value) if hasattr(dut, 'mem_valid') else 0
            mem_ready = int(dut.mem_ready.value) if hasattr(dut, 'mem_ready') else 0
            mem_wstrb = int(dut.mem_wstrb.value) if hasattr(dut, 'mem_wstrb') else 0
            
            pc = int(dut.pc_reg.value) if hasattr(dut, 'pc_reg') else 0
            
            if mem_valid:
                if mem_wstrb != 0:  # Write operation
                    logger.info(f"Cycle {cycle+1:2d}: MEMORY WRITE - PC=0x{pc:08x} "
                               f"Addr=0x{mem_addr:08x} Data=0x{mem_wdata:08x} "
                               f"Strb=0x{mem_wstrb:01x} Ready={mem_ready}")
                else:  # Read operation
                    logger.info(f"Cycle {cycle+1:2d}: MEMORY READ  - PC=0x{pc:08x} "
                               f"Addr=0x{mem_addr:08x} Data=0x{mem_rdata:08x} "
                               f"Ready={mem_ready}")
            elif cycle % 10 == 0:  # Periodic status
                logger.info(f"Cycle {cycle+1:2d}: PC=0x{pc:08x} (no memory activity)")
                
        except Exception as e:
            if cycle % 20 == 0:  # Reduce error spam
                logger.info(f"Cycle {cycle+1:2d}: Error reading memory signals: {e}")
    
    logger.info("✅ Memory interface debug completed")
