# Wyckoff Event — Đặc tả dự thảo Test cung v1.0

**Trạng thái:** DỰ THẢO ĐỂ PHÊ DUYỆT. Chưa khóa công thức, chưa triển khai AFL, chưa nghiệm thu hoặc phát hành Event. Tài liệu này phát triển đề cương v0.1; không thay thế đề cương hoặc các hợp đồng đã phát hành.

## 1. Phạm vi và nguồn chuẩn

Lớp mới chỉ nghiên cứu giả thuyết kiểm tra cung tại vùng hỗ trợ. Test cung, No Supply, Spring và Shakeout là các khái niệm khác nhau. Bản đầu tiên không nhận diện Spring, Shakeout, SOS, LPS, pha thị trường hoặc ý định của tổ chức. Không có tín hiệu mua/bán, điểm số, xác suất, cảnh báo hoặc quản trị vốn.

Nền triển khai là commit `c31e61fccdd7867f417bc036c3b9705c0256dc53`; Confirmation AFL blob `48061c9dd763814dc31f27e1dcf19ed61065aee5`, SHA-256 `72f29ad5fb8fb121f4e04ad59ec29c52a8e94025d0ccd66aa9d9175d18683da3`. Giữ nguyên Core, Candidate, Structure/Location và Confirmation. Kế thừa các giới hạn nghiệm thu đã ghi trong hồ sơ Confirmation; không coi các ca được miễn là PASS.

Nguồn tham chiếu: `docs/wyckoff-event-engine-v0.1-scope.md`, `docs/confirmation-engine-v1.0-spec.md`, `docs/structure-location-engine-v1.0-spec.md`, `docs/vsa-candidate-engine-v1.0-spec.md`. Tất cả quy tắc mới bên dưới là đề xuất, chưa phải quy tắc đã khóa.

## 2. Ý nghĩa của Test cung

Giả thuyết Test cung là giá quay về kiểm tra một vùng hỗ trợ đã được xác định trước, xuất hiện dấu hiệu cung chủ động suy giảm và sau đó có phản ứng cầu phù hợp. Một No Supply được xác nhận chỉ chứng minh phản ứng Close một thanh theo hợp đồng Confirmation; nó không tự chứng minh Test thành công. Vị trí, khả năng giữ hỗ trợ, thời điểm vùng được biết và phản ứng tiếp theo phải được đánh giá riêng.

Bản đầu tiên dự kiến chỉ nhận diện Test thông thường. Một cú xuyên hỗ trợ rồi thu hồi có thể là giả thuyết Spring/Shakeout và không được tự gán Test cung thành công. Việc hỗ trợ bị phá không đủ để kết luận phân phối hoặc xu hướng giảm.

## 3. Kiến trúc và dữ liệu

Luồng: Core → Candidate → Structure/Location → Confirmation → Supply Test Event. Tệp dự kiến `afl/WyckoffVSA_Event_SupplyTest_v1.0.afl`, dùng include_once của Confirmation. Mọi tên mới dùng `WE_`; không ghi đè hoặc sao chép công thức upstream.

Đầu vào tối thiểu: mã ứng viên No Supply và validity; trạng thái Confirmation No Supply, opportunity, mã phản ứng, tọa độ và Close ứng viên/đánh giá; snapshot S/M/L và pivot của ứng viên; các trường Structure/Location có thời điểm khả dụng; OHLCV và validity cần thiết của thanh khởi phát/đánh giá; tham số cấu hình; mã chứng khoán, khung thời gian, nguồn/phiên bản dữ liệu và chính sách điều chỉnh. Không sử dụng một snapshot chỉ vì có giá trị số nếu validity không hợp lệ.

Vùng S/M/L là cửa sổ trượt prior-only, không phải vùng hỗ trợ có vòng đời. Vì vậy không được mặc định lấy Lower hiện tại làm hỗ trợ cố định của một Test đã bắt đầu. Mọi vùng được chọn phải có tọa độ khả dụng, biên giá và quy tắc duy trì/hết hiệu lực riêng. Pivot xác nhận muộn chỉ khả dụng từ thanh xác nhận của nó, không phải thanh cực trị.

## 4. Các quyết định định nghĩa cần khóa

| Mã | Nội dung | Đề xuất để thảo luận |
|---|---|---|
| D01 | Nguồn hỗ trợ | Một vùng S/M/L đã READY và/hoặc pivot Low đã xác nhận. Phải chọn nguồn cụ thể, quy tắc ưu tiên và cách khóa biên; không tự chọn vùng thuận lợi nhất. |
| D02 | Hỗ trợ hợp lệ | Có nguồn gốc thời gian, giá trị hữu hạn, validity hợp lệ và điều kiện tồn tại trước khởi phát. Cần định nghĩa kiểm tra lại vùng, vòng đời, tuổi tối đa và xử lý vùng trượt. |
| D03 | Tiếp cận vùng | Xác định bằng giá/biên và khoảng cách đã được định nghĩa trước. Cần phê duyệt ngưỡng, đơn vị và quy tắc chạm/xuyên; không tự mượn tỷ lệ từ Core. |
| D04 | Khởi phát | Đề xuất dùng No Supply Candidate cơ bản tại k kết hợp điều kiện vị trí. Không đồng nhất mọi thanh giảm khối lượng thấp với Test. |
| D05 | Phản ứng | Đề xuất yêu cầu Confirmation No Supply code3 tại k+1 và điều kiện giữ hỗ trợ riêng. Cần quyết định có cho phép xác nhận nhiều thanh hay không; không sửa quy tắc một thanh của Confirmation. |
| D06 | Xuyên hỗ trợ | Quy định khi nào vẫn là Test thông thường, khi nào phải chuyển thành giả thuyết khác hoặc bác bỏ. Không gọi mọi cú xuyên là Spring. |
| D07 | Bác bỏ/hết hiệu lực | Định nghĩa rõ phá vùng, phản ứng thất bại, dữ liệu lỗi, timeout và điều kiện kết thúc; không coi thiếu dữ liệu là bằng chứng cung mạnh. |
| D08 | Chồng lấn | Cho phép nhiều giả thuyết có khóa riêng hay chỉ một Test đang theo dõi trên một nguồn hỗ trợ; không âm thầm chọn ứng viên tốt nhất. |
| D09 | Thời gian | Chỉ công bố kết quả khi đủ dữ liệu; không backfill; chốt chính sách thanh hoàn tất và dữ liệu nguồn sửa đổi. |
| D10 | Phạm vi vận hành | Nghiên cứu trên dữ liệu Daily đã hoàn tất, một mã một khung thời gian, không giao dịch tự động. Mở rộng thời gian thực cần nghiệm thu riêng. |

