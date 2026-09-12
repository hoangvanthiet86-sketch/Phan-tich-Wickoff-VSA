# Wyckoff VSA Performance Runtime v0.2 — RuntimeConfig & Stock Snapshot Contract

**Status:** IMPLEMENTATION CONTRACT — approved architecture, pre-native-test  
**Parent specification:** `wyckoff-vsa-performance-runtime-v0.2-spec-draft.md` + approved owner decisions  
**Baseline:** `integration/wyckoff-vsa-production-candidate-v0.1`  
**Primary invariant:** implementation may change, analytical result may not change under equivalent input/configuration except through the approved correctness-exception process.

---

## 1. Purpose

This contract defines the concrete pre-code interface for:

1. centralized runtime Parameters;
2. effective configuration variables consumed by runtime engines;
3. stock snapshot publication;
4. Fast Scanner snapshot consumption;
5. atomicity/staleness/config guards;
6. the compact DAILY FAST SCAN decision surface;
7. the equivalence gate against Production Candidate v0.1.

It does **not** redefine Wyckoff/VSA methodology.

---

## 2. RuntimeConfig public namespace

All centralized runtime variables use prefix:

`WVRC_`

The first implementation target is:

`afl/WyckoffVSA_RuntimeConfig_v0.2.afl`

RuntimeConfig is configuration/presentation infrastructure only. It must not generate Candidate, Phase, Event, MTF, RS or P&F meaning.

### 2.1 Run mode

| UI ID | Public variable | Meaning | DAILY FAST default |
|---|---|---|---|
| 1.1 | `WVRC_RuntimeProfileCode` | 0 Daily Fast, 1 Deep Review, 2 Audit/Regression | 0 |
| 1.2 | `WVRC_ProductionFilterCode` | 0 Qualified, 1 Developing+, 2 Watch+, 3 Review, 4 All Eligible, 5 P&F Review | 2 |
| 1.3 | `WVRC_LastBarProvisional` | one production-wide completion declaration | 0 |

### 2.2 Data & VSA

| UI ID | Public variable | Default |
|---|---|---:|
| 2.1 | `WVRC_VolumeLookback` | 20 |
| 2.2 | `WVRC_SpreadLookback` | 20 |
| 2.3 | `WVRC_ATRPeriod` | 14 |
| 2.4 | `WVRC_HighEffortRVOL` | 1.80 |
| 2.5 | `WVRC_LowEffortRVOL` | 0.75 |
| 2.6 | `WVRC_LowDirectionalResultATR` | 0.35 |
| 2.7 | `WVRC_HighDirectionalResultATR` | 0.80 |

### 2.3 Structure / Location

| UI ID | Public variable | Default |
|---|---|---:|
| 3.1 | `WVRC_ShortLookback` | 20 |
| 3.2 | `WVRC_MediumLookback` | 60 |
| 3.3 | `WVRC_LongLookback` | 120 |
| 3.4 | `WVRC_PivotLeft` | 3 |
| 3.5 | `WVRC_PivotRight` | 3 |

### 2.4 Relative Strength

| UI ID | Public variable | DAILY FAST default |
|---|---|---|
| 6.1 | `WVRC_RSMarketSymbol` | `VNINDEX` |
| 6.2 | `WVRC_RSGroupSymbol` | blank |
| 6.3 | `WVRC_RSAdjustmentBasisDeclaration` | `ADJUSTED PRICE` |
| 6.4 | `WVRC_RSAdjustmentBasisStatus` | 1 = compatible-declared |

The presentation text for status 1 is `COMPATIBLE - DECLARED`. This is a configuration declaration, not independent vendor/feed verification.

### 2.5 Market / Group selection context

| UI ID | Public variable | DAILY FAST default |
|---|---|---|
| 7.1 | `WVRC_SelectionMarketSymbol` | `VNINDEX` |
| 7.2 | `WVRC_SelectionGroupSymbol` | blank |

