# Wyckoff VSA SOW / LPSY — Dự thảo đặc tả v0.1

**Trạng thái:** DỰ THẢO ĐỂ CHỦ DỰ ÁN PHÊ DUYỆT. Chưa khóa, chưa phải tiêu chí nghiệm thu và chưa có AFL triển khai.

## 1. Mục tiêu

Mô-đun này nhận diện hai họ hành vi phía suy yếu cần thiết cho Phase / Context Engine:

- `SIGN-OF-WEAKNESS-LIKE (SOW-LIKE)`;
- `LAST-POINT-OF-SUPPLY-LIKE (LPSY-LIKE)`.

Mục tiêu không phải gán Distribution/Redistribution ngay tại Event layer, mà tạo bằng chứng cấu trúc có thời điểm biết rõ ràng để Phase / Context Engine sử dụng sau đó.

Đây là mô-đun bắt buộc theo D38 của đặc tả Phase / Context v0.1 đã khóa tại PR #22.

## 2. Cơ sở nghiên cứu

### 2.1. Nguồn Wyckoff chính

- Wyckoff Analytics — Wyckoff Method: https://www.wyckoffanalytics.com/wyckoff-method/
- Wyckoff Analytics — Wyckoff Schematics / Visual Templates: https://www.wyckoffanalytics.com/wp-content/uploads/2019/09/WyckoffSchematics-VisualTemplatesForMarketTimingDecisions.pdf
- Wyckoff Analytics — Anatomy of a Trading Range: https://www.wyckoffanalytics.com/wp-content/uploads/2019/08/AnatomyofaTradingRange.pdf
- StockCharts ChartSchool — The Wyckoff Method: A Tutorial: https://chartschool.stockcharts.com/table-of-contents/market-analysis/wyckoff-analysis-articles/the-wyckoff-method-a-tutorial
- StockCharts — Distribution Definitions: https://stockcharts.com/articles/wyckoff/2015/09/distribution-definitions.html
- StockCharts — Context is King: https://stockcharts.com/articles/wyckoff/2015/09/context-is-king.html
- StockCharts — Secrets of Point and Figure Distribution: https://stockcharts.com/articles/wyckoff/2016/01/secrets-of-point-and-figure-distribution.html
- StockCharts — Distribution or Re-Accumulation?: https://stockcharts.com/articles/wyckoff/2022/03/distribution-or-reaccumulation-699.html

### 2.2. Nguồn VSA chính

- TradeGuider — Trading in the Shadow of the Smart Money: https://www.tradeguider.com/tradingintheshadow/book1.pdf
- TradeGuider — VSA Signs of Weakness: https://www.tradeguider.com/hubfs/Website%20PDFs%20%28Downloadables%29/VSA%20Signs%20of%20weakness.pdf
- TradeGuider — Resource Center / importance of background: https://www.tradeguider.com/resource_center1.asp

### 2.3. Kết luận nghiên cứu chi phối thiết kế

1. SOW là một nhịp giảm tới hoặc hơi xuyên qua vùng hỗ trợ của trading range; thường đi kèm spread và volume tăng.
2. SOW không bắt buộc phải luôn đóng dưới hỗ trợ. Tài liệu Wyckoff mô tả cả trường hợp SOW không hoàn toàn “fall through the ice”.
3. Vì vậy phải tách **việc thách thức hỗ trợ** khỏi **việc breakdown được chấp nhận bằng giá đóng cửa**.
4. LPSY là một rally yếu sau weakness/SOW. Nó thường không thể quay lại vùng resistance của trading range.
5. Rally LPSY cổ điển thường narrow/overlapping và demand yếu, nhưng volume tại LPSY có thể nhẹ hoặc nặng: nhẹ có thể biểu hiện thiếu cầu, nặng có thể biểu hiện supply đáng kể. Vì vậy low volume không được làm hard gate của LPSY identity.
6. Có thể có nhiều SOW và nhiều LPSY trong cùng một cấu trúc.
7. SOW/LPSY không tự chứng minh Distribution; một range sau prior uptrend vẫn có thể là Reaccumulation cho đến khi hành vi sau đó giải quyết giả thuyết.
8. VSA yêu cầu background: No Demand sau weakness có giá trị hơn No Demand đứng riêng; high volume không tự nói được là mua hay bán.

