# Structure / Location Engine v1.0 — Đặc tả hợp nhất

**Trạng thái:** Dự thảo kỹ thuật hợp nhất để phê duyệt tài liệu; chưa triển khai hoặc hợp nhất lên GitHub.  
**Ngày:** 08/09/2026.  
**Nền cố định:** `core-v1.0.0`, `candidate-v1.0.0`.  
**Commit nền:** `fe7a7329675ee2a9c4d7462a78c87df848df7909`.  
**Môi trường:** AmiBroker 6.20.01, tối thiểu 6.20+.  
**Tệp triển khai dự kiến:** `afl/WyckoffVSA_StructureLocation_v1.0.afl`.

## 1. Nguồn chuẩn và quyết định đã phê duyệt

Nguồn tham chiếu là các tệp tại hai thẻ phát hành của kho `hoangvanthiet86-sketch/Phan-tich-Wickoff-VSA`, không phải những bản sao chưa kiểm chứng. Giữ nguyên ba blob Core:

- `afl/WyckoffVSA_Core_v1.0.afl`: `c03a9599a246849d562ea162975f202781049f90`.
- `docs/core-engine-v1.0-spec.md`: `6788874973cbc6a117037a6865f7db2a173efeb2`.
- `docs/robust-atr-correction-v1.0.md`: `7f8ac6d7cc391044d578a5e35c92799373110501`.

Candidate AFL đã phát hành có blob `589575722c2e2188513f635f089fd97ed2ee7b59`; đặc tả và kế hoạch thử lần lượt là `a33f28890c2d0230a723dcc872b2311991f63731` và `8b4031c0f95eda419d3314086b5eef0d37aeb456`.

Các quyết định đã được chủ dự án đồng ý: ba vùng cao/thấp quá khứ độc lập mặc định 20/60/120; bổ sung cờ hợp lệ, cấu hình, khoảng cách phần trăm và nguồn gốc thời gian; không dùng ATR ở lõi đầu tiên; điểm xoay hai phía mặc định 3/3, nghiêm ngặt bên trái và cho phép bằng bên phải; không gán xác nhận ngược lịch sử; không ép đỉnh–đáy luân phiên. Những chi tiết kỹ thuật được làm rõ thêm trong tài liệu này cần được phê duyệt cùng toàn bộ đặc tả trước khi khóa.

## 2. Phạm vi và bất biến

Mô-đun chỉ đo vị trí giá so với vùng tham chiếu và các điểm xoay đã xác nhận. Không tự chọn vùng quan trọng nhất, không kết luận hỗ trợ/kháng cự thực sự, tích lũy, phân phối, pha Wyckoff, Spring, Upthrust, SOS, LPS, xác nhận No Demand/No Supply hoặc xu hướng giao dịch.

Không có điểm số tổng hợp, mức tin cậy, xác suất, dự báo, lệnh mua/bán, quản trị vị thế, kiểm thử lợi nhuận, cảnh báo hoặc bộ quét thị trường. Không sửa công thức, biến, mã trạng thái, tham số, số cột hay biểu đồ hiện có của Core/Candidate.

Luồng phụ thuộc: Core → Candidate → Structure/Location → Confirmation → Wyckoff Event. Lớp sau có thể đọc các phép đo nhưng không được coi nhãn cấu trúc là kết luận giao dịch. Các phiên bản phát hành trước là bất biến.

## 3. Quy ước thời gian và dữ liệu

Ký hiệu `t` là vị trí logic của một thanh trong chuỗi dữ liệu theo thứ tự thời gian, bắt đầu từ 0 trong bộ dữ liệu chuẩn. `H_t`, `L_t`, `C_t` là High, Low, Close. Không nhầm chỉ số logic này với chỉ số mảng thực tế mà AmiBroker đang tải; `BarIndex()` có thể có gốc khác với vị trí mảng trong một đoạn dữ liệu. Mọi phép truy cập phải dùng ánh xạ đúng và có kiểm tra biên.

