# Wyckoff VSA Cross-Symbol Selection Context Snapshot — Dự thảo đặc tả v0.1

**Trạng thái:** `DRAFT FOR OWNER APPROVAL` — chỉ đặc tả, chưa có AFL triển khai, chưa phải tiêu chí nghiệm thu native.

## 1. Vai trò kiến trúc

Tài liệu này thực hiện cổng bắt buộc **MS40** của `Market Scanner v0.1`, đã được chủ dự án phê duyệt tại PR #36 và merge vào `main` tại `b70cae9c8714cbb2b17082d155e57b50110aa13f`.

Chuỗi mục tiêu:

`Canonical Composite + MTF của Market/Group @ chính symbol đó`
`→ Cross-Symbol Selection Context Publisher`
`→ persistent scalar snapshot`
`→ Cross-Symbol Consumer trong stock Scanner`
`→ Market Scanner`

Mục tiêu của lớp này là truyền **current completed selection context của một symbol tham chiếu** (broad market hoặc group/sector benchmark) sang công thức Scanner đang chạy trên một cổ phiếu khác mà:

1. không chạy lại full Phase/Composite/MTF của benchmark bên trong từng cổ phiếu;
2. không dùng `SetForeign()` để biến từng stock thread thành một engine benchmark thứ hai;
3. không duplicate logic Market/Group selection trong transport layer;
4. giữ source symbol, ngày nguồn, schema, version, generation và trạng thái hoàn tất có thể kiểm toán;
5. fail closed khi snapshot thiếu, stale, future, provisional, sai symbol hoặc đang được ghi dở;
6. cho phép nhiều stock-reader threads đọc cùng một benchmark snapshot mà không có hidden order dependency.

Snapshot là **transport contract**, không phải Market/Group interpretation engine. `MarketSelectionContextCode` và `GroupSelectionContextCode` vẫn do Market Scanner tạo theo MS13–MS22.

---

## 2. Cơ sở nghiên cứu

### 2.1. Cơ sở phương pháp từ Market Scanner

Market Scanner v0.1 đã khóa các nguyên tắc:

- Wyckoff selection đi theo top-down context: Market → Group → Stock;
- Stock-vs-Market Relative Strength không thay thế own Phase/Composite/MTF của Market;
- Group-vs-Market RS không thay thế own Phase/Composite/MTF của Group;
- Scanner phải consume public upstream contracts, không copy analysis logic;
- candidate filter khác ranking;
- current event không tự tạo candidate;
- MS40 bắt buộc có cross-symbol snapshot trước full Scanner AFL.

### 2.2. AmiBroker StaticVar phù hợp với cross-symbol current-state transport

Tài liệu chính thức AmiBroker cho biết `StaticVarSet` / `StaticVarGet` cho phép chia sẻ giá trị giữa các formula. Persistent static variables có thể sống qua application restart khi `persist=True`.

Đối với current-state transport, scalar static variables phù hợp hơn arrays vì không có vấn đề timestamp padding/compression của static arrays.

### 2.3. Multi-threading: một writer / nhiều reader là mô hình ưu tiên

AmiBroker hướng dẫn rằng single static read/write call là thread-safe/atomic, nhưng một bundle gồm nhiều static variables **không tự động là một transaction nguyên tử**. Tài liệu khuyến nghị mô hình một writer / nhiều readers; nếu cần bảo vệ bundle shared writes thì có thể dùng `StaticVarCompareExchange` làm semaphore/critical section.

Điều này đặc biệt quan trọng với Scanner: hàng trăm stock threads có thể đồng thời đọc một Market snapshot. Readers phải không cần lock; writer phải có transaction protocol và writer-lock riêng cho source namespace.

### 2.4. Không dùng hidden SetForeign analysis trong Scanner

`SetForeign()` thay toàn bộ OHLCV arrays của formula bằng foreign security và phải `RestorePriceArrays()` sau đó. Nó hữu ích cho indicator đơn giản, nhưng nếu Scanner chạy full Phase/Composite/MTF của Market/Group bên trong mỗi stock formula sẽ:

- duplicate expensive engine work theo từng stock;
- tạo hidden state dependency;
- làm khó provenance và testing;
- làm tăng global-lock/cross-symbol access cost trong multi-threaded Analysis.

