# Wyckoff VSA Phase / Context Engine — Dự thảo đặc tả v0.1

**Trạng thái:** DỰ THẢO ĐỂ CHỦ DỰ ÁN PHÊ DUYỆT. Chưa khóa, chưa phải tiêu chí nghiệm thu, chưa có AFL triển khai.

## 1. Mục tiêu

Mô-đun này nằm sau Structural Sequence và trước Composite Indicator:

`Core → Candidate → Structure/Location → Confirmation → Event → Structural Sequence → Phase/Context → Composite`

Nhiệm vụ của Phase/Context Engine là:

1. xác định **bối cảnh xu hướng trước vùng giao dịch**;
2. quản lý **vùng giao dịch tạm thời** đã hình thành từ stopping sequence;
3. theo dõi sự tiến triển của vùng giao dịch qua các pha A–E theo cách nhân quả;
4. duy trì các **giả thuyết cấu trúc** thay vì ép kết luận quá sớm:
   - Accumulation;
   - Distribution;
   - Reaccumulation;
   - Redistribution;
5. tích hợp Wyckoff + VSA theo nguyên tắc **bối cảnh trước, tín hiệu sau**;
6. phân biệt `origin-time`, `known-at-time`, `current hypothesis` và `historical fact`;
7. không tạo Buy/Sell/Short/Cover/PositionSize, không chấm điểm xác suất giao dịch và không tạo mục tiêu giá.

## 2. Cơ sở nghiên cứu trước khi đặc tả

### 2.1. Nguồn Wyckoff chính

- Wyckoff Analytics — Wyckoff Method: https://www.wyckoffanalytics.com/wyckoff-method/
- Wyckoff Analytics — Accumulation: The Bigger Picture: https://www.wyckoffanalytics.com/accumulation-the-bigger-picture/
- Wyckoff Analytics — Anatomy of a Trading Range: https://www.wyckoffanalytics.com/wp-content/uploads/2019/08/AnatomyofaTradingRange.pdf
- StockCharts — Phase Analysis. Two Case Studies: https://articles.stockcharts.com/article/articles-wyckoff-2016-08-phase-analysis-two-case-studies/
- StockCharts — How to Determine the Best Trade Entry Points: https://articles.stockcharts.com/article/articles-wyckoff-2016-04-how-to-determine-the-best-trade-entry-points/
- StockCharts — Context is King: https://articles.stockcharts.com/article/articles-wyckoff-2015-09-context-is-king/
- StockCharts — Distribution Definitions: https://articles.stockcharts.com/article/articles-wyckoff-2015-09-distribution-definitions/
- StockCharts — Reaccumulation Review: https://articles.stockcharts.com/article/articles-wyckoff-2018-01-reaccumulation-review/
- StockCharts — Distribution or Re-Accumulation?: https://articles.stockcharts.com/article/articles-wyckoff-2022-03-distribution-or-reaccumulation-699/
- StockCharts — Redistribution, the Evil Twin: https://articles.stockcharts.com/article/articles-wyckoff-2015-11-redistribution-the-evil-twin/
- StockCharts — Redistribution — A Case Study: https://articles.stockcharts.com/article/articles-wyckoff-2015-11-redistribution--a-case-study/

### 2.2. Nguồn VSA chính

- TradeGuider — Master the Markets: https://tradeguider.com/mtm_251058.pdf
- TradeGuider — VSA System Explained: https://www.tradeguider.com/customer/pdf/VSA_System_explained.pdf
- TradeGuider — VSA course / importance of background: https://tradeguider.com/rt/index.asp

### 2.3. Kết luận nghiên cứu có ảnh hưởng trực tiếp đến thiết kế

1. Phase A là quá trình **dừng xu hướng trước đó**, không phải chỉ một thanh climax.
2. Phase B là giai đoạn **xây dựng nguyên nhân / testing trong range**; bản thân Phase B chưa đủ để kết luận hướng thoát range.
3. Phase C là **final test**. Ở phía tăng có thể là Spring/Shakeout hoặc một LPS/higher-low test không có Spring. Ở phía giảm có thể là UT/UTAD hoặc một LPSY/lower-high test không có UTAD.
4. Phase D là lúc cán cân cung cầu bắt đầu nghiêng rõ: trong accumulation/reaccumulation, các nhịp tăng kiểu SOS có spread/volume mở rộng và reactions kiểu LPS thường nhẹ hơn; trong distribution/redistribution, SOW và các rally LPSY thể hiện supply chiếm ưu thế.
5. Phase E là lúc giá **rời trading range** và xu hướng mới/tiếp diễn trở nên rõ.
6. Spring và UTAD **không bắt buộc**. Không được viết máy trạng thái buộc mọi range phải có chúng.
7. Reaccumulation và Distribution có thể bắt đầu gần như giống nhau sau một prior uptrend; tương tự Accumulation và Redistribution có thể cùng bắt đầu bằng stopping action sau prior downtrend. Việc phân loại phải chờ hành vi tiếp theo trong range.
8. VSA nhấn mạnh **background**: No Demand có giá trị hơn sau weakness; No Supply/Test có giá trị hơn sau strength. Một thanh đơn lẻ không nên tự quyết định phase.
9. Volume cao không tự động đồng nghĩa với mua hay bán; Effort phải được đọc cùng Result và phản ứng tiếp theo.
10. Các sơ đồ Wyckoff là mô hình lý tưởng; thực tế có nhiều biến thể. Engine phải hỗ trợ `AMBIGUOUS / UNRESOLVED` thay vì ép mọi chuỗi thành schematic hoàn chỉnh.

