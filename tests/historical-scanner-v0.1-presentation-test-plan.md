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

Da chay native tren AmiBroker 6.20.01 bang ban:

`HISTORICAL_SCANNER_V01_H4_20260916_B`

Formula compile va Explore thanh cong, khong co loi include/compile trong run native da nop.

Checkpoint:

`HISTORICAL_SCANNER_V01_PRESENTATION_FORMULA_NATIVE = PASS`

## P3 — Native display smoke

Khong rerun H2/H3/H4 publisher.

Native run:

- symbol: `SNZ`;
- Periodicity: Daily;
- Apply to: Current;
- Range: All quotes;
- Parameters -> `1.1 Che do loc lich su = Toan bo kiem tra`;
- Explore.

Ket qua native:

1. 1,971 dong du lieu, 17 cot explicit;
2. khong co cot mac dinh `Ticker` / `Date/Time` lap them;
3. hai cot dau do formula tao la `Ma co phieu`, `Ngay gio`;
4. header va text nguoi dung deu ASCII; acronym `MTF`, `RS` duoc giu;
5. khong con nhan `Watch`, `Review`, `Data gated`, `Stock publisher`, `Market context`, `point-in-time`, `Full Top-Down` trong output nguoi dung;
6. co 43 dong `Vi tri trong vung (%)` blank, khong co numeric sentinel cho state invalid/unknown;
7. 1,928 dong valid van hien phan tram binh thuong;
8. khong co cot `Buy`, `Sell`, `Short`, `Cover`, `PositionScore`, P&L;
9. SNZ tai 11/09/2026 van giu terminal control: eligible, Theo doi, side 0, Stage 1, Phase 2, Family 1, Range 35.00%, MTF 0, RS 2, Review 0, MethodBlockMask 7.

Checkpoint:

`HISTORICAL_SCANNER_V01_PRESENTATION_NATIVE = PASS`

## P4 — Final Historical Scanner gate

Merge order da hoan tat va duoc xac minh:

1. PR #56 H6 da merge vao `integration/wyckoff-vsa-production-candidate-v0.1` tai commit `4bad7e2eb09d794190a9eb3d04aa962067890f5c`;
2. PR #57 presentation cleanup da merge tren H6 integration head tai commit `6e097d9873e488f11a0763dc8ce1737401111541`;
3. diff `4bad7e2... -> 6e097d9...` chi gom presentation formula + presentation evidence/test plan, khong co thay doi methodology/decision semantics ngoai scope presentation;
4. strict HS13 van giu `NOT_EXACT_1063_OF_1066` voi accepted exception DMC/SBM/TV3 do data-vintage revision.

Final checkpoint:

`HISTORICAL_SCANNER_V01_FINAL = PASS_WITH_APPROVED_HS13_DATA_VINTAGE_EXCEPTION`

Khong duoc doi thanh strict `PASS_1066_OF_1066`; phe duyet ngoai le DMC/SBM/TV3 phai tiep tuc duoc ghi ro trong release evidence va final handoff.
