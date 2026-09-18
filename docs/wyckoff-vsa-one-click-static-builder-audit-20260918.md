# Wyckoff VSA Unified One-Click v0.1 — Static Builder Audit — 2026-09-18

**Nhánh:** `feature/one-click-scanner-v0.1`  
**Phạm vi:** source flattening / helper extraction / presentation stripping trước native AmiBroker compile.

## Kết quả

Builder source dependencies: 17 modules.

Static source checks:
- mọi section mà builder yêu cầu loại bỏ đều tồn tại;
- helper functions phát hiện: 21;
- duplicate helper function names: 0;
- risky brace-in-string/comment lines cho brace-count extractor: 0.

Mô phỏng builder trực tiếp trên source GitHub hiện tại:
- generated helper body: 11,153 ký tự;
- generated analytical body: 302,894 ký tự;
- helper functions: 21;
- analytical `for` loops: 33;
- analytical `while` loops: 0;
- remaining Param calls: 0.

Forbidden tokens trong generated analytical body:
- `#include`: 0
- `#pragma`: 0
- `SetBarsRequired`: 0
- function definitions: 0
- `AddColumn/AddTextColumn/AddMultiTextColumn`: 0
- `Plot/SetChartOptions`: 0
- `Filter =`: 0
- `Param/ParamToggle/ParamStr`: 0

Required analytical surfaces đều còn:
- RobustATR
- NoDemandCandidateCode
- SL_PivotHighEventCode
- WPC_L_ContextPresent
- WPCF_L_PublicActive
- WPCF_CurrentRangeContextCount
- WCI_ContextMultiplicityCode
- WCI_PhaseStateCode
- WCI_FamilyHypothesisCode
- WCI_DirectionalContextCode

## Kiến trúc compile-size

Không inline analytical body 6 lần.

One-Click formula sẽ include body đúng một lần trong context execution loop, rồi thay đổi context/timeframe/foreign source giữa các iteration. Điều này giữ compile surface gần 300 KB thay vì khoảng 1.8 MB chỉ riêng analytical body.

## Giới hạn của PASS này

Đây chỉ là static audit. Chưa chứng minh:
- AmiBroker 6.20.01 compile PASS;
- cross-context state isolation;
- TimeFrameSet W/M equivalence;
- current/replay equivalence;
- performance thực tế.

Checkpoint:

`ONE_CLICK_STATIC_BUILDER_AUDIT_20260918 = PASS`