# Structure / Location Engine v1.0 — Kế hoạch kiểm thử

**Trạng thái:** Dự thảo để phê duyệt; chưa chạy AFL, chưa có kết quả nghiệm thu.  
**Đặc tả đích:** `docs/structure-location-engine-v1.0-spec.md`.  
**Nền:** `core-v1.0.0`, `candidate-v1.0.0`; commit `fe7a7329675ee2a9c4d7462a78c87df848df7909`.  
**Môi trường thực thi bắt buộc:** AmiBroker 6.20.01 (tối thiểu 6.20+).

## 1. Mục tiêu và nguyên tắc nghiệm thu

Chứng minh triển khai đúng toàn bộ phép đo vùng tham chiếu và điểm xoay đã xác nhận, không sử dụng thông tin tương lai, không sửa lại lịch sử, không thay đổi Core/Candidate và không sinh ra nhận định giao dịch.

Mỗi trường hợp phải có mã, nguồn dữ liệu, tham số, điều kiện đầu vào, giá trị kỳ vọng, bằng chứng thực tế và trạng thái PASS/FAIL/BLOCKED. Không được tính một trường hợp chưa chạy là PASS. Lỗi không được bỏ qua bằng cách sửa dữ liệu, ngưỡng hoặc công thức mà không có phê duyệt thay đổi đặc tả.

Kiểm tra tĩnh, kiểm tra bằng mô hình tham chiếu độc lập và chạy AmiBroker là ba nguồn bằng chứng khác nhau. Không nguồn nào tự động thay thế nguồn còn lại. Các kết quả Core/Candidate trước đây được kế thừa làm hồ sơ nền, không được tuyên bố là đã chạy lại trong lần nghiệm thu mới.

## 2. Chuẩn bị và khóa danh tính

Trước khi chạy, kiểm tra các thẻ phát hành và mã Git của Core/Candidate đúng như đặc tả. Ghi lại SHA đầy đủ của AFL mới và các tài liệu, phiên bản AmiBroker, nguồn dữ liệu, khung thời gian, chế độ điều chỉnh giá, tham số, số thanh, phạm vi phân tích và mã băm SHA-256 của từng tệp xuất.

Không trộn dữ liệu đã điều chỉnh và chưa điều chỉnh. Các kịch bản chỉnh sửa lịch sử chỉ được chạy trên bản sao tạm. Không xóa, nhập đè hoặc thay đổi cơ sở dữ liệu chứng khoán đang dùng để giao dịch.

Dùng cùng dữ liệu, tham số và phạm vi tính toán khi so sánh hồi quy. Đối với các kiểm thử độ ổn định tiền tố, dùng đầy đủ lịch sử nguồn và ghi lại chính xác phần lịch sử được so sánh. Kiểm tra riêng trường hợp AmiBroker tải một đoạn lịch sử để bảo đảm không nhầm BarIndex với chỉ số mảng.

## 3. Bộ dữ liệu và mô hình tham chiếu độc lập

Cần xây dựng trước khi triển khai AFL một bộ tạo dữ liệu và một mô hình tham chiếu độc lập bằng ngôn ngữ khác AFL. Mô hình tham chiếu thực hiện trực tiếp định nghĩa toán học, không sao chép cấu trúc hàm hoặc mã AFL. Mọi giá trị kỳ vọng được lưu kèm cờ hợp lệ, Null, mã trạng thái và tọa độ thời gian.

Các bộ dữ liệu tối thiểu:

- `SL_RANGE`: chuỗi OHLC hợp lệ có cực trị và vùng đã biết, dùng các độ dài nhỏ 2/3/5 để tính tay.
- `SL_BOUNDARY`: các trường hợp bằng biên, vừa vượt biên, vùng suy biến, giá và mẫu số đặc biệt.
- `SL_INVALID`: lỗi OHLC, Null, dữ liệu thiếu và các cấu hình sai.
- `SL_PIVOT`: các chuỗi đỉnh/đáy đơn, bằng nhau, liên tiếp, đồng thời, độ trễ và dữ liệu lỗi.
- `SL_CAUSALITY`: chuỗi đủ dài có các cực trị ở cuối tiền tố, với các biến thể tương lai được kiểm soát.
- `SL_NATIVE_APPEND`: dữ liệu có ngày và mã riêng, được nhập thành hai giai đoạn vào cơ sở dữ liệu tạm.
- `SL_LONG`: lịch sử dài để kiểm tra hiệu năng, độ dài 500 và hồi quy tích hợp.
- Một bộ dữ liệu chứng khoán thực, cố định phiên bản nguồn và phạm vi ngày.

