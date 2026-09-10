# Wyckoff Event — Đặc tả Test cung v1.0

**Trạng thái:** ĐÃ KHÓA ĐỂ THIẾT KẾ MÔ HÌNH VÀ FIXTURE. Chưa triển khai AFL Event, chưa nghiệm thu hoặc phát hành Event.

Tài liệu này cụ thể hóa hướng thiết kế được chủ dự án chấp thuận ngày 10/09/2026. Nó không sửa Core, Candidate, Structure/Location hoặc Confirmation đã phát hành và không biến các ngoại lệ Confirmation thành PASS.

## 1. Phạm vi

v1.0 chỉ nhận diện **Test cung thông thường tại hỗ trợ đã biết trước**. Không nhận diện Spring, Shakeout, SOS, LPS, pha tích lũy/phân phối, ý định tổ chức, tín hiệu mua/bán, điểm số, xác suất, quản trị vốn hoặc cảnh báo giao dịch.

Luồng dữ liệu:

`Core → Candidate → Structure/Location → Confirmation → Supply Test Event`

Tệp triển khai tương lai: `afl/WyckoffVSA_Event_SupplyTest_v1.0.afl`, include_once Confirmation. Mọi trường mới dùng tiền tố `WE_ST_`. Không sao chép hoặc ghi đè công thức upstream.

Nền khóa:

- main sau PR #8: `c31e61fccdd7867f417bc036c3b9705c0256dc53`.
- Confirmation blob: `48061c9dd763814dc31f27e1dcf19ed61065aee5`.
- Candidate blob: `589575722c2e2188513f635f089fd97ed2ee7b59`.
- Structure/Location blob: `f54fd8c24c7cb21beb4966737120b3e3b516e699`.
- Core blob: `c03a9599a246849d562ea162975f202781049f90`.

## 2. Định nghĩa hoạt động

Một Test cung v1.0 chỉ tồn tại khi một No Supply Candidate hợp lệ xuất hiện gần một **pivot Low đã được xác nhận từ trước**, không xuyên hỗ trợ, rồi thanh kế tiếp xác nhận phản ứng No Supply và tiếp tục giữ hỗ trợ.

No Supply code2 hoặc Confirmation code3 một mình không đủ để gọi là Test cung. S/M/L chỉ là bối cảnh bổ sung; không phải nguồn hỗ trợ chính của v1.0.

## 3. Các quyết định D01–D10 đã khóa

### D01 — Nguồn hỗ trợ

Nguồn hỗ trợ duy nhất của v1.0 là **pivot Low gần nhất đã được xác nhận trước thanh khởi phát k**.

Tại k phải dùng nhóm `SL_PivotLowLatestPrior...`, không dùng `Latest...` nếu pivot đó mới được xác nhận tại chính k. Điều này bảo đảm hỗ trợ đã tồn tại trước khi Test bắt đầu.

S/M/L không được dùng làm nguồn hỗ trợ thay thế hoặc tự chọn vùng thuận lợi nhất. Chúng có thể được xuất như context nghiên cứu.

### D02 — Hỗ trợ hợp lệ và cách khóa

Hỗ trợ hợp lệ tại k khi:

- `SL_PivotLowLatestPriorValid = 1`;
- giá pivot tồn tại, hữu hạn và > 0;
- ConfirmBarIndex/DateTime của pivot tồn tại và sớm hơn k;
- tọa độ nguồn hợp lệ.

Không có tuổi tối đa của hỗ trợ trong v1.0. Pivot Low gần nhất đã xác nhận trước k tự nhiên thay thế pivot cũ cho **một sự kiện mới**. Khi một Test bắt đầu, SupportPrice và toàn bộ tọa độ pivot được chụp và giữ cố định cho sự kiện đó; pivot mới xuất hiện sau k không được thay hỗ trợ của sự kiện đang đánh giá.

### D03 — Tiếp cận hỗ trợ

v1.0 dùng khoảng cách theo ATR để tránh ngưỡng giá tuyệt đối theo từng mã.

Hằng số khóa:

`WE_ST_MaxDistanceATR = 0.50`

Tại k yêu cầu `PriorATRValid = 1` và:

```text
SupportPrice <= Low_k <= SupportPrice + 0.50 * PriorATR_k
```

Biên được bao hàm. `Low_k == SupportPrice` hợp lệ. `Low_k < SupportPrice` không phải Test thông thường v1.0; trường hợp xuyên rồi thu hồi để dành cho Spring/Shakeout.

Không tối ưu 0,50 theo kết quả lịch sử trong v1.0. Nếu muốn thay đổi phải tạo phiên bản đặc tả mới hoặc quyết định sửa có kiểm soát trước khi xem kết quả nghiệm thu.

### D04 — Khởi phát

Thanh k là ứng viên Test khi đồng thời:

- `NoSupplyCandidateCode_k = 2` và validity upstream hợp lệ;
- hỗ trợ theo D01–D02 hợp lệ;
- `PriorATRValid_k = 1`;
- điều kiện khoảng cách D03 đạt;
- dữ liệu Low/Close cần dùng ở k hợp lệ.

