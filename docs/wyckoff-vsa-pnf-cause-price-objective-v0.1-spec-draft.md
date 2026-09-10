# Wyckoff VSA P&F Cause / Price Objective Engine — Dự thảo đặc tả v0.1

**Trạng thái:** `DRAFT FOR OWNER APPROVAL` — chỉ đặc tả, chưa có AFL triển khai, chưa phải nghiệm thu native.

## 1. Mục tiêu

P&F Cause / Price Objective Engine v0.1 là lớp đo **Cause → Price Objective** theo Wyckoff bằng horizontal Point-and-Figure (P&F) count, nằm sau các lớp đã có:

`Core → Candidate → Structure/Location → Confirmation → Event → Structural Sequence → Phase/Context → Composite → P&F Cause / Price Objective`

và cung cấp output cho:

`Market Scanner → future Nine Tests / Risk-Reward / Trade Planning`.

Engine này **không quyết định Accumulation/Distribution**, không thay thế Phase/VSA, không phát Buy/Sell và không coi price objective là điểm đảo chiều chắc chắn.

---

## 2. Nghiên cứu phương pháp — kết luận nguồn

### 2.1. Law of Cause and Effect

Nguồn chính:
- Wyckoff Analytics — Wyckoff Method: https://www.wyckoffanalytics.com/wyckoff-method/
- Wyckoff Stock Market Institute — Step Three of the Wyckoff Method: https://wyckoffstockmarketinstitute.com/25/the-wyckoff-method-step-3/
- Wyckoff Stock Market Institute — Figure Charts, Counts and Counting: https://wyckoffsmi.com/figure-charts-counts-and-counting/

Wyckoff dùng horizontal figure/P&F count để đo Cause hình thành trong trading range và ước lượng Effect là biên độ của move sau đó. Figure chart chỉ là công cụ projection; chất lượng supply/demand vẫn phải đọc từ price/volume/bar-chart context.

### 2.2. Count từ phải sang trái và đếm toàn bộ horizontal divisions

Wyckoff Stock Market Institute nêu rõ count được lấy từ **right side về left side** của horizontal formation và **đếm mọi horizontal division**, kể cả division không có posting. Vì vậy v0.1 không được triển khai kiểu “chỉ đếm các cột đang chứa X/O đúng tại count-line row”.

Đây là một điểm rất quan trọng để tránh nhầm với một số cách diễn giải P&F hiện đại khác.

### 2.3. Bullish count line: LPS sau strength; Spring/Test có thể là count point bảo thủ

Wyckoff/WSMI hướng dẫn: nếu kỳ vọng advance, xác định Sign of Strength rồi Last Point of Support; projection được đo từ LPS. LPS có thể là:
- test của Spring;
- low của Back-Up sau Jump/SOS;
- low của correction sau một aggressive rally trong range.

Nếu chưa có test rõ, Spring low có thể được dùng như một count point bảo thủ. Nguyên tắc là **most conservative count first**.

### 2.4. Bearish count line: LPSY; Upthrust có thể là count point bảo thủ khi thiếu test

Đối xứng phía Distribution: count thường bắt đầu từ LPSY về BC/PSY. Bruce Fraser mô tả horizontal Distribution count từ LPSY đến BC hoặc PSY; count line đặt tại khu vực đỉnh LPSY. Khi chưa có test/LPSY rõ, Upthrust có thể đóng vai trò count point bảo thủ theo logic WSMI.

Nguồn bổ sung:
- Secrets of Point and Figure Distribution: https://articles.stockcharts.com/article/articles-wyckoff-2016-01-secrets-of-point-and-figure-distribution/

### 2.5. P&F count phases không phải Wyckoff Phase A–E

Wyckoff Analytics Count Guide nêu rõ các **P&F phases dùng để cộng count từng phần không đồng nhất với Phase A–E** của trading-range analysis.

Khi up-count được chia phase, các reaction lows có thể đánh dấu hết một phase; với down-count, rally highs có thể đánh dấu hết một phase. Phải cộng **trọn phase**, không lấy một phần phase tùy ý.

### 2.6. Conservative first, rồi mới mở rộng count

Count Guide hướng dẫn lấy count bảo thủ trước, sau đó đi xa hơn về trái khi move phát triển và khi các phase hoàn chỉnh được xác nhận. Vì vậy một range có thể có nhiều count segments/objectives hợp lệ đồng thời; không nên cưỡng ép chỉ một “final target”.

### 2.7. Objective range, không phải một con số duy nhất

WSMI Step Three:
- bullish: nếu count line không nằm đúng đáy range, objective range được tạo bằng cách cộng count vào count-line level và vào lowest level của trading range;
- bearish: nếu count line không nằm đúng đỉnh range, objective range được tạo bằng cách trừ count khỏi count-line level và khỏi highest level của trading range.

