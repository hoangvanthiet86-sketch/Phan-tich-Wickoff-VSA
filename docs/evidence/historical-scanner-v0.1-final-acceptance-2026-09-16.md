# Historical Scanner v0.1 — Final Acceptance

Date: 2026-09-16
Base integration head before this documentation branch: `6e097d9873e488f11a0763dc8ce1737401111541`
Branch: `docs/historical-scanner-v0.1-final-acceptance`

## Muc tieu

Tai lieu nay khoa nghiem thu cuoi cho Historical Scanner v0.1 sau khi H6 correctness gate va presentation cleanup da duoc merge dung thu tu vao:

`integration/wyckoff-vsa-production-candidate-v0.1`

Khong thay methodology, threshold, enum, decision semantics, StaticVar namespace, trading behavior, hoac acceptance criteria da khoa.

## Merge chain da xac minh

### H6 correctness / terminal universe

PR #56 da merge vao integration.

Merge commit:

`4bad7e2eb09d794190a9eb3d04aa962067890f5c`

H6 final checkpoint:

`HISTORICAL_SCANNER_V01_H6 = PASS_WITH_APPROVED_EXCEPTION`

### Presentation cleanup

PR #57 da merge tren H6 integration head.

Merge commit / integration head:

`6e097d9873e488f11a0763dc8ce1737401111541`

Presentation checkpoints:

`HISTORICAL_SCANNER_V01_PRESENTATION_STATIC = PASS`

`HISTORICAL_SCANNER_V01_PRESENTATION_FORMULA_NATIVE = PASS`

`HISTORICAL_SCANNER_V01_PRESENTATION_NATIVE = PASS`

## HS11 / HS12 controls

SNZ terminal control tai 11/09/2026 PASS exact voi surface da khoa:

- Class 2;
- Side 0;
- Stage 1;
- Phase 2;
- Family 1;
- RangePosition 0.3500;
- MTF 0;
- RS 2;
- Review 0;
- MethodBlockMask 7.

DTP/FRT controls PASS theo locked production evidence.

Checkpoints:

`HISTORICAL_SCANNER_V01_H6A_SNZ_TERMINAL = PASS`

`HISTORICAL_SCANNER_V01_H6B_DTP_FRT_CONTROLS = PASS`

## HS13 universe equivalence va data-vintage exception

Strict comparator measurement duoc giu nguyen:

- exact eligible symbol set: 1,066/1,066;
- tat ca field ngoai RangePosition: 1,066/1,066 khop;
- exact all-field: 1,063/1,066;
- ba sai khac duy nhat: `DMC`, `SBM`, `TV3`, chi o `RangePosition`.

Strict checkpoint:

`HISTORICAL_SCANNER_V01_H6C_UNIVERSE_TERMINAL_EQUIVALENCE = NOT_EXACT_1063_OF_1066`

Diagnostics da chung minh:

- direct causal runtime == H4;
- future-truncated runtime == H4;
- archived Production dung source-data vintage cu hon cho ba ma nay;
- khong tim thay look-ahead, comparator defect, hoac methodology defect o ba sai khac.

Project owner da phe duyet acceptance exception hep cho ba data-vintage differences nay.

Acceptance record:

`HISTORICAL_SCANNER_V01_HS13_ACCEPTANCE_EXCEPTION = APPROVED_DMC_SBM_TV3_DATA_VINTAGE_REVISION`

`HISTORICAL_SCANNER_V01_H6C = PASS_WITH_APPROVED_EXCEPTION`

Khong duoc bien strict 1063/1066 thanh false `PASS_1066_OF_1066`.

## HS14 / final user-facing presentation

AmiBroker 6.20.01 native presentation run tren SNZ / Daily / Current / All quotes / `Toan bo kiem tra` da PASS:

- 1,971 dong;
- 17 cot explicit;
- hai cot dau: `Ma co phieu`, `Ngay gio`;
- khong duplicate default Ticker/Date-Time;
- user-facing labels/text dung Vietnamese ASCII; `MTF` va `RS` duoc giu nhu acronym;
- 43 invalid/unknown RangePosition rows hien blank;
- 1,928 valid RangePosition rows hien phan tram binh thuong;
- khong Buy/Sell/Short/Cover/PositionScore/P&L;
- SNZ 11/09/2026 van giu terminal control da khoa.

User-facing formula version:

`HISTORICAL_SCANNER_V01_H4_20260916_B`

## Integration diff verification

So sanh H6 integration merge commit `4bad7e2...` voi post-presentation integration head `6e097d9...` cho thay chi co ba file thay doi:

1. `afl/WyckoffVSA_HistoricalScanner_v0.1.afl` — presentation-only cleanup;
2. `docs/evidence/historical-scanner-v0.1-presentation-cleanup-2026-09-16.md`;
3. `tests/historical-scanner-v0.1-presentation-test-plan.md`.

Khong co thay doi nao khac trong integration giua hai moc nay. Presentation code change khong sua cac bieu thuc decision da khoa nhu DataEligible, Review, MethodBlockMask, CandidateClass, CandidateSide.

## Final acceptance

Tat ca gate H1-H6 da hoan tat; H6 duoc chap nhan voi narrow HS13 data-vintage exception; final user-facing presentation da PASS native va da merge tren H6 integration head.

Final checkpoint:

`HISTORICAL_SCANNER_V01_FINAL = PASS_WITH_APPROVED_HS13_DATA_VINTAGE_EXCEPTION`

Trang thai nay co nghia:

- Historical Scanner v0.1 duoc nghiem thu de tiep tuc vao production-candidate integration flow;
- strict HS13 measurement van la 1063/1066 exact all-field;
- DMC/SBM/TV3 exception phai duoc giu trong moi release note / final handoff lien quan;
- khong can rerun cac publisher H2/H3/H4 nang chi de khoa final acceptance nay;
- khong duoc dien giai checkpoint nay thanh strict exact 1066/1066.
