# Wyckoff Event — Đặc tả dự thảo Spring / Shakeout v0.1

**Trạng thái:** DỰ THẢO ĐỂ CHỦ DỰ ÁN PHÊ DUYỆT. Chưa khóa, chưa phải tiêu chí nghiệm thu và không cho phép dùng tài liệu này để tuyên bố AFL hiện có là đúng. Không sửa Core, Candidate, Structure/Location, Confirmation hoặc Supply Test.

## 1. Mục tiêu và ranh giới

Mô-đun Spring / Shakeout v0.1 nhận diện **họ hành vi xuyên hỗ trợ đã biết trước rồi thu hồi lại hỗ trợ**, sau đó theo dõi phản ứng giá ở thanh kế tiếp.

Luồng kiến trúc:

`Core → Candidate → Structure/Location → Confirmation → Wyckoff Event`

Spring / Shakeout là Event module ngang hàng với Supply Test. Supply Test v1.0 yêu cầu không xuyên hỗ trợ; Spring / Shakeout bắt đầu từ trường hợp `Low < SupportPrice` rồi thu hồi lại. Hai mô-đun không được diễn giải cùng một thanh khởi phát thành hai sự kiện đối nghịch.

Mô-đun không phát Buy/Sell, không quản trị vốn, không chấm điểm xác suất, không tự gán pha tích lũy/phân phối và không suy luận ý định tổ chức từ một thanh đơn lẻ.

Do chưa có Phase Engine, v0.1 chỉ dùng nhãn vận hành:

- `SPRING-LIKE`
- `SHAKEOUT-LIKE`
- `AMBIGUOUS RECLAIM`

Không gọi một tín hiệu đơn lẻ là Spring hoặc Shakeout cổ điển đã được xác nhận về mặt pha.

## 2. Nguồn dữ liệu và nguyên tắc kế thừa

Mô-đun chỉ đọc các đầu ra đã công bố từ upstream và OHLCV cần thiết. Không sao chép hoặc sửa công thức upstream.

Các nguồn bắt buộc tối thiểu:

- `PriceInputValid`, `Low`, `Close`, `ClosePosition`, `ClosePositionValid`;
- `PriorATR`, `PriorATRValid`;
- `RVOL`, `RVOLValid`;
- `RSpread`, `RSpreadValid`;
- `SL_PivotLowLatestPrior...` và các tọa độ extreme/confirm tương ứng;
- `BarIndex()` và `DateTime()` của nguồn.

S/M/L chỉ được xuất làm bối cảnh nghiên cứu. Không dùng S/M/L làm hỗ trợ thay thế nếu pivot Low prior không hợp lệ.

## 3. D01 — Nguồn hỗ trợ

**Đề xuất:** nguồn hỗ trợ duy nhất của v0.1 là **pivot Low gần nhất đã được xác nhận trước thanh khởi phát k**.

Tại k phải dùng nhóm `SL_PivotLowLatestPrior...`, không dùng pivot mới chỉ được xác nhận tại chính k.

`SupportValid_k = 1` khi đồng thời:

- `SL_PivotLowLatestPriorValid_k = 1`;
- `SupportPrice_k` hữu hạn và `> 0`;
- ExtremeBarIndex/DateTime tồn tại;
- ConfirmBarIndex/DateTime tồn tại;
- `PivotConfirmBarIndex_k < BarIndex_k`.

Đề xuất **không đặt tuổi tối đa cho support trong v0.1**. Tuy nhiên phải xuất `BarsSinceConfirmation`/Age nếu upstream có, để sau này kiểm tra xem support quá cũ có làm giảm chất lượng tín hiệu hay không.

Khi một origin hợp lệ được tạo, SupportPrice và toàn bộ tọa độ pivot phải được snapshot và giữ cố định cho sự kiện đó. Pivot mới xuất hiện ở k+1 không được thay support đang đánh giá.

## 4. D02 — Khái niệm xuyên và thu hồi hỗ trợ

Thanh k chỉ thuộc họ Spring/Shakeout khi:

```text
Low_k < SupportPrice_k
Close_k >= SupportPrice_k
```

So sánh là số thực nghiêm ngặt, không epsilon và không làm tròn theo hiển thị.