## 3. Phát hiện kiến trúc trước khi đặc tả

SOW/LPSY là sự kiện **phụ thuộc trading-range context**. Nếu chỉ dùng “latest prior Pivot Low” như support, ta có nguy cơ gọi một breakdown cục bộ là SOW dù không liên quan đến range đang được Phase Engine theo dõi.

Vì vậy v0.1 đề xuất một lớp chuyên biệt:

`Core → Candidate → Structure/Location → Confirmation → Event → Structural Sequence → Range-Context Event (SOW/LPSY) → Phase/Context`

Điều này không tạo vòng phụ thuộc:

- Structural Sequence không phụ thuộc SOW/LPSY;
- SOW/LPSY chỉ đọc frozen range snapshot của Structural Sequence;
- Phase/Context đọc cả Structural Sequence và SOW/LPSY.

## 4. D01 — Chính sách nhãn

Mô-đun chỉ được công bố:

- `SOW-LIKE`;
- `LPSY-LIKE`;
- các observation/descriptor phụ trợ.

Không được công bố trực tiếp:

- `CANONICAL SOW`;
- `CANONICAL LPSY`;
- `DISTRIBUTION CONFIRMED`;
- `REDISTRIBUTION CONFIRMED`;
- `PHASE D CONFIRMED`;
- `PHASE E CONFIRMED`.

## 5. D02 — Nguồn range bắt buộc

SOW/LPSY v0.1 không dùng latest prior pivot làm range chính.

Nguồn range là frozen Structural Sequence snapshot:

- lower-sequence-derived range: `SC Low ↔ Automatic Rally High`;
- upper-sequence-derived range: `Automatic Reaction Low ↔ BC High`.

Mỗi range anchor phải có:

- SequenceOrdinal;
- RangeLow;
- RangeHigh;
- RangeWidth;
- climax/automatic-swing coordinates;
- snapshot validity.

`RangeWidth > 0` và mọi giá phải hữu hạn.

## 6. D03 — Hai range channel độc lập

Một thời điểm có thể còn historical/active lower-derived range và upper-derived range cùng tồn tại.

Không được ép chọn một range bằng một biến `CurrentRange` duy nhất trong Event Engine.

V0.1 phải hỗ trợ hai channel độc lập hoặc một event stream có `RangeAnchorSideCode`:

- 1 = `LOWER-SEQUENCE-DERIVED RANGE`;
- 2 = `UPPER-SEQUENCE-DERIVED RANGE`.

Nếu cùng một thanh thỏa SOW trên cả hai anchor, phải giữ cả hai event; Phase Engine sau này quyết định anchor nào thuộc hypothesis đang theo dõi.

## 7. D04 — SOW Price Challenge Observation

Với range anchor hợp lệ, tại thanh k:

```text
PreviousCloseValid = 1
PreviousClose_k >= RangeLow
Low_k <= RangeLow
Close_k < PreviousClose_k
```

thì:

`SOWPriceChallengeObservation = 1`.

Ý nghĩa: giá đi từ phía trong/trên hỗ trợ xuống thách thức lower boundary và có kết quả giảm theo close-to-close.

`Low == RangeLow` được tính là chạm support.

Không yêu cầu `Close < RangeLow` ở bước này.

## 8. D05 — SOW-LIKE cần expanded downside effort

Nguồn Wyckoff mô tả SOW thường đi kèm increased spread và volume. V0.1 dùng đúng các dải Core đã khóa làm operational thresholds:

```text
SOW_MinRSpread = 1.20
SOW_MinRVOL    = 1.25
```

`SOW-LIKE` khi:

```text
SOWPriceChallengeObservation == 1
AND RSpreadValid == 1
AND RVOLValid == 1
AND RSpread >= 1.20
AND RVOL >= 1.25
```

Các ngưỡng này là **quy tắc vận hành v0.1 dựa trên Core**, không phải con số do Wyckoff cổ điển quy định.

Nếu price challenge có nhưng effort data thiếu hoặc effort không đạt, vẫn giữ price observation nhưng không nâng `SOWCode=2`.

## 9. D06 — Breakdown relation tách khỏi SOW identity

Khi SOW-LIKE tồn tại, xuất:

`SOWSupportRelationCode`:

- 1 = `CLOSE ABOVE SUPPORT`;
- 2 = `CLOSE AT SUPPORT`;
- 3 = `CLOSE BELOW SUPPORT`.

Đồng thời:

```text
AcceptedBreakdownFlag = 1 khi Close < RangeLow
SupportChallengeOnlyFlag = 1 khi Low <= RangeLow AND Close >= RangeLow
```

`Close == RangeLow` không phải accepted breakdown.

Một SOW-LIKE có thể chưa “fall through the ice”; Phase Engine sẽ dùng response sau đó để diễn giải.

## 10. D07 — ClosePosition không phải hard gate

Không yêu cầu ClosePosition phải dưới một ngưỡng cố định để có SOW-LIKE.

Xuất descriptor:

- ClosePosition + validity;
- WeakCloseFlag nếu `ClosePosition < 0.40`;
- MidOrHigherCloseFlag nếu `ClosePosition >= 0.40`.

Ranh giới 0.40 lấy từ dải Core, chỉ để mô tả chất lượng đóng cửa.

## 11. D08 — DirectionalProgress / Effort-vs-Result là descriptor

Xuất:

- DirectionalProgress + validity;
- AbsDirectionalProgress + validity;
- EffortDirectionalResultStateCode nếu hợp lệ.

Không dùng một Effort-vs-Result code riêng lẻ để quyết định SOW identity.

Lý do: high effort + low result tại support có thể là absorption/stopping action; cần response và context để phân biệt.

## 12. D09 — Cho phép overlap với Stopping Volume / Absorption / Spring

Một SOW price challenge hoặc thậm chí SOW-LIKE có thể đồng thời có:

- Stopping-Volume-like evidence;
- Absorption-like evidence;
- Spring/Shakeout-like evidence nếu có penetration + reclaim theo hợp đồng Event tương ứng.

Không engine nào được ghi đè engine kia.

Overlap là bằng chứng mâu thuẫn/hữu ích cho Phase Engine, không phải lỗi.

## 13. D10 — SOW được công bố tại chính thanh k

`SOWCode`:

- 0 = `INSUFFICIENT DATA`;
- 1 = `NOT PRESENT`;
- 2 = `SOW-LIKE`.

SOW-LIKE là event tại completed bar k; không cần đợi k+1 để tồn tại.

Tuy nhiên phải xuất ImmediateResponse descriptor tại k+1 khi dữ liệu hợp lệ:

- `FurtherWeaknessFlag`: `Close_(k+1) < Close_k`;
- `SupportStillLostFlag`: nếu SOW close dưới support, `Close_(k+1) < RangeLow`;
- `RecoveredSupportFlag`: `Close_(k+1) >= RangeLow`.

Response không được backfill làm thay đổi SOWCode tại k.

## 14. D11 — Frozen SOW snapshot

Mỗi SOW-LIKE phải đóng băng:

- Symbol;
- RangeAnchorSideCode;
- SequenceOrdinal / RangeAnchorKey;
- SOW BarIndex/DateTime;
- OHLC;
- PreviousClose;
- RangeLow/RangeHigh/RangeWidth;
- RSpread/RVOL + validity;
- ClosePosition + validity;
- DirectionalProgress/AbsDirectionalProgress + validity;
- AcceptedBreakdownFlag;
- StoppingVolume/Absorption context nếu có;
- S/M/L context nếu upstream facade công bố;
- immediate-response fields khi KnownAt sau đó.

Range của SOW lịch sử không được cập nhật khi Structural Sequence tạo anchor mới.

## 15. D12 — Nhiều SOW được phép

Một range có thể có nhiều SOW-LIKE.

Mỗi SOW có:

- `SOWOrdinalWithinRange` = 1,2,3,...;
- event key riêng;
- frozen snapshot riêng.

Không có cờ “đã có SOW thì cấm SOW khác”.

## 16. D13 — Active SOW anchor cho future LPSY

Đối với từng RangeAnchorKey, SOW-LIKE mới nhất trở thành active SOW anchor cho **future LPSY candidates**.

SOW mới không sửa hoặc xóa LPSY đã gắn với SOW cũ.

Không dùng timeout theo số thanh.

