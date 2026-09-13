# Wyckoff VSA Historical Scanner v0.1 — Đặc tả

**Trạng thái:** DRAFT — chờ chủ dự án phê duyệt trước khi triển khai AFL.

**Base:** `integration/wyckoff-vsa-production-candidate-v0.1` tại merge commit PR #48 `c07acf49b892a32e3c67b123a574fcfd9b52d1f6`.

## 1. Mục tiêu

Xây một lớp kiểm định lịch sử riêng để tái dựng **trạng thái ứng viên tại từng ngày trong quá khứ** theo logic Wyckoff VSA canonical hiện hành, phục vụ kiểm tra tính ổn định, độ hữu dụng và look-ahead bias trước khi định nghĩa bất kỳ chiến lược giao dịch/backtest P&L nào.

Historical Scanner v0.1 là **Exploration / validation layer**, không phải trading strategy.

## 2. Không thuộc phạm vi v0.1

v0.1 KHÔNG:

- tạo `Buy`, `Sell`, `Short`, `Cover`;
- tạo `PositionScore`, numeric ranking, probability/confidence;
- tính CAGR, drawdown, P&L, expectancy hay trade statistics;
- tự định nghĩa entry/exit/stop/position sizing;
- sửa Fast Scanner, Market Scanner, Daily Publisher hoặc Discovery / Pre-Watch;
- nới threshold, đổi enum, đổi `ReviewFlag`, `MethodBlockMask`, `CandidateClass` hoặc methodology production;
- dùng current Daily Snapshot để giả lập quá khứ;
- dùng dữ liệu tương lai để gán trạng thái cho một bar quá khứ.

Trading backtest chỉ được xây sau khi Historical Scanner v0.1 chứng minh point-in-time reconstruction và no-lookahead.

## 3. Kết luận audit kiến trúc hiện tại

### 3.1 Market Scanner hiện tại không thể dùng trực tiếp cho lịch sử

`WyckoffVSA_MarketScanner_v0.1.afl` tự khai báo là `current-state EOD only` và lấy hầu hết trạng thái bằng `LastValue(...)`. Vì vậy thay `Range` trong Analysis không làm nó tái dựng từng trạng thái lịch sử.

**Quyết định:** không sửa file production này thành historical scanner. Chỉ tái sử dụng **quy tắc phân loại** sau khi mọi đầu vào đã trở thành point-in-time arrays.

### 3.2 Phase / Context là ứng viên có thể tái sử dụng

`WyckoffVSA_PhaseContext_v0.1.afl` vận hành lower/upper RangeContext bằng vòng lặp từ bar đầu đến bar cuối và công bố các trường `KnownAtBarIndex`, `KnownAtDateTime`, `PhaseKnownAt...`, `HypothesisKnownAt...`.

**Quyết định:** coi Phase / Context là `REUSE_CAUSAL_ARRAY_CANDIDATE`, nhưng vẫn phải qua truncation test native trước khi khóa PASS.

### 3.3 Confirmed pivot semantics là causal

`WyckoffVSA_DerivedSeriesPivotKernel_v0.1.afl` quy định candidate ở `i-rightBars` nhưng chỉ publish pivot tại confirmation bar `i`; kernel ghi rõ `no future access`.

**Quyết định:** historical layer phải giữ nguyên semantics này. Pivot không được xuất hiện sớm tại extreme bar.

### 3.4 Relative Strength có nền tảng array phù hợp nhưng cần kiểm định căn chỉnh ngày

`WyckoffVSA_RelativeStrengthContext_v0.1.afl` dùng `Foreign()` cho benchmark, tính ratio trên arrays và gọi confirmed-pivot kernel.

**Quyết định:** `REUSE_WITH_ALIGNMENT_VALIDATION`. Không được forward-fill một ngày benchmark thiếu dữ liệu mà không có rule canonical. Nếu benchmark không hợp lệ tại T thì historical state phải fail closed theo contract tương ứng.

### 3.5 Multi-Timeframe hiện tại KHÔNG phải historical timeline

