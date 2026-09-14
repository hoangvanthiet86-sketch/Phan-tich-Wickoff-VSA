# Historical Scanner v0.1 — H6 Terminal / Universe Test Plan

## Muc tieu
Khoa acceptance cuoi cho Historical Scanner v0.1 theo HS11-HS13, khong thay methodology, threshold, enum, ReviewFlag, MethodBlockMask hay decision surface production.

Base H6: merge commit PR #55 `95b93efcf2b03d0fe55c2b805518af78ac6f3728`.

## H6-A — SNZ terminal exact (HS11)
Business date: `11/09/2026`.

Historical Scanner phai tai dung chinh xac:
- Class = 2
- Side = 0
- Stage = 1
- Phase = 2
- Family = 1
- Range Position = 0.3500
- MTF = 0
- RS = 2
- Review = 0
- Method Block Mask = 7

Khong chay lai H2/H3/H4/H5 neu code upstream khong thay doi.

Checkpoint du kien khi native dat:
`HISTORICAL_SCANNER_V01_H6A_SNZ_TERMINAL = PASS`

## H6-B — DTP / FRT controls (HS12)
DTP va FRT la control Review da khoa tu production evidence truoc day. H6 khong duoc tu suy doan expected state.

Truoc native run phai resolve expected class va diagnostic fields cua DTP/FRT tu evidence production da merge / checkpoint da khoa. Neu khong resolve duoc expected evidence thi dung o `NOT_VERIFIED`, khong duoc tu tao gia tri mong doi.

Historical terminal output phai giu dung class va diagnostic fields trong pham vi Market-only profile v0.1.

Checkpoint du kien khi native dat:
`HISTORICAL_SCANNER_V01_H6B_DTP_FRT_CONTROLS = PASS`

## H6-C — Universe terminal equivalence (HS13)
Muc tieu: cung business date `11/09/2026`, cung universe/config production da dung cho Performance Runtime.

Production checkpoint da khoa:
- Data Eligible symbols = 1066

Historical Scanner phai doi chieu tung symbol va tung field:
- DataEligible
- CandidateClass
- CandidateSide
- CandidateStage
- Phase
- Family
- RangePosition
- MTFAlignment
- RSvsMarket
- ScannerReview
- MethodBlockMask
- Market selection context trong pham vi profile v0.1

Acceptance:
1. Exact symbol set = 1066 symbols, hoac tao mismatch report day du.
2. Neu symbol set khac: bao missing/extra symbols.
3. Neu field khac: bao symbol, field, production value, historical value.
4. Khong duoc tuyen bo PASS neu con mismatch chua giai thich / chua resolve.
5. Full Top-Down Group van deferred; H6 chi khoa profile Market-only v0.1 theo dac ta.

Checkpoint du kien khi exact:
`HISTORICAL_SCANNER_V01_H6C_UNIVERSE_TERMINAL_EQUIVALENCE = PASS`

## H6-D — Presentation / HS14 debt
Truoc final acceptance Historical Scanner v0.1:
- UI moi phai tieng Viet ASCII khong dau;
- khong de redundant leading columns trong output nghiem thu;
- Null RangePosition khong hien sentinel so am lon;
- khong thay formula logic chi de sua presentation.

## Final gate
Chi khoa sau khi H6-A, H6-B, H6-C va presentation gate deu dat:
`HISTORICAL_SCANNER_V01_FINAL = PASS`

Khong Buy/Sell/Short/Cover/PositionScore/P&L trong H6.