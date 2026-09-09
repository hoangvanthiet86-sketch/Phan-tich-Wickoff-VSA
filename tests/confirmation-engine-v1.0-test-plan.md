# Confirmation Engine v1.0 — Kế hoạch kiểm thử

**Trạng thái:** Dự thảo để phê duyệt; chưa có AFL hoặc kết quả nghiệm thu.

**Đặc tả đích:** `docs/confirmation-engine-v1.0-spec.md`.

**Nền:** `core-v1.0.0`, `candidate-v1.0.0`, `structure-location-v1.0.0`; commit `7c2b8cfb4d729c5b1b631f3860e43a46fc2f6f23`.

**Môi trường thực thi bắt buộc:** AmiBroker 6.20.01 (tối thiểu 6.20+).

## 1. Mục tiêu nghiệm thu

Chứng minh triển khai tương lai:

1. Chỉ đánh giá Candidate ở thanh ngay trước và chỉ phát xác nhận tại thanh kế tiếp.
2. Xác nhận đúng quy tắc Close nghiêm ngặt, đối xứng giữa No Demand và No Supply.
3. Phân biệt rõ dữ liệu không đủ, không có prior candidate, phản ứng không xác nhận và phản ứng đã xác nhận.
4. Chụp đúng Structure/Location tại thanh Candidate, không nhầm với thanh xác nhận.
5. Không dùng dữ liệu tương lai, không backfill, không tìm thanh xác nhận muộn và không repaint completed bars.
6. Không thay đổi bất kỳ output nào của Core, Candidate hoặc Structure/Location đã phát hành.
7. Không thêm trading signal, score, Event Wyckoff hoặc điều kiện context ẩn.

Kiểm tra tĩnh, mô hình tham chiếu độc lập và chạy AmiBroker thực là ba nguồn bằng chứng riêng. Không nguồn nào thay thế nguồn khác; case chưa chạy không được đánh dấu PASS.

## 2. Khóa nền và hồ sơ chạy

Trước và sau nghiệm thu, xác minh toàn bộ blob trong Mục 2 của đặc tả. Sai một blob là lỗi dừng. Ghi lại:

- Full commit SHA của Candidate/Structure nền và Confirmation đang thử.
- Phiên bản AmiBroker, Symbol, timeframe, nguồn/phiên bản dữ liệu và adjustment policy.
- Analysis range, số thanh thực nạp, tham số Core/Structure và thời điểm chạy.
- SHA-256 của fixture đầu vào, file Exploration xuất và file kỳ vọng.
- Trạng thái completed/incomplete của thanh cuối.

Chỉ dùng cơ sở dữ liệu thử nghiệm hoặc bản sao an toàn cho fixture sửa OHLCV. Không nhập đè dữ liệu giao dịch thật.

## 3. Mô hình tham chiếu và fixture trước AFL

Trước khi viết AFL, tạo reference model bằng ngôn ngữ khác AFL, thực hiện trực tiếp state machine của đặc tả. Model không được dịch từng dòng từ AFL và không được dùng output AFL làm expected value.

Các fixture tối thiểu:

- `CE_RESPONSE`: hai Candidate hợp lệ và mọi hướng Close phản ứng.
- `CE_INVALID`: prior code 0, code lỗi hợp đồng, Close Null/không dương và dependency độc lập.
- `CE_CONTEXT`: S/M/L ready/invalid/zero-width và các trạng thái pivot tại Candidate/confirmation bar.
- `CE_SEQUENCE`: Candidate liên tiếp, Candidate mới đồng thời với xác nhận prior Candidate và thất bại không được xét lại.
- `CE_CAUSALITY`: nhiều hậu tố khác nhau dùng chung một tiền tố.
- `CE_NATIVE_APPEND`: dữ liệu được nhập hai giai đoạn vào database AmiBroker tạm.
- `CE_REGRESSION`: lịch sử đủ dài để so sánh toàn bộ stack upstream.
- Một bộ dữ liệu thị trường thực đã cố định phiên bản, chỉ dùng sau khi fixture kiểm soát đạt.

