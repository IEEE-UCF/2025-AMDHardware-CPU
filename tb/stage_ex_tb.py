import cocotb
import random
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock

async def reset_cpu(dut):
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1

@cocotb.test()
async def test_stage_ex(dut):
    """Testing data processing across all coprocessors"""
    
    # Clock start
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Reset procedure
    await reset_cpu(dut)
    dut._log.info("Reset Complete\n")
    
    # Constraints:
    # Number of input combo runs
    INPUT_RUNS = 10
    # Number of bits in each data value
    BIT_WIDTH = 64
    # Absolute maximum of data values
    MAX_DATA_VAL = 2 ** (BIT_WIDTH-1)
    # Mask to convert data values into overflow variants
    OVERFLOW_MASK = (1 << BIT_WIDTH) - 1
    # Mask for value after unsigned max
    UNSIGNED_MASK = 1 << BIT_WIDTH
    # Mask to use only first 5 bits for shifting
    SHAMT_MASK = (1 << 5) - 1
    # Number of possible operations
    OP_NUM = 19
    
    alu_out = 0
    
    dut.ecall.value = 0
    
    # For each set of inputs
    for i in range(INPUT_RUNS + 1):
        dut._log.info("Test %s", i+1)
        
        # Run 1: ea = 0 | eb = 0
        # Run 2: ea = 0 | eb = R
        # Run 3: ea = R | eb = 0
        # Run 4: ea = R | eb = R
        ea = 0 if (i < 2) else random.randint(-MAX_DATA_VAL,MAX_DATA_VAL-1)
        eb = random.randint(-MAX_DATA_VAL,MAX_DATA_VAL-1) if (i == 0 or i == 2) else 0
        dut.ea.value = ea
        dut.eb.value = eb
        
        # Show input values
        dut._log.info("Input A: %s", dut.ea.value.integer)
        dut._log.info("Input B: %s", dut.eb.value.integer)
        
        # For each ALU operation
        for op in range(OP_NUM):
            # Plug in ALU value
            dut.ealuc.value = op
            # Store expected out from ALU
            exp_out = 0
            
            match op:
                case 0: # ADD
                    exp_out = (ea + eb) & OVERFLOW_MASK 
                case 1: # SUB
                    exp_out = (ea - eb) & OVERFLOW_MASK
                case 2: # AND
                    exp_out = ea & eb
                case 3: # OR
                    exp_out = ea | eb
                case 4: # XOR
                    exp_out = ea ^ eb
                case 5: # NOR
                    exp_out = ~(ea | eb)
                case 6: # NAND
                    exp_out = ~(ea & eb)
                case 7: # Logical left shift
                    exp_out = ea << (eb & SHAMT_MASK)
                case 8: # Logical right shift
                    exp_out = (ea % UNSIGNED_MASK) >> (eb & SHAMT_MASK)
                case 9: # Arithmetic right shift
                    exp_out = ea >> (eb & SHAMT_MASK)
                case 10: # Set less than (signed)
                    exp_out = 1 if ea < eb else 0
                case 11: # Set less than (unsigned)
                    exp_out = 1 if (ea % UNSIGNED_MASK) < (eb % UNSIGNED_MASK) else 0
                case 12: # Pass-through A
                    exp_out = ea
                case 13: # Pass-through B
                    exp_out = eb
                case 14: # Bitwise NOT A
                    exp_out = ~ea
                case 15: # Equality test
                    exp_out = 1 if ea == eb else 0
                case 16: # Inequality test
                    exp_out = 1 if ea != eb else 0
                case 17: # Increment A
                    exp_out = ea + 1
                case 18: # Decrement A
                    exp_out = ea - 1
                case _: # If invalid, return 0
                    exp_out = 0
            
            await RisingEdge(dut.clk)
            
            # Past clock cycle 1
            if (i != 0):
                assert alu_out == dut.eal.value.integer, f"Output mismatch!\nExpected: {alu_out} \nActual: {dut.ela.value.integer}"
            
            alu_out = exp_out
    
    # Check eal when ecall is 1
    dut.ecall.value = 1
    dut.ea.value = 0
    dut.eb.value = 0
    dut.ealuc.value = 0
    dut.epc4.value = 1
    
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    
    assert dut.eal.value.integer == 1, f"ecall output failed!\nExpected: {1}\nActual: {dut.alu.value.integer}"