Contract v0.1 vì vậy chỉ cho Scanner **đọc snapshot**, không chạy benchmark engine ngầm.

### 2.5. Hai giai đoạn vận hành phải tách nhau

AmiBroker New Analysis chạy multi-threaded. Không được giả định “symbol đầu tiên của stock scan” là Market benchmark rồi publish từ đó.

V0.1 tách rõ:

1. **Publisher stage:** chạy dedicated publisher trên Market/Group benchmark symbols;
2. **Scanner stage:** sau khi publisher hoàn tất, stock scan chỉ đọc snapshot.

Scanner không vừa publish vừa consume trong cùng multi-symbol pass.

---

# QUYẾT ĐỊNH THIẾT KẾ XS01–XS38

## XS01 — Scope v0.1

Cross-Symbol Snapshot v0.1 phục vụ:

- current-state only;
- native Daily source context;
- một Market benchmark bắt buộc;
- tối đa một Group benchmark explicit cho mỗi Scanner run/profile;
- Market Scanner Daily EOD.

Không historical cross-symbol replay, không intraday, không universe ranking.

## XS02 — Publisher là role-neutral

Publisher serialize context của **source symbol** mà không tự gán symbol đó là `MARKET` hay `GROUP`.

Role được Consumer/Scanner gán từ deployment config:

- RequestedMarketSymbol;
- RequestedGroupSymbol.

Một snapshot format dùng chung cho cả Market và Group, tránh hai schema gần giống nhau.

## XS03 — Không auto-map Group trong v0.1

Group benchmark phải explicit theo Scanner run/profile.

V0.1 không tự ánh xạ mỗi stock sang sector index khác nhau bằng hidden category logic.

Muốn scan nhiều group với benchmark khác nhau:

- chạy các Scanner profile riêng theo group; hoặc
- xây Group-Routing Registry ở version sau.

Không silent fallback từ Group sang Market.

## XS04 — Canonical producer source

Publisher chỉ serialize **public current-state outputs** của:

- Composite Indicator v0.1;
- Multi-Timeframe Context v0.1;

trên chính source symbol.

Publisher không tái tính Event/Phase/Composite/MTF bằng công thức riêng.

## XS05 — Native Daily gate

Publisher official v0.1 chỉ hợp lệ khi chạy ở `inDaily`.

Nếu interval khác:

`PublisherStatus = INVALID_INTERVAL`

và không commit snapshot.

## XS06 — Full upstream readiness gate

Trước publication, source symbol phải có:

- Composite public interface đọc được;
- MTF contract valid theo upstream;
- Weekly snapshot valid;
- Monthly snapshot valid;
- source Daily context không provisional;
- required fields không Null/invalid theo schema.

Thiếu một required upstream state thì không commit official snapshot mới.

## XS07 — Daily completion là vấn đề vận hành, không được giả vờ tự biết

AmiBroker không tự bảo đảm rằng latest Daily database bar đã đóng ở mọi market/datafeed.

V0.1 vì vậy không suy `completed` chỉ từ `LastValue()` hoặc việc bar là bar cuối.

Publisher phải có explicit `DailyCompletionDeclaration`.

## XS08 — Hai CompletionBasis được phép

V0.1 cho phép:

- 1 = `CALENDAR DAY ROLLED OVER` — source business date nhỏ hơn local calendar date;
- 2 = `OPERATOR EOD COMPLETION DECLARATION` — publication same-day chỉ khi dedicated EOD run profile explicitly xác nhận phiên đã đóng.

Không có silent same-day completion.

## XS09 — Same-day publisher mặc định fail closed

Nếu source bar thuộc current local calendar date và `DailyCompletionDeclaration != COMPLETED`:

`PublisherStatus = SOURCE_COMPLETION_NOT_DECLARED`

và snapshot cũ không bị ghi đè.

Mặc định parameter/config phải là **không cho phép same-day publication**.

## XS10 — Completion declaration là provenance, không market evidence

Completion declaration chỉ nói publisher được phép coi source Daily bar là hoàn tất về vận hành.

Nó không làm:

- Phase bullish/bearish;
- event confirmed;
- candidate qualified.

Snapshot phải export `CompletionBasisCode` và `CompletionDeclarationCode`.

## XS11 — BusinessDateKey

