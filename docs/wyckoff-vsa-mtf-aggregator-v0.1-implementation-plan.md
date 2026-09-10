# Wyckoff VSA Multi-Timeframe Aggregator v0.1 — Implementation Plan

**Trạng thái:** `APPROVED SPEC / IMPLEMENTATION START`.

## Mốc chuẩn

- Multi-Timeframe Context D01–D36 đã được chủ dự án phê duyệt và khóa tại PR #28.
- PR #28 merge `main`: `794f947761fcb2c9043fd6d30fb9dd1a48f8c2bc`.
- Snapshot Contract S01–S32 đã được phê duyệt và khóa tại PR #29.
- PR #29 merge `main`: `a098a253cb139c6e2fc226a9aba8b051f3b5fa59`.
- Snapshot Publisher/Consumer implementation PR #30 head lúc bắt đầu Aggregator: `4cd671e31749d27a44d8c628d1f23a3a1218f5d6`.

## Kiến trúc triển khai

`Daily Composite current state + Weekly Snapshot Consumer + Monthly Snapshot Consumer → MTF Aggregator → Exploration → Context Panel`

Aggregator chỉ aggregate/compare các categorical state đã có. Không tái tính Event/Phase/Family/VSA signal.

## Quy tắc triển khai

1. Daily là base current-state từ canonical Composite v0.1.
2. Weekly/Monthly chỉ được dùng khi Snapshot Consumer báo `VALID`.
3. `BULLISH ALIGNMENT` chỉ khi D/W/M đều bullish.
4. `BEARISH ALIGNMENT` chỉ khi D/W/M đều bearish.
5. `BASE COUNTER TO HIGHER CONTEXT` chỉ khi W và M cùng phía, D ngược phía.
6. `HIGHER TIMEFRAMES CONFLICT` khi W và M đều directional nhưng trái phía.
7. Multiple/ambiguous context ở bất kỳ timeframe nào đi vào `MIXED / COMPLEX`.
8. Evidence alignment được tính độc lập với family/directional alignment.
9. Phase relationship chỉ là diagnostic về tiến độ cấu trúc, không phải mức độ tốt/xấu.
10. Range IDs/boundaries và EventMask giữ riêng theo timeframe; không tạo MasterRange, không OR event xuyên timeframe.
11. Không weighted score, majority vote, confidence/probability hoặc trading signal.
12. v0.1 current-state only; không historical backfill.

## Trạng thái kiểm thử

AFL triển khai sau tài liệu này vẫn phải giữ `UNTESTED DEVELOPMENT` cho đến chiến dịch AmiBroker 6.20.01 tổng thể.