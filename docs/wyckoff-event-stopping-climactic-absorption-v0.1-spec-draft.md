# Wyckoff Event — Dự thảo đặc tả Stopping Volume / Climactic Effort / Absorption v0.1

**Trạng thái:** DỰ THẢO ĐỂ CHỦ DỰ ÁN PHÊ DUYỆT. Chưa khóa, chưa phải tiêu chí nghiệm thu, chưa có AFL triển khai cho mô-đun này.

## 1. Mục tiêu và ranh giới

Mô-đun này bổ sung lớp đọc **nỗ lực so với kết quả** ở mức Event, nhưng không được tự biến một thanh khối lượng lớn thành kết luận về tích lũy, phân phối hay đảo chiều.

Ba nhóm hành vi cần tách riêng:

1. `STOPPING-VOLUME-LIKE`: dấu hiệu lực bán đang bị cầu đối ứng đáng kể trong một thanh chịu áp lực xuống;
2. `CLIMACTIC-EFFORT-LIKE`: hoạt động giá/khối lượng cực mạnh cho thấy một cao trào nỗ lực, nhưng chưa khẳng định đó là Selling Climax hay Buying Climax theo cấu trúc Wyckoff;
3. `ABSORPTION-LIKE OBSERVATION`: nỗ lực rất lớn nhưng kết quả dịch chuyển giá ròng hạn chế, gợi ý lực đối ứng hấp thụ một phần áp lực đang tác động.

Luồng kiến trúc tiếp tục là:

`Core → Candidate → Structure/Location → Confirmation → Wyckoff Event → Phase/Context`

Không tạo Buy/Sell/Short/Cover/PositionSize, không chấm điểm xác suất, không tự gán Phase A/B/C/D/E và không gọi canonical `SC`, `BC`, `PS`, `PSY` ở lớp này.

## 2. Cơ sở nghiên cứu trước khi đặc tả

### 2.1. Các điểm được tài liệu Wyckoff hỗ trợ trực tiếp

Nguồn tham khảo chính:

- Wyckoff Analytics — Wyckoff Method: https://www.wyckoffanalytics.com/wyckoff-method/
- StockCharts ChartSchool — The Wyckoff Method: A Tutorial: https://chartschool.stockcharts.com/table-of-contents/market-analysis/wyckoff-analysis-articles/the-wyckoff-method-a-tutorial
- StockCharts — The Stopping Action of a Downtrend: https://stockcharts.com/articles/wyckoff/2015/05/the-stopping-of-a-downtrend.html
- StockCharts — Take the Fork in the Road: https://stockcharts.com/articles/wyckoff/2015/08/take-the-fork-in-the-road.html
- StockCharts — Rev Up with Reaccumulation Trading Ranges: https://stockcharts.com/articles/wyckoff/2015/07/rev-up-with-reaccumulation-trading-ranges.html

Các điểm được hỗ trợ khá nhất quán:

1. Preliminary Support/Selling Climax ở đáy thường đi cùng spread mở rộng và volume tăng mạnh; SC là nơi lực bán lớn được hấp thụ bởi lực mua chuyên nghiệp, giá thường đóng cửa rời khỏi vùng thấp.
2. Preliminary Supply/Buying Climax ở đỉnh cũng thường đi cùng volume và spread tăng mạnh; lực mua công chúng được hấp thụ bởi lực bán lớn hơn.
3. Climactic action là **stopping action của xu hướng trước**, nhưng bản thân một thanh cao trào chưa đủ để biết trading range sau đó sẽ trở thành tích lũy, tái tích lũy, phân phối hay tái phân phối.
4. Một Buying Climax có thể kết thúc bằng hành vi rất mạnh/ồn ào nhưng cũng có trường hợp xu hướng kết thúc bằng sự cạn kiệt dần của demand với spread/volume giảm. Vì vậy không được cho rằng mọi điểm dừng xu hướng phải có climactic volume.
5. Việc xác nhận cấu trúc Wyckoff cần hành vi sau đó như Automatic Rally/Reaction, Secondary Test và trading-range context.

