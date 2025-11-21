# 09_Routing

## Overview
Routing connects all standard cells using metal layers, completing physical connectivity while respecting design rules.

## Files
1. **README.md** - This file
2. **adder32_routed.def** - DEF with all nets routed
3. **adder32_routed.gds** - GDSII layout (placeholder)
4. **routing_congestion.rpt** - Routing metrics

## Flow
```
Input: adder32_cts.def
  ↓
Global Routing (assign routing resources)
  ↓
Track Assignment
  ↓
Detailed Routing (actual wire geometry)
  ↓
Search & Repair (fix DRC violations)
  ↓
Output: adder32_routed.def → Feeds into 10_Extraction
```

## Key Metrics
- Total nets: 520
- Nets routed: 520 (100%)
- DRC violations: 0
- Routing layers used: M1-M5
- Total wirelength: 18,450µm

Next: **10_Extraction** (Parasitic extraction)

