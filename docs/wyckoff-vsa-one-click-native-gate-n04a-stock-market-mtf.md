# Wyckoff VSA One-Click v0.1 — Native Gate N04A: Stock + VNINDEX D/W/M + MTF

Purpose: isolate cross-symbol market execution before RS integration.

Run:
- Apply to = SNZ only
- Periodicity = Daily
- Range = 1 Recent Bar
- last bar provisional = No

Required stock regression:
- stock D/W/M provenance and locked categorical payload must remain equal to accepted N03.

Required market execution:
- MKT Foreign OK = 1
- market D/W/M Found = 1
- W ordinal = expected completed weekly ordinal
- M ordinal = expected completed monthly ordinal
- MTF valid = 1
- Market Selection Context is finite categorical output.

This gate intentionally does not include RelativeStrengthContext. N04B will integrate RS only after N04A establishes SetForeign + generated context + MTF stability.

PASS checkpoint:
`ONE_CLICK_NATIVE_N04A_STOCK_MARKET_MTF = PASS`