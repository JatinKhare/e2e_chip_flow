#!/bin/bash
#==============================================================================
# Script: run_sim.sh
# Description: Compilation and simulation script for 32-bit adder testbench
# Author: Verification Team
# Date: 2024-01-15
# Usage: ./run_sim.sh [options]
#==============================================================================

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=============================================================="
echo " 32-bit Adder Simulation Script"
echo "=============================================================="

# Configuration
SIM_TOOL="vcs"  # Options: vcs, questa, xcelium
RTL_DIR="../02_RTL"
TB_DIR="."
WORK_DIR="./work"
WAVES_DIR="./waves"

# Create directories
mkdir -p $WORK_DIR
mkdir -p $WAVES_DIR

# Parse command line arguments
SEED=${1:-12345}  # Default seed
GUI_MODE=${2:-0}   # 0=batch, 1=GUI

echo " "
echo "Configuration:"
echo "  Simulator: $SIM_TOOL"
echo "  Random Seed: $SEED"
echo "  GUI Mode: $GUI_MODE"
echo " "

#==============================================================================
# VCS Simulation Flow
#==============================================================================

if [ "$SIM_TOOL" == "vcs" ]; then
    echo "--- VCS Compilation ---"
    
    # Compile RTL and Testbench
    vcs -full64 \
        -sverilog \
        -timescale=1ns/1ps \
        -debug_access+all \
        -kdb \
        -lca \
        -o simv \
        -l compile.log \
        $RTL_DIR/adder_pkg.sv \
        $RTL_DIR/adder32.sv \
        $TB_DIR/tb_adder32.sv
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}[ERROR] Compilation failed!${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}[PASS] Compilation successful${NC}"
    echo " "
    echo "--- VCS Simulation ---"
    
    # Run simulation
    if [ $GUI_MODE -eq 1 ]; then
        # GUI mode (Verdi)
        ./simv -gui -l sim.log +ntb_random_seed=$SEED
    else
        # Batch mode
        ./simv -l sim.log +ntb_random_seed=$SEED
    fi
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}[ERROR] Simulation failed!${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}[PASS] Simulation completed${NC}"
    
    # Generate coverage report
    echo " "
    echo "--- Coverage Analysis ---"
    urg -dir simv.vdb -report coverage_report
    echo "Coverage report generated in: coverage_report/"
    
#==============================================================================
# Questa Simulation Flow
#==============================================================================

elif [ "$SIM_TOOL" == "questa" ]; then
    echo "--- Questa Compilation ---"
    
    # Create library
    vlib $WORK_DIR/work
    vmap work $WORK_DIR/work
    
    # Compile RTL
    vlog -sv \
        -work $WORK_DIR/work \
        +incdir+$RTL_DIR \
        -l compile.log \
        $RTL_DIR/adder_pkg.sv \
        $RTL_DIR/adder32.sv \
        $TB_DIR/tb_adder32.sv
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}[ERROR] Compilation failed!${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}[PASS] Compilation successful${NC}"
    echo " "
    echo "--- Questa Simulation ---"
    
    # Run simulation
    if [ $GUI_MODE -eq 1 ]; then
        # GUI mode
        vsim -voptargs=+acc work.tb_adder32 -do "add wave -r /*; run -all"
    else
        # Batch mode
        vsim -c -do "run -all; quit" \
            +ntb_random_seed=$SEED \
            -l sim.log \
            work.tb_adder32
    fi
    
#==============================================================================
# Xcelium Simulation Flow  
#==============================================================================

elif [ "$SIM_TOOL" == "xcelium" ]; then
    echo "--- Xcelium Compilation & Simulation ---"
    
    xrun -sv \
        -64bit \
        -access +rwc \
        -timescale 1ns/1ps \
        -svseed $SEED \
        -l xrun.log \
        $RTL_DIR/adder_pkg.sv \
        $RTL_DIR/adder32.sv \
        $TB_DIR/tb_adder32.sv
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}[ERROR] Simulation failed!${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}[PASS] Simulation completed${NC}"

else
    echo -e "${RED}[ERROR] Unknown simulator: $SIM_TOOL${NC}"
    exit 1
fi

#==============================================================================
# Post-Simulation Analysis
#==============================================================================

echo " "
echo "--- Checking Results ---"

# Check for test failures in log
if grep -q "FAIL" sim.log; then
    echo -e "${RED}[FAIL] Tests failed - see sim.log${NC}"
    grep "FAIL" sim.log
    exit 1
fi

if grep -q "ALL TESTS PASSED" sim.log; then
    echo -e "${GREEN}[PASS] All tests passed!${NC}"
else
    echo -e "${YELLOW}[WARN] Could not verify test status${NC}"
fi

echo " "
echo "=============================================================="
echo " Simulation Complete"
echo "=============================================================="
echo " Log file: sim.log"
echo " Waveform: $WAVES_DIR/adder.vcd"
echo " Coverage: coverage_report/ (if generated)"
echo "=============================================================="

# View waveform (optional)
if [ "$GUI_MODE" == "wave" ]; then
    echo "Opening waveform viewer..."
    gtkwave $WAVES_DIR/adder.vcd &
fi

exit 0

