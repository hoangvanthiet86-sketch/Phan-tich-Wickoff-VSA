# Wyckoff VSA Relative Strength Context Engine — Dự thảo đặc tả v0.1

**Trạng thái:** `DRAFT FOR OWNER APPROVAL` — chưa khóa, chưa phải tiêu chí nghiệm thu, chưa có AFL triển khai.

## 1. Vai trò kiến trúc

Relative Strength Context Engine nằm sau Composite / Multi-Timeframe Context và trước Market Scanner:

`Core → Candidate → Structure/Location → Confirmation → Event → Structural Sequence → Phase/Context → Composite → Multi-Timeframe Context → Relative Strength Context → Market Scanner`

Mục tiêu của v0.1 là cung cấp **bối cảnh sức mạnh/yếu tương đối theo tinh thần Wyckoff**, để trả lời:

1. cổ phiếu đang mạnh/yếu hơn thị trường hay chưa đủ bằng chứng;
2. nếu có benchmark nhóm/ngành, cổ phiếu đang mạnh/yếu hơn nhóm hay chưa đủ bằng chứng;
3. bản thân nhóm đang mạnh/yếu hơn thị trường hay không;
4. cấu trúc giá của cổ phiếu và cấu trúc Relative Strength đang đồng thuận hay phân kỳ;
5. Relative Strength có đang hỗ trợ hay xung đột với Phase/Family/VSA background hiện tại;
6. dữ liệu benchmark có đầy đủ, đồng bộ và có thể kiểm toán hay không.

Engine **không** tạo Buy/Sell/Short/Cover, không tạo điểm 0–100, không confidence %, không probability %, không percentile/ranking toàn thị trường và không thay đổi Phase/Family upstream.

---

## 2. Cơ sở nghiên cứu Wyckoff / VSA / AmiBroker

### 2.1 Wyckoff: comparative strength là phần cốt lõi của stock selection

Nguồn chính:

- Wyckoff Analytics — *Wyckoff Method*, phần Comparative Strength Analysis.
- StockCharts ChartSchool — *The Wyckoff Method: A Tutorial*.
- StockCharts ChartSchool — *Wyckoff Stock Analysis*.
- Bruce Fraser / StockCharts — *In Gear with Relative Strength*.
- Bruce Fraser / StockCharts — *Combining Wyckoff and Relative Strength to Find Big Trends*.
- Bruce Fraser / StockCharts — *Win the Race with Relative Strength*.
- Bruce Fraser / StockCharts — *Sectors. Groups. Stocks.*

Các kết luận trực tiếp cho thiết kế:

1. Wyckoff so sánh cổ phiếu/ngành với thị trường bằng các **wave/swing tương ứng**, đặc biệt các high/low quan trọng.
2. Cổ phiếu giữ tốt hơn khi thị trường giảm, hoặc tăng mạnh hơn khi thị trường tăng, là biểu hiện relative strength; ngược lại là relative weakness.
3. Modern Wyckoff có thể dùng **Relative Strength Ratio** để loại ảnh hưởng khác biệt thang giá.
4. Relative Strength là một bằng chứng chọn cổ phiếu, không thay thế cấu trúc, Phase hay Supply/Demand.
5. Trong Nine Buying Tests, favorable relative strength là một tiêu chí quan trọng; nhưng dự án này chưa xây Nine Tests Engine nên Relative Strength Context **không tự tuyên bố “Test #7 PASS”**.
6. Bruce Fraser nhấn mạnh quy trình drill-down từ market → sector/group → stock, và RS thường hữu ích ở việc tìm leadership/laggard.
7. RS có thể cung cấp non-confirmation/divergence sớm, nhưng đó là **context**, không phải lệnh giao dịch.

### 2.2 VSA: Relative Strength là lớp chọn ứng viên, không thay VSA background

Nguồn:

- TradeGuider Stock Scanner / EOD platform: so sánh stock với parent index để tìm outperform/underperform.
- TradeGuider materials: sau khi scan relative strength vẫn phải đọc VSA signals, background, effort/result và confirmation trên chart.

Kết luận cho dự án:

1. RS và VSA là hai lớp bằng chứng khác nhau.
2. Một cổ phiếu mạnh tương đối nhưng có weakness rõ trong VSA background không được RS Engine xóa weakness đó.
3. Một cổ phiếu yếu tương đối nhưng đang có bullish Phase C/D không được RS Engine sửa Phase; phải xuất **conflict**.
4. Market Scanner sau này có thể dùng RS + VSA + MTF cùng lúc, nhưng không được biến chúng thành xác suất giả nếu chưa có calibration.

