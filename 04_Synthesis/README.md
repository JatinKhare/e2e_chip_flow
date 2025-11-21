# 04_Synthesis

## Overview
This is the logic synthesis phase where the RTL code is translated into a gate-level netlist using standard cells from a technology library. Synthesis optimizes the design for area, timing, and power while meeting specified constraints.

## Purpose
- Transform RTL (behavioral description) to gate-level netlist (structural)
- Map design to standard cell library
- Optimize for timing, area, and power
- Generate reports for analysis
- Produce netlist for physical design

## Files in This Folder

### 1. `adder32.tcl`
Synthesis script (for Design Compiler or Genus):
- Read RTL files
- Set timing constraints
- Configure optimization goals
- Run synthesis
- Write outputs

### 2. `adder32.sdc`
Synopsys Design Constraints (SDC) file:
- Clock definitions (period, uncertainty)
- Input/output delays
- Load constraints
- Timing exceptions (false paths, multi-cycle)

### 3. `adder32_netlist.v`
Synthesized gate-level netlist:
- Instantiates standard cells
- Wire connections
- Preserves functionality from RTL
- Optimized for timing/area

### 4. `synthesis_report.rpt`
Synthesis quality-of-results (QoR) report:
- Timing analysis (setup/hold)
- Area breakdown
- Power estimation
- Design rule violations

## Inputs to This Step
From **02_RTL**:
- `adder_pkg.sv` - Package definitions
- `adder32.sv` - Main RTL module
- `top.sv` - Top-level wrapper

From **01_Architecture**:
- `timing_targets.xlsx` - Clock frequency, delays
- `power_targets.xlsx` - Power budget

Technology Library:
- Standard cell library (.lib)
- Technology file (.tf)
- Physical data (.lef)

## Outputs from This Step
- **Gate-level netlist**: `adder32_netlist.v`
- **Timing reports**: Setup/hold slack
- **Area report**: Cell count, total area
- **Power report**: Dynamic/leakage power
- **SDC constraints**: For downstream tools

These outputs feed into:
- **05_Formal_Verification** - Equivalence checking (RTL vs. netlist)
- **06_Floorplan** - Physical design starting point