Expected output phải chứa cả Null, state code, cờ, giá trị số, BarIndex và DateTime. Không dùng định dạng hiển thị đã làm tròn làm nguồn quyết định.

## 4. Kiểm tra tĩnh bắt buộc

### 4.1. Phạm vi và include

- Chỉ thêm AFL Confirmation, tài liệu và fixture/test liên quan đã phê duyệt.
- AFL dùng `#include_once <WyckoffVSA_StructureLocation_v1.0.afl>`.
- Không sửa hoặc sao chép công thức của ba lớp upstream.
- Mọi tên mới bắt đầu bằng `CE_`; không ghi đè biến upstream.
- Không có `Buy`, `Sell`, `Short`, `Cover`, `ApplyStop`, position sizing, backtest, alert hoặc scanner filter.
- Không có composite score, confidence, trend/phase/Event detector hoặc chart arrow.

### 4.2. Nhân quả

- Mọi tham chiếu mới đến Candidate/Structure của thanh trước chỉ có offset `-1`.
- Không có positive `Ref`, `Zig`, `Peak`, `Trough`, centered average hoặc future quotation.
- Không có ghi mảng về hàng Candidate và không có fallback sang `k+2` trở đi.
- Không có điều kiện phụ thuộc tổng số thanh tương lai.

### 4.3. Công thức khóa

Xác minh trực tiếp:

```text
NoDemandConfirmed = PriorNDCode == 2
                    AND ResponseCloseValid
                    AND Close_t < Close_(t-1)

NoSupplyConfirmed = PriorNSCode == 2
                    AND ResponseCloseValid
                    AND Close_t > Close_(t-1)
```

Không có `<=`, `>=`, epsilon, phá High/Low, Volume/RVOL, Spread, ATR, ClosePosition hoặc Location trong biểu thức xác nhận.

## 5. Ma trận phản ứng và state — CR01 đến CR20

| Mã | Trường hợp | Kỳ vọng bắt buộc |
|---|---|---|
| CR01 | Hàng đầu không có prior Candidate output | Pair/data invalid; hai StatusCode 0; tọa độ opportunity Null. |
| CR02 | Prior Candidate pair `(0,0)` | Hai StatusCode 0, không đổi thành `NO PRIOR CANDIDATE`. |
| CR03 | Prior pair `(1,1)`, current Close hợp lệ | Hai StatusCode 1; hai opportunity 0. |
| CR04 | Prior pair `(1,1)`, current Close lỗi | Hai StatusCode vẫn 1 vì không có opportunity cần đánh giá. |
| CR05 | Prior pair `(2,1)`, `C_t < C_k` | ND code 3/Confirmed1; NS code1. |
| CR06 | Prior pair `(2,1)`, `C_t = C_k` | ND code2/Confirmed0; ResponseDirection0. |
| CR07 | Prior pair `(2,1)`, `C_t > C_k` | ND code2/Confirmed0; ResponseDirection1. |
| CR08 | Prior pair `(1,2)`, `C_t > C_k` | NS code3/Confirmed1; ND code1. |
| CR09 | Prior pair `(1,2)`, `C_t = C_k` | NS code2/Confirmed0; ResponseDirection0. |
| CR10 | Prior pair `(1,2)`, `C_t < C_k` | NS code2/Confirmed0; ResponseDirection-1. |
| CR11 | ND opportunity, current Close Null | ND code0; opportunity1; EvaluationValid0; không tìm bar sau. |
| CR12 | ND opportunity, current Close bằng0, âm hoặc không hữu hạn | ND code0; ResponseCloseValid0. |
| CR13 | NS opportunity, current Close Null/không dương/không hữu hạn | NS code0; opportunity1; EvaluationValid0. |
| CR14 | Current High/Low lỗi nhưng CurrentCloseValid1 | Đánh giá theo Close vẫn hợp lệ; kết quả đúng hướng Close. |
| CR15 | Current Open hoặc Volume lỗi, Close hợp lệ | Không đổi kết quả Confirmation. |
| CR16 | Opportunity hợp lệ | Candidate index/time là `k`; Evaluation index/time là `k+1`; lag đúng1. |
| CR17 | Response hợp lệ | ResponseClose=`C_t`; Delta=`C_t-C_k`; Direction=-1/0/1 đúng dấu. |
| CR18 | Pair `(2,2)`, mixed-zero `(0,1)/(1,0)` hoặc code ngoài 0..2 | PairWellFormed0; hai StatusCode0; không ưu tiên một loại. |
| CR19 | Thanh `t` vừa xác nhận prior Candidate vừa là Candidate mới | Xác nhận prior xuất tại t; Candidate mới tại t vẫn `UNCONFIRMED`. |
| CR20 | Candidate ND rồi NS liên tiếp hoặc ngược lại | Mỗi Candidate chỉ được đánh giá ở hàng kế tiếp; hai luồng không ghi đè nhau. |

