# Confirmation Engine v1.0 — Hồ sơ triển khai và ngoại lệ

**Ngày:** 10/09/2026. **Trạng thái:** Bản triển khai để rà soát; chưa nghiệm thu toàn phần, chưa phê duyệt phát hành.

## 1. Nguồn và phạm vi

- Nền tài liệu đã hợp nhất: `b12d7a1bf287cdf9a60571f64d729ece928b78ae` (PR #7).
- Nền ba lớp đã phát hành: `7c2b8cfb4d729c5b1b631f3860e43a46fc2f6f23`.
- AFL triển khai: `afl/WyckoffVSA_Confirmation_v1.0.afl`.
- SHA-256 của AFL đã kiểm thử: `72f29ad5fb8fb121f4e04ad59ec29c52a8e94025d0ccd66aa9d9175d18683da3`.
- Git blob tương ứng: `48061c9dd763814dc31f27e1dcf19ed61065aee5`.
- Chỉ thêm Confirmation và hồ sơ triển khai. Không sửa Core, Candidate, Structure/Location, đặc tả hay kế hoạch kiểm thử đã khóa.

## 2. Bằng chứng hiện có

Hồ sơ kiểm toán ngày 10/09/2026 phân loại 34 ca có bằng chứng hỗ trợ, 11 ca chưa đầy đủ và một ca được miễn; đây không phải số ca đã ký nghiệm thu. Các lượt đã thực hiện gồm HCM, kiểm soát cô lập, nhân quả P/A/B, nhập nối tiếp P+Q và ba bộ dữ liệu bổ sung. Bộ bổ sung có 260.857 phép đối chiếu, không sai khác sau khi sửa công cụ kiểm toán; hồi quy HCM có 1.010.178 ô upstream nguyên văn không sai khác.

Khóa nguồn Windows đã khớp 14/14 tệp, gồm 11 tệp nền và ba AFL cài trong Include. Confirmation cài trên máy trùng SHA-256 bản đã thử. Mã nguồn cục bộ đã được kiểm toán tĩnh: 33 tham chiếu Ref đều -1, không phát hiện phép gán ngoài CE_ hoặc lời gọi giao dịch bị cấm. Không có lỗi thuật toán Confirmation mới được chứng minh trong các lượt đã đối chiếu. Không coi việc kiểm toán tĩnh là thay thế trình biên dịch AFL.

Bản đầy đủ của ma trận, biên bản và bằng chứng gốc được lưu trong gói `CE_Final_Acceptance_Audit_2026-09-10.zip` của cuộc trò chuyện dự án. Không đưa các bản xuất thị trường hoặc dữ liệu cá nhân lên repository.

## 3. Quyết định bỏ qua kiểm thử

Người dùng đã yêu cầu bỏ qua CA07 và sau đó yêu cầu tiếp tục triển khai trên nhánh GitHub, không thực hiện những ca còn thiếu. Quyết định này chỉ cho phép dừng các lượt thử còn lại để chuẩn bị bản triển khai. Nó không có nghĩa các ca chưa chạy đã đạt, không xác nhận hệ thống đáp ứng nguyên vẹn tiêu chí 46/46 và không tự sửa tài liệu chuẩn.

Các ca còn thiếu theo hồ sơ cuối:

| Nhóm | Ca | Rủi ro hoặc phần chưa chứng minh |
|---|---|---|
| Dữ liệu lỗi | CR12, CR13 | Biến thể Close không hữu hạn. |
| Hợp đồng mã | CR18 | Mã phân số 1,5 chưa chạy lại sau khi sửa định dạng kiểm toán; các cặp lỗi khác có bằng chứng cô lập. |
| Bối cảnh | CX03, CX04, CX08, CX10 | Các tổ hợp zero-width, vùng lỗi độc lập, pivot mới xác nhận ở k+1 và context hoàn toàn lỗi chưa đủ bằng chứng chuỗi đầy đủ. |
| Nhân quả | CA06 | Close lỗi tại k+1 rồi hợp lệ ở k+2 chưa có bằng chứng chuỗi đầy đủ; đã có bằng chứng cô lập. |
| Tích hợp | RG02, RG06, RG07 | Diff ứng viên triển khai, hồ sơ Verify/phiên bản/tham số và Filter/biểu đồ chưa được khóa đầy đủ tại thời điểm kiểm toán. RG02 được thực hiện lại sau khi đưa mã lên nhánh. |
| Thanh đang hình thành | CA07 | Người dùng miễn kiểm thử thực; mô phỏng lịch sử không thay thế dữ liệu trực tiếp. |

Bốn tình huống ranh giới 100 ± 0,000001 được miễn theo quyết định trước. Không thay đổi quy tắc Close nghiêm ngặt, không thêm epsilon hoặc làm tròn. Quyết định bỏ qua lượt mã phân số không được hiểu là phê duyệt toàn bộ các biến thể lỗi chưa kiểm tra.

## 4. Giới hạn sử dụng và phê duyệt

Đây là lớp xác nhận phản ứng giá cơ bản, không phải sự kiện Wyckoff hoàn chỉnh, tín hiệu mua/bán, điểm số hay lời khuyên giao dịch. Không quảng bá là đã nghiệm thu thời gian thực, không dùng như hệ thống đặt lệnh tự động và không tự thêm cảnh báo hoặc điều kiện giao dịch.

Bản triển khai có thể được rà soát trên nhánh riêng. Không hợp nhất vào main, tạo thẻ hoặc phát hành cho đến khi người có thẩm quyền phê duyệt rõ ràng phạm vi nghiệm thu có ngoại lệ. Nếu muốn phát hành với các ngoại lệ, cần tài liệu quyết định riêng xác định tiêu chí thay thế, rủi ro còn lại và phạm vi sử dụng; không sửa âm thầm đặc tả v1.0.

## 5. Kiểm tra trước khi hợp nhất

Đối chiếu Git blob của AFL với bản đã kiểm thử; xác minh toàn bộ 11 blob nền không đổi; kiểm tra diff chỉ gồm tệp được phép. Giữ nguyên bằng chứng native đã đạt, không chạy lại toàn bộ nếu nguồn không đổi. Những kiểm tra tích hợp còn thiếu chỉ được ghi đạt khi thực sự có bằng chứng; nếu tiếp tục miễn thì phải được quyết định và ghi nhận riêng.
