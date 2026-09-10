# Wyckoff VSA Market Scanner — Dự thảo đặc tả v0.1

**Trạng thái:** `DRAFT FOR OWNER APPROVAL` — chỉ đặc tả, chưa có AFL triển khai, chưa phải tiêu chí nghiệm thu native.

## 1. Mục tiêu

Market Scanner v0.1 là lớp **lọc ứng viên nghiên cứu** nằm sau các engine phân tích hiện có:

`Core → Candidate → Structure/Location → Confirmation → Event → Structural Sequence → Phase/Context → Composite → Multi-Timeframe → Relative Strength → Market Scanner`

Scanner không thay thế chart review và không phát tín hiệu giao dịch. Nhiệm vụ của nó là thu hẹp universe thành các ứng viên có bối cảnh Wyckoff/VSA đáng xem xét, đồng thời giữ rõ lý do đạt, lý do bị loại và các xung đột còn tồn tại.

## 2. Cơ sở nghiên cứu

### 2.1. Wyckoff: lựa chọn là quy trình top-down, không phải một điểm số

Nguồn chính:
- Wyckoff Analytics — Wyckoff Method.
- StockCharts ChartSchool — The Wyckoff Method: A Tutorial.
- StockCharts ChartSchool — Wyckoff Stock Analysis.
- Wyckoff Analytics — Wyckoff Market Report selection methodology.

Các điểm được giữ trong thiết kế:

1. Bắt đầu từ trạng thái và hướng có khả năng của **thị trường chung**.
2. Chọn cổ phiếu **hòa hợp với hướng thị trường**, với comparative/relative strength theo đúng phía.
3. Thực hành hiện đại còn đi theo chuỗi **thị trường → nhóm/ngành → cổ phiếu**, ưu tiên nhóm dẫn dắt khi bullish và nhóm yếu khi bearish.
4. Chỉ relative strength chưa đủ; còn cần price/volume structure và readiness.
5. Wyckoff Five-Step còn có P&F cause/objective và timing/risk. Dự án hiện chưa có P&F Target/Risk Engine, vì vậy Scanner v0.1 không được tuyên bố rằng ứng viên đã hoàn tất toàn bộ Five-Step/Nine Tests.

### 2.2. VSA: scanner tìm ứng viên, background mới quyết định ý nghĩa

Nguồn chính:
- TradeGuider Stock Scanner / Indicator Scanner.
- TradeGuider VSA materials về Importance of Background, No Supply after strength và No Demand after weakness.

Các điểm giữ trong thiết kế:

1. VSA scanner có thể prospect stocks có relative over/under-performance và vừa xuất hiện thay đổi activity/VSA observations.
2. Một VSA signal đơn lẻ không đủ; background strength/weakness là điều kiện diễn giải quan trọng.
3. No Supply có giá trị bullish hơn khi strength đã có trong background; No Demand có giá trị bearish hơn khi weakness đã có.
4. Vì vậy Scanner không được lấy một Event hiện tại rồi ghi đè Phase/Family/MTF/RS.

### 2.3. Candidate Filter khác Ranking

AmiBroker tách hai khái niệm kỹ thuật:

- `Filter` trong Exploration quyết định dòng/symbol nào được nhận vào báo cáo;
- ranking là một phép so sánh cross-sectional riêng, có thể dùng `AddRankColumn`, `PositionScore` hoặc `StaticVarGenerateRanks`.

Wyckoff cung cấp logic chọn lọc/ưu tiên theo bối cảnh nhưng không cung cấp một universal numeric weight để cộng Phase + VSA + MTF + RS thành một score.

Do đó v0.1 khóa nguyên tắc:

**FILTER FIRST; NO NUMERIC RANKING.**

Sort trong Exploration chỉ là trình bày, không phải rank và không tạo thứ tự ưu tiên giao dịch.

## 3. Giới hạn nguồn hiện tại của dự án

