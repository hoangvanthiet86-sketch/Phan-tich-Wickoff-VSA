# Wyckoff VSA Core Engine v1.0 — Specification

Đây là source of truth cho Measurement Engine. Runtime target tối thiểu là **AmiBroker 6.20+**, do Exploration dùng `AddMultiTextColumn()` để render categorical state theo từng historical row.

## 1. Phạm vi và invariant

Engine chỉ có RVOL, RSpread, Close Position, Directional Progress và Effort vs Directional Result. Các dimension độc lập; không có composite score hoặc trading signal.

Invariant nền tảng:

> A measurement of current-bar abnormality must not use the current bar to construct its own historical reference baseline.

Mọi abnormality measurement dùng **Current Observation vs Prior Reference**. Reference là causal và chỉ chứa dữ liệu trước current bar.

## 2. Stable definitions và calibration parameters

Stable mathematical definitions gồm prior-only reference window và prior ATR normalization; thay đổi chúng là thay đổi architecture. Chỉ bốn Effort/Directional Result thresholds là editable calibration parameters có thể hiệu chỉnh sau bằng dữ liệu thực mà không đổi công thức. Các RVOL, RSpread và Close descriptive display bands là fixed constants của v1.0, không phải `Param()`.

| Parameter | Default | Vai trò |
|---|---:|---|
| Volume Lookback | 20 | Số prior Volume observations |
| Spread Lookback | 20 | Số prior RawSpread observations |
| ATR Period | 14 | ATR dùng tại prior bar |
| High Effort RVOL | 1.80 | Calibration boundary high effort |
| Low Effort RVOL | 0.75 | Calibration boundary low effort |
| Low Directional Result ATR | 0.35 | Editable calibration boundary low directional result |
| High Directional Result ATR | 0.80 | Editable calibration boundary high directional result |
| Show Debug Title | No | Selected-bar chart detail |

Lookback/period là số nguyên tối thiểu 2. Bốn editable calibration Params là Low/High Effort RVOL và Low/High Directional Result ATR; chúng không phải universal truth. Configuration chỉ hợp lệ khi mỗi low threshold nhỏ hơn high threshold. Code không reorder hoặc clamp threshold.

## 3. Explicit validity và safe division

`VolumeValid` là numeric 0/1: Volume không `Null` và `>= 0`. `CurrentCloseValid` chỉ yêu cầu Close không `Null` và `> 0`. `PriceInputValid` yêu cầu H/L/C không `Null`, Close `> 0`, High `>= Low`, và `Low <= Close <= High`.

`SpreadInputValid` chỉ yêu cầu High/Low không `Null` và `High >= Low`; RawSpread/RSpread phụ thuộc mask này, không phụ thuộc Close. ClosePosition phụ thuộc `PriceInputValid` đầy đủ. DirectionalProgress chỉ phụ thuộc `CurrentCloseValid`, `PreviousCloseValid` và `PriorATRValid`; lỗi current High/Low không làm dimension này invalid khi ba dependency tối thiểu vẫn hợp lệ.

Rolling reference không dựa vào hành vi implicit của `MA()` với internal `Null`. Mỗi prior window có explicit rolling valid count và sum. Invalid observation đóng góp `0` vào sum chỉ để arithmetic deterministic, nhưng đóng góp `0` vào valid count; baseline luôn bị mask `Null` trừ khi valid count bằng chính xác lookback. Không skip, forward-fill hoặc interpolate invalid data.

Mọi denominator phải dương. Code dùng safe denominator `1` trong biểu thức rồi mask kết quả về `Null` khi validity false; không sinh Infinity/NaN do zero division. Không bật `EveryBarNullCheck`.

## 4. RVOL — current Volume vs prior Volume

Tại bar `t`, với `N = VolumeLookback`:

```text
PriorVolumeValidCount_t = count(valid Volume from t-N ... t-1)
PriorVolumeSum_t        = sum(Volume from t-N ... t-1)
PriorVolumeBase_t       = PriorVolumeSum_t / N
RVOL_t                  = Volume_t / PriorVolumeBase_t
```

AFL tạo rolling count/sum kết thúc tại current bar rồi dùng `Ref(..., -1)`, nên window reference chính xác là `t-N ... t-1`, không chứa `t`.

Baseline chỉ hợp lệ khi valid count `== N` và base `> 0`. Current Volume cũng phải hợp lệ. Zero Volume là valid observation; current zero cho RVOL 0 nếu base dương. Một invalid prior observation làm base/RVOL `Null`. Prior window toàn zero có đủ valid count nhưng base bằng zero nên RVOL `Null`.

