# Wyckoff VSA Relative Strength Context Engine v0.1 — Rà soát triển khai

**Trạng thái:** `SPEC-ALIGNED DEVELOPMENT / NATIVE ACCEPTANCE BLOCKED BY R35`.

## Mốc chuẩn

- Relative Strength Context R01–R36 được phê duyệt tại PR #32.
- PR #32 merge `main`: `2dedab4168c4845b66a92021ce9a59137a939e82`.
- Derived-Series Pivot Kernel K01–K32 được phê duyệt tại PR #33.
- PR #33 merge `main`: `dcd028447314d49066d0904168ffcf95ed078121`.
- Relative Strength development branch là child của PR #34 Derived-Series Pivot Kernel implementation.

## Tệp triển khai

- `afl/WyckoffVSA_RelativeStrengthContext_v0.1.afl`
- `afl/WyckoffVSA_RelativeStrengthContext_Exploration_v0.1.afl`

## Kiến trúc

Engine consume:

1. `WyckoffVSA_StructureLocation_v1.0.afl` cho confirmed price pivots và cấu hình A/B;
2. `WyckoffVSA_DerivedSeriesPivotKernel_v0.1.afl` cho confirmed pivots trên derived ratio series;
3. optional public upstream variables `WCI_*` và `WMTF_*` khi caller/integration stack đã nạp Composite và Multi-Timeframe Context.

Việc optional bridge ở mục 3 là chủ ý: PR triển khai RS được xếp chồng trên PR #34, trong khi Composite/MTF AFL đang ở các draft stack riêng. Pairwise RS core không được phép copy Phase/Composite/MTF logic. Nếu các biến upstream chưa tồn tại trong formula context, Phase/RS, VSA/RS và MTF/RS phải fail closed thành insufficient/mixed thay vì tự tái tạo upstream.

## Pairwise channels

- `SVM`: Stock vs Market — bắt buộc theo R17.
- `SVG`: Stock vs Group — tùy chọn.
- `GVM`: Group vs Market — tùy chọn, chỉ khi Group benchmark được cấu hình.

Công thức duy nhất:

`RSRatio = numerator Close / denominator Close`

Benchmark Close dùng `Foreign(symbol,"C",0)` để không tự lấp synchronized data hole.

Không dùng benchmark volume, RSI, fixed-return momentum score hay ratio level làm universe rank.

## Cấu trúc RS

Mỗi ratio channel được đưa vào Derived-Series Pivot Kernel với đúng `SL_PivotLeft/SL_PivotRight`.

RS Structure:

- 0 insufficient;
- 1 rising khi 2 confirmed highs gần nhất HH và 2 confirmed lows gần nhất HL;
- 2 falling khi LH + LL;
- 3 mixed/range cho tổ hợp khác.

So sánh strict, không epsilon.

Latest/previous **distinct confirmed pivots** cho structure được lấy từ chính các pivot publication events. Extreme và Confirm coordinates vẫn tách riêng; KnownAt không bị backfill về extreme.

## Comparative wave descriptor

R13 được triển khai bằng pivot-to-opposite-pivot completed wave descriptor. Hai publication liên tiếp cùng kind không bị ép thành completed wave. Wave xuất direction, start/end ratio, % thay đổi, extreme coordinates và duration theo logical source offsets.

Magnitude không được chuyển thành confidence/rank.

## Price/RS, leadership, Phase/VSA/MTF

- Price Structure dùng confirmed price pivot events của Structure/Location; không dựng pivot price thứ hai.
- Price/RS relationship theo R15.
- Leadership Chain theo R20, giữ Stock-vs-Market channel độc lập theo R21.
- Phase/RS dùng `WCI_DirectionalContextCode` nếu upstream có mặt.
- VSA/RS dùng `WCI_EvidenceBalanceCode` nếu upstream có mặt.
- MTF/RS dùng `WMTF_DirectionalAlignmentCode` nếu upstream có mặt.

Không diagnostic nào override upstream.

## Data health và provenance

Public interface có:

- current symbol;
- explicit Market/Group benchmark symbols;
- synchronized benchmark status;
- native interval;
- schema version;
- ratio validity;
- pivot config;
- adjustment-basis declaration/status;
- provisional flag;
- source-revision status placeholder.

`WRS_ContextComputable` phản ánh Daily + market ratio + pivot-config đủ để tính toán.

`WRS_ContextValid` nghiêm ngặt hơn: chỉ true khi adjustment basis được deployment xác nhận compatible. Điều này thực hiện R28 và tránh gọi production-valid khi basis chưa được kiểm chứng.

## R35 — trạng thái chính xác

PR #34 đã có Derived-Series Pivot Kernel source và equivalence harness, nhưng cell-by-cell execution trên AmiBroker 6.20.01 chưa chạy.

Vì chiến lược dự án hiện tại là build-first/test-later, full RS source được phép tiếp tục như development child branch. Tuy nhiên:

- không được gọi R35 native PASS;
- không được gọi Relative Strength native PASS;
- không được merge/release RS như production acceptance trước khi equivalence + native test được xử lý hoặc chủ dự án phê duyệt ngoại lệ rõ ràng.

## Chưa kiểm thử

Chưa thực hiện:

- AmiBroker 6.20.01 Verify Syntax;
- K27–K29 cell-by-cell equivalence execution;
- missing benchmark synchronized-bar fixtures;
- invalid/empty benchmark configuration fixtures;
- corporate-action adjustment basis acceptance fixtures;
- exact pivot tie/boundary cases trên ratio;
- source revision vs repaint audit;
- causal-prefix/append stability;
- integration với Composite/MTF stack;
- long-history performance.

Vì vậy trạng thái vẫn là development, không phải acceptance.