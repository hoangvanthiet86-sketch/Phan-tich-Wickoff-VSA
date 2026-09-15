# Wyckoff VSA Composite Indicator v0.1 — Rà soát triển khai

**Trạng thái:** `SPEC-ALIGNED / UNTESTED DEVELOPMENT`.

## Mốc chuẩn

- Chủ dự án phê duyệt toàn bộ D01–D32 tại PR #26.
- PR #26 merge vào `main`: `dc5089a2502f28ecf9777874561e393de6b62b68`.
- Review artifact nguyên văn: `docs/wyckoff-vsa-composite-indicator-v0.1-spec-draft.md`.
- Phase/Context implementation upstream: PR #25, head tại lúc tạo nhánh Composite `3f8ba910ec1e30227732a5449cecfb67e170d5f4`.

## Nền xếp chồng

Nhánh `composite/composite-indicator-v0.1-development` được tạo trực tiếp từ Phase/Context PR #25 head `3f8ba910ec1e30227732a5449cecfb67e170d5f4` theo D32.

## Tệp triển khai

- `afl/WyckoffVSA_CompositeIndicator_v0.1.afl` — public projection/aggregation facade + Exploration core.
- `afl/WyckoffVSA_CompositeIndicator_Exploration_v0.1.afl` — Exploration entrypoint bổ sung Symbol và human-readable lower/upper status.
- `afl/WyckoffVSA_CompositeIndicator_Chart_v0.1.afl` — minimal chart overlay, giữ raw candles và marker stacking.

## Nguyên tắc được giữ

1. Composite chỉ consume `WyckoffVSA_PhaseContext_ConsumerFacade_v0.1.afl` và public upstream variables đã nạp qua facade; không sao chép công thức Event/Sequence/Phase.
2. Không weighted score, confidence %, probability %, Buy/Sell/Short/Cover/PositionSize.
3. Khi hai RangeContext cùng tồn tại, singleton ID/phase không chọn winner; directional singleton chuyển `MIXED / CONFLICTING`, còn lower/upper channels vẫn export riêng.
4. Directional context chỉ ánh xạ deterministic từ FamilyHypothesis upstream.
5. `StructuralDevelopmentCode` là alias trực tiếp của PhaseState, không có state machine mới.
6. EvidenceBalance và HypothesisAlignment là categorical mapping, không cộng trọng số event.
7. Current event flags độc lập và EventMask chỉ transport/audit.
8. Không có hidden 3/5/10/20-bar recency window.
9. Range boundaries lấy trực tiếp từ frozen Phase/Context range.
10. Chart không recolor raw candles theo family/directional bias.
11. Marker của confirmed event được đặt ở bar hiện tại nơi upstream công bố/known-at; không backfill confirmed marker về origin.
12. Marker overlap dùng stacking offset; thứ tự layout không mang nghĩa ưu tiên phương pháp.
13. Scope single-symbol/single-timeframe.

## Bar completion / ProvisionalFlag

AmiBroker không có một primitive chung đủ tin cậy để tự biết thanh cuối của mọi database/session còn đang hình thành hay đã đóng. Vì vậy implementation **không giả vờ auto-detect**.

`WCI_RuntimeLastBarIsProvisional` là `ParamToggle` rõ ràng, mặc định `No`. Khi runtime/user biết thanh cuối còn đang hình thành, bật tham số này để `WCI_ProvisionalFlag=1` trên last bar in range. Đây là runtime presentation contract; official acceptance vẫn phải dùng completed bars như methodology đã khóa.

## Exploration-first

Core Composite AFL xuất:

- ContextMultiplicity, ambiguity, singleton RangeContext;
- PrimaryRange, age, position;
- PriorTrend, PhaseState, StructuralDevelopment, FamilyHypothesis, DirectionalContext;
- Hypothesis revision/KnownAt;
- EvidenceBalance, HypothesisAlignment, mixed reason;
- SOS/LPS/SOW/LPSY, NoSupply/NoDemand và absorption response counts;
- 11 independent current-event flags + EventMask;
- lower/upper RangeContext diagnostics riêng.

Exploration wrapper thêm Symbol và status text để đáp ứng giao diện kiểm toán D21.

## Chart v0.1

Chart overlay chỉ:

- giữ raw candle;
- vẽ active lower/upper frozen range boundaries;
- hiển thị Phase/Family/Directional context trong Title;
- vẽ marker event tại current/known-at bar với stacking offsets;
- hiển thị cảnh báo provisional trong Title khi runtime flag được bật.

Không vẽ toàn bộ diagnostic fields lên chart.

## Giới hạn chưa nghiệm thu

Chưa thực hiện:

- Verify Syntax trên AmiBroker 6.20.01;
- fixture/expected độc lập;
- native Exploration value comparison;
- chart visual review trên dữ liệu thật;
- regression upstream;
- causal-prefix/append stability;
- forming-bar runtime test;
- source-revision test;
- performance audit.

Do đó đây không phải native PASS và PR triển khai phải tiếp tục là draft.