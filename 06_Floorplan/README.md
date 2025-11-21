# 06_Floorplan

## Overview
Floorplanning is the first physical design step where we define the chip's physical layout: die size, I/O pad placement, power grid, and macro placement. This establishes the foundation for successful place-and-route.

## Purpose
- Define die/core area dimensions
- Place I/O pads around periphery
- Plan power distribution grid
- Reserve space for standard cells
- Set placement blockages/halos
- Create initial DEF (Design Exchange Format) file

## Files in This Folder

### 1. `floorplan_constraints.tcl`
Floorplan setup script (for Innovus/ICC2):
- Define core area and die size
- Set aspect ratio and utilization
- Place I/O pads
- Create power rings and stripes
- Define placement blockages

### 2. `adder32_initial.def`
Initial DEF file with floorplan:
- Die size coordinates
- Core area definition
- I/O pad locations
- Row definitions for standard cells
- Track definitions for routing

## Inputs to This Step
From **04_Synthesis**:
- `adder32_netlist.v` - Gate-level netlist
- `adder32.sdc` - Timing constraints

Technology Files:
- LEF files (layer info, standard cells, pads)
- Technology file (.tf)

## Outputs from This Step
- **Initial DEF**: Physical layout starting point
- **Floorplan report**: Area, utilization, aspect ratio
- **Power plan**: Grid structure

Feeds into **07_Placement**.

## Block Diagram - Floorplan Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         INPUTS                                   │
├─────────────────────────────────────────────────────────────────┤
│  • Gate-level netlist (adder32_netlist.v)                        │
│  • Technology LEF files (.lef)                                   │
│  • Timing constraints (.sdc)                                     │
│  • Design requirements (area, power targets)                     │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                   FLOORPLANNING PHASE                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                  │
│  │ Calculate Area   │───▶│  Define Die &    │                  │
│  │ Requirements     │    │  Core Size       │                  │
│  └──────────────────┘    └────────┬─────────┘                  │
│                                   │                              │
│                                   ▼                              │
│                         ┌──────────────────┐                    │
│                         │  Set Aspect      │                    │
│                         │  Ratio & Margins │                    │
│                         └────────┬─────────┘                    │
│                                   │                              │
│                                   ▼                              │
│                         ┌──────────────────┐                    │
│                         │  Place I/O Pads  │                    │
│                         │  (Periphery)     │                    │
│                         └────────┬─────────┘                    │
│                                   │                              │
│                                   ▼                              │
│                         ┌──────────────────┐                    │
│                         │  Create Power    │                    │
│                         │  Grid (Rings &   │                    │
│                         │  Stripes)        │                    │
│                         └────────┬─────────┘                    │
│                                   │                              │
│                                   ▼                              │
│                         ┌──────────────────┐                    │
│                         │  Define Rows     │                    │
│                         │  for Std Cells   │                    │
│                         └────────┬─────────┘                    │
│                                   │                              │
│                                   ▼                              │
│                         ┌──────────────────┐                    │
│                         │  Write Initial   │                    │
│                         │  DEF File        │                    │
│                         └──────────────────┘                    │
│                                                                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                        OUTPUTS                                   │
├─────────────────────────────────────────────────────────────────┤
│  • adder32_initial.def → Initial physical layout                 │
│  • Floorplan metrics:                                            │
│    - Die size: 50µm × 50µm = 2500 µm²                            │
│    - Core area: 45µm × 45µm = 2025 µm²                           │
│    - Cell area: ~920 µm² (from synthesis)                        │
│    - Utilization: 45% (good for routing)                         │
│    - Aspect ratio: 1.0 (square)                                  │
│    - I/O pads: 68 (around periphery)                             │
│                                                                  │
│  Feeds into → 07_Placement (cell placement optimization)         │
└─────────────────────────────────────────────────────────────────┘
```

## Floorplan Parameters

| Parameter | Value | Reasoning |
|-----------|-------|-----------|
| Core Area | 45µm × 45µm | Fits ~920µm² cells + routing |
| Die Size | 50µm × 50µm | Core + 2.5µm I/O ring |
| Utilization | 45% | Leaves room for routing |
| Aspect Ratio | 1.0 | Square for balanced routing |
| Core-to-Die Margin | 2.5µm | Space for I/O pads |
| Row Height | Site height (typ. 0.2µm) | From std cell lib |
| Power Ring Width | 2µm | VDD/VSS rings |
| Power Stripe Width | 0.5µm | Internal grid |

## I/O Placement Strategy

For 32-bit adder (68 total I/O):
- **Left edge**: a[15:0] (16 inputs)
- **Bottom edge**: a[31:16] (16 inputs)
- **Right edge**: b[15:0] (16 inputs)
- **Top edge**: b[31:16] (16 inputs)
- **Corners**: clk, rst_n, carry_in, carry_out, overflow (control/status)

## Power Grid Structure

```
         VDD Ring
    ┌─────────────────┐
    │  ┌───────────┐  │ VDD Stripes
VSS │  │           │  │ (M4 vertical)
Ring│  │   CORE    │  │ 
    │  │           │  │ 
    │  └───────────┘  │
    └─────────────────┘
         VSS Ring

Power Layers:
- M1 (Metal-1): Standard cell power rails
- M3 (Metal-3): Horizontal stripes
- M4 (Metal-4): Vertical stripes
- M5 (Metal-5): Power rings (outer)
```

## Next Steps
After floorplan → **07_Placement**

