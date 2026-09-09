# Confirmation Engine v1.0 — Đặc tả

**Trạng thái:** Dự thảo kỹ thuật để con người phê duyệt; chưa triển khai AFL.

**Ngày:** 09/09/2026.

**Nền cố định:** `core-v1.0.0`, `candidate-v1.0.0`, `structure-location-v1.0.0`.

**Commit nền:** `7c2b8cfb4d729c5b1b631f3860e43a46fc2f6f23`.

**Môi trường đích:** AmiBroker 6.20.01, tối thiểu 6.20+.

**Tệp triển khai dự kiến:** `afl/WyckoffVSA_Confirmation_v1.0.afl`.

## 1. Mục đích

Confirmation Engine v1.0 chỉ trả lời một câu hỏi hẹp:

> Một No Demand Candidate hoặc No Supply Candidate cơ bản ở thanh hoàn tất ngay trước có được thanh hoàn tất hiện tại xác nhận bằng phản ứng giá đóng cửa đúng hướng hay không?

Đầu ra là **xác nhận phản ứng giá cơ bản**, không phải kết luận hoàn chỉnh rằng cung/cầu đã thắng, không phải Wyckoff Event và không phải tín hiệu giao dịch.

Luồng kiến trúc:

```text
Core -> Candidate -> Structure / Location -> Confirmation -> Wyckoff Event (tương lai)
```

Confirmation dùng đúng ứng viên đã phát hành, giữ lại ảnh chụp Structure/Location tại thanh ứng viên để kiểm toán, rồi đánh giá duy nhất phản ứng đóng cửa của thanh kế tiếp. Mọi diễn giải về bối cảnh, sức mạnh/suy yếu, pha Wyckoff hoặc hành động giao dịch thuộc lớp sau và không được đưa vào v1.0.

## 2. Nguồn chuẩn và khóa danh tính

Nguồn chuẩn là các tệp tại commit nền trên `main`. Trước khi triển khai và trước mọi lần nghiệm thu, các Git blob sau phải khớp tuyệt đối:

| Lớp | Tệp | Git blob bắt buộc |
|---|---|---|
| Core | `afl/WyckoffVSA_Core_v1.0.afl` | `c03a9599a246849d562ea162975f202781049f90` |
| Core | `docs/core-engine-v1.0-spec.md` | `6788874973cbc6a117037a6865f7db2a173efeb2` |
| Core | `docs/robust-atr-correction-v1.0.md` | `7f8ac6d7cc391044d578a5e35c92799373110501` |
| Candidate | `afl/WyckoffVSA_Candidate_v1.0.afl` | `589575722c2e2188513f635f089fd97ed2ee7b59` |
| Candidate | `docs/vsa-candidate-engine-v1.0-spec.md` | `a33f28890c2d0230a723dcc872b2311991f63731` |
| Candidate | `tests/vsa-candidate-engine-v1.0-test-plan.md` | `8b4031c0f95eda419d3314086b5eef0d37aeb456` |
| Structure | `afl/WyckoffVSA_StructureLocation_v1.0.afl` | `f54fd8c24c7cb21beb4966737120b3e3b516e699` |
| Structure | `docs/structure-location-engine-v1.0-spec.md` | `d3dfa5ad4c2c668f999bd89df38a00bf01f16685` |
| Structure | `tests/structure-location-engine-v1.0-test-plan.md` | `8da3b6abdcc74d1f906591e10b8878f9c7455c42` |
| Structure | `tests/structure-location-v1.0-fixture-lock.json` | `73dd6130de87639292f15e4442688affd572244b` |
| Structure | `docs/structure-location-engine-v1.0-acceptance.md` | `2684d2405a961cb3de9a76d8d7a040112845a537` |

Sai khác ở bất kỳ blob nền nào là điều kiện dừng. Không sửa các tệp hoặc thẻ đã phát hành để làm Confirmation đạt kiểm thử.

## 3. Phạm vi và bất biến

### 3.1. Bao gồm

