# Wyckoff VSA Performance Runtime v0.2 — Parameter Mapping

**Status:** IMPLEMENTATION MAPPING — source-verified, pre-code  
**Baseline source:** `integration/wyckoff-vsa-production-candidate-v0.1`  
**Purpose:** map the current AmiBroker Parameter surface into the approved v0.2 hierarchical UX without changing analytical semantics.

---

## 1. Mapping rules

1. Parameter IDs are stable UI identifiers, not locked values.
2. A configurable v0.1 value remains configurable in v0.2 unless it is proven to be a non-configurable methodological constant.
3. DAILY FAST SCAN defaults may differ from legacy UI defaults because they are operational presets. This is **not** analytical drift: equivalence regression always compares explicit equivalent configurations.
4. Any optimization must reproduce v0.1 outputs under equivalent data/configuration.
5. Independent legacy controls may be synchronized by a v0.2 profile for ease of use, but Audit mode must retain a route to reproduce legacy configurations when needed.
6. Empty Parameter groups must not clutter the normal Parameters window.

---

## 2. Source-verified legacy Parameter inventory

### 2.1 Core / Data & VSA

Current source: `WyckoffVSA_Core_v1.0.afl`.

| v0.2 ID | v0.2 label | Legacy variable / label | Legacy default | DAILY FAST SCAN default | Editable |
|---|---|---|---:|---:|---|
| 2.1 | Volume Lookback | `VolumeLookback` / Volume Lookback | 20 | 20 | Yes |
| 2.2 | Spread Lookback | `SpreadLookback` / Spread Lookback | 20 | 20 | Yes |
| 2.3 | ATR Period | `ATRPeriod` / ATR Period | 14 | 14 | Yes |
| 2.4 | High Effort RVOL | `HighEffortThreshold` | 1.80 | 1.80 | Yes |
| 2.5 | Low Effort RVOL | `LowEffortThreshold` | 0.75 | 0.75 | Yes |
| 2.6 | Low Directional Result ATR | `LowDirectionalResultThreshold` | 0.35 | 0.35 | Yes |
| 2.7 | High Directional Result ATR | `HighDirectionalResultThreshold` | 0.80 | 0.80 | Yes |
| 10.4 | Show Debug Title | `ShowDebugTitle` | No | No | Yes |

The fixed RVOL/RSpread/Close display bands in Core are constants, not Params, and remain outside the user-facing Parameter tree unless a future methodology change explicitly makes them configurable.

### 2.2 Structure / Location

Current source: `WyckoffVSA_StructureLocation_v1.0.afl`.

| v0.2 ID | v0.2 label | Legacy variable / label | Legacy default | DAILY FAST SCAN default | Editable |
|---|---|---|---:|---:|---|
| 3.1 | Short Lookback | `SL_S_Lookback` / SL Short Lookback | 20 | 20 | Yes |
| 3.2 | Medium Lookback | `SL_M_Lookback` / SL Medium Lookback | 60 | 60 | Yes |
| 3.3 | Long Lookback | `SL_L_Lookback` / SL Long Lookback | 120 | 120 | Yes |
| 3.4 | Pivot Left | `SL_PivotLeft` | 3 | 3 | Yes |
| 3.5 | Pivot Right | `SL_PivotRight` | 3 | 3 | Yes |

### 2.3 Composite / provisional state

Current source: `WyckoffVSA_CompositeIndicator_v0.1.afl`.

| v0.2 ID | v0.2 label | Legacy variable | Legacy default | DAILY FAST SCAN default |
|---|---|---|---|---|
| 1.3 | Treat Last Bar As Provisional | `WCI_RuntimeLastBarIsProvisional` | No | No |

In standard v0.2 profiles, `1.3` is the primary user-facing provisional control. Audit mode may expose per-module overrides to reproduce unusual legacy mixed settings exactly.

### 2.4 Relative Strength

Current source: `WyckoffVSA_RelativeStrengthContext_v0.1.afl`.

| v0.2 ID | v0.2 label | Legacy variable | Legacy default | DAILY FAST SCAN default |
|---|---|---|---|---|
| 6.1 | Market Benchmark | `WRS_MarketBenchmarkSymbol` | blank | `VNINDEX` |
| 6.2 | Group Benchmark | `WRS_GroupBenchmarkSymbol` | blank | blank |
| 6.3 | Adjustment Basis Declaration | `WRS_AdjustmentBasisDeclaration` | `NOT VERIFIED` | hidden/advanced; canonical declaration to be locked before code |
| 6.4 | Adjustment Basis Status | `WRS_AdjustmentBasisStatusScalar` | 0 | 1 = compatible |
| 1.3 / advanced override | Treat Last Bar As Provisional | `WRS_RuntimeLastBarIsProvisional` | No | No |

The daily profile may synchronize the Composite and RS provisional controls through `1.3`; Audit mode must retain equivalent legacy control if required for regression.

### 2.5 Cross-Symbol Market / Group Context

Current source: `WyckoffVSA_CrossSymbolSelectionContext_Consumer_v0.1.afl`.

| v0.2 ID | v0.2 label | Legacy variable | Legacy default | DAILY FAST SCAN default |
|---|---|---|---|---|
| 7.1 | Selection Market Benchmark | `WXS_RequestedMarketSymbol` | blank | `VNINDEX` |
| 7.2 | Selection Group Benchmark | `WXS_RequestedGroupSymbol` | blank | blank |

DAILY FAST SCAN must default `6.1` and `7.1` to the same market symbol. It must also default `6.2` and `7.2` consistently. If the user deliberately creates a mismatch, validation must expose the mismatch rather than silently normalizing results.

### 2.6 Market Scanner

Current source: `WyckoffVSA_MarketScanner_v0.1.afl`.