## 3. Phát hiện kiến trúc quan trọng trước khi triển khai

Nghiên cứu cho thấy **không nên triển khai đầy đủ Phase/Context Engine ngay sau PR #21** vì chuỗi event hiện tại còn thiếu một họ đối xứng quan trọng:

`SIGN-OF-WEAKNESS-LIKE / LAST-POINT-OF-SUPPLY-LIKE (SOW/LPSY)`.

Hiện đã có phía strength `SOS/LPS`, nhưng Phase D/E của Distribution/Redistribution cần SOW/LPSY để có đối xứng cấu trúc. Do đó:

- đặc tả Phase/Context vẫn có thể được phê duyệt trước;
- **AFL Phase/Context không được triển khai đầy đủ** cho đến khi SOW/LPSY có đặc tả được duyệt và implementation contract ổn định;
- No Demand có thể dùng như VSA supporting evidence nhưng **không thay thế SOW/LPSY structural event**.

Đây là ràng buộc kiến trúc, không phải lỗi của upstream hiện tại.

## 4. D01 — Chính sách nhãn

Phase/Context v0.1 dùng nhãn thận trọng:

- `PHASE-A-LIKE`;
- `PHASE-B-LIKE`;
- `PHASE-C-CANDIDATE`;
- `PHASE-C-LIKE`;
- `PHASE-D-LIKE`;
- `PHASE-E-LIKE`;
- `ACCUMULATION-HYPOTHESIS`;
- `DISTRIBUTION-HYPOTHESIS`;
- `REACCUMULATION-HYPOTHESIS`;
- `REDISTRIBUTION-HYPOTHESIS`;
- `UNRESOLVED-RANGE-HYPOTHESIS`.

Không dùng chữ `CONFIRMED` theo nghĩa tuyệt đối cho cấu trúc chưa có đầy đủ lịch sử hậu nghiệm.

## 5. D02 — Prior Trend Context không dùng MA oracle

Để phân biệt primary reversal và continuation range, Phase Engine phải biết xu hướng trước range.

V0.1 không dùng MA slope, RSI, ADX hay đếm N thanh tùy ý. Dùng **confirmed swing structure** từ Structure/Location.

### PriorUptrendContext

Tại thời điểm Phase-A anchor được biết, hai confirmed Pivot High gần nhất trước anchor phải cho:

`High2 > High1`

và hai confirmed Pivot Low gần nhất phải cho:

`Low2 > Low1`.

### PriorDowntrendContext

Hai Pivot High gần nhất:

`High2 < High1`

và hai Pivot Low gần nhất:

`Low2 < Low1`.

Nếu không đủ hai cặp hoặc quan hệ mâu thuẫn:

- `PRIOR_TREND_INSUFFICIENT`, hoặc
- `PRIOR_TREND_MIXED`.

Đây là **quy tắc vận hành v0.1**, không được mô tả như công thức Wyckoff cổ điển duy nhất.

## 6. D03 — Phase-A anchor lấy từ Structural Sequence đã khóa

Phase Engine không tính lại PS/SC/AR/ST hay PSY/BC/AR/ST.

Nguồn Phase A:

- lower stopping sequence morphology từ Structural Sequence;
- upper stopping sequence morphology từ Structural Sequence.

`PHASE-A-LIKE` chỉ KnownAt khi morphology-complete đã được upstream công bố.

Không backfill Phase A về thời điểm SC/BC origin.

## 7. D04 — Phase A chưa xác định ngay Accumulation hay Distribution

Nếu prior trend là DOWN và lower stopping sequence hình thành:

`CandidateFamily = {ACCUMULATION, REDISTRIBUTION}`.

Nếu prior trend là UP và upper stopping sequence hình thành:

`CandidateFamily = {DISTRIBUTION, REACCUMULATION}`.

