# Wyckoff Event — Đặc tả dự thảo SOS / LPS v0.1

**Trạng thái:** DỰ THẢO ĐỂ CHỦ DỰ ÁN PHÊ DUYỆT. Chưa khóa, chưa phải tiêu chí nghiệm thu và không cho phép dùng tài liệu này để tuyên bố AFL hiện có ở PR #14 là đúng. Không sửa Core, Candidate, Structure/Location, Confirmation, Supply Test, Spring/Shakeout hoặc Upthrust.

## 1. Mục tiêu và ranh giới

Mô-đun này xử lý hai nhóm hành vi phía sức mạnh:

- một nhịp tăng có **độ rộng giá mở rộng, khối lượng tương đối cao và phá một kháng cự đã được biết trước**, được lớp Event gọi thận trọng là `SOS-LIKE`;
- một **phản ứng/pullback sau SOS-LIKE** tạo đáy cục bộ, giữ được vùng hỗ trợ do kháng cự cũ chuyển vai trò và sau đó có phản ứng tăng, được lớp Event gọi là `LPS-LIKE`.

Luồng kiến trúc:

`Core → Candidate → Structure/Location → Confirmation → Wyckoff Event → Phase/Context`

Điểm quan trọng: v0.1 không tự khẳng định `SOS` hay `LPS` cổ điển theo toàn bộ sơ đồ Wyckoff. Tên `-LIKE` được giữ cho đến khi Phase/Context Engine có đủ bối cảnh về trading range, Phase C/D và sự chuyển quyền kiểm soát từ cung sang cầu.

Không phát Buy/Sell, không quản trị vốn, không chấm điểm xác suất và không tự gán Accumulation/Phase D.

## 2. Cơ sở nghiên cứu trước khi đặc tả

### 2.1. Các điểm được tài liệu Wyckoff hỗ trợ trực tiếp

Các nguồn tham khảo chính:

- Wyckoff Analytics — Wyckoff Method: https://www.wyckoffanalytics.com/wyckoff-method/
- StockCharts ChartSchool — The Wyckoff Method: A Tutorial: https://chartschool.stockcharts.com/table-of-contents/market-analysis/wyckoff-analysis-articles/the-wyckoff-method-a-tutorial
- StockCharts — Wyckoff Power Charting: Let’s Review: https://articles.stockcharts.com/article/articles-wyckoff-2015-07-wyckoff-power-charting-lets-review/
- StockCharts — Phase Analysis. Two Case Studies: https://stockcharts.com/articles/wyckoff/2016/08/phase-analysis-two-case-studies.html

Các điểm nhất quán giữa các nguồn:

1. `SOS` là một nhịp tăng giá có spread mở rộng và volume tương đối cao; thường xuất hiện sau quá trình test cung và có thể xác nhận cách đọc Spring/Shakeout trước đó.
2. Trong Phase D, các nhịp tăng kiểu SOS thường đi kèm spread mở rộng/volume tăng, trong khi các phản ứng LPS có spread nhỏ hơn và volume giảm.
3. `LPS` là điểm thấp của một phản ứng/pullback sau SOS; “backing up” thường là quay lại vùng hỗ trợ từng là kháng cự.
4. Có thể có **nhiều LPS**, nên chữ “Last” không có nghĩa thuật toán phải chỉ cho phép đúng một LPS trong toàn cấu trúc.
5. Một LPS không nhất thiết luôn có volume tuyệt đối thấp. Các case study có thể vẫn gắn nhãn LPS khi volume cao nhưng hành vi giá/bối cảnh cho thấy demand/absorption. Vì vậy không nên biến một ngưỡng volume thấp đơn lẻ thành điều kiện định nghĩa bắt buộc.
6. Một SOS có thể là minor SOS trước khi vượt toàn bộ trading-range resistance; major/canonical SOS chỉ có thể được phân loại chắc hơn khi Phase Engine biết cấu trúc lớn.

### 2.2. Hệ quả thiết kế

Từ nghiên cứu trên, v0.1 không được:

1. gọi mọi breakout giá là SOS nếu spread/volume không thể hiện sức mạnh;
2. yêu cầu Spring phải xuất hiện trước SOS;
3. dùng một `MaxBarsAfterSOS = 10` tùy ý để quyết định LPS còn hợp lệ hay không;
4. bắt LPS phải nằm trong đúng `0.50 ATR` quanh BreakoutLevel như điều kiện định nghĩa;
5. bắt LPS phải có `NoSupplyCandidateCode=2` mới tồn tại;
6. bắt Confirmation No Supply tại k+1 như điều kiện duy nhất xác nhận LPS;
7. coi một LPS-LIKE đơn lẻ là bằng chứng đủ để gán Phase D hoặc Accumulation.

