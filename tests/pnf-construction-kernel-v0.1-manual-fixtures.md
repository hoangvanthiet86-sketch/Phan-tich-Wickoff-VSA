# P&F Construction Kernel v0.1 — Manually-Derived Fixture Package

**Trạng thái:** `REFERENCE FIXTURES / NOT YET EXECUTED ON AMIBROKER`.

Các fixture này là oracle thủ công theo PFK01–PFK44. External P&F chart chỉ được dùng cross-check sau khi các fixture này đã chạy native.

## Quy ước chung

Trừ khi fixture ghi khác:

- Timeframe: Daily.
- PriceMethod: HIGH_LOW.
- BoxSize = 1.
- GridOrigin = 0.
- ReversalBoxes = 3.
- AdjustmentBasisStatus = 1.
- Mỗi bar đều completed/non-provisional.
- Seed bar dùng `Close=10`, `High=10`, `Low=10`, nên `SeedBox=10`.
- `UpdateCode`: 4 seed, 5 first-column init, 2 extension, 3 reversal, 1 no-change, 0 invalid/config, 6 provisional ignored.

---

## F01 — 3-box X extension tại exact boundary

Bars:
1. H=10 L=10 C=10 → seed.
2. H=11 L=10 C=10.5 → first X, Column 0, X, box 11.
3. H=12 L=10 C=11.5 → extend X đúng grid 12.

Expected bar 3:
- UpdateCode=2;
- BoxesAdded=1;
- ColumnIndex=0, Direction=X;
- TopBox=12, BottomBox=11, BoxCount=2;
- Reversal=0.

## F02 — X không extend rồi exact 3-box reversal

Tiếp F01 với X top=12.

Bar 4: H=12.5 L=9 C=10.

Expected:
- High không chạm 13 nên không extend;
- Low chạm `12-3=9` → reversal;
- Closed Column 0 = X, top12/bottom11, FinalizedAt=bar4;
- new Column 1 = O, StartBox=11, TopBox=11, BottomBox=9, BoxCount=3;
- UpdateCode=3, BoxesAdded=3, Reversal=1;
- MatureFlag chuyển 0→1 tại bar4.

## F03 — O extension và exact O→X reversal

Bars:
1. seed 10.
2. H=10 L=9 C=9.5 → first O at 9.
3. H=10 L=8 C=8.5 → O extends to 8.
4. H=11 L=8.2 C=10 → Low không chạm 7; High chạm `8+3=11`.

Expected bar4:
- close Column0=O;
- new Column1=X, StartBox=9, BottomBox=9, TopBox=11, BoxCount=3;
- UpdateCode=3, Reversal=1, Mature=1.

## F04 — Extension precedence thắng dù opposite side cũng đủ reversal

State trước bar: Column0=X, top=12, bottom=11.

Bar: H=13 L=8 C=10.

Expected:
- High đạt 13 → extend X trước;
- Low bị bỏ qua hoàn toàn;
- Column vẫn 0=X, top=13;
- UpdateCode=2, BoxesAdded=1, Reversal=0.

## F05 — Multi-box extension trong một bar

State: Column0=X top=11 bottom=11.

Bar: H=15 L=10 C=14.

Expected:
- X extend 4 postings tới 15;
- UpdateCode=2, BoxesAdded=4;
- top=15, bottom=11, BoxCount=5.

## F06 — Multi-box reversal fill trong một bar

State: Column0=X top=15 bottom=11.

Bar: H=15.5 L=8 C=9.

Expected:
- High không chạm16;
- Low đạt reversal;
- new O starts14 và fill tới8;
- Column1 O top14 bottom8, BoxCount=7;
- BoxesAdded=7, chỉ mở một new column.

## F07 — No-change bar

State: X top=12 bottom=11.

Bar: H=12.4 L=10 C=11.

Expected:
- không chạm13;
- reversal grid=9, Low=10 không đạt;
- UpdateCode=1;
- geometry giữ nguyên.

## F08 — Invalid High/Low gap

State: X top=12 bottom=11.

Bar: High=Null, Low=10.

Expected:
- SourceBarValid=0;
- UpdateCode=0;
- DataGapEvent=1;
- geometry không đổi;
- CurrentColumnDataGapObservedFlag=1;
- CumulativeDataGapCount +1.

## F09 — 1-box: một posting bị chặn reversal

Config: ReversalBoxes=1.

Bars:
1. seed10.
2. H=11 L=10 → first X chỉ box11, BoxCount=1.
3. H=11.5 L=10 → High không chạm12; Low chạm reversal grid10.

Expected bar3:
- OneBoxReversalBlocked=1;
- UpdateCode=1;
- vẫn Column0=X, BoxCount=1;
- Reversal=0, Mature=0.

## F10 — 1-box: sau posting thứ hai thì reversal được phép

Tiếp F09:
4. H=12 L=10.5 → X extend tới12, BoxCount=2.
5. H=12.4 L=11 → High không chạm13; Low chạm reversal grid11.

Expected bar5:
- close Column0=X;
- new Column1=O ở box11, BoxCount=1;
- UpdateCode=3, Reversal=1, Mature=1.

## F11 — 1-box two-entry áp dụng lặp lại cho mọi column

