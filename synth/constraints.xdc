# Red Pitaya 125-14 Timing Constraints for RV32IMA CPU
# Target: Zynq-7020 on Red Pitaya board

# Primary clock constraint - Red Pitaya runs at 125MHz
create_clock -period 8.000 -name adc_clk [get_ports adc_clk_p]

# CPU clock domain - optimize for 125MHz operation
create_clock -period 8.000 -name cpu_clk [get_ports clk]

# BRAM timing optimization - since we're using dedicated BRAM slices
# Set maximum delay for BRAM access paths
set_max_delay -from [get_cells -hierarchical -filter {NAME =~ "*inst_mem*"}] -to [get_cells -hierarchical -filter {NAME =~ "*imem_read_data*"}] 6.000
set_max_delay -from [get_cells -hierarchical -filter {NAME =~ "*data_mem*"}] -to [get_cells -hierarchical -filter {NAME =~ "*dmem_read_data*"}] 6.000

# Clock uncertainty for synthesis
set_clock_uncertainty 0.200 [all_clocks]

# Input/Output delays for Red Pitaya interface
set_input_delay -clock cpu_clk -max 2.000 [all_inputs]
set_input_delay -clock cpu_clk -min 1.000 [all_inputs]
set_output_delay -clock cpu_clk -max 2.000 [all_outputs]
set_output_delay -clock cpu_clk -min 1.000 [all_outputs]

# BRAM placement optimization for Red Pitaya
# Force CPU instruction and data memories to use block RAM
set_property RAM_STYLE BLOCK [get_cells -hierarchical -filter {NAME =~ "*inst_mem*"}]
set_property RAM_STYLE BLOCK [get_cells -hierarchical -filter {NAME =~ "*data_mem*"}]

# Pipeline register optimization
set_property MAX_FANOUT 100 [get_nets -hierarchical -filter {NAME =~ "*pipeline_stall*"}]
set_property MAX_FANOUT 100 [get_nets -hierarchical -filter {NAME =~ "*id_valid*"}]
set_property MAX_FANOUT 100 [get_nets -hierarchical -filter {NAME =~ "*ex_valid*"}]

# Critical path optimization for simplified hazard detection
set_max_delay -from [get_cells -hierarchical -filter {NAME =~ "*load_use_hazard*"}] -to [get_cells -hierarchical -filter {NAME =~ "*pipeline_stall*"}] 4.000
set_max_delay -from [get_cells -hierarchical -filter {NAME =~ "*data_hazard*"}] -to [get_cells -hierarchical -filter {NAME =~ "*pipeline_stall*"}] 4.000

# Resource utilization targets for Zynq-7020
# LUTs: Target <40000 (out of 53200 available)
# BRAM: Target <100 blocks (out of 140 available) 
# DSP: Target <50 slices (out of 220 available)
