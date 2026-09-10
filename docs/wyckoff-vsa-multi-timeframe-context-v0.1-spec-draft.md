# Wyckoff VSA Multi-Timeframe Context Engine — Dự thảo đặc tả v0.1

**Trạng thái:** `DRAFT FOR OWNER APPROVAL` — chưa khóa, chưa phải tiêu chí nghiệm thu, chưa có AFL triển khai.

## 1. Mục tiêu

Multi-Timeframe Context Engine nằm sau Composite Indicator và trước Market Scanner / Relative Strength:

`Core → Candidate → Structure/Location → Confirmation → Event → Structural Sequence → Phase/Context → Composite → Multi-Timeframe Context → Scanner / Relative Strength / Chart Panel`

Mục tiêu của v0.1 là cung cấp **bối cảnh Wyckoff–VSA liên khung thời gian có tính nhân quả**, không biến nhiều khung thời gian thành một hệ điểm số hoặc một tín hiệu giao dịch.

Engine phải giúp trả lời:

1. khung cơ sở hiện ở Phase/Family/Evidence nào;
2. khung lớn hơn gần nhất đang ở trạng thái nào;
3. khung lớn hơn thứ hai đang ở trạng thái nào;
4. các khung có đồng thuận, xung đột hay chưa đủ bằng chứng;
5. xung đột nằm ở Family, Phase hay Evidence;
6. higher-timeframe context nào đã **thực sự hoàn tất và được biết** tại thời điểm đánh giá;
7. có nguy cơ dùng dữ liệu higher timeframe chưa hoàn tất hoặc stale snapshot hay không.

Không tạo Buy/Sell/Short/Cover, không confidence %, không probability %, không weighted score.

---

## 2. Cơ sở nghiên cứu Wyckoff / VSA / AmiBroker

### 2.1. Wyckoff: cấu trúc là fractal, nhưng khung lớn có quyền lực bối cảnh lớn hơn

Nguồn nghiên cứu chính:

- Bruce Fraser / StockCharts — *Getting on the Gas*: https://articles.stockcharts.com/article/articles-wyckoff-2016-07-getting-on-the-gas/
- Bruce Fraser / StockCharts — *S&P 500 Tempest in a Teapot*: https://articles.stockcharts.com/article/articles-wyckoff-2024-09-sp-500-tempest-in-a-teapot-268/
- Bruce Fraser / StockCharts — *Wyckoff Nation*: https://articles.stockcharts.com/article/articles-wyckoff-2016-10-wyckoff-nation/
- Bruce Fraser / StockCharts — trend analysis / larger timeframe context.

Kết luận trực tiếp cho thiết kế:

1. Wyckoff structure lặp lại ở nhiều timeframe; cùng mô hình có thể tồn tại ở intraday, daily, weekly, monthly.
2. Khi giao dịch/phân tích một timeframe, việc xem **một hoặc hai timeframe lớn hơn** giúp thấy bức tranh lớn và tránh bị một cấu trúc nhỏ đánh lừa.
3. Cấu trúc khung nhỏ có thể tiết lộ sớm diễn biến đang hình thành, nhưng khung lớn có thể chứa supply/demand đủ lớn để chi phối diễn biến khung nhỏ.
4. Vì vậy MTF engine phải **giữ cả agreement và conflict**, không dùng quy tắc “higher timeframe luôn đúng” hay “lower timeframe luôn đúng”.
5. Một setup bullish ở khung nhỏ trong higher-timeframe supply background là thông tin xung đột quan trọng, không phải dữ liệu cần xóa.

### 2.2. VSA: background ở khung lớn phải được xem như context, không phải lệnh

Nguồn:

- TradeGuider — *Ways to Improve your Chart Reading – Part 2: Multi-Timeframe Environments*: https://tradeguider.com/blogs/blog_fj0MDqoC.asp?ID=fj0MDqoC
- TradeGuider Chart Center / multi-timeframe trend alignment: https://www.tradeguider.com/chart_center.asp
- TradeGuider VSA background materials.

