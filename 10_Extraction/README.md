# 10_Extraction

## Overview
Parasitic extraction extracts resistance and capacitance (RC) from the routed layout for accurate timing analysis.

## Files
1. **README.md** - This file
2. **adder32.spef** - Standard Parasitic Exchange Format
3. **adder32.cap** - Capacitance data
4. **adder32.res** - Resistance data

## Flow
```
Input: adder32_routed.def + Technology RC data
  ↓
Extract wire parasitics (R, C, CC)
  ↓
Generate SPEF file
  ↓
Output: Para sitics → Feeds into 11_STA_Signoff
```

## Key Metrics
- Total nets extracted: 520
- Total capacitance: 2.85 pF
- Total resistance: 145 Ω
- Coupling capacitance: 0.42 pF

Next: **11_STA_Signoff** (Final timing analysis)