Các đặc tả đã khóa:
- Phase/Context D01–D44;
- Composite D01–D32;
- Multi-Timeframe D01–D36;
- Snapshot Contract S01–S32;
- Relative Strength R01–R36;
- Derived-Series Pivot K01–K32.

Các implementation tương ứng đang ở draft development và chưa native acceptance. Scanner v0.1 phải consume public contracts, không copy logic upstream.

Một thiếu hụt kiến trúc đã được xác định qua nghiên cứu: Wyckoff Step 1/5 cần **trạng thái của broad market itself**, còn stock MTF hiện chỉ là D/W/M của chính cổ phiếu và Relative Strength chỉ cho biết stock so với benchmark. Hai thứ đó không thay thế market Phase/Composite/MTF state.

Vì vậy đặc tả này đề xuất một cổng bắt buộc `MS40` cho Cross-Symbol Selection Context Snapshot trước full Scanner implementation.

# QUYẾT ĐỊNH THIẾT KẾ MS01–MS40

## MS01 — Scanner là research-candidate filter

Scanner chỉ tạo:
- candidate flags;
- candidate side;
- structural stage;
- top-down alignment diagnostics;
- exclusion/review reasons;
- Exploration output.

Không tạo entry/exit/stop/target/PositionSize.

## MS02 — Universe do deployment cung cấp

Universe đến từ AmiBroker Analysis `Apply To` / watchlist / category filter.

Scanner không tự đi vòng qua toàn database để xây universe riêng nếu Analysis filter đã có thể làm trước formula.

## MS03 — Ba lớp kết quả tách biệt

Mỗi symbol phải có ba lớp độc lập:

1. `DataEligibility` — dữ liệu/interface có đủ và hợp lệ không;
2. `MethodEligibility` — bối cảnh Wyckoff/VSA có phù hợp với một phía không;
3. `ReviewState` — có ambiguity/conflict cần xem chart thủ công không.

Không collapse ba lớp thành một score.

## MS04 — Candidate Filter không phải Ranking

`QualifiedCandidateFlag` là boolean per-symbol.

Ranking là cross-sectional order giữa nhiều symbol và **không thuộc v0.1**.

Cấm dùng:
- weighted score;
- confidence/probability;
- percentile;
- `StaticVarGenerateRanks`;
- `PositionScore`;
- Top-N selection.

## MS05 — Sort chỉ là presentation

Exploration được phép sort categorical columns để dễ đọc, nhưng:
- không xuất `Rank`;
- không gọi thứ tự sort là “best stock”;
- không dùng sort order làm downstream trading decision.

## MS06 — Official scope là Daily completed-bar current state

Scanner v0.1 chạy current-state EOD trên Daily.

Thanh cuối provisional không được tạo official candidate.

Không historical scanner backfill trong v0.1.

## MS07 — Market benchmark explicit và bắt buộc

Market benchmark phải là symbol explicit, đồng nhất với benchmark của Relative Strength official channel.

Không silent substitute benchmark khác.

## MS08 — Group/sector là optional nhưng provenance phải explicit

Group benchmark có thể không tồn tại.

Nếu không cấu hình Group:
- Stock-vs-Market vẫn được đánh giá;
- không được gọi kết quả là `FULL TOP-DOWN GROUP-ALIGNED`;
- không lấy Market làm Group fallback.

## MS09 — Hai profile qualification

Đề xuất hai profile semantic:

1. `MARKET-ALIGNED CANDIDATE` — đủ market + stock evidence, Group chưa có/không bắt buộc;
2. `FULL TOP-DOWN CANDIDATE` — đủ market + group + stock context và RS chain.

Đây là profile completeness, không phải hạng 1/hạng 2.

## MS10 — Hard data exclusions

Official candidate phải fail closed khi có một trong các điều kiện:
- current Daily bar provisional;
- required upstream schema/interface invalid;
- Relative Strength market benchmark missing/invalid;
- adjustment basis chưa verified-compatible theo R28;
- Stock MTF snapshot contract invalid khi chạy full-MTF profile;
- Market Selection Context snapshot missing/stale/version-mismatch/future/provisional;
- source payload non-finite/invalid tại trường bắt buộc.