Đây là các điểm cần sửa đáng kể so với đặc tả phát triển và AFL ban đầu ở PR #14.

## 3. D01 — Chính sách nhãn ở lớp Event

Lớp Event v0.1 được phép công bố:

- `SOS-LIKE`;
- `LPS-LIKE`;
- các observation/descriptor phụ trợ.

Không công bố trực tiếp:

- `MAJOR SOS`;
- `PHASE D SOS`;
- `CANONICAL LPS`;
- `ACCUMULATION CONFIRMED`.

Các nhãn phụ thuộc trading range/phase dành cho Phase/Context Engine tương lai.

## 4. D02 — Nguồn kháng cự cho SOS-LIKE

Nguồn kháng cự duy nhất của SOS-LIKE v0.1 là **pivot High gần nhất đã được xác nhận trước thanh k**:

`SL_PivotHighLatestPrior...`

`ResistanceValid_k = 1` khi đồng thời:

- `SL_PivotHighLatestPriorValid_k = 1`;
- ResistancePrice hữu hạn và `> 0`;
- ExtremeBarIndex/DateTime tồn tại;
- ConfirmBarIndex/DateTime tồn tại;
- `ConfirmBarIndex < BarIndex_k`.

Không dùng pivot High mới chỉ xác nhận tại chính k.

S/M/L chỉ là bối cảnh nghiên cứu, không làm resistance fallback.

## 5. D03 — SOS phải là cú phá mới từ phía dưới/trong vùng

Để tránh gọi một thanh đang ở rất lâu phía trên pivot cũ là “SOS breakout”, đề xuất yêu cầu:

```text
PreviousClose_k <= ResistancePrice_k
```

`PreviousClose_k = Close_(k-1)` và phải hợp lệ.

Không yêu cầu `High_(k-1) <= Resistance`, vì thanh trước có thể đã test phía trên nhưng chưa được chấp nhận bằng giá đóng cửa.

## 6. D04 — Kênh Price Breakout Observation

Trước khi xét effort, hệ thống nên giữ một observation giá độc lập:

```text
WE_SL_SOSPriceBreakoutObservation = 1
```

khi:

```text
ResistanceValid = 1
PreviousCloseValid = 1
PreviousClose <= Resistance
High_k > Resistance
Close_k > Resistance
Close_k > PreviousClose
```

So sánh là strict/no epsilon đối với breakout:

- `High == Resistance` không phải penetration;
- `Close == Resistance` không phải accepted close above resistance.

Observation này **chưa phải SOS-LIKE**. Nó chỉ xác nhận rằng giá đã phá và đóng cửa trên resistance với tiến triển tăng.

## 7. D05 — Effort/Spread là thành phần bắt buộc để gọi SOS-LIKE

Khác với Upthrust, bản chất SOS theo các nguồn Wyckoff có chứa thông tin về **spread mở rộng và volume tương đối tăng**. Vì vậy v0.1 đề xuất chỉ gọi `SOS-LIKE` khi price breakout observation ở D04 tồn tại và effort data hợp lệ.

Dùng chính các dải mô tả đã có của Core v1.0 làm ngưỡng kỹ thuật, không tạo hệ quy chiếu mới:

```text
WE_SL_SOS_MinRSpread = 1.20
WE_SL_SOS_MinRVOL    = 1.25
```

Trong Core v1.0:

- `RSpread >= 1.20` bắt đầu khỏi dải NORMAL để sang WIDE hoặc cao hơn;
- `RVOL >= 1.25` bắt đầu khỏi dải NORMAL để sang HIGH hoặc cao hơn.

`SOS-LIKE` tại k khi:

```text
SOSPriceBreakoutObservation = 1
RSpreadValid = 1
RVOLValid = 1
RSpread >= 1.20
RVOL >= 1.25
```

Nếu price breakout đạt nhưng effort thiếu hoặc không đạt ngưỡng, vẫn giữ PriceBreakoutObservation nhưng `SOSCode != 2`.