Nếu `BarIndex()` bắt đầu từ 0, earliest possible bar có đủ N prior observations là index `N` (với default 20 là index 20), không phải `N-1`. Actual valid count và positive base là nguồn correctness chính.

### RVOL state codes và exact boundaries

| Code | Boundary | Text |
|---:|---|---|
| 0 | invalid | INSUFFICIENT DATA |
| 1 | `< 0.50` | EXTREMELY LOW |
| 2 | `0.50 <= x <= 0.75` | LOW |
| 3 | `0.75 < x < 1.25` | NORMAL |
| 4 | `1.25 <= x < 1.80` | HIGH |
| 5 | `1.80 <= x < 2.50` | VERY HIGH |
| 6 | `>= 2.50` | ULTRA HIGH |

Do đó 0.50/0.75/1.25/1.80/2.50 lần lượt là LOW/LOW/HIGH/VERY HIGH/ULTRA HIGH.

## 5. RSpread — current RawSpread vs prior RawSpread

RSpread là **relative intrabar High-Low range compared with its own prior High-Low history**:

```text
RawSpread_t       = High_t - Low_t
PriorSpreadBase_t = average(RawSpread from t-N ... t-1)
RSpread_t         = RawSpread_t / PriorSpreadBase_t
```

`SpreadInputValid` chỉ yêu cầu High/Low không `Null` và `High >= Low`. `RawSpreadValid` là explicit 0/1 mask. Zero-range bar hợp lệ có RawSpread 0 và vẫn được valid count tính là observation. Prior reference dùng shifted explicit count/sum như Volume. Một invalid prior observation làm base/RSpread `Null`; window toàn zero có base zero và RSpread `Null`. Earliest possible prior-only baseline là bar index `N`.

RSpread không phụ thuộc current Close hoặc ClosePosition và không đo gap. DirectionalProgress giữ riêng net close-to-close progress, bao gồm gap effect. Thay đổi Close bên trong cùng valid High-Low range không được thay đổi RawSpread hoặc RSpread.

RawSpread và PriorSpreadBase có cùng đơn vị giá nên ratio tự triệt tiêu đơn vị. Ví dụ, symbol A có typical/current spread `0.2/0.4` và symbol B có `2/4`; cả hai có RSpread `2`. Không cần chia RawSpread cho current Close để tạo dimensionless comparison.

| Code | Boundary | Text |
|---:|---|---|
| 0 | invalid | INSUFFICIENT DATA |
| 1 | `< 0.60` | VERY NARROW |
| 2 | `0.60 <= x < 0.80` | NARROW |
| 3 | `0.80 <= x < 1.20` | NORMAL |
| 4 | `1.20 <= x < 1.60` | WIDE |
| 5 | `>= 1.60` | VERY WIDE |

## 6. Close Position

`ClosePosition = (Close - Low) / (High - Low)` khi price input hợp lệ. Nếu `High == Low`, giá trị là `0.5`: bar không có directional position trong range nên midpoint là neutral representation. Invalid OHLC trả `Null`.

| Code | Boundary | Text |
|---:|---|---|
| 0 | invalid | INSUFFICIENT DATA |
| 1 | `< 0.25` | WEAK CLOSE |
| 2 | `0.25 <= x < 0.40` | LOWER CLOSE |
| 3 | `0.40 <= x <= 0.60` | MID CLOSE |
| 4 | `0.60 < x <= 0.75` | UPPER CLOSE |
| 5 | `> 0.75` | STRONG CLOSE |

## 7. Directional Progress — current move vs prior ATR

```text
PreviousClose_t          = Ref(Close, -1)
RawDirectionalMove_t     = Close_t - PreviousClose_t
ATRCurrent_t             = AmiBroker built-in ATR(ATRPeriod)_t
PriorATR_t                = Ref(ATRCurrent, -1)
DirectionalProgress_t    = RawDirectionalMove_t / PriorATR_t
AbsDirectionalProgress_t = abs(DirectionalProgress_t)
```

Current Close và Previous Close phải hợp lệ; PriorATR phải không `Null` và `> 0`. Current High/Low không phải dependency của DirectionalProgress. PriorATR eligibility yêu cầu `BarIndex() >= ATRPeriod` ngoài non-Null positive previous-bar ATR. Gate này làm warm-up deterministic và độc lập với built-in early initialization behavior. Passing warm-up không tự buộc DirectionalProgress valid; mọi dependency khác vẫn phải hợp lệ.

Current ATR không làm denominator: current True Range có thể tăng current ATR và tự thay đổi thước đo đánh giá current event. PriorATR đại diện volatility regime đã biết trước bar hiện tại. `PriorATR` là previous-bar value của AmiBroker built-in `ATR(ATRPeriod)`, hàm này sử dụng **Wilder smoothing**; stable definition v1.0 không phải simple moving average của True Range.

