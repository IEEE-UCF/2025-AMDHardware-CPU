# Holy CPU Documentation

## Overview

The Holy CPU is a high-performance RISC-V compatible processor with advanced coprocessor offload capabilities. The design features a pipelined architecture with integrated floating-point, system control, and memory management coprocessors.

## Architecture Components

### Core Pipeline
- **5-stage pipeline**: IF → ID → EX → MM → WB
- **Advanced hazard detection** and resolution
- **Branch prediction** and speculation
- **Pipeline stall management**

### Coprocessor System
- **CP0**: System Control and CSR operations
- **CP1**: Floating Point Unit (FPU) 
- **CP2**: Memory Management Unit (MMU)
- **CP3**: GPU/Custom operations (optional)

### Offload System
The CPU features a sophisticated instruction offload system for coprocessor integration:

- **Offload Stall Handler**: Manages pipeline stalls and hazard detection
- **Destination Table**: Tracks offloaded instructions and completion
- **Offload Manager**: Unified interface for offload coordination

See [Offload System Documentation](offload_system.md) for detailed information.

## Key Features

### Performance Features
- **Multi-cycle operation support**
- **Out-of-order completion** for coprocessors
- **Advanced stall minimization**
- **Timeout protection** for hung operations

### Memory System
- **Virtual memory support** with TLB
- **Cache control operations**
- **Memory-mapped I/O**
- **DMA integration**

### Debug and Monitoring
- **Comprehensive debug interface**
- **Performance counters**
- **Trace buffer**
- **Breakpoint/watchpoint support**

## File Structure

```
src/
├── cpu_top.sv              # Top-level CPU module
├── pipeline_stages.sv      # Pipeline stage implementations
├── control_unit.sv         # Main control unit
├── dispatcher.sv           # Basic coprocessor dispatcher
├── coprocessor_system.sv   # Coprocessor integration
├── offload_stall_handler.sv    # Offload stall management
├── offload_destination_table.sv # Instruction tracking
├── offload_manager.sv      # Unified offload interface
└── coprocessor_*.sv        # Individual coprocessor modules

rtl_utils/
├── fifo.sv                 # FIFO implementations
├── mux_n.sv               # Parameterized multiplexers
├── adder_n.sv             # N-bit adders
└── arbiter.sv             # Bus arbitration

tb/
├── cpu_top_tb.py          # Main CPU testbench
├── offload_stall_handler_tb.py # Offload system tests
└── coprocessor_*_tb.py    # Individual CP tests

docs/
├── README.md              # This file
├── offload_system.md      # Offload system documentation
├── cpu_architecture.md   # Architecture details
├── cpu_instruction_set.md # ISA documentation
└── memory_map.md          # Memory layout
```

## Getting Started

### Prerequisites
- Python 3.7+
- Cocotb testing framework
- Verilator or other Verilog simulator
- GTKWave (for waveform viewing)

### Building and Testing

```bash
# Install dependencies
cd tb
pip install -r requirements.txt

# Run all tests
make all

# Run specific tests
make test-offload-stall
make test-coprocessor-fpu

# Clean build files
make clean
```

### Synthesis

```bash
cd synth
# Xilinx Vivado
vivado -mode tcl -source board_config.tcl

# Intel Quartus (if supported)
quartus_sh --flow compile cpu_project
```

## Documentation

- [CPU Architecture](cpu_architecture.md) - Detailed architecture overview
- [Instruction Set](cpu_instruction_set.md) - ISA specification
- [Memory Map](memory_map.md) - Memory layout and mapping
- [Offload System](offload_system.md) - Coprocessor offload documentation

## Development

### Adding New Coprocessors

1. Create coprocessor module in `src/coprocessor_cp*.sv`
2. Add opcode mapping in `offload_destination_table.sv`
3. Update coprocessor system integration
4. Add testbench in `tb/`
5. Update documentation

### Testing Guidelines

- All new features must include comprehensive tests
- Use cocotb for Python-based testing
- Include both unit and integration tests
- Verify timing and performance requirements

## Performance Characteristics

### Typical Performance
- **Base clock**: 100MHz - 200MHz (depending on synthesis)
- **IPC**: 0.7 - 0.9 (instructions per cycle)
- **Coprocessor latency**: 1-10 cycles (operation dependent)
- **Memory latency**: 2-5 cycles (cache hit)

### Resource Usage (Synthesis dependent)
- **Logic Elements**: ~15K - 25K
- **Memory**: ~500KB BRAM
- **DSP blocks**: ~20 (for FPU)

## Known Issues and Limitations

### Current Limitations
1. Single-threaded execution only
2. Limited cache size options
3. Basic branch prediction
4. Simplified exception handling

### Future Enhancements
1. Multi-core support
2. Advanced branch prediction
3. Larger cache hierarchies
4. Hardware virtualization support
5. Vector processing unit

## Contributing

1. Fork the repository
2. Create feature branch
3. Implement changes with tests
4. Update documentation
5. Submit pull request

### Coding Standards
- Follow SystemVerilog best practices
- Include comprehensive comments
- Use consistent naming conventions
- Implement proper error handling

## License

[Specify license here]

## Contact

[Contact information]

---

*This documentation is part of the Holy CPU project. Last updated: [Date]*
