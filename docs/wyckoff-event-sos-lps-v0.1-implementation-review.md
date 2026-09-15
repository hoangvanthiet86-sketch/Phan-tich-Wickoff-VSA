# SOS / LPS Event v0.1 — Hồ sơ triển khai phát triển

**Trạng thái:** `SPEC-ALIGNED / UNTESTED DEVELOPMENT`.

Logic AFL hiện tại đã được căn chỉnh theo D01–D22 được chủ dự án phê duyệt ở PR #17. Chưa chạy Verify Syntax trên AmiBroker, chưa có fixture/expected riêng và chưa được nghiệm thu native.

## 1. Mốc đặc tả

- PR #17: đặc tả SOS / LPS v0.1 đã được chủ dự án phê duyệt.
- Merge commit khóa đặc tả trên `main`: `b21ec3af34481b68e07b8268c6658114a09777fe`.
- Tài liệu chuẩn đã khóa trên main: `docs/wyckoff-event-sos-lps-v0.1-spec-draft.md`.
- Tài liệu triển khai trên nhánh này: `docs/wyckoff-event-sos-lps-v0.1-spec.md`.
- AFL: `afl/WyckoffVSA_Event_SOSLPS_v0.1.afl`.

## 2. Nền xếp chồng

PR #14 được đồng bộ lại trên đầu nhánh Upthrust đã căn chỉnh theo PR #16 tại commit:

`63d44844107730cc27c409e35a1ba0cf532ab602`

Việc đồng bộ này loại bỏ bản SOS/LPS phát triển cũ đã bị đặc tả D01–D22 thay thế; không sửa Core, Candidate, Structure/Location, Confirmation, Supply Test, Spring/Shakeout hoặc Upthrust.

## 3. Các thay đổi bắt buộc so với PR #14 ban đầu

1. Thêm `WE_SL_SOSPriceBreakoutObservation` độc lập với SOS classification.
2. Thêm `PreviousClose <= Resistance` để xác định fresh breakout.
3. Giữ `RSpread>=1.20` và `RVOL>=1.25` làm gate vận hành của `SOS-LIKE` theo dải Core.
4. Bỏ `ClosePosition>=0.60` khỏi hard gate; chuyển thành `SOS_StrongCloseFlag`.
5. Bỏ `LPS_MaxBarsAfterSOS=10`.
6. Anchor SOS chỉ hết hiệu lực khi SOS mới thay thế hoặc completed Close phá xuống dưới frozen BreakoutLevel.
7. Bỏ upper-distance `Low <= BreakoutLevel + 0.50 ATR` khỏi hard gate LPS.
8. Giữ `Low >= BreakoutLevel` làm strict support-hold của LPS origin.
9. Bỏ `NoSupplyCandidateCode=2` khỏi hard gate LPS origin.
10. Bỏ Confirmation No Supply khỏi hard gate LPS resolution.
11. Thêm reaction-progress contract: `Close_k < Close_(k-1) OR Low_k < Low_(k-1)`.
12. k+1 xác nhận bằng `Low_t >= BreakoutLevel`, `Low_t >= Low_k`, `Close_t > Close_k`.
13. Cho phép candidate nối tiếp và nhiều LPS trên cùng SOS anchor.
14. Bổ sung frozen anchor/origin snapshot và quality descriptors: BarsSinceSOS, distance ATR, NearBreakoutEdge, contraction vs SOS, No Supply context, LowEffort context và S/M/L context.
15. Giữ `SOS-LIKE`/`LPS-LIKE` ở Event layer; không tự gán Phase D, BUEC hay Accumulation.

## 4. Hợp đồng SOS hiện tại

Price observation:

```text
PreviousClose <= Resistance
High > Resistance
Close > Resistance
Close > PreviousClose
```

SOS-LIKE:

```text
SOSPriceBreakoutObservation = 1
RSpreadValid = 1
RVOLValid = 1
RSpread >= 1.20
RVOL >= 1.25
```

ClosePosition/PriorATR là descriptor, không phải gate.

## 5. Hợp đồng LPS origin hiện tại

```text
Prior SOS anchor active
Current/prior price valid
Close_k < Close_(k-1) OR Low_k < Low_(k-1)
Low_k >= frozen BreakoutLevel
```

No Supply, spread/volume contraction, DistanceAboveBreakoutATR và NearBreakoutEdge chỉ là context/quality evidence.

## 6. Hợp đồng LPS resolution hiện tại

Chỉ tại `k+1`:

```text
Low_(k+1) >= frozen BreakoutLevel
Low_(k+1) >= Low_k
Close_(k+1) > Close_k
```

Không xác nhận muộn. Nếu k+1 tiếp tục giảm nhưng vẫn là reaction candidate hợp lệ, k+1 có thể tạo origin mới và k+2 chỉ resolve origin mới đó.

## 7. Bảo vệ nhân quả

- Resistance của SOS chỉ dùng `SL_PivotHighLatestPrior...`.
- BreakoutLevel của SOS được frozen cho mọi LPS tham chiếu nó.
- SOS/pivot mới tại evaluation không thay snapshot của LPS đang resolve.
- Không Zig/Peak/Trough nhìn trước.
- Không backfill event.
- Thanh cuối chưa được nguồn xác nhận hoàn tất chỉ provisional.
- Không Buy/Sell/Short/Cover/PositionSize.

## 8. Việc chưa thực hiện

Theo quyết định của chủ dự án, vẫn tạm hoãn:

- Verify Syntax trên AmiBroker 6.20.01;
- fixture/expected độc lập;
- kiểm thử ranh giới ngưỡng;
- kiểm thử anchor invalidation và nhiều LPS;
- đối chiếu native;
- hồi quy upstream;
- causality/append/source revision/forming-bar;
- nghiệm thu và release.

Vì vậy PR #14 phải tiếp tục ở trạng thái draft và không được gọi là PASS hay production-ready.