Nếu trend context mixed/insufficient:

`CandidateFamily = UNRESOLVED`.

Không phân loại Accumulation/Distribution chỉ từ Phase A.

## 8. D05 — Frozen Primary Range

Phase/Context dùng provisional range đã được Structural Sequence đóng băng:

- lower sequence: `SC Low ↔ Automatic Rally High`;
- upper sequence: `Automatic Reaction Low ↔ BC High`.

Primary Range boundaries không được tự trôi theo pivot mới.

Spring/UTAD hoặc ST có thể vượt biên nhưng không được âm thầm thay baseline range.

Có thể duy trì `ObservedEnvelopeLow/High` riêng cho nghiên cứu, nhưng không ghi đè Primary Range.

## 9. D06 — Range Position chuẩn hóa

Nếu range width hợp lệ:

`RangePosition = (Close - RangeLow) / (RangeHigh - RangeLow)`.

Đây chỉ là descriptor:

- `<0` dưới range;
- `0..1` trong range;
- `>1` trên range.

Không dùng một ngưỡng RangePosition đơn lẻ để quyết định phase.

## 10. D07 — Phase B là trạng thái testing / cause-building mặc định sau Phase A

Sau `PHASE-A-LIKE`, nếu range vẫn hoạt động và chưa có Phase C/D transition hợp lệ:

`PHASE-B-LIKE` được coi là trạng thái vận hành hiện tại.

Nó biểu thị:

- xu hướng trước đã dừng;
- giá đang tương tác trong range;
- hướng thoát range chưa đủ bằng chứng.

Không được diễn giải Phase B-like là “đang tích lũy” hoặc “đang phân phối”.

## 11. D08 — Không dùng timeout để kết thúc Phase B

Không có `MaxPhaseBBars`.

Một trading range có thể tồn tại rất lâu. Phase B chỉ kết thúc khi có **evidence transition** sang Phase C/D hoặc range context bị supersede/invalidate bởi cấu trúc mới.

Xuất `BarsSincePhaseAKnownAt` như descriptor.

## 12. D09 — Phase B interaction diagnostics

Không dùng thời gian làm bằng chứng duy nhất. Engine phải lưu các descriptor:

- số confirmed Pivot Low trong range sau Phase A;
- số confirmed Pivot High trong range sau Phase A;
- số support interactions;
- số resistance interactions;
- số false breaks/reclaims;
- số SOS-like / Upthrust-like / Supply-Test / No-Supply / No-Demand observations;
- directionality của swing spread/volume nếu upstream có dữ liệu hợp lệ;
- lower-high / higher-low progression count.

Các count này là context, không phải weighted score.

## 13. D10 — VSA Background Contract

Phase/Context không được dùng No Demand / No Supply như tín hiệu độc lập.

### Strength background

Một No Supply/Test chỉ được nâng giá trị bối cảnh khi đã có ít nhất một trong:

- confirmed lower stopping sequence;
- Spring/Shakeout-like liên kết active range;
- SOS-like;
- bullish Phase-C candidate.

### Weakness background

Một No Demand chỉ được nâng giá trị bối cảnh khi đã có ít nhất một trong:

- confirmed upper stopping sequence;
- Upthrust-like liên kết active range;
- SOW-like;
- bearish Phase-C candidate.

Nếu không có background phù hợp, VSA bar vẫn được giữ như observation nhưng không được dùng để chuyển phase.

## 14. D11 — Effort versus Result là context chuỗi, không phải một thanh

Phase Engine không tính lại RVOL/RSpread. Nó dùng upstream measurements/events để đánh giá:

### Bullish evidence

- advance có SOS-like / wider-spread + higher-volume characteristics;
- pullback có diminished spread/volume hoặc No Supply/Test;
- downside effort lớn nhưng downside result giảm / absorption + positive response.

### Bearish evidence

- decline có SOW-like / wider-spread + higher-volume characteristics;
- rally yếu, narrow spread, No Demand;
- upside effort lớn nhưng upside result kém / absorption + negative response.

Không suy ra “smart money buying/selling” chỉ từ volume cao.

## 15. D12 — Bullish Phase-C Candidate: hai con đường

Phase C phía bullish có hai con đường hợp lệ.

### Route C1 — Spring / Shakeout path

Một Spring/Shakeout-like chỉ trở thành `BULLISH-PHASE-C-CANDIDATE` nếu:

- event xuất hiện sau Phase A;
- origin Low xuyên xuống dưới `PrimaryRangeLow`;
- event đóng/reclaim theo hợp đồng upstream;
- event support/context có thể liên kết nhân quả với active range;
- range chưa bị supersede.

### Route C2 — No-Spring test path

