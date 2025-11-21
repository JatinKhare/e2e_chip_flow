# 12_IRDrop_EM

## Overview
IR-drop and electromigration (EM) analysis ensures power grid integrity and reliability.

## Files
1. **README.md** - This file
2. **irdrop_report.rpt** - IR-drop analysis
3. **em_report.rpt** - Electromigration check
4. **power_grid_map.png** - Voltage map (placeholder)

## Flow
```
Input: Routed design + Power grid + Switching activity
  ↓
DC IR-drop analysis (static)
  ↓
Dynamic IR-drop (with switching)
  ↓
EM analysis (current density)
  ↓
Fix violations: Widen wires, add stripes
  ↓
Sign-off: PASS
```

## Key Metrics
- Max IR-drop: 28 mV (Target: <50mV) ✓
- EM violations: 0
- Avg current density: 0.8 mA/µm

Next: **13_Power_Signoff**

