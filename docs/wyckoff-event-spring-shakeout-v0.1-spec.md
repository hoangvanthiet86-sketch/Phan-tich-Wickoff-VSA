# Wyckoff Event — Spring / Shakeout v0.1

**Trạng thái:** ĐÃ PHÊ DUYỆT VÀ KHÓA VỀ LOGIC D01–D14. Chủ dự án phê duyệt đặc tả tại PR #15; mốc hợp nhất phê duyệt: `ea5d1304d6751ad4a8c2b88c69f19d799c79bd8b`. Kiểm thử native/fixture/expected vẫn tạm hoãn theo quyết định hiện tại, vì vậy việc khóa đặc tả không đồng nghĩa mô-đun đã PASS hay sẵn sàng phát hành.

## 1. Mục tiêu và ranh giới

Mô-đun Spring / Shakeout v0.1 nhận diện **họ hành vi xuyên hỗ trợ đã biết trước rồi thu hồi lại hỗ trợ**, sau đó theo dõi phản ứng giá ở thanh kế tiếp.

Luồng kiến trúc:

`Core → Candidate → Structure/Location → Confirmation → Wyckoff Event`

Spring / Shakeout là Event module ngang hàng với Supply Test. Supply Test v1.0 yêu cầu không xuyên hỗ trợ; Spring / Shakeout bắt đầu từ trường hợp `Low < SupportPrice` rồi thu hồi lại. Hai mô-đun không được diễn giải cùng một thanh khởi phát thành hai sự kiện đối nghịch.

Mô-đun không phát Buy/Sell, không quản trị vốn, không chấm điểm xác suất, không tự gán pha tích lũy/phân phối và không suy luận ý định tổ chức từ một thanh đơn lẻ. Trước Phase Engine chỉ dùng nhãn vận hành `SPRING-LIKE`, `SHAKEOUT-LIKE`, `AMBIGUOUS RECLAIM`.

## 2. Nguồn dữ liệu và nguyên tắc kế thừa

Mô-đun chỉ đọc các đầu ra upstream đã công bố và OHLCV cần thiết. Không sao chép hoặc sửa công thức upstream.

Nguồn tối thiểu: `PriceInputValid`, `Low`, `Close`, `ClosePosition`, `ClosePositionValid`, `PriorATR`, `PriorATRValid`, `RVOL`, `RVOLValid`, `RSpread`, `RSpreadValid`, nhóm `SL_PivotLowLatestPrior...`, `BarIndex()` và `DateTime()`.

S/M/L chỉ được snapshot làm bối cảnh nghiên cứu; không dùng làm hỗ trợ thay thế.

## 3. D01 — Nguồn hỗ trợ

Nguồn hỗ trợ duy nhất là **pivot Low gần nhất đã được xác nhận trước thanh khởi phát k**.

Tại k phải dùng `SL_PivotLowLatestPrior...`. `SupportValid_k = 1` khi đồng thời:

- `SL_PivotLowLatestPriorValid_k = 1`;
- SupportPrice hữu hạn và > 0;
- ExtremeBarIndex/DateTime tồn tại;
- ConfirmBarIndex/DateTime tồn tại;
- `PivotConfirmBarIndex_k < BarIndex_k`.

Không đặt tuổi tối đa của support trong v0.1. Nếu upstream có Age/BarsSinceConfirmation thì phải xuất để kiểm toán. Khi origin hợp lệ được tạo, SupportPrice và toàn bộ tọa độ pivot được snapshot và giữ cố định; pivot mới ở k+1 không được thay support đang đánh giá.

## 4. D02 — Xuyên và thu hồi hỗ trợ

Thanh k chỉ thuộc họ Spring/Shakeout khi:

```text
Low_k < SupportPrice_k
Close_k >= SupportPrice_k
```

So sánh số thực nghiêm ngặt, không epsilon, không làm tròn theo hiển thị. `Low == SupportPrice` không phải xuyên. `Low < SupportPrice` nhưng `Close < SupportPrice` là phá hỗ trợ chưa thu hồi và không tạo origin hợp lệ trong v0.1. `Close == SupportPrice` được coi là vừa đủ thu hồi.

## 5. D03 — Giới hạn độ xuyên

```text
Penetration    = SupportPrice_k - Low_k
PenetrationATR = Penetration / PriorATR_k
WE_SS_MaxPenetrationATR = 1.00
```

