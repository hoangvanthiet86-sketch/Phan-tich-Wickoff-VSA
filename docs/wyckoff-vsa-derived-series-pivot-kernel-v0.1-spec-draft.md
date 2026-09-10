# Wyckoff VSA Derived-Series Pivot Kernel — Dự thảo đặc tả v0.1

**Trạng thái:** `DRAFT FOR OWNER APPROVAL` — chưa khóa, chưa có AFL triển khai, chưa phải tiêu chí nghiệm thu native.

## 1. Vai trò kiến trúc

Tài liệu này thực hiện cổng kiến trúc **R35** của `Relative Strength Context v0.1` đã được chủ dự án phê duyệt tại PR #32 và merge vào `main` tại `2dedab4168c4845b66a92021ce9a59137a939e82`.

Mục tiêu là cho phép áp dụng **chính xác cùng semantics pivot causal của Structure/Location v1.0** lên một chuỗi số dẫn xuất như Relative Strength Ratio mà không tạo ra định nghĩa pivot thứ hai.

Chuỗi mục tiêu:

`Derived numeric series + validity + source coordinates + SL PivotLeft/PivotRight → Derived-Series Pivot Kernel → confirmed High/Low pivots + prior/latest snapshots → Relative Strength Structure`

Kernel này là hạ tầng cấu trúc, **không phải Relative Strength Engine**, không biết Market/Group benchmark, không tính RSRatio, không tạo Phase/Event/Buy/Sell.

---

## 2. Kết quả nghiên cứu source hiện hành

Nguồn chuẩn để đối chiếu là `afl/WyckoffVSA_StructureLocation_v1.0.afl` trên `main`.

Semantics pivot hiện hành được xác định như sau:

1. `PivotLeft` và `PivotRight` đều là số nguyên trong `[1,20]`.
2. Chiều dài cửa sổ = `A + B + 1`.
3. Candidate tại thanh xác nhận `i` nằm ở offset `k = i - B`.
4. Cửa sổ chỉ `READY` khi toàn bộ `A+B+1` giá trị nguồn hợp lệ.
5. Pivot High:
   - candidate **strictly greater** mọi giá trị bên trái;
   - candidate **greater than or equal** mọi giá trị bên phải tới thanh xác nhận.
6. Pivot Low đối xứng:
   - candidate **strictly less** mọi giá trị bên trái;
   - candidate **less than or equal** mọi giá trị bên phải tới thanh xác nhận.
7. Event chỉ được công bố tại thanh `i`, không backfill về candidate `k`.
8. `ExtremeBarIndex/DateTime` và `ConfirmBarIndex/DateTime` là hai tọa độ khác nhau.
9. `LatestPrior...` tại thanh `i` chứa snapshot của pivot đã xác nhận **trước khi** đánh giá thanh `i`.
10. `Latest...` tại thanh `i` chứa trạng thái **sau khi** đánh giá thanh `i`; nếu một pivot mới được xác nhận tại `i`, Latest chuyển sang pivot mới ngay tại `i`.
11. Age/BarsSinceConfirmation được đo bằng logical source offset, không giả định BarIndex liên tục.
12. Không dùng Zig/Peak/Trough và không có future offset.

Đặc tả này coi các semantics trên là **chuẩn hành vi bắt buộc**, không phải gợi ý.

---

# QUYẾT ĐỊNH THIẾT KẾ K01–K32

## K01 — Phạm vi

Kernel v0.1 nhận một **arbitrary numeric series** đã được căn theo timeline của symbol hiện tại và tạo confirmed pivots causal cho chính series đó.

Ví dụ consumer đầu tiên là:

`RSRatio = StockClose / BenchmarkClose`.

Kernel không giới hạn cho Relative Strength để có thể tái sử dụng sau này, nhưng v0.1 chỉ được dùng khi consumer đã có contract riêng.

## K02 — Không sửa released Structure/Location v1.0 trong giai đoạn này

Để tránh thay đổi một module đã có release/acceptance history, v0.1 **không refactor trực tiếp** `WyckoffVSA_StructureLocation_v1.0.afl`.

Thay vào đó tạo một derived-series kernel/facade riêng và bắt buộc chứng minh **static equivalence** với pivot logic hiện hành.

Sau chiến dịch native regression, dự án có thể cân nhắc refactor shared kernel ở version sau.

## K03 — Chuẩn tham chiếu duy nhất

Chuẩn hành vi là pivot implementation của Structure/Location v1.0 đang tồn tại tại thời điểm khóa contract này.

Không dùng một mô tả sách Wyckoff chung chung để tự thay đổi tie semantics hoặc publication semantics.

## K04 — Inputs bắt buộc

Một lần chạy kernel tối thiểu nhận:

