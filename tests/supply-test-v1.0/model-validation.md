# Supply Test v1.0 — Xác nhận mô hình/fixture trước AFL

**Ngày:** 10/09/2026. **Trạng thái:** ĐẠT trong phạm vi 20 fixture ban đầu; chưa có AFL Event.

Mô hình tham chiếu độc lập `reference_model.py` đã được chạy trên 20 fixture đã khóa trước khi lập trình AFL. Các bất biến tối thiểu được kiểm tra trực tiếp:

- Low đúng SupportPrice → OriginCode=2.
- Low đúng SupportPrice + 0,50*PriorATR → OriginCode=2.
- Low cao hơn biên 0,50 ATR → OriginCode=1.
- Low xuyên dưới SupportPrice → OriginCode=1, reason=5.
- CE No Supply code3 + giữ hỗ trợ → ResolutionCode=3.
- CE phản ứng thất bại → ResolutionCode=2.
- CE code3 nhưng xuyên hỗ trợ → ResolutionCode=2, reason=2.
- Cả phản ứng và hỗ trợ cùng thất bại → reason=3.
- Candidate coordinate sai → ResolutionCode=0.
- k+2 thuận lợi sau khi k+1 thất bại → không xác nhận muộn.
- k+1 vừa xác nhận Event cũ vừa khởi phát Event mới → hai kênh độc lập.
- pivot mới tại k+1 → Resolution của Event cũ vẫn giữ SupportPrice đã chụp tại k.

Không có AFL Event tại thời điểm sinh expected. Expected không lấy từ AmiBroker hoặc từ mã Event tương lai.

SHA-256 cục bộ trước upload:

- reference model: `447eb6a28fec869179951b330952b820818d292f610d645e3b197fc4242e146e`
- fixtures: `7df333444f69a7d347b575e77c4435089aac17f0468b58cf9879ba9d1f74e9c6`
- expected: `89e455285f00ec8472d6c6dd5753d0f64f4a9fed8cf6d43a8d2860d553508ccd`

Tài liệu, mô hình, fixture và expected hiện đủ điều kiện để trình hợp nhất. Sau khi hợp nhất mới tạo nhánh AFL Event riêng; artefact expected không được sửa để ép kết quả triển khai đạt.