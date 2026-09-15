# Wyckoff VSA Performance Runtime v0.2 — Đặc tả dự thảo

**Trạng thái:** DRAFT FOR OWNER APPROVAL  
**Phạm vi:** tối ưu hiệu năng, kiến trúc runtime, trải nghiệm Parameters và quy trình vận hành  
**Nguồn chuẩn so sánh:** `integration/wyckoff-vsa-production-candidate-v0.1` và các kết quả native đã nghiệm thu trên AmiBroker 6.20.01  
**Không phải:** đặc tả phương pháp Wyckoff/VSA mới, hệ thống giao dịch tự động, weighted ranking, Trade Risk/R:R, Nine Tests, position sizing, Buy/Sell/Short/Cover.

---

## 1. Mục tiêu

Performance Runtime v0.2 được thiết kế để giảm đáng kể thời gian chạy Production Candidate và Market Scanner trên universe lớn mà **không làm giảm chất lượng lọc, không làm thay đổi semantics của các engine đã nghiệm thu và không làm thay đổi decision surface khi cùng dữ liệu/cấu hình được sử dụng**.

Mục tiêu vận hành:

1. Rút ngắn thời gian quét universe cổ phiếu dùng hằng ngày.
2. Không bắt Fast Scanner chạy lại toàn bộ chuỗi phân tích sâu và P&F trên mọi symbol ở mỗi lần Explore.
3. Tách rõ tính toán, snapshot/publish, lọc nhanh và deep review.
4. Giảm khối lượng output/diagnostic không cần thiết trong workflow hằng ngày.
5. Chuẩn hóa Parameters theo thứ tự khoa học, có mã phân cấp ổn định và mặc định phù hợp workflow thường xuyên nhất.
6. Giữ nguyên khả năng audit đầy đủ bằng Production Candidate hiện tại hoặc chế độ regression chuyên dụng.

---

## 2. Nguyên tắc bất biến bắt buộc

### PER01 — Result Preservation Invariant

Có thể thay đổi:

- phương pháp tính toán nội bộ;
- thuật toán triển khai;
- cấu trúc câu lệnh AFL;
- vectorization / scalar state / cache / snapshot;
- thứ tự thực hiện kỹ thuật nếu vẫn causal;
- cách tổ chức file;
- cách tổ chức Parameters;
- cách publish/consume dữ liệu;
- cách tối ưu vòng lặp;
- cách giảm output diagnostic trong Fast Scanner.

**Nhưng không được phép thay đổi kết quả phân tích/decision surface so với implementation chuẩn hiện hành khi đầu vào và cấu hình tương đương.**

Các trường decision surface tối thiểu phải giữ nguyên:

- `Data Eligible`
- `Candidate Class Code`
- `Candidate Class`
- `Candidate Side Code`
- `Candidate Stage Code`
- `Qualified`
- `Developing`
- `Watch`
- `Scanner Review`
- `Scanner Exclusion Mask`
- `Scanner Method Block Mask`

Các trường upstream ảnh hưởng quyết định cũng phải được regression khi module liên quan được tối ưu, bao gồm nhưng không giới hạn:

- Phase/Context;
- Family hypothesis;
- RangeContext identity/status/location;
- MTF alignment;
- Relative Strength structure;
- cross-symbol context;
- event evidence;
- P&F fields khi chạy chế độ Deep Review/P&F.

### PER02 — Correctness Exception

Chỉ được phép thay đổi kết quả nếu phát hiện implementation cũ cho kết quả sai.

Một thay đổi kết quả vì sửa lỗi chỉ được chấp nhận khi thỏa toàn bộ:

1. Có case tái hiện cụ thể.
2. Xác định rõ nguyên nhân trong code/contract cũ.
3. Chứng minh kết quả cũ vi phạm đặc tả/phương pháp/cơ chế causal đã được duyệt.
4. Viết correction note/spec trước khi sửa logic.
5. Có native test đối chứng trên AmiBroker 6.20.01.
6. Có regression để chứng minh thay đổi chỉ nằm trong phạm vi lỗi cần sửa.
7. Không gọi PASS trước khi native evidence xác nhận.

### PER03 — No Methodology Drift

Tối ưu runtime không được tự ý thay đổi:

- định nghĩa Wyckoff/VSA;
- threshold đã được duyệt;
- phase semantics;
- event semantics;
- Candidate Class semantics;
- mask semantics;
- P&F objective semantics;
- no-lookahead / known-at provenance.

