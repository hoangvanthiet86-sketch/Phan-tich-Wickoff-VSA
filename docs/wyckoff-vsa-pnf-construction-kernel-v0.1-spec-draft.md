# Wyckoff VSA P&F Construction Kernel v0.1 — Dự thảo đặc tả

**Trạng thái:** `DRAFT FOR OWNER APPROVAL` — chỉ đặc tả. Chưa có AFL triển khai. Chưa phải nghiệm thu native.

## 1. Vai trò

P&F Construction Kernel v0.1 là prerequisite bắt buộc của `PFO46` trong đặc tả P&F Cause / Price Objective v0.1 đã khóa tại PR #41.

Kernel chỉ có nhiệm vụ biến chuỗi giá Daily đã hoàn tất thành một lịch sử Point-and-Figure (P&F) **nhân quả, xác định, có provenance và có thể kiểm toán**. Nó không:

- xác định Accumulation/Distribution;
- xác nhận Spring/SOS/LPS/SOW/LPSY;
- chọn count line;
- đo horizontal Cause;
- tạo Price Objective;
- tạo Buy/Sell/Short/Cover/PositionSize;
- chấm điểm hay xếp hạng.

Chuỗi kiến trúc:

`Daily OHLC → P&F Construction Kernel → P&F Cause / Price Objective Engine`

---

## 2. Kết luận nghiên cứu dùng làm nền

### 2.1. P&F là price-movement chart, không phải time chart

Nguồn:
- Bruce Fraser, *Intro to Point and Figure Construction*.
- StockCharts ChartSchool, *Introduction to Point & Figure Charts*.

P&F chỉ dịch sang cột mới khi có reversal đủ số box. Một cột có thể đại diện một hoặc nhiều source bars. Vì vậy Kernel phải giữ riêng:

- source-bar chronology;
- P&F column chronology;
- thời điểm column first-known;
- thời điểm column extension;
- thời điểm prior column thực sự được fixed bởi reversal.

### 2.2. High-Low method dùng một phía của bar theo precedence

Nguồn ChartSchool:

Khi current column là X:
1. nếu High đủ để extend X, extend và **bỏ qua Low**;
2. nếu không extend X, mới xét Low để reversal;
3. nếu không đủ cả hai, bar không thay đổi chart.

Khi current column là O: đối xứng — xét Low extend trước, nếu không thì mới xét High reversal.

Điều này có nghĩa Kernel không được giả định intrabar path High→Low hoặc Low→High ngoài precedence đã chọn.

### 2.3. Reversal threshold là inclusive

Ví dụ chuẩn ChartSchool với X ở box 15 và 3-box reversal: Low = 12.00 đủ để tạo reversal vì `12 <= 15 - 3`.

Do đó exact grid hit phải được coi là đạt threshold.

### 2.4. 1-box reversal có two-entry rule

Nguồn Bruce Fraser/Wyckoff Power Charting:

Một cột trong 1-box P&F phải có **ít nhất hai postings/entries** trước khi được phép mở cột reversal tiếp theo. Bỏ quy tắc này làm số cột ngang phình sai và phá horizontal count.

### 2.5. 3-box và 1-box đều hợp lệ trong thực hành Wyckoff

Không coi một reversal mode là “Wyckoff duy nhất”. Kernel v0.1 phải hỗ trợ explicit `1` và `3`.

### 2.6. User-defined fixed box là đường production v0.1

Nguồn ChartSchool xác nhận user-defined scaling giữ BoxSize cố định xuyên toàn chart. Điều này phù hợp yêu cầu causal/reproducible của dự án.

Dynamic ATR/percentage/traditional scale không thuộc production path v0.1.

### 2.7. Initialization không có một universal rule duy nhất

ChartSchool minh họa: “chart has to start somewhere” rồi giả định first column đang giảm. Đây là **construction convention**, không phải bằng chứng phương pháp cho thấy initial direction luôn là O.

Vì vậy Kernel phải tách rõ bootstrap convention khỏi P&F logic sau khi chart đã mature.

### 2.8. Horizontal Wyckoff count đòi hỏi construction đúng trước

Wyckoff/WSMI horizontal count đếm toàn bộ horizontal divisions trong selected span. Nếu reversal, one-box two-entry hoặc source-to-column mapping sai thì mọi Cause/Objective phía sau đều sai. Vì vậy PFO46 được giữ như cổng riêng.