`PriceInputValid_t` kế thừa nguyên trạng Core: High/Low/Close không Null, Close > 0, High >= Low và Low <= Close <= High. Không thêm điều kiện Low > 0, không yêu cầu Open/Volume hợp lệ cho cấu trúc giá. Mọi phép tính mới còn phải kiểm tra mẫu số, kết quả số hữu hạn và các điều kiện riêng của nó. Không dùng một cờ hợp lệ chung thay cho toàn bộ phụ thuộc.

Các cửa sổ phải sử dụng thanh thực sự trước `t`, không phải số hàng tình cờ có trong một đoạn xuất. Không bỏ qua, nội suy, chuyển tiếp, thay thế hoặc lấy thanh cũ hơn để bù dữ liệu lỗi. Giá trị thay thế chỉ được phép tồn tại nội bộ để tính toán an toàn và phải bị che về Null ở đầu ra không hợp lệ. Không dùng hằng cực lớn/cực nhỏ giả định để tạo cực trị nếu chưa chứng minh an toàn cho miền giá.

Thanh đang hình thành có kết quả tạm thời. Mô-đun không tự phát hiện giờ đóng cửa sàn, không tự tuyên bố thanh đã hoàn tất và không tự sửa dữ liệu nguồn. Khi nhà cung cấp điều chỉnh lịch sử, những kết quả có phụ thuộc vào dữ liệu bị điều chỉnh được phép thay đổi; không cam kết bất biến đối với dữ liệu nguồn đã đổi.

## 4. Tham số và cấu hình

| Mã | Tên tham số | Mặc định | Miền đề xuất |
|---|---|---:|---|
| S | `SL_S_Lookback` | 20 | Số nguyên 2–500 |
| M | `SL_M_Lookback` | 60 | Số nguyên 2–500 |
| L | `SL_L_Lookback` | 120 | Số nguyên 2–500 |
| Đỉnh/đáy | `SL_PivotLeft` | 3 | Số nguyên 1–20 |
| Đỉnh/đáy | `SL_PivotRight` | 3 | Số nguyên 1–20 |

Miền của hai tham số điểm xoay là chi tiết kỹ thuật mới được đề xuất để phê duyệt cùng tài liệu. Các tham số độc lập; không yêu cầu S < M < L hoặc Left = Right. Không tự sắp xếp, ép giới hạn, làm tròn cấu hình lỗi hoặc thay bằng mặc định. Giao diện có thể giới hạn đầu vào nhưng kiểm thử phải đưa cấu hình lỗi trực tiếp vào bộ tính toán.

Có `SL_S_ConfigValid`, `SL_M_ConfigValid`, `SL_L_ConfigValid`, `SL_PivotConfigValid` riêng. `SL_ConfigValid` là cờ kiểm toán tổng hợp của cả năm tham số, không phải điều kiện chặn toàn bộ mô-đun. Một vùng cấu hình lỗi không làm hai vùng khác mất hiệu lực; lỗi tham số điểm xoay không làm vùng tham chiếu mất hiệu lực.

## 5. Lõi vùng tham chiếu nhiều độ dài

Với một trong ba độ dài N:

```text
Window(t,N) = [t-N, ..., t-1]
PriorValidCount(t,N) = tổng PriceInputValid trên các thanh thực sự có sẵn trong Window
ReferenceValid = ConfigValid AND t >= N AND PriorValidCount == N
Upper(t,N) = max(H_i), i thuộc Window
Lower(t,N) = min(L_i), i thuộc Window
Width(t,N) = Upper - Lower
ReferenceRangeValid = ReferenceValid AND Width > 0
```

Upper/Lower/Width chỉ được công bố khi ReferenceValid bằng 1 và kết quả số hợp lệ. Nếu không, chúng là Null. Vùng hợp lệ có Upper >= Lower và Width >= 0. Vùng Width = 0 vẫn là vùng hợp lệ về dữ liệu; không được tự gán vị trí 0,5.