Các trường hợp này là `DATA_GATED`, không phải bearish/bullish evidence.

## MS11 — Liquidity không có universal Wyckoff threshold trong v0.1

Modern Wyckoff screening thường ưu tiên instrument đủ thanh khoản, nhưng nguồn không cung cấp một ngưỡng universal phù hợp mọi thị trường.

Vì vậy:
- không hard-code giá trị thanh khoản/giá/turnover cho Việt Nam trong methodology;
- deployment có thể dùng Analysis watchlist/category filter hoặc một `LiquidityPolicy` riêng;
- nếu dùng threshold deployment, output phải ghi `DEPLOYMENT POLICY`, không gọi đó là Wyckoff rule.

## MS12 — Ambiguous RangeContext không phải data corruption

`MULTIPLE RANGE CONTEXTS` vẫn là dữ liệu hợp lệ nhưng không đủ để trở thành Qualified Candidate.

Phân loại:
`REVIEW — MULTIPLE RANGE CONTEXTS`.

Không tùy ý chọn range thắng.

## MS13 — Market Selection Context là lớp riêng

Scanner cần current completed Daily state của broad market gồm tối thiểu:
- Composite Directional Context;
- Phase/Structural Development;
- Evidence Balance;
- MTF Directional Alignment;
- source DateTime;
- schema/provenance.

Stock-vs-Market RS không thay thế các trường trên.

## MS14 — Market context bullish/bearish/neutral/mixed

Đề xuất `MarketSelectionContextCode`:
- 0 `INSUFFICIENT`;
- 1 `UNRESOLVED / NEUTRAL`;
- 2 `BULLISH SUPPORTIVE`;
- 3 `BEARISH SUPPORTIVE`;
- 4 `MIXED / CONFLICTING`.

Chỉ tạo code 2/3 từ market public context + MTF, không từ một bar hoặc một RS ratio.

## MS15 — Group Selection Context nếu Group có cấu hình

Group phải giữ:
- own Composite Directional Context;
- own Phase/Structural Development;
- own MTF alignment;
- Group-vs-Market RS Structure;
- provenance.

Không chỉ nhìn Group-vs-Market ratio rồi gọi group bullish/bearish structure đầy đủ.

## MS16 — Stock structural stage giữ nguyên Phase semantics

Scanner không đổi Phase thành tín hiệu giao dịch.

Đề xuất `CandidateStageCode`:
- 0 `NONE / INSUFFICIENT`;
- 1 `WATCH — RANGE FORMATION/DEVELOPMENT` (Phase A/B);
- 2 `DEVELOPING — FINAL TEST` (Phase C candidate/C-like);
- 3 `DIRECTIONAL DEVELOPMENT` (Phase D-like);
- 4 `TREND EXPANSION` (Phase E-like);
- 5 `TERMINAL / SUPERSEDED`.

Đây là stage, không phải confidence rank.

## MS17 — Phase A/B chỉ Watch, không Qualified Candidate

Phase A/B có thể đáng theo dõi nhưng chưa đủ readiness cho scanner v0.1.

Nếu RS/VSA có dấu hiệu sớm, output là `WATCH`, không nâng thành qualified.

## MS18 — Phase C là Developing Candidate

Phase C candidate/C-like có thể là early Wyckoff opportunity context nhưng vẫn còn test/follow-through risk.

Nó được phân loại `DEVELOPING`, không ngang với Phase D/E.

## MS19 — Phase D/E có thể Qualified nhưng không đồng nghĩa entry tốt

Phase D/E đáp ứng structural maturity tốt hơn cho candidate filtering.

Tuy nhiên Phase E có thể đã đi xa; do thiếu P&F/risk-reward engine, Scanner không được gọi đó là “safe entry” hoặc “best entry”.