- `Series`;
- `SeriesValid`;
- `PivotLeft = A`;
- `PivotRight = B`;
- `SourceBarIndex`;
- `SourceDateTime`;
- `SourceOffset` hoặc khả năng tự tạo logical offset tương đương;
- namespace/tag output deterministic.

## K05 — SeriesValid là authoritative

Kernel không tự suy đoán validity từ `Series != 0`.

Một phần tử hợp lệ khi consumer nói `SeriesValid=1` và giá trị finite/non-null.

Nếu validity và numeric finiteness mâu thuẫn, phần tử được coi là invalid.

## K06 — Không fill missing derived data

Kernel không forward-fill, backward-fill, interpolate hoặc dùng Nz để biến missing derived value thành dữ liệu hợp lệ.

Với Relative Strength, benchmark hole phải làm window tương ứng invalid theo R22/R23 của RS spec.

## K07 — Cấu hình A/B phải tương đương Structure

`A` và `B` chỉ hợp lệ nếu là số nguyên trong `[1,20]`.

Không tạo tuning range riêng cho derived series.

Relative Strength v0.1 phải truyền đúng `SL_PivotLeft` và `SL_PivotRight` hiện hành.

## K08 — Window length và first eligible bar

`WindowLength = A + B + 1`.

Thanh `i` chỉ có full pivot window khi logical offset `>= A+B`.

Không giả định first eligible bar bằng một DateTime hoặc BarIndex cụ thể.

## K09 — Window validity count

Cửa sổ tại `i` chỉ valid khi **toàn bộ** `WindowLength` phần tử từ `i-(A+B)` đến `i` hợp lệ.

Một missing value ở bất kỳ vị trí nào trong cửa sổ làm `WindowValid=0`.

## K10 — Window status enum phải tương đương

Đề xuất giữ đúng semantics:

- 0 = `INSUFFICIENT HISTORY`;
- 1 = `INVALID REFERENCE DATA`;
- 2 = `READY`;
- 3 = `INVALID CONFIG`.

Không collapse invalid data vào insufficient history.

## K11 — Candidate location

Khi window valid tại `i`:

`CandidateOffset = i - B`.

Output phải có candidate SourceBarIndex/DateTime nếu full window tồn tại, kể cả khi event không phải pivot.

## K12 — Pivot High tie semantics

High candidate `v = Series[k]` chỉ confirmed nếu:

- với mọi `j = k-A ... k-1`: `v > Series[j]`;
- với mọi `j = k+1 ... i`: `v >= Series[j]`.

Không epsilon, không rounding.

Điều này cố ý bất đối xứng trái/phải và phải giữ nguyên.

## K13 — Pivot Low tie semantics

Low candidate `v = Series[k]` chỉ confirmed nếu:

- với mọi `j = k-A ... k-1`: `v < Series[j]`;
- với mọi `j = k+1 ... i`: `v <= Series[j]`.

Không epsilon, không rounding.

## K14 — Vì sao right side inclusive phải được giữ

Plateau bằng candidate ở phía **sau** không hủy pivot; giá trị bằng candidate ở phía **trước** hủy pivot.

Đây là hành vi locked của Structure v1.0 và là counterexample bắt buộc trong kiểm thử equivalence.

## K15 — Event validity và event code

Cho High và Low riêng:

- `EventValid = WindowValid`;
- EventCode 0 = `INSUFFICIENT DATA` khi window invalid;
- EventCode 1 = `NOT PRESENT` khi window valid nhưng candidate không đạt;
- EventCode 2 = `CONFIRMED PIVOT` khi đạt.

Không dùng code 1 cho invalid window.

## K16 — Publication time

Pivot chỉ được publish tại confirm bar `i`.

Không được đặt EventCode=2 tại extreme bar `k` trong historical array.

Marker/chart consumer muốn hiển thị extreme phải mang provenance rằng extreme chỉ được biết tại confirm time.

## K17 — Tọa độ phải tách Extreme và Confirm

Mỗi confirmed pivot phải xuất tối thiểu:

- EventPrice;
- ExtremeBarIndex;
- ExtremeDateTime;
- ConfirmBarIndex;
- ConfirmDateTime;
- ConfirmationLag = B.

## K18 — Latest snapshot semantics

`Latest...` tại bar `i` là pivot mới nhất **sau khi xử lý i**.

Nếu pivot mới được confirmed tại i, Latest tại chính i phải phản ánh pivot mới.

## K19 — LatestPrior snapshot semantics

`LatestPrior...` tại bar `i` là pivot mới nhất **trước khi xử lý i**.

Nếu i xác nhận pivot mới, LatestPrior tại i vẫn là pivot cũ; chỉ từ bar kế tiếp pivot mới mới trở thành LatestPrior.

Đây là contract quan trọng cho causal Event/Sequence consumer.

