# Runtime Parameters Vietnamese ASCII v0.2 — Native Test Plan

## 1. Muc tieu

Xac minh patch chi doi lop hien thi Parameters cua `WyckoffVSA_RuntimeConfig_v0.2.afl` sang tieng Viet khong dau, khong lam thay doi decision surface production va khong lam thay doi snapshot/config identity da khoa.

## 2. Pham vi patch

- Chi sua nhan/chuoi lua chon hien thi trong `afl/WyckoffVSA_RuntimeConfig_v0.2.afl`.
- Giu nguyen ten bien `WVRC_*`.
- Giu nguyen tat ca numeric default/min/max/step.
- Giu nguyen validation va orchestration logic.
- Hai canonical free-text adjustment-basis declaration payload defaults duoc GIU NGUYEN:
  - `ADJUSTED PRICE`;
  - `COMPATIBLE - DECLARED`.
- Ly do: cac payload provenance nay co the tham gia config/snapshot identity; khong dich gia tri noi bo chi de lam dep UI.
- Label cua hai field tren van la Vietnamese ASCII.

## 3. Luu y AmiBroker Param cache

AmiBroker co the luu gia tri Param theo nhan. Khi nhan Parameters bi doi ten, gia tri da luu truoc do co the tro ve default cua cung bien.

Do do day KHONG phai thay doi methodology, nhung nguoi van hanh phai kiem tra lai Parameters sau khi cai patch.

Dac biet checkpoint truoc khi sua cho thay `Production Filter = 4` trong cua so Parameters, trong khi default canonical cua `WVRC_ProductionFilterCode` van la `2 = Theo doi+`.

Vi vay:
- neu muon chay `Tat ca du dieu kien`, dat `1.2 Bo loc san xuat = 4`;
- neu muon chay `Theo doi+`, dat `1.2 Bo loc san xuat = 2`.

Khong doi default canonical 2 chi de giu gia tri cache 4.

## 4. Native acceptance

### VP-N01 — Parameters UI
Mo Parameters cua Fast Scanner/runtime production. Tat ca section, nhan va option do `RuntimeConfig_v0.2` tao ra phai la tieng Viet khong dau, gom cac nhom 01/02/03/06/07/08/09/10/90 va moi lua chon Khong/Co.

Chap nhan acronym ky thuat: `ATR`, `RVOL`, `VSA`, `P&F`.

Hai gia tri free-text canonical `ADJUSTED PRICE` va `COMPATIBLE - DECLARED` duoc phep giu nguyen vi la payload provenance/identity, khong phai label UI.

### VP-N02 — Gia tri cau hinh / identity
Xac nhan numeric default/range/step khong doi so voi runtime v0.2 da native-validated.

Dong thoi xac nhan:
- `6.3 Khai bao co so dieu chinh` mac dinh van la `ADJUSTED PRICE`;
- `9.5 Khai bao co so dieu chinh` mac dinh van la `COMPATIBLE - DECLARED`.

Khong duoc doi hai payload nay trong acceptance run.

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

### VP-N05 — Khong analytical/runtime identity drift
Neu VP-N03/04 khop checkpoint cu, snapshot van hop le ma khong republish, va hai canonical free-text payload khong doi thi patch duoc chot la presentation-only doi voi decision surface va runtime identity da test.

## 5. Checkpoint khi dat

`RUNTIME_PARAMETERS_V02_VIETNAMESE_ASCII = PASS`
