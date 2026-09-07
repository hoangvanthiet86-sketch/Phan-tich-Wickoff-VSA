# VSA Candidate Engine v1.0 — Đặc tả

**Trạng thái:** Dự thảo để con người phê duyệt

**Nền chuẩn:** `core-v1.0.0`

**Commit nền:** `595f52d4adaec9b4f21d12f6a00b52b3d5f71aed`

**Môi trường tối thiểu:** AmiBroker 6.20+

## 1. Mục đích

VSA Candidate Engine v1.0 nhận diện hai biến thể cơ bản, được định nghĩa hẹp, của cấu hình giá–khối lượng cục bộ có thể là ứng viên No Demand hoặc No Supply. Engine chỉ trả lời:

> Thanh hiện tại có thỏa cấu hình cục bộ đã định nghĩa hay không?

Engine không kết luận cung hoặc cầu thực sự đã thắng, không đánh giá bối cảnh, không xác nhận diễn biến sau đó và không đưa ra hành động giao dịch.

Luồng kiến trúc bắt buộc:

```text
Core Engine -> VSA Candidate Engine -> Structure / Location -> Confirmation -> lớp sử dụng về sau
```

Mọi lớp phía sau vẫn chưa được triển khai trong phiên bản này.

## 2. Nguyên tắc bất biến

1. Core Engine v1.0.0 là nguồn số đo khách quan và phải được giữ nguyên.
2. Candidate Engine chỉ nhận diện ứng viên, không đổi tên ứng viên thành tín hiệu đã xác nhận.
3. Bối cảnh quan trọng hơn một thanh riêng lẻ; Candidate Engine không được suy đoán bối cảnh.
4. Không dùng dữ liệu tương lai, không sửa lại lịch sử và không gán xác nhận ngược về thanh ứng viên.
5. Dữ liệu không hợp lệ phải tạo trạng thái `INSUFFICIENT DATA`, không được coi là `NOT PRESENT`.
6. Không có điểm số tổng hợp, mức tin cậy, xếp hạng tăng/giảm, `Buy`, `Sell`, lệnh giao dịch hoặc kiểm thử giao dịch.
7. Kết quả trên thanh đang hình thành là tạm thời; chỉ thanh hoàn tất mới có kết quả cuối cùng.

## 3. Phạm vi v1.0

### Bao gồm

- No Demand Candidate cục bộ.
- No Supply Candidate cục bộ.
- Các điều kiện thành phần và trạng thái hợp lệ để kiểm toán.
- Các số đo Core đặt cạnh kết quả ứng viên để con người diễn giải.

### Không bao gồm

- Spring, Shakeout, Upthrust, UTAD.
- Selling Climax, Buying Climax, Stopping Volume hoặc Absorption.
- SOS, LPS, Breakout, Retest hoặc Test.
- Hỗ trợ, kháng cự, Trading Range, pha Wyckoff hoặc xu hướng.
- Sức mạnh/suy yếu trong bối cảnh và phản ứng của các thanh sau.
- Market Scanner, cảnh báo, quản trị vị thế hoặc quản trị rủi ro.
- Mọi biến thể No Demand/No Supply nằm ngoài định nghĩa cơ bản dựa trên giá đóng cửa so với thanh trước tại Mục 6.

Các khái niệm trên cần Structure / Location, Confirmation Engine hoặc một phiên bản đặc tả mới và không được đưa lén vào điều kiện v1.0. Một thanh được tài liệu hoặc người phân tích VSA khác diễn giải là No Demand/No Supply nhưng không thỏa định nghĩa hẹp tại Mục 6 không tự động tạo thành lỗi của v1.0.

## 4. Hợp đồng đầu vào

Candidate Engine được phép sử dụng:

### Từ dữ liệu OHLCV hiện tại và quá khứ

- `High`, `Low`, `Close`, `Volume` tại thanh hiện tại.
- `Close` tại thanh trước.
- `Volume` tại hai thanh trước.

`Open` không tham gia định nghĩa v1.0.

### Từ Core Engine v1.0.0