Tệp CSV kỳ vọng không được dùng giá trị làm tròn để quyết định dấu bằng hoặc bất đẳng thức. Cần lưu giá trị nguồn thô hoặc một định dạng số có đủ độ chính xác. Mỗi tệp có mã băm và thông tin nguồn.

### 3.1. Ví dụ vùng tính tay

Với N=3, ba thanh trước có High `[13,12,14]`, Low `[10,9,11]`; thanh hiện tại H=15, L=10, C=11. Vùng phải là U=14, L=9, W=5, Location=0,4, CloseDistanceUpper=-3, CloseDistanceLower=2, HighPenetrationUpper=1, LowPenetrationLower=0, IntersectsUpper=1, IntersectsLower=0, CloseOutsideUpper=0, CloseOutsideLower=0.

WidthPercent = 100×5/11,5 = 43,4782608695652; CloseUpperPct = -21,4285714285714; CloseLowerPct = 22,2222222222222. Đây là các giá trị kỳ vọng toán học; dung sai số thực của môi trường sẽ được kiểm tra theo Mục 8, không dùng các chữ số đã làm tròn để phân loại.

## 4. Ma trận vùng tham chiếu

Các mã RV01–RV23 là trường hợp chính thức, phải có bằng chứng riêng. Mọi biến thể áp dụng cho cả ba vùng khi phụ thuộc tương ứng tồn tại.

| Mã | Nội dung | Kỳ vọng bắt buộc |
|---|---|---|
| RV01 | N=20, t=19 | ReferenceStatus=0; biên Null; ReferenceValid=0. |
| RV02 | N=20, t=20, 20 thanh trước hợp lệ | ReferenceValid=1; đúng max/min 0..19; không chứa thanh20. |
| RV03 | Cực trị nằm tại t-N | Biên dùng đúng cực trị ở đầu cửa sổ. |
| RV04 | Cực trị nằm tại t-1 | Biên dùng đúng cực trị ở cuối cửa sổ. |
| RV05 | Thay High/Low hiện tại thành cực trị mới | Biên tại t không đổi; chỉ phép đo hiện tại được đổi. |
| RV06 | Cực trị cũ rời cửa sổ trượt | Biên đổi đúng tại thanh đầu tiên không còn phụ thuộc cực trị; không sinh sự kiện Wyckoff. |
| RV07 | N=2,3,5 với các cực trị và giá trị bằng nhau | Kết quả khớp max/min trực tiếp, không bỏ qua hoặc nhân đôi quan sát. |
| RV08 | Một Null/lỗi ở đầu, giữa, cuối cửa sổ | ReferenceStatus=1, biên Null; đủ N hàng không đủ để coi hợp lệ. |
| RV09 | Lỗi nằm ngoài cửa sổ | Không ảnh hưởng vùng nếu mọi phụ thuộc trong cửa sổ hợp lệ. |
| RV10 | Giá hiện tại lỗi, cửa sổ trước hợp lệ | Biên vẫn hợp lệ; phép đo cần giá hiện tại Null và cờ0. |
| RV11 | U=L=10, C=10 | ReferenceStatus2, Width0, LocationNull, Position6, khoảng cách0; không chia0. |
| RV12 | U=120,L=100,C=100/110/120 | Location0/0,5/1; Position2/3/4. |
| RV13 | U=120,L=100,C=98/122 | Location-0,1/1,1; Position1/5; không ép vào[0,1]. |
| RV14 | Close bằng biên | CloseOutside bằng0; dấu bằng được giữ đúng. |
| RV15 | High xuyên U nhưng Close còn trong vùng | PenetrationUpper>0; CloseOutsideUpper0; không kết luận phá vỡ. |
| RV16 | Toàn bộ thanh nằm trên U | IntersectsUpper0, CloseOutsideUpper1. |
| RV17 | High/Low vừa chạm đúng biên | Intersects tương ứng1; xuyên biên0 nếu không vượt. |
| RV18 | Cả hai biên nằm trong một thanh rộng | Hai Intersects có thể cùng1; không có loại trừ giả. |
| RV19 | U=L, giá hiện tại ở ngoài mức chung | Position6 ưu tiên; khoảng cách và các phép đo không chia W vẫn hợp lệ. |
| RV20 | Đầu ra độc lập | Lỗi ở vùng120 không làm vùng20/60 lỗi nếu hai cửa sổ đó không chứa dữ liệu lỗi. |
| RV21 | Cấu hình 20/60/120 thay bằng 5/5/2 | Ba vùng độc lập; hai vùng5 có kết quả giống nhau, không tự sắp xếp. |
| RV22 | N=500, t=499/500/501 | Kiểm tra thiếu lịch sử, đủ lịch sử, chính xác đầu/cuối cửa sổ. |
| RV23 | OHLC cực trị lớn/nhỏ trong miền dữ liệu hợp lệ | Không có hằng sentinel rò rỉ, tràn số không được coi là kết quả hợp lệ. |

