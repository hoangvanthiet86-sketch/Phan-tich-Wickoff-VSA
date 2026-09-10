# Wyckoff Event Engine — Đề cương kiến trúc v0.1

**Trạng thái:** ĐÃ CHỐT ĐỊNH HƯỚNG KIẾN TRÚC. Chưa phải đặc tả chung cho mọi họ sự kiện và chưa có AFL Event tổng quát.

## 1. Cơ sở và ranh giới nguồn

Kiến trúc đã khóa: Core → Candidate → Structure/Location → Confirmation → Wyckoff Event. Confirmation v1.0 chỉ trả lời phản ứng Close ở thanh kế tiếp; bối cảnh được chụp tại thanh ứng viên và không tham gia điều kiện xác nhận. Lớp Event kế thừa các đầu ra này, không diễn giải lại hoặc sửa bất kỳ quy tắc nào của bốn lớp trước.

Nguồn triển khai Confirmation: commit `c31e61fccdd7867f417bc036c3b9705c0256dc53`, AFL blob `48061c9dd763814dc31f27e1dcf19ed61065aee5`. Việc hợp nhất có ngoại lệ không có nghĩa Confirmation đã đạt đầy đủ 46/46. Lớp Event phải kế thừa thông tin về giới hạn bằng chứng, đặc biệt không tự coi thanh đang hình thành là hoàn tất.

## 2. Mục đích

Chuyển các quan sát đo lường và xác nhận cơ bản thành những giả thuyết sự kiện Wyckoff có bối cảnh, thời điểm và điều kiện vô hiệu rõ ràng. Phân biệt quan sát, ứng viên sự kiện, sự kiện được xác nhận và giả thuyết bị bác bỏ. Không coi một mẫu nến đơn lẻ là bằng chứng chắc chắn về ý định của tổ chức hoặc dòng tiền lớn.

Đầu ra phục vụ nghiên cứu, kiểm toán và lớp quyết định tương lai. Không tự động mua/bán, không quản trị vốn, không xếp hạng xác suất và không tối ưu hóa lợi nhuận trong v1.0 đầu tiên.

## 3. Kiến trúc dữ liệu

Lớp Event chỉ đọc đầu ra đã công bố của bốn lớp trước và dữ liệu nguồn cần thiết theo hợp đồng Event. Không sao chép công thức Core/Candidate/Structure/Confirmation. Không đổi tên hoặc ghi đè trường upstream. Các trường mới dùng tiền tố `WE_`; từng mô-đun con có tiền tố hẹp hơn, ví dụ Supply Test dùng `WE_ST_`.

Mỗi bản ghi sự kiện phải chứa loại sự kiện, trạng thái, mã dữ liệu hợp lệ, thời điểm quan sát, tọa độ thanh khởi phát, tọa độ thanh đánh giá, phiên bản nguồn, các trường bối cảnh sử dụng, điều kiện kích hoạt, điều kiện vô hiệu và các mốc tham chiếu cần thiết. Mọi trường phải có miền giá trị và chính sách Null; không dùng 0 giả thay cho dữ liệu thiếu.

Cần phân biệt ba loại thời điểm: thanh cực trị hoặc khởi phát, thanh phát hiện đủ điều kiện và thanh công bố kết luận. Nếu một sự kiện cần nhiều thanh để xác nhận, kết quả chỉ được xuất tại thanh có đủ bằng chứng; không ghi ngược kết luận vào quá khứ. Có thể lưu tọa độ khởi phát để hiển thị nhưng không được làm cho tín hiệu trông như đã biết tại thời điểm khởi phát.

## 4. Các họ sự kiện

Các họ vẫn được chia như sau nhưng không triển khai đồng thời:

