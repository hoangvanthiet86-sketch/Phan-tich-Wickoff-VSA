# Supply Test Event v1.0 — Kế hoạch kiểm thử

**Trạng thái:** ĐÃ KHÓA ĐỂ TẠO MÔ HÌNH VÀ FIXTURE. Chưa có AFL Event hoặc kết quả nghiệm thu.

Nguồn chuẩn: `docs/wyckoff-event-supply-test-v1.0-spec.md`. Expected phải được tạo trước AFL và không lấy từ kết quả AmiBroker.

## 1. Mục tiêu

Chứng minh Event chỉ nhận diện Test cung thông thường tại pivot Low đã biết trước, dùng No Supply Candidate, khoảng cách tối đa 0,50 PriorATR, không xuyên hỗ trợ và chỉ giải quyết tại k+1. Đồng thời chứng minh không làm thay đổi bốn lớp upstream và không nhìn tương lai.

## 2. Ca chức năng khóa

| Mã | Tình huống | Expected |
|---|---|---|
| ST01 | Chưa có pivot Low prior | OriginCode=0, reason=2. |
| ST02 | Pivot Low mới chỉ xác nhận tại chính k | Không được dùng làm hỗ trợ; nếu không có pivot prior khác thì OriginCode=0. |
| ST03 | Có pivot Low prior hợp lệ | SupportPrice và tọa độ phải trỏ đúng LatestPrior. |
| ST04 | Có pivot mới hơn đã xác nhận trước k | Chọn pivot mới nhất, không tự chọn pivot thuận lợi hơn. |
| ST05 | No Supply không xuất hiện, mọi dependency khác hợp lệ | OriginCode=1, reason=1. |
| ST06 | No Supply xuất hiện nhưng PriorATR lỗi | OriginCode=0, reason=3. |
| ST07 | Low đúng SupportPrice | Điều kiện khoảng cách đạt. |
| ST08 | Low đúng SupportPrice + 0,50*PriorATR | Điều kiện khoảng cách đạt. |
| ST09 | Low cao hơn biên 0,50*PriorATR | OriginCode=1, reason=4. |
| ST10 | Low thấp hơn SupportPrice | OriginCode=1, reason=5; không gán Spring/Shakeout. |
| ST11 | Dữ liệu Low/Close khởi phát lỗi | OriginCode=0, reason=6. |
| ST12 | Toàn bộ điều kiện khởi phát đạt | OriginCode=2 và snapshot hỗ trợ cố định. |
| ST13 | Prior OriginCode khác 2 | ResolutionCode=1. |
| ST14 | Prior origin hợp lệ, CE No Supply code3, Low_t giữ hỗ trợ | ResolutionCode=3, Confirmed=1. |
| ST15 | Prior origin hợp lệ, CE phản ứng hợp lệ nhưng code2 | ResolutionCode=2, reason=1. |
| ST16 | CE code3 nhưng Low_t xuyên hỗ trợ | ResolutionCode=2, reason=2. |
| ST17 | CE không xác nhận và Low_t xuyên hỗ trợ | ResolutionCode=2, reason=3. |
| ST18 | CE candidate coordinate không trỏ k | ResolutionCode=0, reason=4. |
| ST19 | Close/Low đánh giá lỗi | ResolutionCode=0, reason=5. |
| ST20 | k+1 không xác nhận, k+2 thuận lợi | Không xác nhận muộn; Event cũ giữ kết quả tại k+1. |
| ST21 | k+1 vừa giải quyết Event cũ vừa có origin mới | Hai kênh Origin/Resolution cùng tồn tại, tọa độ độc lập. |
| ST22 | Pivot mới xác nhận tại k+1 | Không thay SupportPrice đã chụp tại k. |
| ST23 | S/M/L thay đổi tại k+1 | Không thay context/snapshot của Event tại k. |
| ST24 | Pivot price Null/<=0 hoặc validity lỗi | OriginCode=0; không fallback sang S/M/L. |
| ST25 | Giá bằng ranh giới Close của Confirmation | Kế thừa CE code2; Event không tự thêm epsilon. |
| ST26 | Dữ liệu nguồn có cùng tiền tố và hậu tố khác | Mọi đầu ra Event đến hết tiền tố giống nhau. |
| ST27 | Nhập nối tiếp P rồi P+Q trên cùng database | Các thanh cũ và khóa Event cũ không đổi. |
| ST28 | Sửa OHLCV lịch sử có kiểm soát | Chỉ các kết quả phụ thuộc được phép đổi; ghi source revision. |
| ST29 | Thanh cuối chưa hoàn tất | Kết quả chỉ provisional; không ký nghiệm thu realtime. |
| ST30 | Nhiều mã/khung chạy riêng | Không rò trạng thái giữa Symbol/Periodicity. |