Mỗi snapshot phải có một key ngày nguồn đơn giản, monotonic theo ngày lịch, ví dụ `YYYYMMDD` hoặc ordinal day tương đương.

Dùng key này cho same-session equality checks.

Encoded DateTime vẫn được giữ cho provenance, nhưng ordering nếu cần phải dùng `DateTimeDiff`, không dùng raw numeric `>`/`<` trên encoded DateTime.

## XS12 — Source bar selection

Publisher current-state v0.1 chọn **latest source Daily bar** chỉ khi bar đó thỏa:

- Composite valid;
- MTF valid;
- completion gate XS07–XS10;
- required payload valid.

Không tự lùi về bar trước để che lỗi current source. Nếu latest source không đủ điều kiện, publication fail closed.

## XS13 — Snapshot namespace

Đề xuất:

`WVSA_SELCTX_v01_<SourceSymbol>_<Field>`

Publisher và Consumer phải dùng chính xác cùng namespace construction.

Source symbol string phải đồng nhất tuyệt đối với AmiBroker symbol identity; không normalize sang benchmark khác.

## XS14 — Schema/version fields

Snapshot phải có ít nhất:

- `SchemaMajor`;
- `SchemaMinor`;
- `ProducerContractVersion`;
- `ProducerCompositeVersion`;
- `ProducerMTFVersion`;
- `SourceSymbol`;
- `SourceInterval`.

Consumer fail closed khi version không nằm trong compatibility contract explicit.

## XS15 — Provenance bắt buộc

Snapshot phải mang:

- SourceSymbol;
- SourceBusinessDateKey;
- SourceBarDateTime;
- PublishedAtDateTime;
- CompletionBasisCode;
- CompletionDeclarationCode;
- GenerationID;
- Composite schema/version;
- MTF schema/version;
- publisher contract version.

## XS16 — Persistent scalar only

Transport fields của Cross-Symbol Snapshot là:

- scalar numeric StaticVars;
- scalar text StaticVars.

Không dùng static arrays trong v0.1.

Persistent=True được phép để snapshot sống qua restart, nhưng persistence không thay thế freshness validation.

## XS17 — Publisher/Scanner pipeline tách hai Analysis jobs

Official workflow:

1. cập nhật Weekly/Monthly Timeframe snapshots cho benchmark symbols khi cần;
2. chạy Cross-Symbol Publisher trên Market và Group benchmark symbol(s) ở Daily;
3. xác nhận publication valid;
4. chạy Market Scanner trên stock universe.

Scanner job không publish snapshot benchmark.

## XS18 — Không dùng Status("stocknum")==0 để chọn Market benchmark trong Scanner

`Status("stocknum")==0` không được dùng như hidden assumption “symbol đầu tiên là Market”.

Lý do:

- Apply To universe/order có thể thay đổi;
- first stock không phải benchmark;
- tạo order dependency khó kiểm toán.

Benchmark publisher phải là dedicated stage.

## XS19 — Writer lock theo source namespace

Mỗi SourceSymbol namespace có non-persistent writer semaphore riêng.

Publisher phải thử lấy lock bằng atomic mechanism tương đương `StaticVarCompareExchange`.

Nếu lock đang bận:

`PublisherStatus = WRITER_BUSY`

và không chen ghi bundle.

## XS20 — One-writer / many-readers

Trong official operation:

- tối đa một writer cho một SourceSymbol namespace tại một thời điểm;
- nhiều Scanner reader threads được đọc cùng snapshot đồng thời;
- readers không giữ writer lock.

Đây là mô hình concurrency chuẩn v0.1.

## XS21 — Transaction-like commit protocol

Sau khi có writer lock:

1. xác định `NewGenerationID`;
2. `Ready = 0`;
3. ghi payload;
4. ghi schema + provenance;
5. ghi `CommittedGenerationID = NewGenerationID`;
6. `Ready = 1` cuối cùng;
7. release writer lock.

Nếu publication thất bại giữa chừng, Ready không được để ở trạng thái 1 cho payload mới chưa hoàn tất.

## XS22 — Double-read generation guard ở Consumer

Consumer:

1. đọc `Ready_A`, `Generation_A`;
2. đọc payload;
3. đọc `Generation_B`, `Ready_B`;
4. accept chỉ khi Ready A/B = 1 và Generation A = B > 0.

