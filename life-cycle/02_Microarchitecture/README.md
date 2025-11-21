# 02_Microarchitecture

## 🎯 What Is This Step?

**Microarchitecture** is the detailed design of how each functional block works internally. While architecture defines *what* the chip does, microarchitecture defines *how* it does it - pipeline stages, data paths, control logic, timing diagrams, and cycle-by-cycle behavior.

**Duration**: 2-4 months (overlaps with architecture)  
**Team Size**: 10-50 microarchitects  
**Output**: Detailed block specifications, pipeline diagrams, control flow, microarchitectural simulators

---

## 👥 Teams Involved

### Core Microarchitecture Team

1. **Microarchitecture Lead**
   - Owns overall microarch coherence
   - Resolves conflicts between blocks
   - Reviews all detailed designs

2. **Compute Block Microarchitects**
   - ALU pipeline design
   - Register file organization
   - Instruction decode logic

3. **Memory Microarchitects**
   - Cache organization (sets, ways, replacement policy)
   - TLB design
   - Prefetcher algorithms

4. **Interconnect Microarchitects**
   - Crossbar design
   - Arbitration policies
   - Flow control

5. **Control Microarchitects**
   - FSM (Finite State Machine) design
   - Sequencer logic
   - Exception/interrupt handling

### Collaboration

- **Architecture Team**: Ensure microarch meets architectural intent
- **RTL Team**: Prepare for implementation
- **Verification Team**: Understand what to test
- **Physical Design**: Early floorplan discussions

---

## 🛠️ Tools & Methods

| Tool/Method | Purpose | Example |
|-------------|---------|---------|
| **Excel / Google Sheets** | Pipeline spreadsheets, timing analysis | Track 20-stage pipeline |
| **Visio / draw.io / Lucidchart** | Block diagrams, FSM diagrams | State machine visuals |
| **Python / MATLAB** | Algorithm prototyping | Cache replacement policy simulation |
| **SystemC / TLM** | Transaction-level modeling | High-level functional model |
| **C++ Reference Model** | Golden reference | Bit-accurate behavioral model |
| **Confluence / Notion** | Documentation | Wiki for specifications |
| **Waveform tools** | Timing diagrams | GTKWave,WaveDrom for cycle diagrams |

### Internal Custom Tools
- Microarch simulators (cycle-accurate models)
- Pipeline visualizers
- Power calculators

---

## 📥 Inputs

### 1. From 01_Architecture
- **Architecture Specification**
  - Block diagram
  - Interface definitions
  - PPA targets
  
- **Performance Requirements**
  - Throughput: Operations per cycle
  - Latency: Cycles for operation completion
  - Bandwidth: Data movement requirements

### 2. From Process Technology
- **Standard Cell Library Info**
  - Adder delay: 0.25ns
  - Multiplier delay: 0.8ns
  - Register delay: 0.15ns
  - Wire delay estimates
  
- **Clock Target**
  - 2.0 GHz (0.5ns period)
  - Determines pipeline depth

### 3. From Verification Team
- **Testability Requirements**
  - Observable points needed
  - Controllability for debug

---

## 📤 Outputs / Deliverables

### 1. **Microarchitecture Specification Document**

**Contents** (200-1000 pages total):
```
For each major block:
1. Purpose & Requirements
2. Interface Definition (inputs/outputs, protocols)
3. Internal Organization
4. Pipeline Diagram (cycle-by-cycle behavior)
5. Control Logic (FSMs, sequencers)
6. Data Path Diagram
7. Timing Analysis
8. Power Estimation
9. Area Estimation
10. Dependencies & Risks
```

### 2. **Pipeline Diagrams**

Example: 5-Stage Integer Pipeline
```
Cycle:    1     2     3     4     5     6     7     8     9
        ┌─────────────────────────────────────────────────────┐
Inst A  │ IF │ ID │ EX │ MEM│ WB │                            │
        └─────────────────────────────────────────────────────┘
Inst B       │ IF │ ID │ EX │ MEM│ WB │
             └─────────────────────────────────────────────────┘
Inst C            │ IF │ ID │ EX │ MEM│ WB │
                  └─────────────────────────────────────────────┘

Legend:
  IF  = Instruction Fetch
  ID  = Instruction Decode / Register Read
  EX  = Execute (ALU operation)
  MEM = Memory Access
  WB  = Write Back to Register File
  
Pipeline Depth: 5 stages
Throughput: 1 instruction per cycle (ideal)
Latency: 5 cycles for one instruction
```

