# Supply Test Event v1.0 — Hồ sơ triển khai để rà soát

**Trạng thái:** ĐÃ TRIỂN KHAI MÃ TRÊN NHÁNH RIÊNG; CHƯA NGHIỆM THU NATIVE, CHƯA HỢP NHẤT, CHƯA PHÁT HÀNH.

## 1. Nền và phạm vi

- Nền sau khi hợp nhất PR #9: `f45c9501ddc698fc3ac00552b360375b468ca865`.
- Nhánh triển khai: `event/supply-test-v1.0-implementation`.
- Tệp AFL mới: `afl/WyckoffVSA_Event_SupplyTest_v1.0.afl`.
- Đặc tả chuẩn: `docs/wyckoff-event-supply-test-v1.0-spec.md`.
- Mô hình tham chiếu khóa trước AFL: `tests/supply-test-v1.0/reference_model.py`.
- Fixture và expected đã tồn tại trước mã Event và không được sửa để làm triển khai đạt.

Chỉ thêm lớp Supply Test Event và hồ sơ triển khai này. Không sửa Core, Candidate, Structure/Location, Confirmation, đặc tả đã khóa, mô hình tham chiếu, fixture hoặc expected.

## 2. Các bất biến được triển khai

- `WE_ST_MaxDistanceATR = 0.50` là hằng số, không phải tham số tối ưu.
- Nguồn hỗ trợ duy nhất là `SL_PivotLowLatestPrior...` tại thanh khởi phát.
- S/M/L chỉ được chụp như bối cảnh nghiên cứu, không tham gia quyết định hỗ trợ.
- Origin yêu cầu No Supply Candidate code 2, dữ liệu giá hợp lệ, prior pivot Low hợp lệ và `PriorATRValid=1`.
- Ordinary Test chỉ chấp nhận `SupportPrice <= Low_k <= SupportPrice + 0.50*PriorATR_k`.
- Xuyên hỗ trợ tại k không tạo origin; xuyên tại k+1 làm prior origin bị bác bỏ nếu dữ liệu đánh giá hợp lệ.
- Resolution chỉ đọc origin của đúng thanh trước bằng `Ref(...,-1)`, nên không có xác nhận muộn ở k+2.
- Confirmation No Supply tại k+1 phải trỏ đúng OriginBarIndex và code/confirmed phải hợp đồng-hợp lệ.
- Origin và Resolution là hai kênh độc lập, cho phép một thanh vừa giải quyết sự kiện cũ vừa tạo origin mới.
- SupportPrice và tọa độ pivot được Ref từ origin, không thay bằng pivot mới ở thanh đánh giá.
- Không có Buy/Sell/Short/Cover, điểm số, xác suất, cảnh báo hoặc quản trị vốn.

## 3. Kiểm toán phạm vi Git hiện tại

So với nền `f45c9501ddc698fc3ac00552b360375b468ca865`, trước khi thêm hồ sơ này nhánh chỉ có một tệp mới là AFL Event, không có thay đổi upstream. Sau hồ sơ này diff dự kiến chỉ gồm AFL Event và tài liệu rà soát.

Mã AFL dùng một `#include_once <WyckoffVSA_Confirmation_v1.0.afl>` và kế thừa toàn bộ chuỗi upstream. Mọi biến mới dùng tiền tố `WE_ST_`.

## 4. Điều chưa được tuyên bố

Chưa chạy Verify Syntax trên AmiBroker 6.20.01. Chưa chạy fixture/expected qua AFL thật. Chưa có hồi quy toàn bộ cột upstream từ lượt native mới. Chưa kiểm thử append, causal prefix hoặc dữ liệu thị trường thực cho Event. Do đó tài liệu này không tuyên bố PASS nghiệm thu.

Bước tiếp theo là kiểm tra syntax/runtime trên AmiBroker, sau đó tạo bộ wrapper/đối chiếu để so AFL với expected đã khóa. Nếu phát hiện lỗi, chỉ sửa mã Event hoặc harness; không sửa expected để ép PASS. Sau khi bằng chứng đạt mới xem xét chuyển PR khỏi trạng thái nháp và hợp nhất.