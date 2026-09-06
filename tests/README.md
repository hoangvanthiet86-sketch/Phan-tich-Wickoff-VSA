# Core Engine v1.0 — Runtime Test Plan

Runtime target là **AmiBroker 6.20+**. Chạy AFL trong Analysis/Exploration trên controlled OHLCV fixtures và đối chiếu từng audit column. Static inspection không thay thế compilation/runtime test.

## Core cases

| # | Case | Thiết lập và expected behavior |
|---:|---|---|
| 1 | Normal bar | Sau prior-only warm-up, current Volume/RawSpread bằng prior base: RVOL/RSpread xấp xỉ 1, state NORMAL. |
| 2 | Ultra High Volume | Current Volume ít nhất 2.5 prior base: RVOL phản ánh đúng và ULTRA HIGH. |
| 3 | Low Volume | RVOL dưới/đến 0.75: LOW hoặc EXTREMELY LOW theo exact boundary. |
| 4 | Narrow Spread | Current RawSpread thấp hơn 0.8 prior base: NARROW/VERY NARROW. |
| 5 | Wide Spread | Current RawSpread ít nhất 1.2 prior base: WIDE/VERY WIDE. |
| 6 | Close near High | ClosePosition gần 1 và state vị trí tương ứng. |
| 7 | Close near Low | ClosePosition gần 0 và state vị trí tương ứng. |
| 8 | Zero-range current candle | High = Low = Close: RawSpread 0, ClosePosition 0.5/MID CLOSE, không chia zero. |
| 9 | High Effort / Low Directional Result | RVOL >= 1.80, absolute progress <= 0.35: code/text đúng state. |
| 10 | High Effort / High Directional Result | RVOL >= 1.80, absolute progress >= 0.80: code/text đúng state. |
| 11 | Invalid/zero baseline | Measurement liên quan Null/code 0, không Infinity/NaN. |
| 12 | Initial warm-up | Với lookback N, bar sớm nhất có N prior observations là index N; trước đó code 0. |
| 13 | Look-ahead | Thay future bars nhưng giữ history đến bar audit; output bar audit không đổi; mọi Ref dùng -1. |

## Prior-only architecture invariants

### Volume outlier

Tạo 20 prior bars có Volume `1,000,000`, current Volume `10,000,000`. Expected `PriorVolumeValidCount = 20`, `PriorVolumeBase = 1,000,000`, `RVOL = 10.0`. Thay current Volume tiếp tục không được đổi own PriorVolumeBase.

### Spread outlier

Tạo 20 prior RawSpread bằng/trung bình `2`, current RawSpread `8`. Expected `PriorSpreadValidCount = 20`, `PriorSpreadBase = 2`, `RSpread = 4.0`. Thay current spread không được đổi own PriorSpreadBase.

### Prior ATR

Với PreviousClose `100`, CurrentClose `104`, PriorATR `2`, expected RawDirectionalMove `4`, DirectionalProgress `2.0`. Làm current True Range/current ATR tăng không được đổi PriorATR của chính bar đó.

## Invalid internal data

- Một prior Volume `Null`: valid count `< N`, PriorVolumeBase/RVOL Null, code 0.
- Một prior Volume âm: cùng kết quả; không coi là zero hợp lệ.
- Prior Volume bằng zero: vẫn tăng valid count. Nếu các observation khác làm base dương thì baseline hợp lệ.
- Toàn bộ prior Volume bằng zero: valid count `N`, base denominator không dương, RVOL Null/code 0.
- Một prior High/Low invalid: RawSpreadValid 0, prior spread count `< N`, PriorSpreadBase/RSpread Null.
- Prior zero-range OHLC hợp lệ: RawSpread 0 và vẫn tăng valid count.
- Toàn bộ prior RawSpread bằng zero: valid count `N`, denominator zero, RSpread Null/code 0.
- PriorATR Null hoặc zero: DirectionalProgress/absolute progress Null, Effort/Directional Result code 0.
- Current High invalid nhưng Current Close valid: RawSpread/RSpread/ClosePosition Null; DirectionalProgress vẫn valid nếu PreviousClose và PriorATR valid.
- Current Low invalid nhưng Current Close valid: expected giống Current High invalid.
- Current Close invalid với High/Low valid: RSpread có thể valid; ClosePosition và DirectionalProgress invalid.

Không skip, forward-fill hoặc interpolate invalid prior observation.

## Dependency matrix

| Current data | RSpread | ClosePosition | DirectionalProgress |
|---|---|---|---|
| High invalid | Invalid | Invalid | Can remain valid if Close/PreviousClose/PriorATR valid |
| Low invalid | Invalid | Invalid | Can remain valid if Close/PreviousClose/PriorATR valid |
| Close invalid, High/Low valid | Can remain valid | Invalid | Invalid |
| High/Low/Close valid | Normal dependency | Normal dependency | Normal dependency |