Runtime validation must report a configuration mismatch when RS and Selection benchmark identities disagree. It must not silently rewrite one to match the other.

### 2.6 Scanner

| UI ID | Public variable | Default |
|---|---|---:|
| 8.1 | `WVRC_RequireFullTopDown` | 0 |

### 2.7 P&F

| UI ID | Public variable | DAILY FAST | Deep/Audit |
|---|---|---|---|
| 9.1 | `WVRC_PnFRuntimeMode` | 0 deferred/off | 1 on |
| 9.2 | `WVRC_PnFBoxSize` | not executed | 1 |
| 9.3 | `WVRC_PnFGridOrigin` | not executed | 0 |
| 9.4 | `WVRC_PnFReversalBoxes` | not executed | 3 |
| 9.5 | `WVRC_PnFAdjustmentBasisDeclaration` | not executed | `ADJUSTED PRICE` |
| 9.6 | `WVRC_PnFAdjustmentBasisStatus` | not executed | 1 = compatible-declared |
| 90.8 | `WVRC_PnFSourceRevisionStatus` | not executed | 0 unless assessed |

P&F runtime mode is not part of Market Scanner Candidate Class semantics. DAILY FAST can therefore defer P&F without changing Scanner classification.

### 2.8 Output / diagnostics

| UI ID | Public variable | Default |
|---|---|---:|
| 10.1 | `WVRC_OutputDetailCode` | 0 Compact |
| 10.2 | `WVRC_ShowDecisionDiagnostics` | 0 |
| 10.3 | `WVRC_ShowRangeDiagnostics` | 0 |
| 10.4 | `WVRC_ShowDebugTitle` | 0 |

Presentation controls are excluded from the analytical config signature unless they alter calculation, which they must not.

---

## 3. Runtime Profile implementation rule

AmiBroker Parameters are persistent user values. Therefore Runtime Profile must not silently overwrite user-entered analytical Params.

### RPF01 — Profile is runtime orchestration, not hidden parameter mutation

Profile selects runtime behavior that is legitimately profile-specific, including:

- whether P&F is deferred;
- compact vs deep/audit output;
- intended default filter workflow;
- whether full diagnostics are emitted.

The analytical calibration fields `2.x`, `3.x`, benchmark identity/status fields and other editable analytical inputs remain explicit Parameters.

### RPF02 — Initial production defaults

The source-level defaults of those explicit Parameters are the approved DAILY FAST values. Therefore a fresh formula load starts in the common production configuration without requiring manual edits.

### RPF03 — Equivalent-config regression

Regression never assumes that changing profile magically rewrites persistent Params. v0.1/v0.2 equivalence tests set or verify all analytical inputs explicitly.

### RPF04 — No hidden methodology

No profile may change an analytical threshold or identity without that effective value being observable in RuntimeConfig diagnostics.

---

## 4. Unified provisional contract

Production-facing runtime exposes exactly one control:

`1.3 Treat Last Bar As Provisional` → `WVRC_LastBarProvisional`

The value is propagated consistently to all runtime modules that require bar-completion status.

Legacy Composite/RS/P&F module-specific provisional overrides are not ordinary Parameters in v0.2. They exist only in dedicated regression/native-test harnesses for exact legacy reproduction and fault isolation.

No production profile may create contradictory completion assumptions between Composite, RS and P&F.

---

## 5. Analytical configuration signature

Snapshot validity requires exact configuration equivalence.

The stock snapshot stores a canonical text signature:

`WVSA2_CONFIG_V1|...`

The signature must include, in stable order:

1. Volume Lookback
2. Spread Lookback
3. ATR Period
4. High Effort RVOL
5. Low Effort RVOL
6. Low Directional Result ATR
7. High Directional Result ATR
8. Short Lookback
9. Medium Lookback
10. Long Lookback
11. Pivot Left
12. Pivot Right
13. RS Market Symbol
14. RS Group Symbol
15. RS Adjustment Basis Declaration
16. RS Adjustment Basis Status
17. Selection Market Symbol
18. Selection Group Symbol
19. Require Full Top-Down
20. Treat Last Bar As Provisional