### 3. **Detailed Block Diagrams**

Example: Cache Controller Microarchitecture
```
┌──────────────────────────────────────────────────────────────┐
│                   L1 Cache Controller                         │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────┐         ┌─────────────┐                     │
│  │   Tag       │         │   Data      │                     │
│  │   Array     │         │   Array     │                     │
│  │  (8KB SRAM) │         │ (64KB SRAM) │                     │
│  └──────┬──────┘         └──────┬──────┘                     │
│         │                       │                             │
│         └───────┬───────────────┘                             │
│                 │                                             │
│                 ▼                                             │
│         ┌───────────────┐                                     │
│         │  Comparator   │─────▶ Hit/Miss                     │
│         │   Logic       │                                     │
│         └───────────────┘                                     │
│                 │                                             │
│                 ▼                                             │
│       ┌──────────────────┐                                   │
│       │ Replacement      │                                   │
│       │ Policy (LRU)     │                                   │
│       └──────────────────┘                                   │
│                 │                                             │
│                 ▼                                             │
│       ┌──────────────────┐                                   │
│       │ MSHR (Miss       │◀──────▶ L2 Cache                  │
│       │ Status Holding   │                                   │
│       │ Registers)       │                                   │
│       └──────────────────┘                                   │
│                                                               │
│  Parameters:                                                  │
│    - Size: 64KB                                               │
│    - Associativity: 8-way set associative                     │
│    - Line size: 64 bytes                                      │
│    - Latency: 4 cycles (hit)                                  │
│    - MSHR entries: 8                                          │
│    - Replacement: Pseudo-LRU                                  │
└──────────────────────────────────────────────────────────────┘
```

### 4. **FSM (Finite State Machine) Diagrams**

Example: Cache Miss Handler
```
       ┌─────────┐
       │  IDLE   │◀─────────────────────────────┐
       └────┬────┘                               │
            │ Cache Miss                         │
            ▼                                    │
       ┌─────────┐                               │
       │ALLOCATE │ Allocate MSHR entry           │
       │  MSHR   │                               │
       └────┬────┘                               │
            │                                    │
            ▼                                    │
       ┌─────────┐                               │
       │ REQUEST │ Send request to L2            │
       │   L2    │                               │
       └────┬────┘                               │
            │                                    │
            ▼                                    │
       ┌─────────┐                               │
       │  WAIT   │ Wait for L2 response          │
       │   ACK   │                               │
       └────┬────┘                               │
            │ L2 Response                        │
            ▼                                    │
       ┌─────────┐                               │
       │  FILL   │ Write data to cache           │
       │  LINE   │                               │
       └────┬────┘                               │
            │                                    │
            ▼                                    │
       ┌─────────┐                               │
       │ UPDATE  │ Update LRU, clear MSHR        │
       │  STATE  │                               │
       └────┬────┘                               │
            │                                    │
            └────────────────────────────────────┘
```

### 5. **Cycle-by-Cycle Timing**

Example: Load Instruction Timing
```
Cycle  │ Action
───────┼────────────────────────────────────────────────
   0   │ Instruction fetch begins
   1   │ Instruction decode, register address generation
   2   │ Address calculation (base + offset)
   3   │ TLB lookup for virtual-to-physical translation
   4   │ Cache tag comparison
   5   │ Data array access (if hit)
   6   │ Data alignment and sign extension
   7   │ Write back to register file
───────┴────────────────────────────────────────────────
Total: 7 cycles for load (hit case)
Miss case: +20 cycles to fetch from L2
```

---

## 🔄 Communication & Collaboration

### With Architecture Team (Daily → Weekly)

**Scenario: Pipeline Depth Decision**
```
Microarch → Architect
"To meet 2 GHz, we need 8-stage multiply pipeline.
 This increases latency from 3 to 8 cycles."

Architect → Microarch
"What's the performance impact on our key workloads?"

Microarch (analysis) → Architect
"AI inference: -2% (multiplies are back-to-back)
 Gaming: -0.5% (multiplies well distributed)
 Decision: Acceptable. Proceed with 8-stage."

Architect → Customer (FYI)
"Minor performance impact due to timing closure. 
 Within margin."
```