Các ngưỡng 1.20/1.25 là **quy tắc vận hành v0.1 dựa trên dải Core**, không được mô tả như con số do Wyckoff cổ điển quy định. Khi quay lại chiến dịch kiểm thử, ngưỡng sẽ được kiểm định nhưng không được tự ý tuning theo kết quả nếu chưa version hóa đặc tả.

## 8. D06 — ClosePosition là quality descriptor, không phải hard gate của SOS

PR #14 cũ yêu cầu `ClosePosition >= 0.60` để có SOS-LIKE.

Đặc tả mới đề xuất không dùng điều này làm hard gate, vì điều kiện `Close > Resistance` đã xác nhận mức giá mới được giữ ở cuối thanh; vị trí close trong toàn spread chỉ cho biết chất lượng của thanh.

Xuất:

```text
WE_SL_SOS_StrongCloseFlag = 1
khi ClosePositionValid = 1 và ClosePosition > 0.60
```

Biên `0.60` chỉ là descriptor theo dải Core; không thay đổi `SOSCode`.

## 9. D07 — Không yêu cầu Spring/Shakeout trước SOS

Spring/Shakeout có thể làm tăng chất lượng câu chuyện Wyckoff và SOS sau đó có thể xác nhận interpretation của Spring, nhưng Accumulation Schematic #2 có thể không có Spring.

Vì vậy:

- Spring/Shakeout không phải gate của SOS-LIKE;
- nếu có event Spring/Shakeout prior, chỉ snapshot như context;
- Phase Engine tương lai mới dùng quan hệ chuỗi `Spring/Test → SOS` để nâng mức tin cậy của phase hypothesis.

## 10. D08 — SOS được công bố tại cuối chính thanh k

`SOS-LIKE` là hành vi được quan sát ở thanh k; không bắt buộc phải chờ k+1 mới tạo SOSCode.

`WE_SL_SOSCode`:

- 0 = `INSUFFICIENT DATA`;
- 1 = `NOT PRESENT`;
- 2 = `SOS-LIKE`.

Code0 khi dữ liệu bắt buộc cho **việc phân loại SOS** không hợp lệ, ví dụ resistance/previous close/price/effort không đủ.

PriceBreakoutObservation có validity riêng để vẫn bảo toàn thông tin giá nếu effort thiếu.

Có thể xuất k+1 follow-through/hold-above-breakout như descriptor cho Phase Engine, nhưng không được retroactively quyết định SOSCode của k.

## 11. D09 — Snapshot SOS và BreakoutLevel

Khi `SOSCode=2`, phải snapshot tối thiểu:

- SOSBarIndex / SOSDateTime;
- SOS High / Low / Close;
- PreviousClose;
- ResistancePrice = `BreakoutLevel`;
- pivot High ExtremeBarIndex/DateTime;
- pivot High ConfirmBarIndex/DateTime;
- resistance Age/BarsSinceConfirmation nếu có;
- RSpread và validity;
- RVOL và validity;
- ClosePosition và validity;
- PriorATR và validity;
- penetration trên resistance và PenetrationATR nếu hợp lệ;
- S/M/L context nếu xuất.

BreakoutLevel của một SOS đã tạo phải bất biến cho mọi LPS candidate tham chiếu SOS đó.

## 12. D10 — Vòng đời của SOS anchor cho LPS: không dùng timeout 10 thanh

PR #14 dùng `WE_SL_LPS_MaxBarsAfterSOS = 10`. Không có cơ sở Wyckoff đủ mạnh để coi thanh thứ 11 tự động làm mất ý nghĩa cấu trúc.

Đề xuất **không đặt tuổi tối đa cứng trong v0.1**.

SOS anchor gần nhất duy trì trạng thái có thể tham chiếu cho đến khi một trong các điều kiện nhân quả xảy ra:

1. có SOS-LIKE mới hơn → SOS mới trở thành anchor cho candidate mới;
2. một thanh hoàn tất `Close < BreakoutLevel` → breakout support bị thất bại và anchor cũ không còn đủ điều kiện tạo LPS-LIKE mới;
3. dữ liệu anchor bị invalid do source revision → xử lý như data revision, không gọi algorithmic repaint.

Phải xuất `BarsSinceSOS` để sau này nghiên cứu tuổi sự kiện thay vì hard-code timeout chưa có bằng chứng.

Một wick `Low < BreakoutLevel` nhưng `Close >= BreakoutLevel` không tự hủy anchor; tuy nhiên thanh đó không thỏa LPS-LIKE strict-hold và có thể thuộc họ Spring/Shakeout/reclaim khác.