Nếu không:

`ConsumerStatus = WRITE_IN_PROGRESS_OR_UNSTABLE`.

## XS23 — Không dùng GenerationID làm freshness signal

GenerationID chỉ là transaction token.

Freshness official dùng:

- SourceBusinessDateKey;
- SourceBarDateTime;
- publication provenance;
- embedded MTF validity.

## XS24 — Composite payload tối thiểu

Snapshot phải serialize tối thiểu:

- ContextMultiplicityCode;
- ContextAmbiguous;
- CurrentRangeContextID;
- RangeStatusCode;
- PhaseStateCode;
- StructuralDevelopmentCode;
- FamilyHypothesisCode;
- DirectionalContextCode;
- EvidenceBalanceCode;
- HypothesisAlignmentCode;
- HypothesisRevisionCode;
- CurrentEventMask;
- ProvisionalFlag.

Transport không đổi enum semantics.

## XS25 — Multiple-context diagnostics phải giữ

Snapshot phải giữ riêng lower/upper context tối thiểu:

- ContextPresent;
- RangeContextID;
- RangeStatusCode;
- PhaseStateCode;
- FamilyHypothesisCode;
- EvidenceBalanceCode;
- MixedEvidenceReasonCode;
- PrimaryRangeLow/High;
- RangeAgeBars.

Consumer không chọn winner khi source symbol có multiple range contexts.

## XS26 — MTF payload tối thiểu

Snapshot phải serialize:

- MTF SnapshotContractValid;
- Daily/Weekly/Monthly valid status;
- Daily/Weekly/Monthly DirectionalContextCode;
- Daily/Weekly/Monthly PhaseStateCode;
- Daily/Weekly/Monthly FamilyHypothesisCode;
- Daily/Weekly/Monthly EvidenceBalanceCode;
- DirectionalAlignmentCode;
- EvidenceAlignmentCode;
- PhaseRelationshipCode;
- ConflictReasonCode;
- WeeklySnapshotStatusCode;
- MonthlySnapshotStatusCode.

Không collapse MTF thành một bullish/bearish bit duy nhất.

## XS27 — MTF constituent provenance

Để scanner audit được source context, snapshot phải mang nếu upstream có:

- Weekly SourcePeriodOrdinal / generation;
- Monthly SourcePeriodOrdinal / generation;
- Daily source DateTime/business date;
- MTF schema/version.

Nếu field chưa có public interface ở implementation hiện hành, implementation của contract phải bổ sung **projection facade**, không tái tính logic MTF.

## XS28 — Market/Group selection code không nằm trong snapshot

Snapshot không tạo:

- `MarketSelectionContextCode`;
- `GroupSelectionContextCode`;
- candidate side;
- qualification state.

Các code đó thuộc Scanner MS13–MS23.

Cross-Symbol Snapshot chỉ truyền raw canonical context.

## XS29 — Consumer role wrappers

Consumer có thể có hai wrapper:

- MarketSelectionSnapshotConsumer(ExpectedMarketSymbol);
- GroupSelectionSnapshotConsumer(ExpectedGroupSymbol).

Hai wrapper dùng cùng contract và chỉ khác requested role/config.

Group không cấu hình phải trả `NOT_REQUESTED`, không phải `MISSING`.

## XS30 — Consumer status enum

Đề xuất:

- 0 `NOT READ / INSUFFICIENT`;
- 1 `VALID`;
- 2 `NOT REQUESTED`;
- 3 `MISSING`;
- 4 `WRITER BUSY / WRITE IN PROGRESS / UNSTABLE GENERATION`;
- 5 `SCHEMA VERSION MISMATCH`;
- 6 `SYMBOL MISMATCH`;
- 7 `INTERVAL MISMATCH`;
- 8 `STALE BUSINESS DATE`;
- 9 `FUTURE BUSINESS DATE`;
- 10 `PROVISIONAL SOURCE`;
- 11 `INVALID COMPLETION PROVENANCE`;
- 12 `INVALID COMPOSITE PAYLOAD`;
- 13 `INVALID MTF PAYLOAD`;
- 14 `INVALID SOURCE DATETIME`.

Không collapse mọi lỗi thành Null.

## XS31 — Scanner business-date equality gate