Một confirmed Supply Test / lower test có thể trở thành candidate nếu:

- xuất hiện sau Phase A trong active range;
- ở nửa dưới range hoặc kiểm tra một support structural point thuộc active range;
- không cần phá PrimaryRangeLow;
- có phản ứng giá hợp lệ theo upstream;
- No Supply nếu có chỉ là quality evidence tăng thêm.

Không bắt buộc Spring.

## 16. D13 — Bullish Phase C chỉ được nâng khi có response sức mạnh

`BULLISH-PHASE-C-CANDIDATE` chưa phải Phase C-like hoàn chỉnh.

Nó chỉ được nâng thành `BULLISH-PHASE-C-LIKE` khi sau candidate xuất hiện bằng chứng sức mạnh nhân quả, ưu tiên:

- SOS-like; hoặc
- confirmed upward change-of-character structural breakout.

SOS phải xảy ra sau Phase-C origin và dùng dữ liệu đã biết tại thời điểm hiện tại.

Nếu candidate thất bại và range tạo low thấp hơn với weakness mới, candidate cũ được giữ lịch sử nhưng current hypothesis có thể bị hạ/xóa.

## 17. D14 — Bearish Phase-C Candidate: hai con đường

### Route C1 — Upthrust path

Một Upthrust-like có thể trở thành `BEARISH-PHASE-C-CANDIDATE` nếu:

- xuất hiện sau Phase A;
- High xuyên lên trên `PrimaryRangeHigh` hoặc test resistance của active range;
- thất bại quay lại range theo upstream;
- range chưa bị supersede.

### Route C2 — No-UTAD / LPSY path

Wyckoff cho phép Phase C distribution không có UTAD. Khi demand yếu, final test có thể là lower-high / LPSY-type rally.

Vì hiện dự án chưa có SOW/LPSY Event Engine, route này **chưa được phép triển khai AFL** cho đến khi SOW/LPSY được đặc tả.

## 18. D15 — UTAD chỉ được Phase Engine nâng từ Upthrust-like

Upthrust Event Engine không tự gọi UTAD.

Phase/Context chỉ được xuất `UTAD-LIKE-CONTEXT` khi đồng thời:

- active upper-family range tồn tại;
- Phase B-like đã tồn tại trước upthrust;
- Upthrust-like liên kết PrimaryRangeHigh;
- sau upthrust xuất hiện weakness response, ưu tiên SOW-like hoặc persistent decline / weak rally evidence.

Không yêu cầu UTAD trong mọi Distribution.

## 19. D16 — Spring chỉ được Phase Engine nâng theo range + follow-through

Spring/Shakeout Event Engine chỉ phát morphology.

Phase/Context chỉ nâng thành `PHASE-C-SPRING-LIKE-CONTEXT` khi:

- active lower-family range tồn tại;
- spring/shakeout xuyên range support;
- sau đó có test/strength response;
- và cuối cùng SOS-like hoặc tương đương xác nhận demand transition.

Không backfill Phase C về origin như thể đã biết trước follow-through.

## 20. D17 — Bullish Phase D transition

`BULLISH-PHASE-D-LIKE` bắt đầu khi:

- bullish Phase-C-like đã được xác lập;
- sau đó demand thể hiện dominance bằng SOS-like hoặc structural breakout mạnh lên phía trên;
- hành vi không lập tức thất bại trở lại theo weakness evidence.

Primary signals:

- SOS-like;
- higher confirmed lows;
- reactions kiểu LPS-like;
- pullback effort giảm / No Supply/Test sau strength.

Không bắt buộc giá phải breakout toàn bộ PrimaryRangeHigh ngay khi Phase D bắt đầu.

## 21. D18 — Bearish Phase D transition

`BEARISH-PHASE-D-LIKE` cần:

- bearish Phase-C-like;
- sau đó supply dominance bằng SOW-like / structural breakdown;
- weak rallies kiểu LPSY-like hoặc No Demand after weakness.

**D18 là hard dependency của SOW/LPSY Event Engine.** Phase implementation không được mô phỏng SOW bằng một công thức tạm thời trong Phase Engine.

## 22. D19 — LPS trong Phase D là phản ứng hỗ trợ strength hypothesis

LPS-like sau SOS được dùng như evidence của Phase D khi:

- tham chiếu SOS anchor liên quan active range;
- pullback giữ được breakout/support context;
- response tăng tiếp diễn.

Nhiều LPS được phép.

RVOL/RSpread giảm làm quality tốt hơn nhưng không phải điều kiện tồn tại duy nhất.

## 23. D20 — LPSY trong Phase D là phản ứng hỗ trợ weakness hypothesis

LPSY-like sau SOW được dùng như evidence của bearish Phase D khi:

- rally từ/near support cũ nhưng yếu;
- không reclaim được range theo cấu trúc;
- No Demand hoặc diminished rally effort có thể tăng quality;
- weakness tiếp tục sau rally.

Nhiều LPSY được phép.

Đặc tả chi tiết identity/quality của LPSY phải nằm trong Event Engine SOW/LPSY, không viết lại trong Phase Engine.

## 24. D21 — Bullish Phase E transition

`BULLISH-PHASE-E-LIKE` chỉ được công bố khi giá đã **rời PrimaryRange** và khả năng duy trì phía trên được chứng minh.

Một đường xác nhận ưu tiên:

1. SOS-like đóng trên PrimaryRangeHigh;
2. sau đó LPS/backup giữ vùng breakout hoặc không quay lại weakness sâu trong range;
3. cấu trúc tiếp tục tạo higher structural progress.

Một breakout đơn lẻ chưa đủ Phase E.

## 25. D22 — Bearish Phase E transition

Đối xứng:

1. SOW-like đóng dưới PrimaryRangeLow;
2. sau đó LPSY/failed retest không reclaim được support cũ;
3. cấu trúc tiếp tục lower structural progress.

Một breakdown đơn lẻ chưa đủ Phase E.

## 26. D23 — Accumulation vs Redistribution sau prior downtrend

Sau prior downtrend + lower stopping sequence, hypothesis ban đầu là:

`LOWER-RANGE-UNRESOLVED = ACCUMULATION OR REDISTRIBUTION`.

### Evidence nghiêng Accumulation

- successful lower tests;
- Spring/Shakeout + test;
- SOS after final test;
- LPS behavior;
- higher lows / inability to make downside progress;
- No Supply/Test after strength;
- bullish Phase D/E transition.

### Evidence nghiêng Redistribution

- rallies yếu;
- repeated SOW-like;
- LPSY-like;
- lower highs/lower lows;
- support breakdown và failed retest;
- No Demand after weakness;
- bearish Phase D/E transition.

Không được chọn một phía chỉ trong Phase A/B.

## 27. D24 — Distribution vs Reaccumulation sau prior uptrend

Sau prior uptrend + upper stopping sequence:

`UPPER-RANGE-UNRESOLVED = DISTRIBUTION OR REACCUMULATION`.

### Evidence nghiêng Reaccumulation

- higher lows / support holding;
- absorption characteristics;
- final lower test / Spring-like theo cấu trúc range;
- SOS vượt resistance;
- LPS/backup khỏe;
- bullish Phase D/E.

### Evidence nghiêng Distribution

- lower highs/lower lows trong range;
- Upthrust/UTAD context;
- SOW;
- LPSY;
- No Demand after weakness;
- bearish Phase D/E.

Không cho BCLX/AR/ST tự quyết định Distribution.

## 28. D25 — Không phân loại sớm ở Phase A/B

Ở Phase A/B, output family phải là:

- `LOWER-RANGE-UNRESOLVED`;
- `UPPER-RANGE-UNRESOLVED`;
- hoặc `UNRESOLVED-RANGE` nếu prior trend không đủ.

Chỉ sau Phase C/D evidence mới được nâng thành family hypothesis cụ thể.

## 29. D26 — Hypothesis không phải binary permanent label

Current hypothesis có thể thay đổi theo dữ liệu mới.

Ví dụ:

- tại bar t: `DISTRIBUTION-HYPOTHESIS`;
- tại bar t+n: strength phá resistance và giữ được → chuyển thành `REACCUMULATION-HYPOTHESIS`.

Việc đổi current hypothesis **không sửa giá trị historical output của bar t**.

Đây là cập nhật câu chuyện theo thời gian, không phải repaint.

## 30. D27 — Evidence state thay vì weighted score

Không dùng điểm 60/100 hay xác suất 75% trong v0.1.

Dùng các cờ/enum có thể kiểm toán:

- `BULLISH_EVIDENCE_PRESENT`;
- `BEARISH_EVIDENCE_PRESENT`;
- `MIXED_EVIDENCE`;
- `INSUFFICIENT_EVIDENCE`.

Có thể xuất counts theo nhóm evidence nhưng không cộng trọng số tùy ý.

## 31. D28 — Higher Low / Lower High chỉ là context, không phải phase oracle

Higher lows thường hỗ trợ absorption/reaccumulation/accumulation; lower highs/lower lows thường hỗ trợ distribution/redistribution.

Tuy nhiên không một pattern HH/HL hoặc LH/LL đơn lẻ nào được tự xác định family/phase.

## 32. D29 — Absorption phải có response

High effort + limited adverse result chỉ là `ABSORPTION OBSERVATION` upstream.

