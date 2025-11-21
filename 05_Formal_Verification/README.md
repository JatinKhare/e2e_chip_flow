# 05_Formal_Verification

## Overview
Formal verification mathematically proves that the synthesized gate-level netlist is functionally equivalent to the original RTL design. This is a critical step to ensure synthesis hasn't introduced any bugs or changed the design's behavior.

## Purpose
- Prove equivalence between RTL and gate-level netlist
- Catch synthesis bugs early (before physical design)
- Provide mathematical proof of correctness (not just simulation)
- Verify all possible input combinations (exhaustive)
- Generate confidence for tapeout sign-off

## Files in This Folder

### 1. `formal_script.tcl`
Formal verification script (for Conformal/Formality):
- Read RTL (golden reference)
- Read synthesized netlist (revised design)
- Set up comparison points
- Run equivalence checking
- Generate reports

### 2. `rtl_vs_netlist_equiv.rpt`
Equivalence checking report:
- Comparison results (equivalent/non-equivalent)
- Matched/unmatched points
- Any discrepancies found
- Debug information for failures

## Inputs to This Step
From **02_RTL**:
- `adder_pkg.sv` - RTL package
- `adder32.sv` - RTL design (golden reference)

From **04_Synthesis**:
- `adder32_netlist.v` - Gate-level netlist (revised design)

## Outputs from This Step
- **Equivalence report**: Proof of RTL-to-gate equivalence
- **Non-equivalent points**: Any mismatches (if failures)
- **Sign-off certificate**: Formal verification passed

These outputs provide:
- **Confidence** to proceed to physical design
- **Debug info** if equivalence fails (fix RTL or netlist)

