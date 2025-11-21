#==============================================================================
# SDC (Synopsys Design Constraints) File for 32-bit Adder
# Purpose: Define timing constraints for synthesis and STA
# Technology: 28nm CMOS, 100 MHz target frequency
# Author: Synthesis Team
# Date: 2024-01-15
#==============================================================================

puts "Loading SDC constraints for adder32..."

#==============================================================================
# 1. CLOCK DEFINITION
#==============================================================================

# Create clock constraint
# Period: 10ns (100 MHz)
# Name: clk
# Waveform: 50% duty cycle (rising edge at 0ns, falling at 5ns)
create_clock -name clk -period 10.0 -waveform {0 5} [get_ports clk]

# Clock uncertainty (jitter + skew budget)
# Accounts for:
#   - Clock jitter: 100ps
#   - Clock skew (CTS will be done later): 200ps  
#   - Margin: 200ps
# Total: 500ps = 0.5ns
set_clock_uncertainty -setup 0.5 [get_clocks clk]
set_clock_uncertainty -hold 0.2 [get_clocks clk]

# Clock transition time (rise/fall time at clock source)
set_clock_transition 0.1 [get_clocks clk]

# Clock latency (source to sink delay - updated after CTS)
# Source latency: clock generation delay
set_clock_latency -source 0.5 [get_clocks clk]
# Network latency: clock tree delay (placeholder, refined in CTS)
set_clock_latency 0.8 [get_clocks clk]

puts "Clock constraints applied: 10ns period (100MHz)"

#==============================================================================
# 2. INPUT CONSTRAINTS
#==============================================================================

# Input delay constraints
# Assume external logic provides data with 2ns setup time before clock edge
set input_delay_value 2.0

set_input_delay -clock clk -max $input_delay_value [get_ports a*]
set_input_delay -clock clk -max $input_delay_value [get_ports b*]
set_input_delay -clock clk -max $input_delay_value [get_ports carry_in]

# Input delay for hold (min delay)
# Assume external logic has minimum delay of 0.5ns
set_input_delay -clock clk -min 0.5 [get_ports a*]
set_input_delay -clock clk -min 0.5 [get_ports b*]
set_input_delay -clock clk -min 0.5 [get_ports carry_in]

# Input transition (slew rate from pads)
set_input_transition 0.2 [all_inputs]

# Driving cell (model input driver strength)
# Assume inputs are driven by medium-strength buffer
set_driving_cell -lib_cell BUFX2 -library typical_std_cell_28nm [all_inputs]

puts "Input constraints applied"

#==============================================================================
# 3. OUTPUT CONSTRAINTS
#==============================================================================

# Output delay constraints
# Downstream logic requires data 2ns before its clock edge
set output_delay_value 2.0

set_output_delay -clock clk -max $output_delay_value [get_ports sum*]
set_output_delay -clock clk -max $output_delay_value [get_ports carry_out]
set_output_delay -clock clk -max $output_delay_value [get_ports overflow]

# Output delay for hold (min delay)
set_output_delay -clock clk -min 0.5 [get_ports sum*]
set_output_delay -clock clk -min 0.5 [get_ports carry_out]
set_output_delay -clock clk -min 0.5 [get_ports overflow]

# Output load (capacitance of external loads)
# Assume each output drives 50fF (2-3 external inputs)
set_load 50 [all_outputs]

puts "Output constraints applied"

#==============================================================================
# 4. RESET CONSTRAINTS
#==============================================================================

# Reset is asynchronous - set as false path
# This prevents timing analysis on reset paths
set_false_path -from [get_ports rst_n]

# Reset input transition
set_input_transition 0.5 [get_ports rst_n]

puts "Reset constraints applied (asynchronous, false path)"

#==============================================================================
# 5. ENVIRONMENTAL CONSTRAINTS
#==============================================================================

# Operating conditions
# Already set in main script, but can be specified here too
# set_operating_conditions -analysis_type on_chip_variation typical

