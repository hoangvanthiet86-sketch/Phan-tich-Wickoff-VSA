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
- Benchmark proof chi doc `WVSA_HIST_MKT_v01_<MARKET>_*` va kiem source <= T + exact date khi source valid.

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

Static audit nay khong thay the native AmiBroker 6.20.01. Khong tuyen bo H5 PASS truoc khi H5-A va ba moc H5-B deu dat.

Checkpoint:
`HISTORICAL_SCANNER_V01_H5_STATIC = PASS_FOR_NATIVE`