Wyckoff Analytics còn dùng halfway level giữa range extreme và count line trong một số longer-term projections như một điểm trung gian tham khảo.

### 2.8. Price objective là “stop, look and listen”, không phải reversal point

Wyckoff Analytics nhấn mạnh objective chỉ là nơi cần tăng mức quan sát price/volume. Giá có thể dừng, tích lũy/phân phối lại, vượt mục tiêu hoặc không tới mục tiêu. Vì vậy Engine không được auto-flip directional context chỉ vì target được chạm.

### 2.9. Stepping-stone confirming counts

Trong trend lớn, các reaccumulation/redistribution range nhỏ có thể sinh count mới và objective “nest” gần objective của count lớn. Wyckoff gọi đây là stepping-stone confirming counts. Đây là quan hệ giữa nhiều count độc lập, không phải phép cộng score/confidence.

### 2.10. Không có universal minimum Cause

WSMI nêu rằng Wyckoff không cho một ngưỡng universal về count size. Count phải phù hợp với horizon/campaign. Vì vậy v0.1 không được hard-code “ít nhất N cột mới hợp lệ” như một Wyckoff rule, ngoài các yêu cầu tối thiểu thuần kỹ thuật để construction/count có nghĩa.

### 2.11. P&F scale/reversal có nhiều biến thể

Nguồn:
- Intro to Point and Figure Construction: https://articles.stockcharts.com/article/articles-wyckoff-2016-01-intro-to-point-and-figure-construction/
- ChartSchool P&F Scaling and Timeframes: https://chartschool.stockcharts.com/table-of-contents/chart-analysis/point-and-figure-charts/point-and-figure-basics/point-and-figure-scaling-and-timeframes

Wyckoff thực hành hiện đại dùng cả 1-box và 3-box reversal, cùng fixed/user-defined, traditional, ATR, percentage scaling tùy mục tiêu. Tuy nhiên dynamic ATR scaling có rủi ro làm historical P&F representation thay đổi khi ATR thay đổi. Với hệ thống cần causal/reproducible audit, v0.1 phải khóa scale explicit và không silent-rescale.

### 2.12. One-box reversal có quy tắc riêng

Bruce Fraser lưu ý với 1-box reversal, một column cần tối thiểu hai entries trước khi một reversal column mới được mở. Quy tắc này phải được triển khai chính xác trong P&F Construction Kernel nếu hỗ trợ 1-box.

### 2.13. Market objective harmony có giá trị nhưng không phải guarantee

WSMI Step Three lưu ý market và individual issue cùng có objective theo một hướng là trạng thái thuận lợi hơn. Tuy nhiên stock vẫn có thể đạt objective khi market không đồng hướng. Đây là diagnostic cho future selection/risk layer, không phải hard override của objective stock.

---

# QUYẾT ĐỊNH THIẾT KẾ PFO01–PFO48

## PFO01 — Vai trò engine

P&F Engine chỉ:
- dựng/consume P&F construction;
- ánh xạ frozen RangeContext + Wyckoff event anchors sang P&F columns;
- đo horizontal cause;
- tạo objective range;
- theo dõi lifecycle của objective;
- xuất audit/provenance.

Không tự phân loại Accumulation/Distribution nếu Phase/Context chưa kết luận.

## PFO02 — Không dùng P&F thay VSA/Phase

P&F objective không được:
- tạo FamilyHypothesis;
- ghi đè EvidenceBalance;
- tự xác nhận Spring/SOS/LPS/SOW/LPSY;
- đổi Phase;
- thay thế price/volume analysis.

P&F là projection layer.

## PFO03 — Canonical RangeContext là nguồn cấu trúc

Mỗi count phải gắn với một canonical frozen RangeContext đã được Phase/Composite công bố:
- `RangeContextID`;
- lower/upper source channel;
- PrimaryRangeLow/High;
- FamilyHypothesis;
- PhaseState;
- relevant event provenance.

Không tự dựng trading range thứ hai bên trong P&F Engine.

## PFO04 — Multiple RangeContexts được giữ độc lập

Nếu cùng lúc có nhiều RangeContext:
- engine được phép duy trì nhiều count hypotheses;
- mỗi count phải có RangeContextID riêng;
- không chọn một winner tùy ý;
- downstream Scanner/Review quyết định ambiguity.

## PFO05 — Directional objective chỉ khi family/directional context đủ

Nếu FamilyHypothesis còn unresolved/mixed:
- có thể xuất `CAUSE GEOMETRY AVAILABLE` nếu P&F horizontal formation đo được;
- **không** xuất official bullish/bearish objective như thể hướng đã biết.