Ý nghĩa:

- `Low == SupportPrice`: không phải xuyên, nên không phải origin Spring/Shakeout.
- `Low < SupportPrice` nhưng `Close < SupportPrice`: có xuyên nhưng **chưa thu hồi**, không tạo origin hợp lệ trong v0.1.
- `Close == SupportPrice`: được coi là vừa đủ thu hồi.

Đây là lựa chọn bảo thủ để tách rõ một cú phá hỗ trợ chưa hồi phục khỏi một cú xuyên rồi lấy lại vùng.

## 5. D03 — Giới hạn độ xuyên

Độ xuyên được chuẩn hóa bằng PriorATR tại k:

```text
Penetration      = SupportPrice_k - Low_k
PenetrationATR   = Penetration / PriorATR_k
```

Yêu cầu `PriorATRValid_k = 1`, PriorATR hữu hạn và `> 0`.

**Đề xuất khóa sau khi duyệt:**

```text
WE_SS_MaxPenetrationATR = 1.00
```

Origin chỉ hợp lệ khi:

```text
0 < PenetrationATR <= 1.00
```

Mục đích của giới hạn này là loại các cú phá hỗ trợ quá sâu khỏi nhóm Spring/Shakeout thông thường. Giá trị `1.00` là ngưỡng thiết kế đề xuất, chưa phải kết quả tối ưu hóa và không được hiệu chỉnh theo lợi nhuận sau khi kiểm thử bắt đầu.

## 6. D04 — Chất lượng thu hồi trong thanh origin

Ngoài việc Close trở lại trên/đúng support, đề xuất yêu cầu vị trí Close trong biên thanh:

```text
ClosePosition_k >= 0.50
```

Điều này yêu cầu `ClosePositionValid_k = 1`.

Biên `0.50` được bao hàm. Mục đích là tránh gọi một thanh chỉ vừa đóng cửa trên hỗ trợ nhưng vẫn đóng ở nửa dưới của biên độ là một cú thu hồi đủ chất lượng.

**Quyết định cần duyệt:** có giữ ngưỡng `0.50` hay yêu cầu mạnh hơn, ví dụ `0.60`.

Khuyến nghị v0.1: **giữ 0.50** để mô-đun không trở thành quá chọn lọc trước khi có bằng chứng kiểm thử.

## 7. D05 — Origin family và phân loại Kind phải tách riêng

Đề xuất không để thiếu RVOL/RSpread làm mất toàn bộ một origin giá hợp lệ.

### 7.1. Origin family

`WE_SS_OriginCode` chỉ trả lời có tồn tại hành vi xuyên-thu hồi hợp lệ hay không:

- 0 = `INSUFFICIENT DATA`
- 1 = `NOT PRESENT`
- 2 = `PENETRATION RECLAIM CANDIDATE`

OriginCode=2 yêu cầu:

- giá tại k hợp lệ;
- support prior hợp lệ;
- PriorATR hợp lệ;
- `Low_k < SupportPrice`;
- `Close_k >= SupportPrice`;
- `ClosePosition_k >= 0.50`;
- `PenetrationATR <= 1.00`.

RVOL/RSpread **không quyết định OriginCode**; chúng chỉ quyết định phân loại Spring-like / Shakeout-like.

Lý do: thiếu dữ liệu effort không nên biến một hành vi xuyên-thu hồi giá đã quan sát được thành “không có sự kiện”. Thay vào đó, hệ thống phải nói rõ rằng loại sự kiện chưa phân loại được.

### 7.2. Origin Kind

`WE_SS_OriginKindCode` đề xuất:

- 0 = `INSUFFICIENT EFFORT DATA`
- 1 = `SPRING-LIKE`
- 2 = `SHAKEOUT-LIKE`
- 3 = `AMBIGUOUS RECLAIM`

`WE_SS_OriginKindValid = 1` khi code 1/2/3; bằng 0 khi code 0.

Chỉ tính Kind khi OriginCode=2.

## 8. D06 — Phân biệt Spring-like và Shakeout-like

Đề xuất dùng cả **độ xuyên** và **nỗ lực** thay vì chỉ một trong hai.