## K20 — Latest/Prior coordinates và age

High và Low phải độc lập xuất:

- Valid;
- Price;
- ExtremeBarIndex/DateTime;
- ConfirmBarIndex/DateTime;
- Age;
- BarsSinceConfirmation.

Age = logical current offset − stored extreme offset.

BarsSinceConfirmation = logical current offset − stored confirm offset.

## K21 — SourceOffset khác SourceBarIndex

Kernel không được dùng `SourceBarIndex` để tính age nếu mục đích là số thanh đã trôi qua.

Phải dùng logical array/source offset tương đương `Cum(1)-1` như Structure v1.0.

Điều này bảo vệ semantics khi database BarIndex không được xem như một counter portable cho derived consumer.

## K22 — Không future access

Trong xử lý bar i, kernel chỉ được truy cập tối đa đến i.

`k=i-B` là candidate lịch sử được xác nhận bằng dữ liệu tới hiện tại, không phải look-ahead.

Cấm:

- positive `Ref`;
- Zig/Peak/Trough;
- PeakBars/TroughBars hoặc primitive backfill tương đương;
- đọc bar > i trong loop.

## K23 — High/Low của derived series là cùng một numeric series

Đối với RSRatio, cả Pivot High và Pivot Low đều dùng **chính ratio series**, không tạo synthetic HighRS/LowRS từ stock/benchmark OHLC trong v0.1.

Lý do: RS spec R06 định nghĩa identity bằng Close ratio.

Nếu sau này muốn OHLC relative series, phải có đặc tả mới.

## K24 — Namespace contract

Đề xuất prefix kernel: `WDPK_` ở module hạ tầng.

Consumer phải truyền channel key riêng, ví dụ:

- `SVM` = Stock-vs-Market;
- `SVG` = Stock-vs-Group;
- `GVM` = Group-vs-Market.

Output của các channel không được collision.

## K25 — Kernel không sinh RS Structure Code

Kernel dừng ở confirmed pivots/snapshots.

Logic HH+HL / LH+LL / mixed thuộc Relative Strength Context Engine theo R11.

Như vậy kernel không biết ý nghĩa “strong/weak”.

## K26 — Không sửa price Structure state

Derived kernel không VarSet vào namespace `SL_` và không overwrite `SL_PivotHigh...` / `SL_PivotLow...`.

Structure/Location của giá và derived structure cùng tồn tại độc lập.

## K27 — Static equivalence bắt buộc trước khi R35 được coi là thỏa

Implementation phải có một audit mode/harness chạy kernel trên:

- `Series = High`, so High-pivot outputs với `SL_PivotHigh...`;
- `Series = Low`, so Low-pivot outputs với `SL_PivotLow...`;
- cùng A/B;
- cùng source validity/timeline.

Các output tương ứng phải khớp **cell-by-cell** trên vùng cùng valid.

Không được chỉ so số lượng pivot.

## K28 — Trường phải so trong equivalence audit

Tối thiểu cho mỗi High/Low:

- EventValid;
- EventCode;
- EventPrice;
- ExtremeBarIndex;
- ExtremeDateTime;
- ConfirmBarIndex;
- ConfirmDateTime;
- ConfirmationLag;
- LatestValid;
- LatestPrice;
- LatestExtremeBarIndex/DateTime;
- LatestConfirmBarIndex/DateTime;
- LatestAge;
- LatestBarsSinceConfirmation;
- LatestPriorValid;
- LatestPriorPrice;
- LatestPriorExtremeBarIndex/DateTime;
- LatestPriorConfirmBarIndex/DateTime;
- LatestPriorAge;
- LatestPriorBarsSinceConfirmation.

Window/config diagnostics cũng phải so khi kernel được feed cùng validity source.

## K29 — Counterexamples bắt buộc

Fixture/harness về sau tối thiểu phải có:

1. first eligible window;
2. insufficient history;
3. invalid A/B thấp hơn 1;
4. invalid A/B lớn hơn 20;
5. missing candidate;
6. missing left-edge value;
7. missing right/confirm value;
8. High tie bên trái → không pivot;
9. High tie bên phải → vẫn có thể pivot;
10. Low tie bên trái → không pivot;
11. Low tie bên phải → vẫn có thể pivot;
12. hai pivot liên tiếp để kiểm tra Latest/Prior;
13. pivot confirmed tại i: Latest đổi nhưng LatestPrior chưa đổi;
14. exact numeric equality, không epsilon;
15. derived ratio có benchmark hole;
16. append thêm bar không được sửa outputs đã causal-final trước đó;
17. prefix-run không được thay đổi các bar cũ;
18. source revision phải phân biệt với algorithmic repaint.

## K30 — Derived-series validity cho Relative Strength

Khi consumer là RS ratio:

`RatioValid = StockCloseValid AND BenchmarkCloseValid AND BenchmarkClose > 0 AND Ratio finite`.

Kernel chỉ nhận `Ratio` + `RatioValid`; logic Foreign/benchmark mapping nằm ngoài kernel.

## K31 — Điều kiện chuyển sang triển khai

Chỉ sau khi chủ dự án phê duyệt K01–K32 mới:

1. merge docs-only contract này vào `main`;
2. tạo implementation branch xếp chồng trên Multi-Timeframe/Relative-Strength development stack phù hợp;
3. viết `DerivedSeriesPivotKernel_v0.1` hoặc `RelativeStrength_StructureFacade_v0.1` theo contract;
4. viết static equivalence audit với Structure/Location v1.0;
5. chỉ khi source/interface equivalence không còn mismatch mới coi **R35 thỏa ở cấp source**;
6. sau đó mới viết full Relative Strength Context AFL;
7. native AmiBroker Verify Syntax/fixtures/causal regression vẫn được hoãn theo chiến lược dự án hiện tại và không được gọi PASS trước khi thực chạy.

## K32 — Không trading/scoring semantics

Kernel tuyệt đối không tạo:

- Buy/Sell/Short/Cover;
- PositionSize;
- strength score;
- confidence/probability;
- ranking/percentile;
- Phase/Event/Family interpretation.

---

## 3. Lựa chọn triển khai được khuyến nghị

Khuyến nghị cho v0.1 là **không refactor Structure/Location released source ngay**.

Thay vào đó:

1. tạo một generic derived-series pivot kernel/facade độc lập;
2. đóng băng chính xác semantics K07–K21;
3. dùng Structure/Location v1.0 làm behavioral oracle trong static equivalence audit;
4. chỉ sau khi chiến dịch native regression hoàn tất mới cân nhắc hợp nhất hai code path ở phiên bản sau.

Lựa chọn này giảm blast radius: R35 được thực hiện mà không làm thay đổi engine cấu trúc giá đang được các Event/Sequence/Phase module phụ thuộc.

---

## 4. Bảng quyết định cần chủ dự án phê duyệt

| Mã | Đề xuất | Khuyến nghị |
|---|---|---|
| K01 | Generic derived numeric series | Chấp thuận mạnh |
| K02 | Không refactor released Structure v1.0 trong v0.1 | Chấp thuận rất mạnh |
| K03 | Structure v1.0 là behavioral oracle | Chấp thuận rất mạnh |
| K04 | Input contract rõ Series/Valid/A/B/coords | Chấp thuận rất mạnh |
| K05 | SeriesValid authoritative + finite gate | Chấp thuận rất mạnh |
| K06 | Không fill missing derived data | Chấp thuận rất mạnh |
| K07 | A/B giống Structure, 1–20 | Chấp thuận rất mạnh |
| K08–K10 | Window/full/status semantics giống Structure | Chấp thuận rất mạnh |
| K11 | Candidate = i-B | Chấp thuận rất mạnh |
| K12–K14 | Strict-left / inclusive-right | Chấp thuận rất mạnh |
| K15 | Event 0/1/2 giống Structure | Chấp thuận rất mạnh |
| K16–K17 | Confirm-time publication + dual coordinates | Chấp thuận rất mạnh |
| K18–K21 | Latest/LatestPrior/age semantics giống Structure | Chấp thuận rất mạnh |
| K22 | Không future primitive | Chấp thuận rất mạnh |
| K23 | RS Close-ratio series cho cả high/low pivot | Chấp thuận mạnh |
| K24 | Namespace độc lập theo channel | Chấp thuận mạnh |
| K25–K26 | Kernel chỉ structure, không RS interpretation/SL overwrite | Chấp thuận rất mạnh |
| K27–K29 | Cell-by-cell static equivalence + counterexamples | Chấp thuận rất mạnh |
| K30 | Ratio validity do RS consumer tạo | Chấp thuận mạnh |
| K31 | R35 source gate trước full RS AFL | Chấp thuận rất mạnh |
| K32 | Không trading/scoring | Chấp thuận rất mạnh |

---

## 5. Kết luận

R35 không nên được xử lý bằng cách “viết một pivot trông giống nhau”. Nó phải được xử lý như một **behavioral-equivalence contract**.

Nguyên tắc cốt lõi:

`SAME A/B + SAME VALID WINDOW + STRICT LEFT / INCLUSIVE RIGHT + CONFIRM-TIME PUBLICATION + SAME LATEST/PRIOR SNAPSHOTS + CELL-BY-CELL EQUIVALENCE`.

Sau khi K01–K32 được phê duyệt và kernel/facade vượt static equivalence audit, full Relative Strength Context AFL mới được phép bắt đầu.