| v0.2 ID | v0.2 label | Legacy variable | Legacy default | DAILY FAST SCAN default |
|---|---|---|---|---|
| 8.1 | Require Full Top-Down Profile | `WSCN_RequireFullTopDown` | No | No |

### 2.7 Production Candidate filter

Current source: `WyckoffVSA_ProductionCandidate_AmiBroker620_v0.1.afl`.

| v0.2 ID | v0.2 label | Legacy variable | Legacy default | DAILY FAST SCAN default |
|---|---|---|---:|---:|
| 1.2 | Production Filter | `WPROD_FilterModeCode` | 3 = Review | 2 = Watch+ |

Changing the default from Review to Watch+ is a workflow preset change only. Regression tests must explicitly set equivalent filter modes when comparing v0.1 and v0.2.

### 2.8 P&F

Current source: `WyckoffVSA_PnFConstructionKernel_v0.1.afl`.

| v0.2 ID | v0.2 label | Legacy variable | Legacy default | DAILY FAST SCAN | Deep Review / Audit |
|---|---|---|---|---|---|
| 9.1 | P&F Runtime Mode | new v0.2 control | n/a | OFF / deferred | ON |
| 9.2 | Fixed Box Size | `WPFK_BoxSizeScalar` | 1 | not executed | 1 |
| 9.3 | Grid Origin | `WPFK_GridOriginScalar` | 0 | not executed | 0 |
| 9.4 | Reversal Boxes | `WPFK_ReversalBoxesScalar` | 3 | not executed | 3 |
| 9.5 | Adjustment Basis Declaration | `WPFK_AdjustmentBasisDeclaration` | `NOT VERIFIED` | not executed | advanced/canonical declaration |
| 9.6 | Adjustment Basis Status | `WPFK_AdjustmentBasisStatusScalar` | 0 | not executed | 1 for accepted production basis |
| 1.3 / advanced override | Treat Last Bar As Provisional | `WPFK_RuntimeLastBarIsProvisional` | No | n/a | No |
| 90.8 | P&F Source Revision Status | `WPFK_SourceRevisionStatusScalar` | 0 | n/a | 0 unless explicitly assessed |

P&F is deferred in DAILY FAST SCAN because current Market Scanner Candidate Class is upstream of P&F. Deep Review and Audit preserve the complete P&F surface.

---

## 3. New v0.2 controls

| ID | Parameter | DAILY FAST SCAN default | Purpose |
|---|---|---|---|
| 1.1 | Runtime Profile | DAILY FAST SCAN | Select operational preset |
| 1.2 | Production Filter | Watch+ | Fast shortlist by default |
| 1.3 | Treat Last Bar As Provisional | No | Standard completed-EOD workflow |
| 9.1 | P&F Runtime Mode | Deferred/OFF | Avoid running P&F universe-wide during fast scan |
| 10.1 | Output Detail Level | Compact | Avoid audit-column cost in daily workflow |

Runtime Profile is a convenience preset, not methodology. Values remain visible and individually configurable where permitted.

---

## 4. Reserved groups with no current production-facing Params

The current Phase/Context and Multi-Timeframe engines do not require ordinary user calibration Params in the verified production path. Therefore:

- `04. PHASE / CONTEXT` is reserved but should be hidden when empty.
- `05. MULTI-TIMEFRAME` is reserved but should be hidden when empty.

This avoids creating meaningless controls solely to fill numbering gaps.

---

## 5. Default-profile contract

### Profile 0 — DAILY FAST SCAN

- `1.1 Runtime Profile = DAILY FAST SCAN`
- `1.2 Production Filter = Watch+`
- `1.3 Treat Last Bar As Provisional = No`
- `2.1/2.2/2.3 = 20/20/14`
- `2.4/2.5/2.6/2.7 = 1.80/0.75/0.35/0.80`
- `3.1/3.2/3.3 = 20/60/120`
- `3.4/3.5 = 3/3`
- `6.1 = VNINDEX`
- `6.2 = blank`
- `6.4 = 1 compatible`
- `7.1 = VNINDEX`
- `7.2 = blank`
- `8.1 = No`
- `9.1 = Deferred/OFF`
- `10.1 = Compact`

### Profile 1 — DEEP REVIEW

Uses the same analytical defaults but enables the full Production Candidate enrichment stack, including P&F, for selected symbols/shortlists.

### Profile 2 — AUDIT / REGRESSION

Exposes full diagnostics and legacy-equivalent controls so v0.1 and v0.2 can be compared under explicitly identical configurations.

---

## 6. Equivalence gate for implementation

Parameter reorganization is accepted only when the following hold:

1. With explicit equivalent configuration, v0.2 matches v0.1 decision outputs field-for-field.
2. The current whole-universe native baseline of 1,558 Data Eligible symbols is the first regression dataset.
3. Required decision surface:
   - Data Eligible
   - Candidate Class Code / Class
   - Candidate Side Code
   - Candidate Stage Code
   - Qualified
   - Developing
   - Watch
   - Scanner Review
   - Scanner Exclusion Mask
   - Scanner Method Block Mask
4. Any difference is treated as a defect until proven to be an approved correctness correction.
5. Default-profile differences are tested separately from analytical-equivalence tests.

---

## 7. Pre-code unresolved items

Before implementation starts, only the following configuration-interface details remain to be locked:

1. Exact canonical user-facing text for accepted adjustment-basis declaration. The analytical status code remains authoritative; no new semantics may be introduced by presentation text.
2. Exact compact-output column set for DAILY FAST SCAN.
3. Whether legacy per-module provisional overrides are visible only in Audit mode or moved entirely to an internal regression harness.

None of these unresolved interface details authorizes analytical result changes.
