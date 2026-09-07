# VSA Candidate Engine v1.0 — Kế hoạch kiểm thử

**Trạng thái:** Dự thảo để con người phê duyệt

**Đặc tả đích:** `docs/vsa-candidate-engine-v1.0-spec.md`

**Nền chuẩn:** thẻ `core-v1.0.0`, commit `595f52d4adaec9b4f21d12f6a00b52b3d5f71aed`

**Môi trường tối thiểu:** AmiBroker 6.20+

## 1. Mục tiêu nghiệm thu

Chứng minh bản triển khai tương lai:

1. Nhận diện đúng hai biến thể cơ bản dựa trên giá đóng cửa so với thanh trước của No Demand Candidate và No Supply Candidate.
2. Phân biệt rõ `INSUFFICIENT DATA`, `NOT PRESENT` và `BASIC CANDIDATE — UNCONFIRMED`.
3. Không dùng dữ liệu tương lai và không sửa lại lịch sử.
4. Không thay đổi bất kỳ công thức hoặc đầu ra nào của Core Engine v1.0.0.
5. Không tạo tín hiệu giao dịch, điểm số, bối cảnh hoặc xác nhận ngầm.

Một cách diễn giải VSA nằm ngoài định nghĩa hẹp của đặc tả không được tính là lỗi âm tính giả của v1.0. Mọi mở rộng biến thể phải đi qua đặc tả và phiên bản mới.

Kiểm tra tĩnh không thay thế biên dịch và chạy thực tế trong AmiBroker.

## 2. Điều kiện trước khi chạy

- Dùng đúng `afl/WyckoffVSA_Core_v1.0.afl` từ thẻ `core-v1.0.0`.
- Đặt Core AFL trong thư mục dùng chung tiêu chuẩn của AmiBroker.
- Dùng thanh hoàn tất cho toàn bộ bộ dữ liệu nghiệm thu.
- Ghi lại phiên bản AmiBroker, mã bộ dữ liệu, khoảng Analysis và mọi tham số Core.
- Không dùng dữ liệu đã điều chỉnh và chưa điều chỉnh lẫn lộn trong cùng bộ dữ liệu.

## 3. Kiểm tra danh tính Core

Trước và sau mọi lần nghiệm thu, xác minh:

```text
afl/WyckoffVSA_Core_v1.0.afl
  c03a9599a246849d562ea162975f202781049f90

docs/core-engine-v1.0-spec.md
  6788874973cbc6a117037a6865f7db2a173efeb2

docs/robust-atr-correction-v1.0.md
  7f8ac6d7cc391044d578a5e35c92799373110501
```

Sai khác ở bất kỳ blob nào là lỗi dừng nghiệm thu.

## 4. Kiểm tra tĩnh bắt buộc

### 4.1. Phạm vi

- Bản triển khai chỉ thêm tệp Candidate và tài liệu liên quan đã phê duyệt.
- Không sửa ba tệp Core được khóa.
- Không có `Buy`, `Sell`, `Short`, `Cover`, position sizing, stop-loss hoặc backtest rule.
- Không có composite score, confidence, bullish/bearish rank hoặc candidate count.
- Không có Spring, Shakeout, Upthrust, UTAD, SOS, LPS, phase hoặc Trading Range detector.
- Không thêm chart arrow, `PlotShapes()` hoặc màu nền hàm ý giao dịch.

### 4.2. Nhân quả

- Mọi `Ref()` mới chỉ có `-1` hoặc `-2`.
- Không có positive `Ref`, `Zig`, `Peak`, `Trough` hoặc centered average.
- Không có phép tính dùng thanh sau để sửa kết quả thanh ứng viên.

### 4.3. Công thức khóa

Xác minh trực tiếp:

```text
UpBarByClose   = CandidateDirectionValid AND Close > PreviousClose
DownBarByClose = CandidateDirectionValid AND Close < PreviousClose

VolumeBelowPriorTwo = PriorTwoVolumeValid
                      AND Volume < PriorVolume1
                      AND Volume < PriorVolume2

NarrowSpread = RSpreadValid AND RSpread < 0.80
```

Bản triển khai phải dùng mặt nạ số 0/1 tường minh và toán hạng an toàn để `Null` không lan truyền vào các điều kiện thành phần. Toán hạng an toàn không được thay đổi trạng thái hợp lệ. Không được đổi `<` thành `<=`.

## 5. Cột kiểm toán bắt buộc

Exploration phải cho phép nhìn thấy ít nhất:

- Close hiện tại và PreviousClose.
- `Candidate Direction Valid`, `Up Bar By Close`, `Down Bar By Close`, `Flat Bar By Close`.
- Volume hiện tại, `Prior Volume 1`, `Prior Volume 2` và ba validity tương ứng.
- `Volume Below Prior Two`.
- `RSpread`, `RSpread State Code`, `Narrow Spread`.
- `Candidate Input Valid`.
- Validity, code và text riêng của hai ứng viên.
- `RVOL`, `ClosePosition`, `DirectionalProgress` và Effort/Result state của Core.

Mọi văn bản lịch sử phải khớp mã số trên cùng hàng.

## 6. Ma trận kiểm thử chức năng

Mỗi case phải ghi input tối thiểu, output thực tế, output mong đợi và trạng thái đạt/không đạt.

| # | Trường hợp | Thiết lập chính | Kết quả mong đợi |
|---:|---|---|---|
| 1 | No Demand cơ bản | Close tăng; Volume nhỏ hơn cả hai thanh trước; `RSpread < 0.80` | ND code 2; NS code 1 |
| 2 | No Supply cơ bản | Close giảm; Volume nhỏ hơn cả hai thanh trước; `RSpread < 0.80` | NS code 2; ND code 1 |
| 3 | Giá đi ngang | Close bằng PreviousClose; volume/spread đạt | Cả hai code 1 |
| 4 | Volume bằng Prior 1 | Volume bằng thanh trước và nhỏ hơn Prior 2 | Cả hai không xuất hiện |
| 5 | Volume bằng Prior 2 | Volume bằng thanh thứ hai và nhỏ hơn Prior 1 | Cả hai không xuất hiện |
| 6 | Volume lớn hơn một prior | Chỉ nhỏ hơn một trong hai thanh trước | Cả hai không xuất hiện |
| 7 | RSpread ngay dưới 0.80 | Các điều kiện khác đạt | Ứng viên theo hướng có thể xuất hiện |
| 8 | RSpread đúng 0.80 | Các điều kiện khác đạt | `NarrowSpread = 0`; không có ứng viên |
| 9 | RSpread trên 0.80 | Các điều kiện khác đạt | Không có ứng viên |
| 10 | Chưa đủ warm-up spread | `RSpreadValid = 0` | Cả hai code 0 |
| 11 | Current Close Null | Giá/volume khác tùy ý | Cả hai code 0 |
| 12 | PreviousClose Null/không dương | Current data hợp lệ | Cả hai code 0 |
| 13 | High hoặc Low Null | Close và Volume có dữ liệu | Cả hai code 0 |
| 14 | High thấp hơn Low | Các trường khác có dữ liệu | Cả hai code 0 |
| 15 | Close ngoài `[Low, High]` | High/Low hợp lệ | Cả hai code 0 |
| 16 | Current Volume Null/âm | Price và spread hợp lệ | Cả hai code 0 |
| 17 | Prior Volume 1 Null/âm | Current và Prior 2 hợp lệ | Cả hai code 0 |
| 18 | Prior Volume 2 Null/âm | Current và Prior 1 hợp lệ | Cả hai code 0 |
| 19 | Current Volume bằng 0 | Hai prior volume dương; điều kiện khác đạt | `VolumeBelowPriorTwo = 1`; ứng viên theo hướng có thể xuất hiện |
| 20 | Một prior volume bằng 0 | Current volume không âm | So sánh nghiêm ngặt không thể thấp hơn prior 0; không có ứng viên |
| 21 | Zero-range có gap | Core cho `RSpread = 0`; direction và volume đạt | Zero-range không tự động bị loại; ứng viên theo hướng có thể xuất hiện |
| 22 | RVOL không LOW | Quan hệ hai prior và spread vẫn đạt | Ứng viên không bị RVOL chặn; hiển thị RVOL để con người đánh giá |
| 23 | ClosePosition không ủng hộ trực giác | Điều kiện ứng viên vẫn đạt | Ứng viên không bị ClosePosition chặn; hiển thị vị trí đóng cửa |
| 24 | PriorATR chưa hợp lệ | Direction, volume và RSpread hợp lệ | Candidate vẫn hợp lệ; DirectionalProgress có thể Null |
| 25 | ND/NS loại trừ nhau | Quét toàn bộ dữ liệu hợp lệ | Không hàng nào có cả ND và NS code 2 |
| 26 | Mã/văn bản | Tạo đủ trạng thái không hợp lệ, không xuất hiện và ứng viên | 0/1/2 khớp đúng văn bản trên từng hàng |

## 7. Kiểm tra ranh giới chính xác

### 7.1. RSpread

| Giá trị | NarrowSpread |
|---:|---:|
| 0.000000 | 1 nếu Core validity đúng |
| 0.599999 | 1 |
| 0.600000 | 1 |
| 0.799999 | 1 |
| 0.800000 | 0 |
| 0.800001 | 0 |

### 7.2. Hướng theo Close