- `PriceInputValid`
- `CurrentCloseValid`
- `PreviousCloseValid`
- `CurrentVolumeValid`
- `RSpreadValid`, `RSpread`, `RSpreadStateCode`
- `RVOLValid`, `RVOL`, `RVOLStateCode`
- `ClosePositionValid`, `ClosePosition`, `CloseStateCode`
- `DirectionalProgressValid`, `DirectionalProgress`
- `EffortDirectionalResultValid`, `EffortDirectionalResultStateCode`

Candidate Engine không được tính lại hoặc thay thế bất kỳ số đo nào đã thuộc Core.

## 5. Các điều kiện thành phần

### 5.1. Hướng cục bộ theo giá đóng cửa

```text
CandidateDirectionValid = CurrentCloseValid AND PreviousCloseValid
UpBarByClose             = IIf(CandidateDirectionValid, IIf(Close > PreviousClose, 1, 0), 0)
DownBarByClose           = IIf(CandidateDirectionValid, IIf(Close < PreviousClose, 1, 0), 0)
FlatBarByClose           = IIf(CandidateDirectionValid, IIf(Close == PreviousClose, 1, 0), 0)
```

Hướng được xác định bằng giá đóng cửa so với thanh trước, không dùng màu nến và không phụ thuộc `Open`. Candidate Engine không dùng dấu của `DirectionalProgress` để tránh làm hướng cục bộ phụ thuộc vào trạng thái khởi tạo hoặc phục hồi ATR.

### 5.2. Khối lượng so với hai thanh trước

```text
PriorVolume1      = Ref(Volume, -1)
PriorVolume2      = Ref(Volume, -2)
PriorVolume1Valid = IIf(IsNull(PriorVolume1), 0, IIf(PriorVolume1 >= 0, 1, 0))
PriorVolume2Valid = IIf(IsNull(PriorVolume2), 0, IIf(PriorVolume2 >= 0, 1, 0))

PriorTwoVolumeValid = CurrentVolumeValid
                      AND PriorVolume1Valid
                      AND PriorVolume2Valid

SafeCurrentVolume = IIf(CurrentVolumeValid, Volume, 0)
SafePriorVolume1  = IIf(PriorVolume1Valid, PriorVolume1, 0)
SafePriorVolume2  = IIf(PriorVolume2Valid, PriorVolume2, 0)

VolumeBelowPriorTwo = IIf(PriorTwoVolumeValid,
                          IIf(SafeCurrentVolume < SafePriorVolume1
                              AND SafeCurrentVolume < SafePriorVolume2, 1, 0),
                          0)
```

So sánh là nghiêm ngặt. Khối lượng bằng một trong hai thanh trước không đạt điều kiện. Khối lượng bằng 0 là quan sát hợp lệ theo Core; nó có thể đạt điều kiện nếu cả hai khối lượng trước đều lớn hơn 0. Các biến `Safe...` chỉ ngăn `Null` lan truyền trong phép tính; chúng không làm một điều kiện phụ thuộc bị lỗi trở thành hợp lệ.

### 5.3. Biên độ hẹp

```text
SafeRSpread = IIf(RSpreadValid, RSpread, 1)
NarrowSpread = IIf(RSpreadValid, IIf(SafeRSpread < 0.80, 1, 0), 0)
```

Điều kiện dùng nguyên ranh giới mô tả đã khóa của Core:

- `RSpread < 0.60`: `VERY NARROW`.
- `0.60 <= RSpread < 0.80`: `NARROW`.
- `RSpread == 0.80`: `NORMAL`, không đạt `NarrowSpread`.

Thanh có biên độ bằng 0 vẫn là quan sát hợp lệ nếu baseline spread của Core hợp lệ và dương. v1.0 không thêm ngoại lệ riêng cho thanh zero-range.

### 5.4. Điều kiện hợp lệ chung

```text
CandidateInputValid = PriceInputValid
                      AND PreviousCloseValid
                      AND PriorTwoVolumeValid
                      AND RSpreadValid
```

`PriceInputValid` bảo đảm `High`, `Low`, `Close` của thanh hiện tại nhất quán. `PriorATRValid` không phải điều kiện phụ thuộc của Candidate Engine.

## 6. Định nghĩa ứng viên

### 6.1. No Demand Candidate

```text
NoDemandCandidateValid = CandidateInputValid

NoDemandCandidate = IIf(NoDemandCandidateValid,
                        IIf(UpBarByClose
                            AND VolumeBelowPriorTwo
                            AND NarrowSpread, 1, 0),
                        0)
```