### 2.3 AmiBroker: comparative RS và dữ liệu benchmark

Nguồn kỹ thuật:

- AmiBroker `RelStrength()` — comparative relative strength.
- AmiBroker `Foreign()` — dữ liệu symbol khác được đồng bộ theo timestamp với symbol hiện tại.
- AmiBroker `GetBaseIndex()` — có thể lấy base index từ Categories.

Các kết luận kỹ thuật:

1. `RelStrength()` là comparative RS, **không phải RSI**.
2. `Foreign()` đồng bộ benchmark theo từng date của symbol hiện tại, phù hợp cho phép chia/comparison.
3. `Foreign(..., fixup=1)` có thể điền hole bằng previous close; điều này tiện cho chart nhưng có thể che mất missing benchmark data trong một hệ thống cần audit.
4. Vì vậy v0.1 đề xuất dùng benchmark Close qua `Foreign(...,"C",0)` và tự kiểm tra Null/validity; không silent fill-forward.
5. Nếu benchmark không tồn tại hoặc thiếu bar đúng ngày, channel phải fail closed thay vì tạo RS giả.

### 2.4 Cấu trúc pivot hiện có của dự án

`WyckoffVSA_StructureLocation_v1.0.afl` đã khóa một semantics pivot causal:

- cửa sổ trái strict;
- cửa sổ phải inclusive;
- chỉ công bố pivot tại bar xác nhận;
- lưu riêng extreme BarIndex/DateTime và confirm BarIndex/DateTime;
- không dùng Zig/Peak/Trough để backfill.

Relative Strength v0.1 **không được tạo một thuật toán pivot thứ hai có semantics khác** chỉ vì input là ratio.

---

# QUYẾT ĐỊNH THIẾT KẾ R01–R36

## R01 — Scope v0.1

V0.1 là engine comparative-strength cho **một symbol hiện tại** trên **một native EOD timeframe**.

Official integration đầu tiên của dự án là Daily.

Không làm historical cross-timeframe RS timeline, intraday RS hoặc cross-market currency-normalized RS trong v0.1.

## R02 — Benchmark hierarchy

V0.1 có tối đa ba pairwise channels:

1. `STOCK vs MARKET` — bắt buộc;
2. `STOCK vs GROUP` — tùy chọn;
3. `GROUP vs MARKET` — chỉ có khi Group benchmark hợp lệ.

`GROUP` là một benchmark nhóm/ngành do cấu hình cung cấp. V0.1 chưa phân tách riêng Sector và Industry thành hai tầng bắt buộc.

## R03 — Market benchmark phải explicit

Không hardcode benchmark market vào methodology.

Deployment profile có thể chọn VNINDEX/VN30 hoặc benchmark khác, nhưng engine normative chỉ nhận `MarketBenchmarkSymbol` đã cấu hình.

Không tự im lặng dùng một ticker mặc định nếu cấu hình trống/sai.

## R04 — Group benchmark tùy chọn nhưng explicit

Nếu không có Group benchmark hợp lệ:

- Stock-vs-Group = `NOT AVAILABLE`;
- Group-vs-Market = `NOT AVAILABLE`;
- không dùng Market benchmark để giả làm Group.

## R05 — Không dùng benchmark auto-map không kiểm chứng

`GetBaseIndex()` có thể được dùng như helper ở integration layer, nhưng v0.1 không coi kết quả Categories là authoritative nếu không có kiểm tra mapping.

Benchmark identity phải được export để audit.

## R06 — Công thức nền tảng = price ratio

Cho pair `A vs B`:

`RSRatio = Close_A / Close_B`

với điều kiện cả hai Close finite và `Close_B > 0`.

Ratio tăng = A outperform B trong khoảng đó; ratio giảm = A underperform B.

Không dùng RSI/Wilder RSI.

## R07 — Raw ratio level không phải ranking score

Giá trị tuyệt đối của ratio phụ thuộc thang giá và không được so trực tiếp giữa các cổ phiếu như ranking.

Engine chỉ sử dụng:

- cấu trúc ratio;
- thay đổi ratio;
- quan hệ ratio với các swing đã xác nhận;
- contextual alignment.

## R08 — Không fixed-return window làm identity chính

Không định nghĩa relative strength bằng các công thức bắt buộc kiểu:

- 20-day return;
- 3-month return;
- 6-month return;
- 12-month weighted score.