Nguồn nghiên cứu chính:
- https://articles.stockcharts.com/article/articles-wyckoff-2016-01-intro-to-point-and-figure-construction/
- https://chartschool.stockcharts.com/table-of-contents/chart-analysis/point-and-figure-charts/point-and-figure-basics/introduction-to-point-and-figure-charts
- https://chartschool.stockcharts.com/table-of-contents/chart-analysis/point-and-figure-charts/point-and-figure-basics/point-and-figure-scaling-and-timeframes
- https://wyckoffsmi.com/figure-charts-counts-and-counting/
- PR #41 / PFO01–PFO48.

---

# QUYẾT ĐỊNH THIẾT KẾ PFK01–PFK44

## PFK01 — Scope chính thức v0.1

Official path:

- source timeframe: Daily;
- price method: `HIGH_LOW`;
- box scaling: `FIXED_ABSOLUTE`;
- reversal modes: `1` hoặc `3`;
- completed-bar causal construction;
- current-state + historical reconstruction từ trái sang phải;
- một symbol mỗi formula invocation.

Không intraday/Weekly/Monthly production path trong v0.1.

## PFK02 — Kernel không chứa Wyckoff interpretation

Kernel chỉ xuất geometry và provenance của P&F.

Cấm tạo:
- Phase;
- FamilyHypothesis;
- Event labels;
- CountSegment;
- PriceObjective;
- trade signal.

## PFK03 — Input validity tối thiểu

Một source bar dùng cho High-Low construction chỉ hợp lệ khi:

- High hữu hạn;
- Low hữu hạn;
- High > 0;
- Low > 0;
- `High >= Low`.

Open/Close không phải gate của High-Low construction, ngoại trừ Close được dùng trong bootstrap seed theo PFK11.

Nếu bootstrap cần Close thì Close phải hữu hạn và >0 tại bar seed.

## PFK04 — BoxSize

`BoxSize` phải:

- hữu hạn;
- `> 0`;
- explicit từ deployment/profile;
- không thay đổi trong cùng một construction generation.

Không silent auto-box-size.

## PFK05 — GridOrigin

`GridOrigin` phải explicit và hữu hạn.

Production default đề xuất: `0` trong đơn vị giá database, nhưng output luôn phải ghi giá trị thực tế.

Grid level:

`GridPrice(BoxIndex) = GridOrigin + BoxIndex * BoxSize`

`BoxIndex` là integer signed.

## PFK06 — Integer box arithmetic là chuẩn nội bộ

Kernel không điều khiển state bằng giá hiển thị đã làm tròn.

Mọi extension/reversal phải quy về integer BoxIndex trước, sau đó mới tính lại GridPrice để xuất.

Mục tiêu: tránh drift do cộng BoxSize lặp đi lặp lại bằng số thực.

## PFK07 — Inclusive economic boundaries

Economic rule:

- X extension xảy ra khi High **chạm hoặc vượt** next grid level;
- O extension xảy ra khi Low **chạm hoặc thấp hơn** next grid level;
- reversal xảy ra khi giá **chạm hoặc vượt qua theo phía đối diện** reversal grid.

Không dùng strict comparison tại exact box boundary.

## PFK08 — Floating-point handling không được thay economic rule

AFL dùng double nên có thể gặp sai số biểu diễn nhị phân.

Kernel được phép dùng một `GridComparisonTolerance` cực nhỏ chỉ để nhận diện hai số lẽ ra bằng cùng grid level.

Yêu cầu:
- tolerance phải scale theo magnitude số;
- phải nhỏ hơn rất nhiều so với BoxSize;
- không bao giờ được biến một giá cách grid một phần có ý nghĩa của box thành “đã chạm”;
- phải export `BoundaryToleranceUsedFlag` khi equality được cứu bởi tolerance.

Đề xuất implementation review: tolerance cỡ `1e-10 * max(1, |Price|, |GridPrice|)` và đồng thời cap theo một tỷ lệ rất nhỏ của BoxSize. Giá trị cuối cùng sẽ được khóa ở AFL review, không sửa economic threshold PFK07.

## PFK09 — ReversalBoxes chỉ nhận 1 hoặc 3

`ReversalBoxes ∈ {1,3}`.

Giá trị khác → configuration invalid, Kernel fail closed.

