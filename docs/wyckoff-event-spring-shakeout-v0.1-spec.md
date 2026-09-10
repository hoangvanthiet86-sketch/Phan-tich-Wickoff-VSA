# Wyckoff Event — Spring / Shakeout v0.1

**Trạng thái:** BẢN PHÁT TRIỂN CHƯA KIỂM THỬ. Tài liệu này phục vụ xây dựng bộ chỉ báo hoàn chỉnh trước khi quay lại chiến dịch kiểm thử tổng thể. Chưa phải đặc tả nghiệm thu cuối và chưa thay đổi bất kỳ hợp đồng đã khóa nào của Core, Candidate, Structure/Location, Confirmation hoặc Supply Test.

## 1. Mục tiêu

Mô-đun này nhận diện một **họ sự kiện xuyên hỗ trợ rồi thu hồi** tại một pivot Low đã được xác nhận trước. Nó tách trường hợp này khỏi Supply Test thông thường, vì Supply Test v1.0 không cho phép xuyên hỗ trợ.

Luồng dữ liệu phát triển:

`Core → Candidate → Structure/Location → Confirmation → Event modules`

Spring / Shakeout là một Event module ngang hàng với Supply Test. Mô-đun không sửa công thức upstream, không phát Buy/Sell, không quản trị vốn, không chấm điểm xác suất và không suy luận pha tích lũy chỉ từ một sự kiện.

## 2. Nguồn hỗ trợ

Nguồn hỗ trợ duy nhất trong v0.1 là `SL_PivotLowLatestPrior...` tại thanh khởi phát `k`.

Hỗ trợ hợp lệ khi:

- `SL_PivotLowLatestPriorValid = 1`;
- giá pivot hữu hạn và > 0;
- Pivot Confirm BarIndex tồn tại và nhỏ hơn BarIndex của `k`;
- tọa độ xác nhận pivot tồn tại.

Không dùng S/M/L làm hỗ trợ thay thế. Một pivot mới chỉ xác nhận tại `k` hoặc `k+1` không được dùng ngược về trước.

## 3. Điều kiện khởi phát

Một ứng viên Spring/Shakeout tại `k` yêu cầu:

- dữ liệu giá hiện tại hợp lệ;
- PriorATR hợp lệ và > 0;
- hỗ trợ prior hợp lệ;
- `Low_k < SupportPrice`;
- độ xuyên không lớn hơn `1.00 * PriorATR_k`;
- `Close_k >= SupportPrice`, tức thu hồi hỗ trợ ngay trên chính thanh xuyên;
- ClosePosition hợp lệ và `ClosePosition_k >= 0.50`;
- RVOL và RSpread hợp lệ để phân loại cường độ.

Các hằng số phát triển:

```text
WE_SS_MaxPenetrationATR   = 1.00
WE_SS_DeepPenetrationATR  = 0.50
WE_SS_MinClosePosition    = 0.50
WE_SS_ShakeoutRSpreadMin  = 1.20
WE_SS_ShakeoutRVOLMin     = 1.25
```

Các hằng số này là lựa chọn thiết kế v0.1 để tiếp tục phát triển; chưa được coi là ngưỡng nghiệm thu cuối. Khi quay lại giai đoạn kiểm thử, chúng phải được khóa trước khi xây expected chính thức.

## 4. Phân loại Spring-like và Shakeout-like

Khi toàn bộ điều kiện khởi phát đạt:

- `SPRING-LIKE` nếu độ xuyên `<= 0.50 ATR` và không đồng thời có RSpread >= 1.20 cùng RVOL >= 1.25;
- `SHAKEOUT-LIKE` nếu độ xuyên `> 0.50 ATR` **hoặc** đồng thời RSpread >= 1.20 và RVOL >= 1.25.

Đây là phân loại vận hành của mô-đun, không phải tuyên bố rằng mọi trường hợp như vậy đều là Spring/Shakeout chuẩn trong mọi trường phái Wyckoff. Vì vậy các nhãn trong v0.1 cố ý dùng hậu tố `-LIKE`.

## 5. Xác nhận tại thanh kế tiếp

Origin tại `k` chỉ được giải quyết tại `t = k+1`.

Một ứng viên được xác nhận khi:

- dữ liệu giá tại `t` hợp lệ;
- `Low_t >= SupportPrice` đã chụp tại `k`;
- `Close_t > Close_k`.

Nếu một trong hai điều kiện phản ứng giá trên thất bại nhưng dữ liệu vẫn hợp lệ, sự kiện bị bác bỏ tại `k+1`. Không chờ `k+2`, không xác nhận muộn và không backfill kết luận vào `k`.

## 6. Trạng thái

### 6.1 Origin

`WE_SS_OriginCode`:

- 0 = `INSUFFICIENT DATA`
- 1 = `NOT PRESENT`
- 2 = `SPRING/SHAKEOUT CANDIDATE`

`WE_SS_OriginKindCode` khi OriginCode=2:

- 1 = `SPRING-LIKE`
- 2 = `SHAKEOUT-LIKE`

`WE_SS_OriginReasonCode`:

- 0: không lỗi / không áp dụng;
- 1: không xuyên hỗ trợ;
- 2: không có pivot Low prior hợp lệ;
- 3: PriorATR không hợp lệ;
- 4: xuyên sâu hơn 1.00 ATR;
- 5: Close không thu hồi hỗ trợ;
- 6: ClosePosition dưới 0.50;
- 7: RVOL/RSpread không hợp lệ;
- 8: dữ liệu giá hiện tại không hợp lệ.

### 6.2 Resolution

`WE_SS_ResolutionCode`:

- 0 = `INSUFFICIENT DATA`
- 1 = `NO PRIOR SPRING/SHAKEOUT`
- 2 = `SPRING/SHAKEOUT REJECTED`
- 3 = `SPRING/SHAKEOUT CONFIRMED`

`WE_SS_Confirmed = 1` chỉ ở code 3.

`WE_SS_ResolutionReasonCode`:

- 0: không lỗi / không có prior event;
- 1: Close không tăng so với origin;
- 2: Low xuyên lại dưới support;
- 3: đồng thời thất bại cả hai;
- 4: dữ liệu đánh giá không hợp lệ.

## 7. Tọa độ và snapshot

Khi OriginCode=2 phải lưu:

- OriginBarIndex / OriginDateTime;
- OriginKindCode;
- Origin Low / Close / ClosePosition;
- SupportPrice;
- Support pivot extreme/confirm BarIndex và DateTime;
- PriorATR;
- Penetration giá và PenetrationATR;
- RVOL và RSpread dùng để phân loại.

Resolution ở `k+1` phải mang nguyên snapshot của `k`, cộng EvaluationBarIndex/DateTime, Low/Close hiện tại và lý do xác nhận/bác bỏ. Pivot mới sau `k` không được thay SupportPrice của event đang giải quyết.

## 8. Chồng lấn và nhân quả

Origin và Resolution là hai kênh độc lập. Một thanh có thể vừa giải quyết sự kiện từ thanh trước vừa tạo event mới của chính nó.

Chỉ dùng dữ liệu đã tồn tại tại thời điểm công bố. Không Zig/Peak/Trough nhìn tương lai, không backfill, không dùng BarCount để suy đoán thanh đã hoàn tất. Kết quả trên thanh cuối chưa hoàn tất là provisional.

## 9. Quan hệ với các mô-đun khác

- Supply Test: không xuyên hỗ trợ; Spring/Shakeout: có xuyên rồi thu hồi.
- No Supply Candidate: có thể xuất hiện hoặc không; không phải điều kiện bắt buộc của Spring/Shakeout v0.1.
- S/M/L: chỉ làm context nghiên cứu, không phải support fallback.
- Phase Engine tương lai: mới là lớp tổng hợp chuỗi sự kiện; một Spring/Shakeout đơn lẻ không tự gán tích lũy.

## 10. Trạng thái kiểm thử

Theo quyết định hiện tại của chủ dự án, kiểm thử native và nghiệm thu được hoãn để hoàn thiện bộ chỉ báo trước. Vì vậy mọi kết quả của mô-đun v0.1 phải được ghi `UNTESTED DEVELOPMENT`, không được coi là PASS, không merge vào `main` và không phát hành.
