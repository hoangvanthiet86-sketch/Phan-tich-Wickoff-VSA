# SOW / LPSY v0.1 — Kiểm toán phù hợp tĩnh D01–D31

**Kết luận:** `STATIC SPEC CONFORMANCE = PASS` trong phạm vi đọc mã nguồn. Đây **không** phải Verify Syntax hay nghiệm thu runtime AmiBroker.

## Phạm vi

Đối chiếu:

- đặc tả D01–D31 đã khóa tại PR #23 / merge `7670532a230eb051cf5d362be092e2d81283fb92`;
- `afl/WyckoffVSA_RangeContext_SOWLPSY_v0.1.afl`;
- `docs/wyckoff-event-sow-lpsy-v0.1-implementation-contract.md`.

## Ma trận D01–D31

| Quyết định | Tĩnh | Bằng chứng triển khai |
|---|---|---|
| D01 | PASS | Chỉ công bố SOW-LIKE/LPSY-LIKE và descriptors; không phase/distribution conclusion. |
| D02 | PASS | Include Structural Sequence D29 facade; range lấy từ WSS lower/upper frozen active snapshots. |
| D03 | PASS | Hai stream `WE_SW_L_*` và `WE_SW_U_*` độc lập; cùng bar có thể phát cả hai. |
| D04 | PASS | Price challenge dùng PreviousClose>=RangeLow, Low<=RangeLow, Close<PreviousClose. |
| D05 | PASS | SOW-LIKE chỉ nâng khi RSpread>=1.20 và RVOL>=1.25; effort validity tách price observation. |
| D06 | PASS | Support relation 1/2/3; AcceptedBreakdown strict Close<RangeLow; equality không breakdown. |
| D07 | PASS | ClosePosition chỉ descriptor; WeakClose `<0.40`, không gate SOW. |
| D08 | PASS | DirectionalProgress/AbsDirectionalProgress/EffortResult chỉ snapshot descriptor. |
| D09 | PASS | Không loại SOW khi StoppingVolume/Absorption tồn tại; upstream event arrays giữ nguyên. |
| D10 | PASS | SOWCode phát tại k; response tại k+1 dùng Ref(...,-1), không sửa SOWCode quá khứ. |
| D11 | PASS | SOW snapshot gồm range key constituents, OHLC, measurements, breakdown, Stopping/Absorption, S/M/L, response anchor. |
| D12 | PASS | SOW ordinal tăng theo range, không có cờ cấm SOW tiếp theo. |
| D13 | PASS | Latest SOW trên current RangeAnchorKey trở thành active scalar anchor cho future LPSY. |
| D14 | PASS | Active SOW reset bởi new SOW, new range cùng channel hoặc completed Close>frozen RangeHigh; không timeout. |
| D15 | PASS | LPSY chỉ xét khi `SL_PivotHighEventCode==2`; không dùng k+1 tùy ý. |
| D16 | PASS | Yêu cầu PivotHighExtremeBI>SOWBI và PivotHigh>SOWClose. |
| D17 | PASS | LPSY strict `PivotHigh<RangeHigh`; `>=` phát UpperRangeChallengeAfterSOW thay vì label. |
| D18 | PASS | Không ATR/% distance gate; xuất RangePosition và DistanceToRangeLow/High. |
| D19 | PASS | NoDemand/RVOL/RSpread không nằm trong identity gate LPSY. |
| D20 | PASS | Snapshot Narrow/VeryNarrow, contraction, CP, DP, EffortResult, ND candidate/confirmation, Upthrust overlap. |
| D21 | PASS | EvidenceClass 0..4 categorical; Class2 demand-diminution, Class3 high-effort/poor-result, Class4 mixed; không score. |
| D22 | PASS | ND confirmed scan chỉ lấy candidate sau active SOW và không vượt LPSY extreme; unrelated background không kéo vào. |
| D23 | PASS | Origin extreme và confirmation/KnownAt coordinates xuất riêng; label chỉ viết tại confirmation bar. |
| D24 | PASS | LPSY ordinal tăng và active SOW không bị tắt sau LPSY đầu tiên. |
| D25 | PASS | Không ghi đè Structural ST/Upthrust; Upthrust chỉ snapshot overlap; range-high challenge giữ observation. |
| D26 | PASS | Không có Distribution/Redistribution/Phase D/E assignment. |
| D27 | PASS | AFL xuất đầy đủ tuple constituents cho RangeAnchorKey, SOWEventKey và LPSYEventKey; không hash dễ collision. |
| D28 | PASS | Range/price/effort/pivot/quality validity tách theo bước; quality thiếu không xóa LPSY identity. |
| D29 | PASS | Chỉ confirmed pivot/current-past data; Ref chỉ offset -1; forming bar được ghi provisional trong header/contract. |
| D30 | PASS | Không Buy/Sell/Short/Cover/PositionSize, P&F, weighted score hay auto-tuning. |
| D31 | PASS | Triển khai nằm trên nhánh riêng xếp chồng PR #21; không sửa Structural Sequence và không viết Phase Engine. |

## Kiểm tra nhân quả tĩnh

- `#include_once` đi xuống D29 facade; không có dependency từ Structural Sequence ngược lên SOW/LPSY.
- Mọi `Ref()` trong module SOW/LPSY dùng offset `-1` cho PreviousClose hoặc immediate response.
- LPSY dùng confirmed Pivot High và `ConfirmationLag` để truy cập extreme đã được upstream xác nhận.
- Không có Zig/Peak/Trough, future quote hoặc positive Ref.
- SOW tại k và LPSY KnownAt tại pivot confirmation bar được giữ tách biệt với origin coordinates.

## Kiểm tra state ordering

Trong loop, thứ tự là:

1. nhận biết range supersession/invalidation;
2. hủy active SOW nếu giá đã đóng vượt RangeHigh;
3. cho confirmed Pivot High hiện tại đánh giá LPSY trên **SOW anchor đã tồn tại trước thanh hiện tại**;
4. sau đó mới cho SOW mới tại chính thanh hiện tại thay active SOW.

Thứ tự này cho phép một thanh giảm vừa xác nhận Pivot High của rally trước (LPSY) vừa trở thành SOW mới, mà không gắn pivot lịch sử vào SOW vừa mới xuất hiện.

## Evidence Class D21

Mapping triển khai:

- Class 2 khi CE No Demand confirmed đúng extreme, hoặc NarrowSpread + RVOL contraction so với SOW;
- Class 3 khi RVOL ở high-effort band (`>=1.80`) và Core Effort/Directional Result code = 3 (`HIGH EFFORT / LOW DIRECTIONAL RESULT`);
- Class 4 khi Class2 và Class3 cùng xuất hiện, hoặc có weak-rally evidence phụ trợ nhưng không đủ một route sạch;
- Class 1 khi structural LPSY có quality data nhưng không có weak-rally descriptor nêu trên;
- Class 0 khi không có quality data đủ để phân lớp.

Đây là categorical routing theo D21, không phải xác suất hay điểm tổng hợp.

## Những gì chưa được kiểm chứng

Static PASS không chứng minh:

- AmiBroker 6.20.01 Verify Syntax;
- semantics runtime của stateful loop/array indexing;
- fixture/expected cho hai range channel và same-bar overlap;
- regression upstream;
- causality prefix / append stability;
- source-revision behavior;
- forming-bar behavior trên dữ liệu realtime;
- hiệu năng của No Demand scan trên lịch sử dài.

Các hạng mục này tiếp tục được hoãn theo chiến lược build-first hiện tại.

**STATIC SPEC CONFORMANCE = PASS**