### 2.2. Điểm tham khảo từ VSA cần dùng thận trọng

Trong cách đọc VSA phổ biến, `Stopping Volume` thường mô tả một thanh chịu áp lực giảm có volume rất cao nhưng đóng cửa rời khỏi đáy, cho thấy bán đang gặp lực mua hấp thụ. Khái niệm `Absorption` rộng hơn: effort lớn nhưng price result hạn chế.

Do đây không phải các nhãn canonical trong sơ đồ Wyckoff theo cùng cấp độ với SC/BC, v0.1 chỉ dùng hậu tố `-LIKE` hoặc `OBSERVATION` và dành quyền kết luận cấu trúc cho Phase/Context Engine.

## 3. Nguyên tắc thiết kế tổng quát

Mô-đun phải giữ ba tầng thông tin độc lập:

- **Effort/Expansion Observation**: volume/spread có lớn hay không;
- **Effort-vs-Result Observation**: nỗ lực lớn có tạo ra tiến triển giá tương xứng hay không;
- **Contextual Event Interpretation**: có đủ điều kiện thận trọng để gọi Stopping-Volume-Like hay không.

Không dùng một nhãn duy nhất để ghi đè các nhãn khác. Một thanh có thể đồng thời là `CLIMACTIC-EFFORT-LIKE` và `ABSORPTION-LIKE`, hoặc `STOPPING-VOLUME-LIKE` và `CLIMACTIC-EFFORT-LIKE`.

## 4. D01 — Chính sách nhãn của Event layer

Được phép công bố:

- `CLIMACTIC-EFFORT-LIKE`;
- `ABSORPTION-LIKE OBSERVATION`;
- `STOPPING-VOLUME-LIKE`;
- các descriptor về hướng áp lực, vị trí đóng cửa, spread, volume, tiến triển và location.

Không được công bố trực tiếp:

- `SELLING CLIMAX`;
- `BUYING CLIMAX`;
- `PRELIMINARY SUPPORT`;
- `PRELIMINARY SUPPLY`;
- `ACCUMULATION`;
- `DISTRIBUTION`.

Các nhãn trên chỉ được Phase/Context hoặc Structural Sequence Engine tương lai nâng cấp khi đủ bằng chứng.

## 5. D02 — Dùng lại hệ quy chiếu của Core v1.0, không tạo thước đo mới tùy ý

Mô-đun đọc trực tiếp các đầu ra Core hiện có:

- `RVOL`, `RVOLValid`;
- `RSpread`, `RSpreadValid`;
- `ClosePosition`, `ClosePositionValid`;
- `DirectionalProgress`, `AbsDirectionalProgress`, validity tương ứng;
- `PriorATR`, `PriorATRValid`;
- giá OHLC và PreviousClose.

Không tính lại rolling volume/spread base trong Event Engine.

## 6. D03 — Hai tầng nỗ lực mở rộng

Đề xuất dùng chính các dải cố định đã tồn tại trong Core v1.0:

### 6.1. Elevated Expansion Observation

```text
RSpread >= 1.20
RVOL    >= 1.25
```

Đây là mức `WIDE/HIGH hoặc cao hơn`, dùng như descriptor chung, **không phải climax**.

### 6.2. Climactic Effort threshold v0.1

```text
RSpread >= 1.60
RVOL    >= 1.80
```

Đây là mức `VERY WIDE` kết hợp `VERY HIGH hoặc cao hơn` theo dải Core và được dùng làm gate kỹ thuật của `CLIMACTIC-EFFORT-LIKE`.

`RVOL >= 2.50` được xuất riêng là `UltraEffortFlag` nhưng không tạo một event khác.

Các số 1.60/1.80/2.50 là quy tắc vận hành dựa trên Core bands, không được mô tả như hằng số của Wyckoff cổ điển.

## 7. D04 — Hợp đồng Climactic Effort Observation

`WE_ER_ClimacticEffortCode`:

- 0 = `INSUFFICIENT DATA`;
- 1 = `NOT PRESENT`;
- 2 = `CLIMACTIC-EFFORT-LIKE`.

Code2 khi:

```text
PriceValid = 1
RSpreadValid = 1
RVOLValid = 1
RSpread >= 1.60
RVOL >= 1.80
```

Không yêu cầu trend/phase, không yêu cầu support/resistance và không yêu cầu k+1 để ghi nhận high-activity event tại chính thanh k.

## 8. D05 — Hướng của Climactic Effort là descriptor, không phải SC/BC

Khi ClimacticEffortCode=2, xuất:

```text
ClimacticDirectionCode:
1 = DOWNWARD CLOSE PROGRESS
2 = UPWARD CLOSE PROGRESS
3 = FLAT / NEUTRAL CLOSE PROGRESS
```

Theo:

- Close < PreviousClose → 1;
- Close > PreviousClose → 2;
- Close == PreviousClose → 3.

DirectionCode không được chuyển tự động thành `Selling Climax` hoặc `Buying Climax`.

## 9. D06 — ClosePosition của climax chỉ là descriptor

Climactic action có thể kết thúc với close ở vị trí khác nhau trong thanh. Đặc biệt SC thường close rời khỏi đáy nhưng đây là đặc điểm thường gặp, không phải điều kiện tuyệt đối của mọi high-effort bar.

Do đó `ClosePosition` không phải hard gate của `ClimacticEffortCode`.

Xuất tối thiểu:

- `ClimacticClosePosition`;
- `ClimacticClosePositionValid`;
- `StrongCloseFlag = ClosePosition > 0.75`;
- `WeakCloseFlag = ClosePosition < 0.25`.

## 10. D07 — Climactic Effort không đồng nghĩa Stopping Action

Một thanh rất rộng + volume rất lớn có thể là:

- continuation mạnh;
- breakout mạnh;
- panic selling/buying;
- một phần của stopping action;
- hoặc event trong trading range.

Vì vậy `ClimacticEffortCode=2` chỉ mô tả nỗ lực cao, không được tự động gọi đảo chiều hay stopping action.

## 11. D08 — Hợp đồng Absorption-Like Observation

Absorption v0.1 được định nghĩa bằng **high effort + low directional result**, tận dụng đúng triết lý Effort-vs-Result đã có trong Core.

Đề xuất:

```text
RVOL >= 1.80
AbsDirectionalProgress <= 0.35
```

với toàn bộ validity cần thiết hợp lệ.

`WE_ER_AbsorptionCode`:

- 0 = `INSUFFICIENT DATA`;
- 1 = `NOT PRESENT`;
- 2 = `ABSORPTION-LIKE OBSERVATION`.

Không bắt buộc RSpread phải hẹp. Một thanh có intrabar range rộng nhưng close rút về gần PreviousClose vẫn có thể thể hiện effort lớn nhưng net result nhỏ.

## 12. D09 — Không suy diễn bên hấp thụ chỉ từ volume

`ABSORPTION-LIKE OBSERVATION` bản thân là trung tính về kết luận bullish/bearish.

Xuất các pressure descriptor độc lập:

```text
DownsidePressureObserved =
    Low_k < Low_(k-1)
    OR Close_k < PreviousClose

UpsidePressureObserved =
    High_k > High_(k-1)
    OR Close_k > PreviousClose
```

Nếu cả hai xảy ra, giữ cả hai cờ. Không buộc một thanh range lớn thành một phía duy nhất.

Phase/Context Engine sau này mới quyết định đó là absorption of supply, absorption of demand, distributional absorption hay accumulation-related absorption.

## 13. D10 — Absorption một thanh khác với quá trình absorption nhiều thanh

V0.1 chỉ phát hiện **single-bar absorption-like observation**.

Không được từ một thanh duy nhất kết luận:

- `SUPPLY ABSORBED` hoàn toàn;
- `DEMAND ABSORBED` hoàn toàn;
- `ACCUMULATION COMPLETE`;
- `REACCUMULATION COMPLETE`.

Cluster/sequence absorption nhiều thanh sẽ là trách nhiệm của Sequence/Phase Engine tương lai.

## 14. D11 — Hợp đồng Stopping-Volume-Like origin