Các cửa sổ như vậy có thể là descriptor/scanner extension sau này nhưng không phải identity của Wyckoff RS v0.1.

## R09 — Ratio structure dùng confirmed pivots causal

Mỗi pairwise ratio phải có confirmed Pivot High/Pivot Low theo **cùng semantics** với Structure/Location v1.0:

- left strict;
- right inclusive;
- KnownAt = confirm bar;
- không backfill;
- không Zig/Peak/Trough.

## R10 — Không tạo pivot tuning riêng v0.1

RS pivot mặc định dùng cùng `PivotLeft/PivotRight` đã khóa trong Structure/Location.

Không tạo một bộ `RS Pivot = 5/5` khác nếu chưa có đặc tả/kiểm thử riêng.

## R11 — RS Structure Code

Cho từng pair:

- 0 = `INSUFFICIENT`;
- 1 = `RISING RS STRUCTURE`;
- 2 = `FALLING RS STRUCTURE`;
- 3 = `MIXED / RANGE RS STRUCTURE`.

`RISING` khi hai confirmed ratio highs gần nhất tạo higher high **và** hai confirmed ratio lows gần nhất tạo higher low.

`FALLING` khi lower high **và** lower low.

Các tổ hợp khác = mixed.

So sánh strict, không epsilon/rounding.

## R12 — RS structure chỉ được biết tại confirm time

Một ratio extreme tại bar k không được công bố thành RS pivot ở k nếu phải chờ B bars để xác nhận.

Output phải mang:

- ExtremeBarIndex/DateTime;
- ConfirmBarIndex/DateTime;
- confirmation lag.

Chart marker xác nhận dùng KnownAt/Confirm bar, không vẽ như thể biết trước tại extreme.

## R13 — Comparative wave descriptors

Engine được phép xuất descriptor cho completed RS swing:

- direction;
- start/end ratio;
- percentage change của ratio;
- start/end DateTime;
- duration bars.

Không dùng magnitude này làm confidence score.

## R14 — Price structure comparison

Để đọc Wyckoff non-confirmation mà không phát minh oscillator, engine so:

- confirmed **price structure** của current stock từ Structure/Location;
- confirmed **RS ratio structure** của pair.

Price structure dùng cùng nguyên tắc HH/HL, LH/LL, mixed/insufficient.

## R15 — Price/RS Relationship Code

Cho Stock-vs-Market và Stock-vs-Group:

- 0 = `INSUFFICIENT`;
- 1 = `PRICE + RS RISING IN GEAR`;
- 2 = `PRICE RISING / RS NON-CONFIRMING`;
- 3 = `PRICE FALLING / RS NON-CONFIRMING STRONGER`;
- 4 = `PRICE + RS FALLING IN GEAR`;
- 5 = `MIXED / COMPLEX`.

Trong đó:

- price rising + RS rising → 1;
- price falling + RS falling → 4;
- price rising + RS falling → 2;
- price falling + RS rising → 3;
- mixed states → 5.

Không gọi code 2/3 là reversal confirmation.

## R16 — Không gắn nhãn DNC/UNC nếu chưa có matching-swing contract

Bruce Fraser dùng các khái niệm non-confirmation ở các ví dụ RS.

V0.1 **không** tự gán `DNC`/`UNC` chỉ từ hai structure codes nếu chưa chứng minh hai swing tương ứng về mặt thời gian.

Thay vào đó dùng tên trung tính `PRICE/RS STRUCTURAL NON-CONFIRMATION`.

Một matching-swing DNC/UNC chính thức có thể thêm v0.2.

## R17 — Market RS State là kênh chính

`StockVsMarketRSStructureCode` là kênh bắt buộc để đánh giá comparative strength theo Wyckoff stock selection.

Nếu Market benchmark invalid/missing, toàn Relative Strength Context chính = insufficient.

## R18 — Group RS State độc lập

`StockVsGroupRSStructureCode` không được overwrite Stock-vs-Market.

Một stock có thể:

- mạnh hơn group nhưng yếu hơn market;
- yếu hơn group nhưng mạnh hơn market.

Đây là conflict có ý nghĩa, không phải lỗi cần collapse.

## R19 — Group-vs-Market là leadership context

Nếu Group benchmark hợp lệ, tính `GroupVsMarketRSStructureCode` bằng cùng công thức/pivot semantics.

Không lấy trung bình RS của các cổ phiếu trong group trong v0.1.

## R20 — Leadership Chain Code