Các ngưỡng phát triển đề xuất:

```text
WE_SS_ShallowPenetrationATR = 0.50
WE_SS_HighEffortRVOL        = 1.25
WE_SS_WideSpreadRSpread     = 1.20
```

Nếu RVOL và RSpread đều hợp lệ:

### SPRING-LIKE

```text
PenetrationATR <= 0.50
AND RVOL < 1.25
AND RSpread < 1.20
```

Ý nghĩa vận hành: xuyên tương đối nông và không có đồng thời đặc trưng nỗ lực/biên độ lớn.

### SHAKEOUT-LIKE

```text
RVOL >= 1.25
AND RSpread >= 1.20
```

và vẫn phải thỏa toàn bộ Origin family ở mục 7.1.

Ý nghĩa vận hành: cùng là xuyên-thu hồi nhưng diễn ra với nỗ lực và biên độ tương đối cao hơn.

### AMBIGUOUS RECLAIM

Mọi origin hợp lệ còn lại khi effort data hợp lệ nhưng không rơi rõ vào hai nhóm trên.

Ví dụ:

- xuyên sâu nhưng volume thấp;
- volume cao nhưng spread không rộng;
- spread rộng nhưng volume không cao.

Đề xuất **không ép các trường hợp này thành Spring hoặc Shakeout**, để tránh gán nhãn quá mức.

Nếu RVOL hoặc RSpread không hợp lệ, OriginCode vẫn có thể bằng 2 nhưng OriginKindCode=0.

## 9. D07 — Xác nhận tại thanh kế tiếp

Mỗi origin tại k chỉ được giải quyết tại:

```text
t = k + 1
```

Đề xuất xác nhận khi đồng thời:

```text
Low_t   >= SupportPrice_k
Close_t >  Close_k
```

và dữ liệu giá tại t hợp lệ.

Giải thích:

- Low không xuyên lại support: support đã được giữ sau cú thu hồi.
- Close cao hơn Close origin: có phản ứng giá tiếp diễn theo hướng hồi phục.

Không yêu cầu RVOL/RSpread ở k+1 trong v0.1. Các chỉ tiêu này có thể xuất làm context nhưng không tham gia xác nhận để tránh trộn thêm giả thuyết chưa được kiểm chứng.

Không dùng Confirmation No Supply/No Demand như điều kiện bắt buộc cho Spring/Shakeout, vì đây là một họ sự kiện độc lập và không nên ép nó qua định nghĩa của Candidate khác.

## 10. D08 — Bác bỏ và dữ liệu thiếu

Một prior origin hợp lệ tại k được giải quyết duy nhất tại k+1:

- `CONFIRMED` nếu D07 đạt;
- `REJECTED` nếu dữ liệu hợp lệ nhưng một hoặc cả hai điều kiện phản ứng thất bại;
- `INSUFFICIENT DATA` nếu dữ liệu đánh giá bắt buộc không hợp lệ.

Lý do bác bỏ đề xuất:

1. Close không tăng so với origin;
2. Low xuyên lại dưới support;
3. đồng thời thất bại cả hai.

Dữ liệu thiếu không được diễn giải là cung mạnh hoặc thất bại của Spring/Shakeout.

Không có xác nhận muộn tại k+2. Một thanh k+2 thuận lợi không được hồi sinh sự kiện đã bị bác bỏ hoặc thiếu dữ liệu tại k+1.

## 11. D09 — Hợp đồng Resolution

`WE_SS_ResolutionCode`:

- 0 = `INSUFFICIENT DATA`
- 1 = `NO PRIOR SPRING/SHAKEOUT`
- 2 = `SPRING/SHAKEOUT REJECTED`
- 3 = `SPRING/SHAKEOUT CONFIRMED`

`WE_SS_ResolutionValid = 1` cho code 1/2/3, bằng 0 cho code0.

`WE_SS_Confirmed = 1` chỉ ở code3.

`WE_SS_ConfirmedKindCode` mang nguyên KindCode của origin được xác nhận; không được phân loại lại bằng dữ liệu k+1.

