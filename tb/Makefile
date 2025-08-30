SIM ?= icarus

VERILOG_SOURCES += $(shell pwd)/../src/branch_calc.sv
VERILOG_SOURCES += $(shell pwd)/../src/bypass_mux.sv
VERILOG_SOURCES += $(shell pwd)/../src/control_unit.sv
VERILOG_SOURCES += $(shell pwd)/../src/coprocessor.sv
VERILOG_SOURCES += $(shell pwd)/../src/cpu_top.sv
VERILOG_SOURCES += $(shell pwd)/../src/dispatcher.sv
VERILOG_SOURCES += $(shell pwd)/../src/equ.sv
VERILOG_SOURCES += $(shell pwd)/../src/gpu_op_queue.sv
VERILOG_SOURCES += $(shell pwd)/../src/gpu_result_buffer.sv
VERILOG_SOURCES += $(shell pwd)/../src/gpu_result_wb.sv
VERILOG_SOURCES += $(shell pwd)/../src/imme.sv
VERILOG_SOURCES += $(shell pwd)/../src/instruction_buffer.sv
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

# Make 'all_tests_live' the default target when no target is specified
.DEFAULT_GOAL := all_tests_live

TESTBENCHES = cpu_top:cpu_top_tb control_unit:control_unit_tb interconnect:interconnect_tb memory_bus:memory_bus_tb mmu:mmu_tb dispatcher:coprocessor_dispatcher_tb coprocessor_cp0:coprocessor_cp0_tb coprocessor_cp1:coprocessor_cp1_tb coprocessor_cp2:coprocessor_cp2_tb coprocessor_cp3:coprocessor_cp3_tb coprocessor_fpu_fsm:coprocessor_fpu_fsm_tb coprocessor_fpu:coprocessor_fpu_tb coprocessor_fsm:coprocessor_fsm_tb coprocessor_int_alu:coprocessor_int_alu_tb coprocessor_interface:coprocessor_interface_tb coprocessor_mdu_fsm:coprocessor_mdu_fsm_tb coprocessor_mdu:coprocessor_mdu_tb coprocessor_system:coprocessor_system_tb gpu_result_wb:gpu_result_wb_tb offload_stall_handler:offload_stall_handler_tb register_bank_shadow:register_bank_shadow_tb stage_ex:stage_ex_tb stage_id:stage_id_tb stage_if:stage_if_tb stage_mm:stage_mm_tb stage_wb:stage_wb_tb

.PHONY: all_tests
all_tests:
	echo "Running all testbenches in parallel..."
	for tb in $(TESTBENCHES); do 		toplevel=$$(echo $$tb | cut -d: -f1); 		module=$$(echo $$tb | cut -d: -f2); 		echo "Starting $$module ($$toplevel)..."; 		$(MAKE) sim -j1 TOPLEVEL=$$toplevel MODULE=$$module SIM_BUILD=sim_build_$$module > $$module.log 2>&1 & 	done; 	wait; 	echo "All testbenches completed. Check individual .log files for results."

.PHONY: all_tests_sequential
all_tests_sequential:
	echo "Running all testbenches sequentially..."
	for tb in $(TESTBENCHES); do 		toplevel=$$(echo $$tb | cut -d: -f1); 		module=$$(echo $$tb | cut -d: -f2); 		echo "Running $$module ($$toplevel)..."; 		if $(MAKE) sim TOPLEVEL=$$toplevel MODULE=$$module SIM_BUILD=sim_build_$$module; then 			echo "✓ $$module PASSED"; 		else 			echo "✗ $$module FAILED"; 		fi; 	done

.PHONY: all_tests_live
all_tests_live:
	echo "Running all testbenches sequentially with live output..."w
	for tb in $(TESTBENCHES); do 		toplevel=$$(echo $$tb | cut -d: -f1); 		module=$$(echo $$tb | cut -d: -f2); 		echo "========================================"; 		echo "Running $$module ($$toplevel)..."; 		echo "========================================"; 		if $(MAKE) sim TOPLEVEL=$$toplevel MODULE=$$module SIM_BUILD=sim_build_$$module; then 			echo "✓ $$module PASSED"; 		else 			echo "✗ $$module FAILED"; 		fi; 		echo ""; 	done

.PHONY: clean_logs
clean_logs:
	rm -f *_tb.log *.log
	rm -rf sim_build_*

