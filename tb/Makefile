SIM ?= verilator

# Basic utility modules that work with Icarus
VERILOG_SOURCES += ../rtl_utils/mux_n.sv
VERILOG_SOURCES += ../src/branch_calc.sv
VERILOG_SOURCES += ../src/bypass_mux.sv
VERILOG_SOURCES += ../src/control_unit.sv
VERILOG_SOURCES += ../src/equ.sv
VERILOG_SOURCES += ../src/imme.sv
VERILOG_SOURCES += ../src/instruction_buffer.sv

# Conditional inclusion of complex modules for specific tests
ifeq ($(TOPLEVEL),coprocessor_system)
VERILOG_SOURCES += ../src/coprocessor_system.sv
endif

ifeq ($(TOPLEVEL),cpu_top)
VERILOG_SOURCES += ../src/coprocessor_system.sv
VERILOG_SOURCES += ../src/cpu_top.sv
endif

ifeq ($(TOPLEVEL),dispatcher)
VERILOG_SOURCES += ../src/dispatcher.sv
endif

ifeq ($(TOPLEVEL),memory_system)
VERILOG_SOURCES += ../src/memory_system.sv
endif

ifeq ($(TOPLEVEL),mmu)
VERILOG_SOURCES += ../src/mmu.sv
endif

# Skip problematic modules that need advanced SystemVerilog features
# These would need Verilator or Synopsys VCS to simulate properly:
# - gpu_op_queue.sv (uses complex structs and break statements)
# - gpu_result_buffer.sv (uses packed structs)
# - gpu_result_wb.sv (duplicate module)
# - interconnect.sv (uses complex generate blocks)
# - offload_logic.sv (uses advanced SystemVerilog)
# - pipeline_stages.sv (uses complex interfaces)
# - mmu.sv (uses typedefs and complex structs)

TOPLEVEL_LANG = verilog

# Add warning suppression for Icarus Verilog
ifeq ($(SIM), icarus)
	COMPILE_ARGS += -g2012 -Wno-timescale
endif

include $(shell cocotb-config --makefiles)/Makefile.sim

# Make 'all_tests_live' the default target when no target is specified
.DEFAULT_GOAL := basic_tests

# Define working testbenches for Icarus Verilog
BASIC_TESTBENCHES = branch_calc:branch_calc_tb bypass_mux:bypass_mux_tb control_unit:control_unit_tb equ:equ_tb imme:imme_tb instruction_buffer:instruction_buffer_tb mmu:mmu_tb

# Advanced testbenches that require more SystemVerilog features
ADVANCED_TESTBENCHES = coprocessor_system:coprocessor_system_tb dispatcher:dispatcher_tb memory_system:memory_system_tb

.PHONY: basic_tests
basic_tests:
	@echo "Running basic testbenches compatible with Icarus Verilog..."
	@for tb in $(BASIC_TESTBENCHES); do \
		toplevel=$$(echo $$tb | cut -d: -f1); \
		module=$$(echo $$tb | cut -d: -f2); \
		echo "========================================"; \
		echo "Running $$module ($$toplevel)..."; \
		echo "========================================"; \
		if $(MAKE) sim TOPLEVEL=$$toplevel MODULE=$$module SIM_BUILD=sim_build_$$module; then \
			echo "✓ $$module PASSED"; \
		else \
			echo "✗ $$module FAILED"; \
		fi; \
		echo ""; \
	done

.PHONY: advanced_tests
advanced_tests:
	@echo "Running advanced testbenches (may have issues with Icarus)..."
	@for tb in $(ADVANCED_TESTBENCHES); do \
		toplevel=$$(echo $$tb | cut -d: -f1); \
		module=$$(echo $$tb | cut -d: -f2); \
		echo "========================================"; \
		echo "Running $$module ($$toplevel)..."; \
		echo "========================================"; \
		if $(MAKE) sim TOPLEVEL=$$toplevel MODULE=$$module SIM_BUILD=sim_build_$$module; then \
			echo "✓ $$module PASSED"; \
		else \
			echo "✗ $$module FAILED (may need Verilator)"; \
		fi; \
		echo ""; \
	done

.PHONY: all_tests_sequential
all_tests_sequential: basic_tests advanced_tests

.PHONY: clean_logs
clean_logs:
	rm -f *_tb.log *.log
	rm -rf sim_*
	rm -rf sim_build_*
	rm -rf __pycache__
	rm results.xml

.PHONY: help
help:
	@echo "Available targets:"
	@echo "  basic_tests                     - Run basic testbenches (Icarus compatible)"
	@echo "  advanced_tests                  - Run advanced testbenches (may need Verilator)"
	@echo "  all_tests_sequential            - Run all testbenches sequentially"
	@echo "  clean_logs                      - Clean test log files and build directories"
	@echo "  <module_name>                   - Run specific testbench"
	@echo ""
	@echo "Basic Testbenches (Icarus Verilog):"
	@echo "  branch_calc                     - Test branch address calculation"
	@echo "  bypass_mux                      - Test bypass multiplexer"
	@echo "  control_unit                    - Test instruction decoder"
	@echo "  equ                             - Test equality comparator"
	@echo "  imme                            - Test immediate generator"
	@echo "  instruction_buffer              - Test instruction buffer"
	@echo ""
	@echo "Advanced Testbenches (SystemVerilog features):"
	@echo "  coprocessor_system              - Test coprocessor system"
	@echo "  dispatcher                      - Test instruction dispatcher"
	@echo "  memory_system                   - Test memory subsystem"
	@echo ""
	@echo "  help                            - Show this help message"

# Individual test targets
.PHONY: branch_calc
branch_calc:
	$(MAKE) sim TOPLEVEL=branch_calc MODULE=branch_calc_tb SIM_BUILD=sim_branch_calc

.PHONY: bypass_mux
bypass_mux:
	$(MAKE) sim TOPLEVEL=bypass_mux MODULE=bypass_mux_tb SIM_BUILD=sim_bypass_mux

.PHONY: control_unit
control_unit:
	$(MAKE) sim TOPLEVEL=control_unit MODULE=control_unit_tb SIM_BUILD=sim_control_unit

.PHONY: coprocessor_system
coprocessor_system:
	$(MAKE) sim TOPLEVEL=coprocessor_system MODULE=coprocessor_system_tb SIM_BUILD=sim_coprocessor_system

.PHONY: dispatcher
dispatcher:
	$(MAKE) sim TOPLEVEL=dispatcher MODULE=dispatcher_tb SIM_BUILD=sim_dispatcher

.PHONY: equ
equ:
	$(MAKE) sim TOPLEVEL=equ MODULE=equ_tb SIM_BUILD=sim_equ

.PHONY: imme
imme:
	$(MAKE) sim TOPLEVEL=imme MODULE=imme_tb SIM_BUILD=sim_imme

.PHONY: instruction_buffer
instruction_buffer:
	$(MAKE) sim TOPLEVEL=instruction_buffer MODULE=instruction_buffer_tb SIM_BUILD=sim_instruction_buffer

.PHONY: memory_system
memory_system:
	$(MAKE) sim TOPLEVEL=memory_system MODULE=memory_system_tb SIM_BUILD=sim_memory_system

.PHONY: mmu
mmu:
	$(MAKE) sim TOPLEVEL=mmu MODULE=mmu_tb SIM_BUILD=sim_mmu
