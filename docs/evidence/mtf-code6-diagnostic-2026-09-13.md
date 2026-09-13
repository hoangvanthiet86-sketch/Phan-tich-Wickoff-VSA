# MTF Code-6 Diagnostic Evidence - 2026-09-13

## Scope

Analysis-only evidence from AmiBroker 6.20.01 output for `WyckoffVSA_MTFCode6_Diagnostic_v0.1.afl` over the current `VN STOCKS ONLY` universe snapshot dated 2026-09-11.

This evidence does not change methodology, candidate classification, filter semantics, or production snapshot payloads.

## Integrity

- Rows: 1,029
- Unique tickers: 1,029
- `MTF code trong Daily Snapshot = 6`: 1,029 / 1,029
- `MTF code tinh lai = 6`: 1,029 / 1,029
- `Doi chieu logic = Khop`: 1,029 / 1,029
- Weekly snapshot status valid: 1,029 / 1,029
- Monthly snapshot status valid: 1,029 / 1,029

Therefore the current persisted MTF code 6 population is internally consistent with the approved categorical alignment logic.

## Root-cause decomposition

The native output exposed a presentation-indexing defect in the first diagnostic build: `WMD_RootCauseCode` used values 1..4 with `AddMultiTextColumn`, causing displayed reason labels to shift by one. The underlying Daily/Weekly/Monthly columns were unaffected. PR #46 was corrected to use zero-based reason codes in commit `9d68ef8c2e650c6f303a24bb283966254e8caab5`.

Using the actual snapshot fields, the 1,029 MTF=6 symbols decompose as follows:

| Root cause | Count | Share |
| --- | ---: | ---: |
| Daily has multiple active range contexts | 668 | 64.9% |
| Daily has one range but directional context is mixed/conflicting | 246 | 23.9% |
| Daily is not mixed; Weekly and/or Monthly causes mixed/complex MTF | 115 | 11.2% |

Thus 914 / 1,029 symbols (88.8%) already carry a Daily mixed/ambiguous condition before higher-timeframe interaction is considered.

## Higher-timeframe-only subgroup

Within the 115 symbols whose Daily state is not itself mixed:

| Higher-timeframe source | Count |
| --- | ---: |
| Weekly and Monthly both contribute | 61 |
| Weekly only | 41 |
| Monthly only | 13 |

## Additional distribution

Daily range multiplicity across the MTF=6 population:
- multiple ranges: 668
- one range: 345
- no active range: 16

Daily directional state across the MTF=6 population:
- mixed/conflicting: 914
- unresolved: 58
- bearish: 34
- insufficient: 16
- bullish: 7

## Interpretation

The dominant bottleneck is not ordinary disagreement between otherwise clean Daily/Weekly/Monthly directional states. It is upstream ambiguity already present in the structural context, especially multiple active range contexts and mixed/conflicting Daily directional hypotheses.

The next design investigation should therefore focus on why the Phase/Context layer retains multiple simultaneous range contexts and why a single active range resolves to `Family = 7 / MIXED-CONFLICTING` so frequently. Do not loosen Fast Scanner or MTF acceptance thresholds before that upstream behavior is understood.