Official Market Scanner candidate chỉ dùng Market snapshot khi:

`MarketSnapshot.SourceBusinessDateKey == StockCurrentCompletedBusinessDateKey`.

Nếu Market snapshot cũ hơn → `STALE BUSINESS DATE`.

Nếu Market snapshot mới hơn stock source → stock context không đồng bộ và candidate phải `DATA_GATED`; không dùng future market context cho stock bar cũ.

## XS32 — Group business-date equality gate

Nếu Group profile được yêu cầu, Group snapshot cũng phải có SourceBusinessDateKey bằng stock current completed business date.

Group stale/future không được dùng cho Full Top-Down qualification.

Market-Aligned profile vẫn có thể tồn tại nếu Market valid và Group chỉ là optional profile, đúng MS08/MS09.

## XS33 — Source symbol exact-match gate

Consumer phải kiểm tra snapshot `SourceSymbol` chính xác bằng requested benchmark symbol.

Không chấp nhận snapshot khác symbol dù namespace bị cấu hình sai.

Market và Group requested symbols trùng nhau phải được đánh dấu deployment configuration conflict cho Full Top-Down profile; không giả định một symbol đóng hai vai trò trong v0.1.

## XS34 — Embedded MTF fail-closed

Snapshot chỉ được `VALID` cho Scanner full-MTF profile nếu embedded MTF contract valid.

Weekly/Monthly missing, stale, future, version mismatch hoặc provisional phải làm snapshot unusable cho official qualified candidate.

Không dùng Daily-only market/group state rồi gọi là full MTF context.

## XS35 — Persistence không làm snapshot “sống mãi”

Sau restart, persistent snapshot có thể vẫn tồn tại.

Consumer luôn kiểm tra business date, source symbol, version, completion provenance và MTF validity trước khi accept.

Snapshot hôm qua tồn tại trong memory hôm nay vẫn là stale.

## XS36 — Publisher không tự thay đổi watchlist/universe

Publisher chỉ serialize source symbols mà Analysis job cung cấp.

Không tự thêm/xóa symbol khỏi watchlist và không tự xây Group registry.

## XS37 — Exploration-first audit surfaces

Publisher Exploration tối thiểu phải hiển thị:

- SourceSymbol;
- native interval;
- SourceBusinessDateKey;
- SourceBarDateTime;
- completion declaration/basis;
- Composite valid;
- MTF valid;
- generation trước/sau;
- writer-lock result;
- Ready;
- PublisherStatus.

Consumer Exploration tối thiểu phải hiển thị:

- RequestedRole;
- RequestedSymbol;
- SnapshotSourceSymbol;
- schema/version;
- SourceBusinessDateKey;
- ConsumerBusinessDateKey;
- generation A/B;
- Ready A/B;
- Composite/MTF validity;
- ConsumerStatus.

## XS38 — Non-goals và acceptance gate

Cross-Symbol Snapshot v0.1 không có:

- Buy/Sell/Short/Cover;
- candidate score/rank;
- probability/confidence;
- P&F target;
- liquidity rule;
- Group auto-routing;
- historical cross-symbol backfill;
- hidden benchmark engine execution trong Scanner.

Sau khi đặc tả XS01–XS38 được khóa, implementation phải hoàn thành source/static audit nhưng **MS40 chỉ được coi là native-accepted sau AmiBroker 6.20.01 tests**.

---

## 4. Phản ví dụ bắt buộc