The following are explicitly **not** part of the Market Scanner analytical signature:

- Production Filter;
- Output Detail;
- diagnostic display flags;
- P&F runtime mode/BoxSize/etc., because P&F is downstream of current Scanner classification.

If a future Scanner version consumes P&F, this exclusion must be revisited by specification before code changes.

Use exact text comparison for the signature. Do not rely on an unproven numeric hash that could introduce precision/collision ambiguity in AFL.

---

## 6. Persistent stock snapshot namespace

All stock snapshots use prefix:

`WVSA2_STOCK_<SYMBOL>_`

The symbol component must be the exact canonical AmiBroker `Name()` identity used during publication. Publisher also stores the symbol text in payload and Consumer requires exact identity match.

### 6.1 Metadata fields

Mandatory metadata:

- `SchemaMajor`
- `SchemaMinor`
- `RuntimeVersionCode`
- `SourceSymbol`
- `SourceInterval`
- `SourceBusinessDateKey`
- `SourceBarDateTime`
- `ConfigSignature`
- `Generation`
- `PayloadValid`
- `ProvisionalFlag`

Canonical business-date key is AmiBroker `DateNum`, sourced through the accepted Operational Clock contract. Numeric YYYYMMDD is not canonical.

### 6.2 Decision payload

Mandatory decision fields:

- `DataEligible`
- `CandidateClassCode`
- `CandidateSideCode`
- `CandidateStageCode`
- `Qualified`
- `Developing`
- `Watch`
- `ScannerReview`
- `ExclusionMask`
- `MethodBlockMask`

### 6.3 Diagnostic payload required by DAILY FAST

Mandatory compact diagnostic fields:

- `PhaseStateCode`
- `FamilyHypothesisCode`
- `RangePosition`
- `RangePositionValid`
- `MTFAlignmentCode`
- `StockVsMarketRSStructureCode`

### 6.4 Additional provenance required for validation/audit

Snapshot also carries the minimum provenance needed to prove current-state validity, including:

- current RangeContext identity/status where available;
- stock MTF snapshot-contract valid state;
- RS context valid/status;
- market selection-context valid/status;
- group selection-context valid/status when requested;
- schema/version inputs required by current Scanner exclusions.

Exact expansion of audit-only fields may grow, but decision semantics may not change without specification.

---

## 7. Atomic publication protocol

Use an odd/even generation protocol.

### PUB01 — Start write

Publisher reads prior completed generation `G` and begins new write with an odd generation value.

Example:

- previous complete generation = 10
- writer first publishes `Generation = 11` (odd = busy)

### PUB02 — Write payload

Writer publishes all metadata and payload fields while generation is odd.

### PUB03 — Commit write

Only after all payload fields are written, writer publishes the next even generation:

`Generation = 12`

Even generation means a completed candidate snapshot.

### CON01 — Consumer stable-read check

Consumer:

1. reads `GenerationBefore`;
2. rejects immediately if missing or odd;
3. reads metadata/payload;
4. reads `GenerationAfter`;
5. accepts only if `GenerationBefore == GenerationAfter` and both are even.

This prevents use of partially updated snapshots without requiring a lock primitive.

---

## 8. Snapshot validation / status codes

Fast Scanner exposes `Snapshot Status` separately from Wyckoff Scanner classification.

Proposed v0.2 status contract:

| Code | Status |
|---:|---|
| 0 | NOT READ / INSUFFICIENT |
| 1 | VALID |
| 2 | MISSING |
| 3 | WRITER BUSY / UNSTABLE GENERATION |
| 4 | SCHEMA / RUNTIME VERSION MISMATCH |
| 5 | SYMBOL MISMATCH |
| 6 | INTERVAL MISMATCH |
| 7 | STALE BUSINESS DATE |
| 8 | FUTURE BUSINESS DATE |
| 9 | CONFIG SIGNATURE MISMATCH |
| 10 | PROVISIONAL SOURCE NOT ACCEPTED |
| 11 | INVALID / INCOMPLETE PAYLOAD |
| 12 | INVALID SOURCE DATETIME / CLOCK PROVENANCE |