Tiếp F10, Column1=O box11 chỉ một posting.

Bar6: H=12 L=10.5 → O chưa chạm10 để extend; High chạm12 nhưng reversal phải bị chặn vì O BoxCount=1.

Expected: blocked=1, vẫn O box11.

Bar7: H=11.5 L=10 → O extend xuống10, BoxCount=2.

Bar8: H=11 L=10.2 → Low không chạm9; High chạm11 → được mở Column2=X box11.

## F12 — Bootstrap first direction X

Bars:
1. seed10.
2. H=11 L=9.5.

Expected:
- UpReach=1, DownReach=0;
- first direction X;
- Column0 starts/top/bottom=11;
- UpdateCode=5.

## F13 — Bootstrap first direction O

Bars:
1. seed10.
2. H=10.5 L=9.

Expected:
- UpReach=0, DownReach=1;
- Column0=O at9;
- UpdateCode=5.

## F14 — Bootstrap both sides unequal, excursion lớn hơn thắng

Bars:
1. seed10.
2. H=13 L=8.

Expected:
- UpReach=3, DownReach=2;
- first direction X;
- Column0 X boxes11..13, BoxCount=3.

## F15 — Bootstrap exact tie → ambiguous/defer

Bars:
1. seed10.
2. H=12 L=8 → UpReach=2, DownReach=2.
3. H=13 L=8 → UpReach=3, DownReach=2.

Expected:
- bar2: no column, UpdateCode=1, BootstrapAmbiguousFlag=1, AmbiguousCount=1;
- bar3: first X boxes11..13, UpdateCode=5.

## F16 — Exact GridOrigin boundary

Config: BoxSize=1, GridOrigin=0.5.

Seed: C=10.5 → SeedBoxIndex=10, GridPrice=10.5.
Next bar H=11.5 L=10.6.

Expected first X at BoxIndex11, GridPrice11.5 exactly; inclusive boundary.

## F17 — Decimal BoxSize floating boundary

Config: BoxSize=0.1, GridOrigin=0.

Seed C=10.0.
Next bar H mathematically equal 10.1, L=10.0.

Expected:
- first X reaches integer box101;
- no missed posting due binary representation;
- BoundaryToleranceUsedFlag may be 0 or 1 depending binary representation, nhưng geometry bắt buộc identical.

Negative control: H=10.09999 không được tolerance cứu thành box101.

## F18 — Provisional bar would extend, official history không đổi

State completed: X top=11.
Final analysis-range bar flagged provisional: H=12 L=10.

Expected:
- UpdateCode=6;
- ProvisionalWouldExtend=1;
- official Column top vẫn11;
- no LastExtendedAt mutation.

## F19 — Provisional bar would reverse, official history không đổi

State completed: X top=13, ReversalBoxes=3.
Provisional bar: H=13.5 L=10.

Expected:
- UpdateCode=6;
- ProvisionalWouldReverse=1;
- no new column;
- prior X không được Finalized.

## F20 — Deterministic rerun

Chạy cùng exact source/config hai lần.

Expected cell-by-cell identical cho:
- ChartUpdateCode;
- column index/direction/geometry;
- provenance BI/DT;
- maturity;
- closed-column snapshots;
- gap/tolerance diagnostics.

## F21 — Append stability

Run A trên prefix N bars. Run B append thêm M bars mà không sửa prefix.

Expected tất cả official output của bars 0..N-1 identical tuyệt đối giữa A/B.

## F22 — Source revision recomputation

Giữ config, sửa một historical High hoặc Low ở bar r.

Expected:
- output trước vùng phụ thuộc r không đổi;
- output từ điểm construction bị ảnh hưởng trở đi được phép thay đổi;
- không gọi thay đổi này là algorithmic repaint;
- SourceRevisionStatus phải phân biệt revised source.

## F23 — Anchor mapping trước / đúng / sau reversal

State: X Column0 cho tới bar4; bar5 reversal tạo O Column1.

Expected causal mapping:
- anchor KnownAt bar4 → Column0;
- anchor KnownAt bar5 → Column1 và SameBarColumnCreationFlag=1;
- anchor bar6 khi O vẫn mở → Column1.

Không map bar4 sang Column1 chỉ vì về sau biết reversal ở bar5.

## F24 — First reversal maturity gate

Bars:
1. seed10.
2. first X at11.
3. X extend12.
4. exact reversal Low=9.

Expected:
- bars1–3: ConstructionMatureFlag=0;
- bar4 và về sau: MatureFlag=1;
- FirstReversalKnownAt = bar4;
- Cause mapping cho range left-boundary trước bar4 phải fail closed theo PFK14/PFK15.

---

# Native acceptance mapping

- PFK-A01: Kernel + Exploration Verify Syntax.
- PFK-A02: F01–F08.
- PFK-A03: F09–F11.
- PFK-A04: F12–F15.
- PFK-A05: F16–F17.
- PFK-A06: F18–F19.
- PFK-A07: F20.
- PFK-A08: F21.
- PFK-A09: F22.
- PFK-A10: F23.
- PFK-A11: F24.

**Không fixture nào được gọi PASS trước khi chạy trên AmiBroker 6.20.01.**