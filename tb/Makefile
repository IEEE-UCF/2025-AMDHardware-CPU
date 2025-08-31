SIM ?= icarus

VERILOG_SOURCES += ../src/

TOPLEVEL_LANG = verilog

include $(shell cocotb-config --makefiles)/Makefile.sim

# Make 'all_tests_live' the default target when no target is specified
.DEFAULT_GOAL := all_tests

TESTBENCHES = topmodule:testbench_tb

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

.PHONY: cpu_top
cpu_top:
	$(MAKE) sim TOPLEVEL=cpu_top MODULE=cpu_top_tb SIM_BUILD=sim_build_cpu_top

