# Wyckoff VSA Phase / Context Engine v0.1 — Rà soát triển khai

**Trạng thái:** `SPEC-ALIGNED / UNTESTED DEVELOPMENT`.

## Mốc chuẩn

- Đặc tả D01–D44 đã được chủ dự án phê duyệt và khóa tại PR #22.
- PR #22 merge vào `main`: `3fe48b06a635cf105472b27d296fabeee5589488`.
- D38 được khóa là cổng kiến trúc bắt buộc.
- SOW/LPSY D01–D31 đã được phê duyệt tại PR #23 và merge vào `main`: `7670532a230eb051cf5d362be092e2d81283fb92`.
- SOW/LPSY implementation contract nằm trên PR #24 và được Phase/Context consume như upstream riêng, không tái tạo công thức trong Phase Engine.

## Nền xếp chồng

Nhánh `phase/phase-context-v0.1-development` đi trực tiếp từ head PR #24 `52fbb09c942f39e3c43e1469594fcd09ec288189`.

Điểm cần ghi rõ: commit `749211d310aa62f3f56e9ff491a4e516c6e4c700` mang phiên bản Spring/Shakeout D01–D14 đã được phê duyệt và căn chỉnh ở PR #12 vào stack Phase/Context. Đây là đồng bộ prerequisite theo D44, không phải thay đổi phương pháp mới của Phase Engine. Không có claim native acceptance cho thay đổi này.

## Các tệp Phase/Context chính

- `afl/WyckoffVSA_PhaseContext_InputFacade_v0.1.afl`
- `afl/WyckoffVSA_PhaseContext_v0.1.afl`
- `afl/WyckoffVSA_PhaseContext_PublicSnapshot_v0.1.afl`
- `afl/WyckoffVSA_PhaseContext_ConsumerFacade_v0.1.afl`

## Kiến trúc thực thi

`InputFacade` nạp các upstream công khai: Supply Test, Spring/Shakeout, Upthrust, SOS/LPS, SOW/LPSY và Structural Sequence snapshot thông qua chuỗi include hiện hành. Phase Engine chỉ chuẩn hóa và liên kết event với frozen range; không copy công thức Candidate/Event/SOW/LPSY.

`PhaseContext_v0.1` duy trì hai RangeContext độc lập cho lower-derived và upper-derived range. Mỗi context có range key, prior-trend context, PhaseState, family hypothesis, evidence states, event counters, Phase-C origin/KnownAt, Phase-D/E KnownAt và breakout/breakdown lifecycle.

`PublicSnapshot` hoàn thiện contract kiểm toán D32/D34/D35/D36/D42, bao gồm trạng thái range, supersession/invalidation, tọa độ thời gian, event counters và source-key constituents.

`ConsumerFacade` là facade downstream cho Composite; khi hai range cùng tồn tại, facade không chọn winner tùy ý mà đánh dấu ambiguity/mixed context.

## Các quyết định D01–D44 được giữ

- Không dùng MA/RSI/ADX làm prior-trend oracle; prior trend dựa confirmed swing structure.
- Phase A/B không tự kết luận Accumulation/Distribution.
- Primary range lấy frozen Structural Sequence range và không tự trôi.
- Phase B không timeout.
- VSA No Demand/No Supply chỉ nâng ý nghĩa khi background phù hợp.
- Phase C hỗ trợ đường Spring và no-Spring test phía bullish; Upthrust và LPSY/weak-final-test phía bearish.
- Spring/UTAD chỉ được nâng theo range + follow-through; Event layer không bị đổi vai trò.
- Phase D bullish dùng SOS/LPS; bearish dùng SOW/LPSY.
- Phase E yêu cầu breakout/breakdown cùng hành vi giữ/failed retest và structural continuation, không chỉ một thanh vượt biên.
- Hypothesis được revision theo thời gian nhưng không backfill lịch sử.
- Evidence dùng categorical states/diagnostics, không weighted probability score.
- Absorption chỉ có directional meaning sau response.
- Multiple/overlapping event được giữ, không overwrite.
- Không P&F target, không Buy/Sell/Short/Cover/PositionSize.

## D38

D38 được thỏa ở **cấp phát triển source/interface** vì:

1. SOW/LPSY có đặc tả riêng đã khóa;
2. SOW/LPSY có implementation module/interface riêng ở PR #24;
3. Phase InputFacade consume output SOW/LPSY;
4. Phase Engine không viết lại SOW/LPSY bên trong chính nó.

Điều này không đồng nghĩa SOW/LPSY hay Phase/Context đã nghiệm thu AmiBroker.

## Giới hạn kiểm thử hiện tại

Chưa thực hiện:

- Verify Syntax trên AmiBroker 6.20.01;
- fixture/expected độc lập;
- runtime state-machine comparison;
- regression upstream;
- causal-prefix/append stability;
- source-revision behavior;
- forming-bar audit;
- performance audit trên lịch sử dài.

Do đó PR triển khai phải tiếp tục là draft và không được gọi `PASS` native.