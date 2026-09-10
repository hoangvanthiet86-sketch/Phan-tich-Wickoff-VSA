# Structural Sequence v0.1 — Hồ sơ rà soát triển khai

**Trạng thái:** `SPEC-ALIGNED / UNTESTED DEVELOPMENT`.

## Nền

- Đặc tả D01–D32 đã khóa tại PR #20.
- Merge commit đặc tả: `e3a2c342c435aa2fd905fff4ae7ea14d060dafcf`.
- Nhánh triển khai được xếp chồng trên Stopping/Climactic/Absorption head `a310879da4ca04ddb97bff6eae727acb00e65aa0`.
- State-machine AFL: `afl/WyckoffVSA_StructuralSequence_PhaseA_v0.1.afl`.
- D29 public facade: `afl/WyckoffVSA_StructuralSequence_PhaseA_Snapshot_v0.1.afl`.
- Kiểm toán tĩnh: `docs/wyckoff-structural-sequence-phase-a-v0.1-static-conformance-audit.md`.

## Rà soát logic theo đặc tả

Đối chiếu tĩnh hiện đạt D01–D32:

- D01–D02: chỉ phát nhãn `-LIKE`; dùng confirmed pivot làm xương sống.
- D03–D04: Lower/Upper Climax Seed lấy Climactic Effort + pressure tại extreme bar của pivot đã confirmed.
- D05–D08: terminal-extreme contract; Automatic Rally/Reaction là first confirmed counter-pivot; SC/BC chỉ KnownAt tại lúc counter-pivot được confirmed, không backfill.
- D09: tạo provisional range từ climax extreme và automatic counter-swing.
- D10–D12: PS/PSY optional; tìm candidate gần climax nhất với pause/bounce trung gian; không dùng PS/PSY làm gate.
- D13–D16: ST dùng same-side confirmed pivot sau automatic swing; quay lại full climax-bar area; relation với SC Low/BC High không phải hard gate; identity tách quality.
- D17–D18: quality so RVOL/RSpread ST với SC/BC.
- D19–D20: nhiều ST; morphology complete sau ST đầu tiên.
- D21–D22: không tạo trend oracle; non-climactic termination không bị ép thành climax sequence.
- D23–D25: seed supersession và sequence-anchor supersession theo state machine; lower/upper độc lập.
- D26–D28: validity theo bước; origin-time tách known-at-time; sequence ordinal + pivot coordinates giữ định danh nhân quả.
- D29: frozen snapshot đã được hoàn thiện bằng public facade riêng.
- D30–D32: không phân loại Spring/Upthrust từ ST; không suy ra Accumulation/Distribution; không có trading assignment hay look-ahead Zig/Peak/Trough.

## D29 — frozen snapshot đã hoàn thiện

Hạng mục output-completeness trước đây còn mở đã được đóng bằng `WyckoffVSA_StructuralSequence_PhaseA_Snapshot_v0.1.afl`.

Facade hiện materialize và đóng băng:

- climax OHLC;
- RVOL/RSpread/ClosePosition/DirectionalProgress cùng validity;
- Climactic direction, Stopping Volume, Absorption, pressure, Elevated Expansion và Ultra Effort evidence;
- climax pivot coordinates;
- Automatic Rally/Reaction OHLC, pivot coordinates và S/M/L context;
- provisional range;
- optional PS/PSY coordinates/evidence;
- active lower/upper frozen snapshot carry-forward;
- ST-event anchor snapshot.

Snapshot state machine giữ thứ tự tương thích với engine gốc (`lower ST → upper pair → upper ST → lower pair`) để một ST và pair mới xác nhận cùng confirmation bar không bị gắn nhầm anchor.

Do đó **D29 output audit = CLOSED / STATIC PASS**.

## Kết quả kiểm toán tĩnh

Tệp `wyckoff-structural-sequence-phase-a-v0.1-static-conformance-audit.md` ghi nhận:

`STATIC SPEC CONFORMANCE = PASS`

cho toàn bộ D01–D32 trong phạm vi đọc mã nguồn. Đây không phải runtime/native PASS.

## Rủi ro kỹ thuật còn phải kiểm thử native

1. AFL dùng stateful loop và truy cập extreme offset bằng `confirmation bar - ConfirmationLag`; phải Verify Syntax và đối chiếu point-in-time trên AmiBroker 6.20.01.
2. Tìm PS/PSY dùng nested scan qua confirmed pivots; cần đo hiệu năng trên lịch sử dài.
3. Facade D29 dùng mapping `BarIndex → array offset` bằng causal scan và state carry-forward; cần fixture xác nhận đúng ở QuickAFL/phạm vi lịch sử dài.
4. Equality ở ST relation dùng strict exact comparison theo đặc tả; boundary fixtures cần kiểm tra.
5. Thanh cuối/forming-bar vẫn provisional; chưa có native evidence.
6. Chưa có fixture/expected, regression, causality, append hoặc source-revision audit.

## Kết luận hiện tại

Structural Sequence v0.1 hiện **đã phù hợp đặc tả D01–D32 ở cấp kiểm toán tĩnh**, bao gồm D29. Vì chiến dịch kiểm thử đang được chủ dự án hoãn, trạng thái chính xác là:

`SPEC-ALIGNED / UNTESTED DEVELOPMENT`

PR vẫn phải giữ draft và không được hiểu là đã nghiệm thu hoặc sẵn sàng merge vào chuỗi production.
