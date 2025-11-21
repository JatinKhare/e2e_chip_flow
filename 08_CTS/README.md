# 08_CTS

## Overview
Clock Tree Synthesis (CTS) builds a balanced clock distribution network to deliver the clock signal to all flip-flops with minimal skew.

## Files
1. **README.md** - This file
2. **cts_script.tcl** - CTS configuration
3. **adder32_cts.def** - DEF with clock tree
4. **skew_report.rpt** - Clock skew analysis

## Flow
```
Input: adder32_placed.def
  ↓
Identify clock sinks (99 flip-flops)
  ↓
Build clock tree (H-tree or spine)
  ↓
Insert buffers for skew balancing
  ↓
Output: adder32_cts.def → Feeds into 09_Routing
```

## Key Metrics
- Clock sinks: 99 flip-flops
- Clock skew: <50ps (global)
- Clock latency: ~800ps (source to sink)
- Buffers inserted: 12

Next: **09_Routing** (Signal routing)

