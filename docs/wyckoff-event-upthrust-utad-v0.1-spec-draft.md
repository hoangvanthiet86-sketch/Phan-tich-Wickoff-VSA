# Wyckoff Event — Đặc tả dự thảo Upthrust / UTAD v0.1

**Trạng thái:** DỰ THẢO ĐỂ CHỦ DỰ ÁN PHÊ DUYỆT. Chưa khóa, chưa phải tiêu chí nghiệm thu và không cho phép dùng tài liệu này để tuyên bố AFL hiện có ở PR #13 là đúng. Không sửa Core, Candidate, Structure/Location, Confirmation, Supply Test hoặc Spring/Shakeout.

## 1. Mục tiêu và ranh giới

Mô-đun này xử lý **họ hành vi phá kháng cự phía trên nhưng không duy trì được mức giá mới**.

Luồng kiến trúc:

`Core → Candidate → Structure/Location → Confirmation → Wyckoff Event → Phase/Context`

Điểm quan trọng của đặc tả này là **không đồng nhất Upthrust với UTAD**.

- `Upthrust` là một hành vi phá kháng cự rồi nhanh chóng quay lại dưới kháng cự; trong tài liệu Wyckoff nó có thể là một dạng Secondary Test ở phía trên trading range.
- `UTAD` là **Upthrust After Distribution**: một sự kiện phụ thuộc mạnh vào bối cảnh phân phối và vị trí muộn trong trading range. Nó không thể được xác định chỉ từ độ xuyên, volume hoặc spread của một thanh đơn lẻ.

Do Phase Engine chưa tồn tại, v0.1 chỉ được phép công bố **UPTHRUST-LIKE** ở lớp Event và lưu dữ liệu cần thiết để Phase Engine tương lai quyết định liệu một event/sequence có đủ điều kiện gọi là UTAD hay không.

Mô-đun không phát Buy/Sell, không quản trị vốn, không chấm điểm xác suất và không tự gán Distribution/Phase C.

## 2. Cơ sở nghiên cứu trước khi đặc tả

### 2.1. Điều được nguồn Wyckoff hỗ trợ trực tiếp

Wyckoff Analytics mô tả một Upthrust như một Secondary Test có thể vượt kháng cự do Buying Climax hoặc các Secondary Test trước tạo ra, sau đó **nhanh chóng đảo chiều và đóng cửa lại dưới kháng cự**.

Nguồn:
- https://www.wyckoffanalytics.com/wyckoff-method/
- https://chartschool.stockcharts.com/table-of-contents/market-analysis/wyckoff-analysis-articles/the-wyckoff-method-a-tutorial

Các tài liệu Wyckoff về UTAD nhấn mạnh rằng:

- UTAD là đối phần phía phân phối của Spring/Terminal Shakeout;
- thường xuất hiện ở giai đoạn muộn của trading range;
- không phải thành phần bắt buộc của mọi Distribution;
- một breakout kiểu UTAD có thể diễn ra trên volume thấp không có follow-through **hoặc** volume lớn rồi thất bại mạnh trở lại trading range;
- trong một số trường hợp giá có thể lưu lại phía trên kháng cự từ vài ngày đến vài tuần trước khi thất bại trở lại.

Nguồn:
- https://www.wyckoffanalytics.com/wyckoff-method/
- https://www.wyckoffanalytics.com/wp-content/uploads/2019/08/WyckoffSchematics-VisualTemplatesForMarketTimingDecisions.pdf
- https://stockcharts.com/articles/wyckoff/2015/09/distribution-definitions.html

### 2.2. Hệ quả thiết kế bắt buộc

Từ các điểm trên, v0.1 **không được**:

1. gọi một cú xuyên sâu là `UTAD-LIKE` chỉ vì PenetrationATR lớn;
2. gọi một thanh volume/spread lớn là `UTAD-LIKE` chỉ vì effort lớn;
3. bắt mọi UTAD phải quay xuống dưới kháng cự ngay trong cùng thanh;
4. coi UTAD là một biến thể “mạnh hơn” của Upthrust chỉ dựa trên một thanh;
5. dùng nhãn UTAD khi chưa có bằng chứng về trading range phân phối và vị trí pha.

Đây là khác biệt chính so với đặc tả phát triển và AFL ban đầu ở PR #13.

## 3. D01 — Nguồn kháng cự

**Đề xuất:** nguồn kháng cự duy nhất cho Upthrust-like v0.1 là **pivot High gần nhất đã xác nhận trước thanh khởi phát k**.

Tại k dùng nhóm `SL_PivotHighLatestPrior...`.

`ResistanceValid_k = 1` khi đồng thời:

- `SL_PivotHighLatestPriorValid_k = 1`;
- ResistancePrice hữu hạn và `> 0`;
- ExtremeBarIndex/DateTime tồn tại;
- ConfirmBarIndex/DateTime tồn tại;
- `PivotConfirmBarIndex_k < BarIndex_k`.

Không dùng pivot High mới chỉ xác nhận tại chính k.

S/M/L có thể xuất làm context nhưng không làm nguồn kháng cự thay thế.

Khi origin được tạo, ResistancePrice cùng tọa độ pivot phải được snapshot và giữ cố định cho event đó.

**Đề xuất không đặt tuổi tối đa cho resistance trong v0.1**, nhưng phải xuất tuổi/BarsSinceConfirmation nếu upstream cho phép để đánh giá về sau.

## 4. D02 — Yêu cầu tiếp cận kháng cự từ phía dưới hoặc trong vùng

Một Upthrust-like phải là một cú phá kháng cự mới xảy ra từ trạng thái trước đó chưa được chấp nhận phía trên kháng cự.

Đề xuất yêu cầu:

```text
PriorClose_k <= ResistancePrice_k
```

trong đó `PriorClose_k = Close_(k-1)` và phải hợp lệ.

Mục đích là tránh gán nhãn Upthrust cho một thanh nằm trong một xu hướng đã giao dịch trên resistance nhiều phiên rồi mới quay xuống mức pivot cũ.

Không yêu cầu `High_(k-1) <= Resistance`, vì các thanh trước có thể đã test/thrust nhẹ trong trading range nhưng vẫn đóng cửa bên dưới.

## 5. D03 — Khái niệm xuyên kháng cự

Thanh k chỉ có hành vi thrust phía trên khi:

```text
High_k > ResistancePrice_k
```

So sánh số thực nghiêm ngặt, không epsilon, không làm tròn theo hiển thị.

- `High == ResistancePrice`: chỉ chạm, không phải penetration.
- `High > ResistancePrice`: penetration hợp lệ.

Độ xuyên được đo:

```text
Penetration    = High_k - ResistancePrice_k
PenetrationATR = Penetration / PriorATR_k
```

PriorATR phải hợp lệ, hữu hạn và `> 0` để PenetrationATR có validity=1.

## 6. D04 — Không dùng độ xuyên tối đa để loại Origin

**Đề xuất thay đổi so với PR #13:** không dùng `MaxPenetrationATR = 1.00` làm điều kiện loại Upthrust-like.

Lý do:

- tài liệu Wyckoff không đặt một ngưỡng ATR cố định cho magnitude của Upthrust;
- một false breakout có thể vượt kháng cự đáng kể rồi vẫn thất bại;
- UTAD còn có thể là một breakout có vẻ rất thuyết phục trước khi thất bại;
- dùng 1 ATR làm hard gate có nguy cơ loại đúng các trường hợp có ý nghĩa.

PenetrationATR vẫn phải được xuất như **descriptor** để sau này kiểm thử chất lượng event.

Nếu chủ dự án muốn một ngưỡng bảo vệ chống resistance quá cũ, nên xử lý bằng tuổi/cấu trúc resistance chứ không bằng cách mặc định loại mọi penetration >1 ATR.

