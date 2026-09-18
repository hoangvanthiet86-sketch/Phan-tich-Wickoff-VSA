# Wyckoff VSA One-Click Scanner v0.1 — Kiến trúc hiệu năng

**Mục tiêu:** giảm số thao tác người dùng xuống một AFL/một Explore, đồng thời giảm tính toán lặp mà không đổi methodology.

## 1. Nguyên tắc

Tối ưu thời gian theo thứ tự ưu tiên:

1. loại bỏ tính lại benchmark cho từng symbol;
2. tái sử dụng Weekly/Monthly khi completed period chưa đổi;
3. chỉ recompute Daily theo ngày/as-of mới;
4. giữ calculation causal;
5. chỉ sau khi equivalence PASS mới tối ưu sâu vòng lặp/QuickAFL.

Không cắt history tùy tiện ở v0.1.

## 2. Hai tầng cache

### Shared Market Cache

Một cache toàn Analysis cho `VNINDEX`.

Khởi tạo ở top-level `Status("stocknum")==0` để AmiBroker hoàn tất preprocessing trước khi chạy các symbol thread khác.

Payload tối thiểu:

- as-of DateNum/DateTime;
- config fingerprint;
- Daily Composite;
- completed Weekly Composite;
- completed Monthly Composite;
- Market MTF;
- Market selection context;
- generation/ready/schema.

### Per-Symbol Higher-Timeframe Cache

Mỗi symbol có W/M cache riêng.

Weekly key = symbol + config + completed weekly ordinal + schema.  
Monthly key = symbol + config + completed monthly ordinal + schema.

Nếu key hợp lệ thì không chạy lại higher-timeframe analytical stack.

## 3. Direct Daily path

Daily stock context được tính trực tiếp trong One-Click runtime cho current/replay visible as-of.

Không yêu cầu DailyPublisher.

Fast snapshot cũ có thể được dùng làm optional warm cache nếu fingerprint/date/schema khớp, nhưng không phải dependency.

## 4. Re-entrant Phase/Composite kernel

Để chạy cùng methodology trên D/W/M và benchmark trong một AFL, Phase/Composite runtime phải được tách thành:

- helper/function definitions nạp một lần;
- recompute body không chứa Param, output hoặc publisher logic;
- capture facade lưu các output cần thiết ngay sau mỗi context run.

Context execution dùng **một analytical body include duy nhất** bên trong context loop để không nhân kích thước công thức. Mỗi iteration chỉ chạy khi cache tương ứng miss.

Thứ tự logic:

1. resolve/build shared VNINDEX context;
2. stock Daily canonical run nếu final decision cache miss;
3. stock Weekly recompute nếu completed-week cache miss;
4. stock Monthly recompute nếu completed-month cache miss;
5. compute stock RS với benchmark;
6. lightweight MTF relation;
7. shared Scanner Decision Kernel;
8. commit final decision cache;
9. filter/output.

## 5. Threading

Không dùng lock cho mọi symbol.

Chỉ shared market cache cần exclusive initialization. Top-level `Status("stocknum")==0` là cơ chế chính.

`StaticVarCompareExchange` dùng cho generation/write protection nếu cache persistence có thể bị formula khác chạm đồng thời.

`ThreadSleep` chỉ dùng bounded wait trong exceptional synchronization path; không dùng trong hot path.

## 6. Replay

Cùng một kernel và cùng active-slot namespace. Current/Replay không tách namespace theo mode; identity được khóa bằng `AsOfDateNum + AsOfDateTime + ConfigFingerprint + schema`. Khi playback thay đổi, cache cũ tự miss. Điều này tránh tích lũy cache vô hạn theo hàng nghìn replay date và vẫn tuyệt đối không tái sử dụng payload tương lai.

## 7. Đo thời gian

Mỗi native run ghi:

- total Explore elapsed time từ AmiBroker;
- shared market build hit/miss;
- stock W cache hit/miss;
- stock M cache hit/miss;
- number of Daily recomputes;
- output row count.

Các benchmark bắt buộc:

A. pipeline publisher cũ cold;
B. FastScanner warm;
C. OneClick cold;
D. OneClick warm;
E. Replay one-click cold;
F. Replay one-click +1 day;
G. replay week/month rollover.

## 8. Điều kiện tối ưu sâu

Chỉ sau khi one-click decision equivalence = 100% mới cân nhắc:

- incremental state checkpoint;
- giảm sbrAll có proof;
- loop-to-array refactor;
- additional static-array caches.

Không trộn thay đổi methodology với performance optimization.