Kết luận:

1. Higher timeframe có thể cho thấy supply trong background trong khi lower timeframe đang cho demand, và ngược lại.
2. Multi-timeframe alignment có ích, nhưng không có cơ sở để biến số lượng khung đồng thuận thành một xác suất chuẩn hóa trong dự án này.
3. VSA signal vẫn phải được đọc trong structure/background; một No Supply/No Demand ở khung nhỏ không được phép override family/phase khung lớn trong MTF layer.

### 2.3. AmiBroker: nguy cơ look-ahead khi mở rộng higher-timeframe data

Nguồn kỹ thuật chính:

- AmiBroker Multiple Time Frame Support: https://www.amibroker.com/guide/h_timeframe.html
- `TimeFrameSet`: https://www.amibroker.com/guide/afl/timeframeset.html
- `TimeFrameExpand`: https://www.amibroker.com/guide/afl/timeframeexpand.html
- `StaticVarGet`: https://ftp.amibroker.com/guide/afl/staticvarget.html
- `StaticVarSet`: https://ftp.amibroker.com/guide/afl/staticvarset.html

Các điểm bắt buộc:

1. AmiBroker cho phép nén/mở rộng timeframe nhưng `expandFirst` trên High/Low/Close của một higher-timeframe bar có thể tạo look-ahead.
2. `TimeFrameGetPrice` với shift 0 có thể chứa thông tin của higher-timeframe bar hiện tại chưa hoàn tất; tài liệu chính thức cảnh báo dùng negative shift khi cần tránh future leakage.
3. Static arrays có thể đồng bộ timestamp giữa timeframe nhưng có giới hạn; do đó transport/freshness phải được đặc tả rõ, không được ngầm coi dữ liệu đã đồng bộ là causal.
4. Upstream hiện tại là chuỗi module global-state AFL, chưa được thiết kế re-entrant để cùng một formula chạy full Composite stack nhiều lần bằng các prefix độc lập.

Từ đó, v0.1 phải có **Timeframe Snapshot execution contract riêng** trước khi viết aggregator.

---

# QUYẾT ĐỊNH THIẾT KẾ D01–D36

## D01 — Scope v0.1 = cùng một mã, ba khung EOD

V0.1 chỉ hỗ trợ:

- Base = Daily;
- Higher-1 = Weekly;
- Higher-2 = Monthly;
- cùng một symbol.

Không hỗ trợ intraday trong v0.1.

Lý do:

- upstream hiện dùng Daily completed bars làm official research scope;
- Daily → Weekly → Monthly đúng với nguyên tắc Wyckoff “xem một hoặc hai timeframe lớn hơn”;
- tránh mở rộng quá sớm sang arbitrary intervals trước khi causal transport được kiểm thử.

## D02 — Không cho cấu hình tùy ý timeframe ở v0.1

Không cho người dùng thay Weekly/Monthly thành 3-day/7-day/biweekly trong bản đầu.

Đây là giới hạn kỹ thuật để kiểm thử và khóa causality trước, không phải tuyên bố rằng Wyckoff chỉ hợp lệ ở ba timeframe này.

## D03 — Mỗi timeframe là một context độc lập

Daily, Weekly, Monthly mỗi khung phải giữ nguyên:

- ContextMultiplicity;
- RangeContext identity;
- PhaseState;
- FamilyHypothesis;
- DirectionalContext;
- EvidenceBalance;
- HypothesisAlignment;
- range status/boundaries;
- revision/ambiguity state.

MTF không tái tính các trạng thái đó.

## D04 — Multi-Timeframe layer chỉ aggregate, không interpretation mới

Nếu logic mới cần xác định Spring, SOW, Phase, Family hoặc VSA signal, logic đó thuộc upstream.

MTF chỉ:

- consume snapshot;
- kiểm tra snapshot validity/freshness;
- so sánh categorical states giữa khung;
- xuất agreement/conflict diagnostics.

## D05 — Higher timeframe không tự động override lower timeframe