## PFK10 — PriceMethodCode

v0.1 production:

`PriceMethodCode = 1 = HIGH_LOW`

`CLOSE` có thể được giữ cho fixture/reference comparison sau này nhưng không phải official Cause path v0.1 nếu chưa có amendment riêng.

## PFK11 — Bootstrap convention chính thức

Do nguồn không cung cấp một universal initial-direction rule, v0.1 dùng convention nhân quả riêng và phải ghi rõ là **PROJECT CONVENTION, NON-WYCKOFF-NORMATIVE**:

`CAUSAL_CLOSE_SEED_AUTO_DIRECTION`.

Tại first valid seed bar:

- lấy `SeedPrice = Close`;
- map SeedPrice vào `SeedBoxIndex` theo grid;
- chưa tạo X/O column chỉ vì có seed.

Sau đó đợi một completed bar tạo first decisive move khỏi seed.

## PFK12 — Cách xác định first direction từ seed

Tại mỗi bar sau seed, tính số full boxes đạt được lên/xuống so với SeedBox grid level:

- `UpReachBoxes` từ High;
- `DownReachBoxes` từ Low.

Nếu chỉ một phía đạt ít nhất 1 box → first direction theo phía đó.

Nếu cả hai phía cùng đạt:
- chọn phía có **số full boxes lớn hơn**;
- nếu bằng nhau → `BOOTSTRAP_AMBIGUOUS`, chưa mở column và tiếp tục đợi bar sau.

Đây là deterministic bootstrap convention của dự án, không được gọi là quy tắc Wyckoff cổ điển.

## PFK13 — First column construction sau khi direction resolved

Nếu first direction = X:
- first X starts một box trên SeedBox;
- điền liên tục đến highest grid box reached bởi High của resolving bar.

Nếu first direction = O:
- first O starts một box dưới SeedBox;
- điền liên tục đến lowest grid box reached bởi Low.

Không ghi X và O trong cùng first column.

## PFK14 — Bootstrap maturity guard

Một P&F construction chỉ được coi `MATURE_FOR_CAUSE_MAPPING = 1` sau khi **ít nhất một reversal column đã được mở thành công** kể từ first initialized column.

Lý do: làm cho Count Engine không phụ thuộc vào convention chọn first direction ở mép trái dataset.

P&F Cause Engine phải fail closed nếu RangeContext left boundary bắt đầu trước maturity point.

## PFK15 — Warm-up requirement downstream

Kernel export:
- `BootstrapSeedBarIndex/DateTime`;
- `FirstColumnKnownAtBarIndex/DateTime`;
- `FirstReversalKnownAtBarIndex/DateTime`;
- `ConstructionMatureFlag`.

Cause Engine chịu trách nhiệm yêu cầu selected RangeContext/count anchors nằm sau maturity.

Không hard-code số ngày warm-up tùy ý.

## PFK16 — Current X-column extension precedence

Nếu current column là X:

1. tính highest reachable X box từ current bar High;
2. nếu `HighestReachableBoxIndex >= CurrentTopBoxIndex + 1`:
   - extend X tới box đó;
   - cập nhật LastExtendedAt;
   - **bỏ qua Low hoàn toàn cho bar này**;
3. chỉ khi không extend X mới xét reversal bằng Low.

## PFK17 — Current O-column extension precedence

Nếu current column là O:

1. tính lowest reachable O box từ current bar Low;
2. nếu `LowestReachableBoxIndex <= CurrentBottomBoxIndex - 1`:
   - extend O tới box đó;
   - cập nhật LastExtendedAt;
   - **bỏ qua High hoàn toàn cho bar này**;
3. chỉ khi không extend O mới xét reversal bằng High.

## PFK18 — X → O reversal threshold

Nếu X không extend tại current bar, reversal được phép khi:

`Low <= GridPrice(CurrentTopBoxIndex - ReversalBoxes)`

với inclusive semantics PFK07.

Nếu đạt:
- prior X column trở thành closed/fixed tại current source bar;
- new O column mở ở `CurrentTopBoxIndex - 1`;
- fill xuống tới lowest reachable O box của current Low;
- trong 3-box mode new O phải chứa ít nhất 3 boxes do threshold;
- không xét High lần nữa trong cùng bar sau khi reversal.

## PFK19 — O → X reversal threshold

