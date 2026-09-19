# Adaptive batch files to create once

All files are saved under:
`E:\\WyckoffVSA\\batch\\`

Existing canonical APX 01..07 remain unchanged.

Create one new APX:
`WVSA_OC_08_ADAPTIVE_COMMIT.apx`

Formula:
`WyckoffVSA_AdaptiveCommitMarker_v0.1.afl`

Settings:
- Apply To: WVSA ONECLICK MARKET (VNINDEX only)
- Range: 1 recent bar
- Periodicity: Daily
- no special Parameters

Then create these ABB files. Each pair is `Load Project -> Explore`.

### WVSA_OC_FAST_ONLY_v0.1.abb
- 07
- 08

### WVSA_OC_DAILY_REFRESH_v0.1.abb
- 05
- 06
- 07
- 08

### WVSA_OC_WEEKLY_REFRESH_v0.1.abb
- 01
- 03
- 05
- 06
- 07
- 08

### WVSA_OC_MONTHLY_REFRESH_v0.1.abb
- 02
- 04
- 05
- 06
- 07
- 08

### WVSA_OC_FULL_RECOVERY_v0.1.abb
- 01
- 02
- 03
- 04
- 05
- 06
- 07
- 08

The already-created seven-stage `WVSA_OneClick_v0.1.abb` remains the locked
baseline evidence and can be copied to build FULL_RECOVERY before appending 08.

Native acceptance order:
1. Verify Syntax controller and marker only.
2. Create APX 08.
3. Use controller BOOTSTRAP on the verified baseline.
4. Confirm route = FAST_ONLY on same visible date.
5. Run FAST_ONLY and confirm KHX/NTF/VGT equality for the locked 2026-09-18 case.
6. Advance visible as-of one Daily bar: expect DAILY_REFRESH.
7. Week rollover: expect WEEKLY_REFRESH.
8. Month rollover: expect MONTHLY_REFRESH or FULL when both W/M change.
9. Replay backward: current/live markers must not be accepted as fresh.