`WyckoffVSA_MultiTimeframeContext_v0.1.afl` tự khai báo `Current-state Daily / Weekly / Monthly aggregator only`. Daily được lấy bằng `LastValue`, Weekly/Monthly lấy từ scalar snapshot; public arrays chỉ lặp lại cùng một current snapshot trên mọi bar và ghi rõ đó **không phải historical MTF backfill**.

**Quyết định:** không dùng trực tiếp `WMTF_*` current-state arrays cho historical validation. Phải có `Historical MTF Adapter` riêng.

### 3.6 Higher timeframe availability phải theo previous calendar-completed period

`WyckoffVSA_TimeframeSnapshot_Publisher_v0.1.afl` chỉ publish **previous calendar-completed higher-period Composite state** theo operational as-of.

**Quyết định:** tại mỗi Daily bar T, historical Weekly/Monthly context chỉ được dùng khi period đó đã calendar-completed relative to T. Không được dùng dữ liệu của tuần/tháng đang hình thành để đánh giá Daily bar T.

### 3.7 Cross-Symbol selection context hiện tại cũng là current scalar snapshot

`WyckoffVSA_CrossSymbolSelectionContext_Publisher_v0.1.afl` serialize `LastValue(...)` của Market/Group vào StaticVars; consumer lặp scalar đó trên toàn bộ bar.

**Quyết định:** historical scanner không được đọc current Market/Group StaticVar để áp cho các ngày quá khứ. Phải có historical benchmark context point-in-time riêng.

## 4. Kiến trúc bắt buộc của Historical Scanner v0.1

Historical stack phải tách biệt với production stack hiện hành.

Dự kiến:

`Canonical causal stock arrays`
→ `Historical Higher-Timeframe Adapter`
→ `Historical Market Benchmark Context`
→ `Historical Scanner Decision Adapter`
→ `Historical Exploration output`

Không có producer nào của historical layer được ghi đè namespace StaticVar production hiện tại.

Tên file dự kiến, có thể điều chỉnh khi implementation nhưng phải giữ ranh giới trách nhiệm:

- `afl/WyckoffVSA_HistoricalMTFAdapter_v0.1.afl`
- `afl/WyckoffVSA_HistoricalSelectionContext_v0.1.afl`
- `afl/WyckoffVSA_HistoricalScanner_v0.1.afl`
- `tests/historical-scanner-v0.1-test-plan.md`

## 5. Point-in-time contract

Tại mỗi Daily bar T:

1. Chỉ thông tin đã biết đến cuối bar T mới được dùng.
2. Confirmed pivot chỉ được dùng từ confirmation bar trở đi, không từ extreme bar.
3. `KnownAtBarIndex` / `KnownAtDateTime` của Phase/Context là ranh giới sớm nhất trạng thái được phép xuất hiện.
4. Weekly context phải đến từ weekly period calendar-completed gần nhất trước operational period hiện tại của T.
5. Monthly context phải đến từ monthly period calendar-completed gần nhất trước operational period hiện tại của T.
6. Không dùng in-progress Weekly/Monthly data để làm Daily state tại T.
7. Market benchmark context phải là context của benchmark tại cùng historical as-of T, không phải current benchmark snapshot hôm nay.
8. Group context, nếu được bật ở profile sau này, cũng phải tuân thủ cùng rule point-in-time.
9. Missing benchmark / invalid source / invalid adjustment basis phải fail closed; không silent fill.
10. Chạy trên full history và chạy trên database bị cắt tại T phải cho kết quả giống nhau tại mọi bar <= T sau khi loại các bar chưa đủ warm-up.

## 6. Phạm vi profile v0.1

### 6.1 Bắt buộc

v0.1 phải hỗ trợ profile production mặc định không yêu cầu Full Top-Down Group.

Phải tái dựng được các trường tại mỗi bar:

- `DataEligible`
- `CandidateClass`
- `CandidateSide`
- `CandidateStage`
- `Phase`
- `Family`
- `RangePosition`
- `MTFAlignment`
- `RSvsMarket`
- `ScannerReview`
- `MethodBlockMask`
- Market selection context cần thiết cho các rule trên