Nếu origin có KindCode=0 do thiếu effort data nhưng price resolution đạt, ResolutionCode vẫn có thể là 3 nhưng ConfirmedKindCode=0. Điều này có nghĩa: **hành vi xuyên-thu hồi được xác nhận về giá, nhưng chưa đủ dữ liệu để gọi Spring-like hay Shakeout-like**.

## 12. D10 — Chồng lấn

Origin và Resolution phải là hai kênh độc lập.

Một thanh t có thể đồng thời:

- giải quyết event bắt đầu tại t-1;
- tạo origin mới của chính t.

Không dùng một StatusCode duy nhất để chọn trạng thái “quan trọng hơn”.

Khóa event đề xuất:

```text
Symbol
+ OriginBarIndex
+ OriginDateTime
+ SupportPivotConfirmBarIndex
```

## 13. D11 — Tọa độ và snapshot bắt buộc

Khi OriginCode=2 phải snapshot tối thiểu:

- OriginBarIndex / OriginDateTime;
- Origin Low / Close / ClosePosition;
- SupportPrice;
- Support pivot ExtremeBarIndex/DateTime;
- Support pivot ConfirmBarIndex/DateTime;
- PriorATR;
- Penetration và PenetrationATR;
- RVOL/RSpread và validity tại k;
- OriginKindCode/Valid;
- S/M/L context nếu xuất để nghiên cứu.

Resolution tại k+1 phải mang nguyên snapshot origin và bổ sung:

- EvaluationBarIndex / EvaluationDateTime;
- Low / Close tại evaluation;
- SupportHeld;
- CloseImproved;
- ResolutionCode / ReasonCode;
- ConfirmedKindCode.

Pivot mới tại k+1 không được thay SupportPrice đã snapshot.

## 14. D12 — Quan hệ với Supply Test

Hai mô-đun phải loại trừ nhau tại cùng origin theo quy tắc giá:

### Supply Test

```text
Low_k >= SupportPrice
```

### Spring / Shakeout

```text
Low_k < SupportPrice
AND Close_k >= SupportPrice
```

Do đó một thanh không được đồng thời có OriginCode=2 của Supply Test và Spring/Shakeout nếu cả hai triển khai đúng đặc tả.

Một Spring/Shakeout được xác nhận có thể trở thành context cho Event khác trong tương lai, nhưng không tự tạo Supply Test, SOS hoặc LPS nếu chưa đáp ứng hợp đồng riêng của các mô-đun đó.

## 15. D13 — Quan hệ với Phase Engine tương lai

v0.1 không có đủ cấu trúc để khẳng định một Spring xảy ra ở Phase C hoặc một Shakeout thuộc tích lũy.

Phase Engine tương lai có thể dùng:

- vị trí trong trading range;
- chuỗi PS/SC/AR/ST;
- lịch sử hỗ trợ/kháng cự;
- các Event xác nhận trước đó;
- Spring-like / Shakeout-like đã công bố.

Nhưng Phase Engine không được ghi ngược sự kiện vào quá khứ. Nó chỉ có thể công bố một đánh giá pha mới tại thời điểm đủ bằng chứng.

## 16. D14 — Chính sách thanh hoàn tất và sửa dữ liệu

Phạm vi v0.1: Daily, dữ liệu thanh đã hoàn tất, một mã/một khung thời gian trong mỗi lượt kiểm toán.

Thanh cuối chưa được nguồn xác nhận hoàn tất chỉ là provisional. Không dùng BarCount để tự suy đoán “đã đóng phiên”.

Nếu nguồn OHLCV lịch sử được sửa, kết quả phụ thuộc có thể thay đổi. Hồ sơ kiểm thử phải phân biệt:

- source revision;
- algorithmic repaint.

Không Zig/Peak/Trough nhìn tương lai, không backfill, không dùng pivot mới xác nhận như thể đã biết trước.

## 17. Bảng trạng thái đề xuất

### 17.1 OriginReasonCode

- 0: không lỗi / không áp dụng;
- 1: không xuyên support;
- 2: không có pivot Low prior hợp lệ;
- 3: PriorATR không hợp lệ;
- 4: xuyên sâu hơn MaxPenetrationATR;
- 5: Close chưa thu hồi support;
- 6: ClosePosition dưới ngưỡng;
- 7: dữ liệu giá origin không hợp lệ;
- 8: chỉ thiếu effort data — **không làm OriginCode=0**, chỉ làm KindCode=0.

