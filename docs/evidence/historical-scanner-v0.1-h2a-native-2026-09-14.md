# Historical Scanner v0.1 — H2A Native Evidence

**Ngay ghi nhan:** 2026-09-14  
**Moi truong:** AmiBroker 6.20.01  
**Ma kiem tra:** `SNZ`  
**AFL:** `afl/WyckoffVSA_HistoricalMTFRolloverProof_v0.1.afl`  
**Phien ban output:** `HISTORICAL_MTF_ROLLOVER_PROOF_V01_20260914_A`

## 1. Du lieu native

Nguoi dung xuat Exploration TXT voi che do:

`1.1 Dong hien thi = Chi ngay doi tuan / doi thang`

Tap ket qua co 485 dong du lieu, tu 27/11/2017 den 24/08/2026.

Phan ra:

- dong doi tuan = 443;
- dong doi thang = 105;
- dong vua doi tuan vua doi thang = 63;
- chi doi tuan = 380;
- chi doi thang = 42;
- dong khong co bat ky rollover nao = 0.

Toan bo 485/485 dong:

- `Moc tuan hop le = Co`;
- `Moc thang hop le = Co`;
- `Trang thai kiem tra = Dat kiem tra moc doi`;
- `Tuan da hoan tat gan nhat = Ma tuan hien tai - 1`;
- `Thang da hoan tat gan nhat = Ma thang hien tai - 1`;
- cung phien ban `HISTORICAL_MTF_ROLLOVER_PROOF_V01_20260914_A`.

Khong co mismatch ordinal nao trong 485 dong.

## 2. Doi chieu acceptance H2A

### H2A-N01 — Bien dich
PASS. Exploration da chay native va xuat du lieu.

### H2A-N02 — Chi chay Daily
PASS trong run native nay: harness chay tren Daily va output dung contract Daily.

### H2A-N03 — Weekly boundary
PASS. 443 rollover tuan duoc ghi nhan; tat ca co previous completed weekly ordinal = current weekly ordinal - 1 va `Moc tuan hop le = Co`.

### H2A-N04 — Monthly boundary
PASS. 105 rollover thang duoc ghi nhan; tat ca co previous completed monthly ordinal = current monthly ordinal - 1 va `Moc thang hop le = Co`.

### H2A-N05 — Khong current snapshot leakage
PASS theo static source review cua harness: khong include/read current Timeframe Snapshot Consumer, Daily Snapshot Consumer, `WVSA_MTF_v01_*` hoac `WVSA_SELCTX_v01_*` lam nguon state.

### H2A-N06 — Khong claim payload equivalence
PASS. Output chi co calendar/ordinal boundary; khong co Phase/Family/Directional/MTF payload.

### H2A-N07 — Tieng Viet UI
PASS. Parameter, lua chon, ten cot va status do AFL H2A tao ra deu la tieng Viet khong dau; `MTF` duoc giu nhu acronym ky thuat.

### H2A-N08 — Khong trading semantics
PASS. Harness khong co `Buy`, `Sell`, `Short`, `Cover`, `PositionScore`, P&L hay ranking.

## 3. Pham vi ket luan

H2A chi chung minh **calendar availability boundary** cho previous calendar-completed Weekly/Monthly period tren tung Daily bar.

H2A KHONG chung minh:

- payload Weekly/Monthly lich su da duoc tai dung dung;
- categorical MTF alignment da duoc tai dung dung;
- truncation invariance cua Phase/Composite/RS;
- terminal-date decision-surface equivalence.

Cac muc tren thuoc H2B/H5/H6.

## 4. Checkpoint

`HISTORICAL_SCANNER_V01_H2A_ROLLOVER_BOUNDARY = PASS`

Buoc tiep theo duoc phep: H2B historical Weekly/Monthly payload reconstruction.
