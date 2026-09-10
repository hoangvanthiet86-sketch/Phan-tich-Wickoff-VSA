# Wyckoff VSA Composite Indicator v0.1 — Kiểm toán phù hợp tĩnh

**Kết luận:** `STATIC SPEC CONFORMANCE = PASS`

**Giới hạn:** PASS này chỉ ở cấp source/interface review. Không phải AmiBroker native acceptance.

## Cơ sở

- Đặc tả D01–D32 đã được chủ dự án phê duyệt tại PR #26.
- Merge normative: `dc5089a2502f28ecf9777874561e393de6b62b68`.
- Phase/Context upstream head tại lúc dựng Composite: `3f8ba910ec1e30227732a5449cecfb67e170d5f4`.

## D01–D03 — Projection only / no score / no trading — PASS

Composite include Phase/Context ConsumerFacade và chỉ ánh xạ public variables. Không có weighted score, confidence/probability, Buy/Sell/Short/Cover/PositionSize, stop/target hay entry logic.

## D04–D06 — Context multiplicity và directional projection — PASS

- 0/1/2 context được giữ bằng `WCI_ContextMultiplicityCode`.
- Multiple contexts không được chọn winner.
- `WCI_CurrentRangeContextID` chỉ có giá trị khi đúng một context.
- DirectionalContext chỉ map từ FamilyHypothesis: unresolved / bullish / bearish / mixed.

## D07–D11 — Phase, structural development, evidence, alignment — PASS

- `WCI_PhaseStateCode` giữ semantic upstream.
- `WCI_StructuralDevelopmentCode` là alias trực tiếp của PhaseState.
- EvidenceBalance dùng categorical states.
- HypothesisAlignment là deterministic categorical relation giữa family direction và evidence balance.
- Không biến phase maturity thành confidence.

## D12–D14 — Event independence / mask / no recency window — PASS

11 current-event channels được export độc lập. EventMask là bitmask transport/audit và không dùng để ranking. Không có arbitrary 3/5/10/20-bar recency window.

## D15–D18 — Range / revision / supersession — PASS

Range identity, boundaries, width, age, position và status consume upstream. Composite không tính lại support/resistance. Hypothesis revision/KnownAt và lower/upper terminal diagnostics được giữ để downstream không hiểu nhầm lịch sử.

## D19–D20 — Completed/provisional/source revision semantics — PASS ở cấp contract

Composite không tự suy đoán session completion. `WCI_RuntimeLastBarIsProvisional` là runtime toggle minh bạch để gắn `WCI_ProvisionalFlag` lên last bar khi người vận hành biết bar đang forming. Official research/acceptance vẫn dùng completed bars. Không có logic gắn source revision thành algorithmic repaint.

## D21 — Exploration-first — PASS

Exploration public interface có:
- Symbol/DateTime/Provisional;
- multiplicity, range identity/status/boundaries/age;
- prior trend, phase, structural development, family, directional context, revision;
- evidence balance/alignment/mixed reason/counters;
- independent current event flags + EventMask;
- lower/upper channel diagnostics.

## D22–D25 — Minimal chart / raw candle / known-at / overlap — PASS

Chart overlay:
- giữ raw `styleCandle`, không recolor theo bias;
- vẽ frozen range boundaries upstream;
- đưa Phase/Family/Directional context vào Title;
- event markers đặt tại current/known-at bar, không backfill confirmation về origin;
- overlap dùng stacking offsets, không winner-takes-all;
- provisional warning chỉ là presentation.

## D26–D31 — Stable codes / scope / public interface / no duplication — PASS

- Categorical outputs có numeric code và text.
- Scope single-symbol/single-timeframe.
- Prefix public `WCI_`.
- Multiple context làm singleton ID Null và phase singleton insufficient; directional singleton mixed/conflicting.
- Không duplicate No Demand/No Supply, Event, Structural Sequence, Phase hoặc Family formulas.

## D32 — Quy trình triển khai — PASS

- Đặc tả được phê duyệt trước AFL.
- ConsumerFacade upstream đã được kiểm tra và dùng làm source/interface.
- Nhánh Composite được tạo trực tiếp trên Phase/Context head.
- Exploration-first được triển khai trước/đồng thời với public interface; chart overlay tách file riêng.
- PR phải giữ `UNTESTED DEVELOPMENT` cho tới chiến dịch AmiBroker native.

## Chưa được chứng minh

Static PASS không chứng minh:
- compile/Verify Syntax AmiBroker 6.20.01;
- giá trị Exploration native;
- marker chart đúng hình học trên dữ liệu thật;
- regression upstream;
- causal prefix/append stability;
- forming-bar runtime behavior;
- source revision behavior;
- performance.

`STATIC SPEC CONFORMANCE = PASS`