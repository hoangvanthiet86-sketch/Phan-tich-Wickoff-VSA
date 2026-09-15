# SOW / LPSY v0.1 — Hồ sơ rà soát triển khai

**Trạng thái:** `SPEC-ALIGNED / UNTESTED DEVELOPMENT`.

## Nền

- Đặc tả D01–D31 đã được chủ dự án phê duyệt và khóa tại PR #23.
- Merge commit đặc tả: `7670532a230eb051cf5d362be092e2d81283fb92`.
- Nhánh triển khai xếp chồng trên Structural Sequence PR #21 head `5d488602ceeb0504081d05a4379625bb4a76283d`.
- AFL: `afl/WyckoffVSA_RangeContext_SOWLPSY_v0.1.afl`.
- Hợp đồng: `docs/wyckoff-event-sow-lpsy-v0.1-implementation-contract.md`.
- Kiểm toán tĩnh: `docs/wyckoff-event-sow-lpsy-v0.1-static-conformance-audit.md`.

## Nội dung đã triển khai

- Hai range channel lower-derived và upper-derived độc lập từ frozen Structural Sequence D29 snapshot.
- SOW Price Challenge tách khỏi expanded-effort classification.
- SOW-LIKE dùng operational thresholds RSpread `>=1.20` và RVOL `>=1.25` đã khóa trong đặc tả.
- Accepted breakdown tách khỏi SOW identity; close-at-support không phải breakdown.
- ClosePosition, DirectionalProgress, Effort/Result, Stopping Volume và Absorption chỉ là descriptors/context.
- SOW snapshot đóng băng RangeAnchorKey constituents, range boundaries, OHLC và measurements.
- Multiple SOW với ordinal trong range; latest SOW chỉ thay anchor cho future LPSY.
- Immediate response tại k+1 giữ FurtherWeakness / SupportStillLost / RecoveredSupport mà không backfill SOWCode.
- LPSY chỉ từ confirmed Pivot High sau active SOW, có rally thật và thất bại strict trước frozen RangeHigh.
- PivotHigh `>= RangeHigh` không bị ép thành LPSY; giữ `UpperRangeChallengeAfterSOW` observation.
- LPSY identity tách khỏi No Demand/low-volume/narrow-spread quality.
- Quality snapshot chứa No Demand tại extreme, No Demand confirmed trong rally, contraction vs SOW, Effort/Result và Upthrust overlap.
- EvidenceClass 0..4 là categorical evidence routing, không phải weighted score.
- Nhiều LPSY được phép trên cùng SOW anchor.
- Không suy ra Distribution, Redistribution, Phase D/E hoặc trading action.

## Kết quả kiểm toán tĩnh

`STATIC SPEC CONFORMANCE = PASS` cho D01–D31 trong phạm vi source review.

Điều này chỉ xác nhận cấu trúc mã và interface bám đặc tả; không phải native/runtime acceptance.

## D38 — trạng thái cổng kiến trúc

D38 của Phase/Context yêu cầu SOW/LPSY phải được nghiên cứu, đặc tả riêng, phê duyệt, khóa và có implementation contract ổn định trước khi mở full AFL Phase/Context.

Sau PR #23 và implementation contract hiện tại, **cổng D38 đã được thỏa ở cấp đặc tả + source/interface**. Tuy nhiên SOW/LPSY vẫn là `UNTESTED DEVELOPMENT`; Phase/Context triển khai sau đó cũng phải giữ trạng thái development cho đến chiến dịch kiểm thử tổng thể.

## Rủi ro kỹ thuật còn phải kiểm thử native

1. Verify Syntax AmiBroker 6.20.01 chưa chạy.
2. Stateful active-SOW loop và same-bar ordering cần fixture xác minh.
3. Hai range channel có thể đồng thời phát event; cần fixture overlap.
4. No Demand scan trong rally cần đo hiệu năng trên lịch sử dài.
5. Equality tại support/range-high dùng strict/no-epsilon theo đặc tả; cần boundary fixtures.
6. Chưa có regression, causality-prefix, append stability, source-revision hoặc forming-bar audit.

## Kết luận

SOW/LPSY v0.1 hiện đủ điều kiện **về mặt đặc tả và hợp đồng source/interface** để Phase/Context Engine có thể bắt đầu triển khai mà không phải viết lại weakness events bên trong Phase Engine.

Trạng thái chính xác vẫn là:

`SPEC-ALIGNED / UNTESTED DEVELOPMENT`
