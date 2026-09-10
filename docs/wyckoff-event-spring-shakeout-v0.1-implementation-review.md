# Spring / Shakeout Event v0.1 — Hồ sơ triển khai sau phê duyệt đặc tả

**Trạng thái:** `SPEC-ALIGNED / UNTESTED DEVELOPMENT`.

Chủ dự án đã phê duyệt đặc tả D01–D14 tại PR #15. PR #15 được hợp nhất vào `main` tại commit `ea5d1304d6751ad4a8c2b88c69f19d799c79bd8b`. Kiểm thử native/fixture/expected vẫn chủ động tạm hoãn để ưu tiên hoàn thiện bộ chỉ báo.

## 1. Nền phát triển

Nhánh `event/spring-shakeout-v0.1-development` được xếp chồng trên PR #10 Supply Test. Vì Supply Test chưa nghiệm thu và chưa merge `main`, Spring/Shakeout cũng chưa được coi là sẵn sàng phát hành hay hợp nhất sản xuất.

## 2. Tệp triển khai

- `docs/wyckoff-event-spring-shakeout-v0.1-spec.md` — hợp đồng D01–D14 đã phê duyệt;
- `afl/WyckoffVSA_Event_SpringShakeout_v0.1.afl` — AFL đã chỉnh theo hợp đồng;
- tài liệu hồ sơ này.

Không sửa Core, Candidate, Structure/Location, Confirmation hoặc Supply Test.

## 3. Các sai khác của bản PR #12 ban đầu đã được sửa

### 3.1. D05 — Origin không còn phụ thuộc RVOL/RSpread

Bản AFL ban đầu yêu cầu `RVOLValid` và `RSpreadValid` để OriginCode có thể bằng 2. Điều này không đúng đặc tả được phê duyệt.

Bản hiện tại tách:

- `WE_SS_OriginCode`: chỉ dựa vào giá, support, PriorATR, xuyên-thu hồi và ClosePosition;
- `WE_SS_OriginKindCode`: dùng RVOL/RSpread để phân loại.

Nếu effort data thiếu nhưng hành vi giá hợp lệ, OriginCode vẫn bằng 2; KindCode bằng 0 `INSUFFICIENT EFFORT DATA`.

### 3.2. D06 — Không còn ép mọi origin vào Spring hoặc Shakeout

Bản ban đầu coi xuyên sâu hơn 0.50 ATR là Shakeout-like ngay cả khi effort thấp và mặc định phần còn lại thành Spring-like.

Bản hiện tại thực hiện đúng ba nhãn:

- `SPRING-LIKE`: PenetrationATR <=0.50, RVOL<1.25, RSpread<1.20;
- `SHAKEOUT-LIKE`: RVOL>=1.25 và RSpread>=1.20;
- `AMBIGUOUS RECLAIM`: effort hợp lệ nhưng không thỏa rõ hai nhóm trên.

### 3.3. D09/D11 — Bổ sung Kind và snapshot kiểm toán

Đã bổ sung:

- `WE_SS_OriginKindValid`;
- `WE_SS_ConfirmedKindCode` / `WE_SS_ConfirmedKindValid`;
- RVOL/RSpread cùng validity tại origin;
- Age/BarsSinceConfirmation của pivot support;
- các tọa độ pivot extreme/confirm;
- S/M/L context snapshot phục vụ nghiên cứu;
- SupportHeld và CloseImproved tại evaluation.

ConfirmedKind chỉ mang nguyên Kind của origin; không phân loại lại ở k+1.

## 4. Logic hiện tại sau căn chỉnh

Origin tại k yêu cầu:

```text
Low_k < SupportPrice
Close_k >= SupportPrice
0 < PenetrationATR <= 1.00
ClosePosition_k >= 0.50
```

Support là pivot Low gần nhất đã xác nhận trước k. RVOL/RSpread không quyết định OriginCode.

Resolution duy nhất ở k+1:

```text
Low_{k+1} >= SupportPrice_k
Close_{k+1} > Close_k
```

Không xác nhận muộn tại k+2; không backfill; pivot mới ở k+1 không thay support snapshot.

## 5. Trạng thái đối chiếu đặc tả

Sau chỉnh sửa mã nguồn, các điểm D01–D14 đã được **căn chỉnh về mặt triển khai nguồn** với đặc tả đã phê duyệt. Đây là kết luận review mã, không phải kết quả kiểm thử AmiBroker.

Không được suy diễn `SPEC-ALIGNED` thành `PASS` vì các bước sau chưa chạy:

- Verify Syntax trên AmiBroker 6.20.01;
- fixture/expected độc lập cho Spring/Shakeout;
- đối chiếu native;
- hồi quy upstream;
- kiểm thử nhân quả/no-lookahead;
- append;
- source revision vs repaint;
- forming-bar/provisional.

## 6. Quan hệ với các PR sau

PR #13 Upthrust/UTAD và PR #14 SOS/LPS được tạo trên chuỗi nhánh trước khi Spring/Shakeout được căn chỉnh theo PR #15. Vì vậy khi tiếp tục các mô-đun đó phải đưa nền mới này vào chuỗi phát triển hoặc sửa lại theo quy trình đặc tả được phê duyệt; không được coi logic cũ của chúng tự động kế thừa các thay đổi này.

## 7. Quy tắc tiếp theo

Từ đây áp dụng bắt buộc cho từng Event mới:

`DỰ THẢO ĐẶC TẢ → CHỦ DỰ ÁN DUYỆT → KHÓA ĐẶC TẢ → CĂN CHỈNH/VIẾT AFL → TẠM HOÃN HOẶC CHẠY KIỂM THỬ THEO QUYẾT ĐỊNH DỰ ÁN`.

PR #12 tiếp tục giữ `draft` và không merge trước chiến dịch kiểm thử tổng thể hoặc quyết định ngoại lệ riêng.