Khi t<N, chỉ đếm các thanh thực sự tồn tại, không coi phần lịch sử chưa có là thanh lỗi; khi cấu hình sai, PriorValidCount là Null. Thanh đầu tiên có thể có vùng đủ N thanh là `t=N`. Với N=20, t=19 thiếu lịch sử; t=20 chỉ hợp lệ nếu cả 20 thanh trước hợp lệ. Dữ liệu lỗi tại k làm mất hiệu lực đúng những cửa sổ chứa k và không ảnh hưởng các cửa sổ khác nếu không có phụ thuộc chung.

Việc tính cực trị không được dựa vào hành vi ngầm của hàm cửa sổ đối với Null. Có thể dùng hàm cực trị, vòng lặp hoặc thuật toán tối ưu nếu kết quả tương đương với định nghĩa trên. Không được dùng High/Low của thanh hiện tại để tạo vùng của chính thanh đó.

### 5.1. Trạng thái vùng

Tên mã: `SL_X_ReferenceStatusCode`, với X là S, M hoặc L.

| Mã | Văn bản | Điều kiện |
|---:|---|---|
| 0 | `INSUFFICIENT HISTORY` | Cấu hình hợp lệ, t < N |
| 1 | `INVALID REFERENCE DATA` | Đủ lịch sử nhưng cửa sổ có dữ liệu không hợp lệ hoặc cực trị không tính được |
| 2 | `ZERO WIDTH REFERENCE` | Vùng hợp lệ, Width = 0 |
| 3 | `READY` | Vùng hợp lệ, Width > 0 |
| 4 | `INVALID CONFIG` | Cấu hình của vùng không hợp lệ |

Thứ tự ưu tiên: cấu hình lỗi → thiếu lịch sử → dữ liệu lỗi → Width bằng 0 → sẵn sàng. ReferenceValid bằng 1 ở mã 2/3; ReferenceRangeValid chỉ bằng 1 ở mã 3. Các mã là bộ chọn trạng thái, không phải điểm số.

## 6. Vị trí và khoảng cách

Với một vùng hợp lệ, đặt U=Upper, L=Lower, W=Width, C=Close hiện tại. Mọi phép đo giá hiện tại yêu cầu `PriceInputValid_t=1`. Điều kiện số hữu hạn và mẫu số riêng vẫn được áp dụng.

### 6.1. Vị trí tương đối

```text
Location = (C-L)/W
LocationValid = PriceInputValid AND ReferenceRangeValid AND kết quả hữu hạn
```

Giữ nguyên giá trị ngoài [0,1]; không ép giới hạn. Width=0 trả Null và LocationValid=0. Location bằng 0, 0,5, 1 lần lượt là biên dưới, giữa, biên trên. Không sao chép quy tắc ClosePosition=0,5 của Core cho vùng suy biến.

### 6.2. Khoảng cách tuyệt đối có dấu

```text
CloseDistanceUpper = C-U
CloseDistanceLower = C-L
```

`DistanceValid` yêu cầu giá hiện tại và vùng hợp lệ, cùng kết quả hữu hạn. Không phụ thuộc W>0. Vì vậy Width=0 vẫn có thể có khoảng cách hợp lệ. Đơn vị là đơn vị giá gốc, không mặc định là đồng hay nghìn đồng.

### 6.3. Độ xuyên biên

```text
HighPenetrationUpper = max(H-U,0)
LowPenetrationLower  = max(L-Low,0)
```

`PenetrationValid` yêu cầu giá hiện tại và vùng hợp lệ. Hai kết quả không âm, bằng 0 khi không xuyên. Không gọi chúng là phá vỡ thành công hay phá vỡ giả.

### 6.4. Các phép đo tỷ lệ phần trăm

```text
Midpoint       = (U+L)/2
WidthPercent   = 100*W/Midpoint       nếu Midpoint > 0
CloseUpperPct  = 100*(C/U-1)          nếu U > 0
CloseLowerPct  = 100*(C/L-1)          nếu L > 0
```

