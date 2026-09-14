# Historical Scanner v0.1 — H2B Native Test Plan

## 1. Muc tieu

Kiem tra tai dung **payload Weekly/Monthly da hoan tat** va categorical MTF tren tung Daily bar ma khong doc current production snapshot.

H2B dung hai AFL:

1. `afl/WyckoffVSA_HistoricalTimeframeTimelinePublisher_v0.1.afl`
2. `afl/WyckoffVSA_HistoricalMTFPayloadProof_v0.1.afl`

H2B chi chay tren mot ma control truoc, uu tien `SNZ`.

## 2. Nguyen tac an toan

- Namespace lich su rieng: `WVSA_HIST_MTF_v01_*`.
- Cam ghi de `WVSA_MTF_v01_*` production namespace.
- Daily proof khong include/read `WyckoffVSA_TimeframeSnapshot_Consumer_v0.1.afl`.
- Daily proof khong include/read `WyckoffVSA_DailySnapshotConsumer_v0.2.afl`.
- Payload higher timeframe chi duoc nhan tu period co ordinal bang `current period - 1`.
- Source date cua payload phai nho hon Daily date dang danh gia.
- Khong co Buy/Sell/Short/Cover/PositionScore/P&L/ranking.
- Toan bo UI do hai AFL moi tao ra phai la tieng Viet khong dau theo HS14.

## 3. Cai dat cuc bo bat buoc truoc khi chay

Hai AFL H2B dung `#include_once <WyckoffVSA_HistoricalRuntimeDefaults_v0.1.afl>`.
Vi dung cu phap dau ngoac nhon, AmiBroker 6.20.01 tim tep nay trong thu muc Include, khong phai thu muc `Formulas\afl` cua entrypoint.

Can dat tep:

`WyckoffVSA_HistoricalRuntimeDefaults_v0.1.afl`

vao dung thu muc:

`C:\Program Files (x86)\AmiBroker\Formulas\Include\`

Cac runtime include v0.2 khac da duoc dung trong production runtime truoc do cung phai ton tai trong thu muc Include theo bo cai dat hien hanh.

Neu AmiBroker bao:

`Error 42: #include failed because the file does not exist`

va duong dan chi den `...\Formulas\Include\WyckoffVSA_HistoricalRuntimeDefaults_v0.1.afl`, day la **loi trien khai tep phu thuoc cuc bo**, khong phai loi Parameters va khong duoc tinh la native analytical failure.

Sau khi bo sung tep vao Include, dong va mo lai Formula/Analysis neu AmiBroker van giu cache loi, roi chay lai.

## 4. Trinh tu chay native

### Run B1 — Ghi timeline Tuan

AFL:
`WyckoffVSA_HistoricalTimeframeTimelinePublisher_v0.1.afl`

Cau hinh:

- Apply to: `SNZ`
- Periodicity: `Weekly`
- Range: `1 recent bar` la du; AFL van yeu cau all bars bang `SetBarsRequired`.
- Parameters:
  - `1.1 Cho phep ghi timeline lich su = Co`

Explore va xuat TXT.

Ky vong:

- `Khung nguon = W`
- `Trang thai ghi = Da ghi timeline`
- `So bar payload hop le > 0`

### Run B2 — Ghi timeline Thang

Dung cung AFL.

Cau hinh:

- Apply to: `SNZ`
- Periodicity: `Monthly`
- Range: `1 recent bar`
- `1.1 Cho phep ghi timeline lich su = Co`

Explore va xuat TXT.

Ky vong:

- `Khung nguon = M`
- `Trang thai ghi = Da ghi timeline`
- `So bar payload hop le > 0`

### Run B3 — Tai dung tren Daily

AFL:
`WyckoffVSA_HistoricalMTFPayloadProof_v0.1.afl`

Cau hinh:

- Apply to: `SNZ`
- Periodicity: `Daily`
- **Khong duoc de `Range = 1 recent bar`.** O che do `Chi ngay doi tuan / doi thang`, neu bar moi nhat khong phai ngay rollover thi AmiBroker se hien `No results` du H2B khong bi loi.
- Chon `Range = From-To dates` hoac tuong duong, khuyen nghi tu `01/01/2019` den ngay du lieu hien tai; toi thieu phai bao gom 2 rollover Tuan va 2 rollover Thang.
- Parameters:
  - `1.1 Dong hien thi = Chi ngay doi tuan / doi thang`

Explore va xuat TXT.

Neu van `No results` sau khi Range da mo rong, chuyen tam thoi `1.1 Dong hien thi = Tat ca ngay co payload` de chan doan timeline/payload; khong dung che do nay de thay the acceptance rollover.

## 5. Acceptance

### H2B-N01 — Publisher Tuan native

Run B1 bien dich va commit timeline Tuan thanh cong.

### H2B-N02 — Publisher Thang native

Run B2 bien dich va commit timeline Thang thanh cong.

### H2B-N03 — Namespace cach ly

Source review xac nhan chi ghi `WVSA_HIST_MTF_v01_*`; khong ghi `WVSA_MTF_v01_*`.

### H2B-N04 — Previous completed Weekly

Tai moi dong co `Payload Tuan hop le = Co`:

- `Tuan payload da chon = Tuan can dung`;
- `Ngay nguon Tuan < Ngay du lieu`.

Neu source weekly period can dung khong ton tai, phai fail closed thay vi lay period khac.

### H2B-N05 — Previous completed Monthly

Tai moi dong co `Payload Thang hop le = Co`:

- `Thang payload da chon = Thang can dung`;
- `Ngay nguon Thang < Ngay du lieu`.

Neu source monthly period can dung khong ton tai, phai fail closed.

### H2B-N06 — Payload categorical hop le

Khi W/M valid, cac truong:

- so vung;
- pha;
- gia thuyet;
- huong;

phai den tu historical timeline da chon, khong tu current snapshot.

### H2B-N07 — MTF categorical behavioral equivalence

Cong thuc `MTF - dong thuan huong`, `MTF - dong thuan bang chung`, `MTF - quan he pha` va `MTF - ma xung dot` phai giu dung branching semantics cua `WyckoffVSA_MultiTimeframeContext_v0.1.afl`, nhung chay bar-by-bar tren Daily arrays + historical W/M payload.

PASS H2B-N07 chi xac nhan implementation semantics va native execution tren control symbol; universe/terminal-date exact equivalence van thuoc H6.

### H2B-N08 — Khong current snapshot leakage

Daily proof khong doc:

- `WVSA_MTF_v01_*`;
- `WVSA_SELCTX_v01_*`;
- `WyckoffVSA_TimeframeSnapshot_Consumer_v0.1.afl`;
- `WyckoffVSA_DailySnapshotConsumer_v0.2.afl`.

### H2B-N09 — Tieng Viet UI

Toan bo Param, lua chon Param, ten cot, status va canh bao do H2B AFL tao ra la tieng Viet khong dau. Cac acronym ky thuat nhu `MTF` duoc phep giu nguyen.

### H2B-N10 — Khong trading semantics

Khong Buy/Sell/Short/Cover/PositionScore/P&L/ranking.

### H2B-N11 — Phu thuoc local da trien khai dung vi tri

`WyckoffVSA_HistoricalRuntimeDefaults_v0.1.afl` phai duoc AmiBroker resolve tu `Formulas\Include`. Loi Error 42 do thieu tep include la setup/deployment failure, khong phai analytical failure.

## 6. Bang chung can gui

Gui 3 TXT:

- Run B1 Weekly publisher;
- Run B2 Monthly publisher;
- Run B3 Daily payload proof.

Neu Run B3 co nhieu dong, khong can cat bot; gui toan bo TXT de kiem tra ordinal/source-date va phan bo MTF.

## 7. Checkpoint khi dat

`HISTORICAL_SCANNER_V01_H2B_PAYLOAD_RECONSTRUCTION = PASS`

Sau H2B moi tiep tuc H2C/terminal MTF comparison va sau do H3 Historical Market context.
