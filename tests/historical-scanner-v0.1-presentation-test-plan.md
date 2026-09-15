# Historical Scanner v0.1 — Presentation Test Plan

## Muc tieu

Nghiem thu lop hien thi cuoi cho `WyckoffVSA_HistoricalScanner_v0.1.afl` sau khi H6 da duoc chap nhan voi data-vintage exception.

Presentation-only. Khong thay methodology, threshold, enum, Review, MethodBlockMask hay decision semantics.

## P1 — Static diff gate

Base: H6 accepted head `184db8e833919b7fd126ecc57dc726a1782bd81c`.

Yeu cau:

- chi sua output/presentation va tai lieu;
- co `SetOption("NoDefaultColumns",True)`;
- khong sua cac bieu thuc tinh `H4_DataEligible`, `H4_Review`, `H4_MethodBlockMask`, `H4_CandidateClass`, `H4_CandidateSide`;
- khong them trading variables.

Checkpoint:

`HISTORICAL_SCANNER_V01_PRESENTATION_STATIC = PASS`

## P2 — Native syntax / formula

Mo ban moi cua:

`afl/WyckoffVSA_HistoricalScanner_v0.1.afl`

tren AmiBroker 6.20.01 va Verify Syntax/Formula.

Yeu cau: khong loi compile/include.

## P3 — Native display smoke

Khong rerun H2/H3/H4 publisher.

Chay:

- symbol: `SNZ`;
- Periodicity: Daily;
- Apply to: Current;
- Range: All quotes;
- Parameters -> `1.1 Che do loc lich su = Toan bo kiem tra`;
- Explore.

Kiem tra:

1. khong co cot mac dinh `Ticker` / `Date/Time` lap them;
2. hai cot dau do formula tao la `Ma co phieu`, `Ngay gio`;
3. cac nhan nguoi dung la tieng Viet ASCII, ngoai acronym `MTF`, `RS`;
4. khong con nhan `Watch`, `Review`, `Data gated`, `Stock publisher`, `Market context`, `point-in-time`, `Full Top-Down` trong output nguoi dung;
5. dong co `RangePositionValid != 1` hien `Vi tri trong vung (%)` rong/blank, khong hien sentinel so am lon;
6. dong hop le van hien gia tri phan tram binh thuong;
7. khong co `Buy`, `Sell`, `Short`, `Cover`, `PositionScore`, P&L.

Checkpoint neu dat:

`HISTORICAL_SCANNER_V01_PRESENTATION_NATIVE = PASS`

## P4 — Final Historical Scanner gate

Chi sau khi P2 + P3 PASS va H6 acceptance da duoc merge vao integration:

`HISTORICAL_SCANNER_V01_FINAL = PASS_WITH_APPROVED_HS13_DATA_VINTAGE_EXCEPTION`

Khong duoc doi thanh strict `PASS_1066_OF_1066`; phe duyet ngoai le DMC/SBM/TV3 phai tiep tuc duoc ghi ro trong release evidence.