Có cờ `WidthPercentValid`, `CloseUpperPctValid`, `CloseLowerPctValid` riêng. Phép tính chỉ công bố nếu vùng và các phụ thuộc hợp lệ, mẫu số dương, kết quả hữu hạn. Midpoint phải được tính theo cách tránh tràn số không cần thiết mà vẫn tương đương toán học. Không thay đổi PriceInputValid để ép Low dương.

WidthPercent không phải phần trăm biến động giá và không phải ngưỡng phân loại. CloseUpperPct/CloseLowerPct giữ dấu. Width=0 không tự làm các tỷ lệ trên mất hiệu lực nếu mẫu số của chúng hợp lệ; chỉ những tỷ lệ chia cho W mới bị loại. Không thêm ATR normalization trong v1.0.

### 6.5. Giao cắt và trạng thái phía ngoài biên

```text
IntersectsUpper  = High >= U AND Low <= U
IntersectsLower  = High >= L AND Low <= L
CloseOutsideUpper = C > U
CloseOutsideLower = C < L
```

`BoundaryRelationValid` yêu cầu giá hiện tại và vùng hợp lệ. Các cờ xuất 0/1, nhưng 0 khi không hợp lệ chỉ là giá trị an toàn, phải đọc kèm cờ hợp lệ. `Intersects` nghĩa là biên nằm trong khoảng High–Low, không đồng nghĩa với vượt biên hoặc một sự kiện Wyckoff. Một thanh nằm hoàn toàn trên U có thể không IntersectsUpper nhưng CloseOutsideUpper bằng 1.

Close bằng biên không được tính là vượt; không sử dụng sai số hiển thị để xét bằng nhau. Không bổ sung sự kiện cắt từ bên trong ra bên ngoài, phá vỡ, kiểm tra lại hoặc hồi phục trong lõi này.

### 6.6. Trạng thái vị trí

`SL_X_PositionStateCode`:

| Mã | Văn bản | Điều kiện |
|---:|---|---|
| 0 | `INSUFFICIENT DATA` | Giá hiện tại hoặc vùng phụ thuộc không hợp lệ |
| 1 | `BELOW LOWER` | C < L |
| 2 | `AT LOWER` | C = L |
| 3 | `INSIDE` | L < C < U |
| 4 | `AT UPPER` | C = U |
| 5 | `ABOVE UPPER` | C > U |
| 6 | `ZERO WIDTH REFERENCE` | Giá hiện tại và vùng hợp lệ, W = 0 |

Ưu tiên mã 6 trước các phép so sánh vị trí; một vùng suy biến không được đồng thời bị gán tại cả hai biên. Cấu hình lỗi tạo mã vị trí 0 và mã vùng 4, không che giấu nguyên nhân. Văn bản phải khớp chính xác mã theo từng hàng lịch sử.

## 7. Nguồn gốc thời gian của vùng

Mỗi vùng xuất độ dài, số quan sát hợp lệ, chỉ số và DateTime của đầu/cuối cửa sổ. Các tên xuất là `SL_X_ReferenceAvailableBarIndex` và `SL_X_ReferenceAvailableDateTime` cho thời điểm tham chiếu khả dụng. Khi cấu hình hợp lệ và t>=N, tọa độ cửa sổ được công bố kể cả khi dữ liệu giá bên trong lỗi; khi thiếu lịch sử hoặc cấu hình sai, tọa độ cửa sổ là Null. Với vùng tại t:

```text
WindowStart = t-N
WindowEnd   = t-1
ReferenceAvailableAt = t
```

Chỉ số được xuất là BarIndex của nguồn tương ứng, không tự suy ra bằng vị trí mảng khi lịch sử bị tải một phần. DateTime phải giữ đúng dữ liệu nguồn, không tự tạo ngày giao dịch. Ghi lại mã chứng khoán, khung thời gian, nguồn/phiên bản dữ liệu, chế độ điều chỉnh giá, toàn bộ tham số và phạm vi tính toán trong hồ sơ chạy.