## 7. D05 — Điều kiện quay lại dưới kháng cự trong cùng thanh

Một `UPTHRUST-LIKE` origin tại k yêu cầu:

```text
High_k  > ResistancePrice_k
Close_k <= ResistancePrice_k
```

Tức thanh đã xuyên kháng cự nhưng đến lúc đóng cửa không giữ được phía trên kháng cự.

Biên `Close == ResistancePrice` được chấp nhận là vừa đủ quay lại vùng cũ.

Nếu:

```text
High_k > ResistancePrice_k
AND Close_k > ResistancePrice_k
```

thì **không được gọi là Upthrust-like ở k**. Đây chỉ là `UPPER BREAKOUT OBSERVATION`, có thể là breakout thật hoặc là giai đoạn đầu của một UTAD/false breakout nhiều thanh. Phase/sequence layer tương lai mới giải quyết trường hợp đó.

## 8. D06 — ClosePosition là thước đo chất lượng, không phải gate của Origin

**Đề xuất thay đổi so với PR #13:** không bắt `ClosePosition <= 0.50` để OriginCode=2.

Lý do: điều kiện định nghĩa cốt lõi đã là Close quay xuống dưới resistance. ClosePosition cho biết chất lượng rejection trong toàn biên thanh, nhưng không phải tiêu chí bắt buộc trong định nghĩa Wyckoff được nguồn nghiên cứu nêu.

Đề xuất:

```text
WE_UT_StrongCloseRejection = 1
khi ClosePositionValid=1 và ClosePosition <= 0.50
```

Nếu ClosePosition >0.50 nhưng Close vẫn dưới resistance, event vẫn là Upthrust-like nhưng có rejection quality yếu hơn.

## 9. D07 — Effort/Volume/Spread không quyết định Upthrust hay UTAD

RVOL và RSpread **không được dùng để quyết định OriginCode và không được dùng để phân biệt Upthrust với UTAD**.

Lý do nghiên cứu: tài liệu Wyckoff chấp nhận cả hai trường hợp:

- breakout volume thấp nhưng không có follow-through;
- breakout volume cao rồi thất bại trở lại trading range.

Do đó volume cao không đồng nghĩa UTAD và volume thấp không loại UTAD.

Đề xuất chỉ xuất context:

```text
WE_UT_EffortDataValid
WE_UT_OriginRVOL
WE_UT_OriginRSpread
WE_UT_HighEffortFlag
WE_UT_MixedEffortFlag
```

Ngưỡng mô tả đề xuất để tương thích hệ thống hiện tại:

```text
HighEffortFlag = RVOL >= 1.25 AND RSpread >= 1.20
```

Đây chỉ là engineering descriptor, không phải định nghĩa Wyckoff và không thay đổi event identity.

## 10. D08 — Hợp đồng Origin

`WE_UT_OriginCode`:

- 0 = `INSUFFICIENT DATA`
- 1 = `NOT PRESENT`
- 2 = `UPTHRUST-LIKE CANDIDATE`

OriginCode=2 khi đồng thời:

```text
PriceValid_k = 1
ResistanceValid_k = 1
PriorCloseValid_k = 1
PriorClose_k <= ResistancePrice_k
High_k > ResistancePrice_k
Close_k <= ResistancePrice_k
```

PriorATR **không bắt buộc để tồn tại Origin**, vì nó chỉ cần cho descriptor PenetrationATR. Nếu ATR thiếu, Origin vẫn có thể tồn tại nhưng PenetrationATRValid=0.

ClosePosition/RVOL/RSpread cũng không bắt buộc cho OriginCode.

### OriginReasonCode đề xuất

