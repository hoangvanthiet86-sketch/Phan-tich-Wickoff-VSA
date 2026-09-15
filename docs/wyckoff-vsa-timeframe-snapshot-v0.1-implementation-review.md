# Wyckoff VSA Timeframe Snapshot Publisher / Consumer v0.1 — Rà soát triển khai

**Trạng thái:** `SPEC-ALIGNED / UNTESTED DEVELOPMENT`.

## Mốc chuẩn

- Multi-Timeframe Context D01–D36 đã khóa tại PR #28, merge `794f947761fcb2c9043fd6d30fb9dd1a48f8c2bc`.
- Snapshot Contract S01–S32 đã được chủ dự án phê duyệt tại PR #29, merge `a098a253cb139c6e2fc226a9aba8b051f3b5fa59`.
- D34 yêu cầu Publisher/Consumer contract trước MTF Aggregator.
- D35 cấm future-sensitive higher-timeframe expansion.

## Nền xếp chồng

Nhánh `mtf/timeframe-snapshot-v0.1-development` được tạo từ Composite implementation PR #27 sau khi bổ sung public snapshot facade. Composite/Phase và các Event upstream vẫn là development stack chưa nghiệm thu native.

## Tệp triển khai

- `afl/WyckoffVSA_TimeframeSnapshot_Publisher_v0.1.afl`
- `afl/WyckoffVSA_TimeframeSnapshot_WeeklyPublisher_v0.1.afl`
- `afl/WyckoffVSA_TimeframeSnapshot_MonthlyPublisher_v0.1.afl`
- `afl/WyckoffVSA_TimeframeSnapshot_Consumer_v0.1.afl`
- `afl/WyckoffVSA_TimeframeSnapshot_ConsumerExploration_v0.1.afl`

Prerequisite public facade bổ sung trên Composite stack:

- `afl/WyckoffVSA_CompositeIndicator_SnapshotPublic_v0.1.afl`

Facade này chỉ xuất lower/upper EvidenceBalance và schema metadata đã được Composite spec cho phép; không thêm interpretation mới.

## Thiết kế thực thi

### Publisher

- chạy native Weekly hoặc Monthly, kiểm tra bằng `Interval()==inWeekly/inMonthly`;
- xác định kỳ hiện tại từ local Windows clock qua `Now(5)`/`Now(7)`/`Now(8)`;
- weekly ordinal dùng Monday epoch + `DateTimeDiff/604800`, không dùng `YYYYWW`;
- monthly ordinal dùng `Year*12+Month`;
- chỉ tìm bar có ordinal đúng `current ordinal - 1`;
- không giả định `BarCount-2`;
- không dùng `TimeFrameExpand`, `TimeFrameGetPrice` hoặc static arrays;
- serialize scalar numeric/text fields từ Composite public interface;
- namespace `WVSA_MTF_v01_<Symbol>_<W|M>_<Field>`;
- persistent StaticVar;
- commit protocol `Ready=0 → payload/provenance → CommittedGenerationID → Ready=1`;
- Weekly/Monthly entrypoints riêng theo S31.

### Consumer

- intended native Daily consumer;
- đọc Weekly và Monthly tách biệt;
- double-read `Ready/Generation` quanh payload;
- fail closed theo enum S20;
- schema/version/symbol/timeframe/period/provisional/payload validation;
- stale/future dùng period identity, không age-days;
- không fallback Weekly↔Monthly↔Daily;
- giữ EventMask riêng theo timeframe;
- không tạo MTF alignment.

## Audit interface

Publisher entrypoints công bố native interval, current/expected period, source period/DateTime, Ready và Generation. Consumer Exploration công bố requested symbol/timeframe, source/expected periods, schema, generation A/B, Ready A/B, status và decoded Composite fields.

## Giới hạn hiện tại

Chưa thực hiện:

- Verify Syntax trên AmiBroker 6.20.01;
- week/month/year rollover native tests;
- missing expected-period fixture;
- persistent restart test;
- generation race simulation;
- schema/version mismatch mutation test;
- stale/future snapshot tests;
- symbol/timeframe collision tests;
- source revision test;
- performance audit.

Do đó `STATIC SPEC CONFORMANCE` không đồng nghĩa native acceptance và MTF Aggregator chỉ được xây sau khi source/interface của contract này ổn định theo strategy build-first hiện tại.