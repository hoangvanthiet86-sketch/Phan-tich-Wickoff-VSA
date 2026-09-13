# Discovery / Pre-Watch v0.1 — Native Test Plan

**Trang thai:** RUN A DA DAT; CHO RUN B + PRODUCTION REGRESSION.

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

Dua tren file Fast Scanner `All Eligible` da duoc xuat va doi chieu truoc khi viet AFL Discovery, tap 1,066 ma Data Eligible cho snapshot 11/09/2026 co reference classification sau khi ap dung dung quy tac spec v0.1:

- `DiscoveryBase`: 136 ma;
- `PRE_WATCH_NEAR`: 42 ma;
- `DISCOVERY_REVIEW_ONLY`: 93 ma;
- `PRODUCTION_WATCH_REFERENCE`: 1 ma;
- ma Production Watch tham chieu: `SNZ`.

42 ma `PRE_WATCH_NEAR` reference deu co:

- Candidate Stage = 1;
- RS vs Market thuoc {1,2};
- MTF Alignment = 6;
- Method Block Mask = 15;
- khong co concern bit {16,32,64,128,512,1024};
- khong co MTF code 4 hoac 5.

Day la **checkpoint theo snapshot 11/09/2026**, khong phai mot invariance cho moi ngay tuong lai.

## 4. Native acceptance

### DP-N01 — Compile

AFL compile tren AmiBroker 6.20.01 khong loi.

**Run A:** PASS theo bang chung runtime/native export.

### DP-N02 — Default count

Run A tra dung 42 dong tren snapshot 11/09/2026.

**Run A:** PASS — 42 dong / 42 ticker duy nhat.

### DP-N03 — Default class purity

100% dong Run A co `Trang thai Discovery = Pre-Watch Near`.

**Run A:** PASS — 42/42.

### DP-N04 — Audit count

Run B tra dung 136 dong tren snapshot 11/09/2026.

**Trang thai:** CHUA CHAY.

### DP-N05 — Audit distribution

Run B co phan bo:

- Near = 42;
- Review Only = 93;
- Production Watch Reference = 1.

**Trang thai:** CHUA CHAY.

### DP-N06 — SNZ continuity

`SNZ` phai xuat hien dung mot lan trong Run B voi:

- `Trang thai Discovery = Production Watch - doi chieu`;
- Production Candidate Class = WATCH / Theo doi;
- khong bi doi thanh Pre-Watch.

**Trang thai:** CHUA CHAY.

### DP-N07 — Hard concern exclusion

Khong dong `Pre-Watch Near` nao duoc co mot trong cac bit:

`16,32,64,128,512,1024`.

**Run A:** PASS — 42/42 mask = 15 (= 1+2+4+8).

### DP-N08 — MTF hard conflict exclusion

Khong dong `Pre-Watch Near` nao co MTF code 4 hoac 5.

**Run A:** PASS — 42/42 MTF = 6.

### DP-N09 — MTF code 6 allowed

MTF code 6 khong tu dong loai Pre-Watch; tren checkpoint 11/09/2026 ca 42 Near reference deu co MTF=6.

**Run A:** PASS — 42/42.

### DP-N10 — Stage gate

100% Near/ReviewOnly/ProductionWatchReference trong audit run phai co Stage=1.

**Run A:** PASS cho tap Near 42/42; cho Run B.

### DP-N11 — RS gate

100% audit rows phai co RS vs Market code 1 hoac 2.

**Run A:** PASS cho tap Near 42/42; cho Run B.

### DP-N12 — Snapshot read-only

Chay Discovery khong tao/doi Daily Snapshot generation, Ready, WriteComplete hay bat ky production payload nao.

**Trang thai:** cho regression/doi chieu production.

### DP-N13 — Production regression

Sau khi chay Discovery, Fast Scanner production tren cung snapshot van giu nguyen:

- All Eligible = 1,066;
- Filter 2 = 1 ma;
- ma do la `SNZ`;
- Candidate Class / Side / Stage / Phase / Family / MTF / RS / Review / MethodBlockMask khong thay doi.

Khong can chay lai DailyPublisher cho regression nay.

**Trang thai:** CHUA CHAY SAU DISCOVERY.

### DP-N14 — Presentation

Tieu de va text hien thi khong dau, khong co ky tu loi ma hoa tren AmiBroker 6.20.01.

**Run A:** PASS theo TXT export.

### DP-N15 — No trading semantics

AFL khong co `Buy`, `Sell`, `Short`, `Cover`, `PositionScore`, score/ranking, probability/confidence.

**Static implementation review:** PASS; van giu trong gate full native.

## 5. Bang chung can gui sau run

Run A evidence da luu tai:

`docs/evidence/discovery-prewatch-v0.1-native-run-a-2026-09-14.md`

Con lai can:

1. TXT Run B;
2. production regression Fast Scanner sau Discovery;
3. neu co loi compile: anh Error window co line number va message;
4. khong can gui lai Publisher output neu snapshot van hop le.

## 6. Dieu kien PASS

Chi duoc danh dau native PASS khi DP-N01 den DP-N15 deu dat hoac co giai trinh ro rang ve checkpoint snapshot da thay doi do ngay business date moi.

Trang thai hien tai:

`DISCOVERY_PREWATCH_V01_NATIVE_RUN_A = PASS_42_OF_42`

`DISCOVERY_PREWATCH_V01_NATIVE = PARTIAL_WAITING_RUN_B_AND_REGRESSION`