Không có lựa chọn nào trong bảng được xem là đã phê duyệt chỉ vì tài liệu được đưa lên GitHub. Cần quyết định rõ các câu hỏi còn mở trước khi đóng băng đặc tả.

## 5. Hợp đồng trạng thái dự kiến

Đề xuất các trạng thái độc lập: dữ liệu không đủ, không có Test, ứng viên đang theo dõi, Test được xác nhận, giả thuyết bị bác bỏ, hết hiệu lực. Mã số, miền giá trị, độ ưu tiên và văn bản ASCII sẽ khóa sau khi phê duyệt D01–D09. Không sử dụng số 0 giả thay cho Null. Một kết quả không xác nhận không phải tín hiệu bán hoặc xác nhận sự kiện ngược chiều.

Tối thiểu cần ghi: `WE_EventKindCode`, `WE_StatusCode`, `WE_StatusValid`, `WE_OriginBarIndex/DateTime`, `WE_DetectionBarIndex/DateTime`, `WE_EvaluationBarIndex/DateTime`, `WE_ReferenceSourceCode`, `WE_ReferenceAvailableBarIndex/DateTime`, biên hỗ trợ đã chọn, trạng thái/validity nguồn, tọa độ Confirmation liên quan, mã lý do bác bỏ/hết hiệu lực và trạng thái dữ liệu hoàn tất. Đây là danh sách trường dự kiến, chưa phải API đã khóa.

Nếu cần lưu một sự kiện qua nhiều thanh, phải xác định khóa định danh và giới hạn lưu trạng thái trước khi viết AFL. Không được dùng bộ nhớ ẩn hoặc chọn dữ liệu tương lai để thay đổi lịch sử. Nếu một thanh đồng thời kết thúc sự kiện cũ và khởi phát sự kiện mới, hai kết quả phải giữ tọa độ riêng.

## 6. Bất biến nhân quả

Vùng hỗ trợ phải được biết trước lúc quyết định dùng nó. Snapshot tại k không được thay bằng context của k+1. Confirmation chỉ dùng đúng k+1 và giữ nguyên mã nguyên bản. Nếu Event có cửa sổ xác nhận riêng được phê duyệt, đó là logic Event mới, không được sửa CE hoặc gán ngược kết quả vào k. Chỉ số nguồn và DateTime phải giữ nguyên. Không dùng Zig, Peak, Trough nhìn tương lai, cực trị xác nhận muộn như thể đã biết trước, hoặc BarCount để suy đoán thanh đã hoàn tất.

Khi dữ liệu thiếu hoặc sai hợp đồng, trạng thái phải phản ánh thiếu dữ liệu thay vì âm thầm thay vùng hoặc chọn tín hiệu khác. Sửa nguồn lịch sử có thể thay kết quả phụ thuộc, nhưng phải phân biệt với vẽ lại thuật toán. Mọi nguồn và tham số phải có định danh trong hồ sơ chạy.

## 7. Phản ví dụ bắt buộc trước lập trình

Một No Supply code3 ở giữa vùng hoặc gần kháng cự không tự là Test hỗ trợ. Một No Supply hợp lệ nhưng phản ứng không giữ hỗ trợ phải được đánh giá theo quy tắc bác bỏ riêng. Một cú xuyên và thu hồi không tự thành Spring hoặc Test thành công. Vùng thiếu lịch sử, dữ liệu lỗi hoặc zero-width không được xử lý bằng số 0 giả. Pivot mới xác nhận ở k+1 không được xuất hiện trong snapshot k. Một ứng viên mới không được ghi đè sự kiện cũ. Không xác nhận muộn hoặc backfill. Các bản dữ liệu có chung tiền tố phải giữ toàn bộ đầu ra cũ; nhập nối tiếp thực và sửa nguồn lịch sử phải được kiểm tra riêng.

## 8. Điều kiện chuyển sang lập trình

Phê duyệt D01–D10; khóa thuật ngữ, công thức, ngưỡng, miền mã, chính sách Null và tất cả tọa độ. Sau đó tạo mô hình tham chiếu độc lập, fixture cùng expected trước AFL, ma trận kiểm thử và kế hoạch hồi quy bốn lớp. Chỉ khi tài liệu và tiêu chí nghiệm thu được phê duyệt mới tạo nhánh triển khai Event. Không dùng kết quả kiểm thử để tự điều chỉnh ngưỡng hoặc làm đẹp tín hiệu.