### 5.1. Bảng ranh giới Close tối thiểu

Với `C_k=100`:

| `C_t` | ResponseDirection | ND code | NS code khi loại tương ứng là opportunity |
|---:|---:|---:|---:|
| `99.999999` | -1 | 3 | 2 |
| `100.000000` | 0 | 2 | 2 |
| `100.000001` | 1 | 2 | 3 |

Phân loại dùng số nguồn, không dùng số đã làm tròn để hiển thị. Dung sai chỉ được dùng khi đối chiếu Delta số thực, không được dùng trong điều kiện code.

## 6. Ma trận context snapshot — CX01 đến CX10

| Mã | Trường hợp | Kỳ vọng bắt buộc |
|---|---|---|
| CX01 | Candidate tại k có ba vùng S/M/L sẵn sàng | Snapshot tại k+1 khớp tuyệt đối ReferenceStatus, Position, LocationValid/Location của k. |
| CX02 | Structure tại confirmation bar khác mạnh với Candidate bar | Snapshot vẫn là giá trị k, không lấy giá trị hiện tại k+1. |
| CX03 | Một vùng Candidate zero-width | Giữ đúng status/position zero-width và Location Null; Confirmation code không đổi. |
| CX04 | S hợp lệ, M lỗi dữ liệu, L thiếu lịch sử | Ba nhóm giữ độc lập; không thay vùng lỗi bằng vùng khác. |
| CX05 | Không có opportunity | ContextSnapshotPresent0; kind/index/time và giá trị context dành cho opportunity là Null. |
| CX06 | Latest pivot High đã tồn tại ở cuối k | Snapshot giữ đúng valid, price, extreme và confirm coordinates. |
| CX07 | Latest pivot Low đã tồn tại ở cuối k | Snapshot giữ đúng valid, price, extreme và confirm coordinates. |
| CX08 | Pivot mới chỉ xác nhận ở k+1 | Không xuất hiện trong snapshot của Candidate k. |
| CX09 | Chưa có pivot ở k | LatestValid0; giá và tọa độ pivot Null, không dùng 0 giả. |
| CX10 | Context hoàn toàn lỗi nhưng Close response hợp lệ | Confirmation vẫn code2/3 theo Close; không có context gate ẩn. |

Đối chiếu snapshot theo đúng row key Symbol/DateTime/BarIndex. Không chỉ so sánh số Location; phải so sánh cả validity, state code và Null.

## 7. Ma trận thời gian và nhân quả — CA01 đến CA08

| Mã | Trường hợp | Kỳ vọng bắt buộc |
|---|---|---|
| CA01 | Giữ dữ liệu đến t, thay toàn bộ hậu tố từ t+1 | Mọi output đến hết t giống tuyệt đối. |
| CA02 | Chạy tiền tố kết thúc ở t rồi nối thêm dữ liệu thật | Completed rows đến t không đổi nếu dữ liệu nguồn cũ không đổi. |
| CA03 | Candidate ở k được xác nhận tại k+1 | Không cột Confirmation nào được viết code3 ngược vào hàng k. |
| CA04 | ND không được xác nhận ở k+1 nhưng giảm ở k+2 | ND tại k vẫn code2 ở k+1; không sinh xác nhận muộn ở k+2. |
| CA05 | NS không được xác nhận ở k+1 nhưng tăng ở k+2 | Tương tự, không xác nhận muộn. |
| CA06 | Close k+1 lỗi, Close k+2 hợp lệ đúng hướng | k+1 code0; k+2 không được thay thế thanh đánh giá. |
| CA07 | Thay Close của bar cuối đang hình thành | Output ở bar cuối có thể đổi và phải được ghi là provisional; completed prefix không đổi. |
| CA08 | Sửa OHLCV lịch sử tại hoặc trước k | Output phụ thuộc được phép đổi; hồ sơ phải phân biệt source revision với algorithmic repaint. |

