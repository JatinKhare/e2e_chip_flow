# 14_SPICE_Sims

## Overview
SPICE-level simulations verify critical timing paths at transistor level for sign-off accuracy.

## Files/Folders
1. **README.md** - This file
2. **models/** - SPICE models (TT, FF, SS corners)
3. **netlist/** - Transistor-level netlist
4. **tb/** - SPICE testbench
5. **results/** - Simulation outputs

## Flow
```
Input: Critical path extracted to transistor netlist
  ↓
Load SPICE models (TT/FF/SS)
  ↓
Run transient simulation
  ↓
Measure delays, rise/fall times
  ↓
Verify timing margins
```

## Key Metrics
- Critical path delay (SPICE): 9.12 ns
- STA predicted: 9.08 ns
- Correlation: 99.6% ✓

Next: **15_LVS_DRC**