Phase Engine chỉ dùng nó như bullish/bearish context khi sau đó có response phù hợp:

- downside effort lớn nhưng giá không giảm tiếp + strength response → bullish absorption evidence;
- upside effort lớn nhưng giá không tăng tiếp + weakness response → bearish absorption evidence.

Không suy supply/demand absorbed chỉ từ bar origin.

## 33. D30 — Event overlap được phép

Một tọa độ có thể đồng thời là:

- ST-like + Spring-like;
- ST-like + Upthrust-like;
- Supply Test + No Supply confirmation;
- LPS-like + No Supply;
- LPSY-like + No Demand.

Phase Engine không được chọn một event để xóa event khác. Nó chỉ giải thích quan hệ trong active range.

## 34. D31 — State machine tách theo Range Context

Mỗi active range có ít nhất:

- `RangeContextID`;
- `AnchorSequenceSide`;
- `PriorTrendContext`;
- `PrimaryRangeLow/High`;
- `PhaseState`;
- `FamilyHypothesis`;
- `BullishEvidenceState`;
- `BearishEvidenceState`;
- `PhaseCOrigin coordinates`;
- `PhaseDKnownAt coordinates`;
- `PhaseEKnownAt coordinates`;
- `Superseded/Invalidated status`.

Lower/upper stopping sequences có thể cùng tồn tại lịch sử; RangeContext quyết định anchor đang được theo dõi chứ không xóa historical sequence.

## 35. D32 — PhaseState enum

Đề xuất:

- 0 = `INSUFFICIENT CONTEXT`;
- 1 = `PHASE-A-LIKE`;
- 2 = `PHASE-B-LIKE`;
- 3 = `PHASE-C-CANDIDATE`;
- 4 = `PHASE-C-LIKE`;
- 5 = `PHASE-D-LIKE`;
- 6 = `PHASE-E-LIKE`;
- 7 = `RANGE INVALIDATED / SUPERSEDED`.

PhaseState là current operational state tại bar hiện tại; historical states không bị backfill.

## 36. D33 — FamilyHypothesis enum

Đề xuất:

- 0 = `INSUFFICIENT`;
- 1 = `UNRESOLVED LOWER RANGE`;
- 2 = `UNRESOLVED UPPER RANGE`;
- 3 = `ACCUMULATION-HYPOTHESIS`;
- 4 = `REDISTRIBUTION-HYPOTHESIS`;
- 5 = `DISTRIBUTION-HYPOTHESIS`;
- 6 = `REACCUMULATION-HYPOTHESIS`;
- 7 = `MIXED / CONFLICTING EVIDENCE`.

Không có `100% confirmed` state trong v0.1.

## 37. D34 — Transition không backfill

Mỗi transition lưu:

- `OriginBarIndex/DateTime` của event gây ra;
- `KnownAtBarIndex/DateTime` khi đủ evidence;
- source event key / sequence key;
- active range key.

Phase C có thể có origin ở Spring/UT nhưng chỉ KnownAt sau SOS/SOW.

## 38. D35 — Range invalidation và supersession

Không dùng timeout.

Range context có thể kết thúc bởi:

1. Phase E-like đã hình thành và trend mới/tiếp diễn rõ;
2. một stopping sequence mới đủ mạnh tạo range context mới sau một trend leg;
3. source revision làm mất anchor upstream;
4. cấu trúc dữ liệu trở nên không hợp lệ.

Một false breakout đơn lẻ không tự xóa range; nó có thể chính là Spring/Upthrust context.

## 39. D36 — Current hypothesis và historical evidence phải tách

Khi hypothesis thay đổi:

- historical event/phase observations vẫn bất biến;
- `CurrentFamilyHypothesis` được cập nhật từ bar hiện tại trở đi;
- phải xuất `HypothesisRevisionCode` và lý do chuyển.

Không được chỉnh lại quá khứ để tạo cảm giác Phase C/D đã biết sớm hơn.

## 40. D37 — Không dùng P&F Cause/Target trong v0.1

Wyckoff Cause & Effect rất quan trọng, nhưng Point-and-Figure counting là module riêng.

Phase v0.1 chỉ ghi nhận `CAUSE-BUILDING RANGE-LIKE` ở Phase B; không tạo target giá.

## 41. D38 — Không tự tạo SOW/LPSY trong Phase Engine

Đây là quyết định kiến trúc bắt buộc.

Trước khi triển khai AFL Phase/Context đầy đủ, phải xây riêng:

`Wyckoff Event — SOW / LPSY v0.1`

với quy trình:

`nghiên cứu → dự thảo đặc tả → chủ dự án duyệt → khóa → AFL → static audit`.

Phase Engine chỉ consume output đó.