Chỉ khi đủ Market + Group data:

- 0 = `INSUFFICIENT`;
- 1 = `NESTED RELATIVE LEADERSHIP` — Group>Market rising và Stock>Group rising;
- 2 = `NESTED RELATIVE WEAKNESS` — Group<Market falling và Stock<Group falling;
- 3 = `STOCK LEADS WEAK GROUP`;
- 4 = `STOCK LAGS STRONG GROUP`;
- 5 = `MIXED / COMPLEX LEADERSHIP`.

Đây là categorical context, không phải score/ranking.

## R21 — Stock-vs-Market không bị suy ra từ chain

Dù Group-vs-Market + Stock-vs-Group cùng rising, engine vẫn phải giữ và export trực tiếp Stock-vs-Market channel.

Không suy diễn bằng phép cộng các state.

## R22 — Phase/RS Alignment là diagnostic riêng

Engine được phép so RS với Composite/Phase upstream:

- 0 = insufficient;
- 1 = bullish phase/family context + rising RS;
- 2 = bullish phase/family context + falling RS;
- 3 = bearish phase/family context + falling RS;
- 4 = bearish phase/family context + rising RS;
- 5 = unresolved/mixed.

RS không sửa Phase/Family.

## R23 — VSA/RS Alignment là diagnostic riêng

So EvidenceBalance upstream với Stock-vs-Market RS:

- bullish VSA evidence + rising RS = aligned bullish;
- bearish VSA evidence + falling RS = aligned bearish;
- evidence và RS trái nhau = conflict;
- mixed/insufficient giữ riêng.

Không dùng VSA volume trong công thức RSRatio.

## R24 — Multi-Timeframe context không bị RS override

MTF Alignment đã có upstream giữ nguyên.

Relative Strength Context chỉ xuất `RS_vs_MTF_RelationshipCode`, ví dụ:

- MTF bullish + RS rising;
- MTF bullish + RS falling;
- MTF bearish + RS falling;
- MTF bearish + RS rising;
- mixed/insufficient.

Không có quy tắc “RS thắng MTF” hoặc “MTF thắng RS”.

## R25 — Native-timeframe only trong v0.1

RS pairwise computation chạy trên timeframe hiện tại, không tự nén/mở rộng Daily→Weekly→Monthly bên trong engine.

Official integration v0.1 chạy Daily cùng Market Scanner.

Weekly/Monthly RS transport là extension riêng sau khi Daily RS được nghiệm thu.

## R26 — Benchmark data dùng exact-date synchronization

Implementation ưu tiên `Foreign(Benchmark,"C",0)` để giữ missing data là Null và tự kiểm tra.

Không silent fill-forward benchmark Close trong official RS channel.

Nếu benchmark bar đúng ngày không tồn tại:

`BenchmarkDataStatus = MISSING_SYNC_BAR`

và pair đó insufficient ở bar đó.

## R27 — Benchmark existence/validity

Pair chỉ valid khi:

- benchmark symbol được cấu hình;
- data tồn tại;
- Close stock finite > 0;
- Close benchmark finite > 0;
- synchronized bar hợp lệ.

Không chia cho zero/Null; không Nz() benchmark price về 0 hoặc previous value.

## R28 — Corporate action/data adjustment basis

Stock và benchmark phải dùng compatible price-adjustment basis.

V0.1 không tự suy đoán split/dividend adjustment regime từ vendor.

Implementation phải export một `AdjustmentBasisDeclaration`/status từ deployment config hoặc ghi `NOT VERIFIED` nếu chưa có metadata.

Không gọi RS valid-production nếu benchmark basis không được xác nhận trong acceptance profile.

## R29 — Benchmark provenance

Output tối thiểu phải có:

- current symbol;
- MarketBenchmarkSymbol;
- GroupBenchmarkSymbol nếu có;
- benchmark data status;
- source DateTime;
- native interval;
- ratio valid flags;
- pivot configuration;
- schema/version.

## R30 — Không benchmark volume trong RS identity

RS Context v0.1 là price comparative-strength layer.

Không so Volume stock/index như một phần của RSRatio identity.

VSA volume/spread/effort/result tiếp tục đến từ upstream VSA modules.

## R31 — Forming bar provisional

Current final database bar phải được xem là provisional khi runtime context cho biết nó đang hình thành.

Relative Strength current descriptor có thể cập nhật provisional, nhưng không được backfill confirmed RS pivot trước khi right-side confirmation hoàn tất.

## R32 — Source revision khác repaint

