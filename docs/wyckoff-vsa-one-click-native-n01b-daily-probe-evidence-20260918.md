# Wyckoff VSA One-Click v0.1 — Native N01B Daily Probe Evidence — 2026-09-18

**Status:** COMPILE/SANITY PASS; canonical equivalence pending

Native file supplied by owner: `1(20260918-055536).txt`.

Observed row:
- Symbol: SNZ
- As-Of: 2026-09-17 00:00:00
- Config Valid: 1
- Context Body ms: 1430.174
- Composite Multiplicity: 1
- Composite Ambiguous: 0
- L Present/U Present: 1/0
- L PublicActive/U PublicActive: 1/0
- Current Range ID: 1000000000
- Range Status: 1
- Range Position: 0.4500
- Phase: 2
- Structural Development: 2
- Family: 1
- Directional: 1
- Evidence: 0
- Hyp Alignment: 0
- Event Mask: 0
- Probe Version: `ONE_CLICK_CONTEXT_DAILY_PROBE_V01_20260918_A`.

Sanity invariants:
- exactly one SNZ row: PASS
- Config Valid = 1: PASS
- L PublicActive + U PublicActive = Composite Multiplicity: 1 + 0 = 1: PASS
- Composite Ambiguous consistent with multiplicity 1: PASS
- generated body executed natively without compile/runtime failure: PASS

Not yet proven:
- exact equality to canonical Runtime v0.2 on the same SNZ/as-of;
- cross-context isolation;
- Weekly/Monthly equivalence.

Checkpoint:

`ONE_CLICK_NATIVE_N01B_DAILY_COMPILE_SANITY = PASS`