Không có quy tắc:

- Monthly thắng Weekly;
- Weekly thắng Daily;
- phase cao hơn thắng phase thấp hơn;
- range lớn hơn thắng range nhỏ hơn.

Higher timeframe là **context authority về quy mô**, không phải quyền ghi đè state của khung nhỏ.

## D06 — Lower timeframe không tự động override higher timeframe

Một Spring/SOS/No Supply trên Daily không được tự chuyển Weekly/Monthly bullish.

Một Upthrust/SOW/No Demand trên Daily không được tự chuyển Weekly/Monthly bearish.

## D07 — MTF Agreement chỉ dùng directional family state

Đề xuất `WMTF_DirectionalAlignmentCode`:

- 0 = `INSUFFICIENT MTF DATA`;
- 1 = `UNRESOLVED / NON-DIRECTIONAL`;
- 2 = `BULLISH ALIGNMENT`;
- 3 = `BEARISH ALIGNMENT`;
- 4 = `BASE COUNTER TO HIGHER CONTEXT`;
- 5 = `HIGHER TIMEFRAMES CONFLICT`;
- 6 = `MIXED / COMPLEX MTF CONTEXT`.

Không dùng EventMask hay số event để quyết định alignment.

## D08 — Bullish alignment

Chỉ được gọi `BULLISH ALIGNMENT` khi:

- Daily DirectionalContext = bullish;
- Weekly valid DirectionalContext = bullish;
- Monthly valid DirectionalContext = bullish.

Nếu một higher timeframe unresolved/insufficient thì không gọi full bullish alignment.

## D09 — Bearish alignment

Đối xứng D08:

- Daily bearish;
- Weekly bearish;
- Monthly bearish.

## D10 — Base counter to higher context

Dùng khi Weekly và Monthly **cùng directional và cùng phía**, nhưng Daily directional theo phía ngược lại.

Ví dụ:

- Weekly bearish + Monthly bearish + Daily bullish → `BASE COUNTER TO HIGHER CONTEXT`.

Không gọi đây là “false Daily signal” hay “không được mua”.

## D11 — Higher timeframes conflict

Dùng khi Weekly và Monthly đều valid directional nhưng trái dấu nhau.

Daily không được chọn winner cho hai khung lớn.

## D12 — Mixed / complex

Dùng khi:

- có multiple context/ambiguous ở một hoặc nhiều timeframe;
- directional/mixed state không rơi vào D08–D11;
- có combination bullish/bearish/mixed khó rút gọn mà không mất nghĩa.

## D13 — Unresolved không bị ép thành neutral score

`UNRESOLVED` nghĩa là cấu trúc chưa phân giải, không phải điểm 0 hoặc “không có tác động”.

MTF phải phân biệt:

- insufficient;
- unresolved;
- mixed/conflicting.

## D14 — Phase alignment là diagnostics riêng

Đề xuất `WMTF_PhaseRelationshipCode`, chỉ mô tả:

- 0 insufficient;
- 1 same phase state;
- 2 Daily structurally earlier than Weekly/Monthly;
- 3 Daily structurally later than Weekly/Monthly;
- 4 divergent phase states;
- 5 ambiguous because multiple contexts.

**Không** diễn giải số phase lớn hơn là “tốt hơn”.

## D15 — Không so sánh RangeContextID giữa timeframe

RangeContextID chỉ có nghĩa trong chính timeframe tạo ra nó.

Không được suy ra Weekly Range #12 và Monthly Range #12 là cùng cấu trúc.

## D16 — Không hợp nhất range boundaries giữa timeframe

Daily range, Weekly range, Monthly range có thể lồng nhau, chồng nhau hoặc độc lập.

V0.1 chỉ xuất boundaries riêng theo timeframe.

Không tạo một `MasterRange` mới.

## D17 — Range nesting chưa phải quyết định hướng

Nếu Daily range nằm trong Weekly range, đó chỉ là mô tả topology.

