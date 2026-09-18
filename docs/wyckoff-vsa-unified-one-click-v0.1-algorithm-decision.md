# Wyckoff VSA Unified One-Click Scanner v0.1 — Phân tích thuật toán và quyết định kiến trúc

**Trạng thái:** ALGORITHM DECISION — trước triển khai runtime  
**Nhánh:** `feature/one-click-scanner-v0.1`  
**Baseline:** DCMA v0.1 tại `c3b3b45bc3adb18b55d25abae07693c5b7e4df2b`  
**Mục tiêu:** một AFL duy nhất cho cả dữ liệu hiện tại và Bar Replay, một lần Explore, tối ưu thời gian nhưng giữ 100% decision equivalence và causal/no-lookahead.

---

## 1. Bằng chứng hiệu năng đã có

Native benchmark AmiBroker 6.20.01 ngày 2026-09-13:

### Full Runtime
- median: 1874.690 ms/symbol
- mean: 4115.609 ms/symbol
- P95: 14178.315 ms/symbol
- P99: 19842.105 ms/symbol

### Snapshot-only
- median: 1.362 ms/symbol
- mean: 1.480 ms/symbol
- P95: 2.119 ms/symbol
- P99: 2.313 ms/symbol

Decision-surface equivalence: 1558 / 1558, mismatch = 0.

Kết luận bắt buộc: repeated scanning không được chạy full canonical stack lại cho mọi symbol nếu cùng as-of/config đã được tính. Snapshot/cache là điều kiện kiến trúc để đạt hiệu năng tốt.

---

## 2. Nút thắt tính toán trong canonical stack

Các module chính có full-history/state-machine loops:

- Core v1.0: 1 loop
- StructureLocation v1.0: 3 loops
- RangeContext SOW/LPSY v0.1: 3 loops
- PhaseContext v0.1: 3 loops
- Derived-Series Pivot Kernel v0.1: 3 loops, có inner window comparisons

Ngoài ra Runtime hiện dùng `SetBarsRequired(sbrAll,sbrAll)` ở các đường quan trọng. Điều này cố ý giữ toàn bộ history và tắt QuickAFL shortcut cho những state machine cần lịch sử dài.

Vì vậy chi phí lớn nằm ở:
1. tái chạy state machines trên toàn history;
2. tái chạy derived pivot/RS;
3. tái chạy cùng benchmark/higher timeframe nhiều lần.

---

## 3. Các phương án đã đánh giá

### Phương án A — Full direct recompute D/W/M + VNINDEX mỗi Explore

Ưu điểm:
- đơn giản về correctness;
- ít cache invalidation logic.

Nhược điểm:
- Daily full runtime đã khoảng 1.875 s/symbol median;
- thêm W/M và benchmark làm chi phí cold path tăng mạnh;
- đổi Production Filter cũng phải tính lại toàn stack nếu không cache;
- không tận dụng lợi thế 1000x+ đã chứng minh của snapshot-only path.

**Kết luận: loại.**

### Phương án B — Giữ pipeline Publisher -> FastScanner, chỉ bọc UI

Ưu điểm:
- nhanh nhất khi snapshot hợp lệ;
- native equivalence đã có.

Nhược điểm:
- vẫn cần người dùng chạy nhiều AFL;
- không đạt yêu cầu one-click.

**Kết luận: loại ở lớp vận hành; giữ làm oracle/regression.**

### Phương án C — Pure incremental state machine, mỗi ngày chỉ xử lý bar mới

Ưu điểm:
- lý thuyết nhanh nhất cho day-to-day update;
- có thể gần O(1) theo số bar mới thay vì O(history).

Nhược điểm:
- RangeContext/Phase/Structure/RS hiện có nhiều scalar state và confirmed-pivot provenance;
- muốn resume chính xác phải serialize/restore đầy đủ internal state của nhiều engine;
- Bar Replay nhảy lùi/nhảy xa cần checkpoint history hoặc rebuild;
- rủi ro methodology drift/state omission cao;
- phạm vi refactor quá lớn trước khi có equivalence oracle cho resumed execution.

**Kết luận: không chọn cho v0.1. Chỉ cân nhắc sau khi unified cache path PASS 100%.**

### Phương án D — Hybrid self-healing cache + canonical recompute on miss

Ý tưởng:
- cache hit: đọc snapshot scalar giống FastScanner;
- cache miss: chính AFL tự chạy canonical calculation cần thiết và ghi cache;
- benchmark VNINDEX tính một lần cho cùng as-of/config;
- W/M chỉ recompute khi completed period thay đổi;
- Daily stock recompute khi as-of thay đổi;
- Production Filter không nằm trong analytical fingerprint, nên đổi filter không gây recompute.

