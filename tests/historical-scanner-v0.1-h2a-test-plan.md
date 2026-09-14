# Historical Scanner v0.1 — H2A Native Test Plan

## 1. Muc tieu

Kiem tra `WyckoffVSA_HistoricalMTFRolloverProof_v0.1.afl` tren AmiBroker 6.20.01 de xac nhan calendar availability boundary cua Weekly/Monthly truoc khi tai dung bat ky payload MTF nao.

H2A chi chung minh **moc thoi gian duoc phep xuat hien**, chua chung minh full Historical MTF payload.

## 2. Cau hinh chay

- AFL: `afl/WyckoffVSA_HistoricalMTFRolloverProof_v0.1.afl`
- Periodicity: Daily
- Apply to: mot ma co lich su du dai (uu tien SNZ; co the dung ma khac de proof calendar boundary)
- Range: mot khoang co it nhat 2 lan doi tuan va 2 lan doi thang
- Parameters:
  - `1.1 Dong hien thi = Chi ngay doi tuan / doi thang`

Khong can chay DailyPublisher, Timeframe Publisher hay Cross-Symbol Publisher.

## 3. Acceptance

### H2A-N01 — Bien dich
AFL bien dich tren AmiBroker 6.20.01 khong loi.

### H2A-N02 — Chi chay Daily
Moi dong output co `Interval()==inDaily`; neu khong phai Daily thi fail closed / khong co row hop le.

### H2A-N03 — Weekly boundary
Tai ngay dau tien co du lieu cua mot calendar week moi:
- `Doi tuan tai ngay nay = Co`;
- `Tuan da hoan tat gan nhat = Ma tuan hien tai - 1`;
- `Moc tuan hop le = Co`.

Trong cac ngay con lai cung calendar week:
- current weekly ordinal khong doi;
- expected-completed weekly ordinal khong doi.

### H2A-N04 — Monthly boundary
Tai ngay dau tien co du lieu cua calendar month moi:
- `Doi thang tai ngay nay = Co`;
- `Thang da hoan tat gan nhat = Ma thang hien tai - 1`;
- `Moc thang hop le = Co`.

Trong cac ngay con lai cung calendar month:
- current monthly ordinal khong doi;
- expected-completed monthly ordinal khong doi.

### H2A-N05 — Khong current snapshot leakage
Static review + native execution khong include/read:
- `WyckoffVSA_TimeframeSnapshot_Consumer_v0.1.afl`;
- `WyckoffVSA_DailySnapshotConsumer_v0.2.afl`;
- `WVSA_MTF_v01_*` StaticVars;
- `WVSA_SELCTX_v01_*` StaticVars.

### H2A-N06 — Khong claim payload equivalence
H2A output khong co Phase/Family/Directional/MTF category payload. PASS H2A khong duoc ghi thanh full H2 PASS.

### H2A-N07 — Tieng Viet UI
Toan bo nhan Parameter, lua chon Parameter, ten cot va status text do AFL tao ra la tieng Viet khong dau; cho phep acronym ky thuat `MTF`.

### H2A-N08 — Khong trading semantics
Khong `Buy`, `Sell`, `Short`, `Cover`, `PositionScore`, P&L hay ranking.

## 4. Bang chung can gui

Xuat TXT tu Exploration o che do `Chi ngay doi tuan / doi thang` cho khoang du lieu da chon.

Can it nhat:
- 2 dong doi tuan;
- 2 dong doi thang (co the trung voi dong doi tuan);
- tat ca row co `Moc tuan hop le = Co` va `Moc thang hop le = Co`.

## 5. Ket qua native 2026-09-14

AmiBroker 6.20.01 / SNZ / output version `HISTORICAL_MTF_ROLLOVER_PROOF_V01_20260914_A`.

- 485 dong boundary tu 27/11/2017 den 24/08/2026.
- 443 dong doi tuan.
- 105 dong doi thang.
- 63 dong vua doi tuan vua doi thang.
- 485/485 `Moc tuan hop le = Co`.
- 485/485 `Moc thang hop le = Co`.
- 485/485 `Trang thai kiem tra = Dat kiem tra moc doi`.
- 0 mismatch `Tuan da hoan tat gan nhat = Ma tuan hien tai - 1`.
- 0 mismatch `Thang da hoan tat gan nhat = Ma thang hien tai - 1`.

Bang chung: `docs/evidence/historical-scanner-v0.1-h2a-native-2026-09-14.md`.

## 6. Checkpoint

`HISTORICAL_SCANNER_V01_H2A_ROLLOVER_BOUNDARY = PASS`

H2A da dat. Tiep tuc H2B historical Weekly/Monthly payload reconstruction; chua duoc ghi H2 full PASS.
