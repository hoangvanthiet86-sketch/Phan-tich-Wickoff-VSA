# Wyckoff VSA Multi-Timeframe Context Engine v0.1 — Rà soát triển khai

**Trạng thái:** `SPEC-ALIGNED / UNTESTED DEVELOPMENT`.

## Mốc chuẩn

- Đặc tả Multi-Timeframe Context D01–D36 đã được chủ dự án phê duyệt tại PR #28.
- PR #28 merge `main`: `794f947761fcb2c9043fd6d30fb9dd1a48f8c2bc`.
- Timeframe Snapshot Contract S01–S32 đã được phê duyệt tại PR #29.
- PR #29 merge `main`: `a098a253cb139c6e2fc226a9aba8b051f3b5fa59`.
- MTF Aggregator branch được xếp chồng trên Snapshot implementation PR #30 tại head `cd87755ca45b4e52f8922175ac64238170dc0b44`.

## Tệp triển khai

- `afl/WyckoffVSA_MultiTimeframeContext_v0.1.afl`
- `afl/WyckoffVSA_MultiTimeframeContext_Exploration_v0.1.afl`
- `afl/WyckoffVSA_MultiTimeframeContext_Panel_v0.1.afl`

## Kiến trúc

`Daily canonical Composite current state + validated Weekly snapshot + validated Monthly snapshot → MTF categorical relationships → Exploration / context panel`

Aggregator không chạy lại Weekly/Monthly engine, không dùng `TimeFrameExpand`/`TimeFrameGetPrice`, không tái tính Event/Phase/Family và không tạo MasterRange.

## Các quan hệ đã triển khai

### DirectionalAlignment

- 0 `INSUFFICIENT MTF DATA`
- 1 `UNRESOLVED / NON-DIRECTIONAL`
- 2 `BULLISH ALIGNMENT`
- 3 `BEARISH ALIGNMENT`
- 4 `BASE COUNTER TO HIGHER CONTEXT`
- 5 `HIGHER TIMEFRAMES CONFLICT`
- 6 `MIXED / COMPLEX MTF CONTEXT`

Full bullish/bearish alignment chỉ được công bố khi cả D/W/M đều valid và cùng directional side. Weekly/Monthly trái dấu được ưu tiên ghi nhận là higher-timeframe conflict; multiple/mixed context không bị ép chọn winner.

### EvidenceAlignment

Evidence được so sánh độc lập với Family/Directional state:

- aligned bullish;
- aligned bearish;
- Daily evidence counter to both higher frames;
- higher evidence conflict;
- mixed/complex;
- insufficient.

Không cho evidence relationship tự sửa FamilyHypothesis.

### PhaseRelationship

Phase relationship chỉ là diagnostic:

- same phase;
- Daily structurally earlier;
- Daily structurally later;
- divergent;
- ambiguous do multiple contexts.

Phase 7 (`RANGE INVALIDATED / SUPERSEDED`) không được dùng như một nấc tiến triển cao hơn Phase E; nếu terminal state không đồng nhất, quan hệ được ghi `DIVERGENT`.

## Current-state only

D33 được giữ bằng cách chỉ sample latest Daily Composite state và snapshot hiện hành của Weekly/Monthly. Dedicated Exploration lọc đúng current/latest row. Việc các public arrays mang cùng current scalar qua các bar chỉ nhằm interoperability của AFL, **không phải historical MTF backfill**.

## Snapshot health

Weekly/Monthly authoritative fields chỉ được expose khi `WTSC_*_Valid==1`. Nếu snapshot missing/stale/future/version mismatch/provisional/invalid, public MTF field tương ứng fail closed và full MTF alignment không được công bố.

## Range và Event provenance

- D/W/M RangeContextID không so sánh chéo timeframe.
- D/W/M boundaries giữ riêng; không có MasterRange.
- D/W/M EventMask giữ riêng; không OR vào một event stream chung.
- Event source timestamp của Weekly/Monthly dùng source bar DateTime của snapshot khi mask khác 0.
- Multiple-context lower/upper range identity/boundary được giữ riêng để audit; không sinh singleton winner.

## ConflictReasonCode

Implementation dùng một **bit mask chẩn đoán**, không phải score. Các bit có thể đồng thời tồn tại để không mất thông tin về source invalidity, unresolved state, ambiguity, higher conflict, base-counter, evidence conflict hoặc phase divergence.

## Context panel

Panel v0.1 chỉ trình bày D/W/M directional context, snapshot health, MTF alignment và relationship codes. Không mặc định vẽ Weekly/Monthly event marker lên Daily chart.

## Chưa được kiểm thử native

Chưa thực hiện:

- Verify Syntax trên AmiBroker 6.20.01;
- controlled D/W/M categorical fixtures;
- partial-week / partial-month / rollover cases;
- stale/missing/version/future snapshot integration;
- generation-race integration;
- no-look-ahead causal audit;
- historical-backfill guard test;
- visual panel review;
- upstream regression;
- performance audit.

Vì vậy trạng thái vẫn là `SPEC-ALIGNED / UNTESTED DEVELOPMENT`, không phải native PASS.