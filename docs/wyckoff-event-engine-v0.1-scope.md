# Wyckoff Event Engine — Đề cương kiến trúc v0.1

**Trạng thái:** ĐỀ XUẤT ĐỂ THẢO LUẬN. Chưa phải đặc tả v1.0 được phê duyệt, chưa có AFL, ngưỡng nhận diện, ma trận nghiệm thu hay tín hiệu giao dịch.

## 1. Cơ sở và ranh giới nguồn

Kiến trúc đã khóa: Core → Candidate → Structure/Location → Confirmation → Wyckoff Event. Confirmation v1.0 chỉ trả lời phản ứng Close ở thanh kế tiếp; bối cảnh được chụp tại thanh ứng viên và không tham gia điều kiện xác nhận. Tài liệu này đề xuất lớp kế tiếp, không diễn giải lại hoặc sửa bất kỳ quy tắc nào của bốn lớp trước.

Nguồn triển khai Confirmation: commit `c31e61fccdd7867f417bc036c3b9705c0256dc53`, AFL blob `48061c9dd763814dc31f27e1dcf19ed61065aee5`. Việc hợp nhất có ngoại lệ không có nghĩa Confirmation đã đạt đầy đủ 46/46. Lớp Event phải kế thừa thông tin về giới hạn bằng chứng, đặc biệt không tự coi thanh đang hình thành là hoàn tất.

## 2. Mục đích đề xuất

Chuyển các quan sát đo lường và xác nhận cơ bản thành những giả thuyết sự kiện Wyckoff có bối cảnh, thời điểm và điều kiện vô hiệu rõ ràng. Phân biệt quan sát, ứng viên sự kiện, sự kiện được xác nhận và giả thuyết bị bác bỏ. Không coi một mẫu nến đơn lẻ là bằng chứng chắc chắn về ý định của tổ chức hoặc dòng tiền lớn.

Đầu ra dự kiến phục vụ nghiên cứu, kiểm toán và lớp quyết định tương lai. Không tự động mua/bán, không quản trị vốn, không xếp hạng xác suất và không tối ưu hóa lợi nhuận trong v1.0 đầu tiên.

## 3. Kiến trúc dữ liệu

Lớp Event chỉ đọc đầu ra đã công bố của bốn lớp trước và dữ liệu nguồn cần thiết theo hợp đồng mới. Không sao chép công thức Core/Candidate/Structure/Confirmation. Không đổi tên hoặc ghi đè trường upstream. Các trường mới dự kiến dùng tiền tố `WE_`; tên chính thức phải được khóa trong đặc tả.

Mỗi bản ghi sự kiện đề xuất chứa: loại sự kiện, trạng thái, mã dữ liệu hợp lệ, thời điểm quan sát, tọa độ thanh khởi phát, tọa độ thanh đánh giá, phiên bản nguồn, các trường bối cảnh sử dụng, điều kiện kích hoạt, điều kiện vô hiệu, và các mốc tham chiếu cần thiết. Mọi trường phải có miền giá trị và chính sách Null; không dùng 0 giả thay cho dữ liệu thiếu.

Cần phân biệt ba loại thời điểm: thanh cực trị hoặc khởi phát, thanh phát hiện đủ điều kiện, và thanh công bố kết luận. Nếu một sự kiện cần nhiều thanh để xác nhận, kết quả chỉ được xuất tại thanh có đủ bằng chứng; không ghi ngược kết luận vào quá khứ. Có thể lưu tọa độ khởi phát để hiển thị, nhưng không được làm cho tín hiệu trông như đã biết tại thời điểm khởi phát.

## 4. Phạm vi sự kiện cần quyết định

Không triển khai đồng thời mọi sự kiện trước khi có định nghĩa thống nhất. Đề xuất chia theo các họ:

| Họ | Các khái niệm cần đặc tả | Điều cần phân biệt |
|---|---|---|
| Kiểm tra cung | Test, No Supply trong bối cảnh, Spring và Shakeout | Giảm cung chủ động, xuyên hỗ trợ, thu hồi vùng và phản ứng tiếp theo không phải cùng một hiện tượng. |
| Kiểm tra cầu và cung phía trên | No Demand trong bối cảnh, Upthrust, UTAD | Suy yếu sau tăng, phá kháng cự thất bại và vị trí trong cấu trúc phân phối phải được tách riêng. |
| Nỗ lực và hấp thụ | Stopping Volume, Climactic Volume, Absorption | Khối lượng lớn không tự động là mua hoặc bán; cần đánh giá kết quả giá và diễn biến tiếp theo. |
| Sức mạnh và tiếp diễn | SOS, LPS | Phá vùng, giữ hỗ trợ, kiểm tra lại và cầu quay lại cần có thời điểm xác nhận rõ. |
| Chu kỳ thị trường | PS, SC, AR, ST, tích lũy, phân phối, Markup, Markdown | Các nhãn phụ thuộc cấu trúc dài hơn; không được suy ra toàn bộ pha chỉ từ một tín hiệu VSA. |

Đây là danh sách ứng viên để thiết kế, không phải tuyên bố tất cả đã có quy tắc mã hóa hoặc đều thuộc phiên bản đầu tiên.

## 5. Phạm vi nhỏ đề xuất cho bản đầu tiên

Đề xuất bắt đầu bằng một họ sự kiện có thể kiểm tra rõ, chẳng hạn Test cung sau khi giá đã có vùng hỗ trợ hợp lệ, rồi mở rộng sang Spring/Shakeout và SOS/LPS. Việc chọn họ đầu tiên phải được người dùng phê duyệt trước khi khóa đặc tả. Không mặc định rằng No Supply được Confirmation xác nhận đồng nghĩa một Test thành công.