- Xác nhận phản ứng giá một thanh cho No Demand Candidate cơ bản.
- Xác nhận phản ứng giá một thanh cho No Supply Candidate cơ bản.
- Trạng thái dữ liệu không đủ, không có ứng viên, không xác nhận và đã xác nhận.
- Tọa độ riêng của thanh ứng viên và thanh đánh giá/xác nhận.
- Giá đóng cửa ứng viên, giá đóng cửa phản ứng, độ thay đổi và hướng phản ứng.
- Ảnh chụp tối thiểu của Structure/Location tại thanh ứng viên để lớp sau dùng đúng mốc thời gian.
- Cột kiểm toán và mã trạng thái xác định, đối xứng giữa hai loại ứng viên.

### 3.2. Không bao gồm

- Xác nhận nhiều thanh, cửa sổ 2–5 thanh hoặc tìm thanh xác nhận muộn hơn.
- Dùng Volume, RSpread, ClosePosition, DirectionalProgress, ATR hoặc Effort/Result của thanh phản ứng làm điều kiện chặn.
- Dùng vị trí S/M/L, điểm xoay, hỗ trợ/kháng cự hoặc xu hướng làm điều kiện chặn.
- Xác nhận Spring, Shakeout, Upthrust, UTAD, Test, SOS, LPS, Climax, Stopping Volume hoặc Absorption.
- Xác định nền Strength/Weakness, Trading Range, pha Wyckoff hoặc sự kiện Wyckoff.
- Điểm số, trọng số, xác suất, confidence, bullish/bearish rank hoặc chọn “ứng viên tốt nhất”.
- `Buy`, `Sell`, `Short`, `Cover`, entry/exit, position sizing, stop, cảnh báo, backtest hoặc market scanner.
- Multi-timeframe và dữ liệu từ mã chứng khoán khác.

### 3.3. Bất biến kiến trúc

1. Các lớp đã phát hành là bất biến và không được tính lại trong Confirmation.
2. Kết quả chỉ được công bố khi thông tin xác nhận đã tồn tại.
3. Không ghi ngược xác nhận về thanh ứng viên.
4. Không biến việc “không xác nhận” thành tín hiệu ngược chiều.
5. Thiếu dữ liệu không được coi là “không xác nhận”.
6. Location/context được giữ riêng với phản ứng giá; không có composite state.
7. Kết quả thanh đang hình thành là tạm thời; chỉ completed bar mới là cuối cùng.

## 4. Mô hình thời gian nhân quả

Ký hiệu:

- `k`: thanh ứng viên hoàn tất.
- `t`: thanh đánh giá, cố định `t = k + 1`.
- `C_k`: Close của thanh ứng viên.
- `C_t`: Close của thanh đánh giá.

Tại hàng `t`, engine chỉ đánh giá Candidate outputs của hàng `t-1`. Nếu ứng viên xuất hiện ở `k`, các hàng đến hết `k` vẫn chỉ có nhãn Candidate `UNCONFIRMED`. Kết quả Confirmation xuất hiện sớm nhất ở `k+1` và mang theo tọa độ của cả `k` lẫn `k+1`.

Không có tham số confirmation horizon. Nếu thanh `k+1` không xác nhận hoặc có dữ liệu phản ứng không hợp lệ, các thanh `k+2`, `k+3` không được dùng để thay thế. Muốn có xác nhận nhiều thanh phải lập đặc tả và phiên bản mới.

`BarIndex()` và `DateTime()` của nguồn phải được giữ nguyên. Không suy ra ngày giao dịch, không coi vị trí mảng cục bộ là BarIndex nguồn và không dùng tổng `BarCount` để nhìn trước.

## 5. Hợp đồng đầu vào

Tệp triển khai tương lai dùng:

```afl
#include_once <WyckoffVSA_StructureLocation_v1.0.afl>
```

Chuỗi include này phải dẫn về đúng Candidate và Core đã phát hành. Confirmation không được sao chép hoặc sửa công thức upstream.

### 5.1. Từ Candidate Engine

- `NoDemandCandidateCode`, miền hợp lệ 0/1/2.
- `NoSupplyCandidateCode`, miền hợp lệ 0/1/2.
- `NoDemandCandidateValid`, `NoSupplyCandidateValid` để kiểm toán.
- Candidate code 2 là ứng viên; code 1 là dữ liệu hợp lệ nhưng không có ứng viên; code 0 là dữ liệu upstream không đủ.

Candidate v1.0 bảo đảm hai code không thể đồng thời bằng 2 và validity của hai kênh dùng cùng `CandidateInputValid`. Confirmation phải kiểm tra hợp đồng này thay vì giả định âm thầm.