Ưu điểm:
- giữ correctness vì cache miss dùng canonical logic;
- warm path kế thừa hiệu năng snapshot-only;
- người dùng chỉ chạy một AFL;
- tự xử lý day/week/month rollover;
- phù hợp cả current và Replay;
- có đường rollback/audit rõ ràng.

Nhược điểm:
- cold/new-day run vẫn phải trả chi phí canonical Daily cho universe;
- cần re-entrant/namespaced runtime để tính stock/benchmark và W/M trong cùng formula;
- cần synchronization đúng cho shared market cache.

**Kết luận: CHỌN.**

---

## 4. Thuật toán được chọn

Tên kiến trúc:

**Unified Point-in-Time Self-Healing Cache Scanner**

Entrypoint duy nhất:

`afl/WyckoffVSA_OneClickScanner_v0.1.afl`

Không có entrypoint Replay riêng.

### 4.1 Unified as-of

Nguồn thời gian:
- `LastValue(DateTime())`
- `LastValue(DateNum())`

Khi chạy hiện tại: đây là last visible current bar.  
Khi Bar Replay: AmiBroker chỉ cho formula thấy dữ liệu tới playback position, nên cùng clock tự trở thành replay as-of.

Không cần mode switch Live/Replay.

### 4.2 Cache tầng 1 — Final Decision Snapshot

Mỗi symbol có một decision snapshot scalar:

key tối thiểu:
- symbol
- as-of DateNum
- as-of DateTime
- analytical config fingerprint
- schema/runtime version
- benchmark identity

payload:
- DataEligible
- CandidateClass
- Side
- Stage
- Qualified
- Developing
- Watch
- Review
- ExclusionMask
- MethodBlockMask
- Phase
- Family
- DirectionalContext
- MTF
- RS
- Range diagnostics cần cho decision
- provenance

Nếu key hợp lệ:
- không chạy canonical heavy path;
- chỉ đọc scalar payload và apply Production Filter.

Production Filter không nằm trong analytical fingerprint.

### 4.3 Cache tầng 2 — Shared VNINDEX Context

VNINDEX context dùng chung toàn universe.

key:
- as-of
- config fingerprint
- benchmark symbol
- completed W ordinal
- completed M ordinal
- schema

Một thread giành writer lock bằng compare-exchange.
Thread khác chỉ đọc sau khi generation/ready ổn định.

Payload:
- VNINDEX Daily Composite
- VNINDEX completed Weekly Composite
- VNINDEX completed Monthly Composite
- Market MTF
- Market Selection Context
- benchmark close/RS provenance cần thiết

Không tính full VNINDEX stack N lần cho N cổ phiếu.

### 4.4 Cache tầng 3 — Per-symbol Weekly/Monthly

Weekly key:
- symbol
- completed weekly ordinal
- config fingerprint
- schema

Monthly key:
- symbol
- completed monthly ordinal
- config fingerprint
- schema

Nếu kỳ chưa đổi:
- không recompute W/M.

Nếu rollover:
- chỉ timeframe bị đổi mới recompute.

### 4.5 Daily stock path

Nếu Final Decision Snapshot miss:
1. chạy Daily canonical stock runtime đúng visible as-of;
2. lấy W/M từ cache hoặc recompute đúng completed period;
3. lấy shared VNINDEX context;
4. tính RS stock-vs-market;
5. tính MTF categorical relation;
6. gọi shared ScannerDecisionKernel;
7. ghi Final Decision Snapshot;
8. apply filter/output.

---

## 5. Dựng Weekly/Monthly trong một AFL

Ưu tiên kỹ thuật:

1. Refactor analytical stack thành re-entrant/namespaced runtime.
2. Dùng `TimeFrameSet(inWeekly)` / `TimeFrameSet(inMonthly)` hoặc compressed-input equivalent trên cache miss.
3. `TimeFrameRestore()` bắt buộc giữa contexts.
4. Capture output vào namespace riêng trước khi đổi timeframe/context.

AmiBroker hỗ trợ nhiều timeframe trong một formula, nhưng **không được mặc định coi kết quả TimeFrameSet là canonical-equivalent**.

Gate bắt buộc trước khi sử dụng:
- native W/M equivalence với publisher Periodicity Weekly/Monthly;
- exact match các payload fields khóa;
- no future source;
- completed-period ordinal đúng.

