# Historical Scanner v0.1 — H5 Static Audit — 2026-09-14

## Base

H5 bat dau tu integration sau khi PR #53 merge:
`aa08ac53954c1c5aea659325a0bc1046f5491902`

## Tep H5

- `afl/WyckoffVSA_HistoricalCausalityProof_v0.1.afl`
- `afl/WyckoffVSA_HistoricalTruncationProof_v0.1.afl`
- `tests/historical-scanner-v0.1-h5-anti-lookahead-test-plan.md`

## Static contract

### H5-A

- Chay canonical Daily causal runtime tu `*_Runtime_v0.2` voi `HistoricalRuntimeDefaults`.
- Pivot proof doc truc tiep confirmation coordinates cua Structure/Location:
  - event bar phai bang confirm bar;
  - confirm DateTime phai bang current DateTime;
  - extreme phai nam truoc confirm;
  - confirmation lag phai bang locked PivotRight;
  - latest confirmed pivot khong duoc co confirm coordinate > current bar.
- Range/Phase/Family proof doi chieu KnownAt BarIndex/DateTime voi current bar.
- W/M proof chi doc `WVSA_HIST_MTF_v01_<SYMBOL>_<W|M>_*` va tai dung completed-calendar selection.
- Benchmark proof chi doc `WVSA_HIST_MKT_v01_<MARKET>_*` va kiem source <= T + exact date khi context duoc chap nhan.
- Payload carry-forward stale / benchmark khong exact-date phai fail closed. Dong bi gate tu choi la diagnostic, khong phai causal violation.

### H5-B

- Baseline chi doc `WVSA_HIST_STOCK_v01_<SYMBOL>_*` da duoc H4 native-accepted.
- Khong doc Daily Snapshot production.
- Khong doc current `WVSA_MTF_v01_*`.
- Khong doc current `WVSA_SELCTX_v01_*`.
- Future stock OHLCV bi thay thanh Null truoc khi canonical causal runtime duoc include/chay.
- W/M van dung historical completed-period namespace H2.
- Market van dung historical point-in-time namespace H3.
- RS benchmark dung `Foreign(...,"C",0)`; khong forward-fill benchmark thieu.
- Decision reconstruction tai dung H4/production behavioral semantics: SelectionContext, StageFromPhase, exclusion bits Market-only, Review, MethodBlockMask, Watch/Developing/Qualified Market, Candidate Class priority, Candidate Side.
- Full Top-Down Group van deferred theo Historical Scanner v0.1; khong tao class 5/8 moi.

## Native H5-A lan 1 va sua proof

Native SNZ Daily lan 1, file `1(20260914-112216).txt`, cho thay:
- pivot dinh = 198;
- pivot day = 221;
- loi timing pivot = 0;
- loi pivot future = 0;
- single-context rows = 806;
- Range KnownAt = 0;
- Phase KnownAt = 0;
- Family KnownAt = 0;
- diagnostic cu `Loi bien Tuan = 38`;
- `Loi bien Thang = 0`;
- benchmark future = 0;
- diagnostic cu `Loi benchmark khong khop ngay = 2`.

Static review xac dinh hai bo dem cu dang danh nham payload da bi fail-closed la causal violation:
- W/M `ValueWhen` carry-forward co the giu payload cu khi current expected period da doi; H2B guard se danh payload do invalid, khong su dung no.
- Market StaticVar co the carry-forward qua ngay stock ma benchmark khong co exact-date bar; H3 guard se danh context do invalid, khong su dung no.

H5-A ban `HISTORICAL_ANTI_LOOKAHEAD_CAUSALITY_V01_20260914_B` tach ro:
- dong stale / sai ngay `bi loai` = diagnostic, co the > 0;
- `Loi ... da chap nhan` = causal violation, bat buoc 0.

Day la sua proof harness, khong sua methodology, threshold, enum, decision surface hay production runtime.

## Trading guard

Hai AFL H5 khong gan:
- `Buy`
- `Sell`
- `Short`
- `Cover`
- `PositionScore`

Khong tinh P&L, target hay sizing.

## UI

Tat ca Parameters/column/status moi cua H5 dung tieng Viet ASCII khong dau. H5 khong them Parameter tieng Anh.

Runtime include cu co the van de lai cac cot noi bo legacy; day la presentation debt da biet tu H4 va phai duoc xu ly truoc final Historical Scanner UI acceptance. H5 khong tu y sua production runtime presentation architecture.

## Pham vi

Static audit nay khong thay the native AmiBroker 6.20.01. Khong tuyen bo H5 PASS truoc khi H5-A ban B va ba moc H5-B deu dat.

Checkpoint:
`HISTORICAL_SCANNER_V01_H5_STATIC = PASS_FOR_NATIVE`