| Quan hệ | Up | Down | Flat |
|---|---:|---:|---:|
| `Close > PreviousClose` | 1 | 0 | 0 |
| `Close < PreviousClose` | 0 | 1 | 0 |
| `Close == PreviousClose` | 0 | 0 | 1 |

### 7.3. Volume

Với Prior 1 = 100 và Prior 2 = 120:

| Current Volume | VolumeBelowPriorTwo |
|---:|---:|
| 99 | 1 |
| 100 | 0 |
| 110 | 0 |
| 120 | 0 |

## 8. Kiểm tra tính nhân quả và không sửa lịch sử

### Kịch bản A — thay tương lai

1. Chạy bộ dữ liệu gốc và lưu toàn bộ đầu ra đến thanh kiểm toán `t`.
2. Thay mạnh OHLCV từ `t+1` trở đi.
3. Chạy lại cùng tham số.
4. Mọi thành phần đầu vào, trạng thái hợp lệ, mã và văn bản tại `t` phải giống tuyệt đối.

### Kịch bản B — nối thêm dữ liệu

1. Chạy bộ dữ liệu kết thúc tại `t` như một thanh hoàn tất.
2. Nối thêm nhiều thanh mới.
3. Output lịch sử đến `t` phải giống tuyệt đối.

### Kịch bản C — thanh mới nhất đang hình thành

Thay OHLCV của thanh cuối và xác nhận đầu ra có thể thay đổi. Ghi rõ đây là kết quả tạm thời, không coi là sửa lại thanh đã hoàn tất.

## 9. Hồi quy Core Engine

Chạy Core độc lập và Candidate có include Core trên cùng:

- Mã chứng khoán/bộ dữ liệu.
- Khoảng Analysis.
- Tất cả tham số.
- Dữ liệu đầu vào.

So sánh mọi cột Core trên mọi hàng. Yêu cầu:

```text
CORE_CHANGED_COLUMNS = 0
CORE_CHANGED_CELLS   = 0
```

Các giá trị Null phải khớp Null; không chỉ so sánh các ô có số.

## 10. Kiểm tra biên dịch và Exploration trong AmiBroker

Ghi nhận:

- Phiên bản AmiBroker chính xác.
- `#include_once` tìm thấy đúng Core AFL.
- Formula Verify/Apply không có lỗi cú pháp.
- Exploration chạy xong không có lỗi khi thực thi.
- Mã số và văn bản thay đổi đúng theo từng hàng lịch sử.
- `Filter = 1` không bị đổi thành bộ quét ứng viên.
- Chart vẫn là đầu ra Core, không có mũi tên hoặc màu nền mới.

## 11. Đối chiếu biểu đồ thực tế

Sau khi controlled fixtures đạt:

1. Chọn nhiều mã và nhiều giai đoạn thị trường khác nhau.
2. Đánh dấu thủ công thanh Candidate trước khi xem diễn biến sau.
3. Ghi riêng bối cảnh, vị trí và phản ứng tiếp diễn; không đưa chúng ngược vào nhãn Candidate.
4. Ghi nhận dương tính giả/âm tính giả theo đúng định nghĩa đã khóa; tách riêng trường hợp nằm ngoài phạm vi biến thể cơ bản.
5. Không sửa công thức chỉ để khớp một vài biểu đồ riêng lẻ.

Đối chiếu thực tế dùng để đánh giá khả năng sử dụng và chuẩn bị đặc tả tầng sau, không biến Candidate Engine thành mô hình dự báo.

## 12. Điều kiện đạt cuối cùng

Bản triển khai chỉ được đề nghị hợp nhất khi:

- Tất cả kiểm tra tĩnh đạt.
- Tất cả case trong ma trận đạt.
- Ranh giới chính xác đạt.
- No-lookahead và completed-bar tests đạt.
- Core regression có 0 cột và 0 ô thay đổi.
- AmiBroker 6.20+ biên dịch và chạy Exploration đạt.
- Ba Git blob Core khớp tuyệt đối.
- Yêu cầu hợp nhất chỉ chứa Candidate Engine và tài liệu liên quan.
- Không tự động hợp nhất.

## 13. Mẫu biên bản nghiệm thu

```text
VSA CANDIDATE ENGINE v1.0

AmiBroker Version:
Candidate Commit:
Core Tag: core-v1.0.0
Core Commit: 595f52d4adaec9b4f21d12f6a00b52b3d5f71aed

Static Checks:
Functional Matrix: __ / 26 PASS
Boundary Tests:
Causality Tests:
Completed-Bar Tests:
Core Changed Columns:
Core Changed Cells:
Core Blob Identity:

NO DEMAND CANDIDATE = PASS / FAIL
NO SUPPLY CANDIDATE = PASS / FAIL
CORE REGRESSION      = PASS / FAIL
OVERALL              = PASS / FAIL
```
