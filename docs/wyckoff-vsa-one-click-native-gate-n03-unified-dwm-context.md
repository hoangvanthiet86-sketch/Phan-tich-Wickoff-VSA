# Wyckoff VSA One-Click v0.1 — Native Gate N03: Unified D/W/M Context

Goal: prove a single Daily AFL can run the generated analytical body for Daily, Weekly and Monthly contexts and reproduce the already accepted N01/N02 native results.

Control:
- SNZ only
- Periodicity: Daily
- Range: 1 Recent Bar
- 1.3 last bar provisional = No

Expected reference values from accepted gates:

Daily:
- source 2026-09-17
- Multiplicity 1, L/U Active 1/0
- Range ID 1000000000, Range Position 0.4500
- Phase 2, Structural 2, Family 1, Directional 1, Evidence 0

Weekly completed:
- ordinal 1392
- source 2026-09-11
- Multiplicity 1, L/U Active 1/0
- Range ID 1000000000, Range Position 0.9361
- Phase 2, Structural 2, Family 1, Directional 1, Evidence 3

Monthly completed:
- ordinal 24320
- source 2026-08-26
- Multiplicity 1, L/U Active 0/1
- Range ID 2000000000, Range Position 0.7514
- Phase 3, Structural 3, Family 0, Directional 0, Evidence 3

PASS requires exact equality on the locked D/W/M surfaces and correct completed-period provenance.

`ONE_CLICK_NATIVE_N03_UNIFIED_DWM_CONTEXT = PASS`