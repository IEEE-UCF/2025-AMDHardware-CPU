SIM ?= verilator # Verilator for complex use

VERILOG_SOURCES += ../rtl_utils/mux_n.sv
VERILOG_SOURCES += ../src/branch_calc.sv
VERILOG_SOURCES += ../src/bypass_mux.sv
VERILOG_SOURCES += ../src/control_unit.sv
VERILOG_SOURCES += ../src/equ.sv
VERILOG_SOURCES += ../src/imme.sv
VERILOG_SOURCES += ../src/instruction_buffer.sv
VERILOG_SOURCES += ../src/_interconnect.sv
VERILOG_SOURCES += ../src/coprocessor_system.sv
VERILOG_SOURCES += ../src/coprocessor_system.sv
VERILOG_SOURCES += ../src/cpu_top.sv
VERILOG_SOURCES += ../src/dispatcher.sv
VERILOG_SOURCES += ../src/memory_system.sv
VERILOG_SOURCES += ../src/mmu.sv

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

include $(shell cocotb-config --makefiles)/Makefile.sim

# Make 'all_tests_live' the default target when no target is specified
.DEFAULT_GOAL := all_tests

# Define working testbenches
TESTBENCHES =  mux_n:mux_n_tb branch_calc:branch_calc_tb bypass_mux:bypass_mux_tb control_unit:control_unit_tb equ:equ_tb imme:imme_tb instruction_buffer:instruction_buffer_tb _interconnect:interconnect_tb coprocessor_system:coprocessor_system_tb coprocessor_system:coprocessor_system_tb cpu_top:cpu_top_tb dispatcher:dispatcher_tb memory_system:memory_system_tb mmu:mmu_tb

.PHONY: all_tests
basic_tests:
	@echo "Running basic testbenches compatible with Icarus Verilog..."
	@for tb in $(TESTBENCHES); do \
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
	@echo "  all__tests                     - Run basic testbenches (Verilator required for some)"
	@echo "  clean_logs                      - Clean test log files and build directories"
	@echo "  <module_name>                   - Run specific testbench"
	@echo ""
	@echo "  help                            - Show this help message"

.PHONY: mux_n 
mux_n:
	$(MAKE) sim TOPLEVEL=mux_n MODULE=mux_n_tb SIM_BUILD=sim_mux_n

.PHONY: branch_calc 
branch_calc:
	$(MAKE) sim TOPLEVEL=branch_calc MODULE=branch_calc_tb SIM_BUILD=sim_branch_calc

.PHONY: bypass_mux 
bypass_mux:
	$(MAKE) sim TOPLEVEL=bypass_mux MODULE=bypass_mux_tb SIM_BUILD=sim_bypass_mux

.PHONY: control_unit 
control_unit:
	$(MAKE) sim TOPLEVEL=control_unit MODULE=control_unit_tb SIM_BUILD=sim_control_unit

.PHONY: equ 
equ:
	$(MAKE) sim TOPLEVEL=equ MODULE=equ_tb SIM_BUILD=sim_equ

.PHONY: imme 
imme:
	$(MAKE) sim TOPLEVEL=imme MODULE=imme_tb SIM_BUILD=sim_imme

.PHONY: instruction_buffer 
instruction_buffer:
	$(MAKE) sim TOPLEVEL=instruction_buffer MODULE=instruction_buffer_tb SIM_BUILD=sim_instruction_buffer

.PHONY: _interconnect 
_interconnect:
	$(MAKE) sim TOPLEVEL=_interconnect MODULE=_interconnect_tb SIM_BUILD=sim__interconnect

.PHONY: coprocessor_system 
coprocessor_system:
	$(MAKE) sim TOPLEVEL=coprocessor_system MODULE=coprocessor_system_tb SIM_BUILD=sim_coprocessor_system

.PHONY: coprocessor_system 
coprocessor_system:
	$(MAKE) sim TOPLEVEL=coprocessor_system MODULE=coprocessor_system_tb SIM_BUILD=sim_coprocessor_system

.PHONY: cpu_top 
cpu_top:
	$(MAKE) sim TOPLEVEL=cpu_top MODULE=cpu_top_tb SIM_BUILD=sim_cpu_top

.PHONY: dispatcher 
dispatcher:
	$(MAKE) sim TOPLEVEL=dispatcher MODULE=dispatcher_tb SIM_BUILD=sim_dispatcher

.PHONY: memory_system 
memory_system:
	$(MAKE) sim TOPLEVEL=memory_system MODULE=memory_system_tb SIM_BUILD=sim_memory_system

.PHONY: mmub
mmu:
	$(MAKE) sim TOPLEVEL=mmu MODULE=mmu_tb SIM_BUILD=sim_mmu