V0.1 chưa dùng containment/overlap để đổi DirectionalAlignment.

Range nesting analytics để dành v0.2 nếu cần.

## D18 — Higher-timeframe EventMask không được nhập vào Daily CurrentEventMask

Các event ở Weekly/Monthly phải giữ tên khung riêng.

Ví dụ:

- `WMTF_W_EventMask`;
- `WMTF_M_EventMask`.

Không OR tất cả thành một mask duy nhất rồi gọi “current events”, vì một Weekly event có timestamp/known-at khác Daily.

## D19 — Higher-timeframe state phải đến từ completed higher bar

Official MTF context không được dùng Weekly/Monthly bar đang hình thành.

V0.1 dùng **bar hoàn tất trước đó** của Weekly và Monthly làm authoritative higher snapshot.

Nghĩa là:

- trong tuần hiện tại, Weekly context authoritative = tuần hoàn tất trước đó;
- trong tháng hiện tại, Monthly context authoritative = tháng hoàn tất trước đó.

Đây là lựa chọn bảo thủ có chủ ý để tránh incomplete-bar leakage.

## D20 — Không “nâng cấp sớm” Weekly vào cuối thứ Sáu trong v0.1

Ngay cả khi người dùng tin rằng phiên thứ Sáu đã đóng, v0.1 không tự suy đoán holiday/session completion để dùng current Weekly bar.

Weekly snapshot mới trở thành authoritative ở chu kỳ higher snapshot kế tiếp.

Đổi chính sách này cần một calendar/session-completion contract riêng.

## D21 — Monthly tương tự Weekly

Không tự dùng tháng hiện tại chỉ vì hôm nay là ngày giao dịch cuối tháng.

Authoritative Monthly context = previous completed Monthly bar.

## D22 — Higher snapshot phải có provenance

Mỗi Weekly/Monthly snapshot tối thiểu phải có:

- Symbol;
- TimeframeCode;
- SourceBarDateTime;
- SourceBarIndex hoặc local ordinal nếu phù hợp;
- SnapshotVersion;
- Composite/Phase source version marker;
- CompletedSourceFlag;
- SnapshotValidFlag;
- ContextMultiplicity;
- Phase/Family/Directional/Evidence states;
- Range IDs/boundaries;
- current snapshot EventMask + event source DateTime.

## D23 — Snapshot freshness là hard gate

Nếu engine không chứng minh snapshot tương ứng với **previous completed higher period** đang được mong đợi, snapshot không được dùng.

Phải xuất:

- `FRESH`;
- `STALE`;
- `MISSING`;
- `VERSION_MISMATCH`;
- `INVALID SOURCE`.

Không được silently reuse stale Weekly/Monthly snapshot.

## D24 — Không arbitrary stale-day threshold

Không dùng quy tắc kiểu “snapshot quá 7 ngày = stale” hoặc “quá 31 ngày = stale”.

Freshness phải dựa trên **period identity**, không dựa số ngày tùy ý.

## D25 — Missing higher timeframe không suy từ timeframe khác

Nếu Monthly snapshot thiếu:

- không copy Weekly vào Monthly;
- không dùng price trend để bù;
- không gọi full alignment.

Giữ `INSUFFICIENT MTF DATA` hoặc trạng thái tương ứng.

## D26 — Multiple RangeContext ở higher timeframe là ambiguity thực

Nếu Weekly hoặc Monthly Composite báo multiple active range contexts:

- MTF không chọn một range;
- higher directional summary phải giữ mixed/ambiguous;
- diagnostics phải export lower/upper channel nếu cần audit.

## D27 — Evidence relationship tách khỏi Family relationship

Đề xuất `WMTF_EvidenceAlignmentCode` riêng:

- 0 insufficient;
- 1 bullish evidence aligned across all three;
- 2 bearish evidence aligned across all three;
- 3 Daily evidence counter to both higher frames;
- 4 higher evidence conflict;
- 5 mixed/complex.

Không cho evidence alignment tự đổi Family alignment.