## 42. D39 — No Demand / No Supply không bắt buộc phải có Event wrapper mới

V0.1 được phép consume Candidate/Confirmation hiện hành trực tiếp cho VSA background evidence nếu interface ổn định.

Tuy nhiên nếu dự án sau này xây `Demand Test / No Demand in Context Event`, Phase Engine phải chuyển sang public Event interface thay vì duplicate logic.

Không copy công thức Candidate vào Phase Engine.

## 43. D40 — Scope thời gian

Official research/acceptance scope hiện tại:

- Daily completed bars.

Forming bar:

- provisional only;
- không dùng để khóa Phase transition chính thức;
- source revision phải phân biệt với algorithmic repaint.

## 44. D41 — Không giao dịch và không xác suất

Không có:

- Buy/Sell/Short/Cover;
- PositionSize;
- stop/target;
- expected return;
- probability score;
- “safe entry”.

Phase Engine là context/interpretation layer.

## 45. D42 — Đầu ra tối thiểu

### Range identity

- RangeContextID;
- RangeAnchorSequenceID;
- RangeAnchorSide;
- PrimaryRangeLow/High/Width;
- RangeKnownAt coordinates;
- RangeAgeBars;
- RangeActive/Superseded/Invalidated.

### Prior context

- PriorTrendContextCode;
- prior two Pivot High coordinates/prices;
- prior two Pivot Low coordinates/prices;
- validity.

### Phase

- PhaseStateCode;
- PhaseOrigin coordinates;
- PhaseKnownAt coordinates;
- PhaseTransitionReasonCode.

### Family hypothesis

- FamilyHypothesisCode;
- HypothesisKnownAt;
- HypothesisRevisionCode;
- BullishEvidenceState;
- BearishEvidenceState.

### Phase-C context

- Spring/Shakeout linked flag;
- Supply-Test linked flag;
- Upthrust linked flag;
- future LPSY/weak-final-test link;
- PhaseC candidate/confirmed source event key.

### Phase-D/E context

- SOS linked count;
- LPS linked count;
- SOW linked count;
- LPSY linked count;
- NoSupplyAfterStrength count;
- NoDemandAfterWeakness count;
- breakout/breakdown hold state.

### Diagnostics

- support/resistance interaction counts;
- higher-low/lower-high descriptors;
- absorption response descriptors;
- mixed/conflicting evidence reason.

## 46. D43 — Phản ví dụ bắt buộc

1. Lower stopping sequence sau downtrend → chưa được gọi Accumulation.
2. Upper stopping sequence sau uptrend → chưa được gọi Distribution.
3. BCLX/AR/ST rồi higher lows + SOS breakout → có thể là Reaccumulation.
4. SCLX/AR/ST rồi SOW + weak rallies → có thể là Redistribution.
5. Spring-like nhưng không có subsequent strength → chỉ Phase-C candidate, chưa Phase-C-like.
6. Upthrust-like nhưng không có weakness follow-through → chưa UTAD-like context.
7. SOS trong Phase B nhưng chưa có valid final test → strength evidence, không tự buộc Phase D nếu context chưa đủ.
8. No Demand trong strong background → không được tự chuyển bearish phase.
9. No Supply trong weak background → không được tự chuyển bullish phase.
10. High-volume down bar nhưng giá phục hồi mạnh sau đó → không được gọi bearish chỉ vì volume cao.
11. Breakout trên resistance một thanh rồi quay lại range → chưa Phase E.
12. Breakdown dưới support một thanh rồi reclaim → chưa Phase E.
13. Phase C không Spring nhưng lower test + SOS → vẫn hợp lệ.
14. Distribution không UTAD nhưng SOW/LPSY path → vẫn hợp lệ.
15. Multiple LPS/LPSY → được giữ và đếm.
16. Hypothesis đổi từ Distribution sang Reaccumulation sau strength mới → historical bar cũ không sửa.
17. Range tồn tại lâu → không timeout.
18. Prior trend mixed → giữ unresolved, không ép primary/continuation family.
19. Spring/ST overlap → giữ cả hai event layers.
20. Forming bar phá range nhưng chưa hoàn tất → provisional, không Phase E chính thức.

## 47. D44 — Điều kiện chuyển sang triển khai

Chỉ sau khi chủ dự án phê duyệt D01–D44 mới:

1. khóa đặc tả này vào `main`;
2. **trước hết xây và khóa SOW/LPSY Event Engine**;
3. căn chỉnh public interfaces của SOS/LPS, Upthrust, Spring/Shakeout, Supply Test, Structural Sequence snapshot;
4. tạo nhánh Phase/Context implementation xếp chồng trên chuỗi Event/Structural hiện hành;
5. thực hiện static conformance audit;
6. vẫn giữ `UNTESTED DEVELOPMENT` cho đến chiến dịch AmiBroker native tổng thể.

