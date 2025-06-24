# Makefile for CPU Top cocotb testbench

# Simulator selection
SIM ?= verilator

# Default language 
TOPLEVEL_LANG ?= verilog

# Source files
VERILOG_SOURCES += $(PWD)/../src/cpu_top.sv
VERILOG_SOURCES += $(PWD)/../src/control_unit.sv
VERILOG_SOURCES += $(PWD)/../src/stage_if.sv
VERILOG_SOURCES += $(PWD)/../src/stage_id.sv
VERILOG_SOURCES += $(PWD)/../src/stage_ex.sv
VERILOG_SOURCES += $(PWD)/../src/stage_mm.sv
VERILOG_SOURCES += $(PWD)/../src/stage_wb.sv
VERILOG_SOURCES += $(PWD)/../src/reg_if_to_id.sv
VERILOG_SOURCES += $(PWD)/../src/reg_id_to_ex.sv
VERILOG_SOURCES += $(PWD)/../src/reg_ex_to_mm.sv
VERILOG_SOURCES += $(PWD)/../src/reg_mm_to_wb.sv
VERILOG_SOURCES += $(PWD)/../src/reg_if.sv
VERILOG_SOURCES += $(PWD)/../src/register_bank_list.sv
VERILOG_SOURCES += $(PWD)/../src/register_bank_cpu.sv
VERILOG_SOURCES += $(PWD)/../src/register_bank_gpu.sv
VERILOG_SOURCES += $(PWD)/../src/register_bank_shadow.sv
VERILOG_SOURCES += $(PWD)/../src/instruction_buffer.sv
VERILOG_SOURCES += $(PWD)/../src/bypass_mux.sv
VERILOG_SOURCES += $(PWD)/../src/branch_calc.sv
VERILOG_SOURCES += $(PWD)/../src/imme.sv
VERILOG_SOURCES += $(PWD)/../src/equ.sv
VERILOG_SOURCES += $(PWD)/../src/update_pc.sv
VERILOG_SOURCES += $(PWD)/../src/stage_id_stall.sv
VERILOG_SOURCES += $(PWD)/../src/dispatcher.sv
VERILOG_SOURCES += $(PWD)/../src/coprocessor_system.sv
VERILOG_SOURCES += $(PWD)/../rtl_utils/mux_n.sv
VERILOG_SOURCES += $(PWD)/../rtl_utils/fifo.sv
VERILOG_SOURCES += $(PWD)/../rtl_utils/adder_n.sv
VERILOG_SOURCES += $(PWD)/../rtl_utils/reset_sync.sv

# Memory interface modules (create stub versions if needed)
VERILOG_SOURCES += $(PWD)/memory_stubs.sv

# Top level module
TOPLEVEL = cpu_top

# Test module
MODULE = cpu_top_tb

# Verilator specific flags
ifeq ($(SIM), verilator)
    EXTRA_ARGS += --timescale 1ns/1ps
    EXTRA_ARGS += --trace
    EXTRA_ARGS += --trace-structs
    EXTRA_ARGS += -Wno-WIDTHCONCAT
    EXTRA_ARGS += -Wno-WIDTHEXPAND  
    EXTRA_ARGS += -Wno-CASEINCOMPLETE
    EXTRA_ARGS += -Wno-CASEX
    EXTRA_ARGS += -Wno-TIMESCALEMOD
    EXTRA_ARGS += -Wno-UNOPTFLAT
    EXTRA_ARGS += -Wno-SYMRSVDWORD
endif

# Include cocotb make rules
include $(shell cocotb-config --makefiles)/Makefile.sim

# Additional clean target
clean-extra:
	rm -rf sim_build/
	rm -rf results.xml
	rm -rf __pycache__/
	rm -rf .pytest_cache/
	rm -f dump.vcd

# Run specific tests
test-reset:
	$(MAKE) MODULE=cpu_top_tb TESTCASE=test_cpu_reset

test-arithmetic:
	$(MAKE) MODULE=cpu_top_tb TESTCASE=test_basic_arithmetic

test-memory:
	$(MAKE) MODULE=cpu_top_tb TESTCASE=test_load_store

test-branch:
	$(MAKE) MODULE=cpu_top_tb TESTCASE=test_branch_instructions

test-jump:
	$(MAKE) MODULE=cpu_top_tb TESTCASE=test_jump_instructions

test-stall:
	$(MAKE) MODULE=cpu_top_tb TESTCASE=test_pipeline_stalls

test-interrupt:
	$(MAKE) MODULE=cpu_top_tb TESTCASE=test_interrupt_handling

test-control:
	$(MAKE) MODULE=cpu_top_tb TESTCASE=test_control_unit

# Install dependencies
install-deps:
	pip install cocotb pytest

# Help target
help:
	@echo "Available targets:"
	@echo "  all           - Run all tests"
	@echo "  test-reset    - Run reset test only"
	@echo "  test-arithmetic - Run arithmetic test only"
	@echo "  test-memory   - Run memory test only"
	@echo "  test-branch   - Run branch test only"
	@echo "  test-jump     - Run jump test only"
	@echo "  test-stall    - Run stall test only"
	@echo "  test-interrupt - Run interrupt test only"
	@echo "  test-control  - Run control unit test only"
	@echo "  clean-extra   - Clean build files"
	@echo "  install-deps  - Install Python dependencies"
	@echo ""
	@echo "Variables:"
	@echo "  SIM=<simulator>  - Select simulator (default: verilator)"
	@echo "  WAVES=1         - Enable waveform dumping"

.PHONY: clean-extra help install-deps test-reset test-arithmetic test-memory test-branch test-jump test-stall test-interrupt test-control
