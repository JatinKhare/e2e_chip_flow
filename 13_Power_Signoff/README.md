# 13_Power_Signoff

## Overview
Power signoff analyzes and validates total power consumption against specifications.

## Files
1. **README.md** - This file
2. **switching.saif** - Switching Activity Interchange Format
3. **power_report.rpt** - Detailed power analysis

## Flow
```
Input: Netlist + SPEF + Switching activity
  ↓
Vector-based power analysis
  ↓
Calculate dynamic + leakage power
  ↓
Verify against power budget
  ↓
Sign-off: PASS
```

## Key Metrics
- Dynamic power: 0.78 mW @ 100MHz
- Leakage power: 8.2 µW @ 25°C
- Total power: 0.788 mW
- Target: <1.0 mW ✓ PASS

Next: **14_SPICE_Sims**

