# Wyckoff VSA Performance Runtime v0.2 — Native Equivalence Protocol

**Status:** PRE-NATIVE-TEST  
**Target:** AmiBroker 6.20.01  
**Formula under test:** `afl/WyckoffVSA_PerformanceRuntime_CompatibilityHarness_v0.2.afl`  
**Baseline:** current native-accepted v0.1 Market Scanner decision surface after MS41.

## 1. Purpose

This protocol is the first native gate for Performance Runtime v0.2. It does **not** test persistent snapshots yet. It verifies that:

1. the new centralized Parameter namespace can coexist with the exact v0.1 analytical stack;
2. P&F can be deferred without changing Market Scanner decision outputs;
3. the v0.2 compatibility guard fails closed when effective v0.2 and legacy settings do not match;
4. under equivalent configuration, the decision surface for the known DTP/FRT/SNZ cases is identical to the accepted v0.1 baseline.

No result difference is acceptable unless separately approved through the PER02 correctness-correction process.

## 2. Harness architecture

The harness loads:

`RuntimeConfig v0.2 → exact v0.1 stack through Market Scanner → configuration-equivalence guard → compact output`.

It deliberately does not include the P&F stack because current Scanner Candidate Class is upstream of P&F.

No canonical analytical engine is modified by this test.

## 3. Required configuration

Use Daily periodicity and one recent bar for the same database state used by the accepted MS41 native cases.

### v0.2 controls

- `1.1 Runtime Profile = 0 DAILY FAST SCAN`
- `1.2 Production Filter = 4 All Eligible` for this equivalence test
- `1.3 Treat Last Bar As Provisional = No`
- `2.1/2.2/2.3 = 20/20/14`
- `2.4/2.5/2.6/2.7 = 1.80/0.75/0.35/0.80`
- `3.1/3.2/3.3 = 20/60/120`
- `3.4/3.5 = 3/3`
- `6.1 Market Benchmark = VNINDEX`
- `6.2 Group Benchmark = blank`
- `6.4 Adjustment Basis Status = 1`
- `7.1 Selection Market Benchmark = VNINDEX`
- `7.2 Selection Group Benchmark = blank`
- `8.1 Require Full Top-Down Profile = No`
- `9.1 P&F Runtime Mode = 0 Deferred / Off`
- `10.2 Show Decision Diagnostics = Yes` during acceptance testing.

### Legacy controls still present in this temporary compatibility harness

Until the engine-level bridge is implemented, the following legacy values must be equivalent to the v0.2 controls:

- Core: `20 / 20 / 14 / 1.80 / 0.75 / 0.35 / 0.80`
- Structure/Location: `20 / 60 / 120 / 3 / 3`
- Composite last bar provisional: `No`
- RS Market Benchmark: `VNINDEX`
- RS Group Benchmark: blank
- RS Adjustment Basis Status: `1`
- RS last bar provisional: `No`
- Selection Market benchmark symbol: `VNINDEX`
- Selection Group benchmark symbol: blank
- Scanner require Full Top-Down profile: `No`.

The adjustment-basis declaration text is not part of the decision-equivalence guard because v0.1 Scanner decisions consume the status code, not that presentation string.

Acceptance requires:

- `Runtime Config Status = CONFIG EQUIVALENT`
- `Config Mismatch Mask = 0`.

## 4. Three-case native gate

### Case A — DTP

Expected accepted baseline:

- Data Eligible = 1
- Candidate Class Code = 9
- Candidate Class = REVIEW - CONFLICT / AMBIGUITY
- Candidate Side Code = 0
- Candidate Stage Code = 1
- Watch = 0
- Scanner Review = 1
- Exclusion Mask = 0
- Method Block Mask = 1031
- Phase = PHASE-B-LIKE
- Family = UNRESOLVED LOWER RANGE
- current range position approximately -2.3027.

### Case B — FRT

Expected accepted baseline:

- Data Eligible = 1
- Candidate Class Code = 9
- Candidate Class = REVIEW - CONFLICT / AMBIGUITY
- Candidate Side Code = 0
- Candidate Stage Code = 1
- Watch = 0
- Scanner Review = 1
- Exclusion Mask = 0
- Method Block Mask = 1031
- Phase = PHASE-B-LIKE
- Family = UNRESOLVED UPPER RANGE
- current range position approximately -0.7363.

### Case C — SNZ

Expected accepted baseline:

- Data Eligible = 1
- Candidate Class Code = 2
- Candidate Class = WATCH
- Candidate Stage Code = 1
- Watch = 1
- Scanner Review = 0
- Exclusion Mask = 0
- Method Block Mask = 7
- Phase = PHASE-B-LIKE
- Family = UNRESOLVED LOWER RANGE
- current range position approximately 0.3500.

## 5. Acceptance rule

The three-case gate passes only when all of the following are true:

1. Formula compiles and executes natively on AmiBroker 6.20.01.
2. Configuration-equivalence status is valid and mismatch mask is zero.
3. DTP, FRT and SNZ match the accepted v0.1 decision surface field-for-field.
4. No case changes Data Eligibility, Candidate Class, Candidate Stage, Watch/Review state, Exclusion Mask or Method Block Mask.
5. The no-P&F fast path does not alter Market Scanner classification.

Only after user-provided native evidence satisfies these conditions may this checkpoint be called:

`PERFORMANCE RUNTIME v0.2 — DIRECT-COMPUTE COMPATIBILITY = NATIVE PASS`

## 6. After this gate

If this gate passes, implementation proceeds in this order:

1. stock snapshot publisher;
2. persistent stock snapshot consumer / fast scanner;
3. whole-universe v0.1 vs v0.2 field-for-field regression;
4. performance timing comparison;
5. Bar Replay / causal acceptance;
6. engine-level Parameter bridge and final removal of duplicated legacy Parameters from the production-facing runtime.

No merge to `main`, tag or release is authorized by this protocol.
