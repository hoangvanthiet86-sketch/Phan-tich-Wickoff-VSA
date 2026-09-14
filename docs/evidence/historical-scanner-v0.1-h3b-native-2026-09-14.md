# Historical Scanner v0.1 — H3-B Native Evidence — 2026-09-14

## Pham vi

- Control stock: `SNZ`
- Market benchmark: `VNINDEX`
- Periodicity: Daily
- Range native: 2019-01-07 -> 2026-09-11
- Publisher: `HISTORICAL_MARKET_CONTEXT_PUBLISHER_V01_20260914_C`
- Proof: `HISTORICAL_MARKET_CONTEXT_PROOF_V01_20260914_C`

## H3-A3 publisher C

Native publisher tren VNINDEX:
- `So ngay payload hop le = 6254`
- `Trang thai ghi = Da ghi timeline thi truong`
- version = `HISTORICAL_MARKET_CONTEXT_PUBLISHER_V01_20260914_C`

## H3-B point-in-time proof

Tong so dong proof: `1800`.

Ket qua toan bo 1800 dong:
- Publisher san sang: `1800/1800`
- `Khoa ngay co phieu == Khoa ngay thi truong`: `1800/1800`
- `Ngay co phieu == Ngay nguon thi truong`: `1800/1800`
- `Nguon khong den tu tuong lai = Co`: `1800/1800`
- Payload benchmark day du: `1800/1800`
- Khoa ngay `DateNum()` duy nhat theo 1800 ngay: `1800/1800`, khong collision
- Khoa ngay stock dung chinh xac `DateNum()` native: `1800/1800`

Trang thai validity:
- `Hop le point-in-time`: `1783/1800`
- `Nguon benchmark khong hop le`: `17/1800`

17 dong source benchmark khong hop le deu fail closed dung:
- `Boi canh thi truong hop le = Khong`
- `Boi canh lua chon thi truong = Khong du du lieu`
- khong co source tu tuong lai
- khong co forward-fill ngam

Selection Context tren 1783 dong hop le:
- `Hon hop / xung dot`: `1783`

Khong co score/ranking/trading semantics moi.

## Static leakage check

H3 proof/publisher doc namespace lich su `WVSA_HIST_MKT_v01_*` va H2 historical source. Khong dung `WVSA_SELCTX_v01_*` current snapshot lam historical source.

## Ket luan

`HISTORICAL_SCANNER_V01_H3B_POINT_IN_TIME_ALIGNMENT = PASS`

H3 toan phan chua PASS cho den khi H3-C missing-benchmark fail-closed native dat.
