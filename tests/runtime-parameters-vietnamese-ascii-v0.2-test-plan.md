# Runtime Parameters Vietnamese ASCII v0.2 — Native Test Plan

## 1. Muc tieu

Xac minh patch chi doi lop hien thi Parameters cua `WyckoffVSA_RuntimeConfig_v0.2.afl` sang tieng Viet khong dau, khong lam thay doi decision surface production.

## 2. Pham vi patch

- Chi sua `afl/WyckoffVSA_RuntimeConfig_v0.2.afl`.
- Giu nguyen ten bien `WVRC_*`.
- Giu nguyen tat ca numeric default/min/max/step.
- Giu nguyen validation va orchestration logic.
- Hai default text declaration duoc dich sang tieng Viet de khong con chuoi UI tieng Anh; cac chuoi nay la provenance/declaration text, khong tham gia dieu kien phan loai. Adjustment-basis validity van do status code so hoc quyet dinh.

## 3. Luu y AmiBroker Param cache

AmiBroker co the luu gia tri Param theo nhan. Khi nhan Parameters bi doi ten, gia tri da luu truoc do co the tro ve default moi cua cung bien.

Do do day KHONG phai thay doi methodology, nhung nguoi van hanh phai kiem tra lai Parameters sau khi cai patch.

Dac biet checkpoint truoc khi sua cho thay `Production Filter = 4` trong cua so Parameters, trong khi default canonical cua `WVRC_ProductionFilterCode` van la `2 = Theo doi+`.

Vi vay:
- neu muon chay `Tat ca du dieu kien`, dat `1.2 Bo loc san xuat = 4`;
- neu muon chay `Theo doi+`, dat `1.2 Bo loc san xuat = 2`.

Khong doi default canonical 2 chi de giu gia tri cache 4.

## 4. Native acceptance

### VP-N01 — Parameters UI
Mo Parameters cua Fast Scanner/runtime production. Tat ca nhan do `RuntimeConfig_v0.2` tao ra phai la tieng Viet khong dau, gom cac nhom 01/02/03/06/07/08/09/10/90 va moi lua chon Khong/Co.

Chap nhan acronym ky thuat: `ATR`, `RVOL`, `VSA`, `P&F`.

### VP-N02 — Gia tri cau hinh
Xac nhan numeric default/range/step khong doi so voi runtime v0.2 da native-validated.

### VP-N03 — Fast Scanner All Eligible regression
Khong chay lai DailyPublisher. Tren cung snapshot 11/09/2026:
- dat `1.2 Bo loc san xuat = 4`;
- `Apply to = VN STOCKS ONLY`;
- Daily / 1 recent bar;
- ky vong 1,066 ticker duy nhat.

### VP-N04 — Fast Scanner Watch+ regression
- dat `1.2 Bo loc san xuat = 2`;
- cung snapshot/universe;
- ky vong duy nhat `SNZ` voi:
  Class=2, Side=0, Stage=1, Phase=2, Family=1, Range=0.3500, MTF=0, RS=2, Review=0, MethodBlockMask=7.

### VP-N05 — Khong analytical drift
Neu VP-N03/04 khop checkpoint cu thi patch duoc chot la presentation-only doi voi decision surface da test.

## 5. Checkpoint khi dat

`RUNTIME_PARAMETERS_V02_VIETNAMESE_ASCII = PASS`