## 3. Kiểm thử dữ liệu và hợp đồng

Phải có fixture riêng cho Null, giá <=0, ATR không hợp lệ, pivot validity lỗi, tọa độ pivot thiếu, CE status lỗi và code ngoài miền. Không được dùng 0 thay Null. Các ca dữ liệu lỗi phải tách khỏi bác bỏ do giá.

Mỗi fixture phải khóa Symbol, DateTime, BarIndex, OHLCV, các đầu vào upstream cần thiết, expected Origin/Resolution, reason code, SupportPrice và mọi tọa độ. Các số ranh giới phải chọn giá trị biểu diễn được chính xác hoặc dùng Decimal trong mô hình tham chiếu để tránh kết luận dựa trên lỗi hiển thị.

## 4. Kiểm thử nhân quả

Bắt buộc có ba họ bằng chứng:

- **Hậu tố A/B:** cùng tiền tố P, hai hậu tố khác nhau; toàn bộ output đến cuối P phải giống nhau.
- **Nhập nối tiếp:** chạy P, lưu output; thêm Q vào cùng database; output P phải bất biến nếu nguồn P không đổi.
- **Sửa nguồn:** thay có kiểm soát một thanh lịch sử; phân biệt thay đổi nguồn với algorithmic repaint.

Không dùng Zig, Peak, Trough hoặc giá trị tương lai để tạo expected.

## 5. Hồi quy upstream

Trước và sau Event, xuất toàn bộ trường Core, Candidate, Structure/Location và Confirmation. So sánh nguyên văn theo Symbol/DateTime/BarIndex. Yêu cầu 0 sai khác khi nguồn và tham số giống nhau.

Event không được gán lại `Filter`, `Buy`, `Sell`, `Short`, `Cover`, không thêm backtest, score hoặc alert giao dịch.

## 6. Kiểm thử AmiBroker

Mục tiêu AmiBroker 6.20.01:

- Verify Syntax thành công;
- Explore chạy đủ fixture và bộ full-chain;
- Range/Periodicity/parameters được ghi trong run record;
- Filter và biểu đồ upstream không bị Event thay đổi ngoài các cột WE_ST_ được thêm;
- không có lỗi runtime hoặc Null propagation không dự kiến.

Thanh đang hình thành không bắt buộc trong vòng nghiệm thu v1.0 nghiên cứu Daily; nếu chạy thì chỉ là bằng chứng bổ sung và phải phân biệt với thanh hoàn tất.

## 7. Kiểm toán tĩnh và Git

Trước nghiệm thu phải kiểm tra:

- include_once đúng chuỗi `Event → Confirmation → Structure → Candidate → Core`;
- không có tham chiếu tương lai;
- không ghi đè tên upstream;
- mọi biến Event dùng tiền tố `WE_ST_`;
- hằng số 0,50 ATR đúng đặc tả;
- diff chỉ gồm tệp Event và artefact kiểm thử/tài liệu được phép;
- Git blob và SHA-256 nguồn nền khớp khóa.

## 8. Tiêu chí nghiệm thu

Một ca chỉ PASS khi expected đã khóa trước AFL, mô hình độc lập và kết quả AmiBroker cùng khớp trong phạm vi ca. Không tự sửa expected hoặc 0,50 ATR để ép PASS.

Điều kiện phát hành Event v1.0 sẽ được quyết định sau khi ma trận fixture cụ thể được tạo. Việc Confirmation có ngoại lệ không tự động miễn các ca Event độc lập; chỉ dependency thực sự không thể chứng minh mới được ghi rủi ro kế thừa.