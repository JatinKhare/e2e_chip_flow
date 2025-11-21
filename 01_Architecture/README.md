# 01_Architecture

## Overview
This is the first step in the chip design flow where we define the high-level architecture, specifications, and requirements for our 32-bit adder design. This phase establishes the foundation for all subsequent design steps.

## Purpose
- Define the functional requirements of the 32-bit adder
- Establish timing constraints and performance targets
- Set power consumption goals
- Create a high-level block diagram
- Document interfaces and protocols

## Files in This Folder

### 1. `adder_spec.md`
Complete functional specification document describing:
- Adder architecture (ripple-carry, carry-lookahead, etc.)
- Input/output interfaces
- Functional behavior
- Performance requirements

### 2. `timing_targets.xlsx`
Spreadsheet (placeholder) containing:
- Target clock frequency
- Setup and hold time requirements
- Maximum path delays
- Clock-to-Q delays

### 3. `power_targets.xlsx`
Spreadsheet (placeholder) with:
- Maximum dynamic power consumption
- Leakage power budgets
- Power modes and specifications

### 4. `block_diagram.txt`
ASCII representation of the adder architecture showing:
- Input/output ports
- Major functional blocks
- Data flow

## Inputs to This Step
- Product requirements document (PRD)
- Market analysis and use-case scenarios
- Technology node specifications (e.g., 28nm, 7nm)
- Manufacturing constraints

## Outputs from This Step
- Functional specification
- Timing requirements (clock frequency, delays)
- Power budgets
- Area constraints
- Block diagram and micro-architecture

## Block Diagram - Architecture Phase Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         INPUTS                                   │
├─────────────────────────────────────────────────────────────────┤
│  • Product Requirements Document (PRD)                           │
│  • Technology Node Specs (28nm/7nm/etc)                          │
│  • Market Analysis & Use Cases                                   │
│  • Manufacturing Constraints                                     │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│              ARCHITECTURE DEFINITION PHASE                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                  │
│  │  Functional      │    │   Performance    │                  │
│  │  Specification   │───▶│   Analysis       │                  │
│  └──────────────────┘    └──────────────────┘                  │
│           │                        │                             │
│           ▼                        ▼                             │
│  ┌──────────────────┐    ┌──────────────────┐                  │
│  │  Micro-          │    │   Power/Timing   │                  │
│  │  Architecture    │◀───│   Budgeting      │                  │
│  └──────────────────┘    └──────────────────┘                  │
│           │                        │                             │
│           └────────┬───────────────┘                             │
│                    ▼                                             │
│           ┌─────────────────┐                                   │
│           │  Block Diagram  │                                   │
│           │   & Interface   │                                   │
│           │  Specification  │                                   │
│           └─────────────────┘                                   │
│                                                                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                        OUTPUTS                                   │
├─────────────────────────────────────────────────────────────────┤
│  • adder_spec.md        → Functional specification               │
│  • timing_targets.xlsx  → Clock freq, delays, timing margins     │
│  • power_targets.xlsx   → Power budgets for each power mode      │
│  • block_diagram.txt    → High-level architecture diagram        │
│                                                                  │
│  These outputs feed into: 02_RTL (Design Implementation)         │
└─────────────────────────────────────────────────────────────────┘
```

## Next Step
Once the architecture is defined and documented, proceed to:
**02_RTL** - RTL Design and Implementation

The RTL team will use these specifications to implement the actual hardware description in SystemVerilog.

