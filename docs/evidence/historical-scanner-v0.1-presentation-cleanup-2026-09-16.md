# Historical Scanner v0.1 — Presentation cleanup

Date: 2026-09-16
Branch: `feature/historical-scanner-presentation-cleanup-v0.1`
Base: H6 accepted head `184db8e833919b7fd126ecc57dc726a1782bd81c`

## Scope

Presentation-only cleanup for the final user-facing Historical Scanner Exploration.

No methodology, threshold, enum, data eligibility, Review, MethodBlockMask, CandidateClass, CandidateSide, MTF, RS, Market context, StaticVar namespace, or historical decision semantics are changed.

No H2/H3/H4 publisher rerun is required by this cleanup.

## User-facing formula

`afl/WyckoffVSA_HistoricalScanner_v0.1.afl`

Changes:

- `SetOption("NoDefaultColumns", True)` added;
- explicit `Ma co phieu` and `Ngay gio` columns replace AmiBroker default leading columns;
- user-facing parameter options and status/class labels use Vietnamese ASCII;
- English display terms such as `Watch`, `Review`, `Data gated`, `publisher`, `Market context`, `point-in-time`, and `Full Top-Down` are removed from user-facing labels;
- `MTF` and `RS` remain as canonical acronyms;
- `RangePosition` is displayed only when `RangePositionValid == 1`; otherwise the cell remains Null/blank;
- redundant default leading columns are removed;
- version bumped to `HISTORICAL_SCANNER_V01_H4_20260916_B` to identify presentation revision.

## Internal proof / publisher outputs

H2-H6 proof and publisher formulas remain internal validation harnesses. Their prior native evidence is retained and is not rerun merely for display cleanup.

The final Historical Scanner user-facing Exploration does not inherit their diagnostic columns because it reads the historical namespaces directly and defines its own explicit output surface.

Therefore legacy diagnostic-column debt is contained to internal validation tooling and is not part of the final Historical Scanner user-facing output.

## HS14 acceptance surface

The release-facing Historical Scanner output must satisfy:

1. Vietnamese ASCII labels/options/status text;
2. no redundant AmiBroker default columns;
3. explicit compact output surface only;
4. invalid/unknown RangePosition shown blank, never as a numeric sentinel;
5. no trading-action fields (`Buy`, `Sell`, `Short`, `Cover`, `PositionScore`, P&L);
6. no change to analytical decision semantics.

## Native evidence — AmiBroker 6.20.01

Native file received from SNZ / Daily / Current / All quotes / `Toan bo kiem tra`.

Observed:

- 1,971 data rows, exactly 17 explicit columns;
- first two columns are `Ma co phieu`, `Ngay gio`; no duplicate AmiBroker default `Ticker` / `Date/Time` columns;
- all 1,971 rows identify version `HISTORICAL_SCANNER_V01_H4_20260916_B`;
- no non-ASCII character exists in column headers or user-facing text values;
- zero occurrences in user-facing output of `Watch`, `Review`, `Data gated`, `Stock publisher`, `Market context`, `point-in-time`, `Full Top-Down`;
- 43 rows show blank `Vi tri trong vung (%)`, confirming invalid/unknown range is not rendered as a numeric sentinel;
- 1,928 rows with valid range display normal numeric percentages;
- no output fields named `Buy`, `Sell`, `Short`, `Cover`, `PositionScore`, or P&L;
- SNZ at 11/09/2026 remains the locked terminal control: eligible, `Theo doi`, side unresolved, stage Watch-equivalent, Phase B, lower unresolved family, RangePosition 35.00%, MTF 0 display, RS down, Review false, MethodBlockMask 7.

No publisher rerun was performed for this presentation acceptance.

## Checkpoints

`HISTORICAL_SCANNER_V01_PRESENTATION_STATIC = PASS`

`HISTORICAL_SCANNER_V01_PRESENTATION_NATIVE = PASS`

Overall final release checkpoint remains pending merge order only: PR #56 H6 first, then this presentation PR.

After H6 acceptance is merged into integration and this presentation cleanup is merged on top, the planned final checkpoint is:

`HISTORICAL_SCANNER_V01_FINAL = PASS_WITH_APPROVED_HS13_DATA_VINTAGE_EXCEPTION`
