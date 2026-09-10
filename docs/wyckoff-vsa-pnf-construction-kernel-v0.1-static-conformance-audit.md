# P&F Construction Kernel v0.1 — Kiểm toán phù hợp tĩnh

**Kết luận:** `STATIC SPEC CONFORMANCE = PASS`

**Giới hạn:** PASS chỉ ở cấp source/interface review; không phải AmiBroker native acceptance và không phải PFK-A01–A13 PASS.

## PFK01–PFK10 — scope/config/grid — PASS

- Daily-only production path.
- HIGH_LOW, fixed BoxSize, explicit GridOrigin.
- ReversalBoxes fail-closed ngoài {1,3}.
- Internal state dùng integer BoxIndex.
- Exact boundary inclusive với tolerance rất nhỏ để xử lý floating equality.
- Không dynamic ATR/percentage/traditional rescale.

## PFK11–PFK15 — bootstrap/maturity — PASS

- Seed lấy từ first completed valid H/L bar có Close hợp lệ.
- Seed bar không tự mở X/O.
- Up/Down reach được so từ SeedBox.
- Unequal two-sided excursion chọn phía lớn hơn; tie giữ ambiguous.
- First column khởi tạo causal.
- MatureFlag chỉ bật sau first successful reversal.
- Seed/first-column/first-reversal coordinates được xuất.

**Implementation note:** SeedBox dùng deterministic floor-to-grid mapping. Đây là implementation convention dưới PFK11, không phải Wyckoff universal rule; manual/native fixtures phải khóa hành vi trước production acceptance.

## PFK16–PFK20 — High–Low precedence/reversal — PASS

- X kiểm tra High extension trước; nếu extend thì Low không được xét.
- O kiểm tra Low extension trước; nếu extend thì High không được xét.
- X→O và O→X reversal dùng inclusive reversal grid.
- Reversal bar chỉ mở một new column dù đi nhiều boxes.
- Không có X→O→X hay O→X→O trong cùng source bar.

## PFK21–PFK22 — 1-box two-entry — PASS

- ReversalBoxes=1 chỉ reversal khi current column BoxCount>=2.
- Rule áp dụng cả first initialized column và mọi later column.
- Blocked event được xuất riêng, geometry giữ nguyên.

## PFK23–PFK30 — column geometry/provenance/gaps — PASS

- first ColumnIndex=0; mỗi reversal +1; extension/gap không đổi index.
- public Direction enum 0/1/2.
- Start/Top/Bottom/BoxCount và grid prices được giữ.
- FirstKnownAt / LastExtendedAt được giữ cho current column.
- reversal xuất closed-column snapshot với FinalizedAt đúng reversal bar.
- invalid High/Low không fill, không reset chart; DataGapEvent + cumulative gap được xuất.
- open-column gap provenance được giữ.

## PFK31–PFK34 — provisional/revision/identity — PASS

- deployment-provisional bar không mutate official state;
- shadow would-seed/init/extend/reverse tách khỏi canonical geometry;
- source revision status được giữ như provenance hook, không gọi là repaint;
- identity components gồm runtime symbol/timeframe cùng PriceMethod, BoxSize, GridOrigin, ReversalBoxes, AdjustmentBasis và schema/config của Kernel; không có silent rescale.

## PFK35–PFK39 — public contract / causal mapping — PASS

- prefix `WPFK_` dùng cho public arrays.
- current-state, per-bar event và closed-column snapshot được export.
- per-bar state phản ánh state sau khi bar đó được xử lý.
- `ColumnIndexKnownAtOrBeforeBar` và geometry mapping không backfill future column.
- same-bar init/reversal được ghi `SameBarColumnCreationFlag`.
- Kernel sở hữu state machine, không dùng hidden native P&F rendering làm canonical source.

## PFK40–PFK42 — fixtures/parity — PASS Ở CẤP GÓI NGUỒN

- `tests/pnf-construction-kernel-v0.1-manual-fixtures.md` tồn tại với F01–F24.
- Fixtures bao phủ 3-box, 1-box, bootstrap, boundary, provisional, deterministic/append, revision, mapping và maturity.
- External chart chỉ là cross-check; không thay manual/native acceptance.

## PFK43 — historical/performance contract — PASS Ở CẤP SOURCE

- Kernel dùng `SetBarsRequired(sbrAll,sbrAll)`.
- Không có optimization heuristic làm thay đổi history.
- Long-history performance chưa chạy native.

## PFK44 — gate status

Source-level prerequisites 1–4 hiện đã có:
1. PFK01–PFK44 đã khóa;
2. Kernel AFL đã viết;
3. static conformance PASS;
4. manual fixture package tồn tại.

Các native prerequisite 5–9 **chưa hoàn tất**:
- Verify Syntax;
- core construction fixture suite;
- 1-box suite;
- causal prefix/append;
- source-to-column mapping fixtures.

Vì vậy:

`PFO46 SOURCE-DEVELOPMENT GATE = OPEN`

nhưng:

`PFO46 NATIVE ACCEPTANCE = PENDING`

và Kernel vẫn là:

`SPEC-ALIGNED / UNTESTED DEVELOPMENT`.