### PER04 — Causal Equivalence

Mọi implementation tối ưu phải giữ nguyên tính causal. Không được dùng dữ liệu tương lai để tái tạo state nhanh hơn.

### PER05 — Fail Closed

Nếu snapshot/config/schema/date/version không khớp, Fast Scanner phải fail closed thay vì dùng dữ liệu cũ hoặc suy diễn.

---

## 3. Kiến trúc Runtime v0.2

### 3.1 Luồng chuẩn

```text
CANONICAL ANALYTICAL ENGINES
Core → Candidate → Structure/Location → Confirmation → Events
→ Structural Sequence → Phase/Context → Composite → MTF → RS
→ Cross-Symbol Context → Market Scanner
                 │
                 ▼
      STOCK SNAPSHOT PUBLISHER
     (chạy sau khi cập nhật EOD)
                 │
                 ▼
       PERSISTENT STOCK SNAPSHOT
                 │
                 ▼
          FAST MARKET SCANNER
                 │
       WATCH / DEVELOPING / QUALIFIED / REVIEW
                 │
                 ▼
          DEEP PRODUCTION REVIEW
                 │
                 ▼
        P&F ENRICHMENT KHI CẦN
```

### PER06 — Publisher/Consumer Separation

Daily Publisher chịu trách nhiệm chạy các engine canonical cần thiết và publish trạng thái cuối cùng của từng symbol.

Fast Scanner không được tái chạy toàn bộ chuỗi canonical nếu snapshot hợp lệ đã tồn tại.

### PER07 — P&F Deferred Enrichment

P&F không phải điều kiện để tạo Candidate Class hiện tại của Market Scanner. Do đó Fast Scanner mặc định không chạy P&F trên toàn universe.

P&F chỉ chạy trong:

- Deep Review;
- audit/regression;
- shortlist được chọn;
- hoặc khi người dùng chủ động bật chế độ yêu cầu P&F.

Việc trì hoãn P&F không được thay đổi Candidate Class/Watch/Developing/Qualified/Review của Scanner.

### PER08 — Headless Runtime

Các engine runtime dùng trong Publisher/Fast Scanner phải tách khỏi Exploration diagnostics nặng.

Mục tiêu kiến trúc:

```text
Engine_Runtime.afl        → chỉ tính toán / public contract
Engine_Exploration.afl    → include Runtime + AddColumn diagnostics
```

Các file release đã khóa không được sửa phá vỡ backward compatibility chỉ để tối ưu giao diện. Có thể xây wrapper/runtime v0.2 mới và chứng minh equivalence.

---

## 4. Snapshot Contract

### PER09 — Snapshot Granularity

Publisher lưu trạng thái scalar cần thiết của **bar/as-of hiện tại** cho mỗi symbol, không lưu toàn bộ history nếu Fast Scanner không cần.

Tối thiểu snapshot phải chứa:

- Symbol
- BusinessDateKey
- SourceDateTime
- SchemaMajor / SchemaMinor
- RuntimeVersion
- ConfigFingerprint
- GenerationID / write-complete state
- DataEligible
- CandidateClassCode
- CandidateSideCode
- CandidateStageCode
- Qualified
- Developing
- Watch
- ScannerReview
- ExclusionMask
- MethodBlockMask
- PhaseStateCode
- FamilyHypothesisCode
- DirectionalContextCode
- RangeContext identity/status/location fields cần cho diagnostics
- MTF alignment fields cần cho decision surface
- RS fields cần cho decision surface
- Market/Group context validity/provenance cần thiết

### PER10 — Config Fingerprint

Snapshot chỉ được sử dụng khi cấu hình có ảnh hưởng kết quả khớp với Fast Scanner.

Config fingerprint phải bao gồm tối thiểu các tham số có ảnh hưởng logic như lookback, pivot, thresholds, benchmark symbol, adjustment basis và profile-related logic controls.

### PER11 — Date/Clock Contract

Business-date key tiếp tục dùng canonical AmiBroker `DateNum` theo Operational Clock đã native PASS.

Không dùng numeric YYYYMMDD làm canonical key.

### PER12 — Atomic Publication

Snapshot phải có cơ chế generation/write-complete tương tự cross-symbol publisher/consumer hiện tại để consumer không đọc dữ liệu đang ghi dở.

### PER13 — Staleness Guard

Fast Scanner phải từ chối snapshot khi:

- business date cũ;
- future date;
- schema mismatch;
- symbol mismatch;
- config fingerprint mismatch;
- write generation không ổn định;
- payload thiếu trường bắt buộc.

---

## 5. Runtime Profiles

### 5.1 Profile 0 — DAILY FAST SCAN (mặc định)

Mục đích: workflow hằng ngày sau EOD.

Mặc định đề nghị:

- Market benchmark: `VNINDEX`
- Group benchmark: trống
- Last bar provisional: `No`
- Require Full Top-Down: `No`
- P&F: không chạy trong scan toàn universe
- Output: compact
- Filter mặc định: `Watch+` hoặc equivalent production shortlist mode
- Universe: stock-only watchlist/category do lớp vận hành cung cấp

### 5.2 Profile 1 — DEEP REVIEW

Mục đích: phân tích sâu symbol/shortlist.

- Full analytical stack
- P&F bật
- diagnostics mức vừa/đầy đủ theo nhu cầu
- không thay đổi semantics canonical

### 5.3 Profile 2 — AUDIT / REGRESSION

Mục đích: nghiệm thu và đối chiếu.

- All Eligible
- full diagnostics
- P&F bật
- provenance/schema fields đầy đủ
- output đủ để so sánh bit-for-bit/field-for-field với baseline

### PER14 — Profile Is Convenience, Not Methodology

Runtime Profile chỉ là preset tổ hợp Parameters. Người dùng vẫn có thể chỉnh từng tham số được phép cấu hình.

Profile không được lén thay methodology ngoài các giá trị hiển thị rõ ràng.

---

## 6. Parameter UX Contract

### PRM01 — Operational Defaults

Giá trị mặc định phải phản ánh trường hợp sử dụng thường xuyên nhất.

### PRM02 — Ordered Parameter Namespace

Thứ tự hiển thị Parameters phải theo workflow người dùng, không theo số section lịch sử của engine.

### PRM03 — Single Configuration Authority

Runtime production v0.2 phải có một nguồn khai báo Parameters trung tâm, ví dụ:

`WyckoffVSA_RuntimeConfig_v0.2.afl`

Các runtime engine downstream đọc biến cấu hình này thay vì tự tạo nhiều Param trùng lặp/rời rạc.

### PRM04 — Advanced Isolation

Các tham số schema/debug/test/provenance phải được chuyển xuống nhóm `90. ADVANCED / TESTING` hoặc chỉ xuất hiện trong profile Audit.

### PRM05 — No Semantic Change

Tổ chức lại Parameters không được thay đổi output nếu cùng giá trị cấu hình được dùng.

### PRM06 — Hierarchical Parameter Numbering

Mọi tham số production-facing có mã phân cấp ổn định dạng `Nhóm.Thứ tự`.

Ví dụ:

- `1.1 Runtime Profile`
- `1.2 Production Filter`
- `3.1 Short Lookback`
- `6.1 Market Benchmark`

### PRM07 — Visible Parameter IDs

Mã phân cấp phải xuất hiện trực tiếp trong label của cửa sổ Parameters.

### PRM08 — Stable Parameter ID Contract

Sau khi v0.2 phát hành, không tùy tiện đổi mã định danh và ý nghĩa của tham số hiện hữu.

Quy tắc này **không khóa giá trị người dùng nhập**.

Ví dụ:

`3.1 Short Lookback = 20`

- `3.1` luôn đại diện cho Short Lookback.
- `20` là default và vẫn có thể chỉnh nếu methodology cho phép.

### PRM09 — Editable Default Contract

Tham số vận hành có default phù hợp workflow phổ biến nhưng vẫn chỉnh được nếu nó là tham số cấu hình hợp lệ.

Giá trị thực sự là hằng số phương pháp, không được phép thay đổi, **không nên đưa vào Parameters**.

### PRM10 — Parameter Tree v0.2

