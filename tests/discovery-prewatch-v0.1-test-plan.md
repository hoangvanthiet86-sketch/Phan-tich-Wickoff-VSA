# Discovery / Pre-Watch v0.1 — Native Test Plan

**Trang thai:** RUN A + RUN B DA DAT; CHO PRODUCTION REGRESSION.

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
CHO PRODUCTION REGRESSION sau Discovery.

### DP-N13 — Production regression
Sau khi chay Discovery, Fast Scanner production tren cung snapshot phai van giu:
- All Eligible = 1,066;
- Filter 2 = 1 ma;
- ma do la `SNZ`;
- Candidate Class / Side / Stage / Phase / Family / MTF / RS / Review / MethodBlockMask khong thay doi.

Khong can chay lai DailyPublisher.

### DP-N14 — Presentation
PASS — Run A/Run B dung Vietnamese ASCII khong dau, khong mojibake.

### DP-N15 — No trading semantics
PASS theo static review; AFL khong co `Buy`, `Sell`, `Short`, `Cover`, `PositionScore`, score/ranking, probability/confidence.

## 5. Bang chung

- `docs/evidence/discovery-prewatch-v0.1-native-run-a-2026-09-14.md`
- `docs/evidence/discovery-prewatch-v0.1-native-run-b-2026-09-14.md`

Con lai can production regression Fast Scanner sau Discovery. Khong can gui lai Publisher output neu snapshot van hop le.

## 6. Trang thai

`DISCOVERY_PREWATCH_V01_NATIVE_RUN_A = PASS_42_OF_42`

`DISCOVERY_PREWATCH_V01_NATIVE_RUN_B = PASS_136_OF_136`

`DISCOVERY_PREWATCH_V01_NATIVE = PARTIAL_WAITING_PRODUCTION_REGRESSION`