| Họ | Các khái niệm | Điều cần phân biệt |
|---|---|---|
| Kiểm tra cung | Test, No Supply trong bối cảnh, Spring và Shakeout | Giảm cung chủ động, xuyên hỗ trợ, thu hồi vùng và phản ứng tiếp theo không phải cùng một hiện tượng. |
| Kiểm tra cầu và cung phía trên | No Demand trong bối cảnh, Upthrust, UTAD | Suy yếu sau tăng, phá kháng cự thất bại và vị trí trong cấu trúc phân phối phải được tách riêng. |
| Nỗ lực và hấp thụ | Stopping Volume, Climactic Volume, Absorption | Khối lượng lớn không tự động là mua hoặc bán; cần đánh giá kết quả giá và diễn biến tiếp theo. |
| Sức mạnh và tiếp diễn | SOS, LPS | Phá vùng, giữ hỗ trợ, kiểm tra lại và cầu quay lại cần có thời điểm xác nhận rõ. |
| Chu kỳ thị trường | PS, SC, AR, ST, tích lũy, phân phối, Markup, Markdown | Các nhãn phụ thuộc cấu trúc dài hơn; không được suy ra toàn bộ pha chỉ từ một tín hiệu VSA. |

## 5. Họ sự kiện đầu tiên đã được phê duyệt

Chủ dự án đã chấp thuận bắt đầu bằng **Test cung thông thường tại hỗ trợ hợp lệ**. Phạm vi chính thức nằm trong:

- `docs/wyckoff-event-supply-test-v1.0-spec.md`;
- `tests/wyckoff-event-supply-test-v1.0-test-plan.md`.

Supply Test v1.0 dùng pivot Low đã xác nhận trước thanh khởi phát làm nguồn hỗ trợ, No Supply Candidate làm mẫu khởi phát, giới hạn khoảng cách 0,50 PriorATR và giải quyết đúng ở thanh kế tiếp. S/M/L chỉ là context; Spring/Shakeout không thuộc phạm vi và không được tự gán từ một cú xuyên hỗ trợ.

Việc chọn họ đầu tiên không mặc định rằng No Supply được Confirmation xác nhận đồng nghĩa một Test thành công. Tất cả điều kiện cụ thể được khóa trong đặc tả Supply Test.

## 6. Trạng thái và quan hệ giữa sự kiện

Mỗi mô-đun Event phải có hợp đồng trạng thái riêng được khóa trước AFL. Supply Test v1.0 dùng hai kênh Origin/Resolution để cho phép một thanh vừa giải quyết Event cũ vừa khởi phát Event mới mà không ghi đè tọa độ.

Quan hệ giữa các sự kiện phải là quan hệ nhân quả có thời điểm. Một Spring tương lai có thể tạo điều kiện cho Test sau đó hoặc một SOS có thể tạo điều kiện cho LPS, nhưng sự kiện sau không được viết lại thời điểm biết của sự kiện trước. Không suy luận rằng mọi chuỗi PS→SC→AR→ST đều bắt buộc xuất hiện và không tự gán pha tích lũy/phân phối khi chưa có hợp đồng nhận diện pha.

## 7. Quy tắc bảo vệ nhân quả

Chỉ dùng dữ liệu đã tồn tại tại thời điểm công bố; mọi phép tham chiếu và cửa sổ phải được kiểm toán. Không dùng Zig/Peak/Trough nhìn tương lai, cực trị được xác nhận muộn như thể đã biết sớm hơn, hoặc giá trị tổng chuỗi để thay đổi lịch sử. Không backfill trạng thái sự kiện.

Thanh chưa hoàn tất phải được đánh dấu tạm thời hoặc bị loại theo chính sách từng mô-đun; không tự suy đoán trạng thái hoàn tất từ BarCount. Khi dữ liệu nguồn lịch sử được sửa, kết quả phụ thuộc có thể thay đổi; hồ sơ phải phân biệt thay đổi nguồn với lỗi vẽ lại thuật toán.

## 8. Trình tự phát triển bắt buộc

Trước AFL của từng Event phải hoàn tất: thuật ngữ và phạm vi; hợp đồng đầu vào/đầu ra; bảng trạng thái; công thức/ngưỡng; quy tắc thời điểm; chính sách dữ liệu lỗi; quy tắc chồng lấn; mô hình tham chiếu độc lập; fixture có expected trước lập trình; kế hoạch hồi quy và nghiệm thu.

Supply Test đã hoàn tất bước khóa đặc tả và kế hoạch kiểm thử. Bước kế tiếp là tạo mô hình tham chiếu độc lập và fixture/expected trước khi tạo nhánh AFL Event.

Các giới hạn nghiệm thu Confirmation đã biết không được che giấu bởi lớp Event. Nếu nguồn Confirmation được sửa sau này, phải kiểm tra ảnh hưởng và chạy lại các phép thử liên quan.
