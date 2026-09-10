# Wyckoff VSA Composite Indicator — Dự thảo đặc tả v0.1

**Trạng thái:** `DRAFT FOR OWNER APPROVAL` — chưa khóa, chưa phải tiêu chí nghiệm thu, chưa có AFL triển khai.

## 1. Mục tiêu

Composite Indicator là lớp tổng hợp trình bày nằm sau Phase / Context:

`Core → Candidate → Structure/Location → Confirmation → Event → Structural Sequence → Phase/Context → Composite Indicator → Chart/Exploration`

Nhiệm vụ của Composite v0.1 là biến public outputs của các lớp trước thành **một giao diện đọc trạng thái thống nhất, có thể kiểm toán và không làm mất ngữ cảnh**, để người dùng có thể nhìn nhanh:

1. hiện có bao nhiêu RangeContext;
2. thị trường đang ở pha cấu trúc nào;
3. family hypothesis hiện tại là gì;
4. bối cảnh thiên về strength, weakness, unresolved hay conflicting;
5. bằng chứng hiện tại có đồng thuận với hypothesis hay không;
6. các event quan trọng nào đang xuất hiện / vừa được xác nhận tại thanh hiện tại;
7. Primary Range nào đang được theo dõi;
8. trạng thái nào là provisional, trạng thái nào là completed-bar output.

Composite v0.1 **không tạo thêm một phương pháp Wyckoff mới, không tạo weighted score, không tạo xác suất và không phát Buy/Sell/Short/Cover**.

---

## 2. Cơ sở nghiên cứu

### 2.1. Nguồn phương pháp Wyckoff

- Wyckoff Analytics — Wyckoff Method: https://www.wyckoffanalytics.com/wyckoff-method/
- Wyckoff Analytics — Accumulation: The Bigger Picture: https://www.wyckoffanalytics.com/accumulation-the-bigger-picture/
- StockCharts / Wyckoff educational materials đã được dùng khi xây Phase / Context.

Các điểm có ảnh hưởng trực tiếp tới Composite:

1. Wyckoff yêu cầu đánh giá **vị trí hiện tại của thị trường**, market structure, supply/demand và trading-range context trước khi đi đến quyết định hành động.
2. Supply/demand không được suy từ volume đơn lẻ; price, volume và diễn biến theo thời gian phải được đọc cùng nhau.
3. Một trading range được đọc qua **chuỗi phase + event**, không phải qua một thanh đơn lẻ.
4. Spring, Test, SOS, LPS, Upthrust, SOW, LPSY có ý nghĩa khác nhau tùy background và vị trí trong range.
5. Wyckoff dùng nhiều bằng chứng để đánh giá readiness; không có cơ sở để biến toàn bộ phương pháp thành một điểm tổng hợp 0–100 tùy ý.

### 2.2. Nguồn VSA

- TradeGuider — VSA training / Importance of Background: https://tradeguider.com/rt/index.asp
- TradeGuider — VSA educational materials về No Demand / No Supply và background.

Điểm thiết kế chính:

- No Demand trong strength background không được mặc định là bearish.
- No Supply trong weakness background không được mặc định là bullish.
- Vì vậy Composite không được lấy raw Candidate/Confirmation rồi gán hướng độc lập với Phase/Context.

### 2.3. Nguồn kỹ thuật AmiBroker

AmiBroker 6.20 hỗ trợ các primitive cần thiết cho presentation layer:

- `AddColumn` cho exploration numeric output;
- `AddMultiTextColumn` cho bar-by-bar categorical text;
- `Plot`, `PlotShapes`, `PlotText` cho chart presentation.

Các hàm này chỉ là công cụ trình bày; đặc tả v0.1 không khóa màu sắc hoặc mỹ thuật biểu đồ trước khi user review chart prototype.

### 2.4. Phân biệt “Composite Indicator” và “Composite Man”

Trong Wyckoff, **Composite Man** là mô hình tư duy dùng để diễn giải hành vi của các large operators. `Composite Indicator` trong dự án này chỉ là **tên kỹ thuật cho lớp tổng hợp output**.

Hai khái niệm không đồng nhất. Composite Indicator không được tuyên bố rằng nó “phát hiện Composite Man” hoặc suy ra động cơ của tổ chức từ dữ liệu một cách chắc chắn.

---