# Process, Voltage, Temperature (PVT) corners
# TT: Typical-Typical (1.0V, 25C) - default
# FF: Fast-Fast (1.1V, -40C) - best case
# SS: Slow-Slow (0.9V, 125C) - worst case

# For synthesis, we use TT corner
# Multi-corner analysis done in STA phase

puts "Environmental constraints applied"

#==============================================================================
# 6. DESIGN RULE CONSTRAINTS
#==============================================================================

# Maximum transition time (slew rate) on nets
set_max_transition 0.5 [current_design]

# Maximum fanout (number of loads a net can drive)
set_max_fanout 16 [current_design]

# Maximum capacitance on nets
set_max_capacitance 100 [all_outputs]

puts "Design rule constraints applied"

#==============================================================================
# 7. AREA CONSTRAINTS (OPTIONAL)
#==============================================================================

# Set maximum area (soft goal)
# Synthesis will try to minimize area after meeting timing
set_max_area 1000

puts "Area constraint: < 1000 um^2"

#==============================================================================
# 8. POWER CONSTRAINTS (OPTIONAL)
#==============================================================================

# Set power optimization mode
# Options: low, medium, high
set_power_optimization_mode -power_effort high

# Dynamic power optimization
set_dynamic_optimization true

puts "Power optimization enabled"

#==============================================================================
# 9. MULTI-CYCLE PATHS (if any)
#==============================================================================

# Example: If adder result is used 2 cycles later
# set_multicycle_path -setup 2 -from [all_registers] -to [all_registers]
# set_multicycle_path -hold 1 -from [all_registers] -to [all_registers]

# Not applicable for this simple design

#==============================================================================
# 10. FALSE PATHS (if any)
#==============================================================================

# Already defined: reset path is false path
# Add more if there are paths that don't need timing analysis

# Example: Test mode paths
# if {[sizeof_collection [get_ports test_mode]] > 0} {
#     set_false_path -from [get_ports test_mode]
# }

#==============================================================================
# 11. CASE ANALYSIS (constant values)
#==============================================================================

# If certain signals are tied to constant values during synthesis
# Example: set_case_analysis 0 [get_ports test_mode]

# Not applicable for this design

#==============================================================================
# 12. TIMING PATH GROUPS (for better reporting)
#==============================================================================

# Group paths for reporting
group_path -name INPUTS -from [all_inputs]
group_path -name OUTPUTS -to [all_outputs]
group_path -name REGS -from [all_registers] -to [all_registers]

puts "Path groups created for reporting"

#==============================================================================
# 13. OPTIMIZATION DIRECTIVES
#==============================================================================

# Don't touch certain cells (if needed)
# Example: set_dont_touch [get_cells critical_cell]

# Size only (don't replace cell type)
# Example: set_size_only [get_cells some_cell]

# Don't use certain library cells
# Example: set_dont_use [get_lib_cells */LATCH*]

# For this design, let synthesis optimize freely
set_dont_use [get_lib_cells */LATCH*] ;# Avoid latches

puts "Optimization directives applied"

#==============================================================================
# CONSTRAINT SUMMARY
#==============================================================================

puts ""
puts "======================================================================"
puts " SDC Constraints Summary"
puts "======================================================================"
puts " Clock:"
puts "   Name:        clk"
puts "   Period:      10.0 ns (100 MHz)"
puts "   Uncertainty: 0.5 ns (setup), 0.2 ns (hold)"
puts ""
puts " Input Delays:"
puts "   Max: 2.0 ns"
puts "   Min: 0.5 ns"
puts ""
puts " Output Delays:"
puts "   Max: 2.0 ns"
puts "   Min: 0.5 ns"
puts ""
puts " Design Rules:"
puts "   Max Transition: 0.5 ns"
puts "   Max Fanout:     16"
puts "   Max Capacitance: 100 fF"
puts ""
puts " Area Goal: < 1000 um^2"
puts "======================================================================"

#==============================================================================
# END OF SDC FILE
#==============================================================================

