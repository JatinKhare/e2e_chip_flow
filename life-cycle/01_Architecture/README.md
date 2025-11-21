# 01_Architecture

## 🎯 What Is This Step?

The **Architecture phase** translates customer requirements into a high-level technical specification for the chip. This is where the fundamental decisions are made about what the chip will do, how fast it will be, how much power it will consume, and how large it will be.

**Duration**: 2-4 months  
**Team Size**: 5-50 architects depending on complexity  
**Output**: Architecture specification document, performance models, block diagrams

---

## 👥 Teams Involved

### Within Chip Company

1. **Chief Architect / Architecture Lead**
   - Defines overall vision
   - Makes PPA (Performance, Power, Area) trade-offs
   - Interface with customer executives

2. **Performance Architects**
   - Build performance models
   - Define instruction set (for CPUs)
   - Memory hierarchy design

3. **Power Architects**
   - Power budgeting
   - Power management strategy (DVFS, power gating)
   - Thermal analysis

4. **System Architects**
   - Interconnect design (NoC - Network-on-Chip)
   - I/O interfaces (PCIe, DDR, CXL)
   - System-level integration

5. **Security Architects**
   - Security features (encryption, secure boot)
   - Side-channel attack mitigation

### External Stakeholders

- **Customer Product Team**: Define use cases, workloads
- **Marketing**: Market positioning, competitive analysis
- **Sales**: Customer engagement, requirements gathering

---

## 🛠️ Tools Used

| Tool/Method | Vendor | Purpose |
|-------------|--------|---------|
| **gem5** | Open source | CPU performance simulation |
| **Internal Perf Models** | In-house (Python/C++) | Custom workload modeling |
| **McPAT / Wattch** | Academic | Power estimation |
| **Cacti** | HP Labs | Cache/memory power & area |
| **Excel / Python** | Microsoft / Open | Spreadsheet modeling |
| **MATLAB/Simulink** | MathWorks | Signal processing, analog/RF |
| **Visio / draw.io** | Microsoft / Open | Block diagrams |
| **SystemC** | Accellera | Transaction-level modeling (TLM) |

### Example Internal Tools (NVIDIA-like)
- **NVPerf**: Internal GPU performance simulator
- **PowerEstimator**: Spreadsheet-based power model
- **ArchSim**: Cycle-accurate architectural simulator

---

## 📥 Inputs to This Step

### 1. From Customer
- **Product Requirements Document (PRD)**
  - Target market (data center, mobile, automotive)
  - Key use cases (AI training, inference, gaming, HPC)
  - Performance targets (TOPS, FLOPS, bandwidth)
  - Power budget (TDP: Thermal Design Power)
  - Cost targets (BOM: Bill of Materials)
  
- **Competitive Benchmarks**
  - Competitor chips (AMD, Intel, ARM)
  - Performance comparison
  - Feature gaps

- **Workload Characterization**
  - Application traces
  - Memory access patterns
  - Compute intensity

### 2. From Technology / Foundry
- **Process Node Capabilities** (from TSMC/Samsung)
  - Available node: 7nm, 5nm, 3nm
  - Transistor density
  - Power characteristics (VDD, leakage)
  - Standard cell libraries (timing/power/area)
  
- **IP Availability**
  - Licensable IP cores (ARM Cortex, RISC-V)
  - Memory compilers (SRAM, register files)
  - Interface IP (PCIe, DDR PHY, SerDes)

### 3. From Previous Generation
- **Lessons Learned**
  - What worked well
  - Bottlenecks identified
  - Customer feedback

---

## 📤 Outputs / Deliverables

### 1. **Architecture Specification Document** (100-500 pages)
```markdown
Sections:
1. Executive Summary
2. Requirements & Constraints
3. High-Level Block Diagram
4. Performance Targets & Analysis
5. Power Budget & Strategy
6. Memory System Design
7. I/O and Interconnects
8. Security Features
9. Test & Debug Strategy
10. Risks & Mitigations
```

### 2. **Performance Models**
- **Spreadsheet models** (Excel with PPA analysis)
- **Simulators** (gem5 config, internal tools)
- **Benchmark results** (SPEC, MLPerf, etc.)