- 0: không lỗi / không áp dụng;
- 1: không xuyên resistance (`High <= Resistance`);
- 2: không có pivot High prior hợp lệ;
- 3: PriorClose không hợp lệ;
- 4: PriorClose đã ở trên resistance — không phải fresh thrust từ phía dưới/trong vùng;
- 5: xuyên nhưng Close vẫn trên resistance — Upper Breakout Observation, chưa phải Upthrust-like;
- 6: dữ liệu giá origin không hợp lệ.

ATR/ClosePosition/RVOL/RSpread thiếu không đưa OriginCode về 0; chúng có validity riêng cho descriptor.

## 11. D09 — Upper Breakout Observation riêng biệt

Để không làm mất các trường hợp có thể trở thành UTAD nhiều thanh, đề xuất xuất thêm một observation không mang nhãn event:

```text
WE_UT_UpperBreakoutObservation = 1
```

khi:

```text
ResistanceValid = 1
PriorCloseValid = 1
PriorClose <= Resistance
High > Resistance
Close > Resistance
```

Nó chỉ nói rằng giá **đã phá và đóng cửa trên kháng cự**.

Không suy luận:

- breakout thành công;
- UTAD;
- Distribution;
- continuation.

Phase/sequence engine sau này có thể dùng chuỗi observation này để phát hiện breakout ở trên resistance kéo dài nhiều thanh rồi thất bại trở lại.

## 12. D10 — Xác nhận Upthrust-like tại k+1

Một Origin Upthrust-like tại k chỉ được giải quyết tại:

```text
t = k + 1
```

Đề xuất xác nhận cơ bản khi:

```text
Close_t <= ResistancePrice_k
AND Close_t < Close_k
```

và dữ liệu giá tại t hợp lệ.

Điểm khác PR #13: **không bắt `High_t <= ResistancePrice` để xác nhận cơ bản**.

Lý do: thanh kế tiếp có thể retest phía trên resistance trong phiên nhưng vẫn đóng cửa yếu hơn và trở lại dưới resistance. Nếu bắt toàn bộ High phải nằm dưới resistance, tiêu chí sẽ quá cứng và có thể loại một retest thất bại hợp lệ.

Đề xuất xuất thêm:

```text
WE_UT_EvaluationFullyBelowResistance = 1
khi High_t <= ResistancePrice_k
```

để phân biệt xác nhận mạnh hơn, nhưng không dùng nó làm điều kiện tối thiểu của ResolutionCode=3.

## 13. D11 — Bác bỏ và dữ liệu thiếu

Một prior Upthrust-like origin tại k được giải quyết duy nhất ở k+1:

- `CONFIRMED` nếu D10 đạt;
- `REJECTED` nếu dữ liệu hợp lệ nhưng Close không giảm hoặc đóng trở lại trên resistance;
- `INSUFFICIENT DATA` nếu dữ liệu evaluation bắt buộc không hợp lệ.

ResolutionReasonCode đề xuất:

- 0: không lỗi / không có prior origin;
- 1: Close không thấp hơn origin;
- 2: Close quay lại trên resistance;
- 3: đồng thời thất bại cả hai;
- 4: dữ liệu evaluation không hợp lệ.

Không xác nhận muộn tại k+2. Một phản ứng giảm chỉ xuất hiện sau k+1 không hồi sinh event đã bị bác bỏ.

## 14. D12 — Hợp đồng Resolution

`WE_UT_ResolutionCode`:

- 0 = `INSUFFICIENT DATA`
- 1 = `NO PRIOR UPTHRUST-LIKE`
- 2 = `UPTHRUST-LIKE REJECTED`
- 3 = `UPTHRUST-LIKE CONFIRMED`

`WE_UT_ResolutionValid = 1` cho code 1/2/3; bằng 0 cho code0.

`WE_UT_Confirmed = 1` chỉ khi ResolutionCode=3.

Không có `ConfirmedUTAD` trong v0.1.

## 15. D13 — UTAD không phải OriginKind của v0.1

Đây là quyết định kiến trúc quan trọng nhất.

