# 02_RTL

## Overview
This is the RTL (Register Transfer Level) design phase where we implement the 32-bit adder architecture in hardware description language (SystemVerilog). This phase translates the architectural specification into synthesizable code.

## Purpose
- Implement the adder design in SystemVerilog HDL
- Create modular, maintainable, and synthesizable code
- Define all interfaces, packages, and hierarchy
- Ensure coding standards and best practices
- Prepare design for verification and synthesis

## Files in This Folder

### 1. `adder32.sv`
Main RTL module implementing the 32-bit adder:
- Full adder cell implementation
- 32-bit ripple-carry chain
- Overflow detection logic
- Registered inputs/outputs

### 2. `adder_pkg.sv`
SystemVerilog package containing:
- Parameter definitions
- Type definitions
- Constants and enumerations
- Reusable functions

### 3. `top.sv`
Top-level wrapper module:
- Instantiates adder32 module
- Handles clock and reset
- Interface buffering
- Optional debug signals

## Inputs to This Step
From **01_Architecture**:
- `adder_spec.md` - Functional specifications
- `timing_targets.xlsx` - Timing requirements
- `power_targets.xlsx` - Power constraints
- `block_diagram.txt` - Architecture diagram

## Outputs from This Step
RTL source files ready for:
- **03_Verification** - Testbench development and simulation
- **04_Synthesis** - Logic synthesis
- **05_Formal_Verification** - Equivalence checking

## Block Diagram - RTL Design Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         INPUTS                                   │
├─────────────────────────────────────────────────────────────────┤
│  From 01_Architecture:                                           │
│    • adder_spec.md (Functional requirements)                     │
│    • timing_targets.xlsx (Clock freq: 100MHz, delays)            │
│    • power_targets.xlsx (Power budget: <1mW)                     │
│    • block_diagram.txt (Architecture structure)                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                   RTL DESIGN PHASE                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                  │
│  │   Package        │    │   Full Adder     │                  │
│  │  Definition      │───▶│  Cell Design     │                  │
│  │ (adder_pkg.sv)   │    │                  │                  │
│  └──────────────────┘    └──────────────────┘                  │
│           │                        │                             │
│           │                        ▼                             │
│           │              ┌──────────────────┐                   │
│           │              │   32-bit Adder   │                   │
│           └─────────────▶│   Implementation │                   │
│                          │  (adder32.sv)    │                   │
│                          └──────────────────┘                   │
│                                    │                             │
│                                    ▼                             │
│                          ┌──────────────────┐                   │
│                          │   Top-level      │                   │
│                          │   Integration    │                   │
│                          │   (top.sv)       │                   │
│                          └──────────────────┘                   │
│                                                                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                        OUTPUTS                                   │
├─────────────────────────────────────────────────────────────────┤
│  • adder_pkg.sv        → Package with parameters and types       │
│  • adder32.sv          → Main 32-bit adder RTL module            │
│  • top.sv              → Top-level wrapper                       │
│                                                                  │
│  Characteristics:                                                │
│    - Synthesizable SystemVerilog                                 │
│    - Lint-clean (no warnings)                                    │
│    - Coding guidelines compliant                                 │
│    - Self-documenting with comments                              │
│                                                                  │
│  These outputs feed into:                                        │
│    → 03_Verification (for testbench development)                 │
│    → 04_Synthesis (for logic synthesis)                          │
│    → 05_Formal_Verification (for equivalence checking)           │
└─────────────────────────────────────────────────────────────────┘
```

## RTL Design Principles Applied

### 1. **Modularity**
- Separate package for reusable definitions
- Hierarchical design (full adder → 32-bit adder → top)
- Clear module boundaries

### 2. **Synthesizability**
- Only synthesizable constructs used
- Synchronous reset
- No race conditions
- Clock gating ready

### 3. **Readability**
- Consistent naming conventions
- Comprehensive comments
- Self-documenting code
- Parameter-driven design

### 4. **Verification-Friendly**
- Clear input/output interfaces
- Assertion-ready structure
- Observable internal signals (for debug)

## Coding Standards Followed

| Aspect | Standard |
|--------|----------|
| Language | SystemVerilog (IEEE 1800-2017) |
| File Extension | `.sv` |
| Naming | snake_case for signals, PascalCase for modules |
| Indentation | 2 spaces |
| Line Length | Max 100 characters |
| Comments | Inline for complex logic, header for modules |
| Reset | Synchronous, active-low (`rst_n`) |
| Clock | Single clock domain |

## Design Hierarchy

```
top (top-level wrapper)
 │
 └── adder32 (main adder implementation)
      │
      ├── full_adder [×32] (individual FA cells)
      └── overflow_detect (overflow logic)
```

## Key Design Decisions

### 1. **Ripple-Carry vs. Carry-Lookahead**
- **Choice**: Ripple-carry
- **Rationale**: Simpler, smaller area, meets timing @ 100MHz
- **Trade-off**: Slower than CLA but adequate for requirements

### 2. **Registered vs. Combinational**
- **Choice**: Registered inputs and outputs
- **Rationale**: Easier timing closure, better testability
- **Trade-off**: 1-cycle latency vs. combinational adder

### 3. **Parameterization**
- **Choice**: WIDTH parameter for scalability
- **Rationale**: Reusable for 16-bit, 64-bit variants
- **Benefit**: Design can be easily adapted

## RTL Quality Metrics

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Lint Errors | 0 | 0 | ✓ PASS |
| Lint Warnings | 0 | 0 | ✓ PASS |
| Code Coverage | - | - | N/A (verification phase) |
| Synthesis Warnings | <5 | TBD | Pending |
| Lines of Code | <500 | ~250 | ✓ PASS |

## Next Steps
Once RTL design is complete, proceed to:
1. **03_Verification** - Create testbench and run simulations
2. **04_Synthesis** - Synthesize to gate-level netlist
3. **05_Formal_Verification** - Prove equivalence

## Tool Requirements
- **Simulator**: VCS, Questa, or Xcelium
- **Linter**: Spyglass or Questa Lint
- **Editor**: Any text editor with SystemVerilog syntax highlighting
- **Version Control**: Git (recommended)