Bullish objective chỉ khi Phase/Family cho phép accumulation/reaccumulation hypothesis; bearish đối xứng distribution/redistribution.

## PFO06 — P&F Count Phase tách hoàn toàn Phase A–E

Tên internal phải dùng:
- `CountSegment`;
- `CountPhaseOrdinal`;
- `CountPhaseBoundary`.

Cấm đặt `P&F Phase A/B/C...` để tránh nhầm với Wyckoff Phase A–E.

## PFO07 — Scope v0.1: Daily source, completed-bar causal

Official v0.1:
- source OHLC Daily;
- historical reconstruction causal từ trái sang phải;
- thanh cuối forming/provisional không tạo official finalized count revision;
- không intraday/Weekly/Monthly P&F engine trong v0.1.

Các timeframe khác để version sau.

## PFO08 — Official scaling v0.1: explicit fixed absolute box size

V0.1 chỉ khóa production path:
`USER_DEFINED_FIXED_ABSOLUTE_BOX_SIZE`.

`BoxSize > 0`, explicit trong deployment/profile và xuất provenance.

Không dùng bảng Traditional USD-centric làm default cho chứng khoán Việt Nam.

## PFO09 — Không auto ATR/percentage rescale trong v0.1

ATR scale, percentage scale và traditional scale được ghi nhận là kỹ thuật P&F hợp lệ ngoài dự án, nhưng **defer** khỏi v0.1 production path.

Lý do kiến trúc: tránh historical construction thay đổi do dynamic scaling hoặc price-regime table thay đổi.

## PFO10 — Reversal modes v0.1

Construction Kernel v0.1 phải hỗ trợ explicit:
- `1-box reversal`;
- `3-box reversal`.

Không mặc định một loại là “Wyckoff chuẩn duy nhất”.

`ReversalBoxes` phải được lưu trong every count provenance.

## PFO11 — 1-box two-entry rule bắt buộc

Nếu `ReversalBoxes=1`, construction phải giữ quy tắc minimum two entries/boxes trong current column trước khi mở reversal column theo Wyckoff construction reference.

Không bỏ qua vì sẽ làm inflated horizontal column count.

## PFO12 — Price input method phải được khóa ở Construction Kernel

High-Low và Close là hai phương pháp P&F khác nhau và có thể cho column history khác nhau.

V0.1 Cause Engine không được tự lựa chọn ngầm.

Đề xuất cho Construction Kernel review:
- official primary method = deterministic `HIGH_LOW`;
- `CLOSE` có thể là secondary comparison mode;
- output luôn ghi `PriceMethodCode`.

Quyết định cuối cùng được khóa ở prerequisite PFO46.

## PFO13 — High-Low precedence nếu được chọn

Nếu `HIGH_LOW` được khóa ở Construction Kernel, phải theo deterministic P&F precedence:
- X-column: thử extend bằng High trước; nếu extend thành công thì bỏ qua Low; nếu không extend mới xét Low cho reversal;
- O-column: thử extend bằng Low trước; nếu extend thành công thì bỏ qua High; nếu không extend mới xét High cho reversal.

Không suy đoán intrabar path trái quy tắc.

## PFO14 — Grid / box arithmetic deterministic

P&F Construction phải có:
- fixed `GridOrigin`;
- deterministic price-to-box mapping;
- exact/inclusive boundary semantics;
- floating-point audit tolerance chỉ cho kiểm tra số học, không thay đổi economic rule.

Không dùng round-to-display-decimals để quyết định box.

## PFO15 — Adjustment basis phải explicit

P&F count rất nhạy với historical price scale. Vì vậy phải xuất:
- adjusted/unadjusted declaration;
- `AdjustmentBasisStatus`;
- box-size unit;
- source revision status.

Nếu adjustment basis chưa verified-compatible, objective chỉ được `RESEARCH / DATA-GATED`, không production-valid.

## PFO16 — Construction phải causal, không look-ahead

P&F columns được xây sequential từ data đã biết đến bar hiện tại.

Cấm:
- dựng column bằng future high/low;
- backfill event labels vào thời điểm chưa biết;
- sửa historical KnownAt chỉ vì count được xác nhận sau này.

## PFO17 — Source-bar ↔ P&F-column provenance bắt buộc

Mỗi P&F column phải có tối thiểu:
- ColumnIndex;
- Direction X/O;
- FirstKnownAtBarIndex/DateTime;
- LastExtendedAtBarIndex/DateTime;
- StartBox/EndBox;
- MinBox/MaxBox;
- BoxCount;
- SourceBar range contributing;
- completed/open status.

Event-to-column mapping phải dùng provenance này, không map gần đúng bằng Date string.