### 5.2. Từ Core và dữ liệu nguồn

- `Close`, `CurrentCloseValid` tại thanh đánh giá.
- `Close`, `BarIndex()`, `DateTime()` tại thanh ứng viên qua tham chiếu một thanh trước.
- Các cột Core khác được kế thừa để kiểm toán nhưng không chặn kết quả v1.0.

Phản ứng chỉ phụ thuộc Close. Vì vậy Open, High, Low hoặc Volume hiện tại bị Null không tự làm phản ứng mất hiệu lực nếu `CurrentCloseValid=1`. Đây là dependency tối thiểu giống nguyên tắc tách dimension của Core. Dữ liệu Close Null hoặc `<=0` làm phản ứng không hợp lệ.

### 5.3. Từ Structure / Location

Các giá trị S/M/L và mốc pivot tại thanh ứng viên được chụp lại theo Mục 9. Chúng là dữ liệu bối cảnh có thời điểm rõ ràng, không tham gia điều kiện xác nhận v1.0.

## 6. Kiểm tra hợp đồng Candidate trước thanh hiện tại

Tại `t`:

```text
PriorNDCode = NoDemandCandidateCode tại t-1
PriorNSCode = NoSupplyCandidateCode tại t-1
```

`CE_PriorCandidatePairWellFormed=1` chỉ khi:

1. Cả hai code tồn tại và là số nguyên thuộc 0/1/2.
2. Hai code cùng trạng thái dữ liệu: hoặc cùng bằng 0, hoặc cùng khác 0.
3. Không đồng thời bằng 2.

`CE_PriorCandidateDataValid=1` khi pair well-formed và cả hai code khác 0. Một cặp `(2,1)` biểu thị No Demand opportunity; `(1,2)` biểu thị No Supply opportunity; `(1,1)` biểu thị không có ứng viên. `(0,0)` là dữ liệu upstream không đủ.

Cặp code sai miền, mixed-validity như `(0,1)` hoặc hai ứng viên cùng lúc `(2,2)` là vi phạm hợp đồng upstream. Confirmation trả trạng thái 0, không cố sửa, ưu tiên hoặc suy đoán loại ứng viên.

## 7. Quy tắc xác nhận khóa cho v1.0

Với từng kênh `Y`:

```text
CE_Y_ResponseCloseValid = CE_Y_OpportunityPresent
                          AND CurrentCloseValid_t
                          AND C_t hữu hạn
                          AND C_k tồn tại, hữu hạn và > 0
```

Candidate code 2 đã bảo đảm `C_k` hợp lệ theo hợp đồng upstream, nhưng Confirmation vẫn kiểm tra lại trước phép trừ/so sánh. Pair không well-formed làm `ResponseCloseValid=0`.

### 7.1. No Demand

Nếu `PriorNDCode=2`, phản ứng tại `t=k+1` được xác nhận khi:

```text
NoDemandConfirmed = ResponseCloseValid AND C_t < C_k
```

Nói cách khác, thanh kế tiếp là down bar theo đúng quy ước Close so với PreviousClose của Candidate Engine.

### 7.2. No Supply

Nếu `PriorNSCode=2`, phản ứng tại `t=k+1` được xác nhận khi:

```text
NoSupplyConfirmed = ResponseCloseValid AND C_t > C_k
```

Thanh kế tiếp là up bar theo cùng quy ước.

### 7.3. Ranh giới và các điều kiện không được thêm

- So sánh là nghiêm ngặt. `C_t == C_k` không xác nhận cả hai loại.
- Không làm tròn, không dùng tick giả định và không thêm epsilon vào điều kiện.
- Không dùng `Low_t < Low_k` hoặc `High_t > High_k` thay cho điều kiện Close.
- Không yêu cầu phá High/Low của ứng viên.
- Không yêu cầu Volume tăng/giảm, một RVOL state, RSpread state hoặc ClosePosition cụ thể ở thanh phản ứng.
- Không yêu cầu ứng viên nằm ở biên trên/dưới của vùng S/M/L.

Định nghĩa hẹp này cố ý tách **phản ứng giá ngay sau ứng viên** khỏi **bối cảnh giải thích ứng viên**. Một xác nhận phản ứng giá ở vị trí không phù hợp vẫn có code 3; lớp sau phải đọc context snapshot và không được coi code 3 là kết luận giao dịch.