1. Scanner chạy 500 cổ phiếu cùng lúc, tất cả cùng đọc một Market snapshot → không cần 500 lần chạy lại Market Phase Engine.
2. Market snapshot hôm qua vẫn persistent khi scan hôm nay → stale, không valid.
3. Market snapshot ngày hôm nay nhưng stock bị đình chỉ và latest stock bar là hôm qua → stock bị data-gated; không áp context hôm nay lên bar hôm qua.
4. Group không cấu hình → `NOT_REQUESTED`, không làm Market-Aligned profile invalid.
5. Group được cấu hình nhưng snapshot thiếu → Full Top-Down unavailable; không fallback Market làm Group.
6. Group snapshot stale nhưng Market valid → Market-Aligned có thể còn, Full Top-Down không đạt.
7. Market snapshot đang được publisher ghi, Generation thay đổi giữa hai lần đọc → reject lượt đọc.
8. Hai publisher cùng cố ghi cùng Market namespace → chỉ writer lấy được lock được phép ghi.
9. Publisher crash/reject trước Ready=1 → consumer không chấp nhận payload mới dở dang.
10. Snapshot schema major cũ → reject dù ngày nguồn đúng.
11. Snapshot SourceSymbol khác requested symbol → reject dù namespace/key trỏ nhầm.
12. Market Composite bullish nhưng Market MTF invalid → không được gọi Market supportive official.
13. Market MTF mixed/conflicting → snapshot vẫn transport hợp lệ nếu payload valid; Scanner mới quyết định review/method block.
14. Source symbol có multiple range contexts → snapshot giữ lower/upper; không chọn một range thắng.
15. Same-day publisher chạy trước phiên đóng nhưng operator declaration mặc định No → không publish.
16. Same-day publisher chạy sau phiên đóng và operator EOD declaration được bật đúng profile → được phép xét publication; declaration được lưu provenance.
17. Ngày đã rollover, source là ngày trước và all payload valid → có thể dùng CompletionBasis `CALENDAR DAY ROLLED OVER`.
18. `GenerationID` lớn hơn không có nghĩa context “mới hơn về thị trường” nếu SourceBusinessDateKey không đổi.
19. Scanner dùng `SetForeign(Market)` rồi chạy lại Composite bên trong mỗi stock → vi phạm XS04/MS40 dù output trông giống.
20. `Status("stocknum")==0` được dùng để giả định first symbol là Market → vi phạm XS17/XS18.
21. Weekly source snapshot stale nhưng Cross-Symbol Publisher không kiểm tra embedded MTF validity → phải fail publication/acceptance.
22. Source revision cùng business date tạo generation mới → provenance thay đổi; không tự gọi algorithmic repaint.
23. Market và Group symbol cấu hình trùng nhau → Full Top-Down config conflict, không “đếm hai lần” cùng source.
24. Stock-vs-Market RS rising nhưng Market snapshot bearish/mixed → transport không sửa RS; Scanner giữ conflict theo MS26/MS27.

---

## 5. Native acceptance matrix dự kiến

### CSN01 — Verify Syntax

Tất cả Publisher/Consumer/Exploration AFL compile trên AmiBroker 6.20.01.

### CSN02 — Same-day completion default-deny

Không EOD declaration → không commit current-day source.

### CSN03 — Same-day declared EOD publication

Declaration hợp lệ + source payload valid → commit generation mới.

### CSN04 — Calendar rollover publication

Source date < local date → completion basis calendar rollover hoạt động đúng.

### CSN05 — Persistent restart

Restart AmiBroker giữ snapshot nhưng consumer vẫn freshness-check.

### CSN06 — Same-business-date reader

Stock current date = Market snapshot date → valid nếu các gate khác pass.

### CSN07 — Stale Market snapshot

Market source date < stock date → reject stale.

### CSN08 — Future-vs-stock snapshot

Market source date > stock current date → reject/data-gate stock.

### CSN09 — Group not requested

Không Group config → status NOT_REQUESTED, Market profile không bị block.

### CSN10 — Group missing/stale

Full Top-Down block, Market-Aligned không bị giả định invalid nếu các field Market/Stock đủ.

### CSN11 — Schema mismatch

Consumer fail closed.

### CSN12 — SourceSymbol mismatch

Consumer fail closed.

### CSN13 — Writer lock contention

Hai writers same namespace → không có interleaved bundle accepted.

### CSN14 — Double-read generation race

Generation thay đổi trong read → consumer reject lượt đó.

### CSN15 — Interrupted commit

Ready=0/incomplete payload → reject.

### CSN16 — Multiple reader concurrency

Nhiều stock Analysis threads đọc một Market snapshot ổn định và cho cùng source provenance.

### CSN17 — Embedded MTF invalid

Cross-symbol consumer/scanner không dùng snapshot official cho qualified state.

### CSN18 — Multiple RangeContext preservation

Lower/upper payload giữ nguyên, không singleton winner.

### CSN19 — Source revision

Cùng BusinessDateKey nhưng benchmark data/source state được sửa và publisher chạy lại → generation/provenance mới; audit tách source revision khỏi repaint.

### CSN20 — Performance

