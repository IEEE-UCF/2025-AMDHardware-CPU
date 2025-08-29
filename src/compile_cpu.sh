#!/bin/bash

# Compilation script for cpu_top.sv
# This script compiles the CPU with all required dependencies

echo "Compiling CPU..."

# List of required source files in dependency order
SOURCES=(
    "../rtl_utils/mux_n.sv"
    "../rtl_utils/fifo.sv"
    "../rtl_utils/adder_n.sv" 
    "../rtl_utils/reset_sync.sv"
    "../rtl_utils/arbiter.sv"
    "../rtl_utils/clock_divider.sv"
    "register_bank.sv"
    "coprocessor.sv"
    "dispatcher.sv"
    "offload_logic.sv"
    "cpu_top.sv"
)

# Check if files exist
echo "Checking source files..."
for file in "${SOURCES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "Warning: $file not found"
    else
        echo "✓ $file"
    fi
done

echo ""
echo "Running iverilog..."

# Compile with iverilog
iverilog -g2012 -Wall \
    -I../rtl_utils \
    -I. \
    "${SOURCES[@]}" \
    -o cpu_top_sim

if [ $? -eq 0 ]; then
    echo "✓ Compilation successful!"
    echo "Executable: cpu_top_sim"
    echo "To run simulation: vvp cpu_top_sim"
else
    echo "✗ Compilation failed!"
    exit 1
fi