### 7.1. Kiểm thử append thật trong AmiBroker

Tạo database tạm và Symbol riêng. Nhập P thanh, chạy/xuất; sau đó chỉ nhập Q thanh có ngày tiếp nối, xác nhận BarCount thật tăng và chạy lại cùng công thức/tham số. So sánh toàn bộ P hàng cũ, gồm upstream và CE, theo khóa nguồn. Không giả lập append bằng cách thay `Filter`, cắt file xuất hoặc dùng AFL che các thanh cuối.

## 8. Ma trận tích hợp và runtime — RG01 đến RG08

| Mã | Trường hợp | Kỳ vọng bắt buộc |
|---|---|---|
| RG01 | Git identity | Toàn bộ blob nền khớp Mục 2 đặc tả trước/sau test. |
| RG02 | Phạm vi diff | Chỉ có Confirmation AFL và tài liệu/fixture/test đã phê duyệt; upstream diff bằng0. |
| RG03 | Include chain | AmiBroker tìm thấy Structure -> Candidate -> Core đúng bản phát hành, không include lặp. |
| RG04 | Hồi quy upstream | Mọi tên/value/Null/text của Core, Candidate, Structure khớp baseline trên mọi hàng. |
| RG05 | State text | Code 0/1/2/3 khớp đúng ASCII text theo từng historical row. |
| RG06 | Formula Verify và Exploration | Không lỗi cú pháp/runtime trên AmiBroker 6.20.01; chạy được cả fixture ngắn/dài. |
| RG07 | Filter/chart | `Filter=1` không bị biến thành scanner; chart không có marker/màu giao dịch mới. |
| RG08 | Forbidden scope | Quét tĩnh không có trading rule, score, event/phase detector hoặc hàm nhìn tương lai. |

Yêu cầu hồi quy tuyệt đối:

```text
CORE_CHANGED_COLUMNS      = 0
CORE_CHANGED_CELLS        = 0
CANDIDATE_CHANGED_COLUMNS = 0
CANDIDATE_CHANGED_CELLS   = 0
STRUCTURE_CHANGED_COLUMNS = 0
STRUCTURE_CHANGED_CELLS   = 0
```

Null phải khớp Null, DateTime/BarIndex phải khớp tuyệt đối và text phải khớp theo code; không chỉ so sánh ô có số.

## 9. Tổ chức batch để giảm số lần chạy AmiBroker

46 case chính thức được đóng gói để người nghiệm thu không phải chạy từng case riêng:

| Batch | Nội dung | Case | Số lần chạy AmiBroker dự kiến |
|---|---|---:|---:|
| `CE_BATCH_A_RESPONSE` | State, hướng, equality, invalid Close, tọa độ | CR01–CR17; phần có thể tạo tự nhiên của CR18 | 1 |
| `CE_BATCH_B_SEQUENCE_CONTEXT` | Candidate liên tiếp và context snapshot | CR19–CR20, CX01–CX10 | 1 |
| `CE_BATCH_C_CAUSALITY_PREFIX` | Hậu tố A/B, no-backfill, no-late-fallback | CA01, CA03–CA08 | 2 |
| `CE_BATCH_D_NATIVE_APPEND` | Import P rồi P+Q trong database tạm | CA02 | 2 |
| `CE_BATCH_E_REGRESSION` | Compile, Exploration, upstream regression, lịch sử dài | RG01–RG08 | 1 |