Đây là biến thể cơ bản: một thanh tăng theo giá đóng cửa, có biên độ tương đối hẹp và khối lượng nhỏ hơn cả hai thanh trước. Tên đầy đủ trên giao diện phải chứa từ `BASIC CANDIDATE` và `UNCONFIRMED`.

### 6.2. No Supply Candidate

```text
NoSupplyCandidateValid = CandidateInputValid

NoSupplyCandidate = IIf(NoSupplyCandidateValid,
                        IIf(DownBarByClose
                            AND VolumeBelowPriorTwo
                            AND NarrowSpread, 1, 0),
                        0)
```

Đây là biến thể cơ bản: một thanh giảm theo giá đóng cửa, có biên độ tương đối hẹp và khối lượng nhỏ hơn cả hai thanh trước. Tên đầy đủ trên giao diện phải chứa từ `BASIC CANDIDATE` và `UNCONFIRMED`.

### 6.3. Thanh đi ngang

`FlatBarByClose` không thể là No Demand Candidate hoặc No Supply Candidate trong v1.0.

### 6.4. Tính độc lập và loại trừ

Hai ứng viên được xuất thành hai trạng thái độc lập để kiến trúc có thể mở rộng về sau. Tuy nhiên, trong v1.0 chúng không thể đồng thời đúng vì `UpBarByClose` và `DownBarByClose` loại trừ nhau.

Không tạo mã loại ứng viên chung và không tạo tổng số ứng viên.

## 7. Dữ liệu hỗ trợ, không phải điều kiện chặn

Các số đo sau phải được hiển thị cạnh ứng viên để kiểm toán và diễn giải, nhưng không tham gia điều kiện đúng/sai của v1.0:

- `RVOL` và `RVOLStateCode`.
- `ClosePosition` và `CloseStateCode`.
- `DirectionalProgress` khi hợp lệ.
- `EffortDirectionalResultStateCode` khi hợp lệ.

Lý do: khối lượng thấp hơn hai thanh trước và RVOL thấp là hai phép so sánh khác nhau. Vị trí đóng cửa cũng mang thông tin quan trọng nhưng chưa có ranh giới VSA phổ quát được phê duyệt làm điều kiện bắt buộc. Candidate Engine phải hiển thị sự đồng thuận hoặc mâu thuẫn giữa các số đo thay vì che giấu chúng bằng một điểm số.

## 8. Mã trạng thái và văn bản

Mỗi ứng viên có mã riêng:

| Mã | Điều kiện | Văn bản |
|---:|---|---|
| 0 | Điều kiện phụ thuộc không hợp lệ | `INSUFFICIENT DATA` |
| 1 | Điều kiện phụ thuộc hợp lệ, ứng viên không xuất hiện | `NOT PRESENT` |
| 2 | Điều kiện phụ thuộc hợp lệ, ứng viên xuất hiện | `BASIC CANDIDATE — UNCONFIRMED` |

Mã được tạo theo thứ tự ưu tiên:

```text
Code = if NOT CandidateValid then 0
       else if Candidate then 2
       else 1
```

Văn bản lịch sử phải dùng `AddMultiTextColumn()` để thay đổi đúng theo từng thanh. `WriteIf()` không được dùng để tạo phân loại cho nhiều hàng lịch sử.

## 9. Đầu ra Exploration

Ngoài các cột Core hiện hữu, Candidate Engine phải thêm ít nhất:

1. `Candidate Direction Valid`
2. `Up Bar By Close`
3. `Down Bar By Close`
4. `Flat Bar By Close`
5. `Prior Volume 1`
6. `Prior Volume 1 Valid`
7. `Prior Volume 2`
8. `Prior Volume 2 Valid`
9. `Prior Two Volume Valid`
10. `Volume Below Prior Two`
11. `Narrow Spread`
12. `Candidate Input Valid`
13. `No Demand Candidate Valid`
14. `No Demand Candidate Code`
15. `No Demand Candidate`
16. `No Supply Candidate Valid`
17. `No Supply Candidate Code`
18. `No Supply Candidate`

`Filter = 1` tiếp tục phục vụ kiểm toán toàn bộ phạm vi Analysis. Candidate Engine không biến Exploration thành Market Scanner.

