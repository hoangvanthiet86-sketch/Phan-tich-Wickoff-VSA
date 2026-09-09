# Báo cáo nghiệm thu runtime cuối — Structure/Location Engine v1.0

Ngày lập: 2026-09-09  
Phạm vi: kiểm tra runtime và hồi quy cho Structure/Location Engine v1.0 trên AmiBroker 6.20.01.

## 1. Kết luận

`STRUCTURE_LOCATION_RUNTIME_ACCEPTANCE = PASS`

`READY_FOR_FINAL_SOURCE_AND_GIT_IDENTITY_AUDIT = YES`

`READY_FOR_AUTOMATIC_MERGE = NO`

Các bằng chứng runtime hiện có đã hoàn tất phạm vi kiểm thử đã đặc tả. Không cần chạy thêm AmiBroker nếu mã nguồn được đưa lên Git không thay đổi so với logic đã kiểm thử. Bất kỳ thay đổi nào vào mã đo lường sau thời điểm này đều phải được đánh giá tác động và chạy lại các phép thử liên quan.

## 2. Tổng hợp bằng chứng

| Nhóm kiểm tra | Phạm vi | Kết quả |
|---|---:|---|
| Ma trận ca kiểm soát | 63/63 ca, hoàn tất đến PV23 | PASS |
| Ma trận Pivot Validation | PV01–PV23 | PASS |
| Hồi quy Core/Candidate trên ACB | 270.930/270.930 giá trị thuộc 55 cột baseline | 0 sai khác |
| Mô hình tham chiếu Decimal độc lập trên ACB | 615.750 phép đối chiếu | 0 sai khác |
| Append dữ liệu thật | 130 thanh tiền tố → 150 thanh sau append | PASS |

Kiểm tra ACB sử dụng 4.926 dòng dữ liệu, 235 cột, giai đoạn 22/11/2006–07/09/2026, với cấu hình cửa sổ 20/60/120 và pivot trái/phải 3/3. Sai số quan sát ở dữ liệu xuất số chỉ thuộc lượng tử hóa định dạng: tối đa khoảng 0,000001 cho đại lượng cơ bản và khoảng 0,000106 điểm phần trăm cho tỷ lệ.

## 3. Kết quả phép thử native append

### Giai đoạn 1 — tiền tố

- Tệp: `1(20260909-032203).txt`
- Số dòng dữ liệu: 130
- Số cột: 241; tên cột duy nhất: 241
- `BarIndex`: 0–129
- `SL_NativeBarCount = 130`
- `SL_NativeStageCode = 1`
- `SL_NativeStage = PREFIX P=130`
- SHA-256: `f3b7559313780e58052157e8d92c100ff8e504c40f6450700c522e734a13356f`

### Giai đoạn 2 — sau append

- Tệp: `2(3).txt`
- Số dòng dữ liệu: 150
- Số cột: 241; tên cột duy nhất: 241
- `BarIndex`: 0–149
- `SL_NativeBarCount = 150`
- `SL_NativeStageCode = 2`
- `SL_NativeStage = APPENDED P+Q=150`
- SHA-256: `7878abd79b05baa7064e1d150a69e9560feb8e13a29a9488e3f049be7e66d365`

### Đối chiếu tiền tố

- Header hai lần chạy giống tuyệt đối.
- Loại trừ đúng ba cột metadata theo đặc tả: `SL_NativeBarCount`, `SL_NativeStageCode`, `SL_NativeStage`.
- 238 cột bất biến × 130 dòng = 30.940 ô được so sánh chuỗi chính xác.
- Sai khác ngoài metadata: 0.
- Khi so toàn bộ 241 cột, có đúng 390 sai khác dự kiến, tương ứng 130 dòng × 3 cột metadata.
- OHLCV nhập lại khớp fixture trong dung sai xuất số đã phê duyệt; sai số round-trip lớn nhất khoảng `3.00000000664e-06`.

### Sự kiện mới sau append

| Loại | Dòng xác nhận | Extreme index | Giá | Lag | Mã/trạng thái |
|---|---:|---:|---:|---:|---|
| Pivot high | 131 | 128 | 120 | 3 | `1 / 2 / CONFIRMED PIVOT` |
| Pivot low | 132 | 129 | 80 | 3 | xác nhận hợp lệ |

Không có payload của hai sự kiện mới bị ghi ngược vào 130 thanh tiền tố. Kết quả bộ khẳng định: `SL_NATIVE_APPEND_FULL_ASSERTIONS PASS`.

## 4. Phạm vi kết luận

Kết quả này chứng minh mã đã vượt qua tập kiểm thử hữu hạn đã đặc tả, gồm biên so sánh, xác nhận pivot, tính nhân quả/no-lookahead, hồi quy và append. Kết quả không phải tuyên bố rằng mọi trạng thái thị trường có thể có đã được chứng minh hình thức.

## 5. Cổng phát hành còn lại

Không còn bước chạy AmiBroker bắt buộc đối với đúng mã đã kiểm thử. Các bước còn lại là kiểm soát nguồn và Git:

1. Xác định chính xác tệp nguồn Structure/Location Engine sẽ phát hành.
2. Kiểm tra toàn bộ diff và bảo đảm chỉ có mã/tài liệu đúng phạm vi.
3. Tính SHA-256 và Git blob ID của từng tệp đích; đọc lại từ GitHub để đối chiếu.
4. Tạo commit trên nhánh tính năng/sửa lỗi được chỉ định.
5. Tạo pull request vào nhánh đích để chủ dự án duyệt.
6. Không tự động hợp nhất, không gắn thẻ và không tạo release khi chưa có phê duyệt riêng.

## 6. Điều kiện bảo toàn nghiệm thu

- Không thay đổi phương pháp hay công thức đo lường ngoài phạm vi đặc tả.
- Không thêm tín hiệu giao dịch.
- Không chỉnh sửa trực tiếp `main` trong bước chuẩn bị.
- Mọi mã nguồn đưa vào pull request phải được nhận diện và đối chiếu với đúng phiên bản đã kiểm thử.
- Nếu diff cuối có thay đổi logic, trạng thái PASS này phải được xem xét lại trước khi hợp nhất.
