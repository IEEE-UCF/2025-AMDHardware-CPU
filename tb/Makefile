SIM ?= icarus

VERILOG_SOURCES += $(shell pwd)/../src/branch_calc.sv
VERILOG_SOURCES += $(shell pwd)/../src/bypass_mux.sv
VERILOG_SOURCES += $(shell pwd)/../src/coprocessor.sv
VERILOG_SOURCES += $(shell pwd)/../src/cpu_top.sv
VERILOG_SOURCES += $(shell pwd)/../src/dispatcher.sv
VERILOG_SOURCES += $(shell pwd)/../src/equ.sv
VERILOG_SOURCES += $(shell pwd)/../src/gpu_op_queue.sv
VERILOG_SOURCES += $(shell pwd)/../src/gpu_result_buffer.sv
VERILOG_SOURCES += $(shell pwd)/../src/gpu_result_wb.sv
VERILOG_SOURCES += $(shell pwd)/../src/imme.sv
VERILOG_SOURCES += $(shell pwd)/../src/instruction_buffer.sv
VERILOG_SOURCES += $(shell pwd)/../src/interconnect.sv
VERILOG_SOURCES += $(shell pwd)/../src/memory_burst_buffer.sv
VERILOG_SOURCES += $(shell pwd)/../src/memory_bus.sv
VERILOG_SOURCES += $(shell pwd)/../src/memory_data.sv
VERILOG_SOURCES += $(shell pwd)/../src/memory_instruction.sv
VERILOG_SOURCES += $(shell pwd)/../src/mmu.sv
VERILOG_SOURCES += $(shell pwd)/../src/offload_logic.sv
VERILOG_SOURCES += $(shell pwd)/../src/pipeline_stages.sv
VERILOG_SOURCES += $(shell pwd)/../src/register_stages.sv
VERILOG_SOURCES += $(shell pwd)/../src/register_bank.sv
VERILOG_SOURCES += $(shell pwd)/../rtl_utils/adder_n.sv
VERILOG_SOURCES += $(shell pwd)/../rtl_utils/arbiter.sv
VERILOG_SOURCES += $(shell pwd)/../rtl_utils/fifo.sv
VERILOG_SOURCES += $(shell pwd)/../rtl_utils/clock_divider.sv
VERILOG_SOURCES += $(shell pwd)/../rtl_utils/mux_n.sv
VERILOG_SOURCES += $(shell pwd)/../rtl_utils/reset_sync.sv

TOPLEVEL_LANG = verilog
TOPLEVEL ?= cpu_top
MODULE ?= cpu_top_tb

include $(shell cocotb-config --makefiles)/Makefile.sim

TESTBENCHES = cpu_top:cpu_top_tb control_unit:control_unit_tb dispatcher:dispatcher_tb coprocessor:coprocessor_tb pipeline_stages:pipeline_stages_tb branch_calc:branch_calc_tb bypass_mux:bypass_mux_tb instruction_buffer:instruction_buffer_tb interconnect:interconnect_tb memory_bus:memory_bus_tb register_bank:register_bank_tb offload_logic:offload_logic_tb mmu:mmu_tb equ:equ_tb imme:imme_tb memory_data:memory_data_tb memory_instruction:memory_instruction_tb

.PHONY: all_tests
all_tests:
	echo "Running all testbenches in parallel..."
	for tb in $(TESTBENCHES); do 		toplevel=$$(echo $$tb | cut -d: -f1); 		module=$$(echo $$tb | cut -d: -f2); 		echo "Starting $$module ($$toplevel)..."; 		$(MAKE) -j1 TOPLEVEL=$$toplevel MODULE=$$module SIM_BUILD=sim_build_$$module > $$module.log 2>&1 & 	done; 	wait; 	echo "All testbenches completed. Check individual .log files for results."

.PHONY: all_tests_sequential
all_tests_sequential:
	echo "Running all testbenches sequentially..."
	for tb in $(TESTBENCHES); do 		toplevel=$$(echo $$tb | cut -d: -f1); 		module=$$(echo $$tb | cut -d: -f2); 		echo "Running $$module ($$toplevel)..."; 		if $(MAKE) TOPLEVEL=$$toplevel MODULE=$$module SIM_BUILD=sim_build_$$module; then 			echo "✓ $$module PASSED"; 		else 			echo "✗ $$module FAILED"; 		fi; 	done