## MS20 — Bullish Method Eligibility

Một symbol chỉ có thể thành bullish qualified candidate khi tất cả điều kiện lõi sau đồng thuận:

- MarketSelectionContext = bullish supportive;
- Stock Composite Directional Context = bullish hypothesis;
- Stock CandidateStage = Phase D-like hoặc Phase E-like;
- Stock MTF Directional Alignment = bullish alignment;
- Stock-vs-Market RS Structure = rising;
- VSA/Composite evidence không bearish/mixed và hypothesis alignment không conflicting.

Nếu Group được cấu hình cho full top-down profile, thêm điều kiện MS22.

## MS21 — Bearish Method Eligibility đối xứng

Bearish qualified candidate yêu cầu:
- MarketSelectionContext = bearish supportive;
- Stock Composite Directional Context = bearish hypothesis;
- Phase D-like hoặc Phase E-like;
- Stock MTF = bearish alignment;
- Stock-vs-Market RS Structure = falling;
- VSA/Composite evidence không bullish/mixed và hypothesis alignment không conflicting.

Không phát Short signal.

## MS22 — Full Top-Down Group Eligibility

Khi Group benchmark được cấu hình, `FULL TOP-DOWN CANDIDATE` yêu cầu thêm:

Bullish:
- Group own context bullish supportive;
- Group MTF không bearish/conflicting;
- Group-vs-Market RS rising;
- Stock-vs-Group RS rising;
- Leadership Chain = nested relative leadership.

Bearish đối xứng với relative weakness.

Nếu Group thiếu/invalid, symbol có thể vẫn đạt Market-Aligned profile nhưng không Full Top-Down.

## MS23 — VSA Evidence là background gate, không event count score

Không cộng Spring + SOS + No Supply thành điểm.

Dùng categorical upstream:
- EvidenceBalance;
- HypothesisAlignment;
- Phase-linked event context;
- optional current EventMask chỉ để audit.

Bullish qualified không được có bearish-only hoặc mixed evidence; bearish đối xứng.

## MS24 — Current Event không tự tạo Candidate

Một Spring, SOS, LPS, SOW, LPSY, No Supply hay No Demand tại current bar chỉ là context/evidence.

Không có rule kiểu:
`if SOS then Candidate=1`.

## MS25 — MTF là context gate, không majority vote

Qualified candidate v0.1 yêu cầu full D/W/M directional alignment theo phía.

Các trạng thái:
- `BASE COUNTER TO HIGHER CONTEXT`;
- `HIGHER TIMEFRAMES CONFLICT`;
- `MIXED / COMPLEX`

không được Qualified nhưng phải xuất `REVIEW` thay vì bị mất khỏi audit hoàn toàn.

## MS26 — Relative Strength là selection gate, không ranking score

Bullish qualified yêu cầu Stock-vs-Market RS rising; bearish yêu cầu falling.

Raw ratio level, WaveChangePct hoặc magnitude không được dùng làm điểm xếp hạng trong v0.1.

## MS27 — Price/RS non-confirmation tạo Review state

Nếu price structure và RS structure non-confirming:
- không tự đảo candidate side;
- không tự loại dữ liệu;
- Qualified bị chặn;
- xuất `REVIEW — PRICE/RS NON-CONFIRMATION`.

## MS28 — Developing Candidate logic

Phase C candidate/C-like được phép `DEVELOPING BULLISH/BEARISH` khi:
- Market context cùng phía;
- stock directional hypothesis cùng phía;
- Stock-vs-Market RS cùng phía;
- không có VSA evidence đối nghịch rõ;
- MTF không ở trạng thái opposite/conflict nghiêm trọng.

Developing không phải Qualified và không phải rank thấp hơn theo số học.

## MS29 — Watch logic

Phase A/B với relative strength/weakness đáng chú ý có thể xuất `WATCH`.

Watch không đi vào `QualifiedCandidateFlag`.

## MS30 — Conflict Review phải được giữ

