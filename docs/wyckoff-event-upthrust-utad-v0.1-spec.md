# Wyckoff Event — Upthrust / UTAD v0.1

**Trạng thái:** SPEC-ALIGNED / UNTESTED DEVELOPMENT. Tài liệu triển khai này phản ánh D01–D20 đã được chủ dự án phê duyệt ở PR #16. Mốc khóa đặc tả trên `main`: merge commit `d0354bc1314a25806c3cd4f9c70d70b9cd9b52b1`. Chưa phải bằng chứng kiểm thử AmiBroker/native và chưa phải bản phát hành.

## 1. Mục tiêu và ranh giới

Mô-đun xử lý hành vi phá kháng cự phía trên nhưng không duy trì được mức giá mới.

Luồng kiến trúc:

`Core → Candidate → Structure/Location → Confirmation → Wyckoff Event → Phase/Context`

Event layer v0.1 chỉ được phép công bố `UPTHRUST-LIKE`. Không gán `UTAD-LIKE`, `UTAD CONFIRMED`, Distribution hoặc Phase C. UTAD là khái niệm phụ thuộc bối cảnh phân phối và sẽ chỉ được Phase/Context Engine tương lai công bố khi đủ bằng chứng.

Không phát Buy/Sell/Short/Cover, không quản trị vốn, không chấm điểm xác suất và không tự động giao dịch.

## 2. D01 — Nguồn kháng cự

Nguồn kháng cự duy nhất là pivot High gần nhất đã xác nhận **trước** thanh khởi phát `k`, dùng nhóm `SL_PivotHighLatestPrior...`.

`ResistanceValid_k = 1` khi đồng thời:

- `SL_PivotHighLatestPriorValid_k = 1`;
- ResistancePrice hữu hạn và `> 0`;
- ExtremeBarIndex/DateTime tồn tại;
- ConfirmBarIndex/DateTime tồn tại;
- `PivotConfirmBarIndex_k < BarIndex_k`.

Pivot High mới xác nhận tại chính `k` không được dùng làm prior resistance của `k`. S/M/L chỉ là context, không làm resistance fallback. Resistance và toàn bộ tọa độ pivot được snapshot tại origin và không thay đổi trong lifecycle event.

Không đặt tuổi tối đa cho resistance trong v0.1; xuất Age/BarsSinceConfirmation để đánh giá sau.

## 3. D02 — Fresh thrust

Upthrust-like phải là cú thrust mới từ trạng thái trước đó chưa được chấp nhận phía trên resistance:

```text
PriorClose_k <= ResistancePrice_k
```

`PriorClose_k = Close_(k-1)` và phải hợp lệ. Không yêu cầu `High_(k-1) <= Resistance`.

## 4. D03 — Xuyên kháng cự

```text
High_k > ResistancePrice_k
```

So sánh nghiêm ngặt, không epsilon và không làm tròn theo hiển thị. `High == Resistance` chỉ là chạm, không phải penetration.

Descriptor:

```text
Penetration    = High_k - ResistancePrice_k
PenetrationATR = Penetration / PriorATR_k
```

`PenetrationATR` chỉ valid khi PriorATR valid, hữu hạn và `> 0`.

## 5. D04 — Không hard gate theo ATR

Không dùng `MaxPenetrationATR = 1.00` hoặc bất kỳ ngưỡng ATR cố định nào để loại Origin. PenetrationATR chỉ là descriptor phục vụ nghiên cứu/kiểm thử sau này.

## 6. D05 — Failure trong thanh origin

`UPTHRUST-LIKE` origin tại `k` yêu cầu:

```text
High_k  > ResistancePrice_k
Close_k <= ResistancePrice_k
```

`Close == Resistance` được chấp nhận.

Nếu:

```text
High_k > ResistancePrice_k
AND Close_k > ResistancePrice_k
```

thì không gọi Upthrust-like. Chỉ xuất `WE_UT_UpperBreakoutObservation = 1` để Phase/sequence engine tương lai theo dõi breakout thật hoặc failure nhiều thanh.

## 7. D06 — ClosePosition chỉ là quality descriptor

ClosePosition không tham gia OriginCode.

```text
WE_UT_StrongCloseRejection = 1
```

khi ClosePosition valid và `ClosePosition <= 0.50` trên một Upthrust-like origin. ClosePosition >0.50 không loại origin nếu Close vẫn quay xuống resistance.