## PFO18 — Horizontal count là span của divisions, kể cả blank

Theo WSMI Step Three, count v0.1 = số horizontal divisions/columns từ right anchor tới left boundary của selected formation/segment, **kể cả division không có posting tại count-line row**.

Do đó:
`CountColumns = abs(RightColumnIndex - LeftColumnIndex) + 1`
cho selected inclusive segment.

Không dùng thuật toán “count only columns whose vertical extent intersects count line” làm official Wyckoff count.

## PFO19 — Count hướng từ phải sang trái nhưng arithmetic dùng inclusive span

Semantic:
`RightAnchor → LeftBoundary`.

Internal arithmetic có thể dùng column indexes tăng trái→phải, nhưng output phải giữ:
- RightAnchorColumnIndex;
- LeftBoundaryColumnIndex;
- CountDirectionCode = RIGHT_TO_LEFT;
- InclusiveColumnCount.

## PFO20 — Bullish right anchor ưu tiên LPS sau SOS

Bullish standard count anchor hierarchy:
1. confirmed LPS after SOS/Jump/strength;
2. successful Spring/Test acting as LPS when no later LPS available;
3. Spring low as early conservative count point nếu Phase context cho phép và chưa có clear test.

Mỗi loại có `RightAnchorTypeCode` riêng. Không silent substitute.

## PFO21 — Bearish right anchor ưu tiên LPSY sau SOW

Bearish standard hierarchy:
1. confirmed LPSY after SOW/weakness;
2. test/upthrust-derived supply point khi no clear LPSY và Phase context cho phép;
3. Upthrust high as early conservative count point trong trường hợp phù hợp.

Không tự gọi mọi pivot high là LPSY.

## PFO22 — Left boundaries dựa canonical structural/event evidence

Bullish left boundaries ưu tiên các mốc được biết từ vertical-structure engine như:
- Spring/Test boundary;
- prior ST;
- SC;
- PS;
- range-origin/AR boundary trong reaccumulation khi canonical event structure không có SC/PS tương ứng.

Bearish đối xứng:
- Upthrust/test;
- ST;
- BC;
- PSY;
- range-origin/AR boundary trong redistribution khi phù hợp.

Engine không tự đặt “N bars left” tùy ý.

## PFO23 — Không cưỡng ép một final left boundary duy nhất

Wyckoff horizontal count có judgment/nuance. V0.1 phải cho phép nhiều `CountSegmentCandidate` cùng tồn tại:
- Conservative segment;
- Extended segment(s);
- Full range segment nếu đủ evidence.

Output phải giữ từng segment, không cộng/chọn winner ngầm.

## PFO24 — Conservative-first là thứ tự semantic, không rank score

Segment đầu tiên phải là **smallest complete defensible count**.

Downstream risk/reward sau này phải dùng conservative objective trước.

Không dùng full/mega count để vượt qua một trade gate nếu conservative count không đủ.

## PFO25 — Không cộng partial Count Phase

Một CountPhase chỉ được thêm khi boundary đã hoàn chỉnh theo canonical reaction/rally structure.

Nếu phase đang hình thành:
- giữ `CAUSE BUILDING`;
- không cộng phần đã chạy dở vào official count.

## PFO26 — Count-phase boundaries phải causal

Mỗi boundary phải có:
- Origin event/pivot coordinates;
- KnownAt coordinates;
- source type;
- confirmation status.

Count revision chỉ xuất từ KnownAt trở đi.

## PFO27 — Spring/LPS và UT/LPSY relationship không bị backfill

Nếu Spring tại k về sau mới được dùng như LPS/count anchor, historical bar k không được sửa thành “official count known”.

Tương tự Upthrust/LPSY.

`AnchorOrigin` và `AnchorKnownAt` phải tách.

## PFO28 — Cause lifecycle enum

Đề xuất:
- 0 `INSUFFICIENT`;
- 1 `CAUSE BUILDING`;
- 2 `COUNT SEGMENT MEASURABLE — PRELIMINARY`;
- 3 `COUNT SEGMENT CONFIRMED / READY FOR PROJECTION`;
- 4 `OBJECTIVE ACTIVE AFTER DIRECTIONAL RANGE EXIT`;
- 5 `OBJECTIVE ZONE APPROACHED / REACHED`;
- 6 `OBJECTIVE EXCEEDED — MONITOR CHARACTER`;
- 7 `SOURCE RANGE SUPERSEDED / INVALIDATED`.

Mã là state, không confidence.

## PFO29 — Phase D vs Phase E semantics

V0.1 cho phép:
- Phase C/D: cause có thể measurable/preliminary nếu LPS/LPSY và segment đã rõ;
- objective trở thành `ACTIVE` chỉ khi directional range exit/Phase-E-like context xác nhận direction.

