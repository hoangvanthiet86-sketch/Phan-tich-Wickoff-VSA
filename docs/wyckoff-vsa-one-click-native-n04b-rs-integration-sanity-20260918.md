# Wyckoff VSA One-Click v0.1 — Native N04B RS Integration Sanity — 2026-09-18

**Status:** COMPILE/RUNTIME SANITY PASS; canonical equivalence pending

Native result supplied by owner: `1(20260918-113420).txt`.

Observed on SNZ, as-of 2026-09-18:
- Config Valid = 1
- RS Market = VNINDEX
- RS Adjustment Status = 1
- D Mult / Dir / Evidence / Phase / Family = 1 / 1 / 0 / 2 / 1
- D Range ID = 1000000000
- D Range Status = 1
- D Range Position = 0.9500
- D Provisional = 0
- Pivot Config Valid = 1
- RS Context Valid = 1
- RS Context Status = 0
- RS Market Status = 3
- RS Ratio Valid = 1
- RS Ratio = 0.013714
- RS Structure = 0
- Price RS Relationship = 5
- RS Provisional = 0
- Daily Body ms = 1423.077
- RS Runtime ms = 13.099
- Probe Version = `ONE_CLICK_N04B_RS_INTEGRATION_V01_20260918_D`

Interpretation:
- self-contained OneClick RS kernel compiles and executes natively on AmiBroker 6.20.01;
- no manual DailyPublisher / RS snapshot warm-up was required;
- RS validity/benchmark/adjustment/provisional contracts are satisfied;
- because the source date advanced from 2026-09-17 to 2026-09-18, prior-day Daily payload values are not used as an equality oracle.

Next gate: exact same-as-of comparison against the explicit-order canonical Runtime v0.2 RS path.

Checkpoint:
`ONE_CLICK_NATIVE_N04B_RS_INTEGRATION_SANITY = PASS`