### 3. **Block Diagrams**
```
Example GPU Architecture (Simplified):

┌─────────────────────────────────────────────────────────────┐
│                     GPU DIE                                  │
│                                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ SM/CU 0  │  │ SM/CU 1  │  │ SM/CU 2  │  │ SM/CU 3  │   │
│  │ (Compute)│  │ (Compute)│  │ (Compute)│  │ (Compute)│   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
│       │             │             │             │           │
│       └─────────────┴─────────────┴─────────────┘           │
│                      │                                        │
│                      ▼                                        │
│              ┌───────────────┐                                │
│              │   L2 Cache    │                                │
│              │   (Shared)    │                                │
│              └───────┬───────┘                                │
│                      │                                        │
│                      ▼                                        │
│              ┌───────────────┐                                │
│              │ Memory        │                                │
│              │ Controllers   │                                │
│              │ (HBM/GDDR)    │                                │
│              └───────┬───────┘                                │
│                      │                                        │
│       ┌──────────────┼──────────────┐                         │
│       │              │              │                         │
│       ▼              ▼              ▼                         │
│   ┌──────┐      ┌──────┐      ┌──────┐                       │
│   │PCIe  │      │NVLink│      │Video │                       │
│   │Gen5  │      │      │      │Decode│                       │
│   └──────┘      └──────┘      └──────┘                       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 4. **PPA (Performance, Power, Area) Targets**
| Metric | Target | Rationale |
|--------|--------|-----------|
| Performance | 100 TOPS @ INT8 | 2× competitor |
| Power | 300W TDP | Fits standard cooling |
| Die Area | 800 mm² | Reticle limit |
| Memory BW | 2 TB/s | Feeds compute units |
| Clock Freq | 2.0 GHz | Process allows 2.5 GHz |
| Transistors | 70 Billion | Density: 87.5 MTr/mm² |

---

## 🔄 Communication & Collaboration

### With Customer (Weekly → Monthly)

**Week 1-2: Initial Requirements Gathering**
```
Customer → Chip Company
"We need 100 TOPS for our AI inference workload, 
 under 250W, launching in 24 months"

Chip Company → Customer
"What models will you run? Batch size? Precision?"

Customer → Chip Company
"ResNet-50, batch 64, INT8 quantization.
 We also need support for transformer models"
```

**Week 3-6: Architecture Proposal**
```
Chip Company → Customer
"Here's our proposed architecture:
 - 120 TOPS INT8 (20% headroom)
 - 280W TDP (conservative)
 - Tensor cores + programmable SMs
 - HBM3 memory for bandwidth"

Customer → Chip Company
"Looks good, but we need FP16 support too.
 What's the performance there?"

Chip Company → Customer (iterate)
"FP16: 60 TFLOPS. Here's the die photo annotation..."
```

**Month 2-3: Final Sign-off**
- Multiple review meetings
- Trade-off discussions (cost vs. performance)
- Contract finalization
- **Deliverable**: Signed Architecture Spec

### With Foundry (Less frequent at this stage)

- **PDK Request**: "We're designing in N5, need early access"
- **Technology Briefing**: Foundry presents node capabilities
- **IP Selection**: Choose standard cell libraries, memory compilers

### With RTL Team (Handoff at end)

- **Architecture Review**: Present block diagram, interfaces
- **Micro-architecture Workshops**: Detailed design discussions
- **Interface Specifications**: Define bus widths, protocols
- **Deliverable**: Architecture frozen → RTL design begins

---

## ⏱️ Timeline Breakdown

| Week | Activity | Participants | Output |
|------|----------|--------------|--------|
| 1-2 | Requirements gathering | Customer + Architects | Initial PRD |
| 3-4 | Competitive analysis | Architects + Marketing | Feature comparison |
| 5-8 | Performance modeling | Perf architects | Spreadsheet models |
| 9-10 | Architecture proposal | All architects | Block diagram v1 |
| 11-12 | Customer review #1 | Customer + Architects | Feedback |
| 13-14 | Architecture refinement | Architects | Updated design |
| 15-16 | Power/area analysis | Power/physical architects | PPA estimates |
| 17-18 | Customer review #2 | Customer + Architects | Final feedback |
| 19-20 | Specification writing | Lead architect + tech writers | Draft spec |
| 21-22 | Internal review | All design teams | Comments |
| 23-24 | Final sign-off | Executives + Customer | **Frozen spec** |

---

## 📊 Decision Framework Example

### Trade-off: Number of Compute Units

**Option A: 64 CUs (Conservative)**
- ✅ Easier to meet timing
- ✅ Lower power (240W)
- ✅ Smaller die (650 mm²)
- ❌ Performance: 80 TOPS (below target)

**Option B: 96 CUs (Aggressive)**
- ✅ Performance: 120 TOPS (meets target)
- ❌ Timing risk (may not close at 2 GHz)
- ❌ Power: 320W (over budget)
- ❌ Larger die (850 mm², near reticle limit)

**Decision: Option C - 80 CUs (Sweet Spot)**
- ✅ Performance: 100 TOPS (on target)
- ✅ Power: 280W (within budget with margin)
- ✅ Die area: 750 mm² (reasonable)
- ✅ Timing: Achievable at 2 GHz

*Rationale documented in arch spec section 4.3*

---

## ⚠️ Risks & Mitigation

### Risk 1: Performance Model Inaccuracy
- **Risk**: Spreadsheet over-optimistic, silicon under-performs
- **Impact**: Customer dissatisfaction, market loss
- **Mitigation**: 
  - Correlate with previous silicon
  - Conservative assumptions
  - Build detailed cycle-accurate simulator early
  - Plan for 10-15% margin

### Risk 2: Technology Node Delay
- **Risk**: TSMC N5 ramp delayed, affects schedule
- **Impact**: 6-12 month product delay
- **Mitigation**:
  - Dual-source (Samsung backup)
  - Design for N7 fallback option
  - Early engagement with foundry

### Risk 3: Requirements Creep
- **Risk**: Customer keeps adding features mid-design
- **Impact**: Schedule slip, complexity explosion
- **Mitigation**:
  - Strict change control process
  - Freeze architecture at month 3
  - "Nice-to-have" list for next generation

### Risk 4: Unrealistic PPA Targets
- **Risk**: Physics won't allow 300W @ 100 TOPS on 800mm² die
- **Impact**: Project failure, redesign required
- **Mitigation**:
  - Sanity checks with foundry data
  - Physical design early estimates
  - Conservative assumptions in models

---

## 📈 Success Criteria

| Criterion | Measurement | Target |
|-----------|-------------|--------|
| **Customer Sign-off** | Formal approval | By month 3 |
| **Performance Model** | Correlation to silicon | Within 10% |
| **Power Estimate** | Correlation to silicon | Within 15% |
| **Area Estimate** | Correlation to final GDS | Within 10% |
| **Schedule** | On-time handoff to RTL | Week 24 |
| **Completeness** | All interfaces defined | 100% |

---

## 🔄 Iteration Examples

### Iteration 1: Initial Proposal (Week 10)
```
Architect → Customer
"Proposed: 100 TOPS, 300W, 800mm²"

