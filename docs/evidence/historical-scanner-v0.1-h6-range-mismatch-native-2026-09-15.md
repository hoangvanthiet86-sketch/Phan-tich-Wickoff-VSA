# Historical Scanner v0.1 — H6 range mismatch native evidence — 2026-09-15

## Native input

AmiBroker native output: `1(20260915-163445).txt`.

Symbols: `DMC`, `SBM`, `TV3`.

Diagnostic version: `HISTORICAL_H6_RANGE_MISMATCH_DIAGNOSTIC_V01_20260915_A`.

## Result

For all three symbols at 11/09/2026:

- H4 historical timeline is ready.
- Production Daily Snapshot is ready at `BusinessDateKey = 1260911`.
- Direct runtime range-selection validity matches H4 and Production.
- Direct runtime RangePosition matches H4 exactly.
- Direct runtime RangePosition does **not** match Production.
- H4 RangePosition does **not** match Production.

Observed values:

| Symbol | Direct/H4 RangePosition | Production RangePosition |
|---|---:|---:|
| DMC | 1.5892 | 0.6897 |
| SBM | -0.0660 | -0.2981 |
| TV3 | -0.3793 | -0.6667 |

The production `CurrentRangeContextID` remains aligned with the same lower/upper family identity exposed by the direct runtime for each symbol, so the unresolved difference is the point-in-time range state/value, not the simple lower-vs-upper selector or validity flag.

## Interpretation

This evidence rules out the H6 comparator as the source of the remaining three mismatches. It also rules out H4 serialization drift relative to the direct full-history historical runtime: H4 is reproducing the current full-history runtime exactly.

The remaining hypothesis to test is future-state revision of the historical point-in-time range state: full-history runtime/H4 generated after 11/09 may be revising the 11/09 RangePosition relative to the Production snapshot that was serialized on 11/09.

No methodology change is authorized from this evidence alone.

## Next diagnostic

Run `afl/WyckoffVSA_HistoricalH6RangeTruncationDiagnostic_v0.1.afl` on `DMC/SBM/TV3` with future OHLCV after 11/09 masked to Null before the stock causal runtime executes. Compare truncated RangePosition against both H4 full-history and Production.

Expected discriminating outcomes:

- truncated == Production and truncated != H4: future-state revision confirmed;
- truncated == H4 and truncated != Production: Production snapshot path/source differs;
- truncated differs from both: separate source/config discrepancy remains.
