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

Native presentation smoke test is still required on AmiBroker 6.20.01 before declaring overall `HISTORICAL_SCANNER_V01_FINAL = PASS`.

## Static checkpoint

`HISTORICAL_SCANNER_V01_PRESENTATION_STATIC = PASS`

Pending native checkpoint:

`HISTORICAL_SCANNER_V01_PRESENTATION_NATIVE = PENDING`
