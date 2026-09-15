# Upthrust / UTAD Event v0.1 — Hồ sơ triển khai phát triển

**Trạng thái:** `SPEC-ALIGNED / UNTESTED DEVELOPMENT`. Logic AFL đã được căn chỉnh theo D01–D20 được chủ dự án phê duyệt ở PR #16. Chưa chạy Verify Syntax trên AmiBroker, chưa có fixture/expected riêng và chưa được nghiệm thu native.

## 1. Mốc đặc tả

- PR #16: đặc tả Upthrust / UTAD v0.1 đã được chủ dự án phê duyệt.
- Merge commit khóa đặc tả trên `main`: `d0354bc1314a25806c3cd4f9c70d70b9cd9b52b1`.
- Tài liệu triển khai trên nhánh này: `docs/wyckoff-event-upthrust-utad-v0.1-spec.md`.
- AFL: `afl/WyckoffVSA_Event_UpthrustUTAD_v0.1.afl`.

## 2. Thay đổi so với PR #13 ban đầu

AFL ban đầu của PR #13 không còn được coi là source-of-truth. Bản hiện tại đã sửa các khác biệt trọng yếu sau:

1. Bỏ `MaxPenetrationATR = 1.00` khỏi hard gate Origin.
2. Bỏ `ClosePosition <= 0.50` khỏi hard gate Origin; ClosePosition chỉ còn là quality descriptor.
3. Bỏ RVOL/RSpread khỏi hard gate Origin.
4. Xóa logic `UTAD-LIKE = deep penetration OR high effort`.
5. Event layer chỉ có `UPTHRUST-LIKE`; UTAD dành cho Phase/Context Engine tương lai.
6. Thêm `PriorClose <= Resistance` để xác định fresh thrust từ phía dưới/trong vùng.
7. Thêm `WE_UT_UpperBreakoutObservation` cho trường hợp xuyên resistance nhưng Close vẫn ở trên resistance.
8. Resolution tối thiểu tại k+1 đổi thành `Close <= frozen Resistance` và `Close < Close_origin`.
9. `High <= Resistance` tại k+1 chỉ còn là descriptor `EvaluationFullyBelowResistance`, không phải gate.
10. PriorATR/PenetrationATR, ClosePosition, RVOL, RSpread có validity riêng và không làm mất Origin nếu thiếu.
11. Bổ sung snapshot resistance pivot, tuổi/BarsSinceConfirmation, PriorClose, descriptor effort/rejection và S/M/L context.
12. Giữ Origin, Resolution và UpperBreakoutObservation thành các kênh riêng.

## 3. Hợp đồng Origin hiện tại

`WE_UT_OriginCode = 2` chỉ khi:

```text
PriceValid_k = 1
ResistanceValid_k = 1
PriorCloseValid_k = 1
PriorClose_k <= ResistancePrice_k
High_k > ResistancePrice_k
Close_k <= ResistancePrice_k
```

Không yêu cầu PriorATR, ClosePosition, RVOL hoặc RSpread hợp lệ để tồn tại Origin.

`WE_UT_OriginKindCode` chỉ có `1 = UPTHRUST-LIKE` khi OriginCode=2. Không có `UTAD-LIKE` trong Event layer.

## 4. Upper Breakout Observation

Khi fresh thrust xuyên resistance nhưng đóng cửa vẫn trên resistance:

```text
PriorClose <= Resistance
High > Resistance
Close > Resistance
```

AFL xuất `WE_UT_UpperBreakoutObservation = 1`, không gán Upthrust, UTAD, breakout-success hoặc Distribution.

Đây là dữ liệu đầu vào cho sequence/Phase Engine tương lai nếu cần theo dõi nhiều thanh phía trên resistance trước khi failure trở lại range.

## 5. Resolution hiện tại

Origin tại k chỉ được giải quyết tại k+1.

Confirmed khi:

```text
Close_(k+1) <= ResistancePrice_k
AND Close_(k+1) < Close_k
```

`High_(k+1) <= ResistancePrice_k` chỉ mô tả một xác nhận mạnh hơn và không quyết định `ResolutionCode=3`.

Không có late confirmation ở k+2 và không backfill kết luận vào origin.

## 6. Bảo vệ nhân quả và kiến trúc

- Chỉ include upstream `WyckoffVSA_Confirmation_v1.0.afl`.
- Không sửa Core, Candidate, Structure/Location, Confirmation, Supply Test hoặc Spring/Shakeout.
- Event resistance chỉ dùng `SL_PivotHighLatestPrior...` đã tồn tại trước k.
- Pivot mới ở k hoặc k+1 không thay frozen resistance của event đang giải quyết.
- Không dùng Zig/Peak/Trough look-ahead.
- Không tạo Buy/Sell/Short/Cover/PositionSize.
- Không tự gán UTAD/Distribution/Phase.

## 7. Tình trạng kiểm thử

Theo chiến lược hiện tại của chủ dự án, kiểm thử được tạm hoãn để hoàn thiện bộ chỉ báo trước. Vì vậy các mục sau **chưa được tuyên bố PASS**:

- AmiBroker Verify Syntax 6.20.01;
- fixture/expected độc lập;
- đối chiếu native Exploration;
- regression upstream;
- causality/suffix invariance;
- append test;
- historical source revision;
- forming-bar behavior.

Trạng thái `SPEC-ALIGNED` chỉ có nghĩa mã nguồn đã được sửa để phản ánh đặc tả D01–D20 đã duyệt; không đồng nghĩa nghiệm thu.

## 8. Trạng thái PR

PR #13 phải tiếp tục giữ `draft` trong giai đoạn hoàn thiện bộ chỉ báo. Không merge vào nhánh cha hoặc `main` chỉ dựa trên việc căn chỉnh đặc tả. Khi chiến dịch kiểm thử được mở lại, đây sẽ là đơn vị được kiểm thử theo đúng D01–D20 đã khóa.