## D28 — VSA background across timeframe là context, không veto

Ví dụ:

- Daily bullish evidence;
- Weekly bearish evidence;
- Monthly bearish hypothesis.

Engine phải báo conflict, không phát “Daily signal invalid”.

Trader/Scanner layer sau mới quyết định cách sử dụng conflict.

## D29 — Không weighted timeframe score

Cấm các công thức kiểu:

- Monthly × 3 + Weekly × 2 + Daily × 1;
- 2/3 timeframe bullish = 66%;
- confidence = 80%;
- majority vote.

Không có calibration đã khóa để biện minh cho các con số đó.

## D30 — Public interface prefix

Prefix đề xuất: `WMTF_`.

Các field lõi:

- `WMTF_SnapshotContractValid`;
- `WMTF_DailyValid`;
- `WMTF_WeeklySnapshotStatusCode`;
- `WMTF_MonthlySnapshotStatusCode`;
- `WMTF_D_PhaseStateCode`;
- `WMTF_W_PhaseStateCode`;
- `WMTF_M_PhaseStateCode`;
- `WMTF_D_FamilyHypothesisCode`;
- `WMTF_W_FamilyHypothesisCode`;
- `WMTF_M_FamilyHypothesisCode`;
- `WMTF_D_DirectionalContextCode`;
- `WMTF_W_DirectionalContextCode`;
- `WMTF_M_DirectionalContextCode`;
- `WMTF_D_EvidenceBalanceCode`;
- `WMTF_W_EvidenceBalanceCode`;
- `WMTF_M_EvidenceBalanceCode`;
- `WMTF_DirectionalAlignmentCode`;
- `WMTF_EvidenceAlignmentCode`;
- `WMTF_PhaseRelationshipCode`;
- timeframe-specific range identity/boundaries;
- timeframe-specific EventMask and source timestamp.

## D31 — Exploration-first

V0.1 phải có Exploration trước chart panel.

Các cột tối thiểu:

### Snapshot health
- Weekly snapshot status;
- Monthly snapshot status;
- source bar date;
- version/provenance.

### Daily / Weekly / Monthly state
- Phase;
- Family;
- Directional Context;
- Evidence Balance;
- ContextMultiplicity;
- RangeStatus.

### Cross-timeframe diagnostics
- DirectionalAlignment;
- EvidenceAlignment;
- PhaseRelationship;
- conflict reason code.

## D32 — Chart v0.1 chỉ là context panel

Chart panel có thể hiển thị:

- D/W/M Phase;
- D/W/M Family;
- D/W/M Directional Context;
- MTF Alignment;
- snapshot health.

Không mặc định vẽ Weekly/Monthly event markers lên Daily chart trong v0.1 để tránh hiểu sai timestamp.

## D33 — Không historical backfill MTF timeline trong v0.1

V0.1 ưu tiên **current-state MTF snapshot**.

Không dựng lại toàn bộ lịch sử Daily bar với Weekly/Monthly state nếu causal expansion contract chưa được nghiệm thu.

Historical multi-timeframe timeline để v0.2 sau khi có dedicated causality tests.

## D34 — Bắt buộc có Timeframe Snapshot Publisher / Consumer contract trước MTF AFL aggregator

Đây là cổng kiến trúc bắt buộc tương tự D38 trước đây.

Lý do:

- upstream Composite/Phase AFL hiện là global-state stack, chưa re-entrant;
- không nên copy/prefix toàn bộ engine ba lần;
- không nên dùng `TimeFrameExpand` trực tiếp lên current higher bar và vô tình look-ahead;
- cần provenance/freshness/version gate.

Trước khi viết MTF Aggregator phải đặc tả và triển khai tối thiểu:

1. **Snapshot Publisher**: chạy canonical Composite stack tại Weekly/Monthly periodicity và xuất authoritative previous-completed snapshot;
2. **Snapshot Key**: ít nhất `Symbol + Timeframe + SourcePeriodKey + SnapshotSchemaVersion`;
3. **Snapshot Consumer**: Daily MTF engine đọc snapshot, kiểm tra period identity + version + validity;
4. **Fail closed**: missing/stale/version mismatch → MTF unavailable, không fallback im lặng.