`Stopping Volume` ở v0.1 chỉ áp dụng cho **phía giảm**, đúng với cách dùng VSA thông thường: áp lực bán mạnh bắt đầu gặp cầu đủ lớn để hạn chế/thu hồi kết quả giảm trong thanh.

Origin tại k yêu cầu:

```text
PriceValid_k = 1
PriorPriceValid = 1
RVOLValid_k = 1
ClosePositionValid_k = 1
RVOL_k >= 1.80
DownsidePressureObserved_k = 1
ClosePosition_k >= 0.50
```

Không bắt buộc RSpread >= 1.20/1.60; spread được giữ như descriptor. Lý do: absorption mạnh có thể làm spread/result co lại dù volume rất lớn.

`WE_ER_StoppingVolumeCode`:

- 0 = `INSUFFICIENT DATA`;
- 1 = `NOT PRESENT`;
- 2 = `STOPPING-VOLUME-LIKE`.

## 15. D12 — DownsidePressureObserved cho Stopping Volume

Đề xuất:

```text
DownsidePressureObserved =
    Low_k < Low_(k-1)
    OR Close_k < PreviousClose
```

Điều này cho phép cả:

- down-bar volume lớn close về upper half;
- reversal bar có Low tạo thấp mới nhưng Close quay lên bằng/cao hơn PreviousClose.

Không yêu cầu bar phải có `Close < PreviousClose` tuyệt đối.

## 16. D13 — Close >= 0.50 là hard gate; close mạnh hơn chỉ là quality tier

Để tránh gọi một thanh volume lớn đóng gần đáy là Stopping Volume, đề xuất hard gate:

```text
ClosePosition >= 0.50
```

Quality descriptors:

- `UpperCloseFlag`: ClosePosition > 0.60;
- `StrongRecoveryCloseFlag`: ClosePosition > 0.75.

Các ngưỡng 0.60/0.75 chỉ mô tả chất lượng; chỉ 0.50 quyết định identity v0.1.

## 17. D14 — Không bắt buộc Stopping Volume phải là AbsorptionCode=2

Stopping Volume và Absorption-Like có thể chồng lấn nhưng không đồng nhất.

Ví dụ một thanh giảm rất mạnh có volume rất lớn, đóng upper half nhưng Close vẫn thấp hơn PreviousClose đủ xa để `AbsDirectionalProgress > 0.35`. Thanh này vẫn có thể là Stopping-Volume-Like nhưng không thỏa high-effort/low-net-result absorption.

Do đó:

- StoppingVolumeCode không phụ thuộc AbsorptionCode;
- AbsorptionCode không phụ thuộc StoppingVolumeCode.

## 18. D15 — Stopping Volume ở Event layer chưa yêu cầu “xu hướng giảm kéo dài” như hard gate

Ý nghĩa cổ điển của stopping volume mạnh nhất sau một decline đáng kể. Tuy nhiên dự án hiện chưa có Trend/Phase Engine đủ chuẩn để định nghĩa khách quan “prolonged decline”.

Vì vậy v0.1:

- không hard-code số thanh giảm liên tiếp;
- không tạo moving-average trend filter riêng;
- không dùng S/M/L làm trend oracle;
- giữ nhãn thận trọng `STOPPING-VOLUME-LIKE`;
- xuất location/context để Phase Engine đánh giá sau.

Có thể snapshot:

- `SL_S/M/L_PositionStateCode`;
- khoảng cách tới prior lower references;
- latest prior Pivot Low và tuổi pivot;
- DirectionalProgress hiện tại.

Những dữ liệu này là context, không gate.

## 19. D16 — Immediate Response của Stopping Volume là kênh riêng, không viết lại origin

Origin Stopping-Volume-Like được biết tại cuối thanh k.

Tại k+1, xuất `WE_ER_StoppingResponseCode`:

- 0 = `INSUFFICIENT DATA`;
- 1 = `NO PRIOR STOPPING-VOLUME-LIKE`;
- 2 = `IMMEDIATE RESPONSE NOT CONFIRMED`;
- 3 = `IMMEDIATE RESPONSE CONFIRMED`.