Các xung đột có ý nghĩa phải hiện trong audit:
- multiple RangeContext;
- price/RS non-confirmation;
- VSA vs hypothesis conflict;
- Daily counter higher-timeframe;
- higher-timeframe conflict;
- Market vs Stock directional conflict;
- Group vs Market/Stock conflict.

Không xóa dòng chỉ vì không qualify nếu user chọn Audit/Review mode.

## MS31 — Candidate classification không có ordinal quality

Đề xuất `CandidateClassCode` chỉ để enum:
- 0 `DATA GATED / INSUFFICIENT`;
- 1 `NOT A CURRENT CANDIDATE`;
- 2 `WATCH`;
- 3 `DEVELOPING BULLISH`;
- 4 `QUALIFIED BULLISH — MARKET ALIGNED`;
- 5 `QUALIFIED BULLISH — FULL TOP-DOWN`;
- 6 `DEVELOPING BEARISH`;
- 7 `QUALIFIED BEARISH — MARKET ALIGNED`;
- 8 `QUALIFIED BEARISH — FULL TOP-DOWN`;
- 9 `REVIEW — CONFLICT / AMBIGUITY`.

**Mã enum không phải thứ hạng.** Code 5 không có nghĩa “tốt hơn gấp 5 lần” code 1.

## MS32 — Filter modes

Exploration có thể cung cấp mode:
- `QUALIFIED ONLY`;
- `DEVELOPING + QUALIFIED`;
- `WATCH + DEVELOPING + QUALIFIED`;
- `REVIEW / AUDIT`;
- `ALL ELIGIBLE`.

Mode chỉ chọn dòng hiển thị, không sửa classification.

## MS33 — ExclusionReasonMask là diagnostic bitmask

Hard-data reason bits tối thiểu:
- provisional bar;
- upstream schema invalid;
- market benchmark invalid;
- adjustment basis unverified/incompatible;
- MTF invalid;
- market-context snapshot invalid;
- group-context invalid khi Full Top-Down được yêu cầu;
- required value non-finite.

Bitmask chỉ để audit, không phải score.

## MS34 — MethodBlockReasonMask riêng với Data Exclusion

Method-block reasons tối thiểu:
- market opposite/unresolved;
- stock phase too early;
- stock hypothesis opposite/unresolved;
- MTF counter/conflict;
- RS opposite/mixed;
- VSA conflicting/mixed;
- price/RS non-confirmation;
- group leadership conflict;
- multiple range contexts.

Không trộn method conflict với lỗi dữ liệu.

## MS35 — P&F và risk/reward chưa được đánh giá

Scanner phải xuất một `SelectionCompletenessCode` cho biết:

`PARTIAL WYCKOFF SELECTION — P&F CAUSE / PRICE OBJECTIVE / TRADE RISK NOT EVALUATED`.

Không tuyên bố Five-Step complete hoặc Nine Tests complete trong v0.1.

## MS36 — Không tái tạo Nine Buying/Selling Tests bằng proxy tùy ý

Không được lấy Phase + RS + VSA rồi gọi là “7/9 tests passed” nếu các test P&F/trend-line/risk chưa có implementation đã khóa.

Nếu sau này xây Nine Tests Engine, phải là module/đặc tả riêng.

## MS37 — Exploration-first, không auto-watchlist mutation v0.1

Output đầu tiên là Exploration current-state.

Không tự `CategoryAddSymbol`/`CategoryRemoveSymbol` vào watchlist trong v0.1 để tránh side effect khó kiểm toán.

Người dùng có thể lưu kết quả thủ công sau review.

## MS38 — Public interface prefix

Prefix đề xuất: `WSCN_`.