Nếu vendor sửa stock/benchmark historical data, ratio/pivot lịch sử có thể thay đổi ở lần chạy mới.

Audit phải phân biệt:

- source revision;
- algorithmic look-ahead/repaint.

## R33 — Public interface prefix

Prefix đề xuất: `WRS_`.

Các nhóm field lõi:

- `WRS_ContextValid`;
- benchmark identities/status;
- Stock-vs-Market Ratio/Structure/Pivots;
- Stock-vs-Group Ratio/Structure/Pivots;
- Group-vs-Market Ratio/Structure/Pivots;
- PriceStructureCode;
- PriceRSRelationshipCode;
- LeadershipChainCode;
- PhaseRSAlignmentCode;
- VSARSAlignmentCode;
- RSMTFRelationshipCode;
- provisional/source revision diagnostics.

## R34 — Exploration-first

V0.1 phải có Exploration trước chart/scanner integration.

Cột tối thiểu:

### Data health
- symbol;
- market/group benchmark;
- native interval;
- benchmark status;
- adjustment basis status;
- current/provisional status.

### Pairwise RS
- ratio valid/value;
- latest/prior confirmed RS highs/lows;
- extreme + confirm coordinates;
- RS Structure Code;
- completed RS wave descriptor.

### Context
- Price Structure Code;
- Price/RS Relationship;
- Leadership Chain;
- Phase/RS;
- VSA/RS;
- MTF/RS relationship.

## R35 — Cổng kiến trúc bắt buộc: Derived-Series Pivot Kernel

Trước khi viết full Relative Strength Context AFL, phải xác nhận cách áp dụng **chính xác cùng pivot semantics** của Structure/Location lên derived ratio series.

Chấp nhận một trong hai cách:

1. trích/refactor một generic causal pivot kernel dùng được cho arbitrary numeric series; hoặc
2. tạo một `RelativeStrength_StructureFacade` nhỏ nhưng phải chứng minh static equivalence với thuật toán pivot hiện có.

Không được:

- dùng Zig/Peak/Trough;
- dùng future offset;
- tạo pivot left/right semantics mới;
- copy rồi sửa ngầm thuật toán đến mức khác Structure v1.0.

**R35 là prerequisite bắt buộc trước full RS Engine implementation.**

## R36 — Không trading/ranking logic

Relative Strength Context v0.1 không có:

- Buy/Sell/Short/Cover;
- PositionSize;
- stop/target;
- probability/confidence;
- percentile;
- universe rank;
- “Top 10 stocks”.

Những chức năng lọc/ranking thuộc Market Scanner sau khi RS Context được khóa.

---

## 3. Phản ví dụ bắt buộc

1. Stock tăng 3% nhưng market tăng 5% → ratio giảm; không gọi stock mạnh tương đối chỉ vì giá stock tăng.
2. Stock giảm 1% trong khi market giảm 4% → ratio tăng; đây có thể là relative resilience dù giá stock giảm.
3. Raw ratio của A = 0.5 và B = 2.0 → không suy B mạnh hơn A chỉ vì ratio level cao hơn.
4. Một bar ratio tăng không đủ để gọi `RISING RS STRUCTURE` nếu chưa có HH+HL confirmed pivots.
5. Ratio extreme tại k chỉ confirmed ở k+B → không backfill KnownAt về k.
6. Price bullish structure + RS falling → structural non-confirmation, không tự gọi reversal.
7. Stock>Group rising nhưng Group>Market falling → `STOCK LEADS WEAK GROUP`, không gọi nested leadership.
8. Group missing → không dùng Market làm Group fallback.
9. Market benchmark missing bar đúng ngày → pair insufficient; không fill-forward official context.
10. Benchmark ticker sai nhưng GetBaseIndex trả ticker khác → không silent substitute.
11. Stock-vs-Market rising nhưng VSA bearish evidence → conflict, không xóa bearish evidence.
12. MTF bearish nhưng Daily RS rising → conflict, không sửa MTF state.
13. Relative Strength ratio rising trong Phase B → có thể là early clue, nhưng không tự đổi Phase thành C/D.
14. Price/RS both falling → “in gear down” context, không tự phát Short.
15. Corporate-action basis stock adjusted nhưng benchmark unadjusted/unknown → acceptance profile không được gọi fully verified.
16. Vendor sửa lịch sử benchmark → ratio history đổi nhưng phải phân biệt source revision với repaint.
17. `RelStrength()` default fixup che hole benchmark → official audit path phải phát hiện bằng explicit benchmark-valid channel.
18. RSI(14) tăng → không có nghĩa WRS Relative Strength tăng; hai khái niệm khác nhau.
19. Group>Market rising + Stock>Group rising nhưng Stock-vs-Market raw channel invalid → không suy stock-vs-market valid bằng logic bắc cầu.
20. Scanner chưa tồn tại → Relative Strength Context không tự rank universe.

