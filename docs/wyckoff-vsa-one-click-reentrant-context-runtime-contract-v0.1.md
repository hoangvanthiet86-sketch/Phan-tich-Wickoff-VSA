# Wyckoff VSA Unified One-Click v0.1 — Re-entrant Context Runtime Contract

**Trạng thái:** IMPLEMENTATION CONTRACT  
**Mục tiêu:** cho phép cùng analytical methodology chạy nhiều role/context trong một AFL mà không nhân bản methodology.

## 1. Vấn đề kỹ thuật

Stack canonical hiện tại phần lớn là top-level AFL dùng global variable names và include chain. Nó không phải callable kernel.

Vì vậy không được thực hiện kiểu:

- đổi TimeFrameSet;
- include lại cùng stack;
- kỳ vọng engine tự chạy lại độc lập.

#include_once sẽ chặn include lặp; còn include thô nhiều lần có nguy cơ trùng function/global names và state overwrite.

## 2. Kiến trúc bắt buộc

Phải tách mỗi analytical layer thành hai phần:

1. definitions/helpers — function/constants nạp một lần;
2. context body — callable/re-entrant body, nhận channel + source arrays/config và ghi output vào namespace động.

Không sửa ý nghĩa công thức.

## 3. Context roles cần hỗ trợ

- STOCK_D
- STOCK_W
- STOCK_M
- MARKET_D
- MARKET_W
- MARKET_M

Cùng một body phải dùng được cho stock và market.

## 4. Capture payload chuẩn

Mỗi context tối thiểu phải xuất:

- ContextMultiplicityCode
- ContextAmbiguous
- CurrentRangeContextID
- RangeStatusCode
- PrimaryRangeLow
- PrimaryRangeHigh
- RangeAgeBars
- PhaseStateCode
- StructuralDevelopmentCode
- FamilyHypothesisCode
- DirectionalContextCode
- EvidenceBalanceCode
- HypothesisAlignmentCode
- CurrentEventMask
- ProvisionalFlag
- L/U ContextPresent
- L/U PublicActive
- L/U RangeContextID
- L/U RangeStatusCode
- L/U PhaseStateCode
- L/U FamilyHypothesisCode
- L/U PrimaryRangeLow/High
- L/U RangeAgeBars

## 5. Higher-timeframe execution

Cache miss cho W/M:

1. chuyển input sang timeframe cần tính;
2. chạy re-entrant context body;
3. chọn đúng completed-period ordinal;
4. capture payload vào normal variables;
5. restore timeframe;
6. validate source time < Daily as-of;
7. chỉ sau đó mới ghi cache.

Không dùng bar W/M đang hình thành.

## 6. Market execution

Market benchmark không được chạy full stack riêng cho từng stock.

Shared market builder phải:

1. giành market writer lock;
2. tính MARKET_D/W/M một lần cho as-of/config;
3. chạy MTF relation kernel;
4. tính Market Selection Context;
5. commit shared market cache;
6. các symbol khác đọc generation-stable payload.

## 7. Correctness gate

Trước khi One-Click dùng re-entrant context làm production source:

- Daily context exact match canonical runtime;
- Weekly exact match native Weekly publisher payload;
- Monthly exact match native Monthly publisher payload;
- VNINDEX D/W/M exact match cùng oracle;
- PublicActive/Multiplicity exact match;
- source provenance causal.

Không có tolerance cho categorical/code fields.

## 8. Build strategy

V0.1 ưu tiên builder-generated re-entrant variants từ canonical sources thay vì viết lại logic thủ công.

Builder phải:

- đọc canonical source;
- chỉ đổi dependency/config wiring và namespace plumbing;
- fail nếu source text expected không còn khớp;
- ghi SHA-256 generated artifacts;
- không sửa canonical files.

Nếu một module không thể chuyển an toàn bằng deterministic builder, dừng ở module đó và viết correction/refactor spec riêng trước khi sửa source.

## 9. Performance rule

Re-entrant kernel chỉ chạy khi corresponding cache miss.

Warm decision-cache hit path không được load/run heavy analytical bodies.

`ONE_CLICK_REENTRANT_CONTEXT_CONTRACT_V01 = DEFINED`