### With RTL Team (Weekly)

**Interface Definition**
```
Microarch → RTL
"Cache controller interface specification:
 - Request: {valid, addr[31:0], size[2:0], type[1:0]}
 - Response: {ready, data[511:0], hit}
 - Protocol: Valid-ready handshake"

RTL → Microarch
"What happens if ready is low?"

Microarch → RTL
"Requester must hold valid high and repeat request.
 See section 5.3 of spec for detailed protocol."
```

### With Verification Team (Weekly)

```
Verification → Microarch
"How do we test the corner case where MSHR is full?"

Microarch → Verification
"Generate 9 simultaneous cache misses (we have 8 MSHRs).
 Expected: 9th request stalls until an MSHR frees up."

Verification → Microarch
"What's the timeout value? How do we know it's not hung?"

Microarch → Verification
"Max L2 response time: 100 cycles. 
 Add watchdog timer check in testbench."
```

---

## ⏱️ Timeline & Milestones

| Week | Milestone | Deliverable |
|------|-----------|-------------|
| 1-2 | Block decomposition | List of all blocks to design |
| 3-4 | Interface definition | All inter-block protocols defined |
| 5-8 | Pipeline design | Cycle-by-cycle timing for major paths |
| 9-10 | FSM design | State machine diagrams |
| 11-12 | Control logic | Sequencer designs |
| 13-14 | Review #1 | Present to architecture team |
| 15-16 | Refinements | Address feedback |
| 17-18 | Documentation | Write detailed specs |
| 19-20 | RTL handoff | Transfer knowledge to RTL team |

---

## 📊 Example Microarchitecture Decisions

### Decision 1: Cache Associativity

**Options**:
- **4-way**: Smaller, faster access, higher miss rate
- **8-way**: Balanced
- **16-way**: Larger, slower access, lower miss rate

**Analysis**:
| Metric | 4-way | 8-way | 16-way |
|--------|-------|-------|--------|
| Miss Rate | 8.5% | 6.2% | 5.9% |
| Access Time | 3 cycles | 4 cycles | 5 cycles |
| Area | 60 KB | 68 KB | 84 KB |
| Performance Impact | Baseline | +3% | +2% |

**Decision**: 8-way (best perf/area trade-off)

### Decision 2: Register File Ports

**Options**:
- **2 Read, 1 Write**: Simple, limits IPC
- **3 Read, 2 Write**: Balanced
- **4 Read, 2 Write**: More parallel, larger area

**Analysis**:
- Instruction mix shows 70% operations need 2 source registers
- 30% need 3 sources (e.g., multiply-accumulate)
- Dual-issue pipeline requires 2 writes/cycle

**Decision**: 4 Read, 2 Write (enables dual-issue)

---

## ⚠️ Risks & Mitigation

### Risk 1: Timing Closure Failure
- **Risk**: Microarch assumes 0.5ns clock, but RTL can't close timing
- **Impact**: Performance target miss, must reduce frequency
- **Mitigation**:
  - Conservative timing assumptions
  - Add pipeline stage if needed (designed in advance)
  - Early synthesis runs to validate

### Risk 2: Complexity Explosion
- **Risk**: Detailed design reveals exponential complexity
- **Impact**: Schedule slip, bugs, area growth
- **Mitigation**:
  - Simplify where possible
  - Reuse proven designs
  - Modular approach

### Risk 3: Interface Mismatch
- **Risk**: Blocks designed in isolation don't integrate
- **Impact**: RTL integration failures, rework
- **Mitigation**:
  - Rigorous interface reviews
  - Interface specification document
  - Early integration simulations

### Risk 4: Power Overshoot
- **Risk**: Detailed design exceeds power budget
- **Impact**: Must redesign blocks, schedule slip
- **Mitigation**:
  - Track power at each decision
  - Power review at every milestone
  - Have lower-power fallback options

---

## 📈 Metrics & Analysis

### Performance Analysis