Vùng theo cửa sổ trượt không phải vùng giao dịch có vòng đời được duy trì. Việc một cực trị rời khỏi cửa sổ có thể làm biên đổi dù không có một sự kiện giá mới. Mô-đun không được diễn giải thay đổi đó là phá vỡ cấu trúc, hấp thụ, tích lũy hoặc phân phối.

## 8. Điểm xoay chiều đã xác nhận

### 8.1. Định nghĩa

Với Left=A, Right=B, điểm cực trị ứng viên tại k và thanh xác nhận t=k+B, cửa sổ yêu cầu là `[k-A,...,k+B]`. Toàn bộ A+1+B thanh phải có PriceInputValid=1. Cấu hình hợp lệ yêu cầu A và B là số nguyên trong miền đã định.

Đỉnh được xác nhận tại t khi:

```text
H[k] >  H[k-i] với mọi i=1..A
H[k] >= H[k+j] với mọi j=1..B
```

Đáy được xác nhận tại t khi:

```text
Low[k] <  Low[k-i] với mọi i=1..A
Low[k] <= Low[k+j] với mọi j=1..B
```

So sánh bằng nhau là số thực theo dữ liệu nguồn, không làm tròn và không có dung sai ẩn. Quy tắc bất đối xứng ưu tiên cực trị xuất hiện sớm hơn trong cụm bằng nhau còn nằm trong cửa sổ trái. Hai cực trị bằng nhau cách xa hơn cửa sổ vẫn có thể được xác nhận độc lập. Không ép đỉnh/đáy luân phiên; một thanh cực trị có thể đồng thời đáp ứng cả hai loại khi dữ liệu cho phép.

Thanh đầu tiên có thể xác nhận là `t=A+B`, tại cực trị k=A. Với mặc định 3/3, cực trị đầu tiên có thể là k=3 và được xác nhận tại t=6. Thiếu một thanh trong cửa sổ hoặc cấu hình lỗi không tạo sự kiện.

### 8.2. Trạng thái cửa sổ và sự kiện

`SL_PivotWindowStatusCode`:

| Mã | Văn bản | Điều kiện |
|---:|---|---|
| 0 | `INSUFFICIENT HISTORY` | t < A+B |
| 1 | `INVALID REFERENCE DATA` | Có đủ lịch sử nhưng cửa sổ lỗi |
| 2 | `READY` | Cửa sổ đầy đủ, hợp lệ |
| 3 | `INVALID CONFIG` | A hoặc B không hợp lệ |

Cấu hình lỗi có ưu tiên cao nhất. `SL_PivotWindowValid` bằng 1 chỉ ở mã 2.

Mỗi loại đỉnh/đáy có mã sự kiện riêng `SL_PivotHighEventCode`, `SL_PivotLowEventCode`:

- 0: `INSUFFICIENT DATA` — cửa sổ hoặc cấu hình không hợp lệ.
- 1: `NOT PRESENT` — cửa sổ hợp lệ nhưng không xác nhận loại điểm xoay đó tại thanh này.
- 2: `CONFIRMED PIVOT` — vừa xác nhận tại thanh hiện tại.

`SL_PivotHighEventValid` và `SL_PivotLowEventValid` bằng PivotWindowValid. Không có mã hoặc nhãn khẳng định một cực trị tiềm năng đã được xác nhận trước khi đủ B thanh. v1.0 không xuất các điểm xoay tạm thời để lớp sau sử dụng.

### 8.3. Thời điểm khả dụng và không gán ngược lịch sử

Tại t=k+B, nếu điều kiện đạt, một sự kiện được phát ra **tại t**, mang theo giá và thời điểm cực trị k. Không ghi lại mã sự kiện ở k, không tạo lịch sử giả tại k và không dùng điểm này trong bất kỳ phép đo nào có thời điểm quyết định trước t.

Trường `ExtremeBarIndex`, `ExtremeDateTime` chỉ nơi cực trị; `ConfirmBarIndex`, `ConfirmDateTime` chỉ nơi xác nhận. `ConfirmationLag=B`. Cả hai thời điểm phải được giữ riêng.