Transport có thể dùng `StaticVarSet/StaticVarGet` nếu implementation review xác nhận đúng timestamp/period semantics trên AmiBroker 6.20.01; không khóa transport chỉ vì tiện lập trình.

## D35 — Không dùng `expandFirst` cho higher High/Low/Close/Phase state

Nếu bất kỳ implementation path nào dùng TimeFrame functions:

- không dùng future-sensitive `expandFirst` cho higher H/L/C hoặc derived state;
- shift 0 của higher current bar không được dùng làm official context;
- causal publication point phải được test bằng controlled fixture.

## D36 — Điều kiện chuyển sang implementation

Chỉ sau khi chủ dự án phê duyệt D01–D36 mới:

1. khóa đặc tả MTF vào `main`;
2. xây **Timeframe Snapshot Publisher/Consumer contract** theo D34;
3. static audit contract đó;
4. sau khi contract ổn định mới tạo MTF Aggregator branch xếp chồng trên Composite PR #27;
5. triển khai Exploration-first;
6. static conformance audit;
7. giữ `UNTESTED DEVELOPMENT` cho đến AmiBroker 6.20.01 native tests;
8. native tests bắt buộc có look-ahead/partial-week/partial-month/stale snapshot/version mismatch cases.

---

## 3. Phản ví dụ bắt buộc

1. Daily bullish, Weekly bearish, Monthly bearish → không majority-score; `BASE COUNTER TO HIGHER CONTEXT`.
2. Daily bullish, Weekly bullish, Monthly unresolved → không gọi full bullish alignment.
3. Daily bearish, Weekly bullish, Monthly bearish → higher timeframes conflict, không chọn Monthly vì lớn hơn.
4. Weekly có multiple RangeContext → không chọn range mới nhất làm Weekly singleton.
5. Monthly snapshot thiếu → không copy Weekly sang Monthly.
6. Weekly snapshot từ hai tuần trước trong khi previous completed week mới hơn đã tồn tại → STALE, không dùng.
7. Snapshot schema khác version → VERSION_MISMATCH, không dùng.
8. Current week đang tăng mạnh nhưng previous completed Weekly vẫn bearish → official Weekly context vẫn previous completed week.
9. Thứ Sáu cuối phiên nhưng không có session-completion contract → không tự nâng current Weekly bar thành official.
10. Cuối tháng nhưng current month completion chưa được causal contract chứng minh → không dùng current Monthly.
11. Daily Spring confirmed trong Monthly bearish context → giữ cả hai, không xóa Daily event.
12. Weekly No Demand trong Monthly bullish family → evidence conflict, không tự đổi Monthly family.
13. Daily Phase E, Weekly Phase B → không gọi Daily “mạnh hơn” vì phase code cao hơn.
14. Range ID Daily = 5 và Weekly = 5 → không coi là cùng range.
15. Daily range nằm trong Weekly range → không tự bullish/bearish.
16. Weekly event xảy ra tuần trước → không OR vào Daily `CurrentEventMask` của hôm nay.
17. `TimeFrameExpand(..., expandFirst)` khiến weekly high xuất hiện từ đầu tuần → test phải fail.
18. shift 0 current Monthly high/close dùng giữa tháng → test phải fail official-context contract.
19. StaticVar snapshot không có SourcePeriodKey → invalid source.
20. MTF conflict không được biến thành Buy/Sell avoidance rule trong engine.

---

## 4. Bảng quyết định cần chủ dự án phê duyệt