```text
01. RUN MODE
    1.1 Runtime Profile
    1.2 Production Filter
    1.3 Treat Last Bar As Provisional

02. DATA & VSA
    2.1 Volume Lookback
    2.2 Spread Lookback
    2.3 ATR Period
    2.4 High Effort RVOL
    2.5 Low Effort RVOL
    2.6 Low Directional Result ATR
    2.7 High Directional Result ATR

03. STRUCTURE / LOCATION
    3.1 Short Lookback
    3.2 Medium Lookback
    3.3 Long Lookback
    3.4 Pivot Left
    3.5 Pivot Right

04. PHASE / CONTEXT
    4.x Chỉ chứa tham số thật sự cần người vận hành

05. MULTI-TIMEFRAME
    5.x Chỉ chứa cấu hình MTF production-facing cần thiết

06. RELATIVE STRENGTH
    6.1 Market Benchmark
    6.2 Group Benchmark
    6.3 Adjustment Basis
    6.4 Adjustment Basis Status
    6.5 Treat Last Bar As Provisional

07. MARKET / GROUP CONTEXT
    7.1 Selection Market Benchmark
    7.2 Selection Group Benchmark
    7.3 Require Market Context
    7.4 Require Group Context

08. SCANNER
    8.1 Require Full Top-Down Profile
    8.2 Candidate Filter
    8.3 Scanner Output Detail

09. P&F
    9.1 P&F Runtime Mode
    9.2 Fixed Box Size
    9.3 Grid Origin
    9.4 Reversal Boxes
    9.5 Adjustment Basis
    9.6 Adjustment Basis Status
    9.7 Treat Last Bar As Provisional
    9.8 Source Revision Status

10. OUTPUT / DIAGNOSTICS
    10.1 Output Detail Level
    10.2 Show Decision Diagnostics
    10.3 Show Range Diagnostics
    10.4 Show P&F Diagnostics

90. ADVANCED / TESTING
    90.1 Runtime Validation Mode
    90.2 Schema Diagnostics
    90.3 Snapshot Diagnostics
    90.4 Provenance Diagnostics
    90.5 Native Acceptance / Regression Controls
```

Các nhóm `04` và `05` chỉ được bổ sung Param nếu thật sự có giá trị cấu hình cần người dùng điều khiển. Không tạo Param chỉ để phản ánh internal state.

---

## 7. Mặc định production đề nghị

Các default ban đầu phải tái hiện workflow native hiện tại trừ những mục được cố ý thay cho trải nghiệm vận hành nhanh.

| ID | Parameter | Default đề nghị |
|---|---|---|
| 1.1 | Runtime Profile | DAILY FAST SCAN |
| 1.2 | Production Filter | Watch+ / shortlist equivalent |
| 1.3 | Last Bar Provisional | No |
| 2.1 | Volume Lookback | 20 |
| 2.2 | Spread Lookback | 20 |
| 2.3 | ATR Period | 14 |
| 2.4 | High Effort RVOL | 1.8 |
| 2.5 | Low Effort RVOL | 0.75 |
| 2.6 | Low Directional Result ATR | 0.35 |
| 2.7 | High Directional Result ATR | 0.8 |
| 3.1 | Short Lookback | 20 |
| 3.2 | Medium Lookback | 60 |
| 3.3 | Long Lookback | 120 |
| 3.4 | Pivot Left | 3 |
| 3.5 | Pivot Right | 3 |
| 6.1 | Market Benchmark | VNINDEX |
| 6.2 | Group Benchmark | trống |
| 6.4 | Adjustment Basis Status | 1 = compatible |
| 6.5 | Last Bar Provisional | No |
| 8.1 | Require Full Top-Down | No |
| 9.1 | P&F Runtime Mode | Deferred in Fast Scan |
| 9.4 | Reversal Boxes | 3 |

Chuỗi `Adjustment Basis` phải được làm nhất quán với status; không hiển thị `NOT VERIFIED` đồng thời với status `1=compatible` trong production default.

---

## 8. Chiến lược tối ưu thuật toán

### PER15 — Không cắt history tùy tiện

Không thay `sbrAll` bằng một số bars cố định chỉ để nhanh hơn nếu chưa chứng minh equivalence.

RangeContext/Phase/P&F có state lịch sử dài; cắt history có thể đổi kết quả.

### PER16 — Tối ưu vòng lặp có kiểm soát

Ưu tiên loại bỏ tính toán lặp lại bằng:

- lưu latest confirmed pivot state thay vì quét lại từ đầu;
- precompute prefix/state arrays;
- vectorization khi semantics tương đương;
- incremental state/checkpoint khi có thể chứng minh causal equivalence.

Mỗi tối ưu phải có regression riêng.

### PER17 — Benchmark Cache

Market benchmark/MTF/cross-symbol context nên được publish/cache một lần theo business date thay vì tính lại dư thừa cho từng stock thread khi contract cho phép.

