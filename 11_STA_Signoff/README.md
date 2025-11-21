# 11_STA_Signoff

## Overview
Static Timing Analysis (STA) signoff verifies all timing requirements are met with extracted parasitics.

## Files
1. **README.md** - This file
2. **adder32_post_route.sdc** - Post-route constraints
3. **adder32_post_route.sdf** - Standard Delay Format
4. **setup_timing.rpt** - Setup timing report
5. **hold_timing.rpt** - Hold timing report

## Flow
```
Input: Routed netlist + SPEF parasitics + SDC
  ↓
Load design and constraints
  ↓
Run STA (setup & hold analysis)
  ↓
Check all paths meet timing
  ↓
Sign-off: PASS → Proceed to tapeout
```

## Key Metrics
- WNS (Setup): +0.42 ns ✓
- WNS (Hold): +0.08 ns ✓
- All paths meet timing
- Clock period: 10 ns (100 MHz)

Next: **12_IRDrop_EM** (Power integrity)