No Supply Candidate vẫn giữ nguyên định nghĩa upstream: down bar theo Close, Volume thấp hơn hai thanh trước và RSpread < 0,80. Event không sao chép hoặc sửa công thức đó.

### D05 — Phản ứng xác nhận

Chỉ đánh giá tại `t = k+1`.

Test được xác nhận khi đồng thời:

- prior Event origin tại k hợp lệ;
- `CE_NoSupply_StatusCode_t = 3`;
- `CE_NoSupply_Confirmed_t = 1`;
- `CE_NoSupply_CandidateBarIndex_t` trỏ đúng k;
- dữ liệu giá tại t hợp lệ;
- `Low_t >= SupportPrice` đã chụp tại k.

Không có cửa sổ nhiều thanh. Không xác nhận tại k+2 hoặc muộn hơn. Không sửa Confirmation để chờ thêm.

### D06 — Xuyên hỗ trợ

Ordinary Supply Test v1.0 **không cho phép xuyên hỗ trợ**.

- `Low_k < SupportPrice`: không tạo Event origin hợp lệ.
- Event origin hợp lệ ở k nhưng `Low_{k+1} < SupportPrice`: Event bị bác bỏ tại k+1 nếu dữ liệu đánh giá hợp lệ.

Không tự gán Spring/Shakeout cho bất kỳ cú xuyên nào.

### D07 — Bác bỏ, dữ liệu thiếu và hết hiệu lực

Không dùng trạng thái hết hiệu lực nhiều thanh trong v1.0 vì vòng đời chỉ k → k+1.

Một Event origin hợp lệ tại k được giải quyết duy nhất tại k+1:

- xác nhận nếu D05 đạt;
- bác bỏ nếu CE phản ứng hợp lệ nhưng không xác nhận và/hoặc hỗ trợ bị xuyên tại k+1;
- `INSUFFICIENT DATA` nếu dữ liệu cần thiết tại k+1 không hợp lệ.

Dữ liệu thiếu không được diễn giải là bác bỏ do cung mạnh. Một thanh k+2 hợp lệ không được hồi sinh Event đã thiếu dữ liệu hoặc bị bác bỏ tại k+1.

### D08 — Chồng lấn

Cho phép ứng viên liên tiếp. Một thanh t có thể vừa giải quyết Event từ t-1 vừa là origin của Event mới tại t.

Do đó v1.0 dùng **hai kênh trạng thái tách biệt**:

- `WE_ST_OriginCode` cho Event bắt đầu tại thanh hiện tại;
- `WE_ST_ResolutionCode` cho Event bắt đầu ở thanh trước và được giải quyết tại thanh hiện tại.

Không dùng một StatusCode duy nhất để âm thầm chọn trạng thái “quan trọng hơn”. Khóa sự kiện là Symbol + OriginBarIndex + OriginDateTime + SupportPivotConfirmBarIndex.

### D09 — Thời gian và thanh hoàn tất

Phạm vi vận hành v1.0 là Daily trên thanh đã hoàn tất. Tất cả kết quả ở thanh cuối khi nguồn chưa xác nhận hoàn tất chỉ là provisional và không được dùng để ký nghiệm thu hoặc ra quyết định tự động.

Không suy đoán thanh hoàn tất chỉ từ BarCount. Không backfill kết luận về k. Kết quả xác nhận/bác bỏ được công bố tại k+1. Khi nguồn sửa lịch sử, kết quả phụ thuộc có thể thay đổi nhưng phải phân biệt source revision với algorithmic repaint.

### D10 — Phạm vi sử dụng

Nghiên cứu và kiểm toán có giám sát trên AmiBroker 6.20.01, một mã và một khung thời gian trong mỗi lượt. Không giao dịch tự động. Không tối ưu tham số bằng lợi nhuận. Mở rộng intraday, realtime hoặc tự động hóa cần đặc tả và nghiệm thu riêng.

## 4. Hợp đồng trạng thái khóa

### 4.1. Origin

`WE_ST_OriginCode`:

| Mã | Văn bản | Điều kiện |
|---:|---|---|
| 0 | `INSUFFICIENT DATA` | Một dependency bắt buộc của origin không hợp lệ. |
| 1 | `NOT PRESENT` | Dữ liệu hợp lệ nhưng không đạt toàn bộ D03–D04. |
| 2 | `SUPPLY TEST CANDIDATE` | Toàn bộ điều kiện origin đạt tại k. |

`WE_ST_OriginValid = 1` cho code1/2, bằng 0 cho code0.

`WE_ST_OriginReasonCode`:

- 0: không có lỗi/không áp dụng;
- 1: No Supply Candidate không xuất hiện;
- 2: không có pivot Low prior hợp lệ;
- 3: ATR prior không hợp lệ;
- 4: Low nằm cao hơn dải 0,50 ATR;
- 5: Low xuyên dưới hỗ trợ;
- 6: dữ liệu giá cần thiết không hợp lệ.

Code lý do dùng để kiểm toán, không phải điểm số. Nếu có nhiều lỗi, ưu tiên dữ liệu nguồn/hợp đồng trước vị trí giá.

### 4.2. Resolution