Đối với mỗi loại được chọn, đặc tả phải trả lời: bối cảnh nào là điều kiện tiên quyết; mốc hỗ trợ/kháng cự được lấy từ thời điểm nào; mẫu khởi phát được xác định ra sao; phản ứng nào là bắt buộc; cần bao nhiêu thanh và có được phép chờ nhiều thanh hay không; khi nào bác bỏ; khi nào hết hiệu lực; dữ liệu thiếu xử lý thế nào; sự kiện chồng lấn có được phép hay không; và kết quả xuất ở thanh nào.

Không đưa ra ngưỡng định lượng, cửa sổ xác nhận, điểm số hoặc quy tắc ưu tiên sự kiện trong tài liệu đề cương này. Những lựa chọn đó cần được soạn, tranh luận và khóa riêng; không vay mượn tùy tiện ngưỡng từ Confirmation hoặc điều chỉnh theo kết quả kiểm thử.

## 6. Trạng thái và quan hệ giữa sự kiện

Đề xuất mô hình trạng thái tối thiểu: dữ liệu không đủ, không có sự kiện, ứng viên đang theo dõi, xác nhận, bác bỏ hoặc hết hiệu lực. Đây chưa phải enum chính thức. Cần quyết định liệu mỗi họ dùng trạng thái riêng hay một hợp đồng chung; một thanh có thể có nhiều giả thuyết cùng tồn tại và không được âm thầm chọn một giả thuyết tốt nhất.

Quan hệ giữa các sự kiện phải là quan hệ nhân quả có thời điểm: một Spring có thể tạo điều kiện cho Test sau đó, hoặc một SOS có thể tạo điều kiện cho LPS, nhưng sự kiện sau không được viết lại thời điểm biết của sự kiện trước. Không suy luận rằng mọi chuỗi PS→SC→AR→ST đều bắt buộc xuất hiện, cũng không tự gán pha tích lũy/phân phối khi chưa có hợp đồng nhận diện pha.

## 7. Quy tắc bảo vệ nhân quả

Chỉ dùng dữ liệu đã tồn tại tại thời điểm công bố; mọi phép tham chiếu và cửa sổ phải được kiểm toán. Không dùng Zig/Peak/Trough nhìn tương lai, cực trị được xác nhận muộn như thể đã biết sớm hơn, hoặc giá trị tổng chuỗi để thay đổi lịch sử. Không có backfill trạng thái sự kiện. Thanh chưa hoàn tất phải được đánh dấu tạm thời hoặc bị loại theo chính sách được phê duyệt; không tự suy đoán trạng thái hoàn tất từ BarCount.

Khi dữ liệu nguồn lịch sử được sửa, kết quả phụ thuộc có thể thay đổi; hồ sơ phải phân biệt thay đổi nguồn với lỗi vẽ lại thuật toán. Phải giữ khóa Symbol/DateTime/BarIndex, phiên bản dữ liệu và chính sách điều chỉnh giá. Các mốc Structure/Location và Confirmation dùng trong quyết định phải là mốc có thể kiểm toán tại đúng thời điểm, không lấy nhầm snapshot hiện tại.

## 8. Kế hoạch đặc tả và kiểm thử trước lập trình

Trước khi viết AFL cần hoàn tất: danh mục thuật ngữ và phạm vi sự kiện được chọn; hợp đồng đầu vào/đầu ra; bảng trạng thái và chuyển trạng thái; công thức và ngưỡng đã phê duyệt; quy tắc thời điểm; chính sách dữ liệu lỗi; quy tắc chồng lấn; mô hình tham chiếu độc lập; fixture có expected trước khi lập trình; kế hoạch hồi quy và nghiệm thu.

Fixture phải có các tình huống phản ví dụ: tín hiệu giống Spring nhưng không thu hồi hỗ trợ; No Supply có phản ứng giá phù hợp nhưng vị trí không phù hợp; khối lượng lớn mà kết quả giá yếu; vùng tham chiếu thiếu hoặc zero-width; pivot chỉ xác nhận sau thanh khởi phát; ứng viên liên tiếp; xác nhận muộn; sửa hậu tố; nối dữ liệu thật; thay đổi nguồn lịch sử; và dữ liệu không hợp lệ. Mỗi tình huống phải có kết luận dự kiến theo quy tắc đã khóa, không dùng kết quả AFL làm expected.

Kiểm thử hồi quy phải chứng minh mọi đầu ra của bốn lớp upstream không đổi. Các giới hạn nghiệm thu Confirmation đã biết không được che giấu bởi lớp Event. Nếu nguồn Confirmation được sửa sau này, phải kiểm tra ảnh hưởng và chạy lại những phép thử liên quan; không mặc định kết quả cũ vẫn hợp lệ.

## 9. Các quyết định cần người dùng phê duyệt

1. Chọn họ sự kiện đầu tiên và danh sách sự kiện cụ thể của v1.0.
2. Chọn chính sách thanh hoàn tất, khung thời gian và dữ liệu điều chỉnh; xác định phạm vi sử dụng có giám sát.
3. Phê duyệt định nghĩa bối cảnh, mẫu khởi phát, xác nhận, bác bỏ, hết hiệu lực và xử lý chồng lấn.
4. Phê duyệt hợp đồng mã trạng thái, tọa độ và chính sách Null.
5. Phê duyệt kế hoạch kiểm thử và tiêu chí nghiệm thu trước khi triển khai AFL.

Sau khi các quyết định trên được khóa, mới tạo đặc tả Event v1.0, kế hoạch kiểm thử và nhánh triển khai riêng. Không tạo AFL Event hoặc thay đổi các lớp đã phát hành trong đợt tài liệu này.