**Instruction Mix** (from workload analysis):
```
Instruction Type   │ Frequency │ Latency │ Impact
──────────────────┼───────────┼─────────┼────────
Integer ALU        │ 40%       │ 1 cycle │ 0.40
Load/Store         │ 25%       │ 4 cycle │ 1.00
Multiply           │ 15%       │ 8 cycle │ 1.20
Branch             │ 15%       │ 1 cycle │ 0.15
FP Operations      │ 5%        │ 6 cycle │ 0.30
──────────────────┴───────────┴─────────┴────────
Average CPI (Cycles Per Instruction): 3.05
IPC (Instructions Per Cycle): 0.33
```

**With Optimizations**:
- Out-of-order execution: IPC → 1.2
- Dual-issue: IPC → 1.8
- Speculation: IPC → 2.1

### Power Analysis

```
Block              │ Activity │ Power (mW) │ % Total
──────────────────┼──────────┼────────────┼────────
Register File      │ 80%      │ 45         │ 15%
ALU Units          │ 40%      │ 60         │ 20%
L1 Cache           │ 50%      │ 40         │ 13%
L2 Cache           │ 30%      │ 35         │ 12%
Control Logic      │ 100%     │ 25         │ 8%
Clock Network      │ 100%     │ 50         │ 17%
Interconnect       │ 40%      │ 30         │ 10%
Leakage (all)      │ 100%     │ 15         │ 5%
──────────────────┴──────────┴────────────┴────────
TOTAL                         │ 300        │ 100%
```

---

## 📚 Deliverable Examples

### 1. Interface Specification Template
```verilog
// INTERFACE: Compute Unit to L1 Cache
// Protocol: Ready-valid handshake
// Latency: 4 cycles (hit), 20+ cycles (miss)

// Request
logic        req_valid;    // Initiator asserts when request ready
logic [31:0] req_addr;     // Physical address
logic [2:0]  req_size;     // 0=byte, 1=half, 2=word, 3=double
logic        req_type;     // 0=read, 1=write
logic [63:0] req_data;     // Write data (valid only if req_type=1)
logic        req_ready;    // Cache asserts when can accept request

// Response
logic        resp_valid;   // Cache asserts when data ready
logic [63:0] resp_data;    // Read data
logic        resp_error;   // 1=error occurred (e.g., ECC)
logic        resp_ready;   // Initiator asserts when can accept response

// Timing: req_valid → resp_valid: 4 cycles (hit), 20+ (miss)
```

### 2. Performance Spreadsheet
```
Workload: ResNet-50 Inference
Batch Size: 64

Layer Type  │ Operations │ Cycles │ Time (ms) │ % Total
────────────┼────────────┼────────┼───────────┼────────
Conv2D      │ 1.8 B      │ 900 M  │ 0.45      │ 60%
ReLU        │ 0.5 B      │ 50 M   │ 0.025     │ 3%
MaxPool     │ 0.2 B      │ 100 M  │ 0.05      │ 7%
BatchNorm   │ 0.4 B      │ 200 M  │ 0.1       │ 13%
FC Layer    │ 0.3 B      │ 150 M  │ 0.075     │ 10%
Overhead    │ -          │ 100 M  │ 0.05      │ 7%
────────────┴────────────┴────────┴───────────┴────────
TOTAL                    │ 1.5 B  │ 0.75      │ 100%

Throughput: 85 images/second (target: 80) ✓
```

---

## 🎓 Skills Required

- **Deep Technical Knowledge**: Computer architecture, digital design
- **Analytical**: Performance modeling, optimization
- **Attention to Detail**: Every cycle, every bit matters
- **Communication**: Explain complex designs clearly
- **Tools**: Excel, Python, waveform viewers, diagram tools
- **Creativity**: Solve problems within constraints

---

## 🔗 Handoff to 03_RTL_Design

### Deliverables for RTL Team:
1. ✅ Complete microarchitecture spec (all blocks)
2. ✅ Interface definitions (protocols, timing)
3. ✅ Cycle-accurate behavioral models (C++/SystemC)
4. ✅ Test plans (what to verify)
5. ✅ Known limitations and assumptions

### Handoff Meeting (Full Day Workshop):
- **Morning**: Overview of overall design
- **Afternoon**: Deep-dives into each major block
- **Q&A**: RTL team asks clarifying questions
- **Ongoing**: Weekly design review meetings

### What RTL Team Does Next:
- Implement microarch spec in SystemVerilog
- Ask questions when ambiguous
- Propose optimizations (with microarch approval)

---

**Next**: **03_RTL_Design** - Turning specifications into actual hardware code!