### 17.2 ResolutionReasonCode

- 0: không lỗi / không có prior origin;
- 1: Close không tăng;
- 2: Low xuyên lại support;
- 3: đồng thời thất bại cả hai;
- 4: dữ liệu đánh giá không hợp lệ.

Mã lý do là dữ liệu kiểm toán, không phải điểm số.

## 18. Phản ví dụ bắt buộc

Các tình huống sau **không được** gán sai:

- Low chỉ chạm support nhưng không xuyên → không phải Spring/Shakeout.
- Low xuyên nhưng Close vẫn dưới support → không phải origin hợp lệ.
- Low xuyên hơn 1.00 PriorATR → không thuộc v0.1.
- Close thu hồi support nhưng đóng ở nửa dưới thanh → không origin nếu giữ ngưỡng ClosePosition 0.50.
- một cú xuyên-thu hồi với effort không rõ → `AMBIGUOUS RECLAIM` hoặc Kind insufficient, không ép nhãn.
- pivot Low chỉ được xác nhận ở k → không được dùng làm prior support của k.
- pivot mới ở k+1 → không thay support của event đã bắt đầu ở k.
- k+1 thất bại, k+2 hồi phục → không xác nhận muộn.
- sửa dữ liệu lịch sử làm thay event → phải ghi là source revision nếu đầu vào đã thay đổi.

## 19. Quyết định cần chủ dự án phê duyệt

Để khóa đặc tả trước khi sửa/viết lại AFL, cần chấp thuận hoặc chỉnh các điểm sau:

| Mã | Đề xuất | Khuyến nghị |
|---|---|---|
| D01 | Support = pivot Low gần nhất đã xác nhận trước k | Chấp thuận |
| D02 | Xuyên khi Low < support; thu hồi khi Close >= support | Chấp thuận |
| D03 | MaxPenetrationATR = 1.00 | Chấp thuận thử nghiệm v0.1 |
| D04 | ClosePosition >= 0.50 | Chấp thuận |
| D05 | Tách Origin family khỏi Kind classification | Chấp thuận |
| D06 | 3 loại Kind: Spring-like / Shakeout-like / Ambiguous | Chấp thuận |
| D06a | Spring-like: shallow <=0.50 ATR, RVOL<1.25, RSpread<1.20 | Chấp thuận thử nghiệm v0.1 |
| D06b | Shakeout-like: RVOL>=1.25 và RSpread>=1.20 | Chấp thuận thử nghiệm v0.1 |
| D07 | Xác nhận duy nhất tại k+1: Low giữ support và Close > Close_k | Chấp thuận |
| D08 | Không xác nhận muộn; dữ liệu thiếu ≠ bị bác bỏ | Chấp thuận |
| D09 | ConfirmedKind giữ nguyên Kind của origin | Chấp thuận |
| D10 | Origin và Resolution tách kênh để cho phép chồng lấn | Chấp thuận |
| D11 | Snapshot support/pivot/origin bất biến đến resolution | Chấp thuận |
| D12 | Supply Test và Spring/Shakeout loại trừ nhau tại origin | Chấp thuận |
| D13 | Chỉ dùng nhãn -LIKE trước khi có Phase Engine | Chấp thuận |
| D14 | Daily completed-bar research; forming bar provisional | Chấp thuận |

## 20. Điều kiện chuyển sang triển khai

Chỉ sau khi chủ dự án phê duyệt D01–D14 mới:

1. đổi trạng thái tài liệu từ DỰ THẢO sang ĐÃ KHÓA;
2. sửa hoặc thay AFL Spring/Shakeout hiện có để khớp đúng đặc tả;
3. không coi AFL cũ là nguồn chuẩn nếu có khác biệt;
4. tiếp tục phát triển mô-đun tiếp theo theo cùng quy trình: **dự thảo đặc tả → duyệt → khóa → triển khai**;
5. chiến dịch fixture/expected/native test vẫn có thể hoãn theo quyết định hiện tại, nhưng không được bỏ qua bước duyệt đặc tả.