## 13. D11 — LPS-LIKE phải xuất hiện trong một phản ứng sau SOS

LPS là low point của reaction/pullback sau SOS, không phải một thanh No Supply bất kỳ ở gần BreakoutLevel.

Đề xuất một `LPS-LIKE CANDIDATE` origin tại k chỉ có thể hình thành khi:

- có SOS anchor active từ một thanh trước đó;
- dữ liệu giá k và k-1 hợp lệ;
- k thể hiện một nhịp phản ứng xuống tối thiểu qua:

```text
Close_k < Close_(k-1)
OR Low_k < Low_(k-1)
```

- `Low_k >= BreakoutLevel` của SOS anchor.

Điều kiện này cho phép chuỗi phản ứng nhiều thanh. Nếu k chưa phải đáy, k+1 tiếp tục giảm thì candidate k sẽ bị bác bỏ; k+1 có thể tự trở thành candidate mới. Khi phản ứng thực sự tạo đáy, resolution ở thanh sau sẽ xác nhận cục bộ.

Không yêu cầu Close của origin phải là down-bar tuyệt đối nếu Low vẫn tạo lower low trong phản ứng.

## 14. D12 — Không dùng khoảng cách 0.50 ATR làm hard gate LPS

PR #14 cũ yêu cầu:

```text
BreakoutLevel <= Low <= BreakoutLevel + 0.50 * PriorATR
```

Đặc tả mới bỏ upper-distance hard gate.

Lý do:

- các nguồn Wyckoff mô tả LPS là reaction/pullback sau SOS và thường back up về support cũ;
- nhưng case study cũng nhấn mạnh rằng **retrace ít hơn có thể là biểu hiện mạnh hơn**, và LPS có thể dừng cao hơn nhiều so với mép trading range;
- dùng 0.50 ATR có nguy cơ loại các higher-low LPS có ý nghĩa.

V0.1 giữ điều kiện bảo vệ cấu trúc:

```text
Low_k >= BreakoutLevel
```

và xuất descriptor:

```text
DistanceAboveBreakout = Low_k - BreakoutLevel
DistanceAboveBreakoutATR = DistanceAboveBreakout / PriorATR_k
```

Nếu muốn đánh dấu một backup gần mép kháng cự cũ, có thể xuất:

```text
NearBreakoutEdgeFlag = DistanceAboveBreakoutATR <= 0.50
```

nhưng flag này **không quyết định LPS identity**.

## 15. D13 — Spread/Volume giảm là quality evidence của LPS, không phải hard gate tuyệt đối

Nguồn Wyckoff mô tả phản ứng LPS điển hình có spread nhỏ hơn và volume giảm so với advance/SOS. Tuy nhiên các case study cũng có LPS volume cao do demand/absorption, nên volume thấp không thể là điều kiện bắt buộc tuyệt đối.

Đề xuất snapshot effort của SOS anchor và so sánh tại LPS origin:

```text
SpreadContractedVsSOS = RSpread_k < SOS_RSpread
VolumeContractedVsSOS = RVOL_k < SOS_RVOL
TextbookSupplyContraction = SpreadContractedVsSOS AND VolumeContractedVsSOS
```

Nếu RSpread/RVOL thiếu, các flag quality có validity=0 nhưng không làm mất LPS origin nếu price/structure contract vẫn đủ.

Có thể xuất thêm:

- `NoSupplyCandidateAtOrigin`;
- `NoSupplyConfirmedAtEvaluation`;
- `LowEffortFlag` theo Core;

nhưng đây là context evidence, không phải gate của LPS-LIKE.

## 16. D14 — Không bắt buộc No Supply Candidate cho LPS origin

PR #14 yêu cầu `NoSupplyCandidateCode=2` tại origin. Đề xuất bỏ hard gate này.

Lý do:

- LPS là khái niệm cấu trúc về reaction low sau SOS;
- No Supply là một pattern VSA hẹp hơn;
- một LPS có thể có absorption/demand với volume không thấp, do đó không phải LPS nào cũng là No Supply bar.

No Supply được giữ làm bằng chứng bổ sung để Composite/Phase Engine đánh giá chất lượng phản ứng.

## 17. D15 — Xác nhận LPS-LIKE tại k+1 bằng phản ứng giá, không phụ thuộc duy nhất CE No Supply