## Block Diagram - Synthesis Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         INPUTS                                   │
├─────────────────────────────────────────────────────────────────┤
│  From 02_RTL:                                                    │
│    • adder_pkg.sv, adder32.sv, top.sv (RTL source)               │
│                                                                  │
│  From 01_Architecture:                                           │
│    • timing_targets.xlsx (100MHz clock)                          │
│    • power_targets.xlsx (<1mW power budget)                      │
│                                                                  │
│  Technology Library:                                             │
│    • std_cell_lib.lib (timing models, 28nm)                      │
│    • tech.lef (physical abstracts)                               │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                   SYNTHESIS PHASE                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                  │
│  │  Read RTL &      │    │   Elaborate      │                  │
│  │  Constraints     │───▶│   Design         │                  │
│  │ (adder32.tcl)    │    │                  │                  │
│  └──────────────────┘    └────────┬─────────┘                  │
│                                   │                              │
│                                   ▼                              │
│                         ┌──────────────────┐                    │
│                         │   Generic        │                    │
│                         │   Optimization   │                    │
│                         │   (Boolean)      │                    │
│                         └────────┬─────────┘                    │
│                                   │                              │
│                                   ▼                              │
│                         ┌──────────────────┐                    │
│                         │   Technology     │                    │
│                         │   Mapping        │                    │
│                         │   (std cells)    │                    │
│                         └────────┬─────────┘                    │
│                                   │                              │
│                                   ▼                              │
│  ┌──────────────────┐    ┌──────────────────┐                  │
│  │  Timing          │◀───│   Optimization   │                  │
│  │  Analysis        │───▶│   (Area/Power)   │                  │
│  └──────────────────┘    └────────┬─────────┘                  │
│                                   │                              │
│                                   ▼                              │
│                         ┌──────────────────┐                    │
│                         │   Write          │                    │
│                         │   Outputs        │                    │
│                         │   (netlist, rpt) │                    │
│                         └──────────────────┘                    │
│                                                                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                        OUTPUTS                                   │
├─────────────────────────────────────────────────────────────────┤
│  • adder32_netlist.v    → Gate-level netlist                     │
│  • adder32.sdc          → Timing constraints                     │
│  • synthesis_report.rpt → QoR metrics                            │
│                                                                  │
│  Quality Metrics:                                                │
│    - Timing: WNS (Worst Negative Slack) > 0 ns                   │
│    - Area: ~900 µm² (meets <1000 µm² target)                     │
│    - Power: 0.82 mW @ 100MHz (meets <1mW target)                 │
│    - Cell Count: ~450 cells                                      │
│                                                                  │
│  These outputs feed into:                                        │
│    → 05_Formal_Verification (RTL-to-gate equivalence)            │
│    → 06_Floorplan (physical implementation)                      │
└─────────────────────────────────────────────────────────────────┘
```

## Synthesis Optimization Goals

### 1. **Timing Optimization**
- **Goal**: Meet 10ns clock period (100MHz)
- **Strategy**: 
  - Use fast cells on critical paths
  - Optimize carry chain
  - Minimize wire delay estimates
- **Result**: Target WNS > 0.5ns (positive slack)

### 2. **Area Optimization**
- **Goal**: Minimize silicon area (<1000 µm²)
- **Strategy**:
  - Use smallest drive strength cells where possible
  - Share logic resources
  - Avoid redundant logic
- **Result**: Target ~900 µm²

### 3. **Power Optimization**
- **Goal**: Minimize power (<1mW @ 100MHz)
- **Strategy**:
  - Use high-VT cells for non-critical paths
  - Clock gating where applicable
  - Minimize switching activity
- **Result**: Target ~0.8mW

## Synthesis QoR Targets

| Metric | Target | Typical | Status |
|--------|--------|---------|--------|
| WNS (Setup) | > 0 ns | +0.5 ns | ✓ TARGET |
| TNS (Total Neg Slack) | 0 ns | 0 ns | ✓ TARGET |
| WHS (Hold) | > 0 ns | +0.2 ns | ✓ TARGET |
| Total Area | <1000 µm² | 920 µm² | ✓ TARGET |
| Cell Count | - | ~450 | Info |
| Total Power | <1 mW | 0.82 mW | ✓ TARGET |
| Max Fanout | <16 | 8 | ✓ GOOD |
| Max Transition | <0.5 ns | 0.35 ns | ✓ GOOD |
| Max Capacitance | <100 fF | 65 fF | ✓ GOOD |

## Critical Path Analysis

The critical path in the 32-bit ripple-carry adder is the carry chain:

```
carry[0] → FA0 → FA1 → FA2 → ... → FA31 → carry[32]
         └─ ~0.25ns per stage × 32 = ~8ns total
```

**Optimization techniques**:
1. Use low-VT (fast) cells for full adders
2. Minimize buffering delays
3. Consider restructuring to carry-lookahead if timing not met
4. Pipeline insertion (adds latency but improves fmax)

## Standard Cell Library

This design targets a 28nm CMOS technology:
- **Library**: `typical_std_cell_28nm.lib`
- **Operating Conditions**: 1.0V, 25°C, typical corner
- **Available Cells**:
  - Logic gates: AND, OR, NAND, NOR, XOR, INV (various drive strengths)
  - Sequential: DFF, LATCH
  - Special: MUX, AOI, OAI, Full Adder macros
- **VT Options**: Low-VT (fast, leaky), High-VT (slow, low-leakage)

## Synthesis Tool Support

This synthesis script is compatible with:
- **Synopsys Design Compiler** (recommended)
- **Cadence Genus**
- **Yosys** (open-source, limited optimizations)

## Common Synthesis Issues & Solutions

| Issue | Symptom | Solution |
|-------|---------|----------|
| Timing violation | WNS < 0 | Use faster cells, restructure logic |
| High power | Power > budget | Use high-VT cells, clock gating |
| Large area | Area > target | Share resources, optimize FSMs |
| Latch inference | Warnings | Fix combinational logic (all paths assigned) |
| Multi-driven nets | Errors | Fix RTL (one driver per signal) |

## Next Steps
After successful synthesis:
1. **Review reports** - Check timing, area, power
2. **05_Formal_Verification** - Prove RTL-netlist equivalence
3. **06_Floorplan** - Begin physical design
4. **Iterate if needed** - Adjust constraints, optimize RTL

## Deliverables Checklist
- ✓ Gate-level netlist (Verilog)
- ✓ SDC constraints
- ✓ Synthesis reports (timing, area, power)
- ✓ QoR summary document
- ✓ Critical path report

