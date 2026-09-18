# Wyckoff VSA One-Click Scanner v0.1 — Đặc tả dự thảo

**Trạng thái:** DRAFT FOR IMPLEMENTATION  
**Nhánh triển khai:** `feature/one-click-scanner-v0.1`  
**Baseline:** `main` tại `c3b3b45bc3adb18b55d25abae07693c5b7e4df2b`  
**Mục tiêu:** một AFL duy nhất, một lần Explore, trả kết quả lọc cuối cùng.

---

## 1. Yêu cầu vận hành bắt buộc

Người dùng chỉ phải thực hiện:

1. mở `WyckoffVSA_OneClickScanner_v0.1.afl`;
2. `Apply to = VN STOCKS ONLY`;
3. `Periodicity = Daily`;
4. `Range = 1 Recent Bar`;
5. chọn Production Filter;
6. bấm `Explore` đúng một lần.

Không được yêu cầu người dùng chạy trước hoặc chạy riêng:

- Weekly Publisher;
- Monthly Publisher;
- VNINDEX Weekly/Monthly Publisher;
- Cross-Symbol Selection Publisher;
- Daily Publisher;
- Fast Scanner cache warm-up;
- bất kỳ AFL chuẩn bị dữ liệu trung gian nào khác.

Nếu cache/snapshot được dùng nội bộ thì đó là chi tiết triển khai và không được trở thành thao tác bắt buộc của người dùng.

---

## 2. Kết quả phải bảo toàn

One-Click Scanner không được thay đổi methodology hay decision semantics.

Với cùng dữ liệu và cùng cấu hình, kết quả cuối phải tương đương implementation production hiện hành ở tối thiểu các trường:

- Data Eligible;
- Candidate Class;
- Candidate Side;
- Candidate Stage;
- Qualified;
- Developing;
- Watch;
- Review;
- Exclusion Mask;
- Method Block Mask;
- Phase;
- Family;
- Directional Context;
- MTF Directional Alignment;
- RS vs Market;
- Range status/location diagnostics có ảnh hưởng quyết định.

Không tạo score/ranking mới.
Không thêm Buy/Sell/Short/Cover.
Không thay threshold.
Không thay Candidate Class methodology.
Không thay strict ambiguity.
Không thay semantics PublicActive / ContextMultiplicity đã phát hành ở DCMA v0.1.

---

## 3. Hợp đồng dependency tự động

One-Click Scanner phải tự đảm bảo trong chính lượt chạy rằng các dependency cần cho ngày quét là hợp lệ.

### 3.1 Daily
Daily state của từng cổ phiếu phải được tính cho đúng bar/as-of hiện tại.

### 3.2 Weekly
Weekly context phải lấy từ kỳ Weekly hoàn tất gần nhất theo Operational Clock.

Người dùng không phải tự phát hiện sang tuần mới và không phải chạy Weekly Publisher.

### 3.3 Monthly
Monthly context phải lấy từ kỳ Monthly hoàn tất gần nhất theo Operational Clock.

Người dùng không phải tự phát hiện sang tháng mới và không phải chạy Monthly Publisher.

### 3.4 VNINDEX / Market context
Market benchmark mặc định là `VNINDEX`.

One-Click Scanner phải tự bảo đảm market context và MTF của VNINDEX đúng ngày/kỳ cần thiết mà không yêu cầu một lượt Analysis riêng trên VNINDEX.

### 3.5 Relative Strength
RS Stock-vs-Market phải dùng cùng benchmark/config hiện hành và giữ nguyên adjustment-basis contract.

---

## 4. Cache / snapshot policy

Cache được phép để tăng tốc nhưng phải theo các quy tắc sau:

1. Cache hợp lệ thì được tái sử dụng.
2. Cache stale/future/schema-mismatch/config-mismatch phải bị từ chối.
3. Nếu cache thiếu hoặc không hợp lệ, One-Click Scanner phải tự tính lại dependency cần thiết hoặc tự refresh nội bộ trong cùng workflow.
4. Không được fail-closed chỉ vì người dùng chưa chạy một publisher thủ công.
5. Fail-closed chỉ áp dụng khi dữ liệu nguồn thực sự không đủ/không hợp lệ hoặc không thể tái tạo dependency một cách causal.
6. Không được dùng snapshot cũ để giả lập dữ liệu mới.

---

## 5. Giao diện người dùng

Entrypoint production:

`afl/WyckoffVSA_OneClickScanner_v0.1.afl`

Production Filter giữ semantics hiện tại:

- 0 = Qualified
- 1 = Developing+
- 2 = Watch+
- 3 = Review/Audit
- 4 = All Eligible

Mặc định: `2 = Watch+`.

Output compact tối thiểu:

- Ticker
- Date/Time
- Data status
- Data Eligible
- Candidate Class
- Side
- Stage
- Phase
- Family
- Range Position
- MTF Alignment
- RS vs Market
- Review
- Method Block reason

Diagnostics có thể bật riêng nhưng không được yêu cầu cho workflow bình thường.

---

## 6. Kiến trúc triển khai

Không khóa trước kỹ thuật nội bộ miễn là đáp ứng hợp đồng một-click và bảo toàn kết quả.

Các hướng hợp lệ gồm:

- tính trực tiếp Daily/Weekly/Monthly/Benchmark trong một runtime namespaced;
- tự refresh cache/snapshot nội bộ;
- refactor analytical engines thành các runtime callable/namespaced để có thể chạy stock và benchmark trong cùng một Analysis;
- kết hợp direct-compute + cache với fallback causal.

Không được chỉ tạo một wrapper gọi `FastScanner` rồi tiếp tục yêu cầu publisher thủ công.

---

## 7. Bất biến kỹ thuật

- AmiBroker target: 6.20.01.
- Operational Clock hiện hành giữ nguyên.
- Canonical business date vẫn là `DateNum`.
- Không numeric YYYYMMDD làm canonical key.
- Không look-ahead.
- Không dùng Weekly/Monthly bar chưa hoàn tất như authoritative higher-timeframe context.
- Không silent fallback sang stale state.
- Không thay RuntimeConfig analytical values mà người dùng không nhìn thấy.
- Không sửa các release engine cũ nếu có thể đạt mục tiêu bằng runtime/wrapper mới; nếu buộc phải refactor thì phải có regression tương đương.

---

## 8. Native acceptance bắt buộc

### OC01 — One-click cold start
Xóa/không có cache liên quan, chạy đúng một AFL trên VN STOCKS ONLY, một lần Explore.

Yêu cầu: có kết quả hợp lệ mà không chạy publisher trước.

### OC02 — Same-day repeat
Chạy lại One-Click Scanner nhiều lần trong cùng ngày.

Yêu cầu: decision surface không đổi; cache nếu có được tái sử dụng an toàn.

### OC03 — New trading day
Từ snapshot/ngữ cảnh ngày trước, cập nhật dữ liệu sang ngày mới rồi chỉ chạy One-Click Scanner.

Yêu cầu: tự refresh/tính lại đúng dependency; không trả `STALE SNAPSHOT` chỉ vì chưa chạy publisher thủ công.

### OC04 — Week rollover
Chuyển qua tuần mới.

Yêu cầu: Weekly completed-period dependency tự cập nhật trong cùng workflow.

### OC05 — Month rollover
Chuyển qua tháng mới.

Yêu cầu: Monthly completed-period dependency tự cập nhật trong cùng workflow.

### OC06 — VNINDEX market context
Không chạy Analysis riêng cho VNINDEX.

Yêu cầu: market context vẫn hợp lệ và đúng ngày/kỳ.

### OC07 — Production equivalence
Trên cùng universe/ngày/config, so với pipeline canonical đã được cập nhật đầy đủ.

Yêu cầu: 100% match cho toàn bộ decision surface khóa.

### OC08 — Fail-closed thật sự
Thiếu dữ liệu benchmark, dữ liệu nguồn hỏng, schema không thể xử lý, hoặc provenance causal không đủ.

Yêu cầu: fail closed có lý do rõ ràng; không dùng dữ liệu cũ.

### OC09 — Performance
Đo thời gian one-click cold run và warm run.

Không chấp nhận tăng tốc bằng cách hạ tiêu chuẩn phân tích.

---

## 9. Backward compatibility

Các file hiện có vẫn được giữ để audit/regression:

- `WyckoffVSA_DailyPublisher_v0.2.afl`
- `WyckoffVSA_FastScanner_v0.2.afl`
- Weekly/Monthly publishers
- Selection publisher

Sau khi One-Click Scanner native PASS, chúng trở thành hạ tầng/audit entrypoints, không còn là thao tác bắt buộc trong workflow người dùng.

---

## 10. Điều kiện chốt

Chỉ được gọi:

`ONE_CLICK_SCANNER_V01 = PASS`

khi OC01-OC09 đạt trên AmiBroker 6.20.01 và không có unexplained mismatch so với production canonical pipeline.

Không merge `main`, không tag/release nếu chưa có final review và phê duyệt riêng.