Origin LPS-LIKE candidate tại k chỉ được resolve tại:

```text
t = k + 1
```

Đề xuất `LPS-LIKE CONFIRMED` khi đồng thời:

```text
EvaluationPriceValid_t = 1
Low_t >= BreakoutLevel_frozen
Low_t >= Low_k
Close_t > Close_k
```

Ý nghĩa:

- breakout support vẫn được giữ;
- k không bị phá xuống thành đáy thấp hơn ngay ở thanh kế tiếp;
- có phản ứng giá tăng sau candidate low.

Không yêu cầu `CE_NoSupply_StatusCode=3` để ResolutionCode=3. Nếu Confirmation No Supply tồn tại và trỏ đúng k, nó được xuất như quality/context evidence riêng.

## 18. D16 — Hợp đồng LPS Origin/Resolution

`WE_SL_LPSOriginCode`:

- 0 = `INSUFFICIENT DATA`;
- 1 = `NOT PRESENT`;
- 2 = `LPS-LIKE CANDIDATE`.

OriginReasonCode đề xuất tối thiểu:

- 0: không lỗi / không áp dụng;
- 1: không có SOS anchor active;
- 2: dữ liệu giá origin/prior không hợp lệ;
- 3: không có reaction progress;
- 4: Low xuống dưới frozen BreakoutLevel;
- 5: anchor invalidated bởi close dưới BreakoutLevel;
- 6: snapshot anchor không hợp lệ.

`WE_SL_LPSResolutionCode`:

- 0 = `INSUFFICIENT DATA`;
- 1 = `NO PRIOR LPS-LIKE CANDIDATE`;
- 2 = `LPS-LIKE REJECTED`;
- 3 = `LPS-LIKE CONFIRMED`.

`WE_SL_LPSConfirmed = 1` chỉ khi ResolutionCode=3.

ResolutionReasonCode phải phân biệt ít nhất:

- evaluation price invalid;
- support break;
- lower low tiếp diễn;
- close không cải thiện;
- nhiều điều kiện cùng thất bại.

## 19. D17 — Không xác nhận muộn và cho phép candidate nối tiếp

Không xác nhận origin k tại k+2 hoặc muộn hơn.

Nếu k+1 tiếp tục giảm:

- origin k bị reject;
- nếu k+1 vẫn đủ điều kiện reaction và support hold, nó có thể là origin candidate mới;
- k+2 chỉ resolve candidate của k+1.

Cách này giữ nhân quả và tự nhiên chọn ra low point cuối cùng của phản ứng mà không cần nhìn trước nhiều thanh.

## 20. D18 — Cho phép nhiều LPS sau một SOS

Tài liệu Wyckoff ghi nhận có thể có nhiều LPS.

Do đó:

- một SOS anchor có thể sinh nhiều LPS-LIKE đã xác nhận nếu sau đó có nhiều reaction/pullback riêng biệt mà support vẫn giữ;
- không dùng cờ “LPS đã xuất hiện rồi thì cấm LPS tiếp theo”;
- mỗi event có key riêng.

Event key đề xuất:

```text
Symbol
+ LPSOriginBarIndex
+ LPSOriginDateTime
+ SOSAnchorBarIndex
+ SOSResistancePivotConfirmBarIndex
```

SOS mới hơn có thể thay anchor cho candidate tương lai nhưng không sửa event lịch sử.

## 21. D19 — Quan hệ LPS với Backup/BUEC

`Back-Up`/`BUEC` là khái niệm gần LPS nhưng không nên ép đồng nhất trong v0.1.

Đề xuất:

- `LPS-LIKE` = reaction low có cấu trúc giữ support sau SOS theo D11–D17;
- `NearBreakoutEdgeFlag` cho biết pullback có thực sự back up gần resistance cũ hay không;
- Phase/Context Engine sau này mới quyết định có đủ điều kiện gọi `BUEC` trong trading range cụ thể hay không.

Không thêm BUEC như event chính thức ở v0.1.

## 22. D20 — Quan hệ với Phase D và canonical SOS/LPS

Event layer chỉ công bố `SOS-LIKE`/`LPS-LIKE`.

Phase/Context Engine tương lai phải có quyền phân biệt:

- local strength breakout ngoài Accumulation;
- minor SOS trong trading range;
- major SOS/JAC trong Phase D;
- LPS ở Phase C;
- LPS/BUEC sau SOS trong Phase D;
- pullback bình thường trong markup không còn thuộc accumulation.

