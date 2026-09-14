# Historical Scanner v0.1 — H2B Native Evidence — 2026-09-14

## Pham vi

Control symbol: `SNZ`.
AmiBroker: 6.20.01.
H2B version B3: `HISTORICAL_MTF_PAYLOAD_PROOF_V01_20260914_B`.

Muc tieu: xac minh tai dung payload Tuan/Thang da hoan tat va categorical MTF tren Daily history ma khong doc current production timeframe snapshot lam historical source.

## B1 — Historical Weekly timeline publisher

Native output:
- `Khung nguon = W`
- `Tong so bar = 446`
- `So bar payload hop le = 446`
- `Trang thai ghi = Da ghi timeline`
- version `HISTORICAL_TF_TIMELINE_PUBLISHER_V01_20260914_A`

Ket luan: `H2B-N01 = PASS`.

## B2 — Historical Monthly timeline publisher

Native output:
- `Khung nguon = M`
- `Tong so bar = 107`
- `So bar payload hop le = 107`
- `Trang thai ghi = Da ghi timeline`
- version `HISTORICAL_TF_TIMELINE_PUBLISHER_V01_20260914_A`

Ket luan: `H2B-N02 = PASS`.

## B3 — Daily historical payload reconstruction

Native output co 485 dong boundary.

Phan bo contract:
- `Payload Tuan hop le = Co`: 471/485
- `Payload Thang hop le = Co`: 484/485
- `Dat tai dung payload va MTF`: 470/485
- `Chua du payload da hoan tat`: 15/485

Tai 471 dong Weekly valid:
- `Tuan payload da chon == Tuan can dung`: 471/471
- `Ngay nguon Tuan < Ngay du lieu`: 471/471
- mismatch ordinal: 0
- future/same-day source: 0

Tai 484 dong Monthly valid:
- `Thang payload da chon == Thang can dung`: 484/484
- `Ngay nguon Thang < Ngay du lieu`: 484/484
- mismatch ordinal: 0
- future/same-day source: 0

15 dong khong du payload deu fail closed. Trong do:
- 1 dong dau chuoi chua co previous completed Monthly payload;
- 14 dong Weekly khong co dung calendar period can dung trong source timeline, nen selected ordinal cu hon expected ordinal va `Payload Tuan hop le = Khong` thay vi tu dong lay period gan nhat khac.

Khong co dong nao duoc danh dau `Dat tai dung payload va MTF` khi mot trong hai payload W/M invalid.

## Kiem tra branching categorical

Recompute doc lap tu cac cot native hien thi tren toan bo 485 dong:
- `MTF - dong thuan huong`: 0 mismatch
- `MTF - quan he pha`: 0 mismatch

Phan bo output:
- MTF huong = `MTF hon hop / phuc tap`: 393
- MTF huong = `Khong du du lieu MTF`: 92

- MTF pha = `Nhieu vung / khong ro`: 332
- `Khong du du lieu`: 90
- `Pha phan ky`: 52
- `Cung trang thai pha`: 6
- `Ngay muon hon ve cau truc`: 4
- `Ngay som hon ve cau truc`: 1

Source review xac nhan B3 branching giu semantics cua `WyckoffVSA_MultiTimeframeContext_v0.1.afl` va historical namespace tach rieng `WVSA_HIST_MTF_v01_*`.

## UI / HS14

Cac cot va status do H2B harness them vao deu la tieng Viet khong dau. Tuy nhien heavy runtime modules duoc include van mang theo cac cot diagnostic legacy tieng Anh. Day la presentation debt khong anh huong analytical result, nhung chua duoc coi la hoan tat yeu cau giao dien toan bo bo loc. PR #51 dang tach rieng viec Viet hoa Parameters production; viec giam/hide legacy diagnostic columns se duoc xu ly truoc final Historical Scanner UI acceptance.

## Checkpoint

Analytical H2B payload reconstruction:

`HISTORICAL_SCANNER_V01_H2B_PAYLOAD_RECONSTRUCTION = PASS`

Presentation/UI acceptance cua Historical Scanner van chua final.