.PHONY: help
help:
	echo "Available targets:"
	echo "  all_tests                       - Run all testbenches in parallel (with logs)"
	echo "  all_tests_sequential            - Run all testbenches sequentially (with logs)"
	echo "  all_tests_live                  - Run all testbenches sequentially (live terminal output)"
	echo "  clean_logs                      - Clean test log files and build directories"
	echo "  <module_name>                   - Run specific testbench (live terminal output)"
	echo ""
	echo "Available Testbenches:"
	echo "  cpu_top                 - Test top-level CPU module"
	echo "  control_unit            - Test control unit"
	echo "  interconnect            - Test interconnect"
	echo "  memory_bus              - Test memory bus"
	echo "  mmu                     - Test memory management unit"
	echo "  coprocessor_dispatcher  - Test coprocessor dispatcher routing"
	echo "  coprocessor_cp0         - Test System Control Coprocessor (CSR, interrupts)"
	echo "  coprocessor_cp1         - Test Floating Point Unit (IEEE 754)"
	echo "  coprocessor_cp2         - Test Memory Management Unit (TLB, virtual memory)"
	echo "  coprocessor_cp3         - Test Debug/Performance Monitor"
	echo "  coprocessor_fpu_fsm     - Test FPU Finite State Machine"
	echo "  coprocessor_fpu         - Test complete Floating Point Unit"
	echo "  coprocessor_fsm         - Test main coprocessor FSM"
	echo "  coprocessor_int_alu     - Test integer ALU operations"
	echo "  coprocessor_interface   - Test coprocessor interface routing"
	echo "  coprocessor_mdu_fsm     - Test MDU Finite State Machine"
	echo "  coprocessor_mdu         - Test Multiply/Divide Unit"
	echo "  coprocessor_system      - Test integrated coprocessor system"
	echo "  arbiter                 - Test arbiter"
	echo "  fifo                    - Test FIFO"
	echo "  gpu_result_wb           - Test GPU result writeback"
	echo "  offload_stall_handler   - Test offload stall handler"
	echo "  register_bank_shadow    - Test shadow register bank"
	echo "  register_banks          - Test register banks"
	echo "  stage_ex                - Test execute stage"
	echo "  stage_id                - Test instruction decode stage"
	echo "  stage_if                - Test instruction fetch stage"
	echo "  stage_mm                - Test memory access stage"
	echo "  stage_wb                - Test writeback stage"
	echo ""
	echo "  help                    - Show this help message"

.PHONY: cpu_top
cpu_top:
	$(MAKE) sim TOPLEVEL=cpu_top MODULE=cpu_top_tb SIM_BUILD=sim_build_cpu_top

.PHONY: control_unit
control_unit:
	$(MAKE) sim TOPLEVEL=control_unit MODULE=control_unit_tb SIM_BUILD=sim_build_control_unit

.PHONY: dispatcher
dispatcher:
	$(MAKE) sim TOPLEVEL=dispatcher MODULE=dispatcher_tb SIM_BUILD=sim_build_dispatcher

.PHONY: pipeline_stages
pipeline_stages:
	$(MAKE) sim TOPLEVEL=pipeline_stages MODULE=pipeline_stages_tb SIM_BUILD=sim_build_pipeline_stages

.PHONY: branch_calc
branch_calc:
	$(MAKE) sim TOPLEVEL=branch_calc MODULE=branch_calc_tb SIM_BUILD=sim_build_branch_calc

.PHONY: bypass_mux
bypass_mux:
	$(MAKE) sim TOPLEVEL=bypass_mux MODULE=bypass_mux_tb SIM_BUILD=sim_build_bypass_mux

.PHONY: instruction_buffer
instruction_buffer:
	$(MAKE) sim TOPLEVEL=instruction_buffer MODULE=instruction_buffer_tb SIM_BUILD=sim_build_instruction_buffer

.PHONY: interconnect
interconnect:
	$(MAKE) sim TOPLEVEL=interconnect MODULE=interconnect_tb SIM_BUILD=sim_build_interconnect

.PHONY: memory_bus
memory_bus:
	$(MAKE) sim TOPLEVEL=memory_bus MODULE=memory_bus_tb SIM_BUILD=sim_build_memory_bus

.PHONY: register_bank
register_bank:
	$(MAKE) sim TOPLEVEL=register_bank MODULE=register_bank_tb SIM_BUILD=sim_build_register_bank

.PHONY: offload_logic
offload_logic:
	$(MAKE) sim TOPLEVEL=offload_logic MODULE=offload_logic_tb SIM_BUILD=sim_build_offload_logic

.PHONY: mmu
mmu:
	$(MAKE) sim TOPLEVEL=mmu MODULE=mmu_tb SIM_BUILD=sim_build_mmu

.PHONY: equ
equ:
	$(MAKE) sim TOPLEVEL=equ MODULE=equ_tb SIM_BUILD=sim_build_equ

.PHONY: imme
imme:
	$(MAKE) sim TOPLEVEL=imme MODULE=imme_tb SIM_BUILD=sim_build_imme

.PHONY: memory_data
memory_data:
	$(MAKE) sim TOPLEVEL=datamem MODULE=memory_data_tb SIM_BUILD=sim_build_memory_data

.PHONY: memory_instruction
memory_instruction:
	$(MAKE) sim TOPLEVEL=memory_instruction MODULE=memory_instruction_tb SIM_BUILD=sim_build_memory_instruction

# Coprocessor testbench targets
.PHONY: coprocessor_dispatcher
coprocessor_dispatcher:
	$(MAKE) sim TOPLEVEL=dispatcher MODULE=coprocessor_dispatcher_tb SIM_BUILD=sim_build_coprocessor_dispatcher

