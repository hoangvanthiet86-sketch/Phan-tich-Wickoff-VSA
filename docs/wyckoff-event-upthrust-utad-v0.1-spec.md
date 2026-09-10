# Wyckoff Event — Đặc tả phát triển Upthrust / UTAD v0.1

**Trạng thái:** PHÁT TRIỂN CHƯA KIỂM THỬ. Tài liệu này phục vụ hoàn thiện bộ chỉ báo trước chiến dịch kiểm thử tổng thể. Không phải đặc tả nghiệm thu cuối.

## 1. Phạm vi

Mô-đun này nhận diện giả thuyết phá kháng cự thất bại ở phía trên cấu trúc. Nó là nhánh đối xứng về kiến trúc với Spring / Shakeout nhưng không khẳng định đối xứng hoàn toàn về ý nghĩa thị trường.

Luồng dữ liệu giữ nguyên:

`Core → Candidate → Structure/Location → Confirmation → Event`

v0.1 chỉ dùng cho nghiên cứu có giám sát. Không phát Buy/Sell, không quản trị vốn, không gán pha phân phối, không dự đoán xu hướng.

## 2. Nguồn kháng cự

Nguồn kháng cự duy nhất của v0.1 là **pivot High gần nhất đã được xác nhận trước thanh khởi phát k**:

- `SL_PivotHighLatestPriorValid = 1`;
- `SL_PivotHighLatestPriorPrice` hữu hạn và > 0;
- `SL_PivotHighLatestPriorConfirmBarIndex < BarIndex_k`;
- tọa độ xác nhận tồn tại.

S/M/L chỉ dùng làm bối cảnh nghiên cứu, không làm nguồn kháng cự thay thế.

## 3. Điều kiện khởi phát

Các hằng số phát triển ban đầu:

```text
WE_UT_MaxPenetrationATR = 1.00
WE_UT_DeepPenetrationATR = 0.50
WE_UT_MaxClosePosition = 0.50
WE_UT_UTADRSpreadMin = 1.20
WE_UT_UTADRVOLMin = 1.25
```

Thanh k là ứng viên khi đồng thời:

1. dữ liệu giá, `PriorATR`, `RVOL`, `RSpread`, `ClosePosition` hợp lệ;
2. có pivot High prior hợp lệ;
3. `High_k > ResistancePrice`;
4. độ xuyên không vượt `1.00 * PriorATR_k`;
5. `Close_k <= ResistancePrice`, tức giá quay lại dưới/đúng kháng cự trong cùng thanh;
6. `ClosePosition_k <= 0.50`.

Nếu `High_k <= ResistancePrice` thì không có sự kiện. Nếu xuyên quá sâu, không thu hồi kháng cự hoặc đóng cửa quá cao thì không được coi là ứng viên Upthrust/UTAD v0.1.

## 4. Phân loại vận hành

Khi Origin hợp lệ:

- `UPTHRUST-LIKE` nếu không thỏa tiêu chí UTAD-like;
- `UTAD-LIKE` nếu độ xuyên > 0.50 ATR **hoặc** đồng thời `RSpread >= 1.20` và `RVOL >= 1.25`.

Tên `UTAD-LIKE` chỉ là **phân loại hình thái phát triển**. Nó không chứng minh đây là UTAD theo Wyckoff cổ điển vì v0.1 chưa có Phase Engine để xác nhận vùng phân phối hay vị trí pha.

## 5. Giải quyết tại thanh kế tiếp

Chỉ đánh giá tại `t = k+1`.

Ứng viên được xác nhận khi:

- dữ liệu giá tại t hợp lệ;
- `High_t <= ResistancePrice` đã khóa tại k;
- `Close_t < Close_k`.

Nếu một trong hai điều kiện giá thất bại thì ứng viên bị bác bỏ. Nếu dữ liệu bắt buộc thiếu thì trạng thái là `INSUFFICIENT DATA`.

Không xác nhận tại k+2, không backfill kết luận về k, không thay ResistancePrice bằng pivot High mới xuất hiện sau k.

## 6. Chồng lấn

Origin và Resolution là hai kênh riêng. Một thanh có thể vừa giải quyết sự kiện của thanh trước vừa khởi phát một sự kiện mới.

Khóa sự kiện tối thiểu:

`Symbol + OriginBarIndex + OriginDateTime + ResistancePivotConfirmBarIndex`

## 7. Mã trạng thái dự kiến

### Origin

- 0: `INSUFFICIENT DATA`
- 1: `NOT PRESENT`
- 2: `UPTHRUST/UTAD CANDIDATE`

`OriginKindCode`:

- 1: `UPTHRUST-LIKE`
- 2: `UTAD-LIKE`

### Resolution

- 0: `INSUFFICIENT DATA`
- 1: `NO PRIOR UPTHRUST/UTAD`
- 2: `UPTHRUST/UTAD REJECTED`
- 3: `UPTHRUST/UTAD CONFIRMED`

## 8. Các bất biến

- Chỉ dùng pivot High đã xác nhận trước k.
- Không dùng dữ liệu tương lai hoặc Zig/Peak/Trough nhìn trước.
- Không sửa Core, Candidate, Structure/Location, Confirmation, Supply Test hoặc Spring/Shakeout.
- Không coi `UTAD-LIKE` là xác nhận pha phân phối.
- Không thêm tín hiệu giao dịch.
- Thanh đang hình thành chỉ mang tính tạm thời.

## 9. Trạng thái phát triển

Theo quyết định của chủ dự án, kiểm thử native và khóa expected riêng được tạm hoãn cho đến khi hoàn thiện bộ chỉ báo. Các ngưỡng trên là ngưỡng phát triển v0.1 và phải được rà soát/khóa trước chiến dịch nghiệm thu cuối.