### 6.2 Deferred

Full Top-Down Group profile có thể được bổ sung sau khi Market-only historical path đạt native acceptance. Cho đến lúc đó không được tuyên bố historical equivalence cho Full Top-Down.

## 7. Quy tắc tái sử dụng logic Scanner

Historical Scanner phải sao chép **behavioral semantics**, không tự sáng tạo rule mới.

Các hàm/quy tắc sau phải giữ tương đương với production Market Scanner:

- `SelectionContext`
- `StageFromPhase`
- Data eligibility logic trong phạm vi profile v0.1
- range-location coherence/conflict
- Review conditions
- Method Block bit meaning
- Candidate Class priority
- Candidate Side mapping
- Watch / Developing / Qualified logic

Nếu implementation cần đổi hình thức scalar → array, kết quả logic phải tương đương bar-by-bar với cùng input state.

## 8. Higher-Timeframe reconstruction

Historical MTF Adapter không được dùng current `StaticVar` Weekly/Monthly snapshot.

Nó phải tạo một timeline Daily mà tại mỗi T mang đúng Composite state của:

- previous calendar-completed Weekly period;
- previous calendar-completed Monthly period.

Rollover là causal availability boundary.

Ví dụ nguyên tắc: một Weekly state của tuần X không được xuất hiện trong Daily bars thuộc tuần X trước khi calendar week X đã hoàn tất và operational period đã rollover.

Không được dùng `expandFirst` hay kỹ thuật tương đương nếu nó khiến higher-timeframe result xuất hiện trước thời điểm period completion.

## 9. Historical Market context

Market benchmark phải được tính từ dữ liệu của benchmark symbol và aligned theo Daily date.

Historical Market context phải đưa ra cùng các input category mà production `SelectionContext` cần:

- multiplicity;
- directional context;
- evidence balance;
- hypothesis alignment;
- MTF directional alignment;
- validity/status.

Không dùng `WVSA_SELCTX_v01_*` current snapshot làm history.

Nếu Market benchmark không có bar hợp lệ tương ứng tại T, historical `DataEligible` phải fail closed hoặc đánh dấu rõ `INSUFFICIENT` theo contract; không được lấy giá trị của ngày tương lai/gần nhất một cách ngầm định.

## 10. Output Exploration

Mặc định v0.1 là Exploration, không Backtest action.

Cột tối thiểu:

`Ticker | Date/Time | Data Eligible | Candidate Class | Side | Stage | Phase | Family | Range Position (%) | MTF | RS vs Market | Review | Method Block Mask | Market Context | Historical Status | Version`

Hiển thị hướng tới AmiBroker 6.20.01 dùng tiếng Việt **không dấu** để tránh lỗi encoding đã xác nhận ở Fast Scanner.

Phải có filter mode tối thiểu:

- All Historical Eligible
- Historical Watch+
- Historical Review
- Historical Pre-Watch (chỉ khi Discovery historical được đặc tả riêng; KHÔNG tự động đưa vào v0.1)

## 11. Anti-lookahead acceptance

### HS01 — Không current snapshot leakage
Không được include/use `WyckoffVSA_DailySnapshotConsumer_v0.2.afl` hoặc current Cross-Symbol StaticVars làm nguồn historical state.

### HS02 — Không current MTF scalar leakage
Không được dùng `WMTF_*` current-state replicated arrays như historical timeline.

### HS03 — Pivot publication timing
Một pivot chỉ ảnh hưởng output từ confirmation bar trở đi.

### HS04 — Phase known-at timing
Phase/Family/Range hypothesis không được xuất hiện trước `KnownAt...` canonical của nó.

### HS05 — Weekly rollover
Weekly context chỉ đổi sau calendar-period completion boundary.

### HS06 — Monthly rollover
Monthly context chỉ đổi sau calendar-period completion boundary.

### HS07 — Truncation invariance
Với các control date T, output của full-history run tại <=T phải bằng output khi database/range bị cắt tại T, sau warm-up.

### HS08 — Benchmark date alignment
Market benchmark state tại T phải dùng dữ liệu <=T.