Điểm được xác nhận trở thành thông tin khả dụng sau khi xử lý thanh xác nhận. Một phép đo dùng trạng thái cuối thanh t được phép đọc điểm vừa xác nhận tại t nếu hợp đồng của nó cho phép; một phép đo đánh giá thanh t bằng tham chiếu đã tồn tại trước thanh hiện tại phải dùng ảnh chụp trạng thái đến t-1. Không được dùng điểm vừa xác nhận tại t để bí mật thay thế tham chiếu trước t của chính thanh đó.

### 8.4. Các mốc gần nhất

Đỉnh và đáy được duy trì độc lập. Sau khi có sự kiện, lưu mốc gần nhất cùng giá, BarIndex/DateTime cực trị, BarIndex/DateTime xác nhận, độ trễ, số thanh kể từ xác nhận và số thanh kể từ cực trị. Trước sự kiện đầu tiên, `LatestValid=0`, giá và chỉ số không tồn tại là Null.

Một cửa sổ hiện tại không đủ hợp lệ không tự xóa sự kiện đã được xác nhận trước đó. Tuy nhiên, `LatestValid=1` chỉ có nghĩa có một mốc lịch sử được lưu, không phải có một hỗ trợ/kháng cự hiện còn hiệu lực. Tuổi mốc tiếp tục tăng theo thanh; không có cơ chế hết hạn, thay thế theo độ mạnh hoặc tự xác nhận lại. Mọi mốc mới chỉ xuất hiện từ sự kiện xác nhận mới; không được suy luận mốc mới bằng cách quét lại lịch sử rồi gán ngược.

Ảnh chụp `LatestPrior` là đầu ra bắt buộc, chứa trạng thái đã được xác nhận đến t-1, được chụp trước khi xử lý sự kiện tại t. Tuổi của mốc trong cả Latest và LatestPrior được tính tại t; ảnh chụp không được chứa sự kiện mới tại t. Không được âm thầm dùng trạng thái mới cập nhật tại t để thay cho tham chiếu trước thanh hiện tại.

### 8.5. Giới hạn

Không nối thành ZigZag, không dùng Peak/Trough để gán lại lịch sử, không ép luân phiên, không chọn đỉnh/đáy “quan trọng nhất”, không xếp hạng xu hướng, không tự tạo Trading Range thích nghi và không gán pha/sự kiện Wyckoff. Mối liên hệ giữa điểm xoay với ba vùng tham chiếu chỉ là các cột đo lường độc lập trong v1.0.

## 9. Hợp đồng đầu ra và tên biến

Tất cả tên biến mới bắt đầu bằng `SL_`. Dùng `X` là S/M/L; tên cụ thể phải được khai triển thành ba nhóm, không để ký tự `<X>` trong mã AFL. Các cờ là số 0/1; các trạng thái là số nguyên; các giá trị số không hợp lệ là Null. Văn bản lịch sử sử dụng `AddMultiTextColumn()` hoặc cơ chế tương đương đã được chứng minh đúng trên AmiBroker 6.20. Không dùng `WriteIf()` để gán trạng thái cho nhiều hàng lịch sử.

### 9.1. Nhóm vùng (mỗi X)

**Tham số và dữ liệu:** `SL_X_Lookback`, `SL_X_ConfigValid`, `SL_X_PriorValidCount`, `SL_X_ReferenceStatusCode`, `SL_X_ReferenceStatus`, `SL_X_ReferenceValid`, `SL_X_ReferenceRangeValid`, `SL_X_WindowStartBarIndex`, `SL_X_WindowEndBarIndex`, `SL_X_WindowStartDateTime`, `SL_X_WindowEndDateTime`, `SL_X_ReferenceAvailableBarIndex`, `SL_X_ReferenceAvailableDateTime`.