## 17. D14 — Invalidation của active SOW anchor

Active SOW anchor không tự hết hạn chỉ vì thời gian trôi qua.

Nó mất quyền tạo LPSY mới khi một trong các điều kiện sau xảy ra:

1. SOW-LIKE mới hơn trên cùng RangeAnchorKey thay nó;
2. range anchor mới cùng channel đã supersede range cũ cho future events;
3. completed bar đóng **trên RangeHigh** của frozen SOW range, cho thấy price đã phục hồi vượt toàn bộ range;
4. source revision làm snapshot không còn hợp lệ.

Một rally quay lại bên trong range nhưng chưa vượt RangeHigh không làm SOW anchor mất hiệu lực.

## 18. D15 — LPSY là một rally cấu trúc, không phải một thanh tùy ý

LPSY-LIKE candidate phải là **confirmed Pivot High** của Structure/Location có extreme sau SOW origin.

Không dùng k+1 đơn lẻ làm LPSY.

Pivot confirmation chính là bằng chứng nhân quả rằng rally đã tạo local high và quay xuống đủ để Structure Engine xác nhận.

## 19. D16 — Phải tồn tại rally thật từ SOW

Với confirmed Pivot High candidate p:

```text
PivotHighExtremeBarIndex > SOWBarIndex
PivotHighPrice > SOWClose
```

Nếu `PivotHighPrice <= SOWClose`, không gọi là rally sau SOW và không thể là LPSY-LIKE.

## 20. D17 — LPSY phải thất bại trước RangeHigh

V0.1 định nghĩa LPSY-LIKE theo hình thái rally yếu sau SOW:

```text
LPSYPivotHigh < FrozenRangeHigh
```

Nếu Pivot High chạm hoặc vượt RangeHigh:

- không gọi LPSY-LIKE theo v0.1;
- xuất `UPPER-RANGE-CHALLENGE-AFTER-SOW` observation;
- Upthrust/UTAD interpretation thuộc engine/context khác.

So sánh là strict/no epsilon.

## 21. D18 — Không bắt LPSY phải retest đúng “ice”

Không hard-code khoảng cách LPSY với RangeLow bằng ATR/%.

LPSY có thể:

- hồi yếu và dừng dưới support cũ sau breakdown;
- quay lại gần support cũ;
- hồi sâu hơn vào trong range nhưng vẫn thất bại trước RangeHigh.

Xuất `LPSYRangePosition` và `DistanceToRangeLow/High` như descriptor.

## 22. D19 — Low volume / No Demand không phải hard gate của LPSY identity

Tài liệu Wyckoff cho phép LPSY có volume nhẹ **hoặc** nặng.

Do đó LPSY-LIKE identity chỉ phụ thuộc:

- SOW anchor hợp lệ;
- confirmed Pivot High sau SOW;
- rally thực sự;
- thất bại trước RangeHigh.

Không yêu cầu:

- NoDemandCandidate;
- CE_NoDemand_Confirmed;
- RVOL thấp;
- RSpread hẹp.

Các yếu tố này thuộc lớp quality/evidence.

## 23. D20 — LPSY quality descriptors, không weighted score

Tại LPSY extreme phải snapshot độc lập:

- `NarrowSpreadFlag`: `RSpread < 0.80`;
- `VeryNarrowSpreadFlag`: `RSpread < 0.60`;
- `RVOLContractedVsSOW`: `RVOL_LPSY < RVOL_SOW` nếu cả hai hợp lệ;
- `RSpreadContractedVsSOW`: `RSpread_LPSY < RSpread_SOW` nếu cả hai hợp lệ;
- ClosePosition + validity;
- DirectionalProgress + validity;
- EffortDirectionalResultStateCode;
- NoDemandCandidateCode nếu tọa độ trùng extreme;
- CE_NoDemand_Confirmed nếu confirmation coordinates khớp candidate extreme;
- Upthrust-like overlap nếu có.

Không cộng các cờ thành điểm số xác suất.

## 24. D21 — LPSY Evidence Class

Để Phase Engine đọc dễ hơn nhưng vẫn tránh weighted score, đề xuất categorical class:

- 0 = `INSUFFICIENT QUALITY DATA`;
- 1 = `STRUCTURAL LPSY ONLY`;
- 2 = `DIMINISHED-DEMAND COMPATIBLE`;
- 3 = `HIGH-EFFORT / POOR-RESULT COMPATIBLE`;
- 4 = `MIXED WEAK-RALLY EVIDENCE`.

Đề xuất mapping:

### Class 2

Khi có ít nhất một demand-diminution evidence rõ:

- CE_NoDemand_Confirmed khớp extreme; hoặc
- `NarrowSpreadFlag==1 AND RVOLContractedVsSOW==1`.

### Class 3

Khi LPSY effort cao nhưng upward result kém, ví dụ:

- RVOL thuộc high-effort band;
- EffortDirectionalResult = high effort / low directional result;
- và pivot đã confirmed quay xuống.

### Class 4

Khi có bằng chứng weak-rally nhưng không rơi sạch vào Class 2 hoặc 3, hoặc hai route cùng xuất hiện.

Class chỉ mô tả kiểu bằng chứng, không nói “xác suất Distribution”.

## 25. D22 — No Demand phải tuân thủ background contract

No Demand tại/giữa rally LPSY chỉ được Phase Engine coi là bearish supporting evidence vì nó xuất hiện **sau SOW/weakness background**.

SOW/LPSY Engine chỉ snapshot tọa độ và trạng thái No Demand; không tự tạo lệnh giao dịch.

No Demand ngoài SOW context không được engine này kéo vào làm LPSY evidence.

## 26. D23 — KnownAt-time của LPSY

LPSY origin là Pivot High extreme.

LPSY chỉ KnownAt khi Pivot High được Structure/Location xác nhận.

Phải xuất tách:

- `LPSYOriginExtremeBarIndex/DateTime`;
- `LPSYPivotConfirmBarIndex/DateTime`;
- `LPSYKnownAtBarIndex/DateTime`.

Không backfill label về extreme bar như thể engine đã biết trước pivot.

## 27. D24 — Nhiều LPSY được phép

Một SOW/range có thể tạo nhiều LPSY-LIKE.

Mỗi LPSY có:

- `LPSYOrdinalWithinSOWAnchor`;
- frozen SOW key;
- frozen range key;
- evidence snapshot riêng.

Không có cờ “đã có LPSY thì cấm LPSY sau”.

## 28. D25 — Relation với Upthrust / Structural ST

Một Pivot High sau SOW có thể đồng thời là:

- LPSY-LIKE;
- một Structural ST theo sequence khác;
- hoặc Upthrust-like nếu hợp đồng riêng thỏa.

Không ưu tiên hoặc ghi đè giữa các engine.

Riêng trường hợp `LPSYPivotHigh >= FrozenRangeHigh`, LPSY v0.1 không gắn label nhưng vẫn xuất upper-range-challenge observation để Phase Engine có thể liên kết với Upthrust/UTAD path.

## 29. D26 — SOW/LPSY không tự suy ra Distribution/Redistribution

Sau một SOW-LIKE đơn lẻ chỉ được nói:

`WEAKNESS EVENT OBSERVED IN FROZEN RANGE CONTEXT`.

Sau SOW + LPSY chỉ được nói:

`SOW/LPSY WEAKNESS SEQUENCE-LIKE OBSERVED`.

Không tự gọi Distribution hoặc Redistribution.

Phase Engine phải kết hợp prior trend, Phase-A anchor, Phase C context, SOS/LPS cạnh tranh, Spring/Upthrust, VSA background và hành vi breakout/breakdown sau đó.

## 30. D27 — Event keys

### RangeAnchorKey

Dùng key bất biến từ Structural Sequence, tối thiểu:

```text
Symbol
+ RangeAnchorSideCode
+ SequenceOrdinal
+ ClimaxExtremeBarIndex
+ AutomaticSwingExtremeBarIndex
```

### SOWEventKey

```text
RangeAnchorKey
+ SOWBarIndex
+ SOWDateTime
```

### LPSYEventKey

```text
SOWEventKey
+ LPSYExtremeBarIndex
+ LPSYConfirmBarIndex
```

## 31. D28 — Data validity tách theo bước

Không dùng `AllInputsValid` chung.