## 5. Ma trận cấu hình, tỷ lệ và trạng thái

| Mã | Nội dung | Kỳ vọng bắt buộc |
|---|---|---|
| CF01 | N=1,0,-1,501,1,5,Null | ConfigValid0, ReferenceStatus4; không tự sửa tham số. |
| CF02 | Một vùng lỗi cấu hình | Hai vùng còn lại vẫn tính được; cờ tổng hợp0. |
| CF03 | Left/Right=0,21,không nguyên hoặc Null | PivotConfigValid0, WindowStatus3, EventCode0. |
| CF04 | Left=1,Right=20 và Left=20,Right=1 | Hợp lệ; không ép hai phía bằng nhau. |
| CF05 | Cả ba độ dài bằng nhau | Kết quả ba vùng bằng nhau; không có thứ tự bắt buộc. |
| PC01 | U=120,L=100,C=110 | WidthPct20×100/110; UpperPct=-8,3333333333333; LowerPct10. |
| PC02 | U=10,L=0 | WidthPct hợp lệ nếu midpoint>0; LowerPctNull/Valid0; không đổi PriceInputValid. |
| PC03 | U=10,L=-10 | Midpoint0: WidthPctNull; UpperPct có thể hợp lệ; LowerPctNull. |
| PC04 | U=L=10,C=10 | WidthPct0, UpperPct0, LowerPct0 đều hợp lệ; LocationNull. |
| PC05 | Giá hiện tại lỗi, vùng hợp lệ | WidthPct vẫn có thể hợp lệ; các tỷ lệ có C không hợp lệ. |
| PC06 | Nhân tất cả OHLC với hệ số dương 10 | Location và tỷ lệ giữ nguyên trong sai số số thực; khoảng cách tuyệt đối nhân10. |
| PC07 | Giá trị sát ranh giới, không làm tròn | Dấu bằng và bất đẳng thức dựa trên giá trị nguồn; không dùng epsilon ẩn. |
| ST01 | Mã trạng thái vùng0..4 | Văn bản, cờ hợp lệ và Null đúng bảng đặc tả. |
| ST02 | Mã vị trí0..6 | Văn bản và điều kiện loại trừ đúng từng mã; Width0 ưu tiên6. |
| ST03 | Tất cả cờ quan hệ0 khi thiếu dữ liệu | Cờ hợp lệ phải0, không diễn giải là quan sát không xuất hiện. |
| ST04 | Cấu hình sai và dữ liệu thiếu đồng thời | InvalidConfig ưu tiên; trạng thái khác không che nguyên nhân. |
| ST05 | Xuất đủ độ chính xác | Tệp thô phân biệt các giá trị hai phía ranh giới mà định dạng hiển thị có thể làm tròn giống nhau. |