## 8. D07 — RVOL/RSpread chỉ là effort context

RVOL và RSpread không quyết định OriginCode và không phân biệt Upthrust với UTAD.

Descriptor:

```text
HighEffortFlag = RVOL >= 1.25 AND RSpread >= 1.20
```

`MixedEffortFlag` dùng khi chỉ một trong hai điều kiện RVOL/RSpread đạt ngưỡng. Các descriptor này không thay đổi event identity.

## 9. D08 — Hợp đồng Origin

`WE_UT_OriginCode`:

- 0 = `INSUFFICIENT DATA`
- 1 = `NOT PRESENT`
- 2 = `UPTHRUST-LIKE CANDIDATE`

Code 2 khi đồng thời:

```text
PriceValid_k = 1
ResistanceValid_k = 1
PriorCloseValid_k = 1
PriorClose_k <= ResistancePrice_k
High_k > ResistancePrice_k
Close_k <= ResistancePrice_k
```

PriorATR, ClosePosition, RVOL, RSpread không bắt buộc để tồn tại Origin; mỗi descriptor có validity riêng.

`WE_UT_OriginReasonCode`:

- 0: không lỗi / không áp dụng;
- 1: không xuyên resistance (`High <= Resistance`);
- 2: không có prior pivot High hợp lệ;
- 3: PriorClose không hợp lệ;
- 4: PriorClose đã ở trên resistance;
- 5: xuyên nhưng Close vẫn trên resistance — Upper Breakout Observation;
- 6: dữ liệu giá origin không hợp lệ.

## 10. D09 — Upper Breakout Observation

`WE_UT_UpperBreakoutObservation = 1` khi:

```text
ResistanceValid = 1
PriorCloseValid = 1
PriorClose <= Resistance
High > Resistance
Close > Resistance
```

Observation này không khẳng định breakout thành công, continuation, UTAD hoặc Distribution.

## 11. D10 — Xác nhận tại k+1

Origin Upthrust-like tại `k` chỉ được giải quyết tại `t = k+1`.

Xác nhận cơ bản khi:

```text
Close_t <= ResistancePrice_k
AND Close_t < Close_k
```

và dữ liệu giá tại `t` hợp lệ.

`High_t <= ResistancePrice_k` chỉ là descriptor xác nhận mạnh hơn (`FullyBelowResistance` / `StrongResistanceHold`), không phải gate tối thiểu.

## 12. D11 — Bác bỏ và dữ liệu thiếu

Tại `k+1`:

- `CONFIRMED` nếu D10 đạt;
- `REJECTED` nếu dữ liệu hợp lệ nhưng Close không giảm hoặc đóng lại trên resistance;
- `INSUFFICIENT DATA` nếu dữ liệu evaluation bắt buộc không hợp lệ.

Không xác nhận muộn ở `k+2`.

`ResolutionReasonCode`:

- 0: không lỗi / không prior origin;
- 1: Close không thấp hơn origin;
- 2: Close quay lại trên resistance;
- 3: đồng thời thất bại cả hai;
- 4: dữ liệu evaluation không hợp lệ.

## 13. D12 — Hợp đồng Resolution

`WE_UT_ResolutionCode`:

- 0 = `INSUFFICIENT DATA`
- 1 = `NO PRIOR UPTHRUST-LIKE`
- 2 = `UPTHRUST-LIKE REJECTED`
- 3 = `UPTHRUST-LIKE CONFIRMED`

`WE_UT_ResolutionValid = 1` cho code 1/2/3, bằng 0 cho code 0. `WE_UT_Confirmed = 1` chỉ khi code 3.

## 14. D13 — Không dùng UTAD làm OriginKind

Event v0.1 chỉ có:

```text
WE_UT_OriginKindCode = 1  // UPTHRUST-LIKE
```

khi OriginCode=2. Không có KindCode=2 cho UTAD. Mọi logic cũ kiểu `UTAD-LIKE = deep penetration OR high effort` bị loại bỏ.

## 15. D14 — UTAD có thể là sequence nhiều thanh

Một chuỗi `UpperBreakoutObservation` có thể kéo dài nhiều thanh phía trên resistance. Event Engine không ép UTAD vào lifecycle `k → k+1` của Upthrust-like và không đặt timeout tùy ý 2/3/5/10 thanh. Phase/sequence engine tương lai xử lý lifecycle nhiều thanh.

