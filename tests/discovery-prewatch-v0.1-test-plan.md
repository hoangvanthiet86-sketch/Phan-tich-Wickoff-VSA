# Discovery / Pre-Watch v0.1 — Native Test Plan

**Trang thai:** FULL NATIVE PASS.

**Dac ta:** `docs/wyckoff-vsa-discovery-prewatch-v0.1-spec.md`

**AFL:** `afl/WyckoffVSA_DiscoveryPreWatch_v0.1.afl`

**Moi truong dich:** AmiBroker 6.20.01, Daily.

## 1. Muc tieu

Xac minh AFL Discovery / Pre-Watch v0.1:

1. bien dich va chay duoc tren AmiBroker 6.20.01;
2. chi doc Daily Snapshot, khong chay heavy stack va khong ghi snapshot;
3. phan loai dung `PRE_WATCH_NEAR`, `DISCOVERY_REVIEW_ONLY`, `PRODUCTION_WATCH_REFERENCE` theo dac ta;
4. khong lam thay doi Production Scanner decision surface;
5. hien thi tieng Viet khong dau de tranh loi ma hoa.

## 2. Cau hinh native

Dung snapshot hien co, KHONG chay lai DailyPublisher chi de test Discovery.

- `Apply to`: `VN STOCKS ONLY`
- `Periodicity`: Daily
- `Range`: 1 recent bar
- AFL: `WyckoffVSA_DiscoveryPreWatch_v0.1.afl`

Chay hai lan:

### Run A — mac dinh
`Discovery: che do hien thi = Chi Pre-Watch Near`

### Run B — audit
`Discovery: che do hien thi = Tat ca Discovery`

Sau Run A/Run B, chay regression nhe tren `WyckoffVSA_FastScanner_v0.2.afl`:

- Filter 4 — All Eligible;
- Filter 2 — Watch + Developing + Qualified.

## 3. Checkpoint tham chieu cho snapshot 11/09/2026

- `DiscoveryBase`: 136 ma;
- `PRE_WATCH_NEAR`: 42 ma;
- `DISCOVERY_REVIEW_ONLY`: 93 ma;
- `PRODUCTION_WATCH_REFERENCE`: 1 ma;
- Production Watch tham chieu: `SNZ`.

42 ma `PRE_WATCH_NEAR` reference deu co:
- Candidate Stage = 1;
- RS vs Market thuoc {1,2};
- MTF Alignment = 6;
- Method Block Mask = 15;
- khong co concern bit {16,32,64,128,512,1024};
- khong co MTF code 4 hoac 5.

Day la checkpoint theo snapshot 11/09/2026, khong phai invariance cho moi ngay tuong lai.

## 4. Native acceptance

### DP-N01 — Compile
PASS theo native Run A/Run B.

### DP-N02 — Default count
PASS — Run A = 42 dong / 42 ticker duy nhat.

### DP-N03 — Default class purity
PASS — Run A 42/42 = `Pre-Watch Near`.

### DP-N04 — Audit count
PASS — Run B = 136 dong / 136 ticker duy nhat.

### DP-N05 — Audit distribution
PASS — Run B:
- Near = 42;
- Review Only = 93;
- Production Watch Reference = 1.

### DP-N06 — SNZ continuity
PASS — `SNZ` xuat hien dung mot lan:
- Discovery = `Production Watch - doi chieu`;
- Production Candidate Class = WATCH / `Theo doi`;
- Production Review = `Khong`;
- khong bi doi thanh Pre-Watch.

### DP-N07 — Hard concern exclusion
PASS — khong dong `Pre-Watch Near` nao co bit {16,32,64,128,512,1024}. Run A 42/42 mask = 15.

### DP-N08 — MTF hard conflict exclusion
PASS — khong dong Near nao co MTF code 4 hoac 5.

### DP-N09 — MTF code 6 allowed
PASS — 42/42 Near co MTF code 6 tren checkpoint nay.

### DP-N10 — Stage gate
PASS — 136/136 audit rows co Stage=1.

### DP-N11 — RS gate
PASS — 136/136 audit rows co RS vs Market code 1 hoac 2.

### DP-N12 — Snapshot read-only
PASS theo production regression sau Discovery:
- Fast Scanner All Eligible van = 1,066 unique ticker;
- 1,066/1,066 Snapshot Status = 1 va Data Eligible = 1;
- version van `FAST_SCANNER_V02_20260913_A`;
- khong co dau hieu Discovery ghi de hay lam thay doi production snapshot payload.

### DP-N13 — Production regression
PASS sau Discovery tren cung snapshot:
- All Eligible = 1,066;
- Candidate Class distribution = Review 1,051 / Not Current Candidate 14 / Watch 1;
- Filter 2 = 1 ma;
- ma do la `SNZ`;
- SNZ giu nguyen Candidate Class=2, Side=0, Stage=1, Phase=2, Family=1, Range Position=0.3500, MTF=0, RS=2, Review=0, MethodBlockMask=7.

Khong chay lai DailyPublisher.

### DP-N14 — Presentation
PASS — Run A/Run B dung Vietnamese ASCII khong dau, khong mojibake.

### DP-N15 — No trading semantics
PASS theo static review; AFL khong co `Buy`, `Sell`, `Short`, `Cover`, `PositionScore`, score/ranking, probability/confidence.

## 5. Bang chung

- `docs/evidence/discovery-prewatch-v0.1-native-run-a-2026-09-14.md`
- `docs/evidence/discovery-prewatch-v0.1-native-run-b-2026-09-14.md`
- `docs/evidence/discovery-prewatch-v0.1-native-production-regression-2026-09-14.md`

## 6. Trang thai

`DISCOVERY_PREWATCH_V01_NATIVE_RUN_A = PASS_42_OF_42`

`DISCOVERY_PREWATCH_V01_NATIVE_RUN_B = PASS_136_OF_136`

`DISCOVERY_PREWATCH_V01_PRODUCTION_REGRESSION = PASS_1066_AND_SNZ`

`DISCOVERY_PREWATCH_V01_NATIVE = PASS`

Native PASS nay chi xac nhan implementation Discovery / Pre-Watch v0.1 va tinh read-only tren checkpoint snapshot 11/09/2026. No khong thay doi methodology, Production Scanner acceptance, hay release acceptance khac cua du an.