### HS09 — Missing benchmark fail closed
Thiếu benchmark tại T không được forward-fill im lặng.

### HS10 — Không trading semantics
Không có Buy/Sell/Short/Cover/PositionScore/P&L.

## 12. Terminal-date equivalence acceptance

Khi chạy historical scanner đến business date 11/09/2026 với cùng universe/configuration đã dùng cho native Performance Runtime:

### HS11 — SNZ control
SNZ phải tái dựng đúng:

- Class = 2 WATCH;
- Side = 0;
- Stage = 1;
- Phase = 2;
- Family = 1;
- Range Position = 0.3500;
- MTF = 0;
- RS = 2;
- Review = 0;
- Method Block Mask = 7.

### HS12 — DTP/FRT controls
Các control Review đã khóa trước đây phải giữ đúng class và diagnostic fields trong phạm vi dữ liệu/profile được hỗ trợ.

### HS13 — Universe checkpoint
Mục tiêu sau cùng của v0.1 là tái dựng exact terminal-date production decision surface cho cùng 1,066 Data Eligible symbols, hoặc nếu chưa đạt phải có mismatch report đầy đủ theo từng field và không được tuyên bố PASS.

HS13 là acceptance cuối của historical scanner, không phải điều kiện để viết prototype đầu tiên.

## 13. Kiểm thử theo giai đoạn

### Giai đoạn H1 — Source causality audit
Phân loại từng upstream module thành:

- `REUSE_CAUSAL_ARRAY`
- `REUSE_WITH_VALIDATION`
- `HISTORICAL_ADAPTER_REQUIRED`
- `PROHIBITED_CURRENT_SNAPSHOT`

Không viết scanner trước khi audit hoàn tất.

### Giai đoạn H2 — Historical MTF proof
Tạo harness riêng để chứng minh Weekly/Monthly rollover đúng tại một số boundary dates.

### Giai đoạn H3 — Historical Market context proof
Tạo benchmark context point-in-time và test missing-date/fail-closed.

### Giai đoạn H4 — Single-symbol Historical Scanner
Chạy một symbol control, ưu tiên SNZ, xuất toàn bộ timeline classification.

### Giai đoạn H5 — Anti-lookahead controls
Chạy truncation invariance, pivot confirmation và higher-timeframe boundary tests.

### Giai đoạn H6 — Multi-symbol native validation
Mở rộng sang `VN STOCKS ONLY` và đối chiếu terminal-date 11/09/2026 với production checkpoint.

Chỉ sau H6 PASS mới xem xét Trading Backtest specification.

## 14. Performance boundary

Historical Scanner buộc phải đánh giá heavy analytical logic trên history nên **không có** mục tiêu tốc độ ngang Fast Scanner snapshot-only.

Không được dùng formula-local benchmark của Performance Runtime để suy ra historical elapsed time.

Mục tiêu v0.1 là correctness / causal equivalence trước, optimization sau.

## 15. Definition of Done v0.1

Historical Scanner v0.1 chỉ được coi là native PASS khi:

1. H1-H6 hoàn tất;
2. HS01-HS13 đều PASS hoặc có acceptance exception được chủ dự án phê duyệt rõ ràng;
3. terminal-date controls khớp production trong phạm vi profile hỗ trợ;
4. không phát hiện future leakage trong truncation/boundary tests;
5. production files không bị sửa đổi ngoài thay đổi được phê duyệt riêng;
6. không có trading semantics.

Checkpoint dự kiến khi hoàn tất:

`HISTORICAL_SCANNER_V01_NO_LOOKAHEAD = PASS`

`HISTORICAL_SCANNER_V01_TERMINAL_EQUIVALENCE = PASS`

`HISTORICAL_SCANNER_V01_NATIVE = PASS`

## 16. Bước triển khai ngay sau khi đặc tả được phê duyệt

Không viết toàn bộ scanner ngay.

Bước implementation đầu tiên phải là **H1 Source Causality Audit + H2 Historical MTF proof harness**, vì current MTF snapshot architecture là ranh giới lớn nhất giữa current-state scanner và historical reconstruction.
