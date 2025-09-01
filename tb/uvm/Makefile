# Makefile for UVM-style CPU testbench using cocotb
# Comprehensive testing for RV32IMA CPU

# Default simulation tool
SIM ?= verilator

# Default test
TEST ?= cpu_sanity_test

# Python test module  
MODULE ?= cpu_test_cases

# Top level module
TOPLEVEL = cpu_top

# Debug targets
debug: MODULE = cpu_debug_test
debug: TEST = cpu_detailed_debug_test
debug: sim

step_debug: MODULE = cpu_debug_test
step_debug: TEST = cpu_step_by_step_test
step_debug: sim

memory_debug: MODULE = cpu_debug_test  
memory_debug: TEST = cpu_memory_debug_test
memory_debug: sim

# Source directories
RTL_DIR = ../../rtl_utils
SRC_DIR = ../../src

# SystemVerilog source files
VERILOG_SOURCES = \
    $(RTL_DIR)/mux_n.sv \
    $(SRC_DIR)/branch_calc.sv \
    $(SRC_DIR)/bypass_mux.sv \
    $(SRC_DIR)/control_unit.sv \
    $(SRC_DIR)/equ.sv \
    $(SRC_DIR)/imme.sv \
    $(SRC_DIR)/instruction_buffer.sv \
    $(SRC_DIR)/_interconnect.sv \
    $(SRC_DIR)/memory_system.sv \
    $(SRC_DIR)/mmu.sv \
    $(SRC_DIR)/coprocessor_system.sv \
    $(SRC_DIR)/dispatcher.sv \
    $(SRC_DIR)/gpu_op_queue.sv \
    $(SRC_DIR)/gpu_result_buffer.sv \
    $(SRC_DIR)/gpu_result_wb.sv \
    $(SRC_DIR)/pipeline_stages.sv \
    $(SRC_DIR)/register_file_system.sv \
    $(SRC_DIR)/offload_logic.sv \
    $(SRC_DIR)/clock_divider.sv \
    $(SRC_DIR)/cpu_top.sv \
    $(SRC_DIR)/cpu_axi_wrapper.sv \
    $(SRC_DIR)/red_pitaya_cpu_wrapper.sv \
    $(RTL_DIR)/rv32a_atomic.sv \
    $(RTL_DIR)/rv32m_muldiv.sv

# Build directory
SIM_BUILD = sim_uvm_$(TEST)

# Verilator specific flags
ifeq ($(SIM),verilator)
    COMPILE_ARGS += --timescale 1ns/1ps
    COMPILE_ARGS += --trace
    COMPILE_ARGS += --trace-structs
    COMPILE_ARGS += --coverage
    COMPILE_ARGS += -Wno-UNOPTFLAT
    COMPILE_ARGS += -Wno-WIDTH
    COMPILE_ARGS += -Wno-CASEINCOMPLETE
endif

# Python path
export PYTHONPATH := $(PWD):$(PYTHONPATH)

# Include cocotb makefiles
include $(shell cocotb-config --makefiles)/Makefile.sim

# Test targets
.PHONY: sanity load_store branch jump multiply atomic hazard alignment stress reset performance corner regression all_tests clean_uvm uvm_help

# Individual test targets
sanity:
	$(MAKE) sim TEST=cpu_sanity_test

load_store:
	$(MAKE) sim TEST=cpu_load_store_test

branch:
	$(MAKE) sim TEST=cpu_branch_test

jump:
	$(MAKE) sim TEST=cpu_jump_test

multiply:
	$(MAKE) sim TEST=cpu_multiply_test

atomic:
	$(MAKE) sim TEST=cpu_atomic_test

hazard:
	$(MAKE) sim TEST=cpu_hazard_test

alignment:
	$(MAKE) sim TEST=cpu_memory_alignment_test

stress:
	$(MAKE) sim TEST=cpu_pipeline_stress_test

reset:
	$(MAKE) sim TEST=cpu_reset_test

performance:
	$(MAKE) sim TEST=cpu_performance_test

corner:
	$(MAKE) sim TEST=cpu_corner_case_test

regression:
	$(MAKE) sim TEST=cpu_full_regression_test

# Run all tests sequentially
all_tests: sanity load_store branch jump multiply atomic hazard alignment stress reset performance corner regression
	@echo "All UVM-style tests completed!"

# Coverage report (for Verilator)
coverage:
ifeq ($(SIM),verilator)
	@echo "Generating coverage report..."
	@verilator_coverage --annotate coverage_report sim_uvm_*/coverage.dat
	@echo "Coverage report generated in coverage_report/"
else
	@echo "Coverage only supported with Verilator"
endif

# Clean UVM build artifacts (renamed to avoid conflict with cocotb clean)
clean_uvm:
	rm -rf sim_uvm_*
	rm -rf coverage_report
	rm -rf __pycache__
	rm -f results.xml
	rm -f dump.vcd
	rm -f *.log

# UVM Help target (renamed to avoid conflict with cocotb help)
uvm_help:
	@echo "==============================================="
	@echo "UVM-style CPU Testbench Makefile"
	@echo "==============================================="
	@echo ""
	@echo "IMPORTANT: Run from nix shell environment!"
	@echo "  nix-shell && cd tb/uvm"
	@echo ""
	@echo "UVM Test Targets:"
	@echo "  sanity      - Basic ALU operations test"
	@echo "  load_store  - Load/store operations test"
	@echo "  branch      - Branch operations test"
	@echo "  jump        - Jump operations test"
	@echo "  multiply    - M extension test"
	@echo "  atomic      - A extension test"
	@echo "  hazard      - Hazard detection test"
	@echo "  alignment   - Memory alignment test"
	@echo "  stress      - Pipeline stress test"
	@echo "  reset       - Reset behavior test"
	@echo "  performance - Performance metrics test"
	@echo "  corner      - Corner cases test"
	@echo "  regression  - Full regression test"
	@echo "  all_tests   - Run all tests"
	@echo ""
	@echo "Utility Targets:"
	@echo "  coverage    - Generate coverage report (Verilator only)"
	@echo "  clean_uvm   - Clean UVM build artifacts"
	@echo "  clean       - Clean all build artifacts (cocotb)"
	@echo "  uvm_help    - This help message"
	@echo "  help        - Cocotb help message"
	@echo ""
	@echo "Variables:"
	@echo "  SIM=verilator|modelsim|questa|xsim  (default: verilator)"
	@echo "  TEST=<test_name>                    (default: cpu_sanity_test)"
	@echo ""
	@echo "Examples:"
	@echo "  make sanity"
	@echo "  make all_tests SIM=questa"
	@echo "  make regression COMPILE_ARGS='-Wno-fatal'"
	@echo "  make clean_uvm  # Clean UVM artifacts only"
