#==============================================================================
# Synthesis Script for 32-bit Adder
# Tool: Synopsys Design Compiler or Cadence Genus
# Technology: 28nm CMOS
# Author: Synthesis Team
# Date: 2024-01-15
#==============================================================================

# This script is written for Design Compiler syntax
# For Genus, some commands may differ slightly

puts "======================================================================"
puts " 32-bit Adder Synthesis Script"
puts " Technology: 28nm CMOS"
puts " Target Frequency: 100 MHz (10ns period)"
puts "======================================================================"

#==============================================================================
# 1. SETUP - Libraries and Search Paths
#==============================================================================

puts "\n[INFO] Setting up libraries and search paths..."

# Define technology library paths (adjust for your installation)
set TECH_LIB_PATH "/path/to/tech/libs/28nm"
set STD_CELL_LIB  "typical_std_cell_28nm"

# Search path for files
set search_path [list . \
                      ../02_RTL \
                      $TECH_LIB_PATH \
                      ]

# Target library (used for mapping)
set target_library [list ${STD_CELL_LIB}.db]

# Link library (includes target + standard cells)
set link_library [concat * $target_library]

# Symbol library for schematic generation (optional)
set symbol_library [list ${STD_CELL_LIB}.sdb]

# Set operating conditions (TT = Typical-Typical corner)
set_operating_conditions -analysis_type on_chip_variation typical

puts "[INFO] Target library: $target_library"

#==============================================================================
# 2. READ RTL - Load SystemVerilog source files
#==============================================================================

puts "\n[INFO] Reading RTL source files..."

# Read RTL files in dependency order
analyze -format sverilog [list \
    ../02_RTL/adder_pkg.sv \
    ../02_RTL/adder32.sv \
]

# Elaborate the design (top module)
elaborate adder32

# Link the design to libraries
link

# Check design integrity
check_design > reports/check_design.rpt

puts "[INFO] RTL read and elaborated successfully"

#==============================================================================
# 3. APPLY CONSTRAINTS - Read SDC file
#==============================================================================

puts "\n[INFO] Applying timing constraints..."

# Read SDC constraints
source adder32.sdc

# Check timing constraints
check_timing -verbose > reports/check_timing.rpt

puts "[INFO] Constraints applied"

#==============================================================================
# 4. OPTIMIZATION SETTINGS
#==============================================================================

puts "\n[INFO] Configuring synthesis options..."

# Enable high-effort optimization
set compile_ultra_ungroup_dw true

# Clock gating (for power savings)
set compile_clock_gating_through_hierarchy true
set power_cg_auto_identify true

# Multi-VT optimization (use mix of low/high VT cells)
set_multi_vt_optimization_preference -multi_vt_effort high

# Wire load model (estimate interconnect delay)
set_wire_load_model -name typical_wire_load

# Area recovery (optimize area after meeting timing)
set compile_enable_area_recovery true

# Set max area constraint (soft goal)
set_max_area 1000

puts "[INFO] Optimization settings configured"

#==============================================================================
# 5. COMPILE (SYNTHESIS)
#==============================================================================

puts "\n[INFO] Starting synthesis..."

# Compile Ultra: aggressive optimization
# Options:
#   -gate_clock: insert clock gates
#   -no_autoungroup: keep hierarchy
#   -timing_high_effort_script: extra timing optimization
compile_ultra -gate_clock -no_autoungroup

# Alternative: Standard compile (faster, less optimal)
# compile -map_effort medium

puts "[INFO] Synthesis completed"

#==============================================================================
# 6. OPTIMIZATION FOR AREA (if timing met)
#==============================================================================

puts "\n[INFO] Performing area optimization..."

# Incremental compile with area focus
compile_ultra -incremental -area_high_effort_script

puts "[INFO] Area optimization completed"

#==============================================================================
# 7. GENERATE REPORTS
#==============================================================================

puts "\n[INFO] Generating reports..."

# Create reports directory
file mkdir reports

# Timing reports
report_timing -path full -delay max -max_paths 10 -nworst 1 \
    > reports/timing_setup.rpt
report_timing -path full -delay min -max_paths 10 -nworst 1 \
    > reports/timing_hold.rpt
report_constraint -all_violators > reports/constraints_violated.rpt

# Area reports
report_area -hierarchy > reports/area.rpt
report_cell > reports/cell_usage.rpt
report_reference > reports/reference.rpt

# Power reports
report_power -hierarchy > reports/power.rpt

# QoR (Quality of Results) summary
report_qor > reports/qor.rpt

# Design statistics
report_design > reports/design_stats.rpt

# Clock gating report
report_clock_gating -gating_elements > reports/clock_gating.rpt

puts "[INFO] Reports generated in reports/ directory"

#==============================================================================
# 8. WRITE OUTPUTS
#==============================================================================

puts "\n[INFO] Writing output files..."

# Create outputs directory
file mkdir outputs

# Write gate-level netlist (Verilog)
write -format verilog -hierarchy -output outputs/adder32_netlist.v
# Also copy to current directory for convenience
file copy -force outputs/adder32_netlist.v adder32_netlist.v

# Write SDC constraints (for downstream tools)
write_sdc outputs/adder32_synth.sdc

# Write design database (Synopsys format, for reopening)
write -format ddc -hierarchy -output outputs/adder32.ddc

# Write scan DEF (if scan chains inserted)
# write_scan_def -output outputs/adder32_scan.def

puts "[INFO] Output files written to outputs/ directory"

#==============================================================================
# 9. FINAL CHECKS AND SUMMARY
#==============================================================================

puts "\n[INFO] Performing final checks..."

# Check for any remaining issues
check_design > reports/check_design_final.rpt
check_timing > reports/check_timing_final.rpt

# Print summary to console
puts "\n======================================================================"
puts " SYNTHESIS SUMMARY"
puts "======================================================================"
report_qor
puts "======================================================================"

# Extract key metrics
set wns [get_attribute [get_timing_paths -delay_type max] slack]
set tns [get_attribute [current_design] total_negative_slack]
set area [get_attribute [current_design] area]
set power [get_attribute [current_design] total_power]

puts "\nKey Metrics:"
puts "  WNS (Setup):  $wns ns"
puts "  TNS (Total):  $tns ns"
puts "  Area:         [format %.2f $area] um^2"
puts "  Power:        [format %.4f $power] mW"

# Check if goals met
if {$wns >= 0} {
    puts "\n*** Timing: PASS (WNS >= 0)"
} else {
    puts "\n*** Timing: FAIL (WNS < 0) - Needs optimization"
}

if {$area <= 1000} {
    puts "*** Area:   PASS (< 1000 um^2)"
} else {
    puts "*** Area:   FAIL (> 1000 um^2) - Needs optimization"
}

puts "\n======================================================================"
puts " Synthesis Complete"
puts " Review reports in: reports/"
puts " Netlist:           adder32_netlist.v"
puts "======================================================================"

# Exit (optional - comment out for interactive mode)
# quit