Nếu TimeFrameSet path không match 100%, phải dùng cách dựng higher-timeframe khác; không chấp nhận xấp xỉ.

---

## 6. Relative Strength

RS tiếp tục dùng benchmark với missing bars không được forward-fill ngầm.

Canonical historical path hiện dùng:

`Foreign(VNINDEX,"C",0)`

Unified runtime có thể:
- build benchmark close array một lần;
- lưu/read static array;
- dùng normal variable read-once trong mỗi formula instance.

Không gọi lại benchmark engine nặng cho từng stock.

Static array chỉ dùng khi timestamp alignment/provenance đã xác minh.

---

## 7. StaticVar policy

Static arrays/scalars là cache, không phải source of truth.

Quy tắc:
- read once -> xử lý bằng normal variables -> write once;
- metadata scalar luôn đi kèm payload;
- generation/ready atomic protocol;
- align=true mặc định cho array data;
- không dùng align=false trừ khi có proof timestamp mapping;
- không tích lũy cache vô hạn theo mọi replay date.

Replay/current chỉ giữ active cache key; khi nhảy sang as-of khác có thể overwrite namespace active thay vì lưu toàn bộ lịch sử.

---

## 8. Bar Replay

Cùng AFL, cùng thuật toán.

### Replay same date
Final snapshot hit -> path gần snapshot-only.

### Replay +1 day
- Daily decision key miss -> recompute Daily stock;
- W/M hit nếu chưa rollover;
- market W/M hit nếu chưa rollover.

### Replay week rollover
- Weekly miss/recompute;
- Monthly vẫn hit.

### Replay month rollover
- Monthly miss/recompute.

### Replay jump backward
- future cache key không được dùng;
- as-of mismatch => cache miss;
- canonical rebuild tới visible data hiện tại;
- ghi đè active cache.

Không cần historical timeline publisher để lọc một thời điểm.

---

## 9. Tại sao chưa chọn incremental checkpoint

Incremental checkpoint có tiềm năng nhanh hơn ở new-day cold path, nhưng chưa phải tối ưu tổng thể dưới constraint correctness hiện tại.

Lý do:
- nhiều engine chứa loop-state phức tạp;
- state cần checkpoint chưa có public contract;
- omission một internal state có thể làm Phase/Range/RS lệch âm thầm;
- khó chứng minh append stability và backward replay cùng lúc.

Điều kiện mới được nghiên cứu incremental:
1. Unified cache scanner đạt 100% equivalence;
2. đo native cho thấy new-day cold path vẫn là bottleneck cần xử lý;
3. viết explicit state-checkpoint contract;
4. checkpoint/restart equivalence PASS trước khi thay default path.

---

## 10. Acceptance tối thiểu

### UA01 Cold current
Không cache, một Explore -> kết quả đúng.

### UA02 Warm current
Cùng as-of/config -> snapshot hit, không chạy heavy path.

### UA03 Filter-only change
Đổi 1.2 filter -> không invalidate analytical cache.

### UA04 New day
Daily refresh; W/M không refresh nếu period không đổi.

### UA05 Week rollover
Weekly refresh đúng một lần/kỳ.

### UA06 Month rollover
Monthly refresh đúng một lần/kỳ.

### UA07 Shared market
VNINDEX heavy context không bị tính lại theo từng stock.

### UA08 Replay same date
Warm cache đúng as-of.

### UA09 Replay backward/forward
Không future-cache leakage.

### UA10 Native W/M equivalence
One-click W/M == native-periodicity publisher W/M.

### UA11 Decision equivalence
100% match canonical production decision surface.

### UA12 Timing
Đo:
- cold current
- warm current
- filter-only rerun
- new day
- week rollover
- month rollover
- replay cold
- replay warm
- replay step
- replay backward jump

---

## 11. Quyết định

**Chọn Hybrid Self-Healing Cache, không chọn Full Recompute và chưa chọn Pure Incremental.**

Ưu tiên triển khai:
1. unified cache contract;
2. re-entrant context kernel;
3. shared VNINDEX cache;
4. W/M lazy cache;
5. final decision cache;
6. unified entrypoint;
7. equivalence;
8. performance benchmark;
9. chỉ sau đó nghiên cứu incremental checkpoint nếu cần.

Checkpoint thiết kế:

`UNIFIED_ONE_CLICK_ALGORITHM_DECISION_V01 = HYBRID_SELF_HEALING_CACHE`
