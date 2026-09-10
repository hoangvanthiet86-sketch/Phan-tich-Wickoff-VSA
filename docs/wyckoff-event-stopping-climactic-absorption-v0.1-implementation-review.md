# Stopping Volume / Climactic Effort / Absorption v0.1 — Hồ sơ triển khai

**Trạng thái:** `SPEC-ALIGNED / UNTESTED DEVELOPMENT`.

## 1. Mốc đặc tả

- PR #18 đã được chủ dự án phê duyệt và hợp nhất vào `main`.
- Merge commit khóa đặc tả: `e9c1d1078a24474da1fa674810775389161ef631`.
- Đặc tả chuẩn: `docs/wyckoff-event-stopping-climactic-absorption-v0.1-spec-draft.md` trên `main`.
- Hợp đồng ánh xạ triển khai trên nhánh này: `docs/wyckoff-event-stopping-climactic-absorption-v0.1-spec.md`.
- AFL: `afl/WyckoffVSA_Event_StoppingClimacticAbsorption_v0.1.afl`.

## 2. Nền xếp chồng

Nhánh triển khai:

`event/stopping-climactic-absorption-v0.1-development`

được tạo từ head đã căn chỉnh của SOS/LPS:

`54c3e8a34a92ac496ab2acdae4fa081b9c3d3802`

Mục tiêu là giữ diff của PR tiếp theo chỉ chứa mô-đun Effort/Result mới, không hợp nhất các Event chưa kiểm thử vào `main`.

## 3. Ánh xạ logic chính

### Climactic Effort

- Elevated Expansion: `RSpread>=1.20 AND RVOL>=1.25`.
- Climactic Effort: `RSpread>=1.60 AND RVOL>=1.80`.
- UltraEffort: `RVOL>=2.50` chỉ là descriptor.
- Direction chỉ mô tả Close so với PreviousClose.
- ClosePosition, DirectionalProgress và PriorATR là descriptor, không gate.

### Absorption

- `RVOL>=1.80`.
- `AbsDirectionalProgress<=0.35`.
- RSpread không phải gate.
- Pressure up/down được xuất độc lập từ quan hệ High/Low/Close với thanh trước.
- Không suy ra supply absorbed/demand absorbed từ một thanh.

### Stopping Volume-like

- RVOL >=1.80.
- Có downside pressure: `Low<PriorLow OR Close<PreviousClose`.
- ClosePosition >=0.50.
- Không yêu cầu RSpread rộng.
- Không yêu cầu AbsorptionCode=2.
- Không hard-code prolonged decline.

### Immediate Response

Origin tại k được giữ nguyên. Chỉ tại k+1:

```text
Low_(k+1) >= Low_k
AND Close_(k+1) > Close_k
```

thì `StoppingResponseCode=3`.

Không xác nhận muộn và không backfill.

## 4. Kiến trúc và tính độc lập

AFL chỉ include:

`WyckoffVSA_Confirmation_v1.0.afl`

Mô-đun đọc measurement/context upstream nhưng không sửa Core, Candidate, Structure/Location hay Confirmation.

Ba event channel độc lập; không có logic ưu tiên hay ghi đè. Các nhãn canonical SC/BC/PS/PSY không tồn tại trong Event layer này.

## 5. Kiểm toán tĩnh đã thực hiện ở mức mã nguồn

Đã thiết kế mã để:

- chỉ dùng `Ref(...,-1)` cho dữ liệu prior và snapshot k→k+1;
- không dùng Zig/Peak/Trough/ValueWhen/LastValue để suy ra tương lai;
- không gán Buy/Sell/Short/Cover/PositionSize;
- không thay `Filter` upstream;
- validity của Climactic, Absorption và Stopping Volume tách riêng;
- response dùng frozen origin snapshot, không thay bằng context tại k+1;
- cho phép cùng thanh vừa resolve Stopping Volume trước vừa tạo event mới.

Đây mới là kiểm toán thiết kế/tĩnh, **không phải Verify Syntax hoặc native acceptance**.

## 6. Việc chưa thực hiện

Theo quyết định build-first hiện tại, chưa thực hiện:

- Verify Syntax trên AmiBroker 6.20.01;
- fixture/expected độc lập;
- kiểm thử biên 1.20/1.25/1.60/1.80/2.50/0.35/0.50/0.60/0.75;
- kiểm thử malformed/Null/Infinity;
- hồi quy upstream;
- causal P/A/B;
- append P+Q;
- forming-bar/live-bar;
- nghiệm thu release.

Không được gọi mô-đun là PASS trước khi các hạng mục phù hợp được hoàn tất hoặc có quyết định ngoại lệ riêng của chủ dự án.

## 7. Bước sau

Sau mô-đun này, bước thiết kế tiếp theo theo đặc tả PR #18 là nghiên cứu và xây **Structural Sequence Engine cho PS/SC/AR/ST và PSY/BC/AR/ST**, trước khi xây Phase Engine.