Nếu O không extend tại current bar, reversal được phép khi:

`High >= GridPrice(CurrentBottomBoxIndex + ReversalBoxes)`.

Nếu đạt:
- prior O fixed tại current bar;
- new X mở ở `CurrentBottomBoxIndex + 1`;
- fill lên tới highest reachable X box;
- không xét Low lần nữa trong cùng bar.

## PFK20 — Một source bar tối đa một directional decision

Một Daily source bar có thể:
- extend current column nhiều boxes; hoặc
- mở đúng một reversal column và điền nhiều boxes trong new column; hoặc
- không đổi chart.

Không được tạo X→O→X hay O→X→O nhiều lần trong cùng source bar vì High-Low data không cho biết intrabar path.

## PFK21 — 1-box two-entry rule chính xác

Khi `ReversalBoxes = 1`, current column chỉ được reversal nếu:

`CurrentColumnBoxCount >= 2`.

Nếu current column chỉ có 1 posting:
- opposite move dù đạt 1-box threshold **không được mở new column**;
- bar được ghi `ONE_BOX_REVERSAL_BLOCKED_BY_TWO_ENTRY_RULE`;
- current column giữ nguyên;
- chỉ khi current direction về sau extend thành box thứ hai thì reversal mới có thể xảy ra ở một bar sau.

## PFK22 — Two-entry rule áp dụng cho mọi 1-box column, kể cả first initialized column

Không có ngoại lệ silent cho bootstrap column.

Nếu first initialized 1-box column chỉ có một posting, nó chưa được đảo chiều cho tới khi có posting thứ hai.

## PFK23 — ColumnIndex

- first initialized column = `ColumnIndex 0`;
- mỗi reversal tăng `ColumnIndex` đúng `+1`;
- extension không đổi ColumnIndex;
- gap bar không đổi ColumnIndex.

ColumnIndex là integer monotonic và là coordinate chính để horizontal count downstream.

## PFK24 — ColumnDirectionCode

- `0 = NONE / BOOTSTRAP`;
- `1 = X`;
- `2 = O`.

Không dùng +1/-1 nếu downstream có nguy cơ cộng số học thành score. Có thể export signed helper riêng nếu cần kỹ thuật, nhưng public enum là 0/1/2.

## PFK25 — Column box geometry

Mỗi current/frozen column phải có:

- `ColumnIndex`;
- `DirectionCode`;
- `StartBoxIndex`;
- `TopBoxIndex`;
- `BottomBoxIndex`;
- `BoxCount = Top - Bottom + 1`;
- Start/Top/Bottom GridPrice.

Một column không bao giờ có box gaps bên trong.

## PFK26 — Column provenance

Mỗi column phải mang:

- `FirstKnownAtBarIndex/DateTime`;
- `LastExtendedAtBarIndex/DateTime`;
- `FinalizedAtBarIndex/DateTime` khi reversal kế tiếp xuất hiện;
- `SourceValidBarCountContributed`;
- `BoundaryToleranceUseCount`;
- `DataGapObservedWhileOpenFlag`.

## PFK27 — ColumnClosed event là causal event ở reversal bar

Khi reversal xảy ra tại bar t:

- new column được `FirstKnownAt = t`;
- prior column được `FinalizedAt = t`;
- không backfill FinalizedAt về LastExtendedAt.

Output cần có `ClosedColumnEventCode` tại t với snapshot đầy đủ của prior column.

## PFK28 — Extension event riêng với reversal event

Per source bar export tối thiểu:

- `ChartUpdateCode`:
  - 0 invalid/config;
  - 1 no chart change;
  - 2 current-column extension;
  - 3 reversal/new column;
  - 4 bootstrap seed;
  - 5 first column initialized;
  - 6 provisional ignored;
- `BoxesAddedCount`;
- `ReversalOccurredFlag`;
- `OneBoxReversalBlockedFlag`.

Enums chỉ phục vụ audit.

## PFK29 — Data gap không được silently filled

Nếu source High/Low invalid/missing:
- Kernel không fill từ previous price;
- không thay current P&F geometry;
- `DataGapEventFlag = 1`;
- tăng cumulative gap diagnostics.

Kernel không tự reset chart chỉ vì một gap.

## PFK30 — Gap provenance downstream