### PER18 — Output Cost Reduction

Fast Scanner chỉ xuất các cột quyết định và diagnostics tối thiểu.

Full upstream diagnostic columns chỉ thuộc Audit/Deep Review exploration.

---

## 9. Tệp mục tiêu dự kiến

Tên file có thể được tinh chỉnh khi triển khai nhưng trách nhiệm phải tách rõ:

```text
afl/WyckoffVSA_RuntimeConfig_v0.2.afl
afl/WyckoffVSA_DailyStockSnapshotPublisher_v0.2.afl
afl/WyckoffVSA_FastMarketScanner_v0.2.afl
afl/WyckoffVSA_DeepReview_v0.2.afl
```

Production Candidate v0.1 hiện tại tiếp tục là baseline/audit reference cho tới khi v0.2 native acceptance hoàn tất.

---

## 10. Ma trận nghiệm thu bắt buộc

### ACC01 — Baseline Decision Equivalence

Chạy baseline v0.1 và v0.2 trên cùng universe, cùng dữ liệu, cùng Parameters tương đương.

Baseline hiện tại có 1.558 Data Eligible trong bài whole-universe sau MS41.

Yêu cầu tối thiểu:

**1.558/1.558 symbol phải khớp toàn bộ decision surface.**

Không chấp nhận “gần giống”.

### ACC02 — MS41 Preservation

Các case DTP, FRT, SNZ phải tiếp tục giữ đúng behavior đã native PASS:

- DTP: A/B outside range → Review, Watch=0, method bit 1024.
- FRT: tương tự.
- SNZ: inside range → không có bit 1024 và không bị MS41 chặn Watch.

### ACC03 — P&F Equivalence in Deep Review

Khi Deep Review bật P&F, các field P&F phải khớp v0.1 với cùng dữ liệu/config, trừ correction đã được duyệt theo PER02.

### ACC04 — No-Lookahead / Bar Replay

Phải chạy Bar Replay end-to-end để chứng minh snapshot/publisher/consumer không nhìn dữ liệu tương lai.

### ACC05 — Append Stability

Kết quả của các bar lịch sử đã hoàn tất không được thay đổi chỉ vì append thêm bar mới, ngoại trừ các trường được đặc tả là provisional/current-state và có provenance đúng.

### ACC06 — Snapshot Staleness Tests

Phải test ít nhất:

- stale date;
- future date;
- schema mismatch;
- config mismatch;
- incomplete generation;
- symbol mismatch.

Tất cả phải fail closed.

### ACC07 — Performance Measurement

Đo thời gian ít nhất cho:

1. v0.1 full Production Candidate trên stock-only universe;
2. v0.2 Daily Publisher;
3. v0.2 Fast Scanner sau khi snapshot đã có;
4. Deep Review trên shortlist.

Performance PASS chỉ có ý nghĩa khi ACC01–ACC06 vẫn đạt.

---

## 11. Quy trình triển khai

1. Duyệt đặc tả này.
2. Không sửa methodology.
3. Tạo implementation branch riêng từ integration branch đã native-tested.
4. Xây RuntimeConfig trước.
5. Xây headless/snapshot publisher với output equivalence.
6. Xây Fast Scanner consumer.
7. Xây Deep Review/P&F deferred path.
8. Chạy static checks.
9. Chạy native equivalence nhỏ theo case.
10. Chạy whole-universe 1.558/1.558 decision equivalence.
11. Chạy Bar Replay/no-lookahead.
12. Đo performance.
13. Chỉ sau toàn bộ native acceptance mới cân nhắc thay workflow hằng ngày.
14. Không merge `main`, không tag/release nếu chưa có phê duyệt riêng của chủ dự án.

---

## 12. Điều kiện chốt v0.2

Không được tuyên bố `PERFORMANCE RUNTIME v0.2 = NATIVE PASS` chỉ vì thời gian chạy nhanh hơn.

Chỉ được PASS khi đồng thời:

- decision equivalence đạt;
- correction exception nếu có đã được duyệt và native-tested;
- MS41 preservation đạt;
- snapshot guards đạt;
- Bar Replay causal acceptance đạt;
- Deep Review/P&F equivalence đạt trong phạm vi áp dụng;
- performance improvement được đo thực tế trên AmiBroker 6.20.01.

**Nguyên tắc cuối cùng:** tối ưu implementation, không tối ưu bằng cách hạ tiêu chuẩn phân tích.
