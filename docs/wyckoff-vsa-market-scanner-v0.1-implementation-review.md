# Wyckoff VSA Market Scanner v0.1 — Rà soát triển khai

**Trạng thái:** `SPEC-ALIGNED / UNTESTED DEVELOPMENT`.

## Mốc chuẩn

- Market Scanner MS01–MS40 đã khóa tại PR #36, merge `b70cae9c8714cbb2b17082d155e57b50110aa13f`.
- Cross-Symbol Selection Context XS01–XS38 đã khóa tại PR #37, merge `d006959f11f5ec544f5f000c53448cec2643dc99`.
- Base của nhánh Scanner là Cross-Symbol implementation PR #38 head `3f59590bedb6e476a1bf97856eceb96b537b67a4`.

## Integration sources

Để full Scanner có đồng thời MTF + Cross-Symbol + Relative Strength mà không sửa các PR development gốc, nhánh Scanner mang nguyên source blob hiện hành của:

- `WyckoffVSA_DerivedSeriesPivotKernel_v0.1.afl` — blob `c52c1dbf61984533734f18606277f363d041c695`, từ PR #34;
- `WyckoffVSA_RelativeStrengthContext_v0.1.afl` — blob `06d1493900048394932608feb3a8125d71a17816`, từ PR #35.

Đây là tích hợp source snapshot để xây downstream Scanner; không thay đổi semantics K01–K32 hoặc R01–R36 và không biến PR #34/#35 thành native PASS.

## Tệp Scanner

- `afl/WyckoffVSA_MarketScanner_v0.1.afl`
- `afl/WyckoffVSA_MarketScanner_Exploration_v0.1.afl`

## Luồng dữ liệu

`Stock Composite + Stock MTF + Stock Relative Strength + Cross-Symbol Market/Group snapshots → Market/Group Selection Context → DataEligibility / Method diagnostics / Review → CandidateClass → Exploration Filter`

Scanner không chạy lại full Market/Group Phase/Composite/MTF qua `SetForeign`; market/group own context đến từ Cross-Symbol snapshot. `Foreign(...,"C",0)` chỉ còn ở Relative Strength module để tính comparative ratio theo R01–R36.

## Mapping vận hành đã triển khai

### DataEligibility

Data gate bao gồm:
- Daily provisional;
- upstream schema không tương thích;
- Market RS benchmark invalid;
- adjustment basis chưa verified-compatible;
- Stock MTF invalid;
- Market Cross-Symbol snapshot invalid;
- Group invalid khi deployment yêu cầu Full Top-Down;
- required current fields không hữu hạn;
- không chạy native Daily;
- Market benchmark config giữa Selection Snapshot và RS không khớp;
- Market/Group role config conflict.

Group không requested không làm Market-Aligned profile invalid.

### Market/Group Selection Context

Code 2/3 chỉ được tạo khi own directional context và D/W/M MTF cùng phía, không có mixed evidence/hypothesis conflict. Mixed/multiple/counter/conflicting MTF được giữ là code 4. Các trường còn lại là unresolved hoặc insufficient.

### Candidate Stage

Phase mapping giữ nguyên semantics upstream:
- Phase A/B → Watch stage;
- Phase C candidate/C-like → Developing stage;
- Phase D-like → Directional Development;
- Phase E-like → Trend Expansion;
- terminal/superseded → terminal.

### Qualified

Bullish/Bearish Market-Aligned yêu cầu đồng thuận categorical giữa:
- Market Selection Context;
- Stock Directional Context;
- Phase D/E-capable stage;
- Stock D/W/M full alignment;
- Stock-vs-Market RS structure;
- VSA/Composite evidence không đối nghịch/mixed;
- Price/RS không non-confirming;
- một active RangeContext.

Full Top-Down thêm Group own context + Group-vs-Market RS + Stock-vs-Group RS + nested leadership/weakness.

### Developing / Watch / Review

- Phase C có thể Developing khi Market + Stock + RS cùng phía và MTF không opposite/conflict nghiêm trọng.
- Phase A/B có directional RS đáng chú ý chỉ là Watch.
- Multiple RangeContext, Price/RS non-confirmation, VSA conflict, MTF counter/conflict, RS mixed, Market/Stock conflict và Group conflict được đưa vào Review.

## Không xếp hạng

Không có weighted score, percentile, confidence/probability, `PositionScore`, `StaticVarGenerateRanks`, Top-N hay logic sort-as-best. `CandidateClassCode` là enum categorical, không phải ordinal quality.

## Wyckoff completeness

Mọi Data-Eligible result đều công bố:

`PARTIAL WYCKOFF SELECTION - P&F CAUSE / PRICE OBJECTIVE / TRADE RISK NOT EVALUATED`

Scanner không gọi Five-Step/Nine Tests complete.

## Kiểm thử còn thiếu

Chưa thực hiện trên AmiBroker 6.20.01:
- Verify Syntax cho integration stack;
- Cross-Symbol CSN01–CSN20;
- Derived Pivot equivalence K27–K29;
- RS benchmark/missing/tie/boundary fixtures;
- Scanner candidate-class counterexamples MS01–MS40;
- multi-symbol concurrency/performance;
- source revision và forming-bar behavior;
- upstream regression.

Do đó không được gọi implementation này là native acceptance hoặc production PASS.