## 8. Effort vs Directional Result

**Effort vs Directional Result is a measurement relationship, not the complete VSA Effort-vs-Result interpretation.** Core Engine định nghĩa `Effort = RVOL` và `Directional Result = AbsDirectionalProgress`. RSpread, ClosePosition và signed DirectionalProgress vẫn độc lập. Một VSA interpretation đầy đủ về sau có thể dùng thêm Spread, Close, directional progress, follow-through, location và context; v1.0 không triển khai interpretation đó.

Effort: `<= 0.75` low, `>= 1.80` high, còn lại normal. Directional Result: `<= 0.35` low, `>= 0.80` high, còn lại normal. Vì vậy effort 0.75/1.80 là LOW/HIGH; directional result 0.35/0.80 là LOW/HIGH.

`ThresholdConfigValid` yêu cầu `LowEffortThreshold < HighEffortThreshold` và `LowDirectionalResultThreshold < HighDirectionalResultThreshold`. Invalid configuration được ưu tiên trước market-data classification; code không tạo High/Low/Normal state giả.

| Code | Text |
|---:|---|
| 0 | INSUFFICIENT DATA |
| 1 | HIGH EFFORT / HIGH DIRECTIONAL RESULT |
| 2 | HIGH EFFORT / NORMAL DIRECTIONAL RESULT |
| 3 | HIGH EFFORT / LOW DIRECTIONAL RESULT |
| 4 | NORMAL EFFORT / HIGH DIRECTIONAL RESULT |
| 5 | NORMAL EFFORT / NORMAL DIRECTIONAL RESULT |
| 6 | NORMAL EFFORT / LOW DIRECTIONAL RESULT |
| 7 | LOW EFFORT / HIGH DIRECTIONAL RESULT |
| 8 | LOW EFFORT / NORMAL DIRECTIONAL RESULT |
| 9 | LOW EFFORT / LOW DIRECTIONAL RESULT |
| 10 | INVALID THRESHOLD CONFIG |

Code là mutually-exclusive categorical selector, không phải score. Valid config nhưng invalid market data cho code 0; invalid config cho code 10.

## 9. Output semantics

Exploration xuất raw values, dependency validity, valid counts, prior bases, measurements, threshold values/config validity, state codes và bar-aware text. Numeric codes dùng `AddColumn()`; categorical text dùng `AddMultiTextColumn(arrayCode, textList, name)`. `AddTextColumn()` chỉ dùng cho static Symbol. `WriteIf()` chỉ dùng cho selected-bar chart title, không cho historical-row category.

Chart chỉ plot candlestick và optional debug title. `Filter = 1` cho phép Analysis range/filter quyết định các bar xem; đây không phải market scanner.

## 10. Dependency and completed-bar semantics

| Current data | RSpread | ClosePosition | DirectionalProgress |
|---|---|---|---|
| High invalid | Invalid | Invalid | Can remain valid if Close/PreviousClose/PriorATR valid |
| Low invalid | Invalid | Invalid | Can remain valid if Close/PreviousClose/PriorATR valid |
| Close invalid, High/Low valid | Can remain valid | Invalid | Invalid |
| High/Low/Close valid | Normal dependency | Normal dependency | Normal dependency |

Core Engine v1.0 measurements are considered **FINAL for completed bars**. Nếu latest bar còn hình thành, Volume là partial, High/Low có thể mở rộng và Close chưa final; mọi output của bar đó là provisional và không phải final categorical evidence. v1.0 không tự động vô hiệu hóa current bar hoặc phát hiện market session. Runtime fixtures phải dùng completed bars; incomplete-bar handling có thể thuộc realtime/scanner engine tương lai.

## 11. Causal/look-ahead rules

Mọi `Ref()` có offset `-1`: prior Volume count/sum, prior Spread count/sum, PreviousClose và PriorATR. Không có positive `Ref`, future quotation, Zig, Peak, Trough, centered moving average hoặc future-derived data.

## 12. Data-quality assumption

Relative measurements giả định historical observations trong reference window có tính comparable về kinh tế. Corporate actions như stock splits hoặc dữ liệu OHLCV adjusted/unadjusted không nhất quán có thể tạo RVOL, RSpread hoặc DirectionalProgress anomaly giả. Runtime/production data phải dùng một adjustment policy nhất quán. Core Engine v1.0 không tự động phát hiện split hoặc corporate action.

## 13. Non-goals

Không có trading signal, entry/exit, backtest, pattern/event/phase/range detector, support/resistance, scanner, multi-timeframe, Smart Money inference, position sizing, AI/ML hoặc overall/bullish/bearish/confidence score.
