# Wyckoff VSA Timeframe Snapshot Publisher / Consumer v0.1 — Kiểm toán phù hợp tĩnh

**Kết luận:** `STATIC SPEC CONFORMANCE = PASS`

**Giới hạn:** PASS này chỉ ở cấp source/interface review. Không phải AmiBroker 6.20.01 native acceptance.

## Cơ sở chuẩn

- Multi-Timeframe Context PR #28: D01–D36 đã khóa, merge `794f947761fcb2c9043fd6d30fb9dd1a48f8c2bc`.
- Snapshot Contract PR #29: S01–S32 đã khóa, merge `a098a253cb139c6e2fc226a9aba8b051f3b5fa59`.

## Đối chiếu S01–S32

### S01–S04 — Scope / producer / native interval / forming higher bar: PASS

- chỉ W/M publisher và Daily consumer;
- publisher include Composite snapshot public facade, không copy Phase/Event logic;
- interval gate dùng numeric `inWeekly/inMonthly/inDaily`;
- source period là previous calendar period, không mặc định last bar completed.

### S05–S08 — Period identity và source selection: PASS

- weekly ordinal dùng Monday epoch + `DateTimeDiff/604800`;
- monthly ordinal dùng `Year*12+Month`;
- expected completed period = current period - 1;
- scan đúng expected period, không `BarCount-2` fallback;
- không manual completion override.

### S09–S13 — Namespace / schema / provenance / scalar persistence: PASS

- namespace có symbol + W/M;
- schema major/minor, producer versions và contract version được ghi;
- SourcePeriodOrdinal, SourceBarDateTime, PublishedAtDateTime, CompletionBasisCode, ClockBasisCode, Generation được giữ;
- transport dùng persistent scalar `StaticVarSet/StaticVarSetText`;
- không static array transport.

### S14–S16 — Transaction guard: PASS

- Publisher: `Ready=0` trước payload;
- payload + provenance;
- `CommittedGenerationID`;
- `Ready=1` cuối;
- Consumer double-read Generation/Ready trước và sau payload;
- Generation chỉ dùng transaction token, không dùng market recency.

### S17–S19 — Payload Composite và event provenance: PASS

- singleton Composite fields được serialize;
- lower/upper diagnostics được giữ riêng khi multiple contexts;
- lower/upper EvidenceBalance được public hóa qua Composite snapshot facade, không chọn winner;
- Weekly/Monthly EventMask tách biệt, Consumer không OR chúng vào Daily mask.

### S20–S24 — Fail-closed validity: PASS

Consumer giữ enum 0–10 và phân biệt:
- missing;
- unstable generation;
- schema/version mismatch;
- symbol mismatch;
- timeframe mismatch;
- stale period;
- future period;
- provisional source;
- invalid payload.

Không fallback timeframe khác khi một snapshot invalid.

### S25–S28 — DateTime / clock / revision / autosave: PASS

- market recency dùng period ordinal;
- weekly ordinal dùng `DateTimeDiff`, không so encoded DateTime bằng `>`/`<`;
- local system clock được export qua ClockBasisCode;
- generation có thể đổi khi republish cùng period;
- code không bật StaticVarAutoSave tần suất cao.

### S29 — Audit outputs: PASS

- Weekly/Monthly publisher entrypoints: interval, current/expected/source period, source DateTime, Ready, Generation, publisher status;
- Consumer exploration: requested symbol/timeframe, expected/source periods, schema, generation A/B, Ready A/B, validity status và decoded Composite state.

### S30 — Consumer không phải Aggregator: PASS

Consumer không có logic Daily/Weekly/Monthly alignment, higher-dominates, score hay signal.

### S31 — Implementation topology: PASS

Có:
- shared Publisher core;
- explicit WeeklyPublisher entrypoint;
- explicit MonthlyPublisher entrypoint;
- shared Consumer;
- Consumer Exploration audit.

### S32 — Không trading logic: PASS

Không có Buy/Sell/Short/Cover/PositionSize, confidence/probability, preferred timeframe hay ranking trong Snapshot layer.

## D35 look-ahead guard

Ở source layer Snapshot implementation không dùng:
- `TimeFrameExpand`;
- `TimeFrameGetPrice`;
- future shift;
- higher-timeframe current-bar expansion.

Publisher chỉ chạy trên native W/M và serialize bar của expected previous completed calendar period.

## Chưa được chứng minh

Static PASS không chứng minh:
- AFL compile/Verify Syntax;
- `Now`/calendar boundary behavior trên máy Windows thực tế;
- StaticVar persistence qua restart;
- race behavior dưới concurrent execution;
- year rollover ordinal correctness trên AmiBroker runtime;
- source revision semantics;
- namespace behavior với mọi symbol name;
- performance.

Các mục trên phải được kiểm thử native sau theo chiến lược dự án.

`STATIC SPEC CONFORMANCE = PASS`