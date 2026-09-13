# Discovery / Pre-Watch v0.1 — Native Production Regression Evidence — 2026-09-14

## Pham vi

Xac minh Discovery / Pre-Watch v0.1 la read-only va khong lam thay doi Fast Scanner production decision surface tren cung Daily Snapshot business date 11/09/2026.

Moi truong: AmiBroker 6.20.01, Daily, `VN STOCKS ONLY`, `Range = 1 recent bar`.

Khong chay lai DailyPublisher.

## File bang chung nguoi dung

Sau khi da chay Discovery Run A va Run B, nguoi dung chay lai `WyckoffVSA_FastScanner_v0.2.afl`:

1. Filter 4 — All Eligible.
2. Filter 2 — Watch + Developing + Qualified.

## Ket qua Filter 4 — All Eligible

Phan tich toan bo TXT export:

- rows = 1,066;
- unique tickers = 1,066;
- duplicate ticker = 0;
- Snapshot Status = 1 cho 1,066/1,066;
- Data Eligible = 1 cho 1,066/1,066;
- Fast Scanner Version = `FAST_SCANNER_V02_20260913_A` cho 1,066/1,066;
- As-Of Date = 11/09/2026 cho 1,066/1,066.

Candidate Class distribution:

- Class 9 Review = 1,051;
- Class 1 Not Current Candidate = 14;
- Class 2 Watch = 1;
- Developing = 0;
- Qualified = 0.

Scanner Review distribution:

- Review = 1: 1,051;
- Review = 0: 15.

Candidate Side = 0 cho 1,066/1,066.

Stage distribution van giu checkpoint truoc Discovery:

- Stage 0 = 705;
- Stage 1 = 215;
- Stage 2 = 83;
- Stage 3 = 53;
- Stage 4 = 10.

MTF distribution van giu:

- MTF 0 = 35;
- MTF 1 = 2;
- MTF 6 = 1,029.

RS vs Market distribution van giu:

- RS 0 = 7;
- RS 1 = 168;
- RS 2 = 504;
- RS 3 = 387.

## Ket qua Filter 2

TXT export Filter 2 tra dung 1 dong:

`SNZ | Snapshot Status=1 | Data Eligible=1 | Candidate Class=2 | Side=0 | Stage=1 | Phase=2 | Family=1 | Range Position=0.3500 | MTF=0 | RS=2 | Review=0 | Method Block Mask=7 | FAST_SCANNER_V02_20260913_A`

Filter 2 tra dung cung Production Watch control nhu truoc Discovery.

## Doi chieu SNZ voi checkpoint truoc Discovery

Khong co thay doi o cac field production can khoa:

- Candidate Class: 2 -> 2;
- Candidate Side: 0 -> 0;
- Candidate Stage: 1 -> 1;
- Phase: 2 -> 2;
- Family: 1 -> 1;
- Range Position: 0.3500 -> 0.3500;
- MTF Alignment: 0 -> 0;
- RS vs Market: 2 -> 2;
- Scanner Review: 0 -> 0;
- Method Block Mask: 7 -> 7.

## Ket luan

Discovery / Pre-Watch v0.1 khong lam thay doi production decision surface tren checkpoint native nay.

- DP-N12 Snapshot read-only: PASS theo doi chieu production sau Discovery.
- DP-N13 Production regression: PASS.

Checkpoint:

`DISCOVERY_PREWATCH_V01_PRODUCTION_REGRESSION = PASS_1066_AND_SNZ`

Ket hop Run A va Run B:

`DISCOVERY_PREWATCH_V01_NATIVE = PASS`

Pham vi PASS chi ap dung cho implementation Discovery / Pre-Watch v0.1 va snapshot native 11/09/2026; khong thay doi acceptance cua Production Scanner, methodology, hoac release acceptance khac.