## Block Diagram - Formal Verification Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         INPUTS                                   │
├─────────────────────────────────────────────────────────────────┤
│  Golden Reference (RTL):                                         │
│    • adder_pkg.sv (from 02_RTL)                                  │
│    • adder32.sv (from 02_RTL)                                    │
│                                                                  │
│  Revised Design (Netlist):                                       │
│    • adder32_netlist.v (from 04_Synthesis)                       │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│               FORMAL EQUIVALENCE CHECKING                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                  │
│  │  Read Golden     │    │  Read Revised    │                  │
│  │  (RTL)           │    │  (Netlist)       │                  │
│  └────────┬─────────┘    └────────┬─────────┘                  │
│           │                       │                              │
│           └───────────┬───────────┘                              │
│                       ▼                                          │
│            ┌──────────────────────┐                             │
│            │   Parse & Elaborate  │                             │
│            │   Both Designs       │                             │
│            └──────────┬───────────┘                             │
│                       │                                          │
│                       ▼                                          │
│            ┌──────────────────────┐                             │
│            │  Identify Compare    │                             │
│            │  Points (I/O, FFs)   │                             │
│            └──────────┬───────────┘                             │
│                       │                                          │
│                       ▼                                          │
│            ┌──────────────────────┐                             │
│            │  Map Key Points      │                             │
│            │  (Auto + Manual)     │                             │
│            └──────────┬───────────┘                             │
│                       │                                          │
│                       ▼                                          │
│            ┌──────────────────────┐                             │
│            │  Run Equivalence     │                             │
│            │  Checking (SAT/BDD)  │                             │
│            └──────────┬───────────┘                             │
│                       │                                          │
│           ┌───────────┴───────────┐                             │
│           ▼                       ▼                              │
│  ┌────────────────┐      ┌────────────────┐                    │
│  │  EQUIVALENT    │      │ NON-EQUIVALENT │                    │
│  │  (Pass)        │      │  (Debug)       │                    │
│  └────────┬───────┘      └────────┬───────┘                    │
│           │                       │                              │
│           │                       ▼                              │
│           │              ┌─────────────────┐                    │
│           │              │  Generate       │                    │
│           │              │  Counter-       │                    │
│           │              │  Examples       │                    │
│           │              └─────────────────┘                    │
│           │                                                      │
│           └──────────────┬───────────────────                   │
│                          ▼                                       │
│               ┌──────────────────┐                              │
│               │  Generate        │                              │
│               │  Report          │                              │
│               └──────────────────┘                              │
│                                                                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                        OUTPUTS                                   │
├─────────────────────────────────────────────────────────────────┤
│  • rtl_vs_netlist_equiv.rpt → Equivalence checking results      │
│                                                                  │
│  Expected Results:                                               │
│    - All compare points: EQUIVALENT                              │
│    - Inputs matched: 32+32+1 = 65                                │
│    - Outputs matched: 32+1+1 = 34                                │
│    - Flip-flops matched: 65 (input) + 34 (output) = 99          │
│    - No non-equivalent points                                    │
│    - Runtime: ~1-5 minutes                                       │
│                                                                  │
│  This output provides:                                           │
│    → Mathematical proof of correctness                           │
│    → Confidence to proceed to 06_Floorplan                       │
│    → Sign-off for synthesis phase                                │
└─────────────────────────────────────────────────────────────────┘
```

## Formal Verification Methods

### 1. **Combinational Equivalence Checking**
- Compares combinational logic between compare points
- Uses Boolean satisfiability (SAT) solvers
- Checks if outputs are identical for all input combinations

### 2. **Sequential Equivalence Checking**
- Compares state machines and sequential behavior
- Maps flip-flops between designs
- Verifies state transitions match

### 3. **Key Point Mapping**
- **Automatic Mapping**: Tool finds matching signals by name
- **Manual Mapping**: User specifies mappings for renamed signals
- **Compare Points**: Primary I/O, flip-flops, black boxes

## Equivalence Checking Process

| Step | Description | Status Check |
|------|-------------|--------------|
| 1. Read Golden | Parse RTL design | No errors |
| 2. Read Revised | Parse gate-level netlist | No errors |
| 3. Map Key Points | Match inputs, outputs, FFs | All mapped |
| 4. Run LEC | Compare logic cones | Equivalent |
| 5. Verify Unmapped | Check for unmapped points | None |
| 6. Generate Report | Document results | Pass |

## Expected Results

For the 32-bit adder design:

| Metric | Expected Value |
|--------|----------------|
| Primary Inputs | 65 (32+32+1 for a,b,cin) |
| Primary Outputs | 34 (32+1+1 for sum,cout,ovf) |
| Flip-Flops (Golden) | 99 (65 input + 34 output) |
| Flip-Flops (Revised) | 99 (should match) |
| Mapped Points | 198 (all) |
| Unmapped Points | 0 |
| Equivalent Points | 198 (100%) |
| Non-Equivalent | 0 |
| **Overall Status** | **EQUIVALENT** ✓ |

## Common Issues & Resolutions

| Issue | Cause | Resolution |
|-------|-------|------------|
| Unmapped points | Name changes in synthesis | Add manual name mapping |
| Non-equivalent | Synthesis bug or constraint issue | Debug with counter-examples |
| Constants not matching | Tie-offs differ | Set don't-care conditions |
| Black boxes | Uninterpreted modules | Add compare point at boundaries |
| X-propagation | Initialization differences | Add set_case_analysis |

## Debugging Non-Equivalence

If equivalence check fails:

1. **Review compare points**: Ensure all key points are mapped
2. **Examine counter-example**: Tool provides input pattern that shows difference
3. **Simulate both designs**: Run same stimulus on RTL and netlist
4. **Check synthesis logs**: Look for optimization warnings
5. **Verify constraints**: Ensure SDC constraints are correct
6. **Isolate failing cone**: Narrow down to specific logic block

## Formal Verification Tools

This script supports:
- **Synopsys Formality** (industry standard)
- **Cadence Conformal** (LEC - Logic Equivalence Checker)
- Both tools use similar TCL-based scripting

## Sign-Off Criteria

Formal verification is complete when:
- ✓ All primary I/O mapped and equivalent
- ✓ All flip-flops mapped and equivalent
- ✓ No unmapped points (or all explained/waived)
- ✓ No non-equivalent points
- ✓ Report generated and reviewed
- ✓ Sign-off approval from verification team

## Next Steps
After successful formal verification:
1. **Archive results** - Save report for documentation
2. **06_Floorplan** - Begin physical design with confidence
3. **Repeat LEC** - After place-and-route (netlist vs. final layout)

## Best Practices
- Run formal verification after every netlist transformation
- Keep RTL as golden reference (never modify)
- Document any manual mappings or assumptions
- Re-run after ECOs (Engineering Change Orders)
- Integrate into automated regression flow