Yêu cầu PriorATR hợp lệ, hữu hạn và > 0. Origin chỉ hợp lệ khi `0 < PenetrationATR <= 1.00`. Ngưỡng này đã được phê duyệt cho v0.1 và không được tối ưu theo lợi nhuận sau khi bước kiểm thử bắt đầu.

## 6. D04 — Chất lượng thu hồi

Yêu cầu `ClosePositionValid_k = 1` và:

```text
ClosePosition_k >= 0.50
```

Biên 0.50 được bao hàm.

## 7. D05 — Tách Origin family khỏi Kind classification

`WE_SS_OriginCode` chỉ trả lời có hành vi xuyên-thu hồi hợp lệ hay không:

- 0 = `INSUFFICIENT DATA`
- 1 = `NOT PRESENT`
- 2 = `PENETRATION RECLAIM CANDIDATE`

OriginCode=2 yêu cầu: giá hợp lệ, support prior hợp lệ, PriorATR hợp lệ, `Low < Support`, `Close >= Support`, `ClosePosition >= 0.50`, `PenetrationATR <= 1.00`.

**RVOL/RSpread không quyết định OriginCode.** Thiếu effort data không được làm mất một origin giá hợp lệ; nó chỉ làm Kind không đủ dữ liệu.

`WE_SS_OriginKindCode`:

- 0 = `INSUFFICIENT EFFORT DATA`
- 1 = `SPRING-LIKE`
- 2 = `SHAKEOUT-LIKE`
- 3 = `AMBIGUOUS RECLAIM`

`WE_SS_OriginKindValid = 1` cho code 1/2/3 và bằng 0 cho code0. Chỉ tính Kind khi OriginCode=2.

## 8. D06 — Phân loại Spring-like / Shakeout-like / Ambiguous

Các ngưỡng khóa:

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

### SHAKEOUT-LIKE

```text
RVOL >= 1.25
AND RSpread >= 1.20
```

và vẫn phải thỏa Origin family.

### AMBIGUOUS RECLAIM

Mọi origin hợp lệ còn lại khi effort data hợp lệ nhưng không rơi rõ vào hai nhóm trên. Ví dụ: xuyên sâu nhưng volume thấp; volume cao nhưng spread không rộng; spread rộng nhưng volume không cao.

Nếu RVOL hoặc RSpread không hợp lệ, OriginCode vẫn có thể bằng 2 nhưng OriginKindCode=0.

## 9. D07 — Xác nhận tại thanh kế tiếp

Mỗi origin tại k chỉ được giải quyết tại `t = k+1`.

Xác nhận khi đồng thời:

```text
Low_t   >= SupportPrice_k
Close_t >  Close_k
```

và dữ liệu giá tại t hợp lệ. Không yêu cầu RVOL/RSpread ở k+1 và không dùng Confirmation No Supply/No Demand làm điều kiện bắt buộc.

## 10. D08 — Bác bỏ, dữ liệu thiếu và không xác nhận muộn

Một prior origin tại k được giải quyết duy nhất ở k+1:

- `CONFIRMED` nếu D07 đạt;
- `REJECTED` nếu dữ liệu hợp lệ nhưng một hoặc cả hai điều kiện phản ứng thất bại;
- `INSUFFICIENT DATA` nếu dữ liệu đánh giá bắt buộc không hợp lệ.

Lý do bác bỏ: (1) Close không tăng; (2) Low xuyên lại support; (3) đồng thời thất bại cả hai. Dữ liệu thiếu không được diễn giải là thất bại do cung mạnh. Không có xác nhận muộn tại k+2.

## 11. D09 — Hợp đồng Resolution

`WE_SS_ResolutionCode`:

- 0 = `INSUFFICIENT DATA`
- 1 = `NO PRIOR SPRING/SHAKEOUT`
- 2 = `SPRING/SHAKEOUT REJECTED`
- 3 = `SPRING/SHAKEOUT CONFIRMED`

`WE_SS_ResolutionValid = 1` cho code 1/2/3, bằng 0 cho code0. `WE_SS_Confirmed = 1` chỉ ở code3.

`WE_SS_ConfirmedKindCode` phải mang nguyên KindCode của origin được xác nhận; không phân loại lại bằng dữ liệu k+1. Nếu origin KindCode=0 do thiếu effort data nhưng phản ứng giá đạt, ResolutionCode vẫn có thể bằng 3 và ConfirmedKindCode vẫn bằng 0.

## 12. D10 — Chồng lấn