Mục tiêu là **7 lượt chạy AmiBroker có ghi bằng chứng**, không phải 46 lượt. Các trạng thái CR18 không thể sinh từ Candidate đã phát hành, như `(2,2)` hoặc mixed-validity, được kiểm tra bằng reference model và kiểm tra tĩnh/isolated state-machine harness; không sửa upstream chỉ để tạo lỗi. Các kiểm tra Git/static/reference-model chạy tự động ngoài AmiBroker và được tổng hợp vào cùng báo cáo. Nếu một batch lỗi, chỉ tách nhỏ batch đó để chẩn đoán; không thay đổi expected value.

Mỗi hàng fixture có `CaseID`, `Expected...` và cột actual tương ứng để một Exploration tạo bằng chứng cho nhiều case. Case chỉ PASS khi tất cả assertion thuộc CaseID đều đạt.

## 10. Độ chính xác và đối chiếu

- State code, cờ, Null, text, BarIndex và DateTime: khớp tuyệt đối.
- Điều kiện `<`, `>`, `==`: dùng giá trị nguồn, không dung sai.
- ResponseDelta/context Location: dung sai đối chiếu đề xuất `abs(a-b) <= max(1e-7, 1e-6*max(abs(a),abs(b)))`, phải hiệu chuẩn trước khi khóa fixture.
- Dung sai không được đi vào công thức phân loại.
- Infinity/NaN không được coi là số hợp lệ.

Nếu cần nới dung sai, phải điều tra nguyên nhân và phê duyệt trong hồ sơ thử; không tự điều chỉnh để làm case PASS.

## 11. Đối chiếu dữ liệu thị trường thực

Chỉ thực hiện sau khi toàn bộ controlled fixtures đạt:

1. Chọn nhiều Symbol/giai đoạn nhưng cố định nguồn và phiên bản dữ liệu.
2. Đánh dấu Candidate tại k mà chưa xem k+1.
3. Kiểm tra engine chỉ ghi code2/3 tại k+1 và snapshot context đúng k.
4. Ghi riêng quan sát về bối cảnh và diễn biến nhiều thanh; không dùng chúng để sửa expected code một thanh.
5. Không đánh giá lợi nhuận hoặc entry/exit trong nghiệm thu Confirmation.

Một trường hợp “VSA thực tế” có vẻ mạnh/yếu nhưng khác định nghĩa hẹp không tự động là lỗi. Mở rộng phải qua đặc tả phiên bản mới.

## 12. Tiêu chí kết thúc

Bản triển khai chỉ được đề nghị hợp nhất khi:

- CR01–CR20, CX01–CX10, CA01–CA08 và RG01–RG08 đều PASS.
- Mô hình tham chiếu và AmiBroker thống nhất.
- Kiểm tra no-lookahead, no-backfill, append và incomplete-bar đạt.
- Hồi quy cả ba lớp upstream có 0 cột và 0 ô thay đổi.
- Git blobs nền khớp tuyệt đối.
- Không có trading signal, context gate, score hoặc scope ngoài đặc tả.
- Pull request chỉ chứa đúng tệp đã phê duyệt và không tự động merge.

## 13. Mẫu biên bản nghiệm thu

```text
CONFIRMATION ENGINE v1.0

AmiBroker Version:
Confirmation Commit:
Base Commit: 7c2b8cfb4d729c5b1b631f3860e43a46fc2f6f23
Core Tag: core-v1.0.0
Candidate Tag: candidate-v1.0.0
Structure Tag: structure-location-v1.0.0

Git Identity Lock:
Static Checks:
Reference Model Checks:
CR Matrix: __ / 20 PASS
CX Matrix: __ / 10 PASS
CA Matrix: __ / 8 PASS
RG Matrix: __ / 8 PASS
AmiBroker Runs: __ / 7 PASS

Core Changed Columns/Cells:
Candidate Changed Columns/Cells:
Structure Changed Columns/Cells:
No-lookahead / No-backfill:
Native Append:
Completed-bar Handling:

NO DEMAND CONFIRMATION = PASS / FAIL / BLOCKED
NO SUPPLY CONFIRMATION = PASS / FAIL / BLOCKED
CONTEXT SNAPSHOT       = PASS / FAIL / BLOCKED
UPSTREAM REGRESSION    = PASS / FAIL / BLOCKED
OVERALL                = PASS / FAIL / BLOCKED
```
