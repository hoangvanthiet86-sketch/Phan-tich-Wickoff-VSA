# Spring / Shakeout Event v1.0 — Hồ sơ triển khai phát triển

**Trạng thái:** CHƯA KIỂM THỬ / CHƯA NGHIỆM THU / CHƯA PHÁT HÀNH.

## 1. Nền kế thừa

Nhánh này được tạo trực tiếp từ đầu nhánh `event/supply-test-v1.0-implementation`, vì vậy kế thừa Supply Test chưa nghiệm thu và toàn bộ bốn lớp nền. Không hợp nhất Supply Test hoặc Spring/Shakeout vào `main` trong giai đoạn phát triển bộ chỉ báo.

## 2. Tệp mới

- `docs/wyckoff-event-spring-shakeout-v1.0-spec.md`
- `afl/WyckoffVSA_Event_SpringShakeout_v1.0.afl`
- hồ sơ này.

Không sửa Core, Candidate, Structure/Location, Confirmation hoặc Supply Test.

## 3. Logic triển khai

Nguồn hỗ trợ là `SL_PivotLowLatestPrior...`. Một origin yêu cầu Low xuyên dưới hỗ trợ, Close thu hồi trở lại hỗ trợ và CloseState thuộc Upper/Strong. Spring dùng RVOL và RSpread từ các dải thấp đến bình thường; Shakeout dùng ít nhất một chiều High/Wide trở lên. Không đặt trần độ xuyên trong v1.0; `PenetrationATR` được xuất để lớp sau đánh giá.

Xác nhận chỉ tại k+1. Close phải cao hơn OriginClose và Low không được xuyên lại SupportPrice. Origin/Resolution độc lập nên ứng viên chồng lấn được giữ. Không có xác nhận muộn hoặc backfill.

## 4. Ranh giới với Supply Test

- Supply Test thông thường: `Low >= SupportPrice` tại origin.
- Spring/Shakeout: `Low < SupportPrice` và `Close >= SupportPrice` tại origin.

Hai lớp vì vậy được thiết kế để không cùng nhận một thanh là origin hợp lệ theo cùng một support snapshot.

## 5. Kiểm thử tạm hoãn

Theo yêu cầu của chủ dự án, chưa tạo gói AmiBroker, chưa Verify Syntax, chưa đối chiếu fixture, chưa chạy causal/append/realtime và chưa hồi quy toàn bộ. Các bước đó sẽ được gom vào chiến dịch nghiệm thu sau khi hoàn thiện toàn bộ bộ chỉ báo.

Cho đến lúc đó, PR chỉ dùng làm mốc phát triển và không được đổi trạng thái thành đã nghiệm thu.
