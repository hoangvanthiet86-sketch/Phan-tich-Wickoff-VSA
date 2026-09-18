# Wyckoff VSA One-Click v0.1 — N06B Self-Healing Market Cache

Prerequisite:
`ONE_CLICK_NATIVE_N06A_CACHE_CONTRACT = PASS`

Purpose:
- validate the first real cache domain;
- use canonical `WVOC_MarketPrefix`;
- cold path computes only VNINDEX D/W/M + MTF + Market Selection;
- warm path skips the heavy analytical body entirely;
- consume using generation A -> payload -> generation B.

Native sequence:
1. Verify Syntax.
2. Explore SNZ / Daily / 1 Recent Bar.
3. Save/export result.
4. Run Explore a second time without changing date/config.
5. Save/export the second result.

Expected cold run:
- Cache Hit Before = 0
- Rebuilt = 1
- Writer Acquired = 1
- Stable Read = 1
- Rebuild Exact = 1
- ALL PASS = 1

Expected warm run:
- Cache Hit Before = 1
- Rebuilt = 0
- Stable Read = 1
- Rebuild Exact = 1
- Heavy Runtime ms = 0
- ALL PASS = 1

No stock runtime, RS, or candidate classification is executed in this gate.
