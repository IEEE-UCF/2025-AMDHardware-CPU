SIM ?= icarus

VERILOG_SOURCES += ../src/branch_calc.sv
VERILOG_SOURCES += ../src/bypass_mux.sv
VERILOG_SOURCES += ../src/control_unit.sv
VERILOG_SOURCES += ../src/coprocessor_system.sv
VERILOG_SOURCES += ../src/cpu_top.sv
VERILOG_SOURCES += ../src/dispatcher.sv
VERILOG_SOURCES += ../src/equ.sv
VERILOG_SOURCES += ../src/gpu_op_queue.sv
VERILOG_SOURCES += ../src/gpu_result_buffer.sv
VERILOG_SOURCES += ../src/gpu_result_wb.sv
VERILOG_SOURCES += ../src/imme.sv
VERILOG_SOURCES += ../src/instruction_buffer.sv
VERILOG_SOURCES += ../src/interconnect.sv
VERILOG_SOURCES += ../src/memory_system.sv
VERILOG_SOURCES += ../src/mmu.sv
VERILOG_SOURCES += ../src/offload_logic.sv
VERILOG_SOURCES += ../src/pipeline_stages.sv
VERILOG_SOURCES += ../src/register_stages.sv

TOPLEVEL_LANG = verilog

include $(shell cocotb-config --makefiles)/Makefile.sim

# Make 'all_tests_live' the default target when no target is specified
.DEFAULT_GOAL := all_tests

TESTBENCHES = branch_calc:branch_calc_tb bypass_mux:bypass_mux_tb control_unit:control_unit_tb coprocessor_system:coprocessor_system_tb cpu_top:cpu_top_tb dispatcher:dispatcher_tb equ:equ_tb gpu_op_queue:gpu_op_queue_tb gpu_result_buffer:gpu_result_buffer_tb gpu_result_wb:gpu_result_wb_tb imme:imme_tb instruction_buffer:instruction_buffer_tb interconnect:interconnect_tb memory_system:memory_system_tb mmu:mmu_tb offload_logic:offload_logic_tb pipeline_stages:pipeline_stages_tb register_stages:register_stages_tb 

.PHONY: all_tests
all_tests:
	echo "Running all testbenches sequentially with live output..."w
	for tb in $(TESTBENCHES); do 		toplevel=$$(echo $$tb | cut -d: -f1); 		module=$$(echo $$tb | cut -d: -f2); 		echo "========================================"; 		echo "Running $$module ($$toplevel)..."; 		echo "========================================"; 		if $(MAKE) sim TOPLEVEL=$$toplevel MODULE=$$module SIM_BUILD=sim_build_$$module; then 			echo "✓ $$module PASSED"; 		else 			echo "✗ $$module FAILED"; 		fi; 		echo ""; 	done

.PHONY: all_tests_sequential
all_tests_sequential:
	echo "Running all testbenches sequentially..."
	for tb in $(TESTBENCHES); do 		toplevel=$$(echo $$tb | cut -d: -f1); 		module=$$(echo $$tb | cut -d: -f2); 		echo "Running $$module ($$toplevel)..."; 		if $(MAKE) sim TOPLEVEL=$$toplevel MODULE=$$module SIM_BUILD=sim_build_$$module; then 			echo "✓ $$module PASSED"; 		else 			echo "✗ $$module FAILED"; 		fi; 	done

.PHONY: clean_logs
clean_logs:
	rm -f *_tb.log *.log
	rm -rf sim_build_*
	rm -rf __pycache__

.PHONY: help
help:
	echo "Available targets:"
	echo "  all_tests                       - Run all testbenches in parallel (with logs)"
	echo "  all_tests_sequential            - Run all testbenches sequentially (with logs)"
	echo "  clean_logs                      - Clean test log files and build directories"
	echo "  <module_name>                   - Run specific testbench (live terminal output)"
	echo ""
	echo "Available Testbenches:"
	echo "  cpu_top                 - Test top-level CPU module"
	echo ""
	echo "  help                    - Show this help message"

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

.PHONY: cpu_top
cpu_top:
	$(MAKE) sim TOPLEVEL=cpu_top MODULE=cpu_top_tb SIM_BUILD=sim_cpu_top

.PHONY: dispatcher
dispatcher:
	$(MAKE) sim TOPLEVEL=dispatcher MODULE=dispatcher_tb SIM_BUILD=sim_dispatcher

.PHONY: equ
equ:
	$(MAKE) sim TOPLEVEL=equ MODULE=equ_tb SIM_BUILD=sim_equ

.PHONY: gpu_op_queue
gpu_op_queue:
	$(MAKE) sim TOPLEVEL=gpu_op_queue MODULE=gpu_op_queue_tb SIM_BUILD=sim_gpu_op_queue

.PHONY: gpu_result_buffer
gpu_result_buffer:
	$(MAKE) sim TOPLEVEL=gpu_result_buffer MODULE=gpu_result_buffer_tb SIM_BUILD=sim_gpu_result_buffer

.PHONY: gpu_result_wb
gpu_result_wb:
	$(MAKE) sim TOPLEVEL=gpu_result_wb MODULE=gpu_result_wb_tb SIM_BUILD=sim_gpu_result_wb

.PHONY: imme
imme:
	$(MAKE) sim TOPLEVEL=imme MODULE=imme_tb SIM_BUILD=sim_imme

.PHONY: instruction_buffer
instruction_buffer:
	$(MAKE) sim TOPLEVEL=instruction_buffer MODULE=instruction_buffer_tb SIM_BUILD=sim_instruction_buffer

.PHONY: interconnect
interconnect:
	$(MAKE) sim TOPLEVEL=interconnect MODULE=interconnect_tb SIM_BUILD=sim_interconnect

.PHONY: memory_system
memory_system:
	$(MAKE) sim TOPLEVEL=memory_system MODULE=memory_system_tb SIM_BUILD=sim_memory_system

.PHONY: mmu
mmu:
	$(MAKE) sim TOPLEVEL=mmu MODULE=mmu_tb SIM_BUILD=sim_mmu

.PHONY: offload_logic
offload_logic:
	$(MAKE) sim TOPLEVEL=offload_logic MODULE=offload_logic_tb SIM_BUILD=sim_offload_logic

.PHONY: pipeline_stages
pipeline_stages:
	$(MAKE) sim TOPLEVEL=pipeline_stages MODULE=pipeline_stages_tb SIM_BUILD=sim_pipeline_stages

.PHONY: register_stages
register_stages:
	$(MAKE) sim TOPLEVEL=register_stages MODULE=register_stages_tb SIM_BUILD=sim_register_stages
