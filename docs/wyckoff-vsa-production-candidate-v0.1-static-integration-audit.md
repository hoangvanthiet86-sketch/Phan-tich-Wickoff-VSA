# Wyckoff VSA Production Candidate v0.1 — Static Integration Audit

**Branch:** `integration/wyckoff-vsa-production-candidate-v0.1`

**Audit status:** `SOURCE-INTEGRATION COMPLETE / NATIVE ACCEPTANCE PENDING`.

This audit verifies the integrated source shape only. It does not replace the owner-directed final AmiBroker 6.20.01 campaign and does not authorize merge/tag/release.

## 1. Integration delta

The integration branch is built from Market Scanner integration head `8b9532d26dfdfacdfba98565af4d30975868a7f4` and adds the final P&F / production-candidate layer without modifying the inherited Scanner classification source.

Added production-candidate files:

- `afl/WyckoffVSA_PnFConstructionKernel_v0.1.afl`
- `afl/WyckoffVSA_PnFConstructionKernel_Exploration_v0.1.afl`
- `afl/WyckoffVSA_PnFCauseInputFacade_v0.1.afl`
- `afl/WyckoffVSA_PnFCausePriceObjective_v0.1.afl`
- `afl/WyckoffVSA_PnFCausePriceObjective_Exploration_v0.1.afl`
- `afl/WyckoffVSA_ProductionCandidate_v0.1.afl`
- `afl/WyckoffVSA_ProductionCandidate_Exploration_v0.1.afl`
- `afl/WyckoffVSA_ProductionCandidate_Chart_v0.1.afl`
- integration-plan and deployment documentation.

## 2. P&F Construction prerequisite — source-level satisfied

The integrated kernel preserves the PR #42 PFK01–PFK44 role as geometry/provenance infrastructure only.

The native compatibility defects discovered during the owner-run AmiBroker smoke execution are corrected in the integration copy:

- loop-local `h/l/c` identifiers are not used because AFL is case-insensitive and `H/L/C` are built-in price arrays;
- scalar state-machine decisions do not rely on array-returning `Min()/Max()` assignments;
- loop source prices are explicit scalar elements from `High[i]`, `Low[i]`, `Close[i]`;
- public `WPFK_` geometry/provenance interface is retained.

No Phase/Family/Event interpretation, Cause selection or trading signal is added to the kernel.

## 3. P&F Cause input facade — separation of concerns satisfied

`WyckoffVSA_PnFCauseInputFacade_v0.1.afl` consumes the canonical Composite/Phase stack and only normalizes:

- lower/upper RangeContext identity and frozen bounds;
- Phase and Family state;
- structural full-range boundaries;
- range-linked LPS, Spring, Supply Test, LPSY and Upthrust anchors;
- Origin vs KnownAt coordinates;
- directional objective eligibility from canonical Family state.

The facade does not recreate Phase/Event classification.

## 4. Cause / Objective engine — PFO architecture represented

The integrated Cause/Objective source provides independent lower/upper channels and preserves multiple RangeContexts rather than selecting an arbitrary winner.

Source-level representation includes:

- directional objective gating from canonical Family context;
- right-anchor hierarchy for bullish and bearish contexts;
- separate Origin and KnownAt coordinates;
- source-bar to P&F-column mapping through the Construction Kernel;
- inclusive horizontal division count;
- conservative and full-range segment surfaces kept separately;
- fixed-scale `CountColumns * BoxSize * ReversalBoxes` projection;
- bullish/bearish objective ranges rather than one forced target;
- physical-validity gate for bearish nonphysical objectives;
- preliminary / ready / active / reached / exceeded lifecycle;
- generation identifiers and range supersession behavior;
- stepping-stone objective overlap/nesting diagnostic;
- explicit adjustment-basis / provisional / source-revision provenance.

P&F remains a projection layer. The integrated source does not convert objective reach into a directional flip or trade exit.

## 5. Scanner integration — locked candidate classification preserved

`WyckoffVSA_ProductionCandidate_v0.1.afl` consumes the existing `WSCN_` outputs verbatim for:

- DataEligibility;
- CandidateClass;
- CandidateSide;
- CandidateStage;
- Qualified / Developing / Watch;
- Scanner Review;
- Scanner reason masks.

P&F is added only as:

- objective availability and count;
- objective direction/lifecycle;
- projected move/objective zone;
- candidate-side vs P&F harmony/conflict diagnostic;
- integrated review diagnostic;
- selection completeness.

P&F therefore does not silently rewrite the locked Market Scanner qualification logic.

## 6. Final practical entrypoints — present

The branch now contains:

- `WyckoffVSA_ProductionCandidate_v0.1.afl` — unified public interface;
- `WyckoffVSA_ProductionCandidate_Exploration_v0.1.afl` — practical current-state scan/audit surface;
- `WyckoffVSA_ProductionCandidate_Chart_v0.1.afl` — compact chart overlay preserving multiple P&F objective contexts;
- dedicated P&F construction and Cause/Objective Explorations for audit.

The chart/Exploration layers are presentation/audit surfaces and do not add methodology or trading signals.

## 7. Deployment architecture — explicit publishers preserved

The final Daily formula intentionally does not hide the higher-timeframe or cross-symbol contracts.

Weekly/Monthly snapshot publishers and Market/Group cross-symbol publishers remain explicit pre-run responsibilities. This preserves the locked completed-period, provenance, generation and fail-closed semantics instead of replacing them with hidden `TimeFrameExpand()` or full benchmark Phase execution through `SetForeign()`.

## 8. Build-first milestone conclusion

The owner-directed objective for this stage was to stop module-by-module native acceptance and first create a final integrated candidate.

At source level that milestone is now reached:

`SOURCE-INTEGRATION COMPLETE / FINAL NATIVE CAMPAIGN NOT YET RUN`

No existing draft PR is merged into `main`, and no tag/release is created by this milestone.

## 9. Remaining gate

The next engineering phase is the single integrated AmiBroker 6.20.01 acceptance campaign against the Production Candidate entrypoints and their reachable dependencies. It must cover syntax/runtime, snapshot workflow, causal append/prefix stability, source revision, provisional bars, critical P&F 1-box/3-box semantics, Cause/Objectives, Scanner regression and long-history/multi-symbol performance.

Only that campaign can change the status from `NATIVE ACCEPTANCE PENDING` to production-ready.