Đề xuất ResponseCode=3 khi:

```text
Low_(k+1) >= Low_k
Close_(k+1) > Close_k
```

Nếu không đạt, **không xóa hoặc backfill lại StoppingVolumeCode của k**. Response chỉ đánh giá phản ứng ngắn hạn.

Không xác nhận muộn origin k tại k+2.

## 20. D17 — Không dùng High/Low tiếp theo để định nghĩa Climactic Effort hoặc Absorption origin

`ClimacticEffortCode` và `AbsorptionCode` là quan sát tại chính k. Dữ liệu tương lai chỉ có thể tạo response/sequence event mới, không sửa event k.

## 21. D18 — Các kênh phải độc lập và cho phép overlap

Một thanh có thể đồng thời có:

- ElevatedExpansionObservation=1;
- ClimacticEffortCode=2;
- AbsorptionCode=2;
- StoppingVolumeCode=2.

Không thiết lập thứ tự ưu tiên kiểu “Climax thắng Absorption” hoặc “Stopping Volume thắng Climax”. Composite/Phase Engine cần thấy toàn bộ bằng chứng nguyên bản.

## 22. D19 — Event keys và frozen snapshot

Mỗi event/observation phải mang tọa độ rõ ràng:

```text
Symbol
+ EventBarIndex
+ EventDateTime
+ EventFamily
```

Stopping Response tại k+1 phải mang nguyên snapshot của origin:

- OriginBarIndex/DateTime;
- Origin Low/High/Close;
- Origin RVOL/RSpread/ClosePosition;
- origin context S/M/L/pivot nếu được xuất.

Không thay snapshot bằng giá trị context mới tại k+1.

## 23. D20 — Quan hệ với Spring/Shakeout, Supply Test, SOS/LPS, Upthrust

Các event hiện có chỉ là context chéo, không hard gate:

- Stopping Volume có thể xuất hiện trước một Spring/Shakeout, nhưng không bắt buộc;
- Climactic Effort có thể xuất hiện ở SOS hoặc breakout nhưng không tự nâng SOS thành canonical event;
- Absorption-Like có thể xuất hiện trong LPS, Support Test, Upthrust hoặc vùng giữa range;
- không để event family mới ghi đè event family cũ.

## 24. D21 — Quan hệ với PS/SC/AR/ST và PSY/BC/AR/ST tương lai

Đây là ranh giới kiến trúc bắt buộc.

Structural Sequence/Phase Engine tương lai có thể dùng:

- Downward Climactic Effort + Stopping Volume + location/decline context + Automatic Rally/Secondary Test để xem xét `PS/SC`;
- Upward Climactic Effort + upper location/uptrend context + Automatic Reaction/Secondary Test để xem xét `PSY/BC`.

Nhưng Event Engine hiện tại không được tự gọi SC/BC chỉ vì có high volume + wide spread.

## 25. D22 — Data validity và phân biệt NOT PRESENT với INSUFFICIENT DATA

Mỗi kênh có validity riêng.

Ví dụ:

- thiếu RVOL → ClimacticEffort/Absorption/StoppingVolume tương ứng `INSUFFICIENT DATA` nếu RVOL là dependency bắt buộc;
- thiếu RSpread → ClimacticEffort insufficient nhưng StoppingVolume vẫn có thể được đánh giá nếu các dependency của nó đủ;
- thiếu DirectionalProgress → Absorption insufficient nhưng ClimacticEffort vẫn đánh giá được;
- thiếu ClosePosition → StoppingVolume insufficient nhưng ClimacticEffort vẫn đánh giá được.

Không dùng một `AllInputsValid` chung khiến thiếu một descriptor làm mất mọi event.

## 26. D23 — Biên so sánh

Đề xuất strict/no epsilon giống các lớp đã khóa:

- Climactic: `RSpread >= 1.60`, `RVOL >= 1.80` bao hàm biên;
- Absorption: `RVOL >= 1.80`, `AbsDirectionalProgress <= 0.35` bao hàm biên;
- Stopping Volume: `RVOL >= 1.80`, `ClosePosition >= 0.50` bao hàm biên;
- DownsidePressure: `Low < PriorLow OR Close < PreviousClose` là strict ở phần pressure.

