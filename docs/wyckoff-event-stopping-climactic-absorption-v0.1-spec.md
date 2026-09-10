# Stopping Volume / Climactic Effort / Absorption v0.1 — Hợp đồng triển khai

**Trạng thái:** `SPEC-ALIGNED / UNTESTED DEVELOPMENT`.

Nguồn chuẩn đã được chủ dự án phê duyệt tại PR #18 và hợp nhất vào `main` ở commit `e9c1d1078a24474da1fa674810775389161ef631`:

`docs/wyckoff-event-stopping-climactic-absorption-v0.1-spec-draft.md`

Tài liệu này không thay thế đặc tả đã khóa. Nó ghi lại cách AFL trên nhánh triển khai ánh xạ D01–D26.

## 1. Ranh giới

Lớp Event chỉ công bố:

- `CLIMACTIC-EFFORT-LIKE`;
- `ABSORPTION-LIKE OBSERVATION`;
- `STOPPING-VOLUME-LIKE`;
- `IMMEDIATE RESPONSE` của Stopping Volume.

Không công bố `SC`, `BC`, `PS`, `PSY`, Accumulation, Distribution hay bất kỳ tín hiệu giao dịch nào.

## 2. D01–D07 — Climactic Effort

- D01: dùng nhãn `-LIKE`, không nâng thành SC/BC.
- D02: đọc trực tiếp RVOL, RSpread, ClosePosition, DirectionalProgress, AbsDirectionalProgress, PriorATR từ Core; không tính lại baseline.
- D03: `ElevatedExpansion = RSpread>=1.20 AND RVOL>=1.25`; `ClimacticEffort = RSpread>=1.60 AND RVOL>=1.80`; `UltraEffort = RVOL>=2.50` chỉ là descriptor.
- D04: `ClimacticEffortCode`: 0 insufficient, 1 not present, 2 climactic-effort-like; event được biết tại chính thanh k.
- D05: DirectionCode chỉ dựa trên Close so với PreviousClose và không suy ra SC/BC.
- D06: ClosePosition không gate Climactic; `>0.75` strong close, `<0.25` weak close chỉ là descriptor.
- D07: Climactic Effort không đồng nghĩa stopping/reversal.

## 3. D08–D10 — Absorption

`AbsorptionCode=2` khi:

```text
PriceValid = 1
RVOLValid = 1
DirectionalProgressValid = 1
RVOL >= 1.80
AbsDirectionalProgress <= 0.35
```

RSpread và ClosePosition chỉ là descriptor.

Pressure descriptors độc lập:

```text
DownsidePressureObserved = Low < PriorLow OR Close < PreviousClose
UpsidePressureObserved   = High > PriorHigh OR Close > PreviousClose
```

Cả hai cờ có thể cùng bằng 1. Một thanh Absorption không được suy ra phía hấp thụ hay kết luận quá trình absorption nhiều thanh.

## 4. D11–D15 — Stopping Volume-like

`StoppingVolumeCode=2` khi:

```text
PriceValid = 1
PriorPriceValid = 1
RVOLValid = 1
ClosePositionValid = 1
RVOL >= 1.80
DownsidePressureObserved = 1
ClosePosition >= 0.50
```

Không dùng RSpread làm gate.

Quality descriptors:

- `UpperCloseFlag = ClosePosition > 0.60`;
- `StrongRecoveryCloseFlag = ClosePosition > 0.75`.

Không bắt buộc AbsorptionCode=2 và không hard-code prolonged decline. S/M/L, khoảng cách lower reference, DirectionalProgress và prior Pivot Low chỉ là context.

## 5. D16–D17 — Immediate Response

Stopping Volume-like tại k không bị viết lại bởi dữ liệu tương lai.

Chỉ tại k+1:

```text
Low_(k+1) >= Low_k
Close_(k+1) > Close_k
```

thì `StoppingResponseCode=3`.

Nếu không đạt thì code2; dữ liệu evaluation không hợp lệ thì code0; không có origin ở k thì code1. Không có late confirmation tại k+2.

ClimacticEffortCode và AbsorptionCode không có resolution tương lai.

## 6. D18–D21 — Overlap, snapshot và ranh giới cấu trúc

Các kênh độc lập, không ưu tiên hay ghi đè. Một thanh có thể đồng thời là Climactic, Absorption và Stopping Volume.

Stopping Response mang frozen snapshot của origin qua `Ref(...,-1)` gồm tọa độ, OHLC, RVOL/RSpread/ClosePosition và context được xuất.

Spring/Shakeout, Supply Test, SOS/LPS và Upthrust chỉ là context chéo. Canonical PS/SC/AR/ST và PSY/BC/AR/ST dành cho Structural Sequence/Phase Engine.

## 7. D22–D24 — Validity, biên và nhân quả

Mỗi kênh có validity riêng:

- thiếu RSpread chỉ làm Climactic insufficient, không làm Stopping Volume mất khả năng đánh giá;
- thiếu DirectionalProgress chỉ làm Absorption insufficient;
- thiếu ClosePosition chỉ làm Stopping Volume insufficient.

Biên được bao hàm:

- Climactic `RSpread>=1.60`, `RVOL>=1.80`;
- Absorption `RVOL>=1.80`, `AbsDirectionalProgress<=0.35`;
- Stopping `RVOL>=1.80`, `ClosePosition>=0.50`.

Pressure dùng so sánh strict. Không epsilon, không làm tròn trước so sánh.

Chỉ dùng dữ liệu hiện tại/prior; mọi `Ref()` của mô-đun phải có offset `-1`. Không Zig/Peak/Trough look-ahead, không backfill. Thanh cuối chưa được nguồn xác nhận hoàn tất chỉ là provisional.

## 8. D25–D26 — Không giao dịch và Exploration

Không gán Buy/Sell/Short/Cover/PositionSize, stop, target hay xác suất.

Exploration xuất độc lập code/valid/reason, tọa độ, measurement, pressure descriptors, S/M/L context, prior Pivot Low và frozen response coordinates.

## 9. Mốc kiểm thử

Theo quyết định hiện tại của chủ dự án, Verify Syntax AmiBroker 6.20.01, fixture/expected, hồi quy, causal/append và forming-bar được hoãn đến chiến dịch kiểm thử tổng thể.

Do đó tài liệu và AFL hiện chỉ được gọi là `SPEC-ALIGNED / UNTESTED DEVELOPMENT`, không phải PASS hay release-ready.