Mỗi current column giữ `DataGapObservedWhileOpenFlag` nếu có invalid source bar từ lúc column mở tới hiện tại.

Ngoài ra Kernel phải có cumulative source-gap mapping để Cause Engine xác định có gap nào nằm giữa selected left/right count anchors hay không.

Nếu có, Cause Engine có thể data-gate objective thay vì giả định continuity.

## PFK31 — Provisional final bar

Official construction không được mutation bởi final bar nếu deployment đánh dấu bar đó `provisional`.

Tại provisional bar:
- output geometry official được giữ bằng trạng thái completed bar trước;
- có thể xuất shadow diagnostic `ProvisionalWouldExtend/Reversal`, nhưng shadow không được ghi vào canonical column history;
- `ChartUpdateCode = 6` cho official path.

Không suy bar completed chỉ vì `BarCount-1`.

## PFK32 — Source revision khác repaint

Nếu vendor sửa historical OHLC, rerun có thể tạo P&F history khác.

Kernel phải xuất source revision/provenance hooks nhưng không gọi thay đổi do source revision là algorithmic repaint.

Acceptance phải tách:
- same source → deterministic stability;
- revised source → expected recomputation.

## PFK33 — Configuration identity

Một construction identity phải gồm tối thiểu:

`Symbol + Timeframe + PriceMethod + BoxSize + GridOrigin + ReversalBoxes + AdjustmentBasis + KernelSchemaVersion`.

Hai charts khác một trường trên là hai construction khác nhau.

## PFK34 — Adjustment basis

Kernel phải nhận/ghi:
- `AdjustmentBasisDeclaration`;
- `AdjustmentBasisStatusCode`.

Nếu basis chưa verified-compatible, Kernel vẫn có thể dựng geometry cho research nhưng public production-valid flag phải bằng 0.

Không tự điều chỉnh lại OHLC.

## PFK35 — Public current-state contract

Prefix đề xuất: `WPFK_`.

Các trường tối thiểu:

### Config/data
- `WPFK_ConfigValid`;
- `WPFK_BoxSize`;
- `WPFK_GridOrigin`;
- `WPFK_ReversalBoxes`;
- `WPFK_PriceMethodCode`;
- `WPFK_AdjustmentBasisStatusCode`;
- `WPFK_SourceBarValid`;
- `WPFK_ProvisionalFlag`.

### Bootstrap/maturity
- Seed BI/DT/Box;
- FirstColumn BI/DT;
- FirstReversal BI/DT;
- MatureFlag;
- BootstrapAmbiguousCount.

### Current column
- Index;
- Direction;
- Start/Top/Bottom box;
- BoxCount;
- FirstKnownAt BI/DT;
- LastExtendedAt BI/DT;
- open gap/tolerance diagnostics.

### Per-bar events
- ChartUpdateCode;
- BoxesAddedCount;
- ReversalOccurredFlag;
- ClosedColumn snapshot;
- DataGapEvent;
- TwoEntryBlocked.

## PFK36 — Column lookup contract cho Cause Engine

Kernel phải cho phép downstream map một source anchor đã KnownAt sang P&F column **nhân quả**.

Input semantic:
- source `BarIndex` hoặc `DateTime` của LPS/LPSY/Spring/Upthrust/range boundary event.

Output semantic:
- `ColumnIndexKnownAtOrBeforeAnchor`;
- direction;
- current/final geometry tại anchor;
- mapping status.

Không map anchor sang một column chưa tồn tại tại thời điểm anchor.

## PFK37 — Mapping khi cùng bar tạo reversal

Nếu event anchor và P&F reversal đều xảy ra trên cùng source bar:
- mapping phải dùng state **sau khi xử lý bar đó**, vì cả event và reversal chỉ KnownAt khi bar hoàn tất;
- public mapping phải ghi `SameBarColumnCreationFlag`.

Nếu upstream event KnownAt xảy ra muộn hơn origin bar, mapping dùng **KnownAt bar**, không origin bar, trừ khi Cause spec yêu cầu map economic price point riêng và giữ cả hai coordinates.

## PFK38 — Historical reconstruction không backfill column knowledge

Arrays/historical outputs phải phản ánh những gì đã biết sau từng bar.

Không được sau này lấp `ColumnIndex` của một reversal column vào những bar trước reversal.

## PFK39 — No hidden time compression