Không epsilon và không làm tròn trước so sánh.

## 27. D24 — Thanh hoàn tất, nhân quả và nguồn dữ liệu sửa đổi

Phạm vi nghiên cứu hiện tại: Daily, completed bars.

- thanh cuối chưa được nguồn xác nhận hoàn tất chỉ là provisional;
- không dùng `BarCount` để suy đoán thanh đã đóng;
- không dùng Zig/Peak/Trough look-ahead;
- không backfill event;
- chỉ dùng `Ref(...,-1)` cho dữ liệu prior cần thiết;
- source revision phải phân biệt với algorithmic repaint.

## 28. D25 — Không tạo logic đảo chiều hoặc giao dịch

Không được dùng các event này để tự động:

- Buy/Sell/Short/Cover;
- đặt stop;
- xác định target;
- tăng/giảm PositionSize;
- tuyên bố “đáy đã hình thành” hay “đỉnh đã hình thành”.

Đây là lớp bằng chứng, không phải strategy engine.

## 29. D26 — Đầu ra Exploration tối thiểu

### Climactic Effort

- Code/Valid/Reason;
- EventBarIndex/DateTime;
- DirectionCode;
- RVOL/RSpread và validity;
- ClosePosition/DirectionalProgress/PriorATR descriptors;
- ElevatedExpansionFlag / UltraEffortFlag;
- S/M/L context nếu có.

### Absorption

- Code/Valid/Reason;
- EventBarIndex/DateTime;
- RVOL;
- DirectionalProgress/AbsDirectionalProgress;
- UpsidePressureObserved;
- DownsidePressureObserved;
- RSpread/ClosePosition descriptors;
- context S/M/L/pivots nếu có.

### Stopping Volume

- Code/Valid/Reason;
- EventBarIndex/DateTime;
- OHLC;
- PriorLow/PreviousClose;
- RVOL/RSpread/ClosePosition;
- DownsidePressureObserved;
- UpperClose/StrongRecoveryClose flags;
- context S/M/L/prior Pivot Low;
- k+1 ResponseCode + frozen origin coordinates.

## 30. Phản ví dụ bắt buộc

1. RVOL rất cao nhưng RSpread hẹp → không ClimacticEffort, nhưng có thể Absorption.
2. RSpread rất rộng nhưng RVOL bình thường → không ClimacticEffort.
3. RVOL=1.80 và RSpread=1.60 → đạt biên ClimacticEffort.
4. RVOL=1.80 và AbsDirectionalProgress=0.35 → đạt biên Absorption.
5. High volume + low result nhưng không rõ bên nào gây pressure → vẫn AbsorptionObservation, không gán supply/demand absorbed.
6. High volume down-pressure, ClosePosition=0.50 → đạt biên StoppingVolume-like.
7. High volume down-pressure, ClosePosition=0.49 → không StoppingVolume-like.
8. Low tạo thấp mới nhưng Close vượt PreviousClose, volume rất cao và close upper half → vẫn có thể StoppingVolume-like.
9. High-volume down bar đóng sát low → không StoppingVolume-like dù volume cực cao.
10. StoppingVolume-like nhưng k+1 tạo lower low → origin vẫn tồn tại, ImmediateResponse không xác nhận.
11. StoppingVolume-like k, k+2 mới bật mạnh → không retroactively đổi k+1 response thành confirmed.
12. ClimacticEffort trong middle of range → không tự gọi SC/BC.
13. Upward ClimacticEffort sau uptrend → không tự gọi BC khi chưa có AR/ST/context.
14. Downward ClimacticEffort sau decline → không tự gọi SC khi chưa có AR/ST/context.
15. Absorption-like xuất hiện cùng Upthrust/Spring/SOS/LPS → cho phép overlap, không ghi đè.
16. Thiếu RSpread nhưng RVOL/ClosePosition đủ cho StoppingVolume → vẫn đánh giá StoppingVolume, không bị một validity chung làm mất.
17. Thiếu DirectionalProgress nhưng Climactic data đủ → ClimacticEffort vẫn đánh giá được, Absorption insufficient.
18. Thanh cuối đang hình thành thay đổi volume/close → mọi event trên thanh đó chỉ provisional.

