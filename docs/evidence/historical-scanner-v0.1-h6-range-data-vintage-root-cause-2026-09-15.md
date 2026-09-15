# Historical Scanner v0.1 — H6 RangePosition data-vintage root cause

Date: 2026-09-15
Branch: `feature/historical-scanner-h6-terminal-universe-v0.1`
PR: #56

## Scope

This evidence note resolves the last three H6 terminal-equivalence mismatches (`DMC`, `SBM`, `TV3`) without changing methodology, thresholds, enums, or decision semantics.

Native evidence used:

- archived production Daily Publisher output at business date 11/09/2026 (`1.txt`, publisher version `DAILY_PUBLISHER_V02_20260912_A`);
- H6 terminal comparator output (`1(20260915-162504).txt`);
- H6 direct/H4/production range diagnostic (`1(20260915-163445).txt`);
- H6 future-truncation range diagnostic (`3(4).txt`).

## 1. Universe result before root-cause isolation

H6 terminal comparison returned the exact 1,066 Production Data Eligible symbols.

For 1,063/1,066 symbols, all compared terminal fields matched.

Exactly three symbols had a remaining mismatch, and only in `RangePosition`:

| Symbol | Production RangePosition | Historical RangePosition |
|---|---:|---:|
| DMC | 0.6897 | 1.5892 |
| SBM | -0.2981 | -0.0660 |
| TV3 | -0.6667 | -0.3793 |

Class, Side, Stage, Phase, Family, MTF, RS, Review, MethodBlockMask, Market context, and RangePosition validity matched for all three.

## 2. Future-truncation result

The dedicated truncation diagnostic masked all OHLCV after 11/09/2026 before rerunning the causal stock runtime.

Result for all three symbols:

- truncated runtime RangePosition == H4 stored historical RangePosition;
- truncated runtime RangePosition != archived Production RangePosition;
- same range-context identity and validity were preserved.

Therefore the mismatch is **not** caused by future leakage in H4 and is **not** caused by the H6 comparator.

## 3. Archived production runtime proves a different source-data vintage

The archived production Daily Publisher output contains the actual range boundaries calculated when the 11/09 production checkpoint was created.

### DMC

Archived production runtime on 11/09/2026:

- Close = 60.0000
- active range = 58.0 .. 60.9
- RangePosition = 0.6897
- PriorATR = 0.9267

Current causal/truncated runtime on the same 11/09 bar:

- Close = 60.0000
- active range approximately = 55.5833 .. 58.3625
- RangePosition = 1.5892
- PriorATR = 0.8881

### SBM

Archived production runtime on 11/09/2026:

- Close = 32.0000
- active range approximately = 33.3 .. 37.8
- RangePosition = -0.2981
- PriorATR = 0.3799

Current causal/truncated runtime on the same 11/09 bar:

- Close = 32.0000
- active range approximately = 32.2841 .. 36.5916
- RangePosition = -0.0660
- PriorATR = 0.3681

### TV3

Archived production runtime on 11/09/2026:

- Close = 15.0000
- active range = 16.2 .. 18.0
- RangePosition = -0.6667
- PriorATR = 0.5684

Current causal/truncated runtime on the same 11/09 bar:

- Close = 15.0000
- active range approximately = 15.6600 .. 17.4000
- RangePosition = -0.3793
- PriorATR = 0.5495

In all three cases the target bar/date and current Close are unchanged, while prior-history-derived quantities (range boundaries and PriorATR) differ. This is direct evidence that the underlying historical source series used by the current recomputation is not the same data vintage as the series used when the production checkpoint was published.

## 4. Root-cause conclusion

The three remaining H6 mismatches are attributable to **source-data vintage revision between the archived 11/09 production run and the current historical recomputation**.

The evidence does not support changing Historical Scanner methodology or range-selection logic:

- H4 == direct current causal runtime;
- H4 == future-truncated current causal runtime;
- comparator field mapping is correct;
- production context ID / validity are consistent;
- archived production runtime itself shows the older range boundaries that generate the archived Production RangePosition values.

Therefore no analytical code correction is justified from these three mismatches.

## 5. Acceptance consequence

HS13 requires exact terminal-date production decision-surface reconstruction for the same 1,066 symbols, otherwise a full mismatch report must be retained and PASS must not be declared.

Current strict result:

`HISTORICAL_SCANNER_V01_H6C_UNIVERSE_TERMINAL_EQUIVALENCE = NOT_EXACT_1063_OF_1066`

Reason:

`DATA_VINTAGE_REVISION = DMC, SBM, TV3 / RangePosition only`

All three locked controls `SNZ`, `DTP`, and `FRT` remain exact.

To obtain strict HS13 exact equivalence without an exception, the historical engine would need the exact historical database/data vintage that existed when the 11/09/2026 production snapshot was created.

Alternatively, the project owner may explicitly approve an acceptance exception for these three verified data-vintage RangePosition differences, as permitted by the Definition of Done.

No production files were modified and no methodology/threshold/decision semantics were changed by this investigation.
