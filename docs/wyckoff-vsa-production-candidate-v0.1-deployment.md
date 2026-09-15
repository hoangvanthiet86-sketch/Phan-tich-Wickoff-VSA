# Wyckoff VSA Production Candidate v0.1 — Deployment Workflow

**Status:** `INTEGRATED DEVELOPMENT / NATIVE ACCEPTANCE PENDING`.

This document describes how the final release candidate is intended to be run on AmiBroker 6.20.01. It is not an acceptance report.

## 1. Production entrypoints

Primary Daily analysis files:

- `afl/WyckoffVSA_ProductionCandidate_v0.1.afl` — unified public interface;
- `afl/WyckoffVSA_ProductionCandidate_Exploration_v0.1.afl` — stock-universe scan/audit;
- `afl/WyckoffVSA_ProductionCandidate_Chart_v0.1.afl` — compact chart overlay.

P&F audit surfaces:

- `afl/WyckoffVSA_PnFConstructionKernel_Exploration_v0.1.afl`;
- `afl/WyckoffVSA_PnFCausePriceObjective_Exploration_v0.1.afl`.

## 2. Why publishers remain separate

The MTF and cross-symbol contracts intentionally serialize completed canonical state. The final entrypoint therefore does **not** silently replace them with `TimeFrameExpand()`, hidden `SetForeign()` Phase execution or duplicated higher-timeframe formulas.

Required publishers remain explicit pre-run responsibilities:

- Weekly Timeframe Snapshot Publisher;
- Monthly Timeframe Snapshot Publisher;
- Cross-Symbol Selection Context Publisher for Market benchmark;
- optional Cross-Symbol Selection Context Publisher for Group benchmark.

This is part of the architecture, not an installation inconvenience to bypass with hidden logic.

## 3. Intended run order

### Step A — Weekly snapshots

Run:

`afl/WyckoffVSA_TimeframeSnapshot_WeeklyPublisher_v0.1.afl`

at native Weekly interval for all symbols that will need D/W/M context, including the scan universe and required benchmark/group symbols.

Use only previous calendar-completed Weekly state according to the locked snapshot contract.

### Step B — Monthly snapshots

Run:

`afl/WyckoffVSA_TimeframeSnapshot_MonthlyPublisher_v0.1.afl`

at native Monthly interval for the same required symbols.

Use only previous calendar-completed Monthly state.

### Step C — Market / Group Daily context publication

After their Weekly/Monthly snapshots are available, run:

`afl/WyckoffVSA_CrossSymbolSelectionContext_Publisher_v0.1.afl`

on the explicit Market benchmark symbol and, when configured, the explicit Group benchmark symbol.

The publisher's completion/date/schema/provenance rules remain authoritative. Do not publish an incomplete same-day state as completed.

### Step D — Daily production-candidate exploration

At native Daily interval, run:

`afl/WyckoffVSA_ProductionCandidate_Exploration_v0.1.afl`

on the stock universe.

The Market Scanner consumes the pre-published Market/Group contexts; the stock formula does not re-run full benchmark Phase/Composite/MTF engines through hidden foreign calls.

### Step E — Chart review

For a selected stock, load:

`afl/WyckoffVSA_ProductionCandidate_Chart_v0.1.afl`

The chart preserves raw candles, canonical range boundaries/events and P&F objective zones. Objective zones are analytical projection areas, not automatic entry/exit levels.

## 4. Required P&F profile inputs

P&F v0.1 production path requires explicit values:

- `P&F fixed BoxSize` > 0;
- `P&F GridOrigin`;
- `P&F ReversalBoxes` = 1 or 3;
- `P&F adjustment basis` status;
- adjustment-basis declaration;
- source-revision status when being audited;
- last-bar provisional toggle when applicable.

`AdjustmentBasisStatus = 1` means the database price adjustment basis has been verified compatible with the chosen fixed BoxSize. If status is 0/unverified or 2/incompatible, construction geometry may still be shown for research but official P&F objective availability remains data-gated.

Changing BoxSize, GridOrigin, ReversalBoxes, adjustment basis or price source creates a different P&F construction identity. Results from different identities must not be compared as if they were one generation.

## 5. Market Scanner profile inputs

The existing Scanner/RS/Cross-Symbol parameters remain required, including explicit Market benchmark and optional Group benchmark identity. Silent benchmark fallback is not allowed.

P&F does not alter the existing CandidateClass logic in v0.1. It adds:

- official objective availability;
- projection direction/lifecycle;
- objective zone;
- candidate-side/P&F harmony diagnostic;
- selection completeness.

## 6. Selection completeness

The integrated facade uses categorical completeness only:

- `0` — insufficient/data ineligible;
- `1` — partial Wyckoff selection; official P&F Cause/Objective unavailable;
- `2` — partial Wyckoff selection + official P&F Cause/Objective available; Trade Risk/R:R still not evaluated.

This is **not** a quality score. Code 2 does not mean Five-Step or Nine Tests is complete.

## 7. What the release candidate still does not do

No module in this production candidate is allowed to introduce:

- `Buy`, `Sell`, `Short`, `Cover`, `PositionSize`;
- stop placement or automatic trade-risk sizing;
- R:R PASS/FAIL;
- probability/confidence score;
- weighted ranking, percentile, Top-N;
- automatic watchlist mutation;
- hidden range/phase detection inside P&F;
- hidden P&F construction inside Cause/Objective;
- automatic reversal/exit when a P&F objective is reached.

## 8. Final native acceptance campaign

Per owner decision, intermediate module-by-module native testing is deferred. Acceptance will be performed against the integrated release candidate.

The final campaign must include at least:

1. Verify Syntax of production entrypoints and all reachable dependencies on AmiBroker 6.20.01.
2. End-to-end Weekly → Monthly → Market/Group publication → Daily stock scan workflow.
3. Real-data Production Exploration and chart review.
4. Causal prefix/append stability.
5. Provisional final-bar behavior.
6. Historical source-revision recomputation classification.
7. P&F 1-box two-entry and 3-box precedence/reversal critical cases within the integrated stack.
8. P&F RangeContext/event anchor mapping, inclusive horizontal count and objective arithmetic.
9. Multiple RangeContext preservation and P&F ambiguity handling.
10. Scanner candidate-class regression showing P&F integration did not rewrite locked candidate classification.
11. Released Core/Candidate/Structure regression.
12. Long-history / multi-symbol performance and memory behavior.

Only after the integrated campaign is closed may the branch be proposed as production-ready. No merge/tag/release is authorized by this document.