`WE_ST_ResolutionCode`:

| Mã | Văn bản | Điều kiện |
|---:|---|---|
| 0 | `INSUFFICIENT DATA` | Có prior origin nhưng dữ liệu đánh giá bắt buộc không hợp lệ. |
| 1 | `NO PRIOR SUPPLY TEST` | Thanh trước không có OriginCode=2. |
| 2 | `SUPPLY TEST REJECTED` | Có prior origin, dữ liệu hợp lệ nhưng phản ứng/hỗ trợ không đạt. |
| 3 | `SUPPLY TEST CONFIRMED` | D05 đạt đầy đủ. |

`WE_ST_ResolutionValid = 1` cho code1/2/3, bằng 0 cho code0. `WE_ST_Confirmed = 1` chỉ ở code3.

`WE_ST_ResolutionReasonCode`:

- 0: không áp dụng/không có lỗi;
- 1: CE No Supply không xác nhận;
- 2: Low đánh giá xuyên hỗ trợ;
- 3: đồng thời không xác nhận và xuyên hỗ trợ;
- 4: CE không trỏ đúng OriginBarIndex;
- 5: dữ liệu đánh giá không hợp lệ.

Lý do 4 hoặc 5 làm ResolutionCode=0 nếu hợp đồng/đầu vào không đủ để đánh giá chắc chắn.

## 5. Tọa độ và snapshot bắt buộc

Khi OriginCode=2 phải xuất tối thiểu:

- `WE_ST_OriginBarIndex`, `WE_ST_OriginDateTime`;
- `WE_ST_SupportPrice`;
- pivot Low extreme/confirm BarIndex và DateTime;
- `WE_ST_SupportDistanceATR`;
- PriorATR dùng tại k;
- No Supply Candidate code/validity tại k;
- snapshot S/M/L và pivot context cần nghiên cứu tại k;
- nguồn/phiên bản dữ liệu trong hồ sơ chạy.

Khi ResolutionCode=0/2/3 của một prior origin phải giữ lại tọa độ origin và SupportPrice đã chụp, đồng thời xuất EvaluationBarIndex/DateTime, CE No Supply status/confirmed/candidate coordinate, Low/Close đánh giá và lý do kết quả.

Không thay SupportPrice bằng pivot mới tại k+1.

## 6. Công thức khóa tối thiểu

Tại k:

```text
SupportValid_k = PivotLowLatestPriorValid_k
                 AND SupportPrice_k hữu hạn > 0
                 AND PivotConfirmBarIndex_k < BarIndex_k

NearSupport_k = PriorATRValid_k
                AND Low_k >= SupportPrice_k
                AND Low_k <= SupportPrice_k + 0.50 * PriorATR_k

OriginCode_k =
    0 nếu dependency bắt buộc không hợp lệ
    2 nếu NoSupplyCandidateCode_k == 2 AND SupportValid_k AND NearSupport_k
    1 trong các trường hợp dữ liệu hợp lệ còn lại
```

Tại t=k+1, nếu `OriginCode_k=2`:

```text
SupportHeld_t = Low_t >= SupportPrice_k
CEConfirmed_t = CE_NoSupply_StatusCode_t == 3
                AND CE_NoSupply_Confirmed_t == 1
                AND CE_NoSupply_CandidateBarIndex_t == OriginBarIndex_k

ResolutionCode_t =
    0 nếu dependency đánh giá không hợp lệ
    3 nếu CEConfirmed_t AND SupportHeld_t
    2 nếu dữ liệu hợp lệ nhưng một hoặc cả hai điều kiện trên không đạt
```

Nếu OriginCode_{t-1} khác 2 thì ResolutionCode_t=1.

## 7. Bất biến nhân quả

- Chỉ dùng pivot đã xác nhận trước k; pivot mới xác nhận tại k hoặc k+1 không được dùng làm hỗ trợ của Event đã bắt đầu.
- Không dùng S/M/L hiện tại thay snapshot k để đổi kết luận.
- Không xác nhận muộn sau k+1.
- Không ghi ngược code3 về thanh k.
- Không dùng Zig/Peak/Trough nhìn tương lai.
- Không chọn hỗ trợ tốt nhất sau khi biết kết quả.
- Không thay 0,50 ATR sau khi xem kết quả fixture/kiểm thử.
- Tiền tố dữ liệu giống nhau phải cho đầu ra Event giống nhau đến hết tiền tố, trừ khi nguồn lịch sử thực sự bị sửa.
- Không sửa bất kỳ đầu ra upstream nào.

## 8. Điều kiện trước lập trình AFL

Trước khi tạo nhánh AFL Event phải có:

1. mô hình tham chiếu độc lập theo tài liệu này;
2. fixture và expected được khóa trước AFL;
3. ma trận kiểm thử cụ thể;
4. kiểm tra độc lập mô hình/fixture;
5. kế hoạch hồi quy Core/Candidate/Structure/Confirmation;
6. định danh Git blob/commit của toàn bộ nguồn nền.

AFL chỉ được triển khai sau khi các artefact trên hoàn tất. Không điều chỉnh expected để khớp kết quả AFL.