## 3. Nguồn dữ liệu chuẩn của Composite

Composite v0.1 phải ưu tiên public downstream facade của Phase / Context:

`afl/WyckoffVSA_PhaseContext_ConsumerFacade_v0.1.afl`

Mốc phát triển hiện tại:

- Phase / Context spec: PR #22, merge `3fe48b06a635cf105472b27d296fabeee5589488`;
- SOW/LPSY spec: PR #23, merge `7670532a230eb051cf5d362be092e2d81283fb92`;
- Phase / Context implementation: PR #25, hiện `SPEC-ALIGNED / UNTESTED DEVELOPMENT`.

Composite có thể consume thêm public event fields khi cần **hiển thị event hiện tại**, nhưng không được duplicate event formulas.

---

# QUYẾT ĐỊNH THIẾT KẾ D01–D32

## D01 — Composite là projection layer, không phải interpretation engine mới

Composite chỉ:

- đọc public upstream states;
- chuẩn hóa thành interface dễ dùng;
- ánh xạ deterministic giữa các enum đã được khóa;
- trình bày chart/exploration.

Nếu một kết luận mới cần logic causal hoặc knowledge mà upstream chưa công bố, logic đó phải được bổ sung vào đúng upstream engine qua đặc tả riêng; **không giấu logic mới trong Composite**.

## D02 — Không weighted score

Không có:

- Wyckoff Score 0–100;
- VSA Score 0–100;
- confidence %;
- probability %;
- cộng trọng số tùy ý giữa Spring, SOS, No Supply, RVOL, Phase.

Lý do: các bằng chứng là phụ thuộc bối cảnh và không có calibration thống kê được khóa cho phép biến chúng thành xác suất.

## D03 — Không trading signal

Composite v0.1 không tạo:

- `Buy`;
- `Sell`;
- `Short`;
- `Cover`;
- `PositionSize`;
- stop;
- target;
- entry price;
- risk/reward;
- “safe entry”.

Composite chỉ mô tả **state of evidence and structure**.

## D04 — Hai RangeContext không được ép thành một

Dựa trên Phase ConsumerFacade:

- `CurrentRangeContextCount = 0`: không có active public range context;
- `=1`: được phép tạo singleton summary;
- `>1`: `MULTIPLE RANGE CONTEXTS`.

Khi có hai context, Composite **không chọn winner** dựa trên recency, phase cao hơn, bullish/bearish direction hay range width.

Phải giữ cả lower-derived và upper-derived channels để người dùng kiểm tra.

## D05 — ContextMultiplicityCode

Đề xuất enum:

- 0 = `NO ACTIVE RANGE CONTEXT`;
- 1 = `SINGLE ACTIVE RANGE CONTEXT`;
- 2 = `MULTIPLE ACTIVE RANGE CONTEXTS`.

Đây là trạng thái topology, không phải bullish/bearish score.

## D06 — CompositeDirectionalContextCode

Chỉ tạo directional context khi mapping từ **FamilyHypothesis** đã có.

Đề xuất:

- 0 = `INSUFFICIENT`;
- 1 = `UNRESOLVED`;
- 2 = `BULLISH HYPOTHESIS`;
- 3 = `BEARISH HYPOTHESIS`;
- 4 = `MIXED / CONFLICTING`.

Mapping:

- `ACCUMULATION-HYPOTHESIS` → bullish;
- `REACCUMULATION-HYPOTHESIS` → bullish;
- `DISTRIBUTION-HYPOTHESIS` → bearish;
- `REDISTRIBUTION-HYPOTHESIS` → bearish;
- unresolved lower/upper range → unresolved;
- mixed/conflicting → mixed;
- insufficient → insufficient.

Composite không được tự nâng unresolved family thành bullish/bearish dựa trên một event đơn lẻ.

## D07 — PhaseState giữ nguyên semantic upstream

Composite phải xuất nguyên `PhaseStateCode` / text tương ứng:

- insufficient;
- Phase A-like;
- Phase B-like;
- Phase C candidate;
- Phase C-like;
- Phase D-like;
- Phase E-like;
- invalidated/superseded.

Không đổi Phase B thành “Accumulation”, không đổi Phase C thành “Entry Zone”, không đổi Phase E thành “Buy”.

## D08 — StructuralDevelopmentCode chỉ là alias trình bày