**Đề xuất loại bỏ hoàn toàn quy tắc PR #13:**

```text
UTAD-LIKE nếu PenetrationATR > 0.50
OR (RSpread >=1.20 AND RVOL >=1.25)
```

Quy tắc đó không được nguồn Wyckoff hỗ trợ và trộn lẫn `magnitude/effort` với `phase/context`.

Trong v0.1:

```text
WE_UT_OriginKindCode
1 = UPTHRUST-LIKE
```

Không có KindCode=2 cho UTAD.

UTAD chỉ được gán bởi Phase/Context Engine tương lai khi có đủ bằng chứng ít nhất về:

- trading range phía trên đã hình thành;
- resistance của range;
- bằng chứng Distribution trước event;
- vị trí muộn của range/Phase C hoặc tương đương;
- breakout phía trên resistance;
- failure/re-entry phù hợp;
- phản ứng yếu đi sau breakout;
- thời điểm công bố hoàn toàn nhân quả.

Khi đó Phase Engine có thể tham chiếu một Upthrust-like đã công bố hoặc một Upper Breakout Failure sequence để gán nhãn `UTAD` tại thời điểm đủ bằng chứng. Không được ghi ngược nhãn UTAD vào thanh quá khứ như thể đã biết từ trước.

## 16. D14 — UTAD có thể kéo dài nhiều thanh

Nguồn Wyckoff ghi nhận giá có thể ở phía trên resistance từ vài ngày đến vài tuần trước khi UTAD thất bại trở lại.

Do đó không được ép UTAD vào lifecycle `k → k+1` của Upthrust-like.

v0.1 chỉ:

- nhận diện Upthrust-like same-bar rejection;
- ghi Upper Breakout Observation nếu Close vẫn trên resistance.

Một **Upper Breakout Failure Sequence** nhiều thanh sẽ được đặc tả ở Phase/Context layer hoặc một sequence engine riêng sau khi kiến trúc Phase được duyệt.

Không đặt arbitrary timeout 2/3/5/10 thanh trong đặc tả này.

## 17. D15 — Snapshot bắt buộc

Khi OriginCode=2 phải snapshot tối thiểu:

- OriginBarIndex / OriginDateTime;
- Origin High / Close;
- PriorClose;
- ResistancePrice;
- Resistance pivot ExtremeBarIndex/DateTime;
- Resistance pivot ConfirmBarIndex/DateTime;
- ResistanceAge nếu có;
- PriorATR và validity;
- Penetration và PenetrationATR/validity;
- ClosePosition/validity;
- RVOL/validity;
- RSpread/validity;
- StrongCloseRejection flag;
- HighEffort flag;
- S/M/L context nếu xuất để nghiên cứu.

Resolution tại k+1 mang nguyên snapshot origin và bổ sung:

- EvaluationBarIndex / EvaluationDateTime;
- Evaluation High / Close;
- CloseStayedBelowResistance;
- CloseDeclined;
- FullyBelowResistance;
- ResolutionCode / ReasonCode.

Pivot High mới xác nhận sau k không được thay resistance snapshot của event đang giải quyết.

## 18. D16 — Chồng lấn

Origin và Resolution là hai kênh riêng.

Một thanh t có thể vừa:

- resolve event từ t-1;
- tạo Upthrust-like origin mới của t;
- hoặc tạo UpperBreakoutObservation của t.

Không dùng một StatusCode duy nhất để buộc các hiện tượng loại trừ nhau khi chúng thuộc các kênh khác nhau.

Event key đề xuất:

```text
Symbol
+ OriginBarIndex
+ OriginDateTime
+ ResistancePivotConfirmBarIndex
```

## 19. D17 — Quan hệ với No Demand, Supply Test và Spring/Shakeout

