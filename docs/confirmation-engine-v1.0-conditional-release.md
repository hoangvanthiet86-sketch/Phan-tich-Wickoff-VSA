# Confirmation Engine v1.0 — Hồ sơ phát hành có điều kiện

**Ngày:** 10/09/2026. **Trạng thái:** Confirmation đã hợp nhất vào `main`; hồ sơ này ghi phạm vi phát hành có điều kiện và chuyển tiếp sang lớp Event. Chưa tạo thẻ hoặc GitHub Release cho Confirmation.

## 1. Định danh

- Commit đã hợp nhất: `c31e61fccdd7867f417bc036c3b9705c0256dc53` (PR #8).
- AFL: `afl/WyckoffVSA_Confirmation_v1.0.afl`.
- Git blob: `48061c9dd763814dc31f27e1dcf19ed61065aee5`.
- SHA-256 bản đã kiểm thử: `72f29ad5fb8fb121f4e04ad59ec29c52a8e94025d0ccd66aa9d9175d18683da3`.
- Không sửa Core, Candidate, Structure/Location, đặc tả hoặc kế hoạch kiểm thử đã khóa.

## 2. Bằng chứng và ngoại lệ

Hồ sơ kiểm toán cuối phân loại 34 ca có bằng chứng hỗ trợ, 11 ca chưa đầy đủ và một ca được miễn; đây không phải tuyên bố 46/46 PASS. Các lượt HCM, kiểm soát cô lập, nhân quả P/A/B, nhập nối tiếp P+Q và ba bộ bổ sung đã được giữ làm bằng chứng. Bộ bổ sung có 260.857 phép đối chiếu, không sai khác sau khi sửa công cụ kiểm toán; khóa nguồn Windows khớp 14/14.

Người dùng đã phê duyệt hợp nhất với các ngoại lệ đang ghi nhận. CA07 được miễn; các ca còn thiếu và lượt mã phân số bị bỏ qua không tự động thành PASS. Không quảng bá Confirmation là đã nghiệm thu realtime đầy đủ.

## 3. Giới hạn sử dụng

Confirmation v1.0 chỉ xác nhận phản ứng Close cơ bản ở thanh kế tiếp của No Demand/No Supply Candidate. Nó không phải sự kiện Wyckoff hoàn chỉnh, tín hiệu mua/bán, xác suất hay hệ thống giao dịch. Thanh cuối chưa hoàn tất là provisional. Không thêm epsilon, không xác nhận muộn và không dùng context để sửa mã phản ứng đã khóa.

## 4. Trạng thái phát hành

Tên `confirmation-v1.0.0-rc.1` chỉ là đề xuất nếu sau này cần một bản phát hành trước chính thức. Hiện chưa tạo tag/Release vì tiêu chí nghiệm thu nguyên bản chưa đạt đầy đủ và người dùng đã chọn tiếp tục phát triển với ngoại lệ thay vì chạy hết các ca còn thiếu.

## 5. Chuyển sang Wyckoff Event

Chủ dự án đã chấp thuận hướng phát triển Event đầu tiên: **Test cung thông thường tại hỗ trợ hợp lệ**. Đặc tả và kế hoạch kiểm thử đã được khóa trên nhánh tài liệu hiện tại:

- `docs/wyckoff-event-supply-test-v1.0-spec.md`;
- `tests/wyckoff-event-supply-test-v1.0-test-plan.md`.

Supply Test v1.0 dùng pivot Low đã xác nhận trước thanh khởi phát, khoảng cách tối đa 0,50 PriorATR, No Supply Candidate tại k và Confirmation No Supply tại k+1; xuyên hỗ trợ thuộc ngoài phạm vi ordinary Test và không tự gán Spring/Shakeout.

Bước tiếp theo là tạo mô hình tham chiếu độc lập và fixture/expected trước khi viết AFL Event. Không được dùng kết quả AFL tương lai để sửa expected hoặc hiệu chỉnh ngưỡng 0,50 ATR.