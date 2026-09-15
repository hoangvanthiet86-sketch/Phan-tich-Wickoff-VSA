# Discovery / Pre-Watch v0.1 — Native Run A Evidence

**Ngay:** 14/09/2026

**Moi truong:** AmiBroker 6.20.01, Daily

**Snapshot business date:** 11/09/2026

**AFL:** `afl/WyckoffVSA_DiscoveryPreWatch_v0.1.afl`

**Che do:** `Chi Pre-Watch Near`

## Ket qua native

Nguoi dung xuat TXT Run A tu AmiBroker.

- So dong ket qua: **42**
- So ticker duy nhat: **42**
- 42/42 `Trang thai Discovery = Pre-Watch Near`
- 42/42 `Production Review = Co`
- 42/42 `Candidate Stage = 1` (`Theo doi - dang hinh thanh / phat trien vung`)
- 42/42 `So vung context = Mot vung`
- 42/42 `MTF = Da khung hon hop / phuc tap` (code 6)
- 42/42 `Method Block Mask = 15`
- 42/42 `Range-location conflict = 0`
- 42/42 `Range-location coherent = 1`
- 42/42 phien ban `DISCOVERY_PREWATCH_V01_20260914_A`
- RS vs Market: 33 falling / 9 rising
- Phase: 39 Pha B / 3 Pha A

## Doi chieu Native Test Plan

Run A xac nhan:

- DP-N01 Compile: **PASS theo bang chung runtime**
- DP-N02 Default count: **PASS (42)**
- DP-N03 Default class purity: **PASS (42/42 Near)**
- DP-N07 Hard concern exclusion: **PASS** — mask 15 chi gom bits 1+2+4+8
- DP-N08 MTF hard conflict exclusion: **PASS** — khong co code 4/5 trong Run A
- DP-N09 MTF code 6 allowed: **PASS (42/42)**
- DP-N10 Stage gate cho Run A: **PASS (42/42 Stage 1)**
- DP-N11 RS gate cho Run A: **PASS (42/42 RS code 1/2)**
- DP-N14 Presentation: **PASS theo TXT** — Vietnamese ASCII khong dau, khong mojibake

Chua du bang chung de danh dau full native PASS. Van can Run B audit va regression production de xac minh DP-N04, DP-N05, DP-N06, DP-N10/N11 tren toan audit, DP-N12 va DP-N13.

## Checkpoint

`DISCOVERY_PREWATCH_V01_NATIVE_RUN_A = PASS_42_OF_42`

`DISCOVERY_PREWATCH_V01_NATIVE = PARTIAL_WAITING_RUN_B_AND_REGRESSION`