- No Demand có thể xuất hiện sau Upthrust như một test cầu yếu nhưng **không phải điều kiện bắt buộc** của Upthrust-like.
- Supply Test/Spring/Shakeout thuộc phía hỗ trợ; không được dùng để quyết định event phía kháng cự.
- Confirmation No Demand có thể trở thành context bổ sung ở lớp Phase/Composite sau này.
- Không làm cho Upthrust phụ thuộc một Candidate VSA khác nếu định nghĩa event giá đã đủ độc lập.

## 20. D18 — Quan hệ với Distribution và Phase Engine

Một Upthrust-like đơn lẻ không đủ để kết luận Distribution.

Phase Engine tương lai phải có quyền phân biệt:

- Upthrust trong một Secondary Test thông thường;
- false breakout không thuộc distribution;
- UTAD trong giai đoạn muộn của Distribution;
- breakout thật được chấp nhận phía trên resistance.

Nếu Phase Engine sau này gọi một event là UTAD, thời điểm `UTADPublishedBar` phải là thanh đầu tiên mà toàn bộ điều kiện context đã có, không phải retroactive label trên origin.

Có thể lưu `UTADSourceOriginBarIndex` để chỉ về event gốc, nhưng đây chỉ là tọa độ lịch sử.

## 21. D19 — Chính sách thanh hoàn tất và dữ liệu sửa

Phạm vi nghiên cứu hiện tại: Daily, dữ liệu thanh đã hoàn tất.

Thanh cuối chưa được nguồn xác nhận hoàn tất chỉ là provisional.

Không dùng BarCount để tự suy đoán thanh đã đóng.

Không dùng Zig/Peak/Trough nhìn tương lai.

Nếu dữ liệu lịch sử thay đổi, output phụ thuộc có thể thay đổi và phải phân biệt rõ:

- source revision;
- algorithmic repaint.

## 22. D20 — Không giao dịch tự động

Mô-đun chỉ phục vụ nghiên cứu/kiểm toán.

Không tạo hoặc ghi đè:

- Buy;
- Sell;
- Short;
- Cover;
- PositionSize;
- stop;
- order;
- điểm xác suất giao dịch.

Exploration chỉ xuất các trường quan sát, trạng thái và tọa độ.

## 23. Phản ví dụ bắt buộc

Các trường hợp sau không được gán sai:

- High chỉ chạm resistance → không Upthrust-like.
- High xuyên resistance nhưng PriorClose đã ở trên resistance → không coi là fresh Upthrust origin.
- High xuyên và Close vẫn trên resistance → chỉ Upper Breakout Observation, không Upthrust-like.
- High xuyên rất sâu nhưng Close quay lại dưới resistance → không loại chỉ vì >1 ATR.
- RVOL/RSpread cao → không tự gọi UTAD.
- RVOL/RSpread thấp → không tự loại Upthrust/UTAD context.
- ClosePosition >0.50 nhưng Close vẫn dưới resistance → vẫn có thể là Upthrust-like, chỉ chất lượng rejection yếu hơn.
- k+1 High retest trên resistance nhưng Close trở lại dưới resistance và thấp hơn Close_k → vẫn có thể xác nhận cơ bản; FullyBelowResistance=0.
- breakout giữ trên resistance nhiều thanh → không ép thành Upthrust hoặc UTAD tại thanh đầu tiên.
- pivot High chỉ xác nhận tại k → không dùng làm resistance prior của k.
- pivot mới k+1 → không thay resistance snapshot của origin k.
- k+1 thất bại, k+2 mới giảm → không xác nhận muộn Upthrust-like.
- Upthrust-like xảy ra ngoài distribution → không gán UTAD.

## 24. So sánh với PR #13 hiện tại

Nếu đặc tả này được phê duyệt, AFL/đặc tả phát triển PR #13 phải được sửa ở các điểm trọng yếu:

1. bỏ `MaxPenetrationATR=1.00` khỏi hard gate của origin;
2. tách ClosePosition khỏi hard gate của Origin;
3. tách RVOL/RSpread khỏi hard gate Origin;
4. xóa logic `UTAD-LIKE = deep penetration OR high effort`;
5. không dùng UTAD như OriginKind ở Event layer;
6. thêm `PriorClose <= Resistance` để đảm bảo fresh upper thrust;
7. thêm UpperBreakoutObservation cho trường hợp Close vẫn trên resistance;
8. thay resolution tối thiểu từ `High_t <= Resistance AND Close_t < Close_k` thành `Close_t <= Resistance AND Close_t < Close_k`;
9. giữ `High_t <= Resistance` như chỉ báo xác nhận mạnh hơn;
10. bổ sung đầy đủ validity/snapshot/context theo D15.

Do đó PR #13 hiện tại phải tiếp tục được coi là `UNAPPROVED DEVELOPMENT` cho đến khi đặc tả này được phê duyệt và AFL được căn chỉnh.

## 25. Bảng quyết định cần chủ dự án phê duyệt

| Mã | Đề xuất | Khuyến nghị |
|---|---|---|
| D01 | Resistance = pivot High gần nhất đã xác nhận trước k | Chấp thuận |
| D02 | Yêu cầu PriorClose <= Resistance để xác định fresh thrust | Chấp thuận |
| D03 | Penetration khi High > Resistance, strict/no epsilon | Chấp thuận |
| D04 | Không dùng MaxPenetrationATR hard gate | Chấp thuận |
| D05 | Upthrust-like = High > Resistance và Close <= Resistance | Chấp thuận |
| D06 | ClosePosition chỉ là quality descriptor, không gate | Chấp thuận |
| D07 | RVOL/RSpread chỉ là effort context, không phân biệt UT/UTAD | Chấp thuận |
| D08 | OriginCode chỉ dựa trên price/structure contract | Chấp thuận |
| D09 | Close > Resistance sau penetration = UpperBreakoutObservation | Chấp thuận |
| D10 | k+1 confirm: Close <= Resistance và Close < Close_k | Chấp thuận |
| D11 | Không late confirmation; thiếu data != rejected | Chấp thuận |
| D12 | Resolution 0/1/2/3 riêng | Chấp thuận |
| D13 | Không có `UTAD-LIKE` ở Event v0.1; UTAD dành cho Phase Engine | Chấp thuận mạnh |
| D14 | Không ép UTAD vào k→k+1; lưu breakout observation cho sequence tương lai | Chấp thuận mạnh |
| D15 | Snapshot đầy đủ resistance/origin/effort/quality | Chấp thuận |
| D16 | Origin/Resolution/UpperBreakoutObservation là các kênh độc lập | Chấp thuận |
| D17 | No Demand là context tùy chọn, không gate | Chấp thuận |
| D18 | Distribution/UTAD chỉ do Phase Engine công bố có thời điểm | Chấp thuận mạnh |
| D19 | Daily completed-bar research; forming bar provisional | Chấp thuận |
| D20 | Không trading assignments | Chấp thuận |

## 26. Điều kiện chuyển sang triển khai

Chỉ sau khi chủ dự án phê duyệt D01–D20 mới:

1. đổi trạng thái đặc tả từ DỰ THẢO sang ĐÃ KHÓA;
2. sửa đặc tả phát triển, AFL và hồ sơ triển khai ở PR #13 theo đặc tả này;
3. không giữ nhãn `UTAD-LIKE` cũ nếu không có Phase Engine;
4. không coi AFL PR #13 hiện tại là source-of-truth;
5. kiểm thử vẫn có thể hoãn theo chiến lược hiện tại, nhưng trạng thái sau sửa chỉ được gọi `SPEC-ALIGNED / UNTESTED DEVELOPMENT`;
6. các Event tiếp theo phải theo cùng quy trình: nghiên cứu → dự thảo đặc tả → chủ dự án duyệt → khóa → triển khai.