## 10. Đầu ra biểu đồ

v1.0 không thêm:

- Mũi tên hoặc biểu tượng mua/bán.
- Màu nền hàm ý tăng/giảm.
- Dòng chữ khẳng định No Demand hoặc No Supply đã được xác nhận.
- Thay đổi candlestick hoặc tiêu đề hiện hữu của Core.

Trình bày ứng viên trên biểu đồ, nếu được xem xét về sau, cần một đặc tả giao diện riêng.

## 11. Quy tắc nhân quả và xác nhận về sau

1. Candidate Engine chỉ được dùng dữ liệu tại `t`, `t-1` và `t-2`, cùng các reference prior-only đã có trong Core.
2. Mọi `Ref()` mới chỉ được có offset `-1` hoặc `-2`.
3. Không dùng positive `Ref`, `Zig`, `Peak`, `Trough`, centered average hoặc dữ liệu có nguồn gốc từ tương lai.
4. Thay đổi mọi thanh sau `t` không được thay đổi kết quả ứng viên tại `t`.
5. Confirmation Engine về sau phải ghi xác nhận tại thời điểm thông tin xác nhận xuất hiện. Không được quay lại sửa nhãn lịch sử của thanh ứng viên.

## 12. Thanh hoàn tất và thanh đang hình thành

Kết quả trên thanh hoàn tất là cuối cùng nếu dữ liệu nguồn không bị nhà cung cấp sửa lại. Kết quả trên thanh mới nhất đang hình thành là tạm thời vì giá, biên độ và khối lượng còn có thể thay đổi.

v1.0 không tự phát hiện lịch giao dịch hoặc trạng thái đóng cửa thị trường. Mọi fixture nghiệm thu phải dùng thanh hoàn tất.

## 13. Tổ chức tệp khi triển khai

Sau khi đặc tả được phê duyệt, bản triển khai dự kiến tạo tệp mới:

```text
afl/WyckoffVSA_Candidate_v1.0.afl
```

Tệp mới dùng:

```afl
#include_once <WyckoffVSA_Core_v1.0.afl>
```

`WyckoffVSA_Core_v1.0.afl` phải được đặt trong thư mục dùng chung tiêu chuẩn của AmiBroker. Không sao chép rồi sửa logic Core trong tệp Candidate vì cách đó tạo hai nguồn sự thật.

Ba Git blob của nền Core phải giữ nguyên trong mọi yêu cầu hợp nhất Candidate v1.0:

| Tệp | Git blob bắt buộc |
|---|---|
| `afl/WyckoffVSA_Core_v1.0.afl` | `c03a9599a246849d562ea162975f202781049f90` |
| `docs/core-engine-v1.0-spec.md` | `6788874973cbc6a117037a6865f7db2a173efeb2` |
| `docs/robust-atr-correction-v1.0.md` | `7f8ac6d7cc391044d578a5e35c92799373110501` |

Nếu một blob thay đổi, yêu cầu hợp nhất phải dừng nghiệm thu.

## 14. Tài liệu phương pháp tham chiếu

- `docs/methodology.md`
- `docs/core-engine-v1.0-spec.md`
- TradeGuider, *VSA Signs of Weakness* — No Demand.
- TradeGuider, *VSA System Explained* — No Demand và No Supply/Test.

Các tài liệu ngoài chỉ là cơ sở phương pháp. Định nghĩa có hiệu lực đối với dự án là định nghĩa được viết rõ trong đặc tả này sau khi con người phê duyệt.

## 15. Điều kiện chấp nhận đặc tả

Đặc tả chỉ được phép chuyển sang triển khai khi con người xác nhận:

1. Phạm vi chỉ có No Demand Candidate và No Supply Candidate.
2. Hướng dùng Close so với PreviousClose, không dùng Open.
3. Khối lượng phải nhỏ hơn nghiêm ngặt cả hai thanh trước.
4. Biên độ hẹp dùng `RSpread < 0.80`.
5. RVOL, ClosePosition và Effort/Result chỉ là dữ liệu hỗ trợ.
6. Không có bối cảnh, xác nhận, điểm số hoặc giao dịch.
7. Ma trận kiểm thử đi kèm bao phủ đầy đủ ranh giới, dữ liệu lỗi, tính nhân quả và hồi quy Core.
