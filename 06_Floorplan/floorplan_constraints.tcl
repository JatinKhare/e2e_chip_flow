#==============================================================================
# Floorplan Script for 32-bit Adder
# Tool: Cadence Innovus or Synopsys ICC2
# Purpose: Create initial physical layout with die/core area, I/O placement
# Author: Physical Design Team
# Date: 2024-01-15
#==============================================================================

puts "======================================================================"
puts " Floorplan Creation - 32-bit Adder"
puts " Technology: 28nm CMOS"
puts "======================================================================"

#==============================================================================
# 1. READ DESIGN
#==============================================================================

# Read gate-level netlist
read_verilog ../04_Synthesis/adder32_netlist.v

# Read technology LEF
read_lef /path/to/tech/28nm/tech.lef
read_lef /path/to/stdcells/stdcells.lef

# Set top module
set_top_module adder32

#==============================================================================
# 2. DEFINE FLOORPLAN
#==============================================================================

# Calculate core area based on cell area and utilization
# Cell area from synthesis: ~920 µm²
# Target utilization: 45%
# Required core area: 920 / 0.45 ≈ 2044 µm²
# Core dimensions: sqrt(2044) ≈ 45µm × 45µm

# Define floorplan
# Die size: 50µm × 50µm (includes I/O ring)
# Core size: 45µm × 45µm
# Core offset: 2.5µm from die edge

floorPlan -site core_site \
          -r 1.0 0.45 2.5 2.5 2.5 2.5
          # Aspect ratio: 1.0 (square)
          # Utilization: 0.45 (45%)
          # Margins: 2.5µm on all sides

puts "[INFO] Floorplan created: 45µm × 45µm core, 50µm × 50µm die"

#==============================================================================
# 3. I/O PAD PLACEMENT
#==============================================================================

# Place I/O pads around periphery
# Total I/O: 68 (65 inputs + 3 outputs)

# Left edge: a[15:0]
foreach i {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15} {
    placeInstance a_pad_${i} 0.0 [expr 5.0 + $i * 2.5] -fixed
}

# Bottom edge: a[31:16]
foreach i {16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31} {
    placeInstance a_pad_${i} [expr 5.0 + ($i-16) * 2.5] 0.0 -fixed
}

# Right edge: b[15:0]
foreach i {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15} {
    placeInstance b_pad_${i} 50.0 [expr 5.0 + $i * 2.5] -fixed
}

# Top edge: b[31:16]
foreach i {16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31} {
    placeInstance b_pad_${i} [expr 5.0 + ($i-16) * 2.5] 50.0 -fixed
}

# Corner placements (special signals)
placeInstance clk_pad 2.5 2.5 -fixed
placeInstance rst_n_pad 47.5 2.5 -fixed
placeInstance carry_in_pad 2.5 47.5 -fixed
placeInstance carry_out_pad 47.5 47.5 -fixed

puts "[INFO] I/O pads placed"

#==============================================================================
# 4. POWER PLANNING
#==============================================================================

# Create power rings (VDD/VSS) around core
addRing -nets {VDD VSS} \
        -layer {top M5 bottom M5 left M5 right M5} \
        -width 2.0 \
        -spacing 0.5 \
        -offset 1.0

# Create power stripes (vertical on M4, horizontal on M3)
addStripe -nets {VDD VSS} \
          -layer M4 \
          -direction vertical \
          -width 0.5 \
          -spacing 5.0 \
          -start 5.0

addStripe -nets {VDD VSS} \
          -layer M3 \
          -direction horizontal \
          -width 0.5 \
          -spacing 5.0 \
          -start 5.0

puts "[INFO] Power grid created"

#==============================================================================
# 5. DEFINE PLACEMENT ROWS
#==============================================================================

# Rows for standard cell placement are created automatically
# based on site definition from LEF

puts "[INFO] Standard cell rows defined"

#==============================================================================
# 6. WRITE OUTPUT DEF
#==============================================================================

defOut -floorplan adder32_initial.def

puts "[INFO] Initial DEF written: adder32_initial.def"

puts "======================================================================"
puts " Floorplan Complete"
puts "======================================================================"

