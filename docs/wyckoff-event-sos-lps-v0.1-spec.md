# Wyckoff Event — SOS / LPS v0.1 — đặc tả triển khai

**Trạng thái:** `SPEC-ALIGNED / UNTESTED DEVELOPMENT`.

Tài liệu chuẩn đã được chủ dự án phê duyệt tại PR #17 và hợp nhất vào `main` tại commit `b21ec3af34481b68e07b8268c6658114a09777fe`:

`docs/wyckoff-event-sos-lps-v0.1-spec-draft.md`

Tài liệu này là hồ sơ triển khai trên PR #14. Nếu có khác biệt, đặc tả D01–D22 đã khóa ở PR #17 là nguồn quyết định.

## 1. Ranh giới

Lớp Event chỉ công bố:

- `SOS-LIKE`;
- `LPS-LIKE`;
- observation/descriptor phục vụ nghiên cứu.

Không công bố `MAJOR SOS`, `CANONICAL LPS`, `BUEC`, `PHASE D` hoặc `ACCUMULATION CONFIRMED`.

Không tạo Buy/Sell/Short/Cover/PositionSize, không quản trị vốn, không chấm điểm xác suất.

## 2. SOS-LIKE

### 2.1. Resistance

Resistance là `SL_PivotHighLatestPrior...` gần nhất đã xác nhận **trước** thanh k. Snapshot phải có giá, ExtremeBarIndex/DateTime, ConfirmBarIndex/DateTime hợp lệ và `ConfirmBarIndex < BarIndex_k`.

### 2.2. Price breakout observation

`WE_SL_SOSPriceBreakoutObservation = 1` khi:

```text
PreviousClose <= Resistance
High > Resistance
Close > Resistance
Close > PreviousClose
```

với dữ liệu giá/resistance/PreviousClose hợp lệ. Breakout dùng strict comparison, không epsilon.

Observation này độc lập với effort và chưa phải SOS-LIKE.

### 2.3. SOS-LIKE classification

`WE_SL_SOSCode = 2` khi price breakout observation tồn tại và:

```text
RSpreadValid = 1
RVOLValid = 1
RSpread >= 1.20
RVOL >= 1.25
```

Hai ngưỡng là quy tắc vận hành v0.1 lấy từ dải Core, không phải hằng số Wyckoff cổ điển.

`ClosePosition` không phải hard gate. `ClosePosition > 0.60` chỉ tạo `WE_SL_SOS_StrongCloseFlag`.

`PriorATR` cũng chỉ phục vụ descriptor penetration/ATR, không phải gate của SOS.

Spring/Shakeout không phải điều kiện bắt buộc của SOS.

### 2.4. SOS snapshot

Khi SOSCode=2 phải đóng băng tối thiểu:

- SOS BarIndex/DateTime, High/Low/Close, PreviousClose;
- BreakoutLevel/Resistance;
- pivot High Extreme/Confirm coordinates và tuổi;
- RSpread/RVOL/ClosePosition cùng validity;
- PriorATR cùng validity;
- penetration và PenetrationATR cùng validity;
- S/M/L context nếu xuất.

## 3. SOS anchor cho LPS

Không có timeout 10 thanh.

Anchor gần nhất duy trì cho candidate tương lai cho đến khi:

1. SOS-LIKE mới xuất hiện và thay anchor;
2. một thanh hoàn tất đóng cửa `Close < frozen BreakoutLevel`, khi đó anchor cũ bị vô hiệu cho các candidate sau;
3. source revision làm snapshot không còn hợp lệ.

Wick `Low < BreakoutLevel` nhưng Close vẫn ở trên không tự hủy anchor, nhưng thanh đó không thể là LPS-LIKE strict-hold.

Phải xuất `BarsSinceSOS`.

## 4. LPS-LIKE origin

LPS origin tại k yêu cầu:

```text
Prior SOS anchor active
Price k hợp lệ
Price k-1 hợp lệ
(Close_k < Close_(k-1) OR Low_k < Low_(k-1))
Low_k >= frozen BreakoutLevel
```

Không bắt buộc:

- `Low <= BreakoutLevel + 0.50*ATR`;
- No Supply Candidate;
- volume thấp;
- spread hẹp tuyệt đối.

`WE_SL_LPSOriginCode`:

- 0 = `INSUFFICIENT DATA`;
- 1 = `NOT PRESENT`;
- 2 = `LPS-LIKE CANDIDATE`.

OriginReasonCode tối thiểu:

- 0: không lỗi / không áp dụng;
- 1: không có SOS anchor active;
- 2: dữ liệu giá origin/prior không hợp lệ;
- 3: không có reaction progress;
- 4: Low xuống dưới frozen BreakoutLevel nhưng Close chưa phá anchor;
- 5: Close xuống dưới BreakoutLevel, anchor bị invalidated;
- 6: snapshot anchor không hợp lệ.

## 5. Descriptor LPS

Khoảng cách tới support:

```text
DistanceAboveBreakout = Low - BreakoutLevel
DistanceAboveBreakoutATR = DistanceAboveBreakout / PriorATR
NearBreakoutEdgeFlag = DistanceAboveBreakoutATR <= 0.50
```

Các trường ATR chỉ có hiệu lực khi ATR hợp lệ và không thay đổi LPS identity.

Chất lượng co cung so với SOS anchor:

```text
SpreadContractedVsSOS = RSpread_k < SOS_RSpread
VolumeContractedVsSOS = RVOL_k < SOS_RVOL
TextbookSupplyContraction = SpreadContractedVsSOS AND VolumeContractedVsSOS
```

No Supply Candidate tại origin và Confirmation No Supply tại evaluation chỉ là context evidence.

## 6. LPS resolution tại k+1

Chỉ resolve candidate của đúng thanh trước.

`LPS-LIKE CONFIRMED` khi:

```text
EvaluationPriceValid = 1
Low_t >= frozen BreakoutLevel
Low_t >= Low_k
Close_t > Close_k
```

Không dùng Confirmation No Supply làm hard gate.

`WE_SL_LPSResolutionCode`:

- 0 = `INSUFFICIENT DATA`;
- 1 = `NO PRIOR LPS-LIKE CANDIDATE`;
- 2 = `LPS-LIKE REJECTED`;
- 3 = `LPS-LIKE CONFIRMED`.

Không late confirmation ở k+2. Nếu k+1 tiếp tục reaction nhưng vẫn giữ support, candidate k bị reject và k+1 có thể tự trở thành candidate mới.

## 7. Nhiều LPS và snapshot bất biến

Một SOS anchor có thể sinh nhiều LPS-LIKE. Không có cờ khóa sau LPS đầu tiên.

Event key logic:

```text
Symbol
+ LPSOriginBarIndex
+ LPSOriginDateTime
+ SOSAnchorBarIndex
+ SOSResistancePivotConfirmBarIndex
```

Resolution phải dùng nguyên snapshot của origin và SOS anchor. SOS/pivot mới tại k+1 không được thay dữ liệu event đang resolve.

## 8. Nhân quả

- Chỉ dùng dữ liệu đã biết tại thời điểm tính.
- Không Zig/Peak/Trough look-ahead.
- Không backfill event.
- Thanh chưa được nguồn xác nhận hoàn tất chỉ provisional.
- Không dùng BarCount để tự suy đoán thanh đã đóng.
- Source revision phải tách biệt với algorithmic repaint.

Kiểm thử native, fixture/expected, hồi quy, causality, append và forming-bar tiếp tục tạm hoãn theo quyết định của chủ dự án.