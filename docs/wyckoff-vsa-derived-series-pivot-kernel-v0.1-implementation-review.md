# Wyckoff VSA Derived-Series Pivot Kernel v0.1 — Rà soát triển khai

**Trạng thái:** `SPEC-ALIGNED / UNTESTED DEVELOPMENT`.

## Mốc chuẩn

- Relative Strength Context R01–R36 đã khóa tại PR #32, merge `2dedab4168c4845b66a92021ce9a59137a939e82`.
- Derived-Series Pivot Kernel K01–K32 đã được chủ dự án phê duyệt tại PR #33, merge `dcd028447314d49066d0904168ffcf95ed078121`.
- R35 yêu cầu cùng confirmed-pivot semantics với Structure/Location v1.0 trước full Relative Strength AFL.

## Tệp triển khai

- `afl/WyckoffVSA_DerivedSeriesPivotKernel_v0.1.afl`
- `afl/WyckoffVSA_DerivedSeriesPivotKernel_EquivalenceAudit_v0.1.afl`

## Kiến trúc

Kernel là generic derived-series facade, không sửa released Structure/Location v1.0 và không tạo Wyckoff/VSA interpretation mới.

Một channel nhận:

- numeric derived series;
- explicit validity array;
- `PivotLeft/PivotRight`;
- source BarIndex/DateTime;
- logical source offset.

Kernel xuất window diagnostics, Pivot High/Pivot Low event, Extreme/Confirm coordinates, `Latest` và `LatestPrior` snapshots dưới namespace `WDP_<channel>_...`.

## Behavioral oracle mapping

Implementation cố ý giữ cùng control flow với `SL_CalcPivotKind`:

1. candidate tại `i-B`;
2. High: strict `>` ở cửa sổ trái, inclusive `>=` ở cửa sổ phải;
3. Low: strict `<` ở cửa sổ trái, inclusive `<=` ở cửa sổ phải;
4. publication chỉ tại confirm bar `i`;
5. `LatestPrior` chụp trước khi đánh giá `i`;
6. `Latest` chụp sau khi đánh giá `i`;
7. Age/BarsSinceConfirmation dùng logical offsets;
8. window phải đủ `A+B+1` và toàn bộ validity đúng.

## R35 equivalence harness

`WyckoffVSA_DerivedSeriesPivotKernel_EquivalenceAudit_v0.1.afl` chạy:

- derived kernel trên `High` và so cell-by-cell với `SL_PivotHigh...`;
- derived kernel trên `Low` và so cell-by-cell với `SL_PivotLow...`;
- so cả window diagnostics, Event, Extreme/Confirm, Latest, LatestPrior, Age/BarsSinceConfirmation.

Harness xuất mismatch flags và mismatch counts.

**Quan trọng:** harness đã được viết nhưng chưa được chạy trên AmiBroker 6.20.01. Vì vậy chưa được ghi `0 mismatches` và chưa coi đây là native proof.

## Giới hạn

Chưa thực hiện:

- Verify Syntax AmiBroker 6.20.01;
- chạy cell-by-cell equivalence harness;
- equal-left/equal-right controlled fixtures;
- missing-derived-value fixture;
- first-eligible-bar fixture;
- current-confirm-bar Latest-vs-LatestPrior fixture;
- causal-prefix/append regression;
- performance audit.

Do đó trạng thái vẫn là `SPEC-ALIGNED / UNTESTED DEVELOPMENT`.