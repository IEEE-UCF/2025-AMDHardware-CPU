import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock

async def reset_cpu(dut):
    dut.reset.value = 1
    await RisingEdge(dut.clk)
    dut.reset.value = 0

@cocotb.test()
async def test_stage_id(dut):
    """Testing buffer behavior during expected use, including correct instruction output"""

    BUFFER_SIZE = 16

    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Reset procedure
    await reset_cpu(dut)
    dut._log.info("Reset Complete")

    dut._log.info("Regular Passthrough Test")
    # Run instructions one cycle ahead of PC and check if output values are consistent

    # Set up instruction list
    instructions = [0b00000001010000000000000011100111, # jalr x1, 20(x0)
                    0b00000011001000010000000001100011, # beq x2, x18, 32
                    0b00000011011101011001000001100011, # bne x11, x23, 32
                    0b00000010000100000010100000100011, # sw x3, 48(x0)
                    0b00000001010011110001111110010011, # slli x31, x30, 20
                    0b11111011110100100000001010010011, # addi x5, x4, -67
                    0b11111111111111110110100000110111, # lui x16, -10
                    0b01000000011000111000010000110011, # sub x8, x7, x7
                   ]
    instructions.reverse()

    # Initialize simulation values for comparison
    pc = 0
    inst_valid = 0
    initialized = False
    prev_inst = instructions[0]

    # For each instructions, send values to regs and check output
    for inst in instructions:
        # Set pc and inst_valid before cycle
        dut.pc.value = pc
        dut.inst_valid = inst_valid

        # Set inst after cycle
        await RisingEdge(dut.clk)
        dut.inst.value = inst

        # After initializing, check reg values against simulation values 
        if initialized:
            assert dut.d_pc.value.integer == pc, 
            f"Error: Unexpected value for PC,\n {dut.d_pc.value.integer} instead of {pc}"
            assert dut.d_inst_valid.value.integer == inst_valid,
            f"Error: Unexpected value for inst_valid,\n {dut.d_inst_valid.value.integer} instead of {inst_valid}"
            assert dut.d_inst.value == prev_inst,
            f"Error: Unexpected value for instruction,\n {dut.d_inst.value} instead of {prev_inst}"
        
        # Update simulation values and set as initialized
        pc += 4
        inst_valid = (inst_valid + 1) % 2
        prev_inst = inst
        initialized = True

    dut._log.info("Initiate Stall")

    dut._log.info("Buffer Passthrough Test")