**Biên và vị trí:** `SL_X_Upper`, `SL_X_Lower`, `SL_X_Width`, `SL_X_Location`, `SL_X_LocationValid`, `SL_X_PositionStateCode`, `SL_X_PositionState`.

**Khoảng cách:** `SL_X_DistanceValid`, `SL_X_CloseDistanceUpper`, `SL_X_CloseDistanceLower`, `SL_X_PenetrationValid`, `SL_X_HighPenetrationUpper`, `SL_X_LowPenetrationLower`.

**Tỷ lệ:** `SL_X_WidthPercent`, `SL_X_WidthPercentValid`, `SL_X_CloseUpperPct`, `SL_X_CloseUpperPctValid`, `SL_X_CloseLowerPct`, `SL_X_CloseLowerPctValid`.

**Quan hệ biên:** `SL_X_BoundaryRelationValid`, `SL_X_IntersectsUpper`, `SL_X_IntersectsLower`, `SL_X_CloseOutsideUpper`, `SL_X_CloseOutsideLower`.

### 9.2. Nhóm điểm xoay

Các tên đề xuất được giữ nhất quán theo tiền tố `SL_Pivot...`: `SL_PivotLeft`, `SL_PivotRight`, `SL_PivotConfigValid`, `SL_PivotWindowStatusCode`, `SL_PivotWindowStatus`, `SL_PivotWindowValid`, `SL_PivotWindowValidCount`, `SL_PivotWindowStartBarIndex`, `SL_PivotWindowEndBarIndex`, `SL_PivotWindowStartDateTime`, `SL_PivotWindowEndDateTime`, `SL_PivotCandidateBarIndex`, `SL_PivotCandidateDateTime`. Tọa độ cửa sổ/cực trị chỉ được công bố khi cấu hình hợp lệ và có đủ lịch sử; sự kiện lỗi dữ liệu vẫn có thể có tọa độ cửa sổ kiểm toán. Cấu hình sai làm ValidCount và các tọa độ này Null.

Với mỗi loại `High`/`Low`: `SL_PivotYEventValid`, `SL_PivotYEventCode`, `SL_PivotYEvent`, `SL_PivotYEventPrice`, `SL_PivotYExtremeBarIndex`, `SL_PivotYExtremeDateTime`, `SL_PivotYConfirmBarIndex`, `SL_PivotYConfirmDateTime`, `SL_PivotYConfirmationLag`, `SL_PivotYLatestValid`, `SL_PivotYLatestPrice`, `SL_PivotYLatestExtremeBarIndex`, `SL_PivotYLatestExtremeDateTime`, `SL_PivotYLatestConfirmBarIndex`, `SL_PivotYLatestConfirmDateTime`, `SL_PivotYLatestAge`, `SL_PivotYLatestBarsSinceConfirmation`. Y là High hoặc Low.

Ảnh chụp trước thanh hiện tại là bắt buộc: `SL_PivotYLatestPriorValid`, `SL_PivotYLatestPriorPrice`, `SL_PivotYLatestPriorExtremeBarIndex`, `SL_PivotYLatestPriorExtremeDateTime`, `SL_PivotYLatestPriorConfirmBarIndex`, `SL_PivotYLatestPriorConfirmDateTime`, `SL_PivotYLatestPriorAge`, `SL_PivotYLatestPriorBarsSinceConfirmation`. Không được tái sử dụng `Latest` để mang hai ý nghĩa thời gian khác nhau. Các trường giá/định danh sự kiện phải Null khi sự kiện không xuất hiện; không dùng 0 làm chỉ số giả.

### 9.3. Cột chung và khả năng kiểm toán

`SL_CurrentPriceValid` kế thừa PriceInputValid. Có các tham số thực tế, mã nguồn/phiên bản dữ liệu và danh tính nền trong hồ sơ chạy. Các trạng thái và mã phải có bảng ánh xạ cố định, duy nhất, không phụ thuộc ngôn ngữ hệ điều hành. Nhãn có thể trình bày tiếng Việt nhưng không thay đổi mã kỹ thuật đã khóa.

