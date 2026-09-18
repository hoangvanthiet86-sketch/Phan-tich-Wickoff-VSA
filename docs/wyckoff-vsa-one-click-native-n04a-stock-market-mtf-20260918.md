# Wyckoff VSA One-Click v0.1 — Native N04A Stock + Market MTF — 2026-09-18

**Status:** PASS

Control: SNZ, Daily, visible as-of 2026-09-17.

Stock regression against accepted N03:
- Daily: source 2026-09-17, mult 1, dir 1, evidence 0, phase 2;
- Weekly completed: ordinal 1392 / 2026-09-11, mult 1, dir 1, evidence 3, phase 2;
- Monthly completed: ordinal 24320 / 2026-08-26, mult 1, dir 0, evidence 3, phase 3;
- exact accepted N03 categorical/provenance values preserved.

Stock MTF:
- valid 1;
- directional alignment 0;
- evidence alignment 0;
- phase relationship 4;
- conflict mask 512.

VNINDEX direct foreign execution:
- SetForeign success = 1;
- Daily / Weekly / Monthly found = 1 / 1 / 1;
- Weekly ordinal 1392 / 2026-09-11;
- Monthly ordinal 24320 / 2026-08-26;
- Daily/Weekly/Monthly multiplicity = 1 / 0 / 1;
- Daily/Weekly/Monthly directional = 1 / 0 / 0;
- market MTF valid = 1;
- market selection context = 1 (finite unresolved/neutral categorical state).

Performance diagnostics from native probe (ms):
- stock D/W/M: 1251.811 / 200.060 / 43.054;
- market D/W/M: 88.695 / 26.478 / 43.851.

Interpretation:
- no manual market publisher was required;
- one stock Daily thread successfully built stock and VNINDEX D/W/M contexts plus both MTF relationships;
- N04B may now isolate canonical Relative Strength runtime integration.

Checkpoint:

`ONE_CLICK_NATIVE_N04A_STOCK_MARKET_MTF = PASS`