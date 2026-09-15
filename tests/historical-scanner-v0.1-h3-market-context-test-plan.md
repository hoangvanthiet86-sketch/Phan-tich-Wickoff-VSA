# Historical Scanner v0.1 — H3 Historical Market Context Test Plan

## Muc tieu

Chung minh benchmark thi truong duoc tai dung point-in-time theo tung ngay lich su, khong dung current `WVSA_SELCTX_v01_*` snapshot ap nguoc cho qua khu, va fail closed neu khong co dung ngay benchmark.

Control dau tien:
- Stock: `SNZ`
- Market benchmark: `VNINDEX`
- Periodicity: Daily

Khong co trading semantics.

## Tep

- `afl/WyckoffVSA_HistoricalMarketContextPublisher_v0.1.afl`
- `afl/WyckoffVSA_HistoricalMarketContextProof_v0.1.afl`

H3 publisher tai su dung H2B:
- `afl/WyckoffVSA_HistoricalTimeframeTimelinePublisher_v0.1.afl`
- `afl/WyckoffVSA_HistoricalMTFPayloadProof_v0.1.afl`

## UI / HS14

Tat ca Param/cot/status moi do H3 tao ra phai la tieng Viet khong dau.

Runtime modules cu co the van ke thua Parameters/diagnostic labels tieng Anh neu local `WyckoffVSA_RuntimeConfig_v0.2.afl` chua duoc cap nhat. Theo yeu cau chu du an, native H3 chi duoc coi la UI-acceptable sau khi patch Parameters tieng Viet cua PR #51 duoc cai local/merge va xac minh. Analytical H3 proof van tach biet voi presentation regression.

## Cai dat local

AmiBroker 6.20.01 native da xac nhan `#include_once` cua historical harness resolve qua `Formulas\Include`.

Can co ban local cua:
`WyckoffVSA_HistoricalMTFPayloadProof_v0.1.afl`
trong:
`C:\Program Files (x86)\AmiBroker\Formulas\Include\`

Cac runtime include v0.2 can giu nhu H2 native.

## Quy tac khoa ngay H3

Native B cho thay viec chuyen `DateNum()` sang so dang YYYYMMDD khoang 20 trieu lam mat bit don vi trong AFL float va tao collision giua nhieu ngay. Tu ban C:
- Publisher va Proof dung `DateNum()` goc lam `Khoa ngay`.
- `DateNum()` nam trong mien so nguyen duoc AFL float bieu dien chinh xac.
- Exact-date guard bat buoc ca `Khoa ngay co phieu == Khoa ngay thi truong` va `Ngay co phieu == Ngay nguon thi truong`.
- Khong duoc nghiem thu bang khoa YYYYMMDD tu tao.

## Trinh tu native

### H3-A1 — Ghi Weekly timeline cho VNINDEX

AFL:
`WyckoffVSA_HistoricalTimeframeTimelinePublisher_v0.1.afl`

- Apply to: `VNINDEX`
- Periodicity: `Weekly`
- Range: `1 recent bar`
- `1.1 Cho phep ghi timeline lich su = Co`
- Explore

Ky vong:
- `Khung nguon = W`
- `Trang thai ghi = Da ghi timeline`

### H3-A2 — Ghi Monthly timeline cho VNINDEX

Cung AFL tren:
- Apply to: `VNINDEX`
- Periodicity: `Monthly`
- Range: `1 recent bar`
- `1.1 Cho phep ghi timeline lich su = Co`
- Explore

Ky vong:
- `Khung nguon = M`
- `Trang thai ghi = Da ghi timeline`

### H3-A3 — Ghi Daily Market context timeline

AFL:
`WyckoffVSA_HistoricalMarketContextPublisher_v0.1.afl`

- Apply to: `VNINDEX`
- Periodicity: `Daily`
- Range: `1 recent bar`
- `7.1 Cho phep ghi boi canh thi truong lich su = Co`
- Explore

Ky vong:
- `Trang thai ghi = Da ghi timeline thi truong`
- `So ngay payload hop le > 0`
- phien ban `HISTORICAL_MARKET_CONTEXT_PUBLISHER_V01_20260914_C`

## H3-B — Point-in-time alignment tren SNZ

AFL:
`WyckoffVSA_HistoricalMarketContextProof_v0.1.afl`

- Apply to: `SNZ`
- Periodicity: `Daily`
- Range: From-To, nen dung 2019 den hien tai hoac mot doan dai du de co nhieu ngay
- `1.1 Ma thi truong doi chieu = VNINDEX`
- `1.2 Mo phong thieu du lieu thi truong = Khong`
- `1.3 Chi hien thi dong khong hop le = Khong`
- Explore va xuat TXT

### H3-N01 — Publisher hop le

Tai cac dong sau warm-up co source:
`Publisher thi truong san sang = Co`.

### H3-N02 — Exact date alignment

Moi dong duoc danh dau `Boi canh thi truong hop le = Co` phai co:
- `Khop dung ngay benchmark = Co`
- `Khoa ngay co phieu == Khoa ngay thi truong`
- `Ngay co phieu == Ngay nguon thi truong`
- `Nguon khong den tu tuong lai = Co`

Khong chap nhan forward-fill ngam tu ngay benchmark cu.

### H3-N03 — Payload validity

Moi dong hop le phai co:
- `Nguon benchmark hop le = Co`
- `Payload benchmark day du = Co`

### H3-N04 — Selection semantics

`Boi canh lua chon thi truong` phai tai dung dung semantics `WSCN_SelectionContext`:
- 0: khong du du lieu
- 1: trung tinh / chua ro
- 2: ho tro tang
- 3: ho tro giam
- 4: hon hop / xung dot

Khong co diem so/xep hang moi.

### H3-N05 — No current snapshot leakage

H3 proof/publisher khong doc `WVSA_SELCTX_v01_*` lam historical source.
Historical namespace duy nhat la `WVSA_HIST_MKT_v01_*` + H2 historical namespaces.

## H3-C — Missing benchmark fail-closed

Chay lai `WyckoffVSA_HistoricalMarketContextProof_v0.1.afl` tren SNZ cung Range, nhung:

- `1.2 Mo phong thieu du lieu thi truong = Co`
- `1.3 Chi hien thi dong khong hop le = Khong`

Acceptance:
- `Boi canh thi truong hop le = Khong`
- `Boi canh lua chon thi truong = Khong du du lieu`
- `Kiem tra fail closed dat = Co`
- `Trang thai H3 = Mo phong thieu benchmark - da fail closed`

### H3-N06 — Missing benchmark fail closed

Khong duoc giu lai Selection Context cua ngay truoc, khong duoc suy dien neutral/supportive khi benchmark bi thieu.

## Checkpoint

Neu H3-B va H3-C dat:

`HISTORICAL_SCANNER_V01_H3_MARKET_CONTEXT = PASS`

Sau H3 moi tiep tuc H4 Single-symbol Historical Scanner.
