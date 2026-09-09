# Confirmation Engine v1.0 — Hồ sơ chuẩn bị phát hành có điều kiện

**Ngày:** 10/09/2026. **Trạng thái:** DỰ THẢO ĐỂ PHÊ DUYỆT. Chưa tạo thẻ, chưa công bố GitHub Release và chưa nghiệm thu toàn phần.

## 1. Định danh bất biến

- Repository: `hoangvanthiet86-sketch/Phan-tich-Wickoff-VSA`.
- PR triển khai: #8, đã hợp nhất.
- Commit hợp nhất: `c31e61fccdd7867f417bc036c3b9705c0256dc53`.
- AFL: `afl/WyckoffVSA_Confirmation_v1.0.afl`.
- Git blob: `48061c9dd763814dc31f27e1dcf19ed61065aee5`.
- SHA-256: `72f29ad5fb8fb121f4e04ad59ec29c52a8e94025d0ccd66aa9d9175d18683da3`.
- Nền ba lớp đã phát hành: `7c2b8cfb4d729c5b1b631f3860e43a46fc2f6f23`.
- Nền tài liệu Confirmation: `b12d7a1bf287cdf9a60571f64d729ece928b78ae`.
- Môi trường đích: AmiBroker 6.20.01, tối thiểu 6.20+.

GitHub đã xác nhận commit hợp nhất là đầu `main` và blob AFL đúng định danh trên. Không sử dụng `main` di động làm định danh phát hành. Mọi thẻ tương lai phải trỏ chính xác commit trên hoặc một commit hồ sơ được phê duyệt rõ ràng; không tự tạo thẻ ổn định mang ý nghĩa 46/46 PASS.

## 2. Nội dung và giới hạn

Confirmation chỉ đánh giá ứng viên No Demand/No Supply tại thanh kế tiếp theo giá đóng cửa nghiêm ngặt và chụp bối cảnh Structure/Location tại thanh ứng viên. Không phải sự kiện Wyckoff hoàn chỉnh, không phải tín hiệu mua/bán, không có điểm số, đặt lệnh, kiểm thử lợi nhuận hay cảnh báo. Không thay đổi Core, Candidate, Structure/Location hoặc các tài liệu chuẩn đã khóa.

Chỉ sử dụng có giám sát để nghiên cứu và kiểm tra trên dữ liệu đã hoàn tất. Không quảng bá là đã nghiệm thu thời gian thực, không dùng làm hệ thống giao dịch tự động. Kết quả của thanh đang hình thành là tạm thời; người dùng phải kiểm tra trạng thái nguồn và không coi xác nhận cơ bản là bằng chứng cung/cầu đã thắng hoàn toàn.

## 3. Bằng chứng và ngoại lệ

Hồ sơ kiểm toán ngày 10/09/2026 phân loại 34 ca có bằng chứng hỗ trợ, 11 ca chưa đầy đủ và một ca được miễn. Đây không phải 34 ca đã ký PASS. Các lượt HCM, cô lập, nhân quả P/A/B, nhập nối tiếp P+Q và ba bộ dữ liệu bổ sung được tái sử dụng. Bộ bổ sung có 260.857 phép đối chiếu không sai khác sau khi sửa công cụ kiểm toán; hồi quy HCM có 1.010.178 ô thượng nguồn không sai khác. Khóa nguồn Windows đạt 14/14; AFL cài trùng SHA-256 trên. Không có lỗi thuật toán mới được chứng minh trong phạm vi đã kiểm tra.

Các ca chưa đầy đủ: `CR12`, `CR13`, `CR18`, `CX03`, `CX04`, `CX08`, `CX10`, `CA06`, `RG02`, `RG06`, `RG07` theo ma trận kiểm toán trước triển khai. RG02 đã có thêm bằng chứng sau khi đưa mã lên nhánh: PR #8 chỉ thêm AFL và tài liệu, không sửa ba lớp nền; không vì vậy tự thay đổi số liệu của biên bản cũ. RG06/RG07 và các tình huống chưa đủ bằng chứng vẫn phải được ghi nhận trung thực.

Người dùng đã yêu cầu bỏ qua các ca còn thiếu và chấp thuận hợp nhất PR #8. CA07 được miễn kiểm thử thực; bốn tình huống ranh giới 100 ± 0,000001 được miễn; lượt mã phân số 1,5 được bỏ qua sau khi xác định lỗi định dạng kiểm toán và chưa chạy lại. Các quyết định này không biến ca chưa đạt thành PASS. Không thay đổi so sánh Close nghiêm ngặt, không thêm epsilon và không sửa expected để hợp thức hóa ngoại lệ.

Nguồn bằng chứng: `docs/confirmation-engine-v1.0-implementation-review.md`, đặc tả và kế hoạch đã khóa; biên bản và ma trận đầy đủ nằm trong gói `CE_Final_Acceptance_Audit_2026-09-10.zip` của cuộc trò chuyện dự án. Không đưa bản xuất thị trường hoặc dữ liệu cá nhân lên repository.

## 4. Quyết định cần phê duyệt trước khi công bố

Việc hợp nhất mã vào `main` đã được người dùng phê duyệt. Việc đó không đồng nghĩa phê duyệt phát hành ổn định. Nếu tiếp tục phát hành với ngoại lệ, người có thẩm quyền cần xác nhận rõ: phạm vi sử dụng có giám sát; danh sách ngoại lệ và rủi ro còn lại; tiêu chí nghiệm thu thay thế hoặc trạng thái phát hành trước chính thức; định danh commit và thẻ; cách xử lý các ca chưa đầy đủ về sau. Tài liệu chuẩn 46/46 không được sửa âm thầm.

Đề xuất tên nếu được phê duyệt phát hành trước chính thức: `confirmation-v1.0.0-rc.1`, trỏ commit `c31e61fccdd7867f417bc036c3b9705c0256dc53`. Đây chỉ là tên đề xuất, chưa tồn tại và chưa được phê duyệt. Không dùng `confirmation-v1.0.0` như một thẻ ổn định khi các tiêu chí nguyên bản chưa được giải quyết.

## 5. Dự thảo nội dung GitHub Release

**Tên:** Wyckoff VSA Confirmation Engine v1.0.0-rc.1 — Bản trước chính thức có ngoại lệ

Bổ sung lớp xác nhận phản ứng giá cơ bản cho No Demand và No Supply, kế thừa Core, Candidate và Structure/Location đã khóa. Chỉ xác nhận tại thanh kế tiếp bằng Close nghiêm ngặt; giữ tọa độ và bối cảnh của thanh ứng viên. Không có giao dịch, điểm số hoặc sự kiện Wyckoff.

Bằng chứng hiện có hỗ trợ 34/46 ca; 11 ca chưa đầy đủ và CA07 được miễn theo hồ sơ trước triển khai. Các ngoại lệ ranh giới và mã phân số được ghi riêng. Không tuyên bố 46/46 PASS hoặc đã kiểm thử đầy đủ thanh thời gian thực. Chỉ dùng nghiên cứu có giám sát trên dữ liệu đã hoàn tất, không dùng đặt lệnh tự động. Xem hồ sơ triển khai để biết danh sách giới hạn và bằng chứng.

Commit: `c31e61fccdd7867f417bc036c3b9705c0256dc53`. AFL blob: `48061c9dd763814dc31f27e1dcf19ed61065aee5`. Yêu cầu AmiBroker 6.20.01 và ba lớp nền đã phát hành.

**Chưa công bố:** nội dung trên là dự thảo, không phải Release đã tạo.