.PHONY: clean_logs
clean_logs:
	rm -f *_tb.log *.log
	rm -rf sim_build_*

.PHONY: help
help:
	echo "Available targets:"
	echo "  all_tests           - Run all testbenches in parallel"
	echo "  all_tests_sequential- Run all testbenches sequentially"
	echo "  clean_logs          - Clean test log files and build directories"
	echo "  <module_name>       - Run specific testbench"
	echo ""
	echo "CPU Testbenches:"
	echo "  cpu_top            - Test top-level CPU module"
	echo "  control_unit       - Test control unit"
	echo "  dispatcher         - Test coprocessor dispatcher" 
	echo "  coprocessor        - Test coprocessor system"
	echo "  pipeline_stages    - Test pipeline stages"
	echo "  branch_calc        - Test branch calculation"
	echo "  bypass_mux         - Test bypass multiplexer"
	echo "  instruction_buffer - Test instruction buffer"
	echo "  interconnect       - Test interconnect"
	echo "  memory_bus         - Test memory bus"
	echo "  register_bank      - Test register bank"
	echo "  offload_logic      - Test offload logic"
	echo "  mmu                - Test memory management unit"
	echo ""
	echo "  help               - Show this help message"

.PHONY: cpu_top
cpu_top:
	$(MAKE) TOPLEVEL=cpu_top MODULE=cpu_top_tb SIM_BUILD=sim_build_cpu_top

.PHONY: control_unit
control_unit:
	$(MAKE) TOPLEVEL=control_unit MODULE=control_unit_tb SIM_BUILD=sim_build_control_unit

.PHONY: dispatcher
dispatcher:
	$(MAKE) TOPLEVEL=dispatcher MODULE=dispatcher_tb SIM_BUILD=sim_build_dispatcher

.PHONY: coprocessor
coprocessor:
	$(MAKE) TOPLEVEL=coprocessor_system MODULE=coprocessor_simple_tb SIM_BUILD=sim_build_coprocessor

.PHONY: pipeline_stages
pipeline_stages:
	$(MAKE) TOPLEVEL=pipeline_stages MODULE=pipeline_stages_tb SIM_BUILD=sim_build_pipeline_stages

.PHONY: branch_calc
branch_calc:
	$(MAKE) TOPLEVEL=branch_calc MODULE=branch_calc_tb SIM_BUILD=sim_build_branch_calc

.PHONY: bypass_mux
bypass_mux:
	$(MAKE) TOPLEVEL=bypass_mux MODULE=bypass_mux_tb SIM_BUILD=sim_build_bypass_mux

.PHONY: instruction_buffer
instruction_buffer:
	$(MAKE) TOPLEVEL=instruction_buffer MODULE=instruction_buffer_tb SIM_BUILD=sim_build_instruction_buffer

.PHONY: interconnect
interconnect:
	$(MAKE) TOPLEVEL=interconnect MODULE=interconnect_tb SIM_BUILD=sim_build_interconnect

.PHONY: memory_bus
memory_bus:
	$(MAKE) TOPLEVEL=memory_bus MODULE=memory_bus_tb SIM_BUILD=sim_build_memory_bus

.PHONY: register_bank
register_bank:
	$(MAKE) TOPLEVEL=register_bank MODULE=register_bank_tb SIM_BUILD=sim_build_register_bank

.PHONY: offload_logic
offload_logic:
	$(MAKE) TOPLEVEL=offload_logic MODULE=offload_logic_tb SIM_BUILD=sim_build_offload_logic

.PHONY: mmu
mmu:
	$(MAKE) TOPLEVEL=mmu MODULE=mmu_tb SIM_BUILD=sim_build_mmu

.PHONY: equ
equ:
	$(MAKE) TOPLEVEL=equ MODULE=equ_tb SIM_BUILD=sim_build_equ

.PHONY: imme
imme:
	$(MAKE) TOPLEVEL=imme MODULE=imme_tb SIM_BUILD=sim_build_imme

.PHONY: memory_data
memory_data:
	$(MAKE) TOPLEVEL=memory_data MODULE=memory_data_tb SIM_BUILD=sim_build_memory_data

.PHONY: memory_instruction
memory_instruction:
	$(MAKE) TOPLEVEL=memory_instruction MODULE=memory_instruction_tb SIM_BUILD=sim_build_memory_instruction