## 6. Ma trận điểm xoay chiều đã xác nhận

Các trường hợp PV01–PV23 áp dụng riêng cho đỉnh và đáy khi thích hợp, dùng cả mặc định3/3 và cấu hình nhỏ để dễ đối chiếu.

| Mã | Nội dung | Kỳ vọng bắt buộc |
|---|---|---|
| PV01 | A=3,B=3,t=5 | WindowStatus0, EventCode0; không đọc cực trị chưa đủ cửa sổ. |
| PV02 | A=3,B=3,t=6 với cực trị tại3 hợp lệ | Đây là thanh đầu tiên có thể xác nhận; không xác nhận tại3. |
| PV03 | Một đỉnh cao hơn toàn bộ3 thanh trái và bằng/lớn hơn3 thanh phải | EventHighCode2 tại k+3; đúng giá và tọa độk. |
| PV04 | Một đáy thấp hơn toàn bộ3 thanh trái và bằng/nhỏ hơn3 thanh phải | EventLowCode2 tại k+3; đúng giá và tọa độk. |
| PV05 | Đỉnh bằng một High bên trái trong cửa sổ | Không được xác nhận; bất đẳng thức trái nghiêm ngặt. |
| PV06 | Đỉnh bằng một High bên phải | Được phép xác nhận nếu các điều kiện khác đạt. |
| PV07 | Đáy bằng một Low bên trái | Không được xác nhận. |
| PV08 | Đáy bằng một Low bên phải | Được phép xác nhận nếu các điều kiện khác đạt. |
| PV09 | Cụm đỉnh bằng nhau liên tiếp | Ưu tiên điểm xuất hiện sớm hơn; không sinh nhiều đỉnh trong cùng cụm trái. |
| PV10 | Hai cực trị bằng nhau cách xa hơn A | Có thể cùng được xác nhận nếu từng cửa sổ đạt; không loại trừ toàn cục. |
| PV11 | Hai đỉnh hợp lệ liên tiếp mà chưa có đáy xác nhận | Cả hai sự kiện được xuất; không ép luân phiên. |
| PV12 | Một thanh vừa là đỉnh vừa là đáy theo hai quy tắc | Hai sự kiện có thể cùng2; lưu hai luồng độc lập. |
| PV13 | Một thanh trái/phải có PriceInputValid0 | WindowStatus1, EventCode0; không bỏ qua dữ liệu lỗi. |
| PV14 | Cửa sổ hiện tại lỗi sau khi có mốc cũ | Không có sự kiện mới; latest cũ vẫn giữ cùng nguồn gốc. |
| PV15 | Trước sự kiện đầu tiên | LatestValid0, giá và chỉ số Null; không dùng chỉ số0 giả. |
| PV16 | Đỉnh tại100 xác nhận tại103 | Event tại103, ExtremeIndex100, ConfirmIndex103, Lag3; hàng100 không bị gán ngược. |
| PV17 | Nối thêm dữ liệu chưa đủ B thanh sau cực trị | Chưa có xác nhận; khi đủ mới phát sự kiện tại thanh xác nhận. |
| PV18 | Thay tương lai sau thời điểm xác nhận | Không đổi sự kiện đã xác nhận nếu toàn bộ cửa sổ nguồn không đổi. |
| PV19 | Sự kiện mới tại t | Latest tại t chứa mốc mới; LatestPrior tại t chỉ chứa trạng thái đến t-1. |
| PV20 | Tuổi mốc sau xác nhận | LatestAge=t-k; BarsSinceConfirmation=t-confirm; không tự hết hạn. |
| PV21 | Cực trị gần đầu dữ liệu, thiếu thanh trái | Không xác nhận bằng cách rút ngắn cửa sổ. |
| PV22 | Đỉnh/đáy tại cuối cửa sổ, cực trị bằng nhau và dữ liệu âm hợp lệ | Đúng miền số và quy tắc so sánh; không dùng sentinel. |
| PV23 | Mọi mã0/1/2 và trạng thái cửa sổ0..3 | Ánh xạ văn bản, Null, cờ hợp lệ và loại trừ đúng bảng. |