Snapshot Status is operational validity, not a replacement for Scanner Exclusion Mask.

A snapshot invalid solely because it is stale/config-mismatched must not be reinterpreted as an analytical `REVIEW` or other Candidate Class. DAILY FAST fails closed and does not use its analytical payload.

---

## 9. DAILY FAST SCAN output contract

Default compact output is exactly:

1. Symbol
2. As-Of Date
3. Snapshot Status
4. Data Eligible
5. Candidate Class
6. Candidate Side
7. Candidate Stage
8. Phase
9. Family
10. Range Position
11. MTF Alignment
12. RS vs Market
13. Scanner Review
14. Method Block Mask

`Scanner Exclusion Mask` remains available in diagnostics/Audit and may be surfaced in a dedicated ineligible-data diagnostic mode.

Fast output reduction is presentation-only. Publisher still computes/publishes all fields required for exact classification and validation.

---

## 10. Fast Scanner filter behavior

DAILY FAST default is `Watch+`.

Equivalent logic must preserve current Production Candidate definitions:

- Qualified: `Qualified == 1`
- Developing+: `Developing == 1 OR Qualified == 1`
- Watch+: `Watch == 1 OR Developing == 1 OR Qualified == 1`
- Review: current approved review semantics
- All Eligible: `DataEligible == 1`

Fast Scanner may filter snapshot rows only after Snapshot Status is VALID.

Audit mode can expose invalid snapshot rows for diagnosis; it must never consume invalid payload as if current.

---

## 11. Performance architecture

### Stage A — Publisher

Runs the canonical analytical stack required to reproduce current Scanner decision surface and writes one current-state snapshot per stock.

Publisher may remain computationally expensive initially. Its job is to move the expensive calculation to a controlled once-per-EOD step.

### Stage B — Fast Scanner

Reads persistent scalar snapshots only. It does not run:

- the full historical Phase state machine;
- Relative Strength derived-pivot construction;
- P&F Construction;
- P&F Cause/Objective;
- upstream diagnostic Explorations.

### Stage C — Deep Review

Runs full Production Candidate/P&F only for selected symbols or shortlist.

### Stage D — Later optimization

Loop/vectorization/incremental-state changes may be introduced only after Stage A/B equivalence is native-proven. This isolates architecture optimization from algorithmic optimization and makes regressions attributable.

---

## 12. Result-preservation acceptance gate

No v0.2 runtime is accepted merely because it is faster.

First native baseline is the existing universe run with 1,558 Data Eligible rows.

For every comparable symbol, the following must match exactly under equivalent configuration:

- Data Eligible
- Candidate Class Code
- Candidate Side Code
- Candidate Stage Code
- Qualified
- Developing
- Watch
- Scanner Review
- Scanner Exclusion Mask
- Scanner Method Block Mask

Upstream fields are additionally compared when their producing module has been changed.

Any unexplained mismatch is a defect.

A mismatch may be accepted only through the documented correctness-exception process: reproducible case → root cause → proof old result violates approved contract → correction spec → native test → scoped regression.

---

## 13. Native acceptance sequence

Implementation proceeds in this order:

1. RuntimeConfig compile smoke.
2. Publisher single-symbol smoke using DTP/FRT/SNZ controls.
3. Snapshot consumer stable-read/staleness/config mismatch tests.
4. Fast Scanner single-symbol equivalence.
5. 1,558-row whole-universe equivalence.
6. Performance timing comparison.
7. Bar Replay end-to-end causal acceptance.
8. Only then consider deeper algorithmic/loop optimizations.

No `NATIVE PASS` is claimed before AmiBroker 6.20.01 evidence is supplied.
