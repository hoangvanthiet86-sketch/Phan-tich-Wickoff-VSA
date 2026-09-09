# Supply Test Event v1.0 — Kế hoạch kiểm thử dự thảo

**Trạng thái:** CHƯA PHÊ DUYỆT. Không có AFL Event, mô hình kỳ vọng cuối cùng hoặc kết quả nghiệm thu. Kế hoạch này là khung kiểm tra cho `docs/wyckoff-event-supply-test-v1.0-spec-draft.md`; chưa được phép dùng để tuyên bố một ca đã đạt.

## 1. Điều kiện tiên quyết

Phê duyệt các quyết định D01–D10 trong đặc tả dự thảo, gồm nguồn hỗ trợ, vòng đời vùng, vị trí, mẫu khởi phát, phản ứng, bác bỏ, hết hiệu lực, chồng lấn và chính sách thanh hoàn tất. Đóng băng công thức và miền mã trước khi viết AFL. Tạo mô hình tham chiếu độc lập và các giá trị kỳ vọng từ dữ liệu đầu vào, không lấy kết quả AFL làm kỳ vọng. Mọi ca phải có trường đầu vào, kết quả mong đợi, tọa độ và điều kiện đạt cụ thể trước khi thực thi.

## 2. Danh mục kiểm thử dự kiến

| Mã | Tình huống | Bất biến cần chứng minh |
|---|---|---|
| ST01 | Không đủ lịch sử hoặc cấu hình lỗi | Không phát sự kiện giả; giữ nguyên nguyên nhân thiếu dữ liệu. |
| ST02 | Vùng hỗ trợ hợp lệ và đã khả dụng | Chọn đúng nguồn, biên và tọa độ; không lấy dữ liệu tương lai. |
| ST03 | Vùng trượt thay biên sau khởi phát | Giữ đúng mốc đã khóa hoặc xử lý theo vòng đời được phê duyệt. |
| ST04 | No Supply ở vị trí không phù hợp | Không tự gán Test thành công chỉ vì Confirmation code3. |
| ST05 | Ứng viên phù hợp nhưng phản ứng thất bại | Giữ đúng trạng thái và không xác nhận muộn ngoài cửa sổ Event. |
| ST06 | Phản ứng phù hợp và hỗ trợ giữ | Chỉ xác nhận khi toàn bộ điều kiện đã phê duyệt cùng hợp lệ. |
| ST07 | Xuyên hỗ trợ rồi thu hồi | Không tự gán Spring/Shakeout hoặc Test thành công nếu chưa có hợp đồng tương ứng. |
| ST08 | Hỗ trợ bị phá hoặc hết hiệu lực | Bác bỏ/hết hạn đúng nguyên nhân và thời điểm. |
| ST09 | Vùng zero-width, lỗi và thiếu lịch sử độc lập | Không thay vùng lỗi bằng vùng khác hoặc dùng Null như số 0. |
| ST10 | Pivot chỉ xác nhận sau khởi phát | Không dùng pivot trước thời điểm thực sự khả dụng. |
| ST11 | Hai ứng viên liên tiếp hoặc chồng lấn | Giữ khóa và tọa độ từng giả thuyết; không âm thầm chọn tốt nhất. |
| ST12 | Dữ liệu khởi phát/đánh giá không hợp lệ | Trạng thái thiếu dữ liệu độc lập với bác bỏ do giá. |
| ST13 | Xác nhận nhiều thanh nếu được phê duyệt | Chỉ công bố tại thanh đủ bằng chứng; không sửa Confirmation hoặc backfill. |
| ST14 | Thay hậu tố sau thời điểm t | Toàn bộ đầu ra đến t bất biến khi tiền tố nguồn không đổi. |
| ST15 | Nhập nối tiếp P rồi Q thật trên AmiBroker | Thanh hoàn tất cũ không đổi; tọa độ nguồn giữ nguyên. |
| ST16 | Sửa OHLCV lịch sử có kiểm soát | Phân biệt thay đổi nguồn với lỗi vẽ lại thuật toán. |
| ST17 | Thanh đang hình thành | Chỉ kiểm tra khi có nguồn và chính sách hoàn tất được phê duyệt; không suy đoán bằng BarCount. |
| ST18 | Hồi quy bốn lớp upstream | Toàn bộ đầu ra Core/Candidate/Structure/Confirmation không đổi nguyên văn. |
| ST19 | Kiểm toán tĩnh | Không giao dịch, điểm số, nhìn tương lai, ghi đè upstream hoặc điều kiện ẩn. |
| ST20 | Verify/Explore/Filter và biểu đồ | Chạy được trên AmiBroker đích; không thêm lệnh hoặc ký hiệu giao dịch ngoài phạm vi. |

Đây là 20 nhóm dự kiến, không phải ma trận nghiệm thu đã khóa. Sau khi phê duyệt đặc tả phải mở rộng từng nhóm thành ca cụ thể, có fixture, expected và tiêu chí PASS/FAIL. Không tự miễn các ca do Confirmation trước đây được miễn; chỉ những yêu cầu thật sự phụ thuộc vào phần chưa chứng minh mới cần ghi rủi ro kế thừa.

## 3. Bằng chứng và khóa nguồn

Trước/sau kiểm thử phải xác minh nguồn bốn lớp upstream và Event đang thử; ghi commit, Git blob, SHA-256, phiên bản AmiBroker, mã, khung thời gian, nguồn/phiên bản dữ liệu, chính sách điều chỉnh, tham số, số thanh và phạm vi Analysis. Mọi bản xuất phải có mã băm và khóa Symbol/DateTime/BarIndex. Không nhập đè dữ liệu thị trường thật; không sử dụng dữ liệu có bản quyền hoặc cá nhân trong repository khi chưa có quyền.

Kiểm tra tĩnh, mô hình độc lập và chạy AmiBroker là bằng chứng khác nhau. Không tự chuyển mô phỏng thành kiểm thử trực tiếp, không chuyển miễn kiểm thử thành PASS, không thay expected hoặc ngưỡng để ép đạt. Nếu chấp nhận ngoại lệ, phải có quyết định riêng về rủi ro và phạm vi sử dụng trước hợp nhất/phát hành.

## 4. Thứ tự thực hiện sau phê duyệt

Khóa đặc tả → tạo mô hình và fixture kỳ vọng → kiểm tra độc lập mô hình → lập trình AFL trên nhánh riêng → kiểm thử cô lập → kiểm thử chuỗi đầy đủ → nhân quả và nhập nối tiếp → hồi quy upstream → kiểm toán phạm vi Git → biên bản nghiệm thu. Không viết AFL Event trong giai đoạn dự thảo này.