### 6.1. Ví dụ xác nhận và bằng nhau

Với A=3,B=3, High tại k=5 bằng14, ba High trái `[11,13,12]`, ba High phải `[13,12,14]`. Tất cả trái nhỏ hơn14, tất cả phải không lớn hơn14 nên xác nhận đỉnh tại t=8. High tại k=8 không được xác nhận như một đỉnh mới nếu High14 tại k=5 còn nằm trong ba thanh trái của nó.

Nếu thay High tại k=5 thành13,5, điều kiện tại k=5 thất bại do High14 bên phải. Không được sửa lại lịch sử để coi k=8 đã được biết trước t=11.

### 6.2. Ví dụ tiền tố điểm xoay

Một đỉnh tại k=100 với Right3 chưa thể được xác nhận khi dữ liệu kết thúc tại102. Khi nối thêm thanh103, nếu điều kiện đạt, sự kiện xuất hiện tại103; không có bất kỳ thay đổi nào ở hàng100–102 của các cột sự kiện lịch sử. Các cột latest tại103 được phép cập nhật, còn ảnh chụp prior tại103 phải phản ánh trạng thái đến102.

## 7. Kiểm thử tính nhân quả và nối thêm dữ liệu

### 7.1. Kịch bản có kiểm soát

Tạo các bản A/B/C/D từ cùng một tiền tố bất biến, trong đó B thay đổi các thanh tương lai sau mốc, C chỉ có tiền tố, D thay đổi một thanh hiện tại hoặc thanh ở ranh giới xác nhận. Các trường được so sánh phải có cùng tham số, nguồn lịch sử và thời điểm khả dụng.

Đối với vùng tham chiếu, thay thanh t chỉ được thay đổi các phép đo cần giá hiện tại tại t, không đổi Upper/Lower/Width của chính t. Thay một thanh k trong lịch sử chỉ được ảnh hưởng các cửa sổ chứa k và các phép đo phụ thuộc vào chúng; không được ảnh hưởng thời điểm trước k.

Đối với điểm xoay, thay thanh ở tương lai của thời điểm xác nhận không được thay đổi sự kiện đã xác nhận. Thay thanh trong cửa sổ xác nhận có thể làm sự kiện tại hoặc sau thanh đó thay đổi, nhưng không được sinh sự kiện ở một thời điểm đã xảy ra trước khi có dữ liệu cần thiết. Không so sánh các trạng thái latest sau mốc có thể chịu ảnh hưởng hợp lệ như thể chúng là kết quả bất biến.

### 7.2. Nối thêm dữ liệu thực trong cơ sở dữ liệu tạm

Tạo cơ sở dữ liệu riêng với mã giả, khung Daily và dữ liệu địa phương. Nhập tiền tố P thanh, xuất toàn bộ lịch sử, sau đó nhập riêng Q thanh mới có ngày tiếp nối. Không nhập lại toàn bộ lịch sử hoặc dùng AFL giả lập BarCount để thay cho bài kiểm thử nối thêm thật.

Chạy đúng cùng AFL, Core, Candidate và tham số trên cơ sở dữ liệu có P và P+Q thanh. Xác nhận BarCount thực tăng; toàn bộ P thanh cũ có cùng khóa định danh, dữ liệu nguồn và giá trị xuất. So sánh tất cả các cột Core/Candidate/Structure, gồm Null, văn bản, trạng thái, giá và tọa độ. Các cột phụ thuộc cấu hình, tổng số thanh hoặc thông tin chạy phải được tách riêng và không coi là kết quả đo lường bất biến.

Điểm xoay được xác nhận tại thanh mới không được viết ngược về thanh cực trị cũ. Nếu lịch sử nguồn cũ đã bị chỉnh sửa ngoài ý muốn, kiểm thử phải bị chặn thay vì coi kết quả thay đổi là lỗi nhân quả.