Các field lõi:
- `WSCN_DataEligibilityCode`;
- `WSCN_CandidateClassCode`;
- `WSCN_CandidateSideCode`;
- `WSCN_CandidateStageCode`;
- `WSCN_QualifiedCandidateFlag`;
- `WSCN_DevelopingCandidateFlag`;
- `WSCN_WatchFlag`;
- `WSCN_ReviewFlag`;
- `WSCN_MarketSelectionContextCode`;
- `WSCN_GroupSelectionContextCode`;
- stock Phase/Family/Evidence/MTF/RS snapshots;
- `WSCN_ExclusionReasonMask`;
- `WSCN_MethodBlockReasonMask`;
- benchmark/group/source/schema/provisional provenance;
- `WSCN_SelectionCompletenessCode`.

## MS39 — Minimum Exploration columns

### Provenance / data health
- Symbol;
- scan DateTime;
- Market benchmark;
- Group benchmark;
- Daily completed/provisional;
- upstream schema status;
- market/group snapshot status;
- RS benchmark status;
- adjustment-basis status.

### Top-down context
- Market Selection Context;
- Group Selection Context;
- Stock Directional Context;
- Stock Phase/Structural Stage;
- Stock EvidenceBalance/HypothesisAlignment;
- D/W/M MTF Alignment;
- Stock-vs-Market RS Structure;
- Stock-vs-Group RS Structure;
- Group-vs-Market RS Structure;
- Leadership Chain;
- Price/RS Relationship.

### Decision audit
- Candidate Class;
- Qualified/Developing/Watch/Review flags;
- ExclusionReasonMask;
- MethodBlockReasonMask;
- SelectionCompleteness.

## MS40 — Cổng kiến trúc bắt buộc: Cross-Symbol Selection Context Snapshot

**Trước khi viết full Market Scanner AFL**, phải có một contract riêng để Scanner đọc current completed context của Market benchmark và Group benchmark mà không chạy lại toàn bộ Composite/MTF engine bên trong từng stock formula.

Contract tối thiểu phải:

1. publish current completed Daily `Composite + MTF` state cho một explicit symbol;
2. namespace theo symbol + schema/version;
3. có source DateTime, publish time, generation và Ready-last transaction semantics tương tự Snapshot Contract hiện hành;
4. consumer phải validate expected symbol, date/session freshness, version và provisional state;
5. Market snapshot bắt buộc; Group snapshot tùy cấu hình;
6. không dùng `SetForeign` để âm thầm chạy full Phase/Composite/MTF engine trong Scanner;
7. không duplicate market/group Phase formulas;
8. fail closed khi stale/missing/future/version-mismatch;
9. giữ current-state only v0.1;
10. có Exploration/audit surface riêng trước khi Scanner consume.

**MS40 là prerequisite bắt buộc trước full Scanner implementation.**

Lý do: Stock MTF ≠ Market MTF và Stock-vs-Market RS ≠ Market structural/phase context. Nếu bỏ bước này, Scanner không thể thực hiện đúng Wyckoff Step 1/5 mà vẫn giữ kiến trúc causal/auditable hiện tại.

---

## 4. Phản ví dụ bắt buộc

