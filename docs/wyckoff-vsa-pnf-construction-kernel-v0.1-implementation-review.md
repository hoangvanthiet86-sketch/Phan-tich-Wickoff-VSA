# P&F Construction Kernel v0.1 — Rà soát triển khai

**Trạng thái:** `SPEC-ALIGNED / UNTESTED DEVELOPMENT`.

## Mốc chuẩn

- P&F Cause / Price Objective PFO01–PFO48 đã khóa tại PR #41, merge `504922996a89c4f80528f6681f4a0217c4bdd0b1`.
- P&F Construction Kernel PFK01–PFK44 đã được chủ dự án phê duyệt tại PR #42, merge `c5c235718b7ead10c702c615476f321dfc54463a`.
- PFO46/PFK44 vẫn là cổng native mở: source-level implementation không đồng nghĩa AmiBroker acceptance.

## Tệp triển khai

- `afl/WyckoffVSA_PnFConstructionKernel_v0.1.afl`
- `afl/WyckoffVSA_PnFConstructionKernel_Exploration_v0.1.afl`
- `tests/pnf-construction-kernel-v0.1-manual-fixtures.md`

## State machine đã triển khai

### Config / input

- Daily-only production path.
- `HIGH_LOW`, fixed absolute BoxSize, explicit GridOrigin.
- ReversalBoxes chỉ hợp lệ khi bằng 1 hoặc 3.
- High/Low invalid không được fill từ prior bar.
- Adjustment basis chỉ được khai báo/validate; Kernel không tự adjust dữ liệu.

### Grid arithmetic

- State được giữ theo integer BoxIndex.
- Grid price = `GridOrigin + BoxIndex*BoxSize`.
- High reachable box dùng floor; Low reachable box dùng ceil.
- Tolerance chỉ dùng để cứu equality do floating representation; cap rất nhỏ so với BoxSize.

### Bootstrap

Triển khai project convention `CAUSAL_CLOSE_SEED_AUTO_DIRECTION`:

1. first valid seed bar lấy Close làm SeedPrice;
2. SeedBox được ánh xạ về grid level tại hoặc ngay dưới Close bằng floor-to-grid;
3. seed bar không mở X/O;
4. bar sau đo UpReach/DownReach từ seed grid;
5. excursion lớn hơn thắng; exact tie giữ ambiguous;
6. first column chỉ được tạo khi direction resolved.

**Lưu ý:** floor-to-grid của SeedBox là implementation convention để làm rõ PFK11; không được diễn giải thành Wyckoff universal rule. Native fixtures phải khóa hành vi này trước production acceptance.

### High–Low precedence

- X-column: High extension trước; extension thành công thì bỏ Low.
- Nếu X không extend mới xét Low reversal.
- O-column đối xứng.
- Một source bar tối đa một directional decision.

### Reversal

- exact reversal boundary inclusive.
- 3-box reversal mở new column và fill mọi postings đạt được trong chính bar reversal.
- 1-box reversal yêu cầu current column BoxCount>=2; áp dụng cả first initialized column và mọi column sau.

### Provenance

Public arrays giữ:

- Seed BI/DT/Price/Box;
- FirstColumn KnownAt;
- FirstReversal KnownAt;
- MatureFlag;
- current ColumnIndex/Direction/Start/Top/Bottom/BoxCount;
- FirstKnownAt/LastExtendedAt;
- source-valid-bar count, tolerance count, gap flag;
- closed-column snapshot tại reversal bar với FinalizedAt=current bar;
- cumulative data-gap count;
- per-bar mapping surface `ColumnIndexKnownAtOrBeforeBar`;
- `SameBarColumnCreationFlag` cho anchor xảy ra đúng reversal/init bar.

### Provisional

Nếu runtime profile đánh dấu final analysis bar provisional:

- official geometry không mutation;
- `ChartUpdateCode=6`;
- chỉ xuất shadow flags would-seed/init/extend/reverse.

Kernel không tự suy bar cuối là completed; việc provisional là deployment declaration.

## Manual fixture package

Đã dựng 24 fixture thủ công theo PFK40:

- 3-box extension/reversal/precedence/multi-box/no-change/gap;
- 1-box two-entry và repeated columns;
- bootstrap X/O/unequal/tie;
- grid/decimal boundary;
- provisional;
- deterministic rerun;
- append stability;
- source revision;
- anchor mapping;
- maturity gate.

Fixtures hiện chỉ là oracle tài liệu, **chưa được chạy native**.

## Giới hạn còn mở

Chưa thực hiện:

- AmiBroker 6.20.01 Verify Syntax;
- PFK-A02…A11 native fixtures;
- external parity cross-check PFK-A12;
- long-history performance PFK-A13;
- prepend/warm-up invariance investigation;
- source revision execution.

Do đó không được gọi PFO46 native PASS và chưa được gọi Kernel production-ready.