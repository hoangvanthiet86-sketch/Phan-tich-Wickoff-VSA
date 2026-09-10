# Structural Sequence v0.1 — Hồ sơ rà soát triển khai

**Trạng thái:** `IMPLEMENTATION DRAFT / UNTESTED`.

## Nền

- Đặc tả D01–D32 đã khóa tại PR #20.
- Merge commit đặc tả: `e3a2c342c435aa2fd905fff4ae7ea14d060dafcf`.
- Nhánh triển khai được xếp chồng trên Stopping/Climactic/Absorption head `a310879da4ca04ddb97bff6eae727acb00e65aa0`.
- AFL: `afl/WyckoffVSA_StructuralSequence_PhaseA_v0.1.afl`.

## Rà soát logic theo đặc tả

Đã triển khai các điểm lõi sau:

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
- D30–D32: không phân loại Spring/Upthrust từ ST; không suy ra Accumulation/Distribution; không có trading assignment hay look-ahead Zig/Peak/Trough.

## D29 — frozen snapshot

Bản AFL hiện đã đóng băng các trường trực tiếp cần cho ST và sequence identity: climax High/Low, RVOL/RSpread + validity nội bộ, climax pivot coordinates, automatic-swing coordinates/price, provisional range và sequence ordinal. ST mang anchor climax/automatic-swing coordinates cùng frozen range, nên pivot mới không thay anchor lịch sử.

Tuy nhiên trước khi có thể gọi implementation **đầy đủ** theo D29, cần rà soát đầu ra snapshot mở rộng: ClosePosition, DirectionalProgress, toàn bộ quality flags, optional PS/PSY evidence và S/M/L context nếu chúng được công bố cho downstream Phase Engine. Đây là hạng mục output-completeness, không được tự coi PASS chỉ vì core state machine đã có.

Vì vậy trạng thái PR không được ghi `FULL SPEC PASS`; chỉ là `IMPLEMENTATION DRAFT / D29 OUTPUT AUDIT PENDING / UNTESTED` cho đến khi phần snapshot được hoàn thiện và kiểm thử sau này.

## Rủi ro kỹ thuật cần kiểm thử native

1. AFL dùng stateful loop và truy cập extreme offset bằng `confirmation bar - ConfirmationLag`; phải Verify Syntax và đối chiếu point-in-time trên AmiBroker 6.20.01.
2. Tìm PS/PSY hiện dùng nested scan qua confirmed pivots. Logic rõ ràng nhưng cần đo hiệu năng trên lịch sử dài.
3. Equality ở ST relation dùng strict exact comparison theo đặc tả; boundary fixtures cần kiểm tra sau.
4. Thanh cuối/forming-bar vẫn provisional; chưa có native evidence.
5. Chưa có fixture/expected, regression, causality, append hoặc source-revision audit.

## Kết luận hiện tại

Mã đã dựng xong state machine và các hợp đồng nhận diện chính của D01–D32, nhưng chưa được nghiệm thu và còn hạng mục D29 output-completeness cần hoàn thiện trước khi chuyển sang Phase/Context Engine. Không merge nhánh này vào chuỗi nghiệm thu.