Các cột giá, tỷ lệ và tọa độ phải có định dạng đủ chính xác hoặc cơ chế xuất thô để kiểm toán ranh giới. Không dùng số đã làm tròn ba chữ số để kết luận một phép so sánh nghiêm ngặt. Không tăng phạm vi thành bộ quét và không ghi đè `Filter=1` của Core.

## 10. Chính sách tính toán AFL và dữ liệu nguồn

Nguồn lịch sử phải được nạp đầy đủ để bảo đảm cửa sổ và các trạng thái đệ quy của Core được tính đúng. Nếu AmiBroker chỉ tải một đoạn lịch sử, phải chứng minh phần lịch sử bắt buộc đã được nạp và ánh xạ chỉ số đúng; không được coi đầu đoạn tải là đầu dữ liệu thực. Đối với nghiệm thu, ưu tiên toàn bộ lịch sử để so sánh Core/Candidate không bị ảnh hưởng bởi cách nạp dữ liệu. Mọi tối ưu hóa tải lịch sử phải có kiểm thử tương đương riêng, không được thay đổi các lớp đã khóa.

Đối với điểm xoay, tại t chỉ được đọc các thanh từ t-(A+B) đến t. Không dùng Ref dương, phép cực trị có trung tâm nhìn tương lai, ZigZag vẽ lại hoặc dữ liệu sau t. Có thể dùng vòng lặp theo thời gian tăng dần hoặc biểu thức mảng đã chứng minh tương đương. Không ghi ngược vào hàng k khi xác nhận tại t.

Mọi tham số cấu hình, phép toán số, điều kiện phụ thuộc và trạng thái phải được kiểm thử độc lập. Không thêm hằng dung sai để biến dấu bằng thành gần bằng hoặc thay đổi điều kiện so sánh. Nếu nguồn dữ liệu không hữu hạn hoặc phép tính tràn số, kết quả phụ thuộc không được xuất Infinity/NaN như số hợp lệ; lý do lỗi được ghi rõ trong cờ và trạng thái liên quan.

## 11. Hợp đồng kiểm thử và nghiệm thu

Kế hoạch chính thức nằm trong `tests/structure-location-engine-v1.0-test-plan.md`. Mọi trường hợp phải có dữ liệu đầu vào, tham số, giá trị kỳ vọng và tiêu chí đạt. Kiểm tra tĩnh không thay thế biên dịch và chạy thật trong AmiBroker 6.20.01.

Bắt buộc có kiểm thử ranh giới chính xác, dữ liệu lỗi, cấu hình, vùng suy biến, cực trị bằng nhau, đỉnh/đáy liên tiếp, hai sự kiện cùng thanh, xác nhận có độ trễ, ảnh chụp trước/sau xác nhận, thay đổi tương lai, nối thêm dữ liệu thật và hồi quy tuyệt đối của Core/Candidate.

Kết quả đã đạt của Core và Candidate là bằng chứng nền, không tự động được tính là nghiệm thu mô-đun mới. Toàn bộ kết quả v1.0 mới phải được kiểm chứng và chủ dự án phê duyệt riêng.

## 12. Trình tự và điều kiện phát hành

Hoàn tất và phê duyệt đặc tả cùng kế hoạch kiểm thử → tạo nhánh tài liệu riêng → kiểm toán và yêu cầu hợp nhất tài liệu → chủ dự án phê duyệt hợp nhất → triển khai AFL trên nhánh riêng → thử nghiệm tĩnh, dữ liệu chuẩn và AmiBroker thực → nghiệm thu → phê duyệt hợp nhất mã → kiểm tra commit `main` → tạo thẻ/bản phát hành riêng.

Không sửa các thẻ đã phát hành, không tự động hợp nhất, không tạo thẻ hoặc bản phát hành cho một bản chưa nghiệm thu. Các quyết định mới phát sinh phải được ghi trong tài liệu và duyệt trước khi lập trình, không giải quyết bằng cách âm thầm sửa công thức.
