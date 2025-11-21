# 07_Placement

## Overview
Placement optimizes the physical location of standard cells within the core area to minimize wirelength, meet timing, and prepare for routing.

## Files
1. **README.md** - This file
2. **adder32_placed.def** - DEF with placed cells
3. **placement_report.rpt** - Congestion, timing estimates

## Flow
```
Input: adder32_initial.def (from 06_Floorplan)
  ↓
Global Placement (spread cells)
  ↓
Legalization (snap to rows)
  ↓
Detailed Placement (local optimization)
  ↓
Output: adder32_placed.def → Feeds into 08_CTS
```

## Key Metrics
- Cell utilization: 45%
- Wirelength: ~15,000µm (estimated)
- Congestion: <50% (good routability)
- Timing (estimated): WNS +1.2ns

Next: **08_CTS** (Clock Tree Synthesis)