Kernel không được dùng native P&F chart rendering như nguồn dữ liệu bí mật nếu không thể audit source-to-column transformation.

AFL implementation phải sở hữu state machine hoặc một helper có output đầy đủ tương đương spec.

Chart rendering có thể dùng để cross-check hình học, không phải canonical logic.

## PFK40 — Reference fixtures bắt buộc trước native acceptance

Phải có manually-derived fixtures tối thiểu:

1. 3-box X extension exact boundary;
2. 3-box X không extend rồi exact reversal;
3. O đối xứng;
4. bar vừa đủ extend và cũng đủ opposite reversal → extension precedence thắng;
5. multi-box extension trong một bar;
6. multi-box reversal fill trong một bar;
7. no-change bar;
8. invalid High/Low gap;
9. 1-box column một posting + opposite move → reversal bị chặn;
10. 1-box sau posting thứ hai → reversal cho phép;
11. repeated 1-box two-entry columns;
12. bootstrap first direction X;
13. bootstrap first direction O;
14. bootstrap both-side unequal → larger excursion wins;
15. bootstrap exact tie → ambiguous/defer;
16. exact GridOrigin/Box boundary;
17. decimal BoxSize floating-point boundary;
18. provisional bar would extend nhưng official history không đổi;
19. provisional bar would reverse nhưng official history không đổi;
20. same source prefix rerun → identical outputs;
21. append bars → historical prefix unchanged;
22. source revision → changes isolated từ revised dependency forward;
23. anchor mapping before/at/after reversal;
24. first reversal maturity gate.

## PFK41 — External parity fixtures

Sau khi manually-derived fixtures PASS, chọn một tập source OHLC cố định và cấu hình tương đương để đối chiếu geometry với ít nhất một external P&F engine có cấu hình rõ ràng.

External engine chỉ là **cross-check** vì:
- initialization conventions có thể khác;
- one-box handling có thể khác;
- High-Low pricing implementation có thể khác.

Do đó mismatch phải được phân loại trước khi kết luận production bug.

## PFK42 — Canonical acceptance là spec + manual fixture, không vendor chart

Nếu external chart khác nhưng:
- PFK rules;
- manually-derived fixture;
- source-to-column causal audit

đều nhất quán, external difference không tự động làm Kernel FAIL.

Ngược lại, external match không thể thay thế native/manual acceptance.

## PFK43 — Performance constraint

Kernel cần `SetBarsRequired(sbrAll,sbrAll)` hoặc cơ chế tương đương nếu historical state machine cần toàn lịch sử.

Acceptance phải đo trên lịch sử dài và nhiều symbol.

Tuy nhiên performance optimization không được:
- cắt mất warm-up cần thiết;
- đổi column history;
- dùng future knowledge;
- thay rules bằng heuristic.

## PFK44 — Gate mở khóa P&F Cause / Price Objective

PFO46 chỉ được coi **đã thỏa ở cấp triển khai** khi:

1. PFK01–PFK44 được owner phê duyệt và khóa;
2. P&F Construction Kernel AFL được viết;
3. static conformance PASS;
4. manual fixture package tồn tại;
5. AmiBroker Verify Syntax chạy được;
6. core construction fixture suite chạy và không có unresolved semantic mismatch;
7. 1-box two-entry suite PASS;
8. causal prefix/append PASS;
9. source-to-column mapping fixtures PASS.

Theo chiến lược build-first hiện hành, owner có thể cho phép Cause Engine **source-development** bắt đầu sau mục 1–4, nhưng không được gọi PFO46 native PASS trước khi mục 5–9 hoàn tất.

---

## 3. Các phản ví dụ bắt buộc

