# Historical Scanner v0.1 — H3-C native evidence — 2026-09-14

## Pham vi

- Stock: `SNZ`
- Benchmark: `VNINDEX`
- Periodicity: Daily
- Range: 2019-01-07 -> 2026-09-11
- AFL: `WyckoffVSA_HistoricalMarketContextProof_v0.1.afl`
- Version native da chay: `HISTORICAL_MARKET_CONTEXT_PROOF_V01_20260914_C`
- `1.2 Mo phong thieu du lieu thi truong = Co`
- `1.3 Chi hien thi dong khong hop le = Khong`

## Ket qua tren 1,800 dong

- `Boi canh thi truong hop le = Khong`: 1800/1800.
- `Boi canh lua chon thi truong = Khong du du lieu`: 1800/1800.
- `Kiem tra fail closed dat = Co`: 1800/1800.
- `Khop dung ngay benchmark = Co`: 1800/1800.
- `Nguon khong den tu tuong lai = Co`: 1800/1800.
- `Payload benchmark day du = Co`: 1800/1800.

Ve semantics fail-closed, H3-C dat tren toan bo 1,800 dong.

## Sai khac diagnostic phat hien

`Trang thai H3` co:
- `Mo phong thieu benchmark - da fail closed`: 1783 dong.
- `Nguon benchmark khong hop le`: 17 dong.

17 dong nay chinh la cac dong source benchmark goc da invalid trong H3-B. Cac dong van fail closed dung ve semantics (`Boi canh thi truong hop le = Khong`, selection = `Khong du du lieu`, fail-closed pass = `Co`), nhung status diagnostic bi source-invalid uu tien truoc simulated-missing.

Theo acceptance H3-C da khoa, khi toggle mo phong thieu benchmark bat thi status phai la `Mo phong thieu benchmark - da fail closed`. Vi vay chua khoa H3 full PASS bang version C.

## Sua diagnostic — version D

Da sua `WyckoffVSA_HistoricalMarketContextProof_v0.1.afl`:
- giu nguyen `HMP_BaseValid`, `HMP_EffectiveValid`, `HMP_SelectionContext` va fail-closed semantics;
- chi doi uu tien `HMP_StatusCode` de `HMP_SimulateMissing` duoc bao la status 6 sau hai dieu kien ha tang toi thieu: Daily interval va publisher san sang;
- version moi: `HISTORICAL_MARKET_CONTEXT_PROOF_V01_20260914_D`.

Khong thay methodology, market-selection semantics, historical namespace hay trading semantics.

## Native con lai

Chi can chay lai H3-C Proof version D tren cung SNZ / Daily / cung Range. Khong can rerun Publisher, Weekly, Monthly hay H3-B.

Acceptance cuoi:
- 1800/1800 `Boi canh thi truong hop le = Khong`;
- 1800/1800 `Boi canh lua chon thi truong = Khong du du lieu`;
- 1800/1800 `Kiem tra fail closed dat = Co`;
- 1800/1800 `Trang thai H3 = Mo phong thieu benchmark - da fail closed`;
- version `HISTORICAL_MARKET_CONTEXT_PROOF_V01_20260914_D`.