- Range invalid → SOW channel insufficient;
- PreviousClose/price invalid → price challenge insufficient;
- effort invalid → SOW classification insufficient nhưng price challenge có thể vẫn quan sát được nếu price data đủ;
- SOW snapshot hợp lệ nhưng pivot chưa confirmed → LPSY đang chờ, không phải reject;
- LPSY price/structure đủ nhưng RVOL/RSpread/NoDemand data thiếu → LPSY identity vẫn có thể tồn tại, quality class=0 hoặc chỉ structural tùy dữ liệu;
- source revision phải được phân biệt với algorithmic repaint.

## 32. D29 — Causality / completed-bar contract

Phạm vi v0.1: Daily completed bars.

- không Zig/Peak/Trough nhìn tương lai;
- chỉ dùng confirmed pivots và current/past data;
- forming bar provisional;
- không dùng BarCount để tuyên bố phiên đã đóng;
- không backfill;
- source revision phải được ghi riêng.

## 33. D30 — Không có trading/tuning trong Event Engine

Không tạo:

- Buy/Sell/Short/Cover;
- PositionSize;
- stop/target;
- xác suất;
- điểm tổng hợp bullish/bearish;
- P&F objective;
- auto-tuning thresholds theo backtest.

Các ngưỡng 1.20/1.25/0.80 chỉ được thay đổi bằng version/spec mới sau nghiên cứu và kiểm thử.

## 34. D31 — Điều kiện chuyển sang triển khai

Chỉ sau khi chủ dự án phê duyệt D01–D31:

1. khóa đặc tả SOW/LPSY;
2. merge docs-only PR vào `main`;
3. tạo nhánh implementation xếp chồng trên Structural Sequence PR #21, vì module cần frozen range snapshot D29;
4. không viết lại Structural Sequence trong SOW/LPSY;
5. không viết SOW/LPSY tạm bên trong Phase Engine;
6. implementation sau đó chỉ được gọi `SPEC-ALIGNED / UNTESTED DEVELOPMENT` cho đến chiến dịch kiểm thử tổng thể;
7. chỉ khi SOW/LPSY implementation contract ổn định mới mở full AFL Phase/Context theo D38.

## 35. Đầu ra tối thiểu

Cho mỗi range channel:

- RangeAnchorValid / RangeAnchorKey / SideCode / SequenceOrdinal;
- RangeLow / RangeHigh / Width;
- SOWPriceChallengeObservation + validity;
- SOWCode + validity;
- SOWOrdinalWithinRange;
- SOW OHLC / PreviousClose;
- SOW support relation / AcceptedBreakdown / SupportChallengeOnly;
- SOW RVOL/RSpread/ClosePosition/DirectionalProgress/EffortResult + validity;
- SOW StoppingVolume/Absorption overlap;
- SOW immediate-response descriptors;
- active SOW anchor state;
- LPSYLikeCode + validity;
- LPSY origin / confirm / known-at coordinates;
- LPSYOrdinalWithinSOWAnchor;
- LPSY High / RangePosition / distance to boundaries;
- Narrow/VeryNarrow flags;
- RVOL/RSpread contraction flags;
- NoDemand candidate/confirmation linkage;
- LPSYEvidenceClassCode;
- upper-range-challenge-after-SOW observation;
- frozen event keys.

## 36. Phản ví dụ bắt buộc