Không cần chờ Phase E mới bắt đầu đo Cause, nhưng phải phân biệt `preliminary projection` và `active objective`.

## PFO30 — Fixed-scale extension formula

Với fixed absolute box:

`ProjectedMove = InclusiveColumnCount × BoxSize × ReversalBoxes`

Đây là horizontal Wyckoff count extension.

Không áp vertical-count formula, không dùng bearish 2/3 multiplier của các vertical P&F methods khác.

## PFO31 — Bullish objective range

Với bullish count:
- `RangeExtremeReference = FrozenPrimaryRangeLow`;
- `CountLineReference = mapped bullish count-line price`;
- `ProjectedMove = M`.

Official endpoints:
- `ConservativeObjective = RangeLow + M`;
- `CountLineObjective = CountLine + M`.

Nếu hai mức khác nhau, vùng giữa chúng là objective range.

## PFO32 — Bearish objective range

Với bearish count:
- `RangeExtremeReference = FrozenPrimaryRangeHigh`;
- `CountLineReference = mapped bearish count-line price`;
- `ProjectedMove = M`.

Official endpoints:
- `ConservativeObjective = RangeHigh - M`;
- `CountLineObjective = CountLine - M`.

Objective range lấy giữa hai giá trị này.

## PFO33 — Midpoint objective chỉ là derived diagnostic

Có thể xuất:
- bullish: `((RangeLow + CountLine)/2) + M`;
- bearish: `((RangeHigh + CountLine)/2) - M`.

Field phải ghi rõ `DERIVED MIDPOINT REFERENCE`, không coi là một objective bắt buộc của mọi Wyckoff count.

## PFO34 — Count line dùng P&F box level thực tế

Count line không lấy raw LPS/LPSY price nếu raw price không nằm đúng grid.

Phải map anchor sang **P&F box level** theo Construction Kernel và lưu cả:
- raw anchor price;
- mapped count-line box level;
- mapping delta.

Nếu mapping không xác định duy nhất → count data-gated.

## PFO35 — Objective không được làm tròn theo tick giao dịch để đổi logic

P&F objective là analytical projection.

Display có thể format theo decimals/tick-size, nhưng internal comparison dùng unrounded objective từ box arithmetic.

## PFO36 — Nonphysical bearish objective

Nếu bearish objective <= 0 đối với equity:
- không clamp về 0;
- giữ raw math để audit;
- đặt `ObjectivePhysicalValidity = 0`;
- không dùng objective đó cho Scanner/Risk qualification.

Đây là dấu hiệu count quá lớn/không hữu ích, không phải target = 0.

## PFO37 — Objective reached không đồng nghĩa trend reversal

Khi giá chạm/đi vào objective range:
- set `STOP_LOOK_LISTEN`/Reached diagnostic;
- tiếp tục theo dõi VSA/Phase/Stopping action;
- không auto terminate bullish/bearish hypothesis;
- không tạo exit signal.

## PFO38 — Objective exceeded không xóa count

Overshoot được phép.

Nếu giá vượt far endpoint:
- trạng thái `OBJECTIVE EXCEEDED — MONITOR CHARACTER`;
- giữ original objective provenance;
- không tự gọi count sai.

## PFO39 — Count revision là generation mới, không sửa lịch sử

Khi:
- LPS/LPSY mới xuất hiện;
- một complete CountPhase mới được thêm;
- full left boundary được mở rộng;
- source data được revised;

engine tạo `CountGenerationID`/`CountRevisionCode` mới từ KnownAt bar.

Không backfill previous bars sang objective mới.

## PFO40 — Range supersession

Nếu Phase/Context supersede RangeContext:
- count cũ trở thành terminal/superseded;
- objective cũ vẫn lưu để audit;
- count mới phải có RangeContextID mới.

Không nối Cause qua hai ranges khác nhau nếu chưa có explicit higher-order count contract.

## PFO41 — Stepping-stone confirming count là quan hệ giữa count objects

V0.1 được phép phát hiện diagnostic:
`OBJECTIVE ZONES OVERLAP / NEST` giữa primary count và later reaccumulation/redistribution count.

Nhưng:
- không cộng hai ProjectedMove;
- không tạo confidence score;
- không gọi “confirmed” nếu chỉ gần nhau do tolerance tùy ý.

Overlap rule phải dựa intersection của objective intervals.

## PFO42 — Market/objective harmony để downstream dùng, không nằm trong core projection

Engine output phải đủ để một future cross-symbol layer so:
- stock objective direction;
- market objective direction;
- objective active status.

Core P&F Engine không tự chạy Market P&F trong stock formula.

