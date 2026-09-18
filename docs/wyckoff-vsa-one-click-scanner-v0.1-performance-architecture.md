# Wyckoff VSA One-Click Scanner v0.1 — Kiến trúc tối ưu hiệu năng

**Mục tiêu:** hai entrypoint production, mỗi entrypoint một AFL + một Explore:
- `WyckoffVSA_OneClickScanner_v0.1.afl` — current/EOD
- `WyckoffVSA_OneClickReplayScanner_v0.1.afl` — Bar Replay/historical point-in-time

## 1. Nguyên tắc

Tối ưu bằng loại bỏ tính lặp, không bằng hạ tiêu chuẩn phân tích.

### P01 — Benchmark once
VNINDEX là dependency dùng chung. Trong cùng as-of/config, benchmark Daily/Weekly/Monthly context chỉ được tính một lần rồi tái sử dụng cho toàn universe.

### P02 — Higher-timeframe period cache
Weekly/Monthly cache khóa theo completed-period ordinal + symbol + config.
Nếu chưa rollover, không tái tính higher timeframe.

### P03 — Current-state boundary
Current scanner chỉ cần authoritative state ở last visible bar. Có thể giữ state/cache trước đó nhưng output phải tương đương full canonical calculation.

### P04 — Replay visible-as-of cache
Replay cache thêm visible DateTime/DateNum vào key. Cache thuộc playback position tương lai bị cấm.

### P05 — Shared decision kernel
SelectionContext, StageFromPhase và Candidate Class mapping dùng kernel chung giữa current và replay để tránh drift.

### P06 — Cheap hard gates first
Được kiểm tra interval/config/benchmark availability trước các phép tính đắt. Không được bỏ qua analytical computation dựa trên heuristic chưa chứng minh equivalence.

### P07 — No duplicate diagnostics
Production compact mode không tạo audit arrays/cột nặng không ảnh hưởng decision. Audit mode mới bật diagnostics sâu.

### P08 — P&F deferred
P&F tiếp tục deferred vì không thuộc Candidate Class semantics hiện hành.

## 2. Cache namespace

Đề nghị:
`WVSA_OC_v01_<ROLE>_<SYMBOL>_<PERIOD>_<CONFIG>_*`

ROLE:
- MKT
- STOCK
- W
- M
- RS

Metadata tối thiểu:
- SchemaMajor/Minor
- ConfigFingerprint
- SourceDateNum
- SourceDateTime
- PeriodOrdinal
- Generation
- Ready
- PayloadValid

Nếu có nhiều Analysis thread, write phải dùng compare-exchange/generation protocol.

## 3. Current/EOD path

1. Xác định visible as-of.
2. Resolve VNINDEX benchmark cache; tính nếu thiếu/stale.
3. Với mỗi stock:
   - resolve W/M completed-period cache;
   - tính Daily current state;
   - tính RS với benchmark close;
   - kết hợp Market context;
   - gọi shared decision kernel;
   - áp Production Filter.
4. Chỉ output last visible bar.

Không yêu cầu persisted Daily Snapshot.

## 4. Replay path

1. Visible as-of = playback position.
2. Benchmark array chỉ dùng visible data.
3. Weekly/Monthly dùng completed period trước current Daily period.
4. Chỉ refresh W/M khi period ordinal đổi.
5. Tính stock Daily/RS/decision tại bar visible.
6. Không đọc future timeline/static state.
7. Apply filter và output đúng bar visible.

## 5. Mục tiêu benchmark

Đo riêng:
- current cold run toàn universe;
- current warm run cùng ngày;
- replay cold run;
- replay repeat cùng ngày;
- replay +1 day;
- replay week rollover;
- replay month rollover.

Không đặt ngưỡng tốc độ tuyệt đối trước native benchmark. Ưu tiên:
1. warm run nhanh hơn cold run;
2. day advance không tái tính Monthly nếu không rollover;
3. benchmark không bị tính N lần cho N stocks;
4. decision equivalence = 100%.

## 6. Thứ tự triển khai

1. Shared decision kernel.
2. Benchmark/current-context runtime tách role.
3. Higher-timeframe causal runtime không cần publisher thủ công.
4. OneClick current entrypoint.
5. OneClick Replay entrypoint.
6. Static audit.
7. Native single-symbol.
8. Whole-universe equivalence.
9. Bar Replay equivalence/no-lookahead.
10. Performance benchmark.