## 8. Trạng thái của hai kênh xác nhận

Mỗi kênh No Demand/No Supply có cùng miền mã:

| Mã | Văn bản ASCII cố định | Điều kiện |
|---:|---|---|
| 0 | `INSUFFICIENT DATA` | Pair upstream lỗi/không đủ, hoặc có opportunity nhưng Close phản ứng không hợp lệ. |
| 1 | `NO PRIOR CANDIDATE` | Pair upstream hợp lệ, nhưng loại ứng viên tương ứng không xuất hiện ở `t-1`. |
| 2 | `RESPONSE NOT CONFIRMED` | Có opportunity, phản ứng hợp lệ nhưng không đạt bất đẳng thức nghiêm ngặt. |
| 3 | `BASIC PRICE RESPONSE CONFIRMED` | Có opportunity, phản ứng hợp lệ và đạt bất đẳng thức nghiêm ngặt. |

Thứ tự ưu tiên cho mỗi kênh:

```text
if pair không well-formed hoặc prior data không hợp lệ -> 0
else if loại candidate tương ứng không xuất hiện        -> 1
else if response Close không hợp lệ                     -> 0
else if phản ứng đúng hướng                              -> 3
else                                                     -> 2
```

Nếu No Demand xuất hiện ở `k`, kênh No Supply tại `k+1` có code 1; điều tương tự áp dụng theo chiều ngược lại. Code 2 chỉ có nghĩa quy tắc một thanh của đúng opportunity đó không được thỏa mãn. Nó không phải xác nhận chiều đối diện, không xóa Candidate lịch sử và không ngăn một Candidate mới xuất hiện trên thanh hiện tại.

Các cờ:

- `OpportunityPresent=1` khi prior code của kênh bằng 2 và pair well-formed.
- `EvaluationValid=1` chỉ khi opportunity tồn tại và hai Close cần so sánh hợp lệ.
- `StatusValid=1` cho code 1/2/3; bằng 0 cho code 0.
- `Confirmed=1` chỉ cho code 3.

Giá trị 0 của `Confirmed` phải luôn được đọc cùng StatusCode; không được coi code 0 là một quan sát “không xác nhận” hợp lệ.

## 9. Tọa độ, phản ứng và ảnh chụp context

### 9.1. Tọa độ của từng kênh

Với `Y` là `NoDemand` hoặc `NoSupply`, khi `OpportunityPresent=1`:

- `CE_Y_CandidateBarIndex`, `CE_Y_CandidateDateTime`, `CE_Y_CandidateClose` trỏ tới `k`.
- `CE_Y_EvaluationBarIndex`, `CE_Y_EvaluationDateTime` trỏ tới `t=k+1`, kể cả khi Close phản ứng lỗi.
- `CE_Y_ConfirmationLag=1`.
- `CE_Y_ResponseClose`, `CE_Y_ResponseDelta=C_t-C_k` và `CE_Y_ResponseDirectionCode` chỉ công bố khi EvaluationValid=1.

`ResponseDirectionCode` là `-1` khi delta âm, `0` khi bằng 0, `1` khi dương. Đây là hướng đo lường, không phải bearish/bullish score. Khi không có opportunity, mọi giá/tọa độ dành riêng cho opportunity là Null.

### 9.2. Ảnh chụp Structure/Location tại thanh ứng viên

Để tránh lớp sau vô tình dùng vị trí của thanh xác nhận thay cho vị trí của thanh ứng viên, Confirmation tạo một context snapshot tại `k` khi đúng một opportunity tồn tại:

- `CE_ContextSnapshotPresent` = 1.
- `CE_ContextCandidateKindCode`: 1 = No Demand, 2 = No Supply; Null khi không có một opportunity hợp lệ.
- `CE_ContextCandidateBarIndex`, `CE_ContextCandidateDateTime`.

Với mỗi `X` là S/M/L, snapshot tối thiểu gồm:

- `CE_ContextXReferenceStatusCode`.
- `CE_ContextXPositionStateCode`.
- `CE_ContextXLocationValid`.
- `CE_ContextXLocation`.

Với pivot High/Low, snapshot tối thiểu gồm:

- `CE_ContextPivotYLatestValid`.
- `CE_ContextPivotYLatestPrice`.
- `CE_ContextPivotYLatestExtremeBarIndex`, `CE_ContextPivotYLatestExtremeDateTime`.
- `CE_ContextPivotYLatestConfirmBarIndex`, `CE_ContextPivotYLatestConfirmDateTime`.

Snapshot dùng trạng thái `SL_PivotYLatest...` ở cuối thanh `k`, không dùng `LatestPrior` của `k`: tại thời điểm đánh giá `k+1`, mọi pivot đã được xác nhận đến hết `k` đều là thông tin quá khứ hợp lệ. Snapshot không được chứa pivot mới chỉ xác nhận ở `k+1`.

Một vùng hoặc pivot không hợp lệ giữ đúng code/cờ/Null của Structure. Không forward-fill, không thay thế S bằng M/L, không chọn vùng “quan trọng nhất” và không tạo `ContextReady`, weight hoặc score tổng hợp. Context lỗi không đổi mã xác nhận phản ứng giá.

## 10. Hợp đồng tên biến và đầu ra

Mọi tên mới bắt đầu bằng `CE_`. Tên cụ thể phải được khai triển đầy đủ trong AFL; ký hiệu `Y` và `X` chỉ dùng trong tài liệu.

### 10.1. Nhóm chung

- `CE_PriorCandidatePairWellFormed`.
- `CE_PriorCandidateDataValid`.
- `CE_ContextSnapshotPresent`.
- `CE_ContextCandidateKindCode`.
- `CE_ContextCandidateBarIndex`, `CE_ContextCandidateDateTime`.
- Các trường context S/M/L và pivot ở Mục 9.2.

### 10.2. Mỗi kênh Y

- `CE_Y_PriorCandidateCode`.
- `CE_Y_OpportunityPresent`.
- `CE_Y_ResponseCloseValid`.
- `CE_Y_EvaluationValid`.
- `CE_Y_StatusValid`.
- `CE_Y_StatusCode`, `CE_Y_Status`.
- `CE_Y_Confirmed`.
- `CE_Y_CandidateBarIndex`, `CE_Y_CandidateDateTime`, `CE_Y_CandidateClose`.
- `CE_Y_EvaluationBarIndex`, `CE_Y_EvaluationDateTime`, `CE_Y_ConfirmationLag`.
- `CE_Y_ResponseClose`, `CE_Y_ResponseDelta`, `CE_Y_ResponseDirectionCode`.

Cờ là số 0/1, state code là số nguyên, giá trị không hợp lệ là Null. Không dùng 0 làm BarIndex/DateTime giả. Văn bản lịch sử dùng `AddMultiTextColumn()` hoặc cơ chế đã chứng minh tương đương trên AmiBroker 6.20. State text trong AFL dùng dấu nháy kép thẳng và ký tự ASCII để tránh lỗi parser/encoding đã từng gặp.

### 10.3. Exploration và biểu đồ

Exploration phải hiển thị đủ đầu vào upstream liên quan, các trường CE và mã/văn bản cùng hàng. `Filter=1` của stack hiện tại được giữ nguyên để Analysis range quyết định phạm vi; Confirmation không được đổi thành scanner chỉ lấy code 3.

Không thêm mũi tên, `PlotShapes()`, màu nền tăng/giảm, chữ Buy/Sell hoặc sửa candlestick/title của các lớp trước. Giao diện trực quan cần đặc tả riêng.

## 11. Quy tắc AFL và no-lookahead

1. Mọi tham chiếu mới tới Candidate/Structure của `k` dùng đúng một thanh trước (`Ref(...,-1)`) hoặc vòng lặp thời gian tăng dần tương đương.
2. Không có positive `Ref`, `Zig`, `Peak`, `Trough`, centered average, future quotation hoặc ghi kết quả vào hàng `k`.
3. Không dùng `ValueWhen` với occurrence từ tương lai hoặc biến toàn chuỗi khiến tiền tố phụ thuộc hậu tố.
4. Thay dữ liệu sau `t` không được đổi bất kỳ CE output nào đến hết `t`.
5. Nối thêm dữ liệu không được đổi kết quả của completed bars cũ nếu dữ liệu nguồn cũ và tham số không đổi.
6. Một Candidate mới tại chính `t` vẫn giữ trạng thái upstream `UNCONFIRMED`; đồng thời `t` có thể xác nhận Candidate ở `t-1`.
7. Nếu dữ liệu `t` đang hình thành, StatusCode 2/3 và mọi response value ở `t` là provisional.

