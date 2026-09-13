# Performance Runtime v0.2 — VN STOCKS ONLY U4 Functional Native Evidence

Date: 2026-09-13
Branch: `feature/performance-runtime-v0.2`
Scope: native AmiBroker operational functional checkpoint on watchlist `VN STOCKS ONLY`.

## Inputs checked

- U4-A Daily Publisher export: 1,668 unique symbols.
- U4-B Snapshot Audit export: 1,668 unique symbols.
- U4-C Fast Scanner export (`Production Filter = 4 All Eligible`): 1,066 unique symbols.

## Results

### U4-A Daily Publisher

- 1,668 / 1,668 rows committed.
- Business DateNum = `1260911`.
- Data Eligible = 1 for 1,066 symbols.
- Data Eligible = 0 for 602 symbols.

### U4-B Snapshot Audit

- 1,668 / 1,668 watchlist members present.
- Snapshot Status = 1 for all 1,668.
- Snapshot Valid = 1 for all 1,668.
- Invalid Snapshot = 0 for all 1,668.
- Snapshot Business DateNum equals current Business DateNum for all rows.
- Publisher vs Audit decision/context fields checked by symbol: zero mismatches.

### U4-C Fast Scanner

- 1,066 rows, 1,066 unique symbols.
- Symbol set equals exactly the 1,066 `U4_DataEligible = 1` symbols from U4-B.
- No missing symbols, no extra symbols, no duplicates.
- Snapshot Status = 1 for all 1,066.
- Data Eligible = 1 for all 1,066.
- Fast Scanner Version = `FAST_SCANNER_V02_20260913_A` for all rows.

Exact per-symbol comparison against U4-B produced zero mismatches on all 12 overlapping fields checked:

1. Snapshot Status
2. Data Eligible
3. Candidate Class
4. Candidate Side
5. Candidate Stage
6. Phase
7. Family
8. Range Position
9. MTF Alignment
10. RS vs Market
11. Scanner Review
12. Method Block Mask

Direct Fast Scanner vs Publisher comparison also produced zero mismatches on overlapping published decision fields checked: Data Eligible, Candidate Class, Stage, Review, Method Block Mask.

## Stock-only distribution at this checkpoint

- Eligible: 1,066
- Candidate Class 9: 1,051
- Candidate Class 1: 14
- Candidate Class 2: 1
- Scanner Review = 1: 1,051
- Watch = 1: 1 (`SNZ`)
- Qualified = 0: 1,066
- Developing = 0: 1,066

## Checkpoint conclusion

`PERFORMANCE_RUNTIME_V02_VN_STOCKS_ONLY_U4_FUNCTIONAL = PASS_1066_OF_1066`

This is a functional/native equivalence checkpoint for the operational `VN STOCKS ONLY` path. It does **not** by itself close the requested Analysis-window wall-clock measurement. Wall-clock elapsed times for U4-A Daily Publisher and U4-C Fast Scanner remain to be recorded before final operational performance acceptance.