1. X-column: High đủ thêm 1 X nhưng Low cũng đủ 3-box reversal → chỉ extend X, Low bị bỏ qua.
2. O-column đối xứng.
3. X không extend, Low đúng reversal grid → reversal xảy ra.
4. Low thiếu một lượng nhỏ có ý nghĩa so với grid → không reversal; tolerance không được cứu.
5. 1-box X chỉ có một posting, giá giảm một box → không mở O.
6. Sau khi X có hai postings, giảm một box → O được mở.
7. New O 1-box chỉ một posting rồi bar sau High tăng một box → không đảo lại X nếu O chưa có posting thứ hai.
8. Một bar reversal đi xa 7 boxes → tạo một new column với nhiều postings, không tạo nhiều columns.
9. Current X extends High rồi Low trong cùng bar rơi sâu → Low vẫn bị bỏ qua.
10. Bootstrap cả Up/Down cùng 2 boxes → không chọn ngẫu nhiên, tiếp tục ambiguous.
11. Bootstrap Up 3, Down 2 → X first direction theo project convention.
12. Invalid bar giữa một open column → geometry không fill bằng prior value.
13. Provisional final bar phá reversal threshold → official column history chưa được cập nhật.
14. Reversal tại t → prior column FinalizedAt=t, không phải LastExtendedAt trước đó.
15. Upstream LPS KnownAt ở t nhưng origin ở t-2 → causal mapping mặc định dùng t.
16. Dataset được prepend thêm rất nhiều warm-up bars → RangeContext nằm sau maturity phải cho cùng construction suffix nếu source/config tương đương; nếu không, phải điều tra bootstrap dependence.
17. BoxSize đổi giữa run → construction identity khác, không so như cùng generation.
18. Adjustment basis thay đổi → không gọi historical difference là repaint.

---

## 4. Native acceptance plan đề xuất

### PFK-A01 — Verify Syntax AmiBroker 6.20.01
AFL Kernel + exploration harness phải compile.

### PFK-A02 — 3-box manual fixtures
Các fixture 1–8 trong PFK40.

### PFK-A03 — 1-box two-entry fixtures
Các fixture 9–11.

### PFK-A04 — Bootstrap fixtures
Các fixture 12–15.

### PFK-A05 — Grid/boundary/floating fixtures
Các fixture 16–17.

### PFK-A06 — Provisional fixtures
18–19.

### PFK-A07 — Determinism rerun
20.

### PFK-A08 — Causal-prefix/append
21.

### PFK-A09 — Source revision
22.

### PFK-A10 — Anchor mapping
23.

### PFK-A11 — Maturity gate
24.

### PFK-A12 — External construction cross-check
Cấu hình cố định, ghi rõ mismatch classification.

### PFK-A13 — Long-history performance
Ít nhất một tập symbol dài, đo thời gian và memory behavior.

---

## 5. Quyết định cần owner duyệt

| Nhóm | Nội dung | Khuyến nghị |
|---|---|---|
| PFK01–PFK10 | Scope/config/grid/high-low path | Chấp thuận rất mạnh |
| PFK11–PFK15 | Bootstrap causal + maturity guard | Chấp thuận rất mạnh |
| PFK16–PFK20 | High-Low precedence/reversal | Chấp thuận bắt buộc |
| PFK21–PFK22 | 1-box two-entry rule | Chấp thuận bắt buộc |
| PFK23–PFK30 | Column identity/provenance/gaps | Chấp thuận rất mạnh |
| PFK31–PFK34 | Provisional/source revision/config identity | Chấp thuận rất mạnh |
| PFK35–PFK39 | Public contract + anchor mapping | Chấp thuận rất mạnh |
| PFK40–PFK43 | Fixtures/parity/performance | Chấp thuận bắt buộc |
| PFK44 | Gate mở P&F Cause/Objective | Chấp thuận bắt buộc |

---

## 6. Trình tự sau khi được duyệt

1. Khóa PFK01–PFK44.
2. Tạo branch `pnf/pnf-construction-kernel-v0.1-development`.
3. Viết Kernel AFL + Exploration/fixture harness.
4. Tạo manually-derived fixture package.
5. Static audit.
6. Giữ PR implementation ở `SPEC-ALIGNED / UNTESTED DEVELOPMENT` cho tới native test.
7. Sau khi source-level gate đủ, mới triển khai P&F Cause / Price Objective Engine theo PFO01–PFO48.
8. Native acceptance PFO46 chỉ đóng khi PFK-A01–A11 không còn unresolved semantic mismatch.

## 7. Kết luận

P&F Construction Kernel phải được xem như **hạ tầng hình học**, không phải chỉ báo. Nếu cột X/O, reversal hoặc mapping thời gian sai thì horizontal Cause phía sau không thể sửa bằng Phase/VSA.

Thiết kế v0.1 ưu tiên ba tính chất:

`DETERMINISTIC → CAUSAL → AUDITABLE`

trước khi tối ưu hiệu năng hay mở thêm scaling/timeframe.