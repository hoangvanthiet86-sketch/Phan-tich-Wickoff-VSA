# Wyckoff VSA One-Click v0.1 — Native Gate N04B: Relative Strength Integration

Purpose: integrate the native-validated `WyckoffVSA_RelativeStrengthContext_Runtime_v0.2.afl` directly into the one-click cold path, without a DailyPublisher or snapshot warm-up.

Ordering contract:
1. stock Daily generated body;
2. canonical RS Runtime v0.2 immediately while stock Daily `SL_*` / `WCI_*` arrays are live;
3. stock completed W/M;
4. VNINDEX D/W/M;
5. lightweight MTF / Market Selection.

Run:
- SNZ only;
- Daily;
- 1 Recent Bar;
- RuntimeConfig defaults;
- last bar provisional = No.

Required:
- Config Valid = 1;
- RS Market = VNINDEX;
- RS Adjustment Status = 1;
- RS Context Valid = 1;
- RS Context Status = 0;
- RS Market Status = 3;
- RS Ratio Valid = 1;
- RS Structure finite categorical 0..3;
- RS Provisional = 0;
- stock D/W/M regression remains equal to N03/N04A;
- market D/W/M + Market Selection remains valid as in N04A.

Checkpoint:
`ONE_CLICK_NATIVE_N04B_RS_INTEGRATION = PASS`