---

## 4. Bảng quyết định cần chủ dự án phê duyệt

| Mã | Đề xuất | Khuyến nghị |
|---|---|---|
| R01 | Native EOD, official Daily integration v0.1 | Chấp thuận mạnh |
| R02 | Market bắt buộc + Group tùy chọn | Chấp thuận rất mạnh |
| R03 | Market benchmark explicit | Chấp thuận rất mạnh |
| R04 | Group missing không fallback | Chấp thuận rất mạnh |
| R05 | Không auto-map benchmark không kiểm chứng | Chấp thuận mạnh |
| R06 | RSRatio = Close/BenchmarkClose | Chấp thuận rất mạnh |
| R07 | Raw ratio không phải score | Chấp thuận rất mạnh |
| R08 | Không fixed-return window làm identity | Chấp thuận mạnh |
| R09 | Confirmed causal RS pivots | Chấp thuận rất mạnh |
| R10 | Cùng pivot config với Structure v1.0 | Chấp thuận rất mạnh |
| R11 | RS structure HH+HL / LH+LL / mixed | Chấp thuận rất mạnh |
| R12 | KnownAt = confirm bar | Chấp thuận rất mạnh |
| R13 | Comparative wave descriptors | Chấp thuận mạnh |
| R14 | So Price structure với RS structure | Chấp thuận rất mạnh |
| R15 | Price/RS Relationship categorical | Chấp thuận mạnh |
| R16 | Chưa gọi DNC/UNC nếu chưa matching-swing | Chấp thuận rất mạnh |
| R17 | Stock-vs-Market là channel chính | Chấp thuận rất mạnh |
| R18 | Stock-vs-Group độc lập | Chấp thuận rất mạnh |
| R19 | Group-vs-Market riêng | Chấp thuận mạnh |
| R20 | Leadership Chain categorical | Chấp thuận mạnh |
| R21 | Không suy Stock-vs-Market bằng bắc cầu | Chấp thuận rất mạnh |
| R22 | Phase/RS diagnostic | Chấp thuận rất mạnh |
| R23 | VSA/RS diagnostic | Chấp thuận rất mạnh |
| R24 | MTF/RS diagnostic, không override | Chấp thuận rất mạnh |
| R25 | Không internal MTF RS v0.1 | Chấp thuận mạnh |
| R26 | Foreign(...,0), explicit missingness | Chấp thuận rất mạnh |
| R27 | Strict benchmark validity | Chấp thuận rất mạnh |
| R28 | Adjustment-basis declaration | Chấp thuận mạnh |
| R29 | Benchmark provenance | Chấp thuận rất mạnh |
| R30 | Không benchmark volume trong RS identity | Chấp thuận rất mạnh |
| R31 | Forming bar provisional | Chấp thuận rất mạnh |
| R32 | Source revision != repaint | Chấp thuận rất mạnh |
| R33 | Prefix WRS_ | Chấp thuận |
| R34 | Exploration-first | Chấp thuận rất mạnh |
| R35 | Derived-Series Pivot Kernel prerequisite | Chấp thuận rất mạnh |
| R36 | Không trading/ranking logic | Chấp thuận rất mạnh |

---

## 5. Kết luận dự thảo

Relative Strength v0.1 nên giữ đúng tinh thần Wyckoff: **so sánh sức mạnh của các wave/swing và sử dụng ratio để quan sát leadership/lagging**, không biến Relative Strength thành RSI, momentum score hay hệ xếp hạng tùy ý.

Thiết kế cốt lõi:

`EXPLICIT BENCHMARK → SYNCHRONIZED VALID CLOSES → RS RATIO → SAME CAUSAL PIVOT SEMANTICS → RS STRUCTURE → PRICE/PHASE/VSA/MTF RELATIONSHIP → SCANNER CONSUMER`

R35 là cổng kiến trúc quan trọng nhất: trước full AFL Relative Strength phải tái sử dụng/đảm bảo tương đương thuật toán pivot đã khóa, để dự án không xuất hiện hai định nghĩa “confirmed pivot” khác nhau.