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

Native completion 15/09/2026:
- VN STOCKS ONLY = 1668 symbols;
- Production Data Eligible = 1066;
- H2 W/M, H4 stock + target date, H3 Market + target date deu san sang cho 1066/1066 eligible symbols.

Checkpoint:
`HISTORICAL_SCANNER_V01_H6_PREREQUISITE_UNIVERSE_1066 = PASS`

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

Native result: exact.

Checkpoint:
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

Khong tu suy doan Side/Stage/Phase/Family/MTF/RS cua DTP/FRT. Cac field nay duoc so sanh historical-vs-production truc tiep.

Native result: DTP va FRT deu dat control da khoa.

Checkpoint:
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

Native strict result 15/09/2026:
- exact symbol set = 1066/1066;
- Class / Side / Stage / Phase / Family / MTF / RS / Review / MethodBlockMask / Market context / DataEligible va RangePosition validity khop cho toan universe;
- 1063/1066 khop tat ca field;
- 3 mismatch duy nhat: `DMC`, `SBM`, `TV3`, chi o `RangePosition`.

Strict checkpoint duoc giu nguyen:
`HISTORICAL_SCANNER_V01_H6C_UNIVERSE_TERMINAL_EQUIVALENCE = NOT_EXACT_1063_OF_1066`

Root-cause diagnostics xac nhan:
- direct causal runtime == H4;
- future-truncated runtime == H4;
- ca hai khac archived Production RangePosition cho DMC/SBM/TV3;
- archived production output cho thay range boundaries va PriorATR tai 11/09 khac voi current historical database;
- nguyen nhan = source-data vintage revision, khong phai look-ahead, comparator mapping hay methodology.

Project owner approved acceptance exception on 15/09/2026:
`HISTORICAL_SCANNER_V01_HS13_ACCEPTANCE_EXCEPTION = APPROVED_DMC_SBM_TV3_DATA_VINTAGE_REVISION`

Accepted H6-C status:
`HISTORICAL_SCANNER_V01_H6C = PASS_WITH_APPROVED_EXCEPTION`

Khong doi strict measurement thanh `PASS_1066_OF_1066`; mismatch report va exact values van duoc giu lam evidence.

## Publisher workflow neu H6-0 cho thay thieu timeline
Workflow da hoan tat trong H6 native run. Khong rerun lai chi de tao evidence presentation:
1. H2 Weekly publisher tren missing 1065 — PASS 1065/1065.
2. H2 Monthly publisher tren missing 1065 — PASS 1065/1065.
3. H4 stock publisher tren missing 1065 — PASS 1065/1065.
4. H3 Market khong rerun vi prerequisite da san sang.
5. H6 prerequisite sau cung — PASS 1066/1066 eligible.

## H6-D — Presentation gate
H6 acceptance-facing formulas da duoc kiem tra native/static:
- UI moi dung tieng Viet ASCII khong dau;
- `SetOption("NoDefaultColumns",True)` loai cot mac dinh thua;
- comparator B hien Null RangePosition thanh blank khi validity = 0, khong dung numeric sentinel de ket luan mismatch;
- output H6 chi giu cot nghiem thu/can thiet;
- khong Buy/Sell/Short/Cover/PositionScore/P&L;
- khong thay analytical logic chi de sua presentation.

Checkpoint H6 presentation:
`HISTORICAL_SCANNER_V01_H6D_PRESENTATION = PASS`

Luu y: presentation debt cua mot so publisher/proof harness H2-H5 cu (inherited English/internal columns) van la debt can don truoc khi tuyen bo **overall Historical Scanner v0.1 final user-facing acceptance**. Khong rerun cac publisher nang chi de sua debt nay.

## H6 final gate
H6-0 PASS, H6-A PASS, H6-B PASS, H6-C PASS_WITH_APPROVED_EXCEPTION, H6-D PASS.

Checkpoint H6:
`HISTORICAL_SCANNER_V01_H6 = PASS_WITH_APPROVED_EXCEPTION`

PR H6 co the chuyen sang Ready for review. Khong auto merge.

Khong gan `HISTORICAL_SCANNER_V01_FINAL = PASS` tai H6 PR nay; overall Historical Scanner v0.1 final acceptance chi duoc khoa sau khi presentation debt con lai duoc xu ly theo Definition of Done.
