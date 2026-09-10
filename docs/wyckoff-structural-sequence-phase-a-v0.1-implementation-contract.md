# Wyckoff Structural Sequence v0.1 — Hợp đồng triển khai

**Trạng thái:** `SPEC-ALIGNED / UNTESTED DEVELOPMENT`.

## Mốc chuẩn

- Đặc tả D01–D32 đã được chủ dự án phê duyệt và khóa tại PR #20.
- Merge commit của PR #20: `e3a2c342c435aa2fd905fff4ae7ea14d060dafcf`.
- Source-of-truth: `docs/wyckoff-structural-sequence-phase-a-v0.1-spec-draft.md` trên `main`. Tên tệp còn hậu tố `draft` là di sản tên vật lý; nội dung đã được khóa bằng quyết định phê duyệt và merge PR #20.
- Upstream Event trực tiếp: `WyckoffVSA_Event_StoppingClimacticAbsorption_v0.1.afl`.
- State-machine AFL: `WyckoffVSA_StructuralSequence_PhaseA_v0.1.afl`.
- **Public downstream facade:** `WyckoffVSA_StructuralSequence_PhaseA_Snapshot_v0.1.afl`. Phase/Context Engine tương lai phải include facade này để nhận cả state machine và hợp đồng frozen snapshot D29.

## Phạm vi triển khai

Mô-đun ghép hai chuỗi nhân quả độc lập:

`PS-LIKE → SC-LIKE → AUTOMATIC-RALLY-LIKE → LOWER-ST-LIKE`

`PSY-LIKE → BC-LIKE → AUTOMATIC-REACTION-LIKE → UPPER-ST-LIKE`

Không gán Accumulation, Distribution, Reaccumulation, Redistribution hay Phase A canonical.

## Quy tắc triển khai bắt buộc

1. Confirmed Pivot Low/High của Structure/Location là xương sống cấu trúc.
2. Lower/Upper Climax Seed chỉ được tạo khi pivot đã confirmed và evidence Climactic Effort + pressure tồn tại tại extreme bar.
3. Seed chưa phải SC/BC. SC/BC chỉ KnownAt khi Automatic Rally/Reaction tương ứng được confirmed.
4. Automatic Rally/Reaction là confirmed counter-swing pivot đầu tiên sau seed; không timeout và không minimum ATR gate.
5. Terminal-extreme contract được kiểm tra trên dữ liệu từ seed extreme đến automatic-swing extreme.
6. PS/PSY là optional, được tìm tại thời điểm pair SC/AR hoặc BC/AR được biết; không backfill nhãn vào quá khứ.
7. Pair tạo provisional range bất biến: `SC Low ↔ AR High` hoặc `Automatic Reaction Low ↔ BC High`.
8. ST dùng confirmed same-side pivot sau automatic swing. ST identity chỉ yêu cầu quay lại full climax-bar area; relation với SC Low/BC High là descriptor.
9. ST quality so RVOL/RSpread tại ST extreme với climax extreme, tách khỏi ST identity.
10. Cho phép nhiều ST trên cùng anchor; mỗi ST có ordinal riêng.
11. Pair cùng phía mới chỉ supersede anchor cho future ST sau khi pair mới đã confirmed.
12. Lower và Upper state machine độc lập.
13. Không backfill, không Zig/Peak/Trough look-ahead, không Buy/Sell/Short/Cover/PositionSize.

## D29 — frozen snapshot public interface

Facade D29 đóng băng tại thời điểm pair được xác nhận và công bố tối thiểu các nhóm dữ liệu sau:

- climax OHLC;
- RVOL/RSpread/ClosePosition/DirectionalProgress cùng validity;
- Climactic direction, Stopping Volume, Absorption, pressure và expansion/ultra-effort evidence;
- climax pivot origin/confirm coordinates;
- Automatic Rally/Reaction OHLC, extreme/confirm coordinates và provisional range;
- optional PS/PSY coordinates cùng evidence dùng để nhận diện;
- S/M/L reference/location context tại climax và automatic swing;
- active frozen sequence snapshot trên từng thanh sau pair confirmation;
- ST-event anchor snapshot để chứng minh ST luôn tham chiếu sequence đã được đóng băng, kể cả khi pair mới cùng phía xuất hiện sau đó.

Facade không tính lại RVOL/RSpread/ATR/pivot và không thay đổi identity logic của state machine. Nó chỉ materialize các output đã có hoặc snapshot các measurement/context upstream tại đúng extreme offsets đã biết ở thời điểm hiện tại.

## Lưu ý về point-in-time

State-machine AFL dùng `SL_Pivot*EventCode` tại confirmation bar và `SL_Pivot*ConfirmationLag` để truy cập đúng extreme offset đã được Structure Engine xác nhận. `OriginExtreme*` và `KnownAt*` được xuất riêng để người dùng không nhầm thời điểm hiện tượng xảy ra với thời điểm hệ thống được phép công bố nhãn.

Facade D29 duy trì lower/upper snapshot bằng hai state machine độc lập. Thứ tự xử lý snapshot được giữ tương thích với state machine gốc để ST cùng thanh với một pair mới không bị gắn nhầm anchor lịch sử.

## Kiểm thử

Theo quyết định hiện tại của chủ dự án, Verify Syntax AmiBroker 6.20.01, fixture/expected, regression, causal/append và forming-bar được hoãn đến chiến dịch kiểm thử tổng thể. Vì vậy `SPEC-ALIGNED` ở đây chỉ có nghĩa là **đã đối chiếu tĩnh với đặc tả D01–D32**, không phải nghiệm thu runtime/native.
