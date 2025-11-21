# 03_Verification

## Overview
This is the functional verification phase where we validate that the RTL design meets all specifications through simulation-based testing. We create testbenches, test vectors, and run simulations to ensure correctness.

## Purpose
- Verify functional correctness of the RTL design
- Test corner cases and boundary conditions
- Achieve comprehensive functional coverage
- Identify and fix bugs before synthesis
- Generate waveforms for debug and analysis

## Files in This Folder

### 1. `tb_adder32.sv`
SystemVerilog testbench for the 32-bit adder:
- Self-checking testbench with assertions
- Random and directed test generation
- Coverage collection
- Result checking and reporting

### 2. `test_vectors.hex`
Pre-defined test vectors in hexadecimal format:
- Corner cases (all 0s, all 1s, etc.)
- Known answer tests
- Overflow conditions
- Carry propagation tests

### 3. `run_sim.sh`
Simulation script to:
- Compile RTL and testbench
- Run simulation with different seeds
- Generate coverage reports
- Create waveform databases

### 4. `waves/adder.vcd`
Waveform dump file (placeholder):
- Value Change Dump (VCD) format
- Contains signal transitions
- Used for debug in waveform viewers (GTKWave, Verdi, etc.)

## Inputs to This Step
From **02_RTL**:
- `adder_pkg.sv` - Package definitions
- `adder32.sv` - Main adder RTL
- `top.sv` - Top-level wrapper

From **01_Architecture**:
- `adder_spec.md` - Functional requirements for test planning

## Outputs from This Step
- **Simulation logs**: Pass/fail status, coverage metrics
- **Waveform files**: For debug and analysis (VCD/FSDB/WLF)
- **Coverage reports**: Functional and code coverage
- **Bug reports**: Issues found during verification
- **Sign-off report**: Verification completion status

These outputs feed into:
- **04_Synthesis** - Confidence to proceed with synthesis
- **05_Formal_Verification** - Reference behavior for equivalence

## Block Diagram - Verification Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         INPUTS                                   │
├─────────────────────────────────────────────────────────────────┤
│  From 02_RTL:                                                    │
│    • adder_pkg.sv (Package definitions)                          │
│    • adder32.sv (Main RTL module)                                │
│    • top.sv (Top-level wrapper)                                  │
│                                                                  │
│  From 01_Architecture:                                           │
│    • adder_spec.md (Functional requirements)                     │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                   VERIFICATION PHASE                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                  │
│  │  Test Plan       │    │   Testbench      │                  │
│  │  Development     │───▶│   Development    │                  │
│  │                  │    │ (tb_adder32.sv)  │                  │
│  └──────────────────┘    └────────┬─────────┘                  │
│                                   │                              │
│                                   ▼                              │
│                         ┌──────────────────┐                    │
│                         │  Test Vector     │                    │
│                         │  Generation      │                    │
│                         │ (test_vectors)   │                    │
│                         └────────┬─────────┘                    │
│                                   │                              │
│                                   ▼                              │
│  ┌──────────────────┐    ┌──────────────────┐                  │
│  │  RTL + TB        │───▶│   Simulation     │                  │
│  │  Compilation     │    │   Execution      │                  │
│  └──────────────────┘    └────────┬─────────┘                  │
│                                   │                              │
│                                   ▼                              │
│                         ┌──────────────────┐                    │
│                         │  Coverage        │                    │
│                         │  Analysis        │                    │
│                         └────────┬─────────┘                    │
│                                   │                              │
│                                   ▼                              │
│                         ┌──────────────────┐                    │
│                         │  Debug &         │                    │
│                         │  Waveform        │                    │
│                         │  Analysis        │                    │
│                         └──────────────────┘                    │
│                                                                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                        OUTPUTS                                   │
├─────────────────────────────────────────────────────────────────┤
│  • Simulation Logs      → Pass/Fail status, error messages      │
│  • Coverage Reports     → Functional/Code coverage metrics       │
│  • Waveform Files       → VCD/FSDB for debugging                 │
│  • Bug Reports          → Issues found during testing            │
│  • Verification Sign-off → Approval to proceed to synthesis     │
│                                                                  │
│  Metrics:                                                        │
│    - Code Coverage: >95% (target: 100%)                          │
│    - Functional Coverage: >90%                                   │
│    - Tests Passed: 1000/1000                                     │
│    - Bugs Found: 0 (all fixed)                                   │
│                                                                  │
│  These outputs enable:                                           │
│    → 04_Synthesis (proceed with confidence)                      │
│    → 05_Formal_Verification (reference golden model)             │
└─────────────────────────────────────────────────────────────────┘
```

## Verification Strategy

### 1. **Directed Testing**
- Test specific scenarios from specification
- Corner cases: all 0s, all 1s, max values
- Overflow conditions
- Carry chain propagation

### 2. **Random Testing**
- Constrained random stimulus generation
- Large number of test iterations
- Uncover unexpected corner cases

### 3. **Coverage-Driven Verification**
- Define coverage goals
- Track code coverage (line, branch, toggle)
- Track functional coverage (operations, conditions)
- Iterate until goals are met

### 4. **Assertion-Based Verification**
- Embedded assertions in RTL (SVA)
- Check for protocol violations
- Verify invariants and properties

## Test Categories

| Category | Description | # Tests | Priority |
|----------|-------------|---------|----------|
| Basic Operations | Simple additions | 100 | HIGH |
| Corner Cases | Boundary values (0, MAX, etc.) | 50 | HIGH |
| Carry Propagation | Full carry chain tests | 100 | HIGH |
| Overflow Detection | Signed overflow scenarios | 50 | HIGH |
| Random Tests | Constrained random | 500 | MEDIUM |
| Regression | Previous bug scenarios | 20 | HIGH |
| Performance | Throughput, latency checks | 10 | LOW |

## Coverage Goals

| Metric | Target | Achieved | Status |
|--------|--------|----------|--------|
| Code Coverage (Line) | 100% | TBD | Pending |
| Code Coverage (Branch) | 100% | TBD | Pending |
| Toggle Coverage | 95% | TBD | Pending |
| Functional Coverage | 90% | TBD | Pending |
| Assertion Pass Rate | 100% | TBD | Pending |

## Simulation Environment

### Tools Required
- **Simulator**: VCS (recommended) / Questa / Xcelium
- **Waveform Viewer**: Verdi / DVE / GTKWave
- **Coverage Tool**: IMC / UCDB analyzer
- **Build System**: Make / Shell scripts

### Simulation Flow
```
1. Compile: vcs -sverilog -full64 +v2k *.sv
2. Elaborate: ./simv +ntb_random_seed=123
3. Run: Monitor console for pass/fail
4. Check Coverage: urg -dir simv.vdb
5. Debug: verdi -ssf dump.fsdb (if failures)
```

## Exit Criteria

Verification is complete when:
- ✓ All directed tests pass
- ✓ 1000+ random tests pass without failures
- ✓ Code coverage > 95%
- ✓ Functional coverage > 90%
- ✓ All assertions pass
- ✓ No outstanding critical bugs
- ✓ Waveform review shows correct behavior
- ✓ Performance meets timing requirements (cycle count)

## Known Issues / Limitations
- Initial simulation may show X-propagation warnings (harmless)
- Long carry chains take time to stabilize
- Coverage may not reach 100% due to unreachable states

## Next Steps
After verification sign-off:
1. **04_Synthesis** - Synthesize RTL to gate-level netlist
2. **05_Formal_Verification** - Formal equivalence check
3. Document any waivers for coverage holes

