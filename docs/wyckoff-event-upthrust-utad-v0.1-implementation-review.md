# Upthrust / UTAD Event v0.1 — Hồ sơ triển khai phát triển

**Trạng thái:** CHƯA KIỂM THỬ NATIVE. Không được coi là bản nghiệm thu hoặc phát hành.

## 1. Nền xếp chồng

- Nhánh cha: `event/spring-shakeout-v0.1-development`.
- Head cha tại thời điểm tạo nhánh: `24c5dbba1872099cdd7e38b99a3d82c31c3ff7a5`.
- Supply Test và Spring/Shakeout vẫn ở trạng thái phát triển chưa nghiệm thu.
- Không sửa Core, Candidate, Structure/Location, Confirmation, Supply Test hay Spring/Shakeout.

## 2. Tệp mới

- `docs/wyckoff-event-upthrust-utad-v0.1-spec.md`
- `afl/WyckoffVSA_Event_UpthrustUTAD_v0.1.afl`
- `docs/wyckoff-event-upthrust-utad-v0.1-implementation-review.md`

## 3. Logic triển khai

Mô-đun đọc pivot High đã xác nhận trước thanh hiện tại làm kháng cự. Ứng viên yêu cầu High xuyên kháng cự, Close quay lại dưới/đúng kháng cự trong cùng thanh, ClosePosition không cao hơn 0,50 và độ xuyên không quá 1,00 PriorATR.

Phân loại `UPTHRUST-LIKE` và `UTAD-LIKE` chỉ nhằm chia hình thái phát triển. `UTAD-LIKE` không phải kết luận pha phân phối vì chưa có Phase Engine.

Resolution chỉ ở k+1: High không vượt lại kháng cự đã khóa và Close thấp hơn Close của origin. Không xác nhận muộn, không backfill.

## 4. Biên an toàn

- Không Buy/Sell/Short/Cover.
- Không sửa Filter upstream.
- Không dùng pivot High xác nhận tại chính k làm kháng cự prior.
- Không thay kháng cự của sự kiện bằng pivot mới tại k+1.
- Không dùng S/M/L làm fallback cho kháng cự.
- Không gán `UTAD-LIKE` thành UTAD hoàn chỉnh trước khi có bối cảnh pha.

## 5. Việc chưa thực hiện

Theo quyết định của chủ dự án, hiện tạm hoãn:

- Verify Syntax trên AmiBroker 6.20.01;
- fixture/expected độc lập riêng cho Upthrust/UTAD;
- kiểm thử ranh giới các ngưỡng;
- hồi quy upstream;
- kiểm thử nhân quả, nối dữ liệu và sửa nguồn;
- nghiệm thu release.

Các ngưỡng v0.1 có thể được rà soát khi khóa toàn bộ bộ chỉ báo, nhưng mọi thay đổi sau đó phải được ghi rõ và không được gọi là kết quả của kiểm thử hiện tại.

## 6. Bước phát triển sau

Sau Upthrust/UTAD, lớp sự kiện nên chuyển sang SOS/LPS để bắt đầu mô hình hóa sức mạnh sau phá vùng và kiểm tra lại, rồi mới phát triển nhóm Effort/Result như Stopping Volume, Climactic Volume và Absorption.