# CPU Top Testbench

This directory contains comprehensive cocotb testbenches for the CPU top module.

## Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Install Verilator (if not already installed):
```bash
# Ubuntu/Debian
sudo apt install verilator

# Or build from source for latest version
```

## Running Tests

Run all tests:
```bash
make
```

Run specific test categories:
```bash
make test-reset          # Test CPU reset functionality
make test-arithmetic     # Test basic arithmetic instructions
make test-memory         # Test load/store instructions  
make test-branch         # Test branch instructions
make test-jump           # Test jump instructions
make test-stall          # Test pipeline stall conditions
make test-interrupt      # Test interrupt handling
```

Enable waveform generation:
```bash
make WAVES=1
```

Use different simulator:
```bash
make SIM=icarus  # Use Icarus Verilog
make SIM=ghdl    # Use GHDL (for mixed language)
```

## Test Description

### test_cpu_reset
- Verifies CPU resets correctly
- Checks PC starts at 0
- Validates reset state

### test_basic_arithmetic  
- Tests R-type instructions (ADD, SUB, AND, OR)
- Tests I-type instructions (ADDI)
- Verifies ALU operations

### test_load_store
- Tests load instructions (LW)
- Tests store instructions (SW)
- Verifies memory interface

### test_branch_instructions
- Tests branch equal (BEQ)
- Tests branch not equal (BNE)
- Verifies branch target calculation

### test_jump_instructions
- Tests jump and link (JAL)
- Tests jump and link register (JALR)
- Verifies return address saving

### test_pipeline_stalls
- Tests load-use hazard detection
- Tests memory stall conditions
- Verifies stall propagation

### test_interrupt_handling
- Tests interrupt assertion/deassertion
- Verifies interrupt handling logic
- Tests register bank switching

## Files

- `cpu_top_tb.py` - Main testbench with all test cases
- `Makefile` - Build configuration for cocotb
- `memory_stubs.sv` - Stub modules for missing components
- `requirements.txt` - Python dependencies
- `README.md` - This file

## Test Infrastructure

The testbench includes several helper classes:

- `CPUTestbench` - Main testbench orchestration
- `InstructionMemoryModel` - Simple instruction memory model
- `DataMemoryModel` - Simple data memory model

These provide RISC-V instruction encoding, memory simulation, and test utilities.

## Extending Tests

To add new tests:

1. Add a new test function with `@cocotb.test()` decorator
2. Follow the existing pattern for setup and execution
3. Add a make target in the Makefile if desired

Example:
```python
@cocotb.test()
async def test_my_feature(dut):
    # Setup
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Test logic here
    
    # Assertions
    assert condition, "Test failed message"
```

## Debugging

View waveforms:
```bash  
make WAVES=1
gtkwave dump.vcd  # Or your preferred waveform viewer
```

Enable debug logging:
```bash
export COCOTB_LOG_LEVEL=DEBUG
make
```

Check simulator output in `sim_build/` directory for detailed logs.
