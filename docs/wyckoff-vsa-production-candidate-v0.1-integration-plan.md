# Wyckoff VSA Production Candidate v0.1 — Integration Plan

**Branch:** `integration/wyckoff-vsa-production-candidate-v0.1`

**Base:** Market Scanner integration head `8b9532d26dfdfacdfba98565af4d30975868a7f4`.

**Strategy:** BUILD FIRST / FINAL NATIVE TEST LATER.

This document defines the source-integration target. It does not claim AmiBroker native acceptance and does not authorize merging to `main`.

## 1. Canonical stack

The production-candidate stack is built in this order:

`Core → Candidate → Structure/Location → Confirmation → Event Engines → Structural Sequence → Phase/Context → Composite → Timeframe Snapshot/MTF → Relative Strength → Cross-Symbol Context → Market Scanner → P&F Construction → P&F Cause/Price Objective → Production Candidate interface`

Released/accepted foundations remain unchanged where already locked. Development layers remain development source until the final integrated native campaign.

## 2. GitHub source-of-truth checkpoints

- Market Scanner integration source: PR #40 / head `8b9532d26dfdfacdfba98565af4d30975868a7f4`.
- P&F Cause / Price Objective specification: PR #41 / PFO01–PFO48.
- P&F Construction Kernel specification: PR #42 / PFK01–PFK44.
- P&F Construction implementation source: PR #43 / development branch.
- Native compatibility correction discovered during AmiBroker execution is incorporated only on this integration branch until final review; PR #43 itself is not merged or rewritten automatically.

## 3. Dependency observations

### 3.1 Market Scanner

`WyckoffVSA_MarketScanner_v0.1.afl` currently consumes:

- `WyckoffVSA_MultiTimeframeContext_v0.1.afl`;
- `WyckoffVSA_RelativeStrengthContext_v0.1.afl`;
- `WyckoffVSA_CrossSymbolSelectionContext_ConsumerVersionGuard_v0.1.afl`.

It explicitly states that P&F target/cause is not yet evaluated. Candidate classification must not be silently rewritten when P&F is added. P&F integration therefore extends **selection completeness and diagnostics**, not the locked scanner classification rules.

### 3.2 Composite / Phase inputs for P&F Cause

The current stack already exposes the canonical information required by PFO03/PFO20/PFO21/PFO22:

- lower/upper `RangeContextID`, frozen range bounds, Phase and Family;
- causal linked-event flags per RangeContext;
- Spring, Supply Test, Upthrust, SOS and LPS origin/known-at coordinates;
- SOW/LPSY range-keyed event outputs and LPSY pivot/known-at coordinates;
- structural-sequence frozen range provenance.

A dedicated `PnF Cause Input Facade` will normalize these upstream fields. The Cause Engine will not copy or recreate Event/Phase logic.

### 3.3 P&F Construction

The kernel remains a geometry/provenance layer. It must not choose ranges, events, count lines or objectives.

The integration branch uses the AmiBroker-compatible correction of the PR #43 kernel discovered during native smoke execution:

- no scalar `Min()/Max()` use inside the state-machine loop;
- no temporary identifiers `h/l/c`, because AFL is case-insensitive and `H/L/C` are built-in price arrays;
- source values are explicit scalar elements such as `High[i]`, `Low[i]`, `Close[i]`.

No PFK economic rule is changed by this compatibility correction.

## 4. P&F Cause / Objective integration contract

### 4.1 Range channels

Lower and upper RangeContexts are preserved independently. No arbitrary winner is selected when both are active.

Each channel may expose two segment classes in v0.1:

1. `CONSERVATIVE` — smallest complete defensible segment using the strongest available right anchor and a causal structural/event left boundary;
2. `FULL_RANGE` — right anchor to the canonical structural range-start boundary when available.

This satisfies the requirement to preserve multiple count candidates without forcing a single final target.

### 4.2 Direction

Official directional objectives are permitted only when the canonical Family hypothesis is directional:

- bullish: `ACCUMULATION-HYPOTHESIS` or `REACCUMULATION-HYPOTHESIS`;
- bearish: `REDISTRIBUTION-HYPOTHESIS` or `DISTRIBUTION-HYPOTHESIS`.

Unresolved/mixed family may expose cause geometry but must not publish an official bullish/bearish objective.

### 4.3 Right-anchor hierarchy

Bullish:

1. latest RangeContext-linked confirmed LPS;
2. latest RangeContext-linked confirmed Supply Test / Spring acting as preliminary conservative anchor when no later LPS exists.

Bearish:

1. latest RangeContext-linked LPSY;
2. latest RangeContext-linked confirmed Upthrust as preliminary conservative anchor when no later LPSY exists.

Origin and KnownAt coordinates are stored separately. Publication occurs only at/after KnownAt.

### 4.4 Left boundaries

Preferred structural boundaries come from the canonical frozen range/sequence already consumed by Phase/Context. No arbitrary `N bars left` rule is introduced.

For arithmetic, the economic boundary/anchor column may be mapped from its origin bar, while its count/objective is published only after the corresponding structural/event KnownAt bar. Both coordinates are retained to preserve causality.

### 4.5 Count arithmetic

For each valid segment:

`InclusiveColumnCount = abs(RightColumnIndex - LeftColumnIndex) + 1`

`ProjectedMove = InclusiveColumnCount × BoxSize × ReversalBoxes`

All horizontal divisions in the selected inclusive span are counted. The engine never counts only postings intersecting the count-line row.

### 4.6 Objective arithmetic

Bullish:

- `ConservativeObjective = RangeLow + ProjectedMove`;
- `CountLineObjective = CountLineBoxLevel + ProjectedMove`.

Bearish:

- `ConservativeObjective = RangeHigh - ProjectedMove`;
- `CountLineObjective = CountLineBoxLevel - ProjectedMove`.

`ObjectiveZoneLow/High` are the sorted endpoints. Midpoint reference remains diagnostic only.

### 4.7 Lifecycle

The PFO lifecycle remains categorical:

0. INSUFFICIENT
1. CAUSE BUILDING
2. COUNT SEGMENT MEASURABLE — PRELIMINARY
3. COUNT SEGMENT CONFIRMED / READY FOR PROJECTION
4. OBJECTIVE ACTIVE AFTER DIRECTIONAL RANGE EXIT
5. OBJECTIVE ZONE APPROACHED / REACHED
6. OBJECTIVE EXCEEDED — MONITOR CHARACTER
7. SOURCE RANGE SUPERSEDED / INVALIDATED

Phase-C/D may measure cause; active objective requires Phase-E-like directional range exit. Reached/exceeded never creates an exit signal.

## 5. Market Scanner integration

P&F does **not** alter existing candidate class logic in v0.1.

The integrated scanner adds:

- Cause/Objective availability;
- objective direction;
- lifecycle;
- conservative/full objective zones;
- stock-candidate/P&F direction harmony diagnostic;
- selection completeness state.

Selection completeness becomes:

- 0 = insufficient/not evaluated;
- 1 = partial Wyckoff selection, P&F Cause/Objective unavailable;
- 2 = partial Wyckoff selection, Cause/Objective available, Trade Risk/R:R still not evaluated.

No Buy/Sell/Short/Cover, R:R gate, probability, confidence, ranking or PositionScore is introduced.

## 6. Final user-facing entrypoints

The integration target will provide:

- `WyckoffVSA_ProductionCandidate_v0.1.afl` — unified current-state public interface;
- `WyckoffVSA_ProductionCandidate_Exploration_v0.1.afl` — practical scan/audit surface;
- `WyckoffVSA_ProductionCandidate_Chart_v0.1.afl` — compact chart/panel surface;
- deployment documentation for required Weekly/Monthly and Market/Group snapshot publishers.

The snapshot publishers remain separate scheduled/pre-run responsibilities because their contracts intentionally use native higher-timeframe and cross-symbol publication. They are not silently replaced by `SetForeign()` or `TimeFrameExpand()` shortcuts.

## 7. Final-test policy

Module-by-module native acceptance is deferred by owner decision. The final integrated candidate will be tested as one release candidate on AmiBroker 6.20.01.

The final campaign must include at minimum:

- Verify Syntax for every production entrypoint/dependency;
- integrated exploration on real data;
- controlled causal-prefix/append checks;
- snapshot publication/consumption workflow;
- source-revision and provisional-bar behavior;
- P&F 1-box/3-box critical semantics inside the integrated stack;
- P&F anchor/count/objective arithmetic;
- scanner + P&F completeness/harmony outputs;
- long-history performance and regression against released Core/Candidate/Structure behavior.

Until that campaign is complete, source status is `INTEGRATED DEVELOPMENT / NATIVE ACCEPTANCE PENDING`.
