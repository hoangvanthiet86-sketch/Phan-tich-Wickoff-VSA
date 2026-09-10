# Wyckoff VSA Derived-Series Pivot Kernel v0.1 — Kiểm toán phù hợp tĩnh

**Kết luận:** `STATIC SPEC CONFORMANCE = PASS`

**Phạm vi:** chỉ kiểm tra mã nguồn/giao diện với K01–K32. Không phải AmiBroker native acceptance và không phải kết quả chạy cell-by-cell.

## K01–K04 — kiến trúc và oracle

PASS:

- kernel độc lập, không refactor Structure/Location v1.0;
- Structure/Location v1.0 giữ vai trò behavioral oracle;
- input là arbitrary numeric series + explicit validity;
- namespace `WDP_<channel>_...` cho phép nhiều derived pair độc lập.

## K05–K12 — cấu hình và cửa sổ

PASS:

- `PivotLeft/PivotRight` dùng cùng miền 1..20;
- không có RS-specific pivot tuning;
- `PivotLength=A+B+1`;
- candidate tại `i-B`;
- full window và valid-count logic được giữ theo source Structure;
- missing derived data không được fill;
- window diagnostics có start/end/candidate coordinates.

## K13–K18 — định nghĩa pivot

PASS:

- High: strict-left `>` và inclusive-right `>=`;
- Low: strict-left `<` và inclusive-right `<=`;
- không epsilon/rounding;
- không Zig/Peak/Trough;
- không future offset;
- publication tại confirm bar, không backfill extreme.

## K19–K24 — tọa độ và snapshot

PASS:

- tách ExtremeBarIndex/DateTime và ConfirmBarIndex/DateTime;
- confirmation lag = B;
- `LatestPrior` lấy trước current-bar evaluation;
- `Latest` lấy sau current-bar evaluation;
- Age và BarsSinceConfirmation dùng logical offsets;
- invalid/no-history outputs giữ Null/0 semantics thay vì synthetic fallback.

## K25–K26 — Relative Strength usage boundary

PASS:

- convenience entry point dùng cùng một derived series để tính cả Pivot High và Pivot Low;
- kernel không tính RS ratio, không tạo RS Structure, Phase, Event, score hoặc trading semantics.

## K27–K29 — equivalence contract

PASS ở cấp **audit harness presence/source mapping**:

- có harness chạy High input đối chiếu `SL_PivotHigh...`;
- có harness chạy Low input đối chiếu `SL_PivotLow...`;
- so window, event, extreme/confirm, latest/latest-prior, age/bars-since;
- có cell-level mismatch flags và aggregate mismatch counts.

**Chưa PASS execution:** harness chưa chạy trên AmiBroker 6.20.01 nên chưa có bằng chứng mismatch count = 0. R35 chỉ được coi là thỏa ở cấp source/interface, chưa phải native acceptance.

## K30–K32 — ranh giới và trạng thái

PASS:

- không trading logic;
- không benchmark fallback/fill logic;
- không full Relative Strength implementation trong kernel PR;
- trạng thái đúng: `SPEC-ALIGNED / UNTESTED DEVELOPMENT`.

## Kết luận

`STATIC SPEC CONFORMANCE = PASS`

`CELL-BY-CELL EQUIVALENCE EXECUTION = PENDING`

`AMIBROKER 6.20.01 NATIVE ACCEPTANCE = PENDING`