## 16. D15 — Snapshot bắt buộc

Origin snapshot tối thiểu:

- OriginBarIndex / OriginDateTime;
- Origin High / Close;
- PriorClose;
- ResistancePrice;
- Resistance pivot ExtremeBarIndex/DateTime;
- Resistance pivot ConfirmBarIndex/DateTime;
- Resistance Age/BarsSinceConfirmation;
- PriorATR + validity;
- Penetration + PenetrationATR + validity;
- ClosePosition + validity;
- RVOL + validity;
- RSpread + validity;
- StrongCloseRejection;
- HighEffort/MixedEffort;
- S/M/L context nếu xuất.

Resolution tại k+1 mang snapshot origin và bổ sung EvaluationBarIndex/DateTime, Evaluation High/Close, CloseStayedBelowResistance, CloseDeclined, FullyBelowResistance, ResolutionCode và ReasonCode.

## 17. D16 — Chồng lấn

Origin, Resolution và UpperBreakoutObservation là các kênh độc lập. Một thanh có thể resolve event từ `t-1` đồng thời tạo origin hoặc observation của chính `t`.

Event key:

```text
Symbol
+ OriginBarIndex
+ OriginDateTime
+ ResistancePivotConfirmBarIndex
```

## 18. D17 — Quan hệ với No Demand và các Event khác

No Demand/Confirmation chỉ là context tùy chọn, không phải gate bắt buộc của Upthrust-like. Supply Test và Spring/Shakeout thuộc phía hỗ trợ và không quyết định event phía kháng cự.

## 19. D18 — Distribution/UTAD dành cho Phase Engine

Một Upthrust-like đơn lẻ không đủ kết luận Distribution. Phase Engine tương lai phải phân biệt Upthrust thông thường, false breakout ngoài distribution, breakout thật và UTAD trong giai đoạn muộn của Distribution.

Nếu sau này gán UTAD, `UTADPublishedBar` phải là thời điểm đầu tiên đủ toàn bộ context; không backfill nhãn UTAD vào origin. Có thể lưu `UTADSourceOriginBarIndex` chỉ như tọa độ lịch sử.

## 20. D19 — Nhân quả và dữ liệu sửa

- Daily completed bars là phạm vi nghiên cứu chính thức v0.1.
- Forming bar chỉ provisional nếu nguồn chưa xác nhận hoàn tất.
- Không dùng BarCount để tự suy đoán thanh đã đóng.
- Không Zig/Peak/Trough nhìn tương lai.
- Không backfill.
- Pivot xác nhận tại k không được dùng như prior resistance cho k.
- Source revision phải được phân biệt với algorithmic repaint.

## 21. D20 — Không giao dịch tự động

Không tạo/ghi đè Buy, Sell, Short, Cover, PositionSize, stop, order hoặc điểm xác suất giao dịch. Exploration chỉ xuất quan sát, trạng thái, descriptor và tọa độ.

## 22. Phản ví dụ bắt buộc

- High chỉ chạm resistance → không Upthrust-like.
- PriorClose đã trên resistance → không fresh Upthrust origin.
- High xuyên nhưng Close vẫn trên resistance → UpperBreakoutObservation, không Upthrust-like.
- High xuyên >1 ATR rồi Close quay dưới resistance → vẫn có thể Upthrust-like.
- RVOL/RSpread cao → không tự gọi UTAD.
- RVOL/RSpread thấp → không loại Upthrust-like.
- ClosePosition >0.50 nhưng Close dưới resistance → vẫn có thể Upthrust-like.
- k+1 High retest trên resistance nhưng Close <= resistance và Close < Close_k → vẫn có thể xác nhận; FullyBelowResistance=0.
- Breakout giữ trên resistance nhiều thanh → Event layer không ép thành Upthrust/UTAD ở thanh đầu.
- k+1 thất bại, k+2 mới giảm → không xác nhận muộn.
- Upthrust-like ngoài Distribution → không gán UTAD.

## 23. Trạng thái triển khai

D01–D20 đã được chủ dự án phê duyệt và khóa ở PR #16. AFL trên PR #13 phải bám đúng tài liệu này. Trạng thái sau khi căn chỉnh chỉ được gọi `SPEC-ALIGNED / UNTESTED DEVELOPMENT` cho đến khi chiến dịch kiểm thử được mở lại.