1. Stock Phase D bullish + RS rising nhưng Market bearish → không Qualified bullish.
2. Market bullish + stock bullish nhưng Stock-vs-Market RS falling → không Qualified bullish.
3. Market/Stock bullish + RS rising nhưng VSA bearish-only → Review/conflict, không qualify.
4. Daily bullish nhưng Weekly+Monthly bearish → `BASE COUNTER TO HIGHER CONTEXT`, không qualify.
5. Weekly bullish, Monthly bearish → higher-timeframe conflict, không qualify.
6. Phase B + RS rất mạnh → Watch, không tự nâng Qualified.
7. Phase C bullish + supportive context → Developing, không coi ngang Phase D/E.
8. Phase E bullish → có thể Qualified context nhưng không gọi “entry tốt”; risk/reward chưa biết.
9. Spring current bar nhưng Phase/market/RS chưa hỗ trợ → không Candidate chỉ vì Spring.
10. No Supply trong weakness background → không bullish qualification.
11. No Demand trong strength background → không bearish qualification.
12. Group missing → không dùng Market làm Group fallback và không gọi Full Top-Down.
13. Group weak nhưng stock mạnh hơn group → không tự gọi nested leadership.
14. Market snapshot stale → Data Gated dù stock data hiện tại đầy đủ.
15. Adjustment basis unverified → không production-qualified RS candidate.
16. Multiple active RangeContexts → Review, không chọn winner.
17. Raw RSRatio cao hơn symbol khác → không có nghĩa rank cao hơn.
18. WaveChangePct lớn → không tạo rank.
19. Exploration sort đầu bảng → không có nghĩa best candidate.
20. Liquidity threshold deployment làm stock bị loại → reason phải là deployment policy, không Wyckoff rule.
21. Thiếu P&F target/risk → không gọi Five-Step complete.
22. Một cổ phiếu thỏa 6 điều kiện còn cổ phiếu khác thỏa 5 → không tự suy ra 6 tốt hơn 5 nếu không có ranking contract.
23. Vendor sửa historical source → phải phân biệt source revision với scanner logic repaint.
24. Forming bar tạo SOS/RS tăng tạm thời → không official candidate cho tới completed bar.

---

## 5. Bảng quyết định cần chủ dự án phê duyệt

| Mã | Đề xuất | Khuyến nghị |
|---|---|---|
| MS01–MS03 | Scanner = research filter, tách data/method/review | Chấp thuận rất mạnh |
| MS04–MS05 | Filter khác Rank; v0.1 không numeric ranking | Chấp thuận rất mạnh |
| MS06 | Daily completed current-state | Chấp thuận rất mạnh |
| MS07–MS09 | Market explicit, Group optional, hai profile completeness | Chấp thuận mạnh |
| MS10–MS12 | Hard data gate + ambiguity review | Chấp thuận rất mạnh |
| MS13–MS15 | Market/Group own context phải tồn tại | Chấp thuận rất mạnh |
| MS16–MS19 | Stage theo Phase; A/B watch, C developing, D/E qualified-capable | Chấp thuận mạnh |
| MS20–MS23 | Kết hợp Market + Phase + VSA + MTF + RS bằng logic categorical | Chấp thuận rất mạnh |
| MS24–MS30 | Event không tự quyết định; conflict giữ để review | Chấp thuận rất mạnh |
| MS31–MS34 | Candidate enum + reason masks, không ordinal score | Chấp thuận rất mạnh |
| MS35–MS36 | Không giả hoàn tất Five-Step/Nine Tests khi thiếu P&F/risk | Chấp thuận rất mạnh |
| MS37–MS39 | Exploration-first, không side-effect watchlist | Chấp thuận mạnh |
| MS40 | Cross-Symbol Selection Context Snapshot prerequisite | **Chấp thuận bắt buộc** |

---

## 6. Trình tự triển khai sau khi được duyệt

1. Khóa MS01–MS40.
2. **Không viết full Scanner ngay.**
3. Nghiên cứu + đặc tả Cross-Symbol Selection Context Snapshot theo MS40.
4. Chủ dự án phê duyệt Snapshot contract.
5. Triển khai Publisher/Consumer + static audit, giữ UNTESTED DEVELOPMENT.
6. Sau đó mới triển khai Market Scanner Exploration trên development stack gồm Composite + MTF + Relative Strength.
7. Market Scanner giữ draft/unmerged cho tới chiến dịch native acceptance tổng thể.

## 7. Kết luận

Thiết kế v0.1 chủ ý biến Scanner thành **cỗ máy thu hẹp tập ứng viên có lý do rõ ràng**, không biến Wyckoff/VSA thành một điểm số.

Chuỗi logic mục tiêu:

`MARKET CONTEXT → GROUP CONTEXT (nếu có) → STOCK PHASE/VSA → STOCK MTF → RELATIVE STRENGTH → CANDIDATE CLASSIFICATION → HUMAN CHART REVIEW`

Không có bước `SCORE → TOP 10 → BUY` trong v0.1.
