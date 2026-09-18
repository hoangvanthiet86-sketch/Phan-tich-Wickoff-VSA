# Wyckoff VSA One-Click v0.1 — Native Gate N04B: Relative Strength Integration

N04A already established Stock + VNINDEX + D/W/M + MTF/Market Selection. N04B is intentionally narrower so any failure is attributable to RS.

Execution order:
1. stock Daily generated body;
2. native-validated `WyckoffVSA_RelativeStrengthContext_Runtime_v0.2.afl` immediately while stock Daily `SL_*` / `WCI_*` arrays are live.

Run: SNZ only, Daily, 1 Recent Bar, RuntimeConfig defaults, last bar provisional = No.

Required:
- Config Valid = 1;
- RS Market = VNINDEX;
- RS Adjustment Status = 1;
- Daily regression remains N01/N03: Mult 1, Dir 1, Evidence 0, Phase 2, Family 1, Range ID 1000000000, Range Position 0.4500;
- D Provisional = 0;
- Pivot Config Valid = 1;
- RS Context Valid = 1;
- RS Context Status = 0;
- RS Market Status = 3;
- RS Ratio Valid = 1;
- RS Structure is finite categorical 0..3;
- RS Provisional = 0.

Checkpoint:
`ONE_CLICK_NATIVE_N04B_RS_INTEGRATION = PASS`