## RSpread close-independence and prior-only tests

1. Bar A `High=110, Low=100, Close=110`; Bar B `High=110, Low=100, Close=100`, with the same PriorSpreadBase. Expected RawSpread A/B both `10`, RSpread equal, ClosePosition different.
2. Current Close invalid with valid High/Low: RSpread can remain valid; ClosePosition and DirectionalProgress invalid.
3. Current High invalid: RSpread/ClosePosition invalid; DirectionalProgress evaluated independently from Close/PreviousClose/PriorATR.
4. Current Low invalid: same dependency behavior.
5. Zero-range current High/Low: RawSpread `0`, RawSpreadValid `1`, RSpread `0` when prior base positive.
6. Prior window all zero: valid count `N`, PriorSpreadBase denominator zero, RSpread Null.
7. One invalid prior RawSpread: valid count `< N`, RSpread Null.
8. Prior-only outlier: 20 prior RawSpread `2`, current `8`; PriorSpreadBase remains `2`, RSpread `4`.
9. Changing current Close inside the same valid High-Low range must not alter RSpread.

## Completed-bar semantics

All runtime fixtures must use completed bars. On a forming latest bar, Volume is partial, High/Low may expand and Close is not final; RVOL, RSpread, ClosePosition, DirectionalProgress and Effort/Directional Result are provisional. Tests must not treat incomplete-bar categories as final evidence.

## Deterministic PriorATR warm-up

With `ATRPeriod = 14`:

- `BarIndex` 0 through 13: `PriorATRWarm = 0`; DirectionalProgress invalid.
- `BarIndex` 14: `PriorATRWarm = 1`; DirectionalProgress may become valid only when CurrentCloseValid, PreviousCloseValid, PriorATR non-Null and PriorATR `> 0` all pass.
- Passing warm-up alone must not force a valid DirectionalProgress.

With custom `ATRPeriod = 20`, earliest eligible current bar is `BarIndex = 20`. Exploration columns `BarIndex` and `Prior ATR Warm` must show the boundary directly.

## Data-quality fixture assumption

Runtime fixtures and production data must follow a consistent adjusted/unadjusted OHLCV policy. Stock splits or inconsistent corporate-action adjustment can create artificial relative-measurement anomalies; Core Engine v1.0 does not detect or repair them.

## Threshold configuration safety

- Valid defaults: low effort `<` high effort và low directional result `<` high directional result; classification hoạt động bình thường.
- Equal effort thresholds: code 10, `INVALID THRESHOLD CONFIG`.
- Reversed effort thresholds: code 10.
- Equal directional-result thresholds: code 10.
- Reversed directional-result thresholds: code 10.
- Khi config invalid, HighEffort/LowEffort và HighDirectionalResult/LowDirectionalResult đều bị validity gate chặn; không có cặp High/Low cùng được classification.
- Exploration phải hiển thị đủ bốn threshold values và `Threshold Config Valid`.

## Exact boundary matrix

| Measurement | Input | Expected text |
|---|---:|---|
| RVOL | 0.50 | LOW |
| RVOL | 0.75 | LOW |
| RVOL | 1.25 | HIGH |
| RVOL | 1.80 | VERY HIGH |
| RVOL | 2.50 | ULTRA HIGH |
| RSpread | 0.60 | NARROW |
| RSpread | 0.80 | NORMAL |
| RSpread | 1.20 | WIDE |
| RSpread | 1.60 | VERY WIDE |
| ClosePosition | 0.25 | LOWER CLOSE |
| ClosePosition | 0.40 | MID CLOSE |
| ClosePosition | 0.60 | MID CLOSE |
| ClosePosition | 0.75 | UPPER CLOSE |
| Effort | 0.75 | LOW |
| Effort | 1.80 | HIGH |
| Directional Result | 0.35 | LOW |
| Directional Result | 0.80 | HIGH |

## Exploration state-code/text mapping

Scan multiple historical rows spanning every category. Verify numeric state code against the tables in the specification and verify adjacent `AddMultiTextColumn()` text changes per row. Code 0 must render `INSUFFICIENT DATA`; code 10 must render `INVALID THRESHOLD CONFIG`. State codes are categories, never scores.

## Acceptance and recorded limitations

- Verify all audit columns allow recomputing current/prior ratios.
- Verify no positive `Ref()` and future edits do not change historical output.
- Record AmiBroker version, compile result, Exploration output, chart title/date rendering, Param behavior, Null behavior, ATR behavior and zero-range behavior.
- Do not report AmiBroker pass until these checks actually run in AmiBroker.