.PHONY: coprocessor_cp0
coprocessor_cp0:
	$(MAKE) sim TOPLEVEL=coprocessor_cp0 MODULE=coprocessor_cp0_tb SIM_BUILD=sim_build_coprocessor_cp0

.PHONY: coprocessor_cp1
coprocessor_cp1:
	$(MAKE) sim TOPLEVEL=coprocessor_cp1 MODULE=coprocessor_cp1_tb SIM_BUILD=sim_build_coprocessor_cp1

.PHONY: coprocessor_cp2
coprocessor_cp2:
	$(MAKE) sim TOPLEVEL=coprocessor_cp2 MODULE=coprocessor_cp2_tb SIM_BUILD=sim_build_coprocessor_cp2

.PHONY: coprocessor_cp3
coprocessor_cp3:
	$(MAKE) sim TOPLEVEL=coprocessor_cp3 MODULE=coprocessor_cp3_tb SIM_BUILD=sim_build_coprocessor_cp3

.PHONY: coprocessor_fpu_fsm
coprocessor_fpu_fsm:
	$(MAKE) sim TOPLEVEL=coprocessor_fpu_fsm MODULE=coprocessor_fpu_fsm_tb SIM_BUILD=sim_build_coprocessor_fpu_fsm

.PHONY: coprocessor_fpu
coprocessor_fpu:
	$(MAKE) sim TOPLEVEL=coprocessor_fpu MODULE=coprocessor_fpu_tb SIM_BUILD=sim_build_coprocessor_fpu

.PHONY: coprocessor_fsm
coprocessor_fsm:
	$(MAKE) sim TOPLEVEL=coprocessor_fsm MODULE=coprocessor_fsm_tb SIM_BUILD=sim_build_coprocessor_fsm

.PHONY: coprocessor_int_alu
coprocessor_int_alu:
	$(MAKE) sim TOPLEVEL=coprocessor_int_alu MODULE=coprocessor_int_alu_tb SIM_BUILD=sim_build_coprocessor_int_alu

.PHONY: coprocessor_interface
coprocessor_interface:
	$(MAKE) sim TOPLEVEL=coprocessor_interface MODULE=coprocessor_interface_tb SIM_BUILD=sim_build_coprocessor_interface

.PHONY: coprocessor_mdu_fsm
coprocessor_mdu_fsm:
	$(MAKE) sim TOPLEVEL=coprocessor_mdu_fsm MODULE=coprocessor_mdu_fsm_tb SIM_BUILD=sim_build_coprocessor_mdu_fsm

.PHONY: coprocessor_mdu
coprocessor_mdu:
	$(MAKE) sim TOPLEVEL=coprocessor_mdu MODULE=coprocessor_mdu_tb SIM_BUILD=sim_build_coprocessor_mdu

.PHONY: coprocessor_system
coprocessor_system:
	$(MAKE) sim TOPLEVEL=coprocessor_system MODULE=coprocessor_system_tb SIM_BUILD=sim_build_coprocessor_system

# Additional testbench targets
.PHONY: arbiter
arbiter:
	$(MAKE) sim TOPLEVEL=arbiter MODULE=arbiter_tb SIM_BUILD=sim_build_arbiter

.PHONY: fifo
fifo:
	$(MAKE) sim TOPLEVEL=fifo MODULE=fifo_tb SIM_BUILD=sim_build_fifo

.PHONY: gpu_result_wb
gpu_result_wb:
	$(MAKE) sim TOPLEVEL=gpu_result_wb MODULE=gpu_result_wb_tb SIM_BUILD=sim_build_gpu_result_wb

.PHONY: offload_stall_handler
offload_stall_handler:
	$(MAKE) sim TOPLEVEL=offload_stall_handler MODULE=offload_stall_handler_tb SIM_BUILD=sim_build_offload_stall_handler

.PHONY: register_bank_shadow
register_bank_shadow:
	$(MAKE) sim TOPLEVEL=register_bank_shadow MODULE=register_bank_shadow_tb SIM_BUILD=sim_build_register_bank_shadow

.PHONY: register_banks
register_banks:
	$(MAKE) sim TOPLEVEL=register_banks MODULE=register_banks_tb SIM_BUILD=sim_build_register_banks

.PHONY: stage_ex
stage_ex:
	$(MAKE) sim TOPLEVEL=stage_ex MODULE=stage_ex_tb SIM_BUILD=sim_build_stage_ex

.PHONY: stage_id
stage_id:
	$(MAKE) sim TOPLEVEL=stage_id MODULE=stage_id_tb SIM_BUILD=sim_build_stage_id

.PHONY: stage_if
stage_if:
	$(MAKE) sim TOPLEVEL=stage_if MODULE=stage_if_tb SIM_BUILD=sim_build_stage_if

.PHONY: stage_mm
stage_mm:
	$(MAKE) sim TOPLEVEL=mm_stage MODULE=stage_mm_tb SIM_BUILD=sim_build_stage_mm

.PHONY: stage_wb
stage_wb:
	$(MAKE) sim TOPLEVEL=stage_wb MODULE=stage_wb_tb SIM_BUILD=sim_build_stage_wb