## 8. Độ chính xác và quy tắc so sánh

Mã trạng thái, cờ, chỉ số, ngày, mã chứng khoán, văn bản và Null phải khớp tuyệt đối. Các phép so sánh ranh giới phải dùng giá trị nguồn chưa làm tròn và cùng quy tắc số học đã được ghi nhận. Không được thêm dung sai vào công thức để làm kiểm thử dễ đạt.

Đối với phép đối chiếu số thực với mô hình tham chiếu độc lập, xác định trước dung sai theo độ chính xác thực tế của AmiBroker và định dạng xuất; đề xuất ban đầu là `abs(a-b) <= max(1e-7, 1e-6*max(abs(a),abs(b)))`, nhưng phải được kiểm tra bằng một bộ dữ liệu hiệu chuẩn và phê duyệt trong hồ sơ thử trước khi áp dụng. Đây là dung sai đối chiếu, không phải ngưỡng phân loại hoặc thay đổi công thức. Nếu cần dung sai lớn hơn, phải điều tra nguyên nhân chứ không tự nới.

Các lần chạy lặp lại cùng AFL, cùng dữ liệu và tham số phải so sánh được giá trị thô chính xác khi môi trường xuất cho phép. Không được chấp nhận sai lệch chỉ vì số hiển thị giống nhau. Mọi trường hợp mâu thuẫn ở ranh giới phải được phân tích bằng giá trị chưa làm tròn.

## 9. Kiểm thử tích hợp và hồi quy

Chạy Core độc lập, Candidate đã phát hành và Structure mới trên cùng dữ liệu và tham số. Đối chiếu từng hàng theo Symbol, DateTime và BarIndex. Toàn bộ cột Core/Candidate phải giữ nguyên cả tên, giá trị, Null, văn bản và ý nghĩa; không chấp nhận thay đổi ngầm tham số hoặc cách tính ATR khi thêm lớp mới.

Kiểm tra tĩnh xác nhận chỉ thêm tệp Structure và tài liệu/bộ thử đã phê duyệt, không sửa hai phiên bản đã phát hành. Không có lệnh giao dịch, điểm số, bộ quét, gán pha/sự kiện Wyckoff, sửa biểu đồ hiện có hoặc tham chiếu tương lai. Kiểm tra đúng mọi tên biến `SL_`, ánh xạ trạng thái và không ghi đè biến Core/Candidate.

Kiểm tra thực tế việc nạp toàn bộ lịch sử, chỉ số mảng/BarIndex, các tham số tối đa và hiệu năng trên lịch sử dài. Đặt tiêu chí thời gian và bộ nhớ trước lần đo, dùng cùng máy và tập dữ liệu để so sánh. Không tối ưu bằng cách làm sai dữ liệu lỗi, cắt lịch sử cần thiết hoặc thay đổi công thức Core.

## 10. Tiêu chí kết thúc và hồ sơ nghiệm thu

Tất cả trường hợp chính thức phải có PASS và bằng chứng; mọi lỗi, trường hợp bị chặn và thay đổi đặc tả phải được giải quyết trước khi chấp nhận. Không có sai lệch mã/trạng thái, không có sử dụng dữ liệu tương lai, không có hồi quy Core/Candidate và không có kết quả số không hợp lệ bị xuất như hợp lệ.

Báo cáo nghiệm thu phải ghi rõ số trường hợp, số phép đối chiếu, số sai lệch, phạm vi dữ liệu, mã băm bằng chứng, danh tính phiên bản, kết quả kiểm tra tĩnh và kết quả chạy AmiBroker thực. Không suy diễn “đạt mọi tình huống thị trường” từ bộ thử hữu hạn.

Sau khi chủ dự án phê duyệt kết quả mới đề xuất hợp nhất mã. Thẻ và bản phát hành chỉ được tạo sau khi hợp nhất được phê duyệt riêng và commit đích được đọc lại. Không tự động hợp nhất hoặc phát hành.
