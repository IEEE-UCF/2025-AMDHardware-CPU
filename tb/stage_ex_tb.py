import cocotb
from cocotb.triggers import Timer
import random

@cocotb.test()
async def test_stage_ex(dut):
    """Testing data processing across all coprocessors"""
    
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
    
    # Initialize signals to avoid 'z' state
    dut.ecall.value = 0
    dut.ea.value = 0
    dut.eb.value = 0
    dut.epc4.value = 0
    dut.ealuc.value = 0
    
    # Wait for signals to settle
    await Timer(1, units="ns")
    
    dut._log.info("ALU Operations\n")
    
    # For each set of inputs
    for i in range(INPUT_RUNS + 1):
        dut._log.info("Test %s", i+1)
        
        # Run 1: ea = 0 | eb = 0
        # Run 2: ea = 0 | eb = R
        # Run 3: ea = R | eb = 0
        # Run X: ea = R | eb = R (X > 3)
        if i < 2:
            ea = 0
        else:
            ea = random.randint(0, OVERFLOW_MASK)
        
        if i == 0 or i == 2:
            eb = 0
        else:
            eb = random.randint(0, OVERFLOW_MASK)
            
        dut.ea.value = ea
        dut.eb.value = eb
        
        # Wait for combinational logic to settle
        await Timer(1, units="ns")
        
        # Show input values (now that they're settled)
        dut._log.info("Input A: %s", ea)
        dut._log.info("Input B: %s", eb)
        
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
                    exp_out = (~(ea | eb)) & OVERFLOW_MASK
                case 6: # NAND
                    exp_out = (~(ea & eb)) & OVERFLOW_MASK
                case 7: # Logical left shift
                    exp_out = (ea << (eb & SHAMT_MASK)) & OVERFLOW_MASK
                case 8: # Logical right shift
                    exp_out = (ea >> (eb & SHAMT_MASK)) & OVERFLOW_MASK
                case 9: # Arithmetic right shift
                    # Convert to signed, do arithmetic shift, then back to unsigned
                    if ea & (1 << (BIT_WIDTH-1)):  # if negative
                        signed_ea = ea - (1 << BIT_WIDTH)
                    else:
                        signed_ea = ea
                    exp_out = (signed_ea >> (eb & SHAMT_MASK)) & OVERFLOW_MASK
                case 10: # Set less than (signed)
                    # Convert to signed for comparison
                    signed_ea = ea if ea < (1 << (BIT_WIDTH-1)) else ea - (1 << BIT_WIDTH)
                    signed_eb = eb if eb < (1 << (BIT_WIDTH-1)) else eb - (1 << BIT_WIDTH)
                    exp_out = 1 if signed_ea < signed_eb else 0
                case 11: # Set less than (unsigned)
                    exp_out = 1 if ea < eb else 0
                case 12: # Pass-through A
                    exp_out = ea
                case 13: # Pass-through B
                    exp_out = eb
                case 14: # Bitwise NOT A
                    exp_out = (~ea) & OVERFLOW_MASK
                case 15: # Equality test
                    exp_out = 1 if ea == eb else 0
                case 16: # Inequality test
                    exp_out = 1 if ea != eb else 0
                case 17: # Increment A
                    exp_out = (ea + 1) & OVERFLOW_MASK
                case 18: # Decrement A
                    exp_out = (ea - 1) & OVERFLOW_MASK
                case _: # If invalid, return 0
                    exp_out = 0
            
            await Timer(1, units="ns")
            
            # Check if output matches expectation
            actual_out = dut.eal.value.integer
            assert exp_out == actual_out, f"Output mismatch!\nOP: {op}\nExpected: {exp_out}\nActual: {actual_out}"
    
    # Check eal when ecall is 1
    dut.ecall.value = 1
    dut.ea.value = 0
    dut.eb.value = 0
    dut.ealuc.value = 0
    dut.epc4.value = 1
    
    await Timer(1, units="ns")
    
    # Check if eal switched to epc4 value
    actual_eal = dut.eal.value.integer
    assert actual_eal == 1, f"ecall output failed!\nExpected: 1\nActual: {actual_eal}"