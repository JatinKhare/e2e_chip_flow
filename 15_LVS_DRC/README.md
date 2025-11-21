# 15_LVS_DRC

## Overview
Layout vs. Schematic (LVS) and Design Rule Check (DRC) verify physical layout correctness.

## Files
1. **README.md** - This file
2. **adder32.lvs.rpt** - LVS report
3. **adder32.drc.rpt** - DRC report
4. **lvs_netlist.sp** - Extracted layout netlist

## Flow
```
GDS Layout + Schematic Netlist
  ↓
DRC: Check design rules (spacing, width, etc.)
  ↓
LVS: Extract layout netlist & compare
  ↓
Fix violations
  ↓
Sign-off: Clean DRC & LVS match
```

## Key Results
- DRC violations: 0 ✓
- LVS: MATCH ✓
- Layout vs. Schematic: Equivalent

Next: **16_GDSII_Tapeout**

