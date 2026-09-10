# Wyckoff Event — Spring / Shakeout v1.0

**Trạng thái:** TRIỂN KHAI PHÁT TRIỂN — CHƯA KIỂM THỬ. Tài liệu này khóa định nghĩa vận hành cho nhánh phát triển hiện tại để có thể hoàn thiện bộ chỉ báo trước khi quay lại chiến dịch kiểm thử tổng thể.

## 1. Phạm vi

v1.0 nhận diện hai biến thể xuyên hỗ trợ rồi thu hồi trên cùng thanh:

- **Spring**: xuyên hỗ trợ, thu hồi, đóng cửa tốt, trong bối cảnh nỗ lực/biên độ không cao.
- **Shakeout**: xuyên hỗ trợ, thu hồi, đóng cửa tốt, nhưng có nỗ lực hoặc biên độ cao hơn.

Đây là định nghĩa vận hành của dự án, không tuyên bố là định nghĩa duy nhất của phương pháp Wyckoff. Không nhận diện pha tích lũy/phân phối, SOS, LPS, tín hiệu mua/bán, xác suất hoặc quản trị vốn.

Luồng mã:

`Core → Candidate → Structure/Location → Confirmation → Supply Test → Spring/Shakeout`

Tệp triển khai: `afl/WyckoffVSA_Event_SpringShakeout_v1.0.afl` và dùng `#include_once <WyckoffVSA_Event_SupplyTest_v1.0.afl>`.

## 2. Nguồn hỗ trợ

Nguồn hỗ trợ duy nhất là pivot Low gần nhất đã được xác nhận **trước** thanh khởi phát k:

- `SL_PivotLowLatestPriorValid = 1`;
- `SL_PivotLowLatestPriorPrice` hữu hạn và > 0;
- `SL_PivotLowLatestPriorConfirmBarIndex < BarIndex()`;
- tọa độ xác nhận tồn tại.

Không dùng S/M/L làm hỗ trợ thay thế. Pivot mới được xác nhận tại k hoặc k+1 không được ghi ngược thành hỗ trợ của sự kiện đã bắt đầu.

## 3. Điều kiện khởi phát

Thanh k phải có dữ liệu giá hợp lệ, `PriorATRValid=1`, RVOL/RSpread/ClosePosition hợp lệ và hỗ trợ hợp lệ.

Một undercut/reclaim hợp lệ khi:

```text
Low_k < SupportPrice
Close_k >= SupportPrice
CloseStateCode_k >= 4
```

`CloseStateCode >= 4` tương ứng đóng cửa vùng trên hoặc mạnh theo Core hiện hành. Độ xuyên được đo và xuất dưới dạng:

```text
PenetrationATR = (SupportPrice - Low_k) / PriorATR_k
```

v1.0 **không đặt trần PenetrationATR**. Giá trị này được giữ để lớp bối cảnh/pha sau đánh giá, tránh tự thêm một ngưỡng chưa được kiểm chứng.

## 4. Phân loại Spring và Shakeout

Chỉ phân loại khi undercut/reclaim hợp lệ.

### Spring

```text
RVOLStateCode in 1..3
AND RSpreadStateCode in 1..3
```

Tức nỗ lực và biên độ thuộc các dải Extremely Low/Low/Normal và Very Narrow/Narrow/Normal đã được Core khóa.

### Shakeout

```text
RVOLStateCode >= 4
OR RSpreadStateCode >= 4
```

Tức ít nhất một trong hai chiều nỗ lực hoặc biên độ đã chuyển sang nhóm High/Wide trở lên.

Quy tắc này tạo hai miền không chồng lấn khi RVOL/RSpread đều hợp lệ. Event không định nghĩa lại ngưỡng số của Core và không tối ưu lại các dải này.

## 5. Mã trạng thái khởi phát

`WE_SS_OriginCode`:

| Mã | Ý nghĩa |
|---:|---|
| 0 | `INSUFFICIENT DATA` |
| 1 | `NOT PRESENT` |
| 2 | `SPRING CANDIDATE` |
| 3 | `SHAKEOUT CANDIDATE` |

`WE_SS_OriginValid=1` cho mã 1/2/3, bằng 0 cho mã 0.

Lý do chính:

- 0: không áp dụng;
- 1: không có pivot Low prior hợp lệ;
- 2: ATR prior không hợp lệ;
- 3: không xuyên hỗ trợ;
- 4: xuyên nhưng không thu hồi hỗ trợ;
- 5: đóng cửa chưa đủ mạnh;
- 6: RVOL/RSpread không hợp lệ;
- 7: dữ liệu giá không hợp lệ.

## 6. Xác nhận ở thanh kế tiếp

Sự kiện origin tại k chỉ được giải quyết ở `t=k+1`.

Xác nhận khi đồng thời:

```text
Close_t > OriginClose
Low_t >= SupportPrice
```

và dữ liệu giá tại t hợp lệ.

Nếu `Close_t <= OriginClose`, phản ứng tăng chưa được xác nhận. Nếu `Low_t < SupportPrice`, hỗ trợ lại bị xuyên. Nếu cả hai xảy ra, ghi lý do kết hợp. Không xác nhận tại k+2 hoặc muộn hơn.

`WE_SS_ResolutionCode`:

| Mã | Ý nghĩa |
|---:|---|
| 0 | `INSUFFICIENT DATA` |
| 1 | `NO PRIOR SPRING/SHAKEOUT` |
| 2 | `EVENT REJECTED` |
| 3 | `SPRING CONFIRMED` |
| 4 | `SHAKEOUT CONFIRMED` |

Origin và Resolution là hai kênh riêng. Một thanh có thể vừa giải quyết sự kiện từ t-1 vừa mở ứng viên mới tại t.

## 7. Snapshot bắt buộc

Khi origin là Spring/Shakeout candidate, phải lưu:

- Origin BarIndex/DateTime và OriginClose;
- SupportPrice;
- pivot Low extreme/confirm coordinates;
- PriorATR và PenetrationATR;
- RVOL, RSpread, ClosePosition và state code tương ứng;
- S/M/L context để nghiên cứu, nhưng context này không thay đổi quyết định origin.

Resolution phải mang lại đúng snapshot của origin bằng `Ref(...,-1)` và không thay bằng pivot/context mới tại k+1.

## 8. Bất biến

- Chỉ dùng thông tin có sẵn tại từng thời điểm.
- Không dùng Zig/Peak/Trough nhìn tương lai.
- Không ghi ngược kết quả về thanh k.
- Không xác nhận muộn.
- Không sửa Core/Candidate/Structure/Confirmation/Supply Test.
- Không có Buy/Sell/Short/Cover, điểm số, tối ưu lợi nhuận hoặc cảnh báo tự động.
- Thanh đang hình thành chỉ là provisional; kiểm thử realtime được để lại cho chiến dịch nghiệm thu sau khi bộ chỉ báo hoàn chỉnh.

## 9. Trạng thái kiểm thử

Theo quyết định hiện tại của chủ dự án, kiểm thử AmiBroker native, fixture, causal/append và hồi quy được **tạm hoãn** cho đến khi hoàn thiện bộ chỉ báo. Vì vậy mã ở nhánh này là bản phát triển, không được coi là đã nghiệm thu hoặc phát hành.
