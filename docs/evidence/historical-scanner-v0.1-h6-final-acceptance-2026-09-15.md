# Historical Scanner v0.1 — H6 final acceptance

Date: 2026-09-15
Branch: `feature/historical-scanner-h6-terminal-universe-v0.1`
PR: #56

## Scope

This note closes H6 multi-symbol native validation for Historical Scanner v0.1. It does not change production methodology, thresholds, enums, decision semantics, or trading behavior.

## H6-0 prerequisite

Final prerequisite audit on `VN STOCKS ONLY`:

- universe = 1,668 symbols;
- Production Data Eligible = 1,066;
- H2 Weekly ready = 1,066/1,066 eligible;
- H2 Monthly ready = 1,066/1,066 eligible;
- H4 stock ready + target 11/09 = 1,066/1,066 eligible;
- H3 Market ready + target 11/09 = available;
- H6 prerequisite = 1,066/1,066 eligible.

Checkpoint:

`HISTORICAL_SCANNER_V01_H6_PREREQUISITE_UNIVERSE_1066 = PASS`

## H6-A / HS11 — SNZ

SNZ terminal control is exact at 11/09/2026:

- Class 2;
- Side 0;
- Stage 1;
- Phase 2;
- Family 1;
- RangePosition 0.3500;
- MTF 0;
- RS 2;
- Review 0;
- MethodBlockMask 7.

Checkpoint:

`HISTORICAL_SCANNER_V01_H6A_SNZ_TERMINAL = PASS`

## H6-B / HS12 — DTP / FRT

DTP and FRT both match the locked production controls, including Review/class 9, Review=1, MethodBlockMask=1031 and locked approximate RangePosition references.

Checkpoint:

`HISTORICAL_SCANNER_V01_H6B_DTP_FRT_CONTROLS = PASS`

## H6-C / HS13 — universe terminal comparison

Strict comparator measurement:

- exact eligible symbol set = 1,066/1,066;
- all compared non-RangePosition fields match across all 1,066 symbols;
- exact all-field match = 1,063/1,066;
- three remaining differences are only `RangePosition`: `DMC`, `SBM`, `TV3`.

Strict checkpoint remains:

`HISTORICAL_SCANNER_V01_H6C_UNIVERSE_TERMINAL_EQUIVALENCE = NOT_EXACT_1063_OF_1066`

Dedicated diagnostics proved that direct causal runtime and future-truncated runtime both match H4, while archived Production values come from a different historical source-data vintage. No look-ahead or comparator defect was found for these three rows.

Project owner explicitly approved the narrow acceptance exception for these verified data-vintage differences on 15/09/2026.

Acceptance record:

`HISTORICAL_SCANNER_V01_HS13_ACCEPTANCE_EXCEPTION = APPROVED_DMC_SBM_TV3_DATA_VINTAGE_REVISION`

Accepted H6-C status:

`HISTORICAL_SCANNER_V01_H6C = PASS_WITH_APPROVED_EXCEPTION`

The strict 1063/1066 measurement remains retained and is not rewritten as exact 1066/1066.

## H6-D presentation

H6 acceptance-facing output satisfies the H6 presentation gate:

- Vietnamese ASCII/no diacritics for AmiBroker 6.20.01;
- `NoDefaultColumns` on H6 acceptance formulas;
- Null RangePosition displayed blank when invalid;
- no numeric sentinel interpreted as a valid RangePosition;
- no Buy/Sell/Short/Cover/PositionScore/P&L.

Checkpoint:

`HISTORICAL_SCANNER_V01_H6D_PRESENTATION = PASS`

Older H2-H5 internal publisher/proof outputs still carry presentation debt and must be cleaned before overall Historical Scanner v0.1 final user-facing acceptance. No expensive publisher rerun is required merely to document H6 closure.

## H6 conclusion

H6-0 PASS, H6-A PASS, H6-B PASS, H6-C PASS_WITH_APPROVED_EXCEPTION, H6-D PASS.

Final H6 checkpoint:

`HISTORICAL_SCANNER_V01_H6 = PASS_WITH_APPROVED_EXCEPTION`

PR #56 is ready for review. It must not be auto-merged.

Overall `HISTORICAL_SCANNER_V01_FINAL = PASS` is intentionally not declared in this note because remaining presentation debt is outside the H6 correctness gate and still belongs to overall final acceptance.
