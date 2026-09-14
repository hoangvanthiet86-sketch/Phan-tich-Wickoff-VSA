# Historical Scanner v0.1 — H4 Single-symbol Test Plan

## Muc tieu

Kiem dinh Historical Scanner tren mot co phieu control (`SNZ`) theo tung ngay lich su, sau khi H2 Historical MTF va H3 Historical Market Context da PASS.

H4 chi la Exploration / validation layer. Khong co trading semantics.

## Checkpoint dau vao da khoa

- H2A rollover: PASS.
- H2B historical W/M payload: PASS.
- H2C terminal MTF equivalence: PASS.
- H3 Market Context point-in-time + missing benchmark fail closed: PASS.
- Integration base sau PR #52: `80b7ce56b29cfd326d540bfa7e96b4d063ee5ab7`.

## Tep H4

- `afl/WyckoffVSA_HistoricalStockTimelinePublisher_v0.1.afl`
- `afl/WyckoffVSA_HistoricalScanner_v0.1.afl`

## Nguyen tac khoa

1. H4 chi doc historical namespace:
   - `WVSA_HIST_STOCK_v01_<SYMBOL>_*`
   - `WVSA_HIST_MKT_v01_<MARKET>_*`
   - va H2 historical W/M namespace ben trong publisher.
2. Khong dung current Daily Snapshot hay current MTF/cross-symbol snapshot lam historical source.
3. RS stock/VNINDEX dung `Foreign(...,"C",0)` de benchmark thieu ngay khong bi forward-fill ngam.
4. Scanner tai dung behavioral semantics cua production Market Scanner: Stage, SelectionContext, data eligibility bits, Review, MethodBlock, Candidate Class priority, Candidate Side, Watch/Developing/Qualified.
5. Profile H4 la Market-only; Full Top-Down Group deferred dung theo spec v0.1.
6. Khong co `Buy`, `Sell`, `Short`, `Cover`, `PositionScore`, P&L.
7. UI moi cua H4 dung tieng Viet khong dau.

## H4-A — Ghi stock timeline SNZ

AFL:
`WyckoffVSA_HistoricalStockTimelinePublisher_v0.1.afl`

Chay:
- Apply to: `SNZ`
- Periodicity: `Daily`
- Range: `1 recent bar`
- `9.1 Cho phep ghi timeline co phieu lich su = Co`
- Explore

Ky vong o cac cot H4 publisher cuoi:
- `Ma co phieu = SNZ`
- `So ngay stock payload hop le > 0`
- `Trang thai ghi = Da ghi timeline co phieu`
- `Phien ban H4 publisher = HISTORICAL_STOCK_TIMELINE_PUBLISHER_V01_20260914_A`

Neu bao H2 W/M timeline chua san sang thi chi sua/rerun prerequisite H2 cho SNZ; khong sua formula decision logic.

## H4-B — Full historical timeline SNZ

AFL:
`WyckoffVSA_HistoricalScanner_v0.1.afl`

Chay:
- Apply to: `SNZ`
- Periodicity: `Daily`
- Range: From-To, de nghi `01/01/2019` den hien tai
- `1.1 Che do loc lich su = Toan bo audit`
- Explore va xuat TXT

### H4-N01 — Nguon stock point-in-time

Tai dong source hop le:
- stock publisher san sang;
- source key = `DateNum()` cua dong;
- source DateTime = DateTime cua dong;
- source khong den tu tuong lai.

### H4-N02 — Market point-in-time

Market context phai den tu H3 historical namespace va exact-date guard. Ngay market invalid/missing phai Data Gated, khong lay context cua ngay khac.

### H4-N03 — Enum va decision surface

Moi dong phai nam trong enum canonical:
- Candidate Class: 0..9;
- Side: 0..2;
- Stage: 0..5;
- Phase: 0..7;
- Family: 0..7;
- MTF: 0..6;
- RS: 0..3.

Profile Market-only khong tao moi class 5/8; cac enum van duoc giu de terminal/universe comparison sau nay khong doi schema.

### H4-N04 — Production behavioral semantics

Kiem tra tren file export:
- Data Gated luon Class 0;
- Review luon Class 9;
- Watch chi khi Stage 1, range-location coherent, RS = 1 hoac 2, khong Review;
- Developing va Qualified dung dung Market/Direction/MTF/RS/evidence predicates production;
- MethodBlockMask giu dung bit meanings production.

### H4-N05 — Terminal SNZ control

Tai business date `11/09/2026`, H4 phai tai dung:
- `Class = 2` (WATCH)
- `Side = 0`
- `Stage = 1`
- `Phase = 2`
- `Family = 1`
- `Range Position = 0.3500` (cot hien thi = 35.00%)
- `MTF = 0`
- `RS = 2`
- `Review = 0`
- `MethodBlockMask = 7`

Neu bat ky field nao lech, H4 chua PASS va phai lap mismatch report truoc khi sua logic.

### H4-N06 — Khong trading semantics

Source H4 khong duoc gan:
`Buy`, `Sell`, `Short`, `Cover`, `PositionScore` va khong tinh P&L.

## Pham vi H4 va dieu chua duoc tuyen bo

H4 PASS khong tu dong co nghia HS07 truncation invariance PASS. H5 se kiem rieng:
- truncation invariance;
- pivot publication timing;
- Phase KnownAt timing;
- benchmark anti-lookahead controls.

H4 cung chua la HS13 universe equivalence.

## Checkpoint

Neu H4-A va H4-B + terminal SNZ dat:

`HISTORICAL_SCANNER_V01_H4_SINGLE_SYMBOL_TIMELINE = PASS`

Sau do moi tiep tuc H5 Anti-lookahead Controls.