| Mã | Đề xuất | Khuyến nghị |
|---|---|---|
| D01 | v0.1 cố định Daily/Weekly/Monthly | Chấp thuận mạnh |
| D02 | Chưa cho arbitrary timeframe | Chấp thuận |
| D03 | Mỗi timeframe giữ Composite state độc lập | Chấp thuận rất mạnh |
| D04 | MTF chỉ aggregate/compare | Chấp thuận rất mạnh |
| D05 | Higher TF không override lower | Chấp thuận rất mạnh |
| D06 | Lower TF không override higher | Chấp thuận rất mạnh |
| D07 | DirectionalAlignment categorical | Chấp thuận mạnh |
| D08 | Bullish alignment cần cả 3 directional bullish | Chấp thuận mạnh |
| D09 | Bearish alignment đối xứng | Chấp thuận mạnh |
| D10 | Base counter khi W+M cùng phía ngược Daily | Chấp thuận mạnh |
| D11 | Weekly/Monthly trái dấu = higher conflict | Chấp thuận rất mạnh |
| D12 | Mixed/complex giữ ambiguity | Chấp thuận rất mạnh |
| D13 | Unresolved khác insufficient/mixed | Chấp thuận mạnh |
| D14 | PhaseRelationship chỉ diagnostics | Chấp thuận mạnh |
| D15 | Không so RangeContextID xuyên timeframe | Chấp thuận rất mạnh |
| D16 | Không tạo MasterRange | Chấp thuận mạnh |
| D17 | Range nesting chưa quyết định hướng | Chấp thuận mạnh |
| D18 | EventMask tách theo timeframe | Chấp thuận rất mạnh |
| D19 | Higher official = previous completed bar | Chấp thuận rất mạnh |
| D20 | Không tự dùng current Weekly cuối thứ Sáu | Chấp thuận mạnh |
| D21 | Monthly cùng chính sách bảo thủ | Chấp thuận mạnh |
| D22 | Snapshot phải có provenance | Chấp thuận rất mạnh |
| D23 | Freshness hard gate | Chấp thuận rất mạnh |
| D24 | Không stale threshold tùy ý | Chấp thuận mạnh |
| D25 | Không fallback missing timeframe | Chấp thuận rất mạnh |
| D26 | Multiple higher context giữ ambiguity | Chấp thuận rất mạnh |
| D27 | Evidence alignment tách Family alignment | Chấp thuận mạnh |
| D28 | Cross-TF VSA conflict là context, không veto | Chấp thuận rất mạnh |
| D29 | Không weighted timeframe score/majority vote | Chấp thuận rất mạnh |
| D30 | Prefix `WMTF_` | Chấp thuận |
| D31 | Exploration-first | Chấp thuận rất mạnh |
| D32 | Chart v0.1 chỉ context panel | Chấp thuận mạnh |
| D33 | Chưa historical MTF backfill v0.1 | Chấp thuận rất mạnh |
| D34 | Snapshot Publisher/Consumer là prerequisite bắt buộc | Chấp thuận rất mạnh |
| D35 | Cấm future-sensitive higher expansion | Chấp thuận rất mạnh |
| D36 | Quy trình chuyển implementation | Chấp thuận rất mạnh |

---

## 5. Kết luận dự thảo

Multi-Timeframe v0.1 nên được xây như **bộ đối chiếu bối cảnh giữa Daily–Weekly–Monthly**, không phải bộ bỏ phiếu nhiều khung thời gian.

Nguyên tắc cốt lõi:

- higher timeframe cung cấp bức tranh lớn nhưng không ghi đè lower timeframe;
- lower timeframe có thể báo sớm nhưng không tự đổi higher structure;
- agreement và conflict đều là dữ liệu có giá trị;
- không điểm số, không xác suất, không majority vote;
- higher snapshot phải là completed, fresh, version-matched và có provenance;
- fail closed khi snapshot không hợp lệ;
- không historical backfill cho đến khi causal expansion được kiểm thử độc lập;
- D34 là cổng kiến trúc bắt buộc trước khi viết MTF Aggregator AFL.

Nếu D01–D36 được phê duyệt, bước kế tiếp là khóa đặc tả này rồi xây **Timeframe Snapshot Publisher / Consumer contract** trước khi triển khai MTF Aggregator.