## 12. Dữ liệu lỗi và trường hợp biên

- Prior Candidate code 0 tạo CE code 0, không phải code 1.
- Có opportunity nhưng Close hiện tại Null/không dương tạo CE code 0; không tìm thanh sau thay thế.
- Close hiện tại hợp lệ nhưng High/Low/Open/Volume lỗi không tự chặn xác nhận.
- Close bằng Candidate Close tạo code 2.
- Current bar đồng thời là Candidate mới không làm thay đổi việc đánh giá prior Candidate.
- Hai Candidate upstream cùng đúng hoặc validity không nhất quán tạo pair not well-formed và CE code 0.
- Context S/M/L zero-width, invalid reference hoặc thiếu pivot được giữ nguyên trong snapshot; response confirmation vẫn độc lập.
- Sửa lịch sử nguồn ở `k` hoặc sớm hơn có thể hợp lệ làm thay đổi Candidate/context/confirmation phụ thuộc; việc đó phải được phân biệt với repaint do thuật toán.

## 13. Kiểm thử và tiêu chí chấp nhận

Kế hoạch chính thức nằm tại `tests/confirmation-engine-v1.0-test-plan.md`. Trước triển khai phải có mô hình tham chiếu độc lập và fixture khóa. Kiểm tra tĩnh không thay thế Formula Verify/Exploration thật trong AmiBroker 6.20.01.

Đặc tả chỉ được chuyển sang triển khai khi con người phê duyệt rõ:

1. v1.0 chỉ xác nhận No Demand/No Supply Candidate đã phát hành.
2. Chỉ thanh kế tiếp được quyền xác nhận; lag cố định bằng 1.
3. No Demand dùng `C_t < C_k`; No Supply dùng `C_t > C_k`; equality không xác nhận.
4. Close là dependency phản ứng duy nhất; không thêm volume/spread/location gate.
5. Context snapshot là dữ liệu độc lập, không phải score hoặc điều kiện xác nhận.
6. Mã 0/1/2/3 và thứ tự ưu tiên được khóa.
7. Không ghi ngược, không trading signal và không sửa bất kỳ lớp đã phát hành nào.
8. Ma trận kiểm thử đi kèm bao phủ state, ranh giới, context snapshot, invalid data, causality và hồi quy tuyệt đối.

## 14. Trình tự triển khai và phát hành

1. Phê duyệt đặc tả và kế hoạch thử.
2. Tạo nhánh tài liệu riêng, kiểm tra diff, tạo pull request tài liệu; không tự merge.
3. Sau khi tài liệu được merge, tạo nhánh triển khai riêng từ đúng `main`.
4. Tạo AFL, mô hình tham chiếu và fixtures đã khóa; không sửa upstream.
5. Chạy kiểm tra tĩnh, đối chiếu mô hình, kiểm thử AmiBroker theo các batch và hồi quy toàn bộ stack.
6. Chỉ sau nghiệm thu mới tạo pull request mã; không tự merge.
7. Sau merge và xác minh commit đích mới đề xuất tag/release riêng.

Không giải quyết mâu thuẫn kiểm thử bằng cách âm thầm thay công thức hoặc nới ranh giới. Mọi thay đổi semantic phải quay lại đặc tả và được phê duyệt.

## 15. Tài liệu phương pháp tham chiếu

- `docs/methodology.md`.
- `docs/vsa-candidate-engine-v1.0-spec.md`.
- `docs/structure-location-engine-v1.0-spec.md`.
- TradeGuider, *VSA System Explained* (SOW 198 No Supply và SOW 199 No Demand): <https://www.tradeguider.com/customer/pdf/VSA_System_explained.pdf>.
- Gavin Holmes, *Trading in the Shadow of the Smart Money*: <https://www.tradeguider.com/tradingintheshadow/book1.pdf>.

Tài liệu ngoài giải thích nguyên tắc cần phản ứng thanh sau và tầm quan trọng của background. Định nghĩa có hiệu lực đối với phần mềm là công thức hẹp trong tài liệu này sau khi chủ dự án phê duyệt.
