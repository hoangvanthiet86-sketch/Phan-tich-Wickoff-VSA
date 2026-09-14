# Historical Scanner v0.1 — H6 Terminal / Universe Test Plan

## Muc tieu
Khoa acceptance cuoi cho Historical Scanner v0.1 theo HS11-HS13, khong thay methodology, threshold, enum, ReviewFlag, MethodBlockMask hay decision surface production.

Base H6: merge commit PR #55 `95b93efcf2b03d0fe55c2b805518af78ac6f3728`.

## H6-0 — Prerequisite audit truoc khi rerun nang
Formula: `afl/WyckoffVSA_HistoricalH6PrerequisiteAudit_v0.1.afl`.

Muc dich: doc StaticVar-only de xac dinh dung phan nao con thieu, tranh rerun H2/H3/H4 khong can thiet.

Chay tren watchlist `VN STOCKS ONLY`, Daily, 1 recent bar, Explore. Output mot dong/symbol va kiem tra:
- production snapshot 11/09/2026;
- production Data Eligible;
- H2 Weekly ready;
- H2 Monthly ready;
- H4 stock timeline ready + co business date 11/09/2026;
- H3 Market ready + co business date 11/09/2026.

Sau audit moi quyet dinh publisher nao can rerun. Khong tu dong rerun H3 neu Market timeline da san sang.

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

Checkpoint du kien khi native dat:
`HISTORICAL_SCANNER_V01_H6A_SNZ_TERMINAL = PASS`

## H6-B — DTP / FRT controls (HS12)
Production oracle da resolve tu evidence merged; xem `docs/evidence/historical-scanner-v0.1-h6-production-oracle.md`.

DTP expected fields duoc evidence khoa:
- Candidate Class = 9 / Review
- Scanner Review = 1
- Method Block Mask = 1031
- Range Position xap xi -2.3027

FRT expected fields duoc evidence khoa:
- Candidate Class = 9 / Review
- Scanner Review = 1
- Method Block Mask = 1031
- Range Position xap xi -0.7363

Range reference DTP/FRT chi la `about` trong evidence nen control-reference check dung tolerance 0.005. Day khong phai tolerance equivalence. Historical-vs-production RangePosition tai H6-C van dung float tolerance 0.0001.

Khong tu suy doan Side/Stage/Phase/Family/MTF/RS cua DTP/FRT. Cac field nay phai so sanh truc tiep voi production snapshot.

Checkpoint du kien khi native dat:
`HISTORICAL_SCANNER_V01_H6B_DTP_FRT_CONTROLS = PASS`

## H6-C — Universe terminal equivalence (HS13)
Formula: `afl/WyckoffVSA_HistoricalTerminalEquivalence_v0.1.afl`.

Muc tieu: business date `11/09/2026`, universe/config production cua Performance Runtime stock-only.

Production checkpoint da khoa:
- watchlist VN STOCKS ONLY = 1668 symbols
- Data Eligible = 1066 symbols
- Business DateNum = 1260911

Probe chi dung production persistent snapshot / selection snapshot lam oracle so sanh. Production oracle KHONG duoc cap nguon cho historical decision.

So sanh tung symbol va tung field:
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
- Market selection context

Acceptance:
1. Output union `production eligible OR historical eligible` phai cho exact symbol set 1066 neu khong co mismatch universe.
2. Neu symbol set khac: xuat missing/extra qua field DataEligible va status.
3. Tat ca cot `Khop ...` = Co cho 1066 symbols.
4. `Khop tat ca = Co` cho 1066/1066.
5. SNZ, DTP, FRT control status = `Dat control da khoa`.
6. Neu bat ky field khac: khong tuyen bo PASS; giu mismatch report de phan tich.
7. Full Top-Down Group deferred; H6 chi khoa Market-only profile v0.1.

Checkpoint du kien khi exact:
`HISTORICAL_SCANNER_V01_H6C_UNIVERSE_TERMINAL_EQUIVALENCE = PASS_1066_OF_1066`

## Publisher workflow neu H6-0 cho thay thieu timeline
Chi chay phan thieu, theo thu tu:
1. `WyckoffVSA_HistoricalTimeframeTimelinePublisher_v0.1.afl` tren `VN STOCKS ONLY`, Weekly, write = Co.
2. Cung formula tren `VN STOCKS ONLY`, Monthly, write = Co.
3. `WyckoffVSA_HistoricalStockTimelinePublisher_v0.1.afl` tren `VN STOCKS ONLY`, Daily, write = Co.
4. Khong rerun H3 Market neu audit xac nhan H3 Market 11/09 san sang.
5. Chay H6 terminal equivalence probe tai 11/09/2026.

## H6-D — Presentation / HS14 debt
Truoc final acceptance Historical Scanner v0.1:
- UI moi phai tieng Viet ASCII khong dau;
- H6 formulas dung `NoDefaultColumns` va chi xuat cot nghiem thu can thiet;
- Null RangePosition phai de Null/blank, khong hien sentinel so am lon;
- inherited legacy English columns trong H2/H4 publisher la presentation debt cua publisher, khong duoc mang sang final Historical Scanner user-facing output;
- khong thay formula logic chi de sua presentation.

## Final gate
Chi khoa sau khi H6-A, H6-B, H6-C va presentation gate deu dat:
`HISTORICAL_SCANNER_V01_FINAL = PASS`

Khong Buy/Sell/Short/Cover/PositionScore/P&L trong H6.