## 31. Bảng quyết định cần chủ dự án phê duyệt

| Mã | Đề xuất | Khuyến nghị |
|---|---|---|
| D01 | Event layer dùng các nhãn `-LIKE/OBSERVATION`, không gọi SC/BC | Chấp thuận mạnh |
| D02 | Chỉ đọc measurement upstream, không tính lại Core | Chấp thuận mạnh |
| D03 | ClimacticEffort dùng RSpread>=1.60 và RVOL>=1.80 theo Core bands | Chấp thuận |
| D04 | ClimacticEffort là event tại k, không cần k+1 | Chấp thuận |
| D05 | Direction chỉ là descriptor, không suy ra SC/BC | Chấp thuận mạnh |
| D06 | ClosePosition không hard gate ClimacticEffort | Chấp thuận |
| D07 | ClimacticEffort không đồng nghĩa stopping/reversal | Chấp thuận mạnh |
| D08 | Absorption = RVOL>=1.80 + AbsDirectionalProgress<=0.35 | Chấp thuận |
| D09 | Không suy diễn bên hấp thụ chỉ từ volume; giữ pressure descriptors | Chấp thuận mạnh |
| D10 | Single-bar Absorption khác process absorption nhiều thanh | Chấp thuận mạnh |
| D11 | StoppingVolume-like dùng high volume + downside pressure + close upper half | Chấp thuận |
| D12 | Downside pressure = Low thấp hơn prior Low OR Close thấp hơn PreviousClose | Chấp thuận |
| D13 | ClosePosition>=0.50 là gate StoppingVolume; >0.60/>0.75 chỉ quality | Chấp thuận |
| D14 | StoppingVolume và Absorption độc lập, cho phép overlap | Chấp thuận mạnh |
| D15 | Chưa hard-code prolonged decline trước khi có Trend/Phase Engine | Chấp thuận mạnh |
| D16 | k+1 ImmediateResponse là kênh riêng, không viết lại origin | Chấp thuận |
| D17 | Không dùng tương lai để định nghĩa Climactic/Absorption origin | Chấp thuận mạnh |
| D18 | Không ưu tiên/ghi đè giữa các event | Chấp thuận mạnh |
| D19 | Snapshot frozen và event key rõ ràng | Chấp thuận |
| D20 | Quan hệ với các Event hiện có chỉ là context | Chấp thuận |
| D21 | SC/BC/PS/PSY dành cho Structural Sequence/Phase Engine | Chấp thuận mạnh |
| D22 | Validity tách riêng từng kênh | Chấp thuận mạnh |
| D23 | Boundary inclusive theo các ngưỡng, no epsilon | Chấp thuận |
| D24 | Daily completed-bar, causal, no backfill | Chấp thuận mạnh |
| D25 | Không tự động giao dịch/đảo chiều | Chấp thuận mạnh |
| D26 | Exploration xuất evidence + coordinates + validity đầy đủ | Chấp thuận |

## 32. Điều kiện chuyển sang triển khai

Chỉ sau khi chủ dự án phê duyệt D01–D26 mới:

1. đổi trạng thái đặc tả sang ĐÃ KHÓA;
2. tạo nhánh AFL phát triển mới, xếp chồng trên nhánh Event gần nhất nếu tiếp tục chiến lược build-first;
3. viết AFL theo đúng các kênh độc lập ở trên;
4. chưa tạo fixture/expected/native acceptance nếu chủ dự án vẫn giữ quyết định hoãn kiểm thử;
5. chỉ gọi AFL sau căn chỉnh là `SPEC-ALIGNED / UNTESTED DEVELOPMENT`;
6. bước sau mô-đun này là nghiên cứu Structural Sequence cho PS/SC/AR/ST và PSY/BC/AR/ST trước Phase Engine.