1. Giá giảm nhưng chưa chạm RangeLow → không SOW price challenge.
2. Low chạm RangeLow, Close giảm, nhưng RSpread/RVOL không đạt → price challenge có, SOW-LIKE không có.
3. Low xuyên support nhưng Close mạnh trở lại trên support, effort cao → vẫn có thể SOW-LIKE challenge; AcceptedBreakdown=0; Spring/Absorption overlap được phép.
4. Close dưới RangeLow với wide spread/high volume → SOW-LIKE, AcceptedBreakdown=1.
5. SOW có high volume nhưng k+1 hồi mạnh → SOW lịch sử không bị xóa; response ghi recovered support.
6. Pivot High sau SOW chưa được confirmed → chưa LPSY-LIKE.
7. Confirmed Pivot High sau SOW nhưng không cao hơn SOWClose → không phải rally, không LPSY.
8. Rally pivot high vẫn dưới RangeHigh → đủ structural relation cho LPSY.
9. Rally chạm đúng RangeHigh → không LPSY v0.1; upper-range-challenge observation.
10. Rally vượt RangeHigh rồi đóng lại trong range → không LPSY v0.1; có thể overlap Upthrust path.
11. LPSY volume thấp/narrow spread → diminished-demand-compatible evidence.
12. LPSY volume cao nhưng upward result nghèo → high-effort/poor-result-compatible evidence; không loại LPSY.
13. LPSY không có No Demand → LPSY identity vẫn có thể tồn tại.
14. No Demand xuất hiện nhưng không có SOW background/rally structure → không tạo LPSY.
15. Nhiều SOW trong một range → ordinal tăng, SOW mới là active anchor cho LPSY tương lai.
16. Nhiều LPSY sau cùng SOW → ordinal tăng, không ghi đè.
17. Structural range mới supersede → historical SOW/LPSY cũ không đổi.
18. Lower-derived và upper-derived range cùng active → event channels độc lập.
19. SOW/LPSY xuất hiện trong range cuối cùng trở thành Reaccumulation → Event Engine không tự gọi Distribution.
20. Forming bar thay đổi volume/high/low → chỉ provisional.

## 37. Bảng quyết định cần phê duyệt

| Mã | Đề xuất | Khuyến nghị |
|---|---|---|
| D01 | Chỉ nhãn `-LIKE`, không phase canonical | Chấp thuận mạnh |
| D02 | Dùng frozen Structural Sequence range, không latest pivot đơn lẻ | Chấp thuận mạnh |
| D03 | Hai range channel độc lập | Chấp thuận mạnh |
| D04 | SOW price challenge: PrevClose>=RangeLow, Low<=RangeLow, Close<PrevClose | Chấp thuận mạnh |
| D05 | SOW-LIKE cần RSpread>=1.20 và RVOL>=1.25 | Chấp thuận |
| D06 | Tách challenge khỏi accepted breakdown | Chấp thuận mạnh |
| D07 | ClosePosition chỉ descriptor | Chấp thuận mạnh |
| D08 | Effort-vs-Result chỉ descriptor | Chấp thuận mạnh |
| D09 | Cho overlap Stopping/Absorption/Spring | Chấp thuận mạnh |
| D10 | SOW công bố tại k; k+1 chỉ response descriptor | Chấp thuận mạnh |
| D11 | Frozen SOW snapshot | Chấp thuận mạnh |
| D12 | Nhiều SOW được phép | Chấp thuận mạnh |
| D13 | SOW mới supersede future LPSY anchor, không timeout | Chấp thuận mạnh |
| D14 | Invalidate active SOW anchor chỉ bởi sự kiện nhân quả | Chấp thuận |
| D15 | LPSY dùng confirmed Pivot High, không k+1 bar | Chấp thuận mạnh |
| D16 | Phải có rally thật: PivotHigh>SOWClose | Chấp thuận mạnh |
| D17 | LPSY pivot high phải < FrozenRangeHigh | Chấp thuận |
| D18 | Không bắt LPSY gần đúng RangeLow bằng ATR/% | Chấp thuận mạnh |
| D19 | Low volume/No Demand không hard-gate LPSY identity | Chấp thuận mạnh |
| D20 | Quality giữ thành descriptor độc lập | Chấp thuận mạnh |
| D21 | Categorical evidence class, không weighted score | Chấp thuận |
| D22 | No Demand chỉ có nghĩa bearish khi có weakness background | Chấp thuận mạnh |
| D23 | Origin-time tách KnownAt-time | Chấp thuận mạnh |
| D24 | Nhiều LPSY được phép | Chấp thuận mạnh |
| D25 | Overlap với Upthrust/ST, không ghi đè | Chấp thuận mạnh |
| D26 | Không suy ra Distribution/Redistribution | Chấp thuận mạnh |
| D27 | Event keys bất biến | Chấp thuận |
| D28 | Validity tách theo bước | Chấp thuận mạnh |
| D29 | Daily completed-bar, causal, no backfill | Chấp thuận mạnh |
| D30 | No trading/no auto-tuning | Chấp thuận mạnh |
| D31 | SOW/LPSY phải triển khai riêng trước full Phase AFL theo D38 | BẮT BUỘC |