Nếu Phase Engine sau này nâng event thành canonical `SOS` hoặc `LPS`, thời điểm công bố phải là thời điểm bối cảnh đủ bằng chứng. Có thể tham chiếu về EventBarIndex cũ nhưng không backfill lịch sử như thể phase label đã biết sớm hơn.

## 23. D21 — Snapshot và kênh độc lập

Các kênh sau phải độc lập:

- SOS PriceBreakoutObservation;
- SOS-LIKE event;
- LPS-LIKE origin;
- LPS-LIKE resolution;
- quality/context descriptors.

Một thanh có thể đồng thời:

- resolve LPS từ thanh trước;
- tạo LPS candidate mới;
- hoặc tạo SOS-LIKE mới.

Không dùng một StatusCode duy nhất để chọn ngầm event “quan trọng hơn”.

LPS resolution phải mang nguyên frozen snapshot của SOS anchor và origin k; pivot/SOS mới ở k+1 không được thay dữ liệu event đang resolve.

## 24. D22 — Nhân quả, thanh hoàn tất và không giao dịch tự động

Phạm vi nghiên cứu hiện tại: Daily, dữ liệu thanh đã hoàn tất.

- thanh cuối chưa được nguồn xác nhận hoàn tất chỉ là provisional;
- không dùng BarCount để tự suy đoán thanh đã đóng;
- không dùng Zig/Peak/Trough nhìn tương lai;
- không backfill event;
- source revision phải phân biệt với algorithmic repaint;
- không tạo/ghi đè Buy, Sell, Short, Cover, PositionSize, stop, order hay điểm xác suất giao dịch.

Exploration chỉ xuất trạng thái, tọa độ, snapshot, validity và descriptor nghiên cứu.

## 25. Phản ví dụ bắt buộc

Các trường hợp sau phải được xử lý đúng:

1. High chỉ chạm resistance → không breakout.
2. High xuyên nhưng Close không vượt resistance → không SOS PriceBreakoutObservation.
3. Breakout giá đẹp nhưng RSpread/RVOL thiếu → giữ price observation, không gọi SOS-LIKE.
4. Breakout giá đẹp nhưng effort vẫn NORMAL → không gọi SOS-LIKE.
5. ClosePosition <0.60 nhưng breakout + effort đủ → vẫn có thể SOS-LIKE; StrongCloseFlag=0.
6. Không có Spring trước đó nhưng breakout + effort đủ → vẫn có thể SOS-LIKE.
7. SOS đã 11+ thanh nhưng chưa bị invalidated → không tự hết hạn chỉ vì tuổi.
8. LPS candidate nằm cao hơn BreakoutLevel >0.50 ATR nhưng tạo reaction low hợp lệ → không loại chỉ vì xa breakout edge.
9. LPS có high volume/absorption → không loại chỉ vì RVOL không thấp.
10. No Supply Candidate không xuất hiện → vẫn có thể LPS-LIKE nếu cấu trúc/price response đủ.
11. Reaction tiếp tục lower low ở k+1 → candidate k bị reject; k+1 có thể thành candidate mới.
12. k+1 Low không thấp hơn k nhưng Close không tăng → chưa xác nhận LPS-LIKE.
13. k+1 Close tăng nhưng Low xuyên dưới BreakoutLevel → reject LPS-LIKE strict support hold.
14. k+1 reject, k+2 mới bật mạnh → không hồi sinh candidate k.
15. Có nhiều reaction sau một SOS → cho phép nhiều LPS-LIKE.
16. SOS mới xuất hiện trong khi LPS cũ đang resolve → resolution dùng frozen anchor cũ; SOS mới chỉ áp dụng cho candidate tương lai.
17. LPS-LIKE ngoài Accumulation → không tự gán Phase D/canonical LPS.

## 26. So sánh với PR #14 hiện tại

Nếu D01–D22 được phê duyệt, PR #14 phải được sửa tối thiểu ở các điểm sau:

1. giữ `SOS-LIKE` nhưng thêm PriceBreakoutObservation độc lập;
2. thêm `PreviousClose <= Resistance` để xác định fresh breakout;
3. giữ RSpread>=1.20 và RVOL>=1.25 làm gate của SOS-LIKE, vì đây là phần effort cốt lõi; ghi rõ chúng dựa trên dải Core chứ không phải hằng số Wyckoff;
4. bỏ `ClosePosition >=0.60` khỏi hard gate, chuyển thành quality descriptor;
5. bỏ `LPS_MaxBarsAfterSOS=10`;
6. bỏ upper-distance `Low <= BreakoutLevel +0.50 ATR` khỏi hard gate LPS;
7. giữ `Low >= BreakoutLevel` cho LPS-LIKE strict support hold;
8. bỏ `NoSupplyCandidateCode=2` khỏi hard gate LPS origin;
9. bỏ `CE_NoSupply confirmed` khỏi hard gate LPS resolution;
10. bổ sung reaction-progress contract ở origin;
11. resolution k+1 chuyển sang price response: support hold + không lower low + Close cải thiện;
12. No Supply/Confirmation No Supply chỉ còn context descriptor;
13. cho phép nhiều LPS trên cùng SOS anchor;
14. bổ sung BarsSinceSOS, quality contraction vs SOS và frozen snapshot đầy đủ;
15. không coi SOS/LPS-LIKE là canonical Phase D labels.

Do đó PR #14 hiện tại phải tiếp tục được coi là `UNAPPROVED DEVELOPMENT` cho đến khi đặc tả này được phê duyệt và AFL được căn chỉnh.

## 27. Bảng quyết định cần chủ dự án phê duyệt

| Mã | Đề xuất | Khuyến nghị |
|---|---|---|
| D01 | Event layer chỉ dùng SOS-LIKE/LPS-LIKE | Chấp thuận mạnh |
| D02 | Resistance = pivot High gần nhất xác nhận trước k | Chấp thuận |
| D03 | PreviousClose <= Resistance để xác định fresh breakout | Chấp thuận |
| D04 | Tách PriceBreakoutObservation khỏi SOS classification | Chấp thuận mạnh |
| D05 | SOS-LIKE cần RSpread>=1.20 và RVOL>=1.25 theo Core bands | Chấp thuận |
| D06 | ClosePosition chỉ là quality descriptor | Chấp thuận |
| D07 | Spring/Shakeout là context, không phải gate | Chấp thuận mạnh |
| D08 | SOS-LIKE được công bố tại cuối k, không chờ k+1 | Chấp thuận |
| D09 | Snapshot BreakoutLevel/pivot/effort/context bất biến | Chấp thuận |
| D10 | Không timeout 10 thanh; anchor hết hiệu lực bởi sự kiện nhân quả | Chấp thuận mạnh |
| D11 | LPS origin phải nằm trong reaction/pullback sau SOS | Chấp thuận mạnh |
| D12 | Không dùng 0.50 ATR upper-distance làm hard gate | Chấp thuận mạnh |
| D13 | Spread/volume contraction là quality evidence, không gate tuyệt đối | Chấp thuận mạnh |
| D14 | No Supply chỉ là context, không gate LPS | Chấp thuận mạnh |
| D15 | k+1 xác nhận LPS bằng price response + support hold | Chấp thuận mạnh |
| D16 | Origin/Resolution code 0/1/2/3 tách riêng | Chấp thuận |
| D17 | Không late confirm; candidate nối tiếp được | Chấp thuận |
| D18 | Cho phép nhiều LPS sau cùng một SOS | Chấp thuận mạnh |
| D19 | BUEC chỉ là context/descriptor ở v0.1 | Chấp thuận |
| D20 | Canonical SOS/LPS/Phase D dành cho Phase Engine | Chấp thuận mạnh |
| D21 | Các kênh độc lập; snapshot frozen | Chấp thuận |
| D22 | Daily completed-bar, no future/backfill/trading assignment | Chấp thuận |

## 28. Điều kiện chuyển sang triển khai

Chỉ sau khi chủ dự án phê duyệt D01–D22 mới:

1. đổi trạng thái đặc tả từ DỰ THẢO sang ĐÃ KHÓA;
2. sửa đặc tả phát triển, AFL và hồ sơ triển khai ở PR #14 theo đặc tả này;
3. không dùng bản AFL PR #14 hiện tại làm source-of-truth;
4. kiểm thử vẫn có thể hoãn theo chiến lược hiện tại, nhưng sau căn chỉnh chỉ được gọi `SPEC-ALIGNED / UNTESTED DEVELOPMENT`;
5. các Event tiếp theo tiếp tục theo quy trình: nghiên cứu → dự thảo đặc tả → chủ dự án duyệt → khóa → triển khai.