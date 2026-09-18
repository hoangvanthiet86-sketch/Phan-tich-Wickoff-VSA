# Wyckoff VSA One-Click v0.1 — Native N04C RS Exact Equivalence — 2026-09-18

**Status:** PASS

Compared same-as-of SNZ 2026-09-18:
- OneClick N04B with `WyckoffVSA_OneClickRSKernel_v0.1.2.afl`
- canonical explicit-order Runtime v0.2 N04C oracle

Exact common decision surface:
- Config Valid = 1
- RS Market = VNINDEX
- RS Adjustment Status = 1
- Daily Mult/Dir/Evidence/Phase/Family = 1/1/0/2/1
- Daily Range ID/Status/Position = 1000000000 / 1 / 0.9500
- Daily Provisional = 0
- Pivot Config Valid = 1
- RS Context Valid/Status = 1/0
- RS Market Status = 3
- RS Ratio Valid = 1
- RS Ratio = 0.013714
- RS Structure = 3
- Price RS Relationship = 5
- RS Provisional = 0

The prior v0.1.1 namespace mismatch is corrected in v0.1.2. No methodology, threshold or categorical mapping changed.

Checkpoint:
`ONE_CLICK_NATIVE_N04C_RS_EQUIVALENCE = PASS`