## PFO43 — Không tính reward/risk trong v0.1

P&F Engine chỉ cung cấp reward-side projection:
- conservative objective;
- objective range;
- projected move.

Stop/risk placement thuộc future `Trade Risk / Reward Engine`.

Do đó không xuất `R:R PASS` dù Wyckoff Nine Tests dùng tối thiểu khoảng 3:1.

## PFO44 — Không giả hoàn tất Five-Step/Nine Tests

P&F Cause/Objectives giúp thực hiện Wyckoff Step 3 và một phần Nine Tests, nhưng chưa đủ để nói:
- Five-Step complete;
- 9/9 Buying Tests;
- 9/9 Selling Tests.

Scanner `SelectionCompleteness` chỉ được nâng phần `CAUSE/OBJECTIVE AVAILABLE`, không phải `FULL WYCKOFF COMPLETE`.

## PFO45 — Public interface

Prefix đề xuất: `WPF_`.

Các field lõi tối thiểu:
- schema/version;
- SourceSymbol/SourceDateTime/SourceBarIndex;
- PriceMethodCode;
- BoxSize;
- ReversalBoxes;
- GridOrigin;
- AdjustmentBasisStatus;
- RangeContextID / RangeSide / FamilyHypothesis / PhaseState;
- CountDirectionCode;
- CountLifecycleCode;
- CountGenerationID;
- RightAnchorType/Origin/KnownAt/raw price/P&F column;
- LeftBoundaryType/Origin/KnownAt/P&F column;
- CountLineRawAnchorPrice;
- CountLineBoxLevel;
- InclusiveColumnCount;
- ProjectedMove;
- ConservativeObjective;
- MidpointObjective;
- CountLineObjective;
- ObjectiveZoneLow/High;
- ObjectivePhysicalValidity;
- ObjectiveReachedFlag;
- ObjectiveExceededFlag;
- SteppingStoneRelationshipCode;
- SourceRevisionCode;
- ProvisionalFlag;
- Reason/Status codes.

Với multiple CountSegments phải có segment-indexed fields hoặc Exploration rows riêng, không collapse thành singleton.

## PFO46 — CỔNG KIẾN TRÚC BẮT BUỘC: P&F Construction Kernel

**Trước full Cause / Price Objective AFL**, phải có một đặc tả riêng và được phê duyệt cho `P&F Construction Kernel v0.1`.

Kernel phải khóa ít nhất:
1. initial column direction/initialization;
2. fixed grid origin;
3. price-to-box snapping;
4. exact boundary semantics;
5. High-Low precedence;
6. Close-mode semantics nếu hỗ trợ;
7. 1-box minimum-two-entry rule;
8. 3-box reversal rules;
9. multiple boxes added in one source bar;
10. column completion/open state;
11. source-bar-to-column provenance;
12. floating-point behavior;
13. missing/nonfinite OHLC behavior;
14. completed/provisional source-bar policy;
15. deterministic output independent of Exploration range;
16. reference fixture format.

Không được viết một “PnF builder tạm” bên trong Cause Engine.

## PFO47 — Cổng kiểm chứng Construction phải có reference fixtures

Native acceptance của Construction Kernel phải có:
- hand-constructed deterministic fixtures cho 1-box và 3-box;
- tie/boundary cases;
- same-bar extension-vs-reversal cases theo High-Low precedence;
- missing data;
- large gap / multi-box move;
- first-column initialization;
- two-entry rule;
- append stability;
- prefix causality;
- source revision;
- comparison với một external P&F reference implementation/chart trên bộ dữ liệu cố định, chỉ như cross-check chứ không thay specification.

Cause Engine không được native PASS nếu Kernel chưa PASS các fixture nền.

## PFO48 — Non-goals v0.1

Không có:
- Buy/Sell/Short/Cover/PositionSize;
- risk stop;
- R:R gate;
- automatic Nine Tests score;
- vertical P&F objective method;
- Breakout/Reversal vertical count method;
- percentage/ATR/traditional dynamic scaling production path;
- intraday/Weekly/Monthly P&F;
- automatic market+stock objective ranking;
- Top-N;
- probability/confidence;
- hidden range detection;
- hidden phase detection;
- hidden P&F construction inside Cause Engine.

---

## 4. Phản ví dụ bắt buộc