Nếu cần một output ngắn cho chart panel, được phép ánh xạ PhaseState thành:

- 0 `INSUFFICIENT`;
- 1 `STOPPING / RANGE FORMATION` — Phase A;
- 2 `RANGE DEVELOPMENT` — Phase B;
- 3 `FINAL TEST UNDER EVALUATION` — Phase C candidate;
- 4 `FINAL TEST + FOLLOW-THROUGH` — Phase C-like;
- 5 `DIRECTIONAL DOMINANCE` — Phase D-like;
- 6 `RANGE EXIT / TREND EXPANSION` — Phase E-like;
- 7 `TERMINAL / SUPERSEDED`.

Đây là **presentation alias** của PhaseState, không phải state machine mới.

## D09 — EvidenceBalanceCode

Composite được phép normalize upstream bullish/bearish evidence thành:

- 0 = `INSUFFICIENT EVIDENCE`;
- 1 = `BULLISH EVIDENCE ONLY`;
- 2 = `BEARISH EVIDENCE ONLY`;
- 3 = `MIXED EVIDENCE`.

Không cộng số lượng event để quyết định strength của evidence.

## D10 — HypothesisAlignmentCode

Để người dùng biết evidence có đồng thuận với current family hypothesis hay không, đề xuất deterministic enum:

- 0 = `NOT APPLICABLE / INSUFFICIENT`;
- 1 = `ALIGNED`;
- 2 = `NOT YET ALIGNED`;
- 3 = `CONFLICTING`.

Quy tắc:

- bullish hypothesis + bullish-only evidence → ALIGNED;
- bearish hypothesis + bearish-only evidence → ALIGNED;
- bullish hypothesis + bearish-only evidence → CONFLICTING;
- bearish hypothesis + bullish-only evidence → CONFLICTING;
- bất kỳ hypothesis directional nào + mixed evidence → CONFLICTING;
- directional hypothesis + insufficient evidence → NOT YET ALIGNED;
- unresolved/mixed/insufficient family → NOT APPLICABLE.

Không dùng enum này như confidence score.

## D11 — Không biến PhaseState thành “độ tin cậy”

Phase D/E có mức trưởng thành cấu trúc cao hơn Phase A/B, nhưng **không đồng nghĩa xác suất thành công cao hơn một tỷ lệ cố định**.

Tên field phải là `StructuralDevelopment`, không phải `Confidence`.

## D12 — CurrentEvent channels phải độc lập

Composite có thể hiển thị event đã được upstream công bố tại current bar:

- Supply Test confirmed;
- Spring/Shakeout confirmed;
- Upthrust confirmed;
- SOS-like;
- LPS-like confirmed;
- SOW-like;
- LPSY-like;
- No Supply confirmed;
- No Demand confirmed;
- bullish absorption response;
- bearish absorption response.

Không dùng một `PrimaryEvent` duy nhất để xóa overlap.

## D13 — EventMask chỉ là kỹ thuật, không phải ranking

Nếu implementation cần compact numeric field, được phép tạo bitmask:

- bit 1: Supply Test;
- bit 2: Spring/Shakeout;
- bit 4: Upthrust;
- bit 8: SOS-like;
- bit 16: LPS-like;
- bit 32: SOW-like;
- bit 64: LPSY-like;
- bit 128: No Supply;
- bit 256: No Demand;
- bit 512: bullish absorption response;
- bit 1024: bearish absorption response.

Bitmask chỉ phục vụ transport/audit. UI phải có individual flags hoặc text rõ nghĩa.

## D14 — Không dùng arbitrary recency window

V0.1 không định nghĩa “event gần đây” bằng 3/5/10/20 bars tùy ý để tạo bias.

Có thể hiển thị:

- event xuất hiện/known-at tại current bar;
- cumulative event counts từ active RangeContext do Phase Engine đã công bố;
- BarsSince nếu upstream có causal field rõ ràng.

Không tự thêm hidden lookback window trong Composite.

## D15 — Active range boundaries được hiển thị, không tính lại

Composite đọc:

- PrimaryRangeLow;
- PrimaryRangeHigh;
- PrimaryRangeWidth;
- RangeContextID;
- RangeAgeBars;
- range status.

Không tính lại support/resistance từ highest/lowest, ZigZag, Peak/Trough hoặc latest pivot.

## D16 — RangePosition là descriptor

Nếu upstream RangePosition valid, Composite có thể hiển thị:

- dưới range;
- trong range;
- trên range;

hoặc numeric RangePosition.

Không dùng ngưỡng 0.25/0.50/0.75 để tự sinh bullish/bearish signal trong v0.1.

## D17 — Hypothesis revision phải hiển thị được

Nếu family hypothesis thay đổi, Composite phải giữ:

- current FamilyHypothesis;
- HypothesisRevisionCode;
- HypothesisKnownAt;
- mixed/conflict reason nếu có.

UI không được tạo cảm giác hypothesis mới đã tồn tại từ trước thời điểm KnownAt.

## D18 — Superseded / invalidated phải được nhìn thấy

Nếu active context bị superseded hoặc invalidated:

- historical phase/event vẫn giữ;
- current panel phải thể hiện context terminal/superseded;
- không nối boundary của range cũ sang range mới như cùng một context.

## D19 — Completed bar là output chính thức

Scope v0.1:

- Daily completed bars là official research scope;
- forming bar chỉ provisional;
- forming bar không được khóa một phase/family mới thành final trong Composite nếu upstream chưa final;
- UI phải có `ProvisionalFlag` hoặc semantic tương đương.

## D20 — Composite không sửa repaint semantics

Composite phải phân biệt:

- algorithmic causal state;
- source/data revision;
- forming-bar change.

Nếu upstream history thay do data vendor revision, Composite không được gắn nhãn đó là repaint logic.

## D21 — Exploration là giao diện nghiệm thu đầu tiên

Trước chart mỹ thuật, Composite v0.1 phải có Exploration output đủ để kiểm toán.

Nhóm cột tối thiểu:

### Identity
- Symbol;
- DateTime;
- Completed/Provisional status.

### Context
- ContextMultiplicityCode;
- singleton RangeContextID nếu đúng một context;
- lower/upper RangeContextID nếu multiple;
- RangeStatus;
- PrimaryRangeLow/High;
- RangeAgeBars.

### Structure
- PriorTrendContext;
- PhaseState;
- StructuralDevelopment;
- FamilyHypothesis;
- CompositeDirectionalContext;
- HypothesisRevision.

### Evidence
- EvidenceBalance;
- HypothesisAlignment;
- mixed/conflicting reason;
- SOS/LPS/SOW/LPSY counts;
- NoSupplyAfterStrength / NoDemandAfterWeakness counts;
- absorption response counts.

### Current events
- individual current-event flags;
- optional EventMask.

## D22 — Chart v0.1 ưu tiên ít nhiễu

Chart overlay mặc định chỉ nên hiển thị:

1. PrimaryRangeLow/High của active context;
2. current Phase/Family/Directional Context trong title/panel;
3. event markers quan trọng tại đúng origin/KnownAt semantic;
4. provisional warning nếu thanh cuối chưa hoàn tất.

Không vẽ mọi diagnostic field lên chart.

## D23 — Không tô lại candle như thể đó là raw price information

Composite không nên mặc định đổi toàn bộ màu nến thành bullish/bearish theo family hypothesis vì việc đó có thể làm người dùng khó đọc raw OHLC/VSA.

Nếu sau này user muốn regime ribbon/background band, đó là presentation option, không thay raw candle semantics.

## D24 — Event label phải giữ origin-time và known-at-time

Ví dụ:

- Spring origin xảy ra tại k nhưng confirmed/known-at tại k+1;
- confirmed pivot-derived LPSY chỉ KnownAt tại pivot confirmation bar.

Chart không được vẽ nhãn confirmed lên origin bar theo cách làm người dùng tưởng rằng hệ thống đã biết điều đó tại thời điểm origin.

Có thể:

- đánh dấu origin morphology riêng;
- đánh dấu confirmation/KnownAt riêng;
- hoặc chỉ vẽ confirmed marker tại KnownAt và giữ origin coordinates trong Exploration.

## D25 — Không collision winner-takes-all cho marker

Nếu nhiều event cùng thanh:

- không xóa event khác;
- implementation phải dùng marker stacking, y-offset hoặc compact multi-event label.

Thứ tự hiển thị là vấn đề layout, không phải độ ưu tiên phương pháp.

## D26 — Text enum phải ổn định và có numeric code

Mỗi composite categorical output cần:

- numeric code ổn định cho test/export;
- human-readable text cho Exploration/chart.

Không test bằng string duy nhất nếu numeric source code có thể kiểm toán trực tiếp.

## D27 — Single-timeframe, single-symbol core scope

Composite v0.1 không tự thêm:

- Multi-Timeframe agreement;
- market index context;
- sector relative strength;
- cross-sectional ranking;
- breadth;
- watchlist score.

Đó là các layer sau: Multi-Timeframe / Market Scanner / Relative Strength context.

## D28 — Không gọi output là “tín hiệu mua/bán” trong Scanner tương lai

Composite outputs được thiết kế để scanner tương lai có thể lọc:

- Phase;
- family;
- directional context;
- evidence alignment;
- current event.

Nhưng v0.1 chưa định nghĩa ranking hay order of preference.

## D29 — Public Composite interface đề xuất

Prefix đề xuất: `WCI_`.

Các field lõi:

- `WCI_ContextMultiplicityCode`;
- `WCI_ContextAmbiguous`;
- `WCI_CurrentRangeContextID`;
- `WCI_PhaseStateCode`;
- `WCI_StructuralDevelopmentCode`;
- `WCI_FamilyHypothesisCode`;
- `WCI_DirectionalContextCode`;
- `WCI_EvidenceBalanceCode`;
- `WCI_HypothesisAlignmentCode`;
- `WCI_HypothesisRevisionCode`;
- `WCI_ProvisionalFlag`;
- `WCI_CurrentEventMask`;
- individual `WCI_Current...Event` flags;
- range identity/boundary fields;
- lower/upper channel diagnostics khi multiple contexts.

## D30 — Singleton fields phải Null/insufficient khi multiple contexts

Khi `ContextMultiplicityCode==2`:

- `WCI_CurrentRangeContextID = Null`;
- singleton `WCI_PhaseStateCode` không được chọn một context;
- singleton directional state = `MIXED / CONFLICTING` hoặc dedicated ambiguous code;
- lower/upper fields vẫn phải được export riêng.

Điều này ngăn downstream scanner hiểu nhầm một context thành toàn bộ thị trường.

## D31 — Không duplicate upstream labels bằng công thức mới

Composite không được tái tính:

- No Demand / No Supply;
- Supply Test;
- Spring/Shakeout;
- Upthrust;
- SOS/LPS;
- SOW/LPSY;
- stopping volume / absorption;
- pivot / support / resistance;
- Phase A–E;
- FamilyHypothesis.

Composite chỉ consume public contracts.

## D32 — Điều kiện chuyển sang AFL implementation

Chỉ sau khi chủ dự án phê duyệt D01–D32 mới:

1. khóa đặc tả Composite vào `main`;
2. xác nhận PR #25 ConsumerFacade vẫn là public source/interface phù hợp;
3. nếu Phase interface thay đổi, cập nhật đặc tả trước khi viết Composite AFL;
4. tạo nhánh Composite implementation xếp chồng trên Phase/Context head;
5. viết Exploration-first implementation;
6. static conformance audit;
7. giữ `UNTESTED DEVELOPMENT` cho đến chiến dịch AmiBroker 6.20.01 tổng thể.

---

## 4. Phản ví dụ bắt buộc

1. Phase B + một No Demand → không được Composite gọi bearish.
2. Phase B + một No Supply → không được Composite gọi bullish.
3. Accumulation-hypothesis nhưng current evidence bearish-only → directional hypothesis vẫn bullish, Alignment = conflicting; không âm thầm đổi family.
4. Distribution-hypothesis nhưng bullish evidence mới xuất hiện → giữ family theo upstream và báo conflicting cho đến khi Phase Engine revision.
5. Unresolved lower range + Spring confirmed → vẫn chưa được Composite tự gọi Accumulation.
6. Unresolved upper range + Upthrust confirmed → vẫn chưa tự gọi Distribution.
7. Phase C candidate → không gọi Phase C confirmed và không gọi entry.
8. Phase E-like → không tự tạo Buy/Sell.
9. Hai RangeContext cùng active → không chọn context mới hơn làm winner.
10. Hai event cùng một bar → không xóa event nào.
11. Confirmed event KnownAt k+1 → không vẽ confirmed marker lùi về k như historical certainty.
12. Range bị superseded → không kéo boundary range cũ tiếp tục sang context mới.
13. Forming bar tạo breakout → Composite chỉ provisional nếu upstream chưa final.
14. Source revision thay lịch sử → không kết luận algorithmic repaint nếu causal logic không đổi.
15. High RVOL đơn lẻ → không tạo bullish/bearish CompositeDirectionalContext.
16. RangePosition ở 0.9 → không tự gọi bullish.
17. RangePosition ở 0.1 → không tự gọi bearish.
18. LPSY + No Demand overlap → giữ hai evidence channels.
19. Spring + ST overlap → giữ nguồn riêng, không deduplicate thành một event.
20. Multiple-context state → singleton ID phải Null/ambiguous.

---

## 5. Bảng quyết định cần chủ dự án phê duyệt

| Mã | Đề xuất | Khuyến nghị |
|---|---|---|
| D01 | Composite chỉ projection/aggregation, không logic phương pháp mới | Chấp thuận rất mạnh |
| D02 | Không weighted score/confidence/probability | Chấp thuận rất mạnh |
| D03 | Không trading signal | Chấp thuận rất mạnh |
| D04 | Không ép hai RangeContext thành một | Chấp thuận rất mạnh |
| D05 | ContextMultiplicityCode 0–2 | Chấp thuận |
| D06 | DirectionalContext deterministic từ FamilyHypothesis | Chấp thuận mạnh |
| D07 | Giữ nguyên PhaseState semantics | Chấp thuận rất mạnh |
| D08 | StructuralDevelopment chỉ alias trình bày | Chấp thuận |
| D09 | EvidenceBalance categorical | Chấp thuận mạnh |
| D10 | HypothesisAlignment categorical, không confidence | Chấp thuận mạnh |
| D11 | Không coi phase maturity là xác suất | Chấp thuận rất mạnh |
| D12 | Current event channels độc lập | Chấp thuận mạnh |
| D13 | EventMask chỉ transport/audit | Chấp thuận |
| D14 | Không arbitrary recency window | Chấp thuận mạnh |
| D15 | Range boundaries consume upstream | Chấp thuận rất mạnh |
| D16 | RangePosition chỉ descriptor | Chấp thuận mạnh |
| D17 | Hiển thị hypothesis revision | Chấp thuận mạnh |
| D18 | Hiển thị superseded/invalidated | Chấp thuận mạnh |
| D19 | Completed bar official, forming provisional | Chấp thuận rất mạnh |
| D20 | Phân biệt source revision / repaint / forming update | Chấp thuận mạnh |
| D21 | Exploration-first acceptance interface | Chấp thuận rất mạnh |
| D22 | Chart mặc định ít nhiễu | Chấp thuận mạnh |
| D23 | Không mặc định recolor raw candles theo bias | Chấp thuận |
| D24 | Tách origin-time / known-at-time trên chart | Chấp thuận rất mạnh |
| D25 | Không winner-takes-all khi event overlap | Chấp thuận mạnh |
| D26 | Numeric enum + human text | Chấp thuận mạnh |
| D27 | Single-symbol/single-timeframe scope | Chấp thuận rất mạnh |
| D28 | Scanner tương lai consume state, không biến thành signal | Chấp thuận mạnh |
| D29 | Public interface prefix `WCI_` | Chấp thuận |
| D30 | Singleton fields Null/ambiguous khi multiple contexts | Chấp thuận rất mạnh |
| D31 | Không duplicate upstream formulas | Chấp thuận rất mạnh |
| D32 | Phê duyệt đặc tả trước AFL; implementation stack trên Phase head | Chấp thuận rất mạnh |

---

## 6. Kết luận dự thảo

Composite Indicator v0.1 nên là **“bảng điều khiển trạng thái Wyckoff–VSA”**, không phải một chỉ báo điểm số thần kỳ.

Giá trị của nó nằm ở việc gom đúng các lớp đã xây dựng — measurement, event, sequence, phase và evidence — thành một giao diện thống nhất nhưng vẫn giữ:

- causality;
- ambiguity;
- overlap;
- provenance;
- completed-bar semantics;
- ranh giới giữa measurement, interpretation và trading decision.

Nếu D01–D32 được phê duyệt, bước tiếp theo là khóa tài liệu này rồi viết Composite AFL theo hướng **Exploration-first → public interface → chart overlay** trên đầu PR #25.