So scanner đọc snapshot với phương án reference chạy `Foreign/SetForeign` rộng; acceptance ưu tiên không làm benchmark full-engine work lặp theo stock.

---

## 6. Bảng quyết định cần chủ dự án phê duyệt

| Mã | Đề xuất | Khuyến nghị |
|---|---|---|
| XS01 | Current-state Daily, 1 Market + optional 1 Group/profile | Chấp thuận mạnh |
| XS02 | Publisher role-neutral | Chấp thuận rất mạnh |
| XS03 | Không auto-map Group v0.1 | Chấp thuận rất mạnh |
| XS04 | Serialize canonical Composite+MTF only | Chấp thuận bắt buộc |
| XS05 | Native Daily publisher | Chấp thuận rất mạnh |
| XS06 | Full upstream readiness | Chấp thuận bắt buộc |
| XS07 | Không giả định latest Daily bar completed | Chấp thuận bắt buộc |
| XS08 | Calendar-rollover hoặc explicit EOD declaration | Chấp thuận rất mạnh |
| XS09 | Same-day default-deny | Chấp thuận bắt buộc |
| XS10 | Completion declaration chỉ là provenance | Chấp thuận mạnh |
| XS11 | BusinessDateKey riêng | Chấp thuận rất mạnh |
| XS12 | Latest source invalid thì fail, không lùi bar | Chấp thuận rất mạnh |
| XS13 | Namespace theo SourceSymbol | Chấp thuận rất mạnh |
| XS14 | Schema/version explicit | Chấp thuận bắt buộc |
| XS15 | Full provenance | Chấp thuận rất mạnh |
| XS16 | Persistent scalar only | Chấp thuận rất mạnh |
| XS17 | Publisher stage và Scanner stage tách nhau | Chấp thuận bắt buộc |
| XS18 | Không dùng stocknum==0 làm hidden Market publisher | Chấp thuận bắt buộc |
| XS19 | Per-source writer lock | Chấp thuận rất mạnh |
| XS20 | One-writer/many-readers | Chấp thuận rất mạnh |
| XS21 | Ready-last transaction protocol | Chấp thuận bắt buộc |
| XS22 | Double-read generation guard | Chấp thuận bắt buộc |
| XS23 | Generation không phải freshness | Chấp thuận rất mạnh |
| XS24 | Composite payload | Chấp thuận rất mạnh |
| XS25 | Preserve multiple-context diagnostics | Chấp thuận bắt buộc |
| XS26 | Preserve full MTF diagnostics | Chấp thuận bắt buộc |
| XS27 | MTF constituent provenance | Chấp thuận mạnh |
| XS28 | Không tạo selection code trong transport | Chấp thuận bắt buộc |
| XS29 | Market/Group consumer wrappers cùng schema | Chấp thuận mạnh |
| XS30 | Consumer status chi tiết | Chấp thuận rất mạnh |
| XS31 | Market same-business-date gate | Chấp thuận bắt buộc |
| XS32 | Group same-business-date gate | Chấp thuận rất mạnh |
| XS33 | Exact symbol match + Market/Group conflict check | Chấp thuận rất mạnh |
| XS34 | Embedded MTF fail-closed | Chấp thuận bắt buộc |
| XS35 | Persistent vẫn freshness-check | Chấp thuận bắt buộc |
| XS36 | Không mutate universe/watchlist | Chấp thuận mạnh |
| XS37 | Exploration-first audit | Chấp thuận rất mạnh |
| XS38 | Non-goals + native gate | Chấp thuận bắt buộc |

---

## 7. Thứ tự sau khi phê duyệt

Nếu XS01–XS38 được chủ dự án phê duyệt:

1. khóa docs-only PR;
2. tạo implementation branch trên stack có Composite + MTF implementation;
3. triển khai role-neutral Publisher;
4. triển khai shared Consumer + Market/Group wrappers;
5. triển khai Publisher/Consumer Exploration;
6. static conformance audit;
7. giữ `UNTESTED DEVELOPMENT`;
8. sau đó mới triển khai full Market Scanner trên integration stack có MTF + RS + Cross-Symbol Snapshot;
9. native acceptance được gom vào chiến dịch kiểm thử tổng thể, nhưng MS40 không được gọi native PASS trước các test CSN01–CSN20.