Origin và Resolution là hai kênh độc lập. Một thanh có thể vừa giải quyết event từ t-1 vừa tạo origin mới tại t.

Khóa event:

```text
Symbol + OriginBarIndex + OriginDateTime + SupportPivotConfirmBarIndex
```

## 13. D11 — Tọa độ và snapshot bắt buộc

Khi OriginCode=2 phải snapshot tối thiểu:

- OriginBarIndex/OriginDateTime;
- Origin Low/Close/ClosePosition;
- SupportPrice;
- Support pivot ExtremeBarIndex/DateTime;
- Support pivot ConfirmBarIndex/DateTime;
- PriorATR;
- Penetration và PenetrationATR;
- RVOL/RSpread cùng validity;
- OriginKindCode/Valid;
- Age/BarsSinceConfirmation nếu upstream có;
- S/M/L context nếu xuất để nghiên cứu.

Resolution tại k+1 phải mang nguyên snapshot origin và bổ sung EvaluationBarIndex/DateTime, Low/Close, SupportHeld, CloseImproved, ResolutionCode/ReasonCode và ConfirmedKindCode.

## 14. D12 — Quan hệ với Supply Test

Supply Test yêu cầu `Low_k >= SupportPrice`. Spring / Shakeout yêu cầu `Low_k < SupportPrice AND Close_k >= SupportPrice`. Vì vậy cùng một thanh không được đồng thời có OriginCode=2 của cả hai mô-đun nếu triển khai đúng hợp đồng.

## 15. D13 — Quan hệ với Phase Engine

v0.1 không đủ dữ liệu để khẳng định Spring thuộc Phase C hoặc Shakeout thuộc tích lũy. Chỉ dùng nhãn `-LIKE` trước Phase Engine. Phase Engine tương lai có thể dùng trading range, chuỗi PS/SC/AR/ST, lịch sử hỗ trợ/kháng cự và các Event đã công bố, nhưng không được ghi ngược sự kiện vào quá khứ.

## 16. D14 — Thanh hoàn tất, nhân quả và sửa dữ liệu

Phạm vi v0.1: Daily, dữ liệu thanh đã hoàn tất, một mã/một khung thời gian trong mỗi lượt kiểm toán. Thanh cuối chưa được nguồn xác nhận hoàn tất chỉ là provisional. Không dùng BarCount để suy đoán đã đóng phiên.

Nếu OHLCV lịch sử được sửa, kết quả phụ thuộc có thể thay đổi; hồ sơ phải phân biệt source revision với algorithmic repaint. Không Zig/Peak/Trough nhìn tương lai, không backfill, không dùng pivot mới xác nhận như thể đã biết trước.

## 17. Mã lý do khóa

### OriginReasonCode

- 0: không lỗi/không áp dụng;
- 1: không xuyên support;
- 2: không có pivot Low prior hợp lệ;
- 3: PriorATR không hợp lệ;
- 4: xuyên sâu hơn MaxPenetrationATR;
- 5: Close chưa thu hồi support;
- 6: ClosePosition dưới ngưỡng;
- 7: dữ liệu giá/ClosePosition origin không hợp lệ;
- 8: chỉ thiếu effort data — không làm OriginCode=0, chỉ làm KindCode=0.

### ResolutionReasonCode

- 0: không lỗi/không có prior origin;
- 1: Close không tăng;
- 2: Low xuyên lại support;
- 3: đồng thời thất bại cả hai;
- 4: dữ liệu đánh giá không hợp lệ.

## 18. Phản ví dụ bắt buộc

Không được gán sai trong các tình huống: Low chỉ chạm support; xuyên nhưng Close vẫn dưới support; xuyên >1 ATR; ClosePosition <0.50; effort không rõ; pivot chỉ xác nhận tại k; pivot mới ở k+1; k+1 thất bại nhưng k+2 hồi phục; hoặc dữ liệu lịch sử bị sửa.

## 19. Trạng thái triển khai và kiểm thử

AFL Spring/Shakeout phải khớp đúng đặc tả này. Việc kiểm thử native, fixture/expected, hồi quy, nhân quả, append và forming-bar hiện vẫn **TẠM HOÃN** để ưu tiên hoàn thiện bộ chỉ báo. Do đó mã triển khai chỉ được gọi là `UNTESTED DEVELOPMENT`, không được coi là PASS, không được phát hành và không được hợp nhất vào `main` trước chiến dịch kiểm thử tổng thể hoặc một quyết định ngoại lệ riêng.