## 48. Bảng quyết định cần chủ dự án phê duyệt

| Mã | Đề xuất | Khuyến nghị |
|---|---|---|
| D01 | Phase/family dùng hậu tố hypothesis/-like, không tuyệt đối hóa | Chấp thuận mạnh |
| D02 | Prior trend bằng confirmed swing structure, không MA oracle | Chấp thuận mạnh |
| D03 | Phase A consume Structural Sequence, không tính lại | Chấp thuận mạnh |
| D04 | Phase A chỉ tạo family set chưa phân giải | Chấp thuận mạnh |
| D05 | Primary Range frozen từ Phase-A sequence | Chấp thuận mạnh |
| D06 | RangePosition chỉ descriptor | Chấp thuận |
| D07 | Phase B = testing/cause-building state sau A | Chấp thuận mạnh |
| D08 | Không timeout Phase B | Chấp thuận mạnh |
| D09 | Lưu range interaction diagnostics, không score | Chấp thuận |
| D10 | VSA background contract | Chấp thuận mạnh |
| D11 | Effort/Result đọc theo chuỗi | Chấp thuận mạnh |
| D12 | Bullish Phase C có Spring path và no-Spring test path | Chấp thuận mạnh |
| D13 | Bullish C chỉ nâng sau strength response | Chấp thuận mạnh |
| D14 | Bearish C có Upthrust path và no-UTAD/LPSY path | Chấp thuận mạnh |
| D15 | UTAD chỉ Phase Engine được nâng từ Upthrust + context | Chấp thuận mạnh |
| D16 | Spring context cần range + follow-through | Chấp thuận mạnh |
| D17 | Bullish Phase D từ confirmed final test → SOS/demand dominance | Chấp thuận mạnh |
| D18 | Bearish Phase D phụ thuộc SOW/LPSY Event | Chấp thuận mạnh |
| D19 | LPS là Phase-D strength evidence, nhiều LPS | Chấp thuận mạnh |
| D20 | LPSY là Phase-D weakness evidence, nhiều LPSY | Chấp thuận mạnh |
| D21 | Phase E bullish cần breakout + hold | Chấp thuận mạnh |
| D22 | Phase E bearish cần breakdown + failed retest | Chấp thuận mạnh |
| D23 | Downtrend range: Accumulation vs Redistribution chỉ phân giải muộn | Chấp thuận mạnh |
| D24 | Uptrend range: Distribution vs Reaccumulation chỉ phân giải muộn | Chấp thuận mạnh |
| D25 | Không phân loại family ở A/B | Chấp thuận mạnh |
| D26 | Hypothesis được cập nhật theo thời gian, không repaint | Chấp thuận mạnh |
| D27 | Evidence state, không weighted score | Chấp thuận mạnh |
| D28 | HH/HL, LH/LL chỉ context | Chấp thuận |
| D29 | Absorption phải có response | Chấp thuận mạnh |
| D30 | Event overlap không ghi đè | Chấp thuận mạnh |
| D31 | RangeContext state machine riêng | Chấp thuận mạnh |
| D32 | PhaseState enum 0–7 | Chấp thuận |
| D33 | FamilyHypothesis enum 0–7 | Chấp thuận |
| D34 | Origin-time tách KnownAt-time | Chấp thuận mạnh |
| D35 | Invalidation/supersession không timeout | Chấp thuận mạnh |
| D36 | Historical evidence bất biến khi hypothesis đổi | Chấp thuận mạnh |
| D37 | Không P&F target ở v0.1 | Chấp thuận mạnh |
| D38 | Phải xây SOW/LPSY Event trước Phase AFL | Chấp thuận rất mạnh |
| D39 | No Demand/No Supply consume upstream, không duplicate | Chấp thuận mạnh |
| D40 | Daily completed bars | Chấp thuận mạnh |
| D41 | Không trading/probability | Chấp thuận mạnh |
| D42 | Output contract đầy đủ cho Composite | Chấp thuận mạnh |
| D43 | Bộ phản ví dụ bắt buộc | Chấp thuận mạnh |
| D44 | Quy trình chuyển sang triển khai | Chấp thuận mạnh |

**Kết luận dự thảo:** Phase/Context Engine phải được xây như một **máy trạng thái câu chuyện thị trường**, không phải bộ gán nhãn mẫu hình. Bối cảnh xu hướng + range + chuỗi event + VSA background + response là bắt buộc để nâng diễn giải. Đặc biệt, không được triển khai đối xứng giả tạo cho Distribution bằng cách viết tạm SOW/LPSY bên trong Phase Engine.