Customer → Architect
"Too expensive. Can you hit 650mm²?"

Architect (analysis) → Customer
"At 650mm²: 75 TOPS. Not enough for your workload."

Customer → Architect
"Ok, 750mm² acceptable if you hit 105 TOPS"
```

### Iteration 2: Memory System (Week 14)
```
Architect → Customer
"HBM3: 2TB/s bandwidth, but adds $200 to BOM"

Customer → Architect
"Can we use GDDR6X instead?"

Architect (analysis) → Customer
"GDDR6X: 1TB/s max. Your models will be memory-bound.
 Performance drops to 80 TOPS."

Customer → Architect
"HBM3 approved. Cost justified by performance."
```

---

## 📚 Key Documents Generated

1. **Architecture Specification** (`arch_spec_v1.0.pdf`)
2. **Performance Model** (`perf_model_vFinal.xlsx`)
3. **Power Budget** (`power_budget_breakdown.xlsx`)
4. **Block Diagram** (`top_level_block_diagram.vsdx`)
5. **Interface Spec** (`interface_specification.docx`)
6. **Risk Register** (`risks_and_mitigations.xlsx`)
7. **Customer Sign-off** (`customer_approval_email.pdf`)

---

## 🎓 Skills Required for Architecture Team

- **Technical**: Deep understanding of computer architecture, performance analysis
- **Analytical**: Mathematical modeling, statistics
- **Communication**: Present complex ideas simply to customers/executives
- **Tools**: Excel, Python, C++ (for simulators)
- **Domain Knowledge**: Specific to product (AI, graphics, networking, etc.)
- **Business Acumen**: Understand cost, schedule, market dynamics

---

## 🔗 Handoff to Next Phase

### To 02_Microarchitecture Team:
- **Deliverable**: Frozen architecture spec
- **Meeting**: Architecture handoff workshop (full day)
- **Ongoing**: Weekly sync meetings for clarifications
- **Expectation**: Microarch team creates detailed designs within architectural constraints

### Questions Microarch Will Ask:
- "How many pipeline stages for the ALU?"
- "What's the arbitration policy for the interconnect?"
- "Can we cache this data?"
- "What's the error handling strategy?"

**Architect's Job**: Answer these OR escalate back to customer if it changes requirements.

---

## 📊 Example Architecture Meeting Agenda

**Weekly Customer Sync (90 minutes)**

1. **Updates** (15 min)
   - Progress since last meeting
   - Any roadblocks
   
2. **Technical Deep-Dive** (45 min)
   - This week: Memory system design
   - Whiteboard session
   - Q&A
   
3. **Action Items Review** (15 min)
   - Customer: Provide workload traces
   - Architect: Run power analysis
   
4. **Schedule** (15 min)
   - On track for sign-off?
   - Any concerns?

---

## 🎯 Next Steps

Once architecture is frozen and signed off:
→ **02_Microarchitecture**: Detailed design of each block
→ **03_RTL_Design**: Implementation in SystemVerilog

**Critical**: No major architectural changes after sign-off. Only bug fixes or minor tweaks allowed.

---

**Remember**: Good architecture is the foundation of a successful chip. Mistakes here are expensive to fix later. Take the time to get it right!

