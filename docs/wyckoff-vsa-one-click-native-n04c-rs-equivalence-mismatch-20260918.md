# Wyckoff VSA One-Click v0.1 — N04C RS Equivalence Comparison — 2026-09-18

**Status:** FAIL — one isolated mismatch; correction prepared

Compared same-as-of SNZ 2026-09-18:
- N04B OneClick RS kernel v0.1.1
- N04C canonical Runtime v0.2 oracle

Matching fields include:
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
- Price RS Relationship = 5
- RS Provisional = 0

Mismatch:
- OneClick N04B `RS Structure = 0`
- Canonical N04C `RS Structure = 3`

Root cause found in `WyckoffVSA_OneClickRSKernel_v0.1.1.afl`:
- `WVRS_DPK_CalcPivotKind` still wrote pivot outputs under legacy dynamic prefix `WDP_<channel>_Pivot...`;
- the adapted RS consumer read the isolated prefix `WVRS_DPK_<channel>_...`;
- therefore derived pivot outputs were not recovered by the RS consumer and structure fell to 0.

Correction:
- v0.1.2 changes that remaining writer prefix to `WVRS_DPK_<channel>_Pivot...`;
- no threshold, formula, categorical mapping, or methodology change.

N04C remains NOT PASS until v0.1.2 is rerun and exact same-as-of equality is demonstrated.