1. Range có 15 P&F columns từ LPS đến SC nhưng một số column không chứa posting tại đúng count-line row → official horizontal count vẫn là 15 divisions, không bỏ các blank divisions.
2. Cùng range nhưng box size khác → count/objective khác; output phải cho thấy config/provenance, không gọi một kết quả là “đúng tuyệt đối”.
3. Dynamic ATR scale thay đổi theo dữ liệu mới → không được làm historical official v0.1 count đổi âm thầm vì v0.1 dùng fixed box.
4. 1-box reversal mà current column mới có một entry → không được đảo column trái two-entry rule.
5. X-column cùng ngày vừa có High đủ extend vừa có Low đủ reverse → theo High-Low precedence, extend trước và ignore Low.
6. Spring xuất hiện nhưng chưa có direction/family context → có thể map event nhưng không official bullish objective.
7. Spring được dùng làm preliminary LPS rồi sau SOS xuất hiện LPS cao hơn → tạo generation/segment mới, không xóa preliminary count cũ.
8. Bullish LPS count 8 columns, later complete phase mở rộng thành 14 columns → output giữ cả conservative và extended segment/objective.
9. Engine chỉ đếm cột “đi qua count line” và cho 9 thay vì 14 → vi phạm PFO18.
10. Bullish RangeLow=40, CountLine=43, ProjectedMove=20 → objective range 60–63; không chỉ xuất 63.
11. Bearish RangeHigh=100, CountLine=96, ProjectedMove=30 → objective range 66–70; conservative endpoint là 70, không chỉ xuất 66.
12. CountLine trùng RangeLow bullish → objective range co thành một mức; không ép tạo band giả.
13. Bearish projection ra -5 → raw math giữ để audit nhưng `ObjectivePhysicalValidity=0`; không clamp thành 0 target.
14. Giá chạm conservative objective rồi tiếp tục trend tới far objective → không auto gọi reversal tại objective đầu tiên.
15. Giá vượt far objective → count vẫn còn provenance; chuyển trạng thái exceeded/monitor character.
16. VSA xuất weakness mạnh trước khi target đạt → P&F target không được override weakness.
17. Family hypothesis từ accumulation đổi thành conflicting trước range exit → bullish objective không được giữ active như thể context không đổi.
18. Multiple RangeContexts → giữ nhiều count objects, không chọn range gần giá nhất làm winner.
19. Reaccumulation nhỏ tạo objective overlap objective của primary accumulation → stepping-stone overlap diagnostic, không cộng hai count.
20. Objective hai ranges chỉ cách nhau rất gần nhưng không overlap interval → không gọi confirming chỉ vì tolerance tùy ý.
21. Stock có bullish P&F objective nhưng Market P&F bearish → core engine vẫn giữ stock objective; downstream mới đánh giá harmony/conflict.
22. Objective tiềm năng rất lớn nhưng chưa có LPS/LPSY/right anchor → Cause Building, không full active projection.
23. P&F full count rất lớn nhưng conservative segment nhỏ → downstream risk/reward sau này phải lấy conservative first.
24. Phase C spring có early count, nhưng Phase E không bao giờ xuất hiện → preliminary count không được hồi tố thành active.
25. Source vendor chỉnh giá lịch sử do corporate action → SourceRevisionCode thay đổi; tách source revision khỏi algorithmic repaint.
26. Forming bar tạo thêm reversal column tạm thời → official completed-bar count không cập nhật cho tới completion policy cho phép.
27. P&F construction thay vì dùng canonical RangeContext tự tạo range theo highest/lowest N bars → vi phạm PFO03.
28. Scanner dùng objective để tự tạo Buy signal → vi phạm PFO01/PFO48.

---

## 5. Native acceptance matrix dự kiến

### PFA01 — Construction Kernel prerequisite
P&F Construction Kernel đã được đặc tả/khóa riêng theo PFO46.

### PFA02 — Verify Syntax
Tất cả AFL compile trên AmiBroker 6.20.01.

### PFA03 — 1-box construction fixtures
Đúng two-entry rule, extension/reversal và multi-box behavior.

### PFA04 — 3-box construction fixtures
Đúng reversal threshold và column transitions.

### PFA05 — High-Low precedence
Same-bar ambiguous OHLC cho đúng precedence đã khóa.

### PFA06 — Fixed-grid arithmetic
Boundary/tie/floating-point fixtures không thay box do display rounding.

### PFA07 — Missing/nonfinite input
Fail closed, không fill dữ liệu.

### PFA08 — Source-to-column provenance
Column FirstKnown/LastExtended/source spans đúng fixture.

### PFA09 — Horizontal divisions count
Blank divisions vẫn được count theo inclusive anchor span.

### PFA10 — Bullish count anchor mapping
LPS/Spring/Test mapping đúng P&F column/box.

### PFA11 — Bearish anchor mapping
LPSY/UT/test mapping đúng.

### PFA12 — Conservative/extended segments
Nhiều complete phases giữ riêng, không overwrite.

### PFA13 — Bullish objective arithmetic
RangeLow/countline endpoints đúng.

### PFA14 — Bearish objective arithmetic
RangeHigh/countline endpoints đúng.

### PFA15 — Count generation lifecycle
New anchor/phase tạo generation mới từ KnownAt, không backfill.

### PFA16 — Range supersession
Old count terminal, new RangeContext tách ID.

### PFA17 — Objective reached/exceeded
Không tạo directional flip/trading signal.

### PFA18 — Stepping-stone interval overlap
Overlap/non-overlap fixtures phân loại đúng.

### PFA19 — Prefix causality
Mọi historical output prefix không đổi khi append future bars, trừ source revision/config revision có ghi provenance.

### PFA20 — Append stability
Thêm dữ liệu mới không sửa old KnownAt/count generations.

### PFA21 — Forming bar
Provisional source không làm official finalized count mutation.

### PFA22 — Corporate-action/source revision
Tách source revision khỏi algorithmic repaint.

### PFA23 — Multiple RangeContexts
Không singleton winner.

### PFA24 — Performance
P&F construction/count trên lịch sử dài vẫn đáp ứng Exploration thực tế mà không O(N²) ngoài giới hạn chấp nhận.

---

## 6. Bảng quyết định cần chủ dự án phê duyệt

| Mã | Đề xuất | Khuyến nghị |
|---|---|---|
| PFO01–PFO06 | P&F là projection layer; không thay Phase/VSA; CountPhase ≠ A–E | Chấp thuận bắt buộc |
| PFO07 | Daily completed causal v0.1 | Chấp thuận mạnh |
| PFO08–PFO09 | Fixed absolute box size; defer dynamic scales | Chấp thuận rất mạnh |
| PFO10–PFO13 | Hỗ trợ 1/3 box; khóa construction semantics riêng | Chấp thuận rất mạnh |
| PFO14–PFO17 | deterministic grid/provenance/no-lookahead | Chấp thuận bắt buộc |
| PFO18–PFO19 | đếm mọi horizontal divisions, kể cả blank | **Chấp thuận bắt buộc** |
| PFO20–PFO23 | LPS/LPSY anchors + nhiều segment candidates | Chấp thuận rất mạnh |
| PFO24–PFO27 | conservative first, complete phases only, no backfill | Chấp thuận bắt buộc |
| PFO28–PFO29 | lifecycle preliminary→active tách rõ | Chấp thuận mạnh |
| PFO30–PFO36 | projection arithmetic + objective range + physical validity | Chấp thuận rất mạnh |
| PFO37–PFO41 | target chỉ stop/look/listen; revisions; stepping-stone | Chấp thuận rất mạnh |
| PFO42–PFO44 | market harmony/downstream, chưa R:R/Nine Tests complete | Chấp thuận rất mạnh |
| PFO45 | public interface WPF_ | Chấp thuận mạnh |
| PFO46–PFO47 | P&F Construction Kernel prerequisite + reference fixtures | **Chấp thuận bắt buộc** |
| PFO48 | non-goals | Chấp thuận bắt buộc |

---

## 7. Thứ tự sau khi phê duyệt

Nếu PFO01–PFO48 được chủ dự án phê duyệt:

1. khóa docs-only PR P&F Cause / Price Objective v0.1;
2. **không viết full Cause AFL ngay**;
3. nghiên cứu chi tiết và tạo dự thảo `P&F Construction Kernel v0.1` theo PFO46;
4. chủ dự án phê duyệt Construction Kernel;
5. triển khai Construction Kernel + deterministic/reference fixtures + static audit, vẫn `UNTESTED DEVELOPMENT` cho tới native run;
6. sau đó triển khai Range/Event Mapper + Cause Segment Engine + Objective Engine;
7. thêm Exploration/Chart objective bands;
8. tích hợp output vào Market Scanner dưới dạng `Cause/Objective available`, không nâng thành full Nine Tests;
9. sau cùng mới đặc tả `Trade Risk / Reward Engine` và `Nine Buying/Selling Tests Engine` riêng.

---

## 8. Kết luận thiết kế

P&F v0.1 phải giữ đúng tinh thần Wyckoff:

`VERTICAL STRUCTURE / VSA XÁC ĐỊNH BỐI CẢNH`
`→ P&F ĐO HORIZONTAL CAUSE`
`→ CONSERVATIVE COUNT FIRST`
`→ OBJECTIVE RANGE`
`→ STOP, LOOK AND LISTEN`

Không biến P&F thành một target generator cơ học tách khỏi supply/demand context.

Điểm khóa quan trọng nhất của dự thảo là **PFO18** (đếm toàn bộ horizontal divisions trong selected span, kể cả blank) và **PFO46** (phải có P&F Construction Kernel được đặc tả riêng trước full Cause AFL).