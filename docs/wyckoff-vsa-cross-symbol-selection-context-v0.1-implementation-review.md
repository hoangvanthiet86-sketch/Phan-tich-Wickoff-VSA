# Wyckoff VSA Cross-Symbol Selection Context Snapshot v0.1 — Rà soát triển khai

**Trạng thái:** `SPEC-ALIGNED / UNTESTED DEVELOPMENT`.

## Mốc chuẩn

- Market Scanner MS01–MS40 đã khóa tại PR #36, merge `b70cae9c8714cbb2b17082d155e57b50110aa13f`.
- Cross-Symbol Snapshot XS01–XS38 đã khóa tại PR #37, merge `d006959f11f5ec544f5f000c53448cec2643dc99`.
- Implementation branch xếp chồng trên Multi-Timeframe Aggregator PR #31 head `b6f190d3edafbaeb2cd54ad75bb16e49a1c54732` để có canonical Composite + MTF implementation source.

## Tệp triển khai

- `afl/WyckoffVSA_MultiTimeframeContext_SelectionSnapshotPublic_v0.1.afl`
- `afl/WyckoffVSA_CrossSymbolSelectionContext_Publisher_v0.1.afl`
- `afl/WyckoffVSA_CrossSymbolSelectionContext_PublisherExploration_v0.1.afl`
- `afl/WyckoffVSA_CrossSymbolSelectionContext_Consumer_v0.1.afl`
- `afl/WyckoffVSA_CrossSymbolSelectionContext_ConsumerVersionGuard_v0.1.afl`
- `afl/WyckoffVSA_CrossSymbolSelectionContext_ConsumerExploration_v0.1.afl`

## Kiến trúc

Publisher chạy độc lập trên chính Market/Group source symbol ở native Daily. Nó chỉ serialize public Composite + MTF current state sang namespace `WVSA_SELCTX_v01_<SourceSymbol>_...`.

Scanner-side consumer không publish. Shared consumer được gọi với hai role configuration độc lập:

- `WXSM_` cho requested Market symbol;
- `WXSG_` cho optional Group symbol.

Group không cấu hình trả `NOT_REQUESTED`; Market và Group dùng cùng schema transport. Full Top-Down config conflict khi hai requested symbols trùng nhau được export riêng để Scanner xử lý.

## Daily completion

Same-day publication mặc định bị chặn. Publisher chỉ cho phép publication khi:

1. source business date nhỏ hơn local calendar date (`CALENDAR DAY ROLLED OVER`), hoặc
2. source date bằng local calendar date và dedicated operator EOD declaration được bật (`OPERATOR EOD COMPLETION DECLARATION`).

Declaration chỉ là provenance, không đổi Phase/VSA/MTF evidence.

## Concurrency

Mỗi source namespace dùng non-persistent writer semaphore qua `StaticVarCompareExchange`. Sau khi lấy lock:

`Ready=0 → payload → schema/provenance → CommittedGenerationID → Ready=1 → release lock`.

Readers không giữ lock. Consumer đọc Ready/Generation trước và sau payload; generation thay đổi hoặc Ready không ổn định thì reject lượt đọc.

## Payload

Giữ nguyên:

- Composite singleton context;
- lower/upper RangeContext độc lập;
- MTF D/W/M Directional/Phase/Family/Evidence;
- MTF alignment/conflict diagnostics;
- Weekly/Monthly period/generation/schema provenance;
- source symbol/date/completion/schema/version provenance.

Transport không tạo MarketSelectionContext, GroupSelectionContext, candidate, score hoặc rank.

## Version compatibility

`ConsumerVersionGuard` kiểm tra explicit:

- snapshot schema 1.0;
- producer contract 0.1;
- Composite producer 0.1 + Composite public schema 1.0;
- MTF producer 0.1 + MTF public schema 1.0.

Không silent-accept producer version khác.

## Giới hạn

Chưa thực hiện:

- AmiBroker 6.20.01 Verify Syntax;
- CSN01–CSN20 native matrix;
- concurrent writer contention thật;
- interrupted-write fixture;
- restart/persistence test;
- same-day EOD operation test;
- stale/future business-date fixtures;
- performance comparison với repeated SetForeign/full-engine reference.

Vì vậy không gọi MS40 là native PASS.