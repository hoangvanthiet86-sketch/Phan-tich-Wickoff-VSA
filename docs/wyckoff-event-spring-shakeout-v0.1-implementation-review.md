# Spring / Shakeout Event v0.1 — Hồ sơ triển khai phát triển

**Trạng thái:** UNTESTED DEVELOPMENT. Kiểm thử và nghiệm thu được chủ dự án chủ động hoãn để ưu tiên hoàn thiện toàn bộ bộ chỉ báo trước.

## 1. Nền phát triển

Nhánh này được tạo từ đầu PR #10 (`event/supply-test-v1.0-implementation`) tại commit `9082acf8939c01622208207d2aebdfb07319876e`. Vì vậy đây là nhánh xếp chồng: nó kế thừa Supply Test chưa nghiệm thu và bổ sung Spring / Shakeout. Không được hiểu là hai mô-đun đã sẵn sàng merge vào main.

## 2. Tệp mới

- `docs/wyckoff-event-spring-shakeout-v0.1-spec.md`
- `afl/WyckoffVSA_Event_SpringShakeout_v0.1.afl`
- tài liệu hồ sơ này.

Không sửa Core, Candidate, Structure/Location, Confirmation, Supply Test, expected hoặc fixture trước đó.

## 3. Logic phát triển

Mô-đun dùng pivot Low đã xác nhận trước làm support. Origin yêu cầu Low xuyên support, Close thu hồi support ngay trên cùng thanh, ClosePosition >= 0.50 và độ xuyên không quá 1.00 PriorATR. Phân loại `SPRING-LIKE` / `SHAKEOUT-LIKE` dựa trên độ xuyên và tổ hợp RSpread/RVOL. Resolution duy nhất ở k+1, yêu cầu Low giữ support và Close tăng so với Close của origin.

Các ngưỡng v0.1 chưa phải ngưỡng nghiệm thu cuối. Chúng được ghi cố định để phát triển chuỗi mô-đun, nhưng sẽ phải được rà soát và khóa trước khi tạo expected chính thức trong chiến dịch kiểm thử tổng thể.

## 4. Giới hạn

- Chưa chạy Verify Syntax trên AmiBroker.
- Chưa có fixture/expected riêng cho Spring / Shakeout.
- Chưa đối chiếu với dữ liệu native.
- Chưa kiểm tra hồi quy, nhân quả, append hoặc thanh đang hình thành.
- Không có Buy/Sell/Short/Cover, không có quản trị vốn hoặc cảnh báo giao dịch theo chủ đích thiết kế.

## 5. Quy tắc phát triển tiếp

PR này phải giữ dạng draft và base trên nhánh Supply Test để tránh đưa mã chưa kiểm thử vào main. Các Event tiếp theo có thể tiếp tục theo mô hình nhánh xếp chồng. Khi bộ chỉ báo hoàn chỉnh, sẽ quay lại khóa ngưỡng, expected, kiểm thử từng lớp từ dưới lên rồi mới lần lượt hợp nhất.
