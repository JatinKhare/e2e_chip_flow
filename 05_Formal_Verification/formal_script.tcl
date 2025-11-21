#==============================================================================
# Formal Verification Script (Logic Equivalence Checking)
# Tool: Synopsys Formality or Cadence Conformal LEC
# Purpose: Prove RTL and gate-level netlist are functionally equivalent
# Author: Formal Verification Team
# Date: 2024-01-15
#==============================================================================

puts "======================================================================"
puts " Formal Equivalence Checking - 32-bit Adder"
puts " RTL (Golden) vs. Gate-Level Netlist (Revised)"
puts "======================================================================"

#==============================================================================
# 1. SETUP - Tool Configuration
#==============================================================================

puts "\n[INFO] Configuring formal verification environment..."

# Set search paths
set search_path [list . \
                      ../02_RTL \
                      ../04_Synthesis \
                      /path/to/tech/libs/28nm \
                      ]

# Enable more verbose reporting
set verification_verify_directly_undriven_output false
set verification_failing_point_limit 10

# Set comparison effort (low/medium/high)
set verification_set_undriven_signals synthesis

puts "[INFO] Environment configured"

#==============================================================================
# 2. READ GOLDEN (RTL Reference Design)
#==============================================================================

puts "\n[INFO] Reading Golden Reference (RTL)..."

# Read RTL files
read_sverilog -container r -libname WORK -05 { \
    ../02_RTL/adder_pkg.sv \
    ../02_RTL/adder32.sv \
}

# Set top module for golden design
set_top r:/WORK/adder32

# Report design statistics
puts "[INFO] Golden design read successfully"
report_design_data r:/WORK/adder32

#==============================================================================
# 3. READ REVISED (Gate-Level Netlist)
#==============================================================================

puts "\n[INFO] Reading Revised Design (Gate-level Netlist)..."

# Read gate-level netlist
read_verilog -container i -libname WORK { \
    ../04_Synthesis/adder32_netlist.v \
}

# Set top module for revised design
set_top i:/WORK/adder32

# Report design statistics
puts "[INFO] Revised design read successfully"
report_design_data i:/WORK/adder32

#==============================================================================
# 4. MATCH - Map Compare Points
#==============================================================================

puts "\n[INFO] Matching compare points between designs..."

# Automatic name matching
# Tool will automatically map signals with same names
match

# Report matching results
puts "\n[INFO] Matching Summary:"
report_matched_points
report_unmatched_points

# If there are unmatched points, may need manual mapping:
# Example manual mappings (if names differ):
# set_reference_design r:/WORK/adder32
# set_implementation_design i:/WORK/adder32
# match_signals r:/signal_name i:/different_signal_name

#==============================================================================
# 5. HANDLE CONSTANTS AND DON'T CARES
#==============================================================================

puts "\n[INFO] Setting up constant and don't-care handling..."

# Set constant values (if any signals are tied high/low)
# Example: set_constant r:/WORK/adder32/test_mode 0
# Example: set_constant i:/WORK/adder32/test_mode 0

# Set don't-care conditions (for X values)
# This helps when reset behavior differs slightly
# set_case_analysis 0 i:/WORK/adder32/scan_enable

puts "[INFO] Constants and don't-cares configured"

#==============================================================================
# 6. VERIFY - Run Equivalence Checking
#==============================================================================

puts "\n[INFO] Running equivalence checking..."
puts "[INFO] This may take a few minutes for complex designs..."

# Verify all compare points
verify

#==============================================================================
# 7. ANALYZE RESULTS
#==============================================================================

puts "\n======================================================================"
puts " EQUIVALENCE CHECKING RESULTS"
puts "======================================================================"

# Report overall status
report_verification

# Report any failing points
if {[get_verification_status] != "SUCCEEDED"} {
    puts "\n[WARNING] Equivalence check found issues!"
    puts "Analyzing non-equivalent points...\n"
    
    # Report failing points in detail
    report_failing_points -verbose
    
    # Generate diagnosis for debugging
    diagnose -mode all
    
    # Save counter-examples for simulation
    report_aborted > reports/aborted_points.rpt
    report_failing_points > reports/failing_points.rpt
    
} else {
    puts "\n[PASS] All compare points are EQUIVALENT!"
}

#==============================================================================
# 8. DETAILED REPORTS
#==============================================================================

puts "\n[INFO] Generating detailed reports..."

# Create reports directory
file mkdir reports

# Overall verification summary
report_verification > reports/verification_summary.rpt

# Matched points report
report_matched_points -class {port pin register} > reports/matched_points.rpt

# Unmatched points report (if any)
report_unmatched_points > reports/unmatched_points.rpt

# Guidance for resolving issues (if any)
report_guidance > reports/guidance.rpt

# Statistics
report_statistics > reports/statistics.rpt

# Copy main report to top level
file copy -force reports/verification_summary.rpt rtl_vs_netlist_equiv.rpt

puts "[INFO] Reports generated in reports/ directory"

#==============================================================================
# 9. ADVANCED CHECKS (Optional)
#==============================================================================

# Check for specific scenarios

# Check if all primary inputs are matched
puts "\n[INFO] Verifying all primary inputs are matched..."
set unmatched_pi [get_unmatched_points -type pi r:/WORK/adder32]
if {[sizeof_collection $unmatched_pi] > 0} {
    puts "[WARNING] Found [sizeof_collection $unmatched_pi] unmatched primary inputs"
    report_object $unmatched_pi
} else {
    puts "[PASS] All primary inputs matched"
}

# Check if all primary outputs are matched
puts "\n[INFO] Verifying all primary outputs are matched..."
set unmatched_po [get_unmatched_points -type po r:/WORK/adder32]
if {[sizeof_collection $unmatched_po] > 0} {
    puts "[WARNING] Found [sizeof_collection $unmatched_po] unmatched primary outputs"
    report_object $unmatched_po
} else {
    puts "[PASS] All primary outputs matched"
}

# Check if all registers are matched
puts "\n[INFO] Verifying all registers are matched..."
set unmatched_reg [get_unmatched_points -type register r:/WORK/adder32]
if {[sizeof_collection $unmatched_reg] > 0} {
    puts "[WARNING] Found [sizeof_collection $unmatched_reg] unmatched registers"
    report_object $unmatched_reg
} else {
    puts "[PASS] All registers matched"
}

#==============================================================================
# 10. SUMMARY AND EXIT
#==============================================================================

puts "\n======================================================================"
puts " FORMAL VERIFICATION SUMMARY"
puts "======================================================================"

# Get verification status
set status [get_verification_status]

puts ""
puts "  Golden Reference:  02_RTL/adder32.sv"
puts "  Revised Design:    04_Synthesis/adder32_netlist.v"
puts "  Verification Status: $status"
puts ""

# Final pass/fail message
if {$status == "SUCCEEDED"} {
    puts "  *** VERIFICATION PASSED ***"
    puts "  All compare points are functionally EQUIVALENT"
    puts ""
    puts "  Sign-off approval: Ready for physical design"
    set exit_code 0
} else {
    puts "  !!! VERIFICATION FAILED !!!"
    puts "  Found non-equivalent points - review reports"
    puts ""
    puts "  Action required: Debug and resolve differences"
    set exit_code 1
}

puts "======================================================================"
puts ""
puts "Main Report: rtl_vs_netlist_equiv.rpt"
puts "Detailed Reports: reports/"
puts ""
puts "======================================================================"

# Exit with appropriate code
# exit $exit_code

