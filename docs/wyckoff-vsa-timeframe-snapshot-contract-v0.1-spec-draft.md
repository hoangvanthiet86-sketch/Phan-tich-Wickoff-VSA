# Wyckoff VSA Timeframe Snapshot Publisher / Consumer Contract — Dự thảo đặc tả v0.1

**Trạng thái:** `DRAFT FOR OWNER APPROVAL` — chưa khóa, chưa phải tiêu chí nghiệm thu, chưa có AFL implementation.

## 1. Vai trò kiến trúc

Tài liệu này thực hiện cổng kiến trúc **D34** của `Multi-Timeframe Context v0.1` đã được chủ dự án phê duyệt tại PR #28 và merge vào `main` tại `794f947761fcb2c9043fd6d30fb9dd1a48f8c2bc`.

Chuỗi mục tiêu:

`Canonical Composite @ Weekly/Monthly → Snapshot Publisher → Static scalar snapshot → Snapshot Consumer @ Daily → MTF Aggregator`

Mục tiêu là truyền **current authoritative state của khung Weekly và Monthly** sang khung Daily mà:

1. không chạy lại toàn bộ engine Weekly/Monthly bên trong Daily formula;
2. không duplicate logic Composite/Phase/Event;
3. không đưa dữ liệu higher timeframe chưa hoàn tất vào context chính thức;
4. không dùng future-sensitive expansion;
5. giữ version, period identity và provenance có thể kiểm toán;
6. fail closed khi snapshot thiếu, stale, sai version hoặc đang được ghi dở.

Contract này **không phải MTF Aggregator** và không tạo bullish/bearish alignment mới.

---

## 2. Cơ sở kỹ thuật AmiBroker đã nghiên cứu

### 2.1 Static variables

AmiBroker cho phép `StaticVarSet` / `StaticVarGet` chia sẻ state giữa các formula. Scalar static variables không có vấn đề timestamp alignment của static arrays khi đọc khác interval.

Persistent static variables có thể tồn tại qua lần đóng/mở AmiBroker bằng tham số `persist=True`; chức năng này đã có trước AmiBroker 6.20.

### 2.2 Vì sao v0.1 dùng scalar snapshot, không static array

AmiBroker cảnh báo static arrays khi đọc ở interval khác sẽ tự padding/synchronization theo timestamp và có giới hạn khác với `Foreign/AddToComposite`.

MTF v0.1 chỉ cần **current authoritative state**, không historical MTF backfill. Vì vậy contract chọn:

- scalar numeric fields qua `StaticVarSet`;
- scalar text/version fields qua `StaticVarSetText`;
- không dùng static arrays để truyền lịch sử Weekly/Monthly sang Daily.

Điều này giảm đáng kể nguy cơ alignment sai và memory footprint.

### 2.3 TimeFrame look-ahead

AmiBroker cảnh báo `TimeFrameExpand(..., expandFirst)` trên higher High/Low/Close có thể đưa dữ liệu cả tuần về đầu tuần; `TimeFrameGetPrice(..., shift=0)` cũng có thể nhìn vào higher bar chưa hoàn tất.

Do đó contract này không dùng higher price expansion để xác định official snapshot payload.

---

# QUYẾT ĐỊNH THIẾT KẾ S01–S32

## S01 — Scope v0.1

Publisher/Consumer chỉ phục vụ:

- cùng symbol;
- Weekly snapshot;
- Monthly snapshot;
- Daily consumer;
- current-state only.

Không hỗ trợ intraday, quarterly, yearly hoặc historical MTF replay trong v0.1.

## S02 — Canonical producer

Publisher chỉ được publish state được tạo bởi **canonical Composite Indicator v0.1 public interface** trên đúng native timeframe của nó.

Không được tái tính Phase/Event/Composite ngay trong Publisher.

Publisher là serialization layer, không phải analysis engine.

## S03 — Native timeframe gate

Weekly Publisher chỉ hợp lệ khi formula đang chạy ở native weekly interval.

Monthly Publisher chỉ hợp lệ khi formula đang chạy ở native monthly interval.

Nếu interval khác:

`PublisherStatus = INVALID_INTERVAL`

và không commit snapshot mới.

## S04 — Không publish forming higher bar

Higher bar hiện tại không được mặc định là completed chỉ vì nó là `LastValue`.

Publisher chỉ chọn bar thuộc **calendar period đã kết thúc chắc chắn** so với local system clock.

V0.1 không cố suy đoán giờ đóng cửa từng sàn/chứng khoán.

## S05 — Period ordinal chuẩn

Để tránh lỗi year-boundary của `YYYYWW`, dùng **monotonic period ordinal**.

### WeeklyPeriodOrdinal

Khái niệm:

1. lấy DateTime của bar;
2. quy về số ngày kể từ một epoch cố định;
3. tìm Monday của tuần chứa bar;
4. chia số ngày Monday-anchor cho 7.

Kết quả là một số nguyên tăng đều mỗi tuần, không reset khi sang năm.

### MonthlyPeriodOrdinal

`Year * 12 + Month`

hoặc biểu thức tương đương tạo ordinal tăng đều mỗi tháng.

Implementation phải có test year-end/month-end trước khi native acceptance.

## S06 — Expected completed period

Với local system clock hiện tại:

- expected Weekly ordinal = `CurrentCalendarWeekOrdinal - 1`;
- expected Monthly ordinal = `CurrentCalendarMonthOrdinal - 1`.

Publisher chỉ publish source bar có ordinal đúng bằng expected ordinal.

Như vậy:

- trong một tuần đang diễn ra, tuần hiện tại không được publish;
- tuần vừa kết thúc chỉ trở thành authoritative khi calendar sang tuần mới;
- tháng vừa kết thúc chỉ authoritative khi calendar sang tháng mới.

Đây là lựa chọn **safety-first**, chấp nhận chậm tới thời điểm calendar rollover thay vì đoán session close.

## S07 — Không manual completion override trong v0.1

V0.1 không có nút kiểu `TreatCurrentWeekAsClosed` hay `ForcePublishLastBar`.

Lý do: override thủ công có thể biến lỗi vận hành thành look-ahead khó kiểm toán.

Nếu sau này cần Friday-after-close publication, phải có đặc tả riêng về exchange calendar/session completion.

## S08 — Source bar selection

Publisher quét từ cuối data series lùi lại và chọn bar mới nhất có:

- valid Composite output;
- period ordinal == expected completed ordinal.

Không giả định source luôn là `BarCount-2`.

Nếu không tìm thấy đúng period:

`PublisherStatus = EXPECTED_PERIOD_NOT_FOUND`

và không commit snapshot.

## S09 — Snapshot namespace

Đề xuất namespace text:

`WVSA_MTF_v01_<SymbolKey>_<TFCode>_<Field>`

Trong đó:

- `TFCode = W` cho Weekly;
- `TFCode = M` cho Monthly.

`SymbolKey` phải là deterministic và cùng cách tạo ở Publisher/Consumer.

Không dùng key chỉ dựa timeframe vì sẽ collision giữa symbols.

## S10 — Schema version

Mỗi snapshot phải có ít nhất:

- `SchemaMajor`;
- `SchemaMinor`;
- `ProducerCompositeVersion`;
- `ProducerContractVersion`.

Consumer v0.1 fail closed nếu `SchemaMajor` khác expected.

`SchemaMinor` chỉ được chấp nhận nếu consumer explicitly hỗ trợ; không silent acceptance.

## S11 — Provenance fields bắt buộc

Snapshot phải mang:

- Symbol;
- TimeframeCode;
- SourcePeriodOrdinal;
- SourceBarDateTime;
- PublishedAtDateTime;
- SourceCompositeVersion;
- ContractVersion;
- GenerationID;
- CompletionBasisCode.

`CompletionBasisCode` v0.1 chỉ có:

- 1 = `CALENDAR PERIOD ROLLED OVER`.

Không có `MANUAL OVERRIDE` trong v0.1.

## S12 — Persistent scalar snapshots

Snapshot fields được ghi bằng persistent static variables (`persist=True`) để state có thể sống qua restart AmiBroker.

Tuy nhiên persistence **không biến snapshot thành hợp lệ**. Consumer vẫn phải kiểm tra period/version/provenance mỗi lần đọc.

Stale persistent snapshot phải bị reject.

## S13 — Không phụ thuộc StaticVar array alignment

Tất cả transport fields của snapshot là scalar number hoặc scalar text.

Không publish arrays trong contract v0.1.

Nếu historical MTF được thêm về sau, cần contract mới.

## S14 — Transaction-like commit protocol

Vì snapshot gồm nhiều StaticVarSet riêng lẻ, Publisher phải dùng commit protocol chống đọc payload dở dang.

Trình tự đề xuất:

1. xác định `NewGenerationID`;
2. đặt `Ready = 0`;
3. ghi payload;
4. ghi schema/provenance;
5. ghi `CommittedGenerationID = NewGenerationID`;
6. ghi `Ready = 1` **cuối cùng**.

Consumer không được chấp nhận snapshot khi `Ready != 1`.

## S15 — Double-read generation guard

Consumer phải:

1. đọc `Ready_A` + `Generation_A`;
2. đọc toàn bộ payload;
3. đọc lại `Generation_B` + `Ready_B`;
4. chỉ accept nếu:
   - `Ready_A == 1`;
   - `Ready_B == 1`;
   - `Generation_A == Generation_B`;
   - generation hợp lệ/nonzero.

Nếu publisher ghi chen giữa lúc consumer đọc, snapshot bị reject trong lượt đó thay vì dùng mixed payload.

## S16 — GenerationID không phải thời gian thị trường

GenerationID chỉ là transaction token, không được dùng làm market recency signal.

Nguồn thời gian thị trường vẫn là `SourcePeriodOrdinal` và `SourceBarDateTime`.

## S17 — Payload singleton core

Snapshot phải truyền các Composite singleton fields khi context multiplicity cho phép:

- `ContextMultiplicityCode`;
- `ContextAmbiguous`;
- `CurrentRangeContextID`;
- `RangeStatusCode`;
- `PrimaryRangeLow`;
- `PrimaryRangeHigh`;
- `PrimaryRangeWidth`;
- `RangeAgeBars`;
- `PhaseStateCode`;
- `StructuralDevelopmentCode`;
- `FamilyHypothesisCode`;
- `DirectionalContextCode`;
- `EvidenceBalanceCode`;
- `HypothesisAlignmentCode`;
- `HypothesisRevisionCode`;
- `CurrentEventMask`;
- `ProvisionalFlag`.

Publisher không sửa enum semantics.

## S18 — Payload multiple-context diagnostics

Để giữ D04/D30 của Composite, snapshot phải mang riêng lower/upper channel tối thiểu:

- RangeContextID;
- RangeStatusCode;
- PhaseStateCode;
- FamilyHypothesisCode;
- Evidence state;
- MixedEvidenceReasonCode;
- PrimaryRangeLow/High;
- RangeAgeBars.

Khi multiple contexts, Consumer không được tự tạo singleton winner.

## S19 — Event provenance giữ theo timeframe

`WeeklyEventMask` và `MonthlyEventMask` là state của chính timeframe đó.

Consumer không OR chúng vào Daily `CurrentEventMask`.

MTF Aggregator sau này chỉ được trình bày chúng như separate timeframe evidence.

## S20 — Snapshot validity status enum

Consumer đề xuất:

- 0 = `NOT READ / INSUFFICIENT`;
- 1 = `VALID`;
- 2 = `MISSING`;
- 3 = `WRITE IN PROGRESS / UNSTABLE GENERATION`;
- 4 = `SCHEMA VERSION MISMATCH`;
- 5 = `SYMBOL MISMATCH`;
- 6 = `TIMEFRAME MISMATCH`;
- 7 = `STALE PERIOD`;
- 8 = `FUTURE PERIOD`;
- 9 = `PROVISIONAL SOURCE`;
- 10 = `INVALID PAYLOAD`.

Không collapse tất cả lỗi thành một Null duy nhất; phải audit được lý do fail closed.

## S21 — Freshness là period identity, không age-days

Consumer Weekly chỉ accept khi:

`Snapshot.SourcePeriodOrdinal == CurrentCalendarWeekOrdinal - 1`

Consumer Monthly chỉ accept khi:

`Snapshot.SourcePeriodOrdinal == CurrentCalendarMonthOrdinal - 1`

Không dùng `DaysSincePublish <= 7/31` làm điều kiện chính.

## S22 — Future snapshot hard reject

Nếu `SourcePeriodOrdinal >= CurrentPeriodOrdinal`, Consumer phải reject với `FUTURE PERIOD`.

Không có tolerance/epsilon.

## S23 — Missing/stale không fallback

Nếu Monthly snapshot stale/missing:

- không copy Weekly state vào Monthly;
- không gọi Weekly-only alignment là 3-timeframe alignment.

Nếu Weekly snapshot stale/missing:

- không copy Daily vào Weekly.

MTF Aggregator phải nhận validity riêng của từng timeframe.

## S24 — ProvisionalFlag hard gate

Higher snapshot official phải có `ProvisionalFlag = 0`.

Nếu payload nói provisional:

`ConsumerStatus = PROVISIONAL SOURCE`

và không dùng cho authoritative alignment.

## S25 — Source DateTime handling

AmiBroker encoded DateTime không được so sánh thứ tự bằng `>` / `<` như số thông thường.

Nếu cần so sánh thời gian publication/source, implementation phải dùng `DateTimeDiff` hoặc period ordinals.

Equality/inequality chỉ dùng khi phù hợp.

## S26 — Clock basis

V0.1 dùng **local Windows system clock của máy chạy AmiBroker** để xác định current calendar period.

Publisher và Consumer phải export:

- `ClockBasisCode = LOCAL_SYSTEM`;
- current period ordinal;
- expected completed period ordinal.

Nếu máy sai ngày/timezone, contract không thể tự sửa. Native test phải có clock-boundary cases.

## S27 — Source revision semantics

Nếu data vendor sửa lịch sử của tuần/tháng đã publish:

- snapshot cũ không tự được gọi algorithmic repaint;
- publisher chạy lại có thể ghi generation mới cho cùng SourcePeriodOrdinal;
- provenance phải cho thấy PublishedAt/Generation thay đổi.

MTF layer cần phân biệt source revision với logic repaint.

## S28 — No autosave assumption

Persistent StaticVars tồn tại trong memory ngay sau publish và được lưu qua exit theo cơ chế AmiBroker.

Contract không bắt buộc `StaticVarAutoSave` với interval nhỏ.

Nếu sau này cần crash-resilient disk flush, phải đặc tả vận hành riêng; không dùng autosave cực ngắn gây block static access.

## S29 — Publisher/Consumer output audit

Publisher Exploration tối thiểu phải cho:

- symbol;
- native interval;
- current calendar period ordinal;
- expected completed ordinal;
- selected source ordinal;
- selected source DateTime;
- generation;
- Ready/commit status;
- PublisherStatusCode.

Consumer Exploration tối thiểu:

- requested symbol/timeframe;
- expected period ordinal;
- source period ordinal;
- schema versions;
- generation A/B;
- validity status/reason;
- decoded Composite state fields.

## S30 — Consumer không phải Aggregator

Consumer chỉ deserialize/validate Weekly hoặc Monthly snapshot.

Nó không được:

- so sánh Daily/Weekly/Monthly để sinh Alignment;
- quyết định higher context dominates;
- tạo score;
- tạo signal.

Những việc đó thuộc MTF Aggregator đã được đặc tả ở PR #28.

## S31 — Điều kiện chuyển sang implementation

Chỉ sau khi chủ dự án phê duyệt S01–S32 mới:

1. khóa contract này vào `main`;
2. tạo branch implementation xếp chồng trên Composite/Phase development stack phù hợp;
3. viết `WeeklyPublisher`, `MonthlyPublisher` và shared `SnapshotConsumer`;
4. static conformance audit;
5. Verify Syntax AmiBroker 6.20.01 khi quay lại native testing;
6. chạy boundary tests: week rollover, month rollover, year rollover, missing period, stale snapshot, generation race simulation, version mismatch;
7. chỉ khi Publisher/Consumer contract đạt yêu cầu source/interface mới viết MTF Aggregator.

## S32 — Không trading logic

Snapshot contract chỉ vận chuyển state.

Không có:

- Buy/Sell/Short/Cover;
- PositionSize;
- confidence/probability;
- risk score;
- preferred timeframe;
- ranking.

---

## 3. Phản ví dụ bắt buộc

1. Thứ Tư: weekly current bar đang tăng mạnh → không publish tuần hiện tại.
2. Thứ Sáu sau giờ đóng cửa nhưng calendar chưa sang tuần mới → v0.1 vẫn không force publish current week.
3. Thứ Hai tuần mới → tuần trước mới đủ điều kiện expected completed period.
4. Ngày cuối tháng sau đóng cửa → current month chưa publish cho tới calendar sang tháng mới.
5. Snapshot tuần trước tồn tại persistent nhưng consumer đang ở tuần kế tiếp nữa → `STALE PERIOD`.
6. Snapshot source period lớn hơn/equal current period → `FUTURE PERIOD`.
7. Consumer đọc đúng generation lúc đầu nhưng publisher commit generation mới giữa chừng → reject lượt đọc đó.
8. SchemaMajor sai → fail closed dù payload numeric nhìn hợp lý.
9. Symbol AAA snapshot không được dùng cho BBB.
10. Weekly snapshot không được dùng thay Monthly khi Monthly missing.
11. Multiple RangeContext → không tự chọn một range để tạo singleton state.
12. Weekly event + Monthly event không được OR vào Daily current-event mask.
13. Data vendor sửa weekly history và republish → generation mới, không gọi algorithmic repaint tự động.
14. StaticVar tồn tại qua restart nhưng source period sai → stale/reject.
15. Publisher chạy ở Daily interval → INVALID_INTERVAL, không commit.
16. Source bar expected period không có do missing data → EXPECTED_PERIOD_NOT_FOUND, không lấy period cũ gần nhất bù vào.
17. Current higher bar provisional → không official snapshot.
18. Consumer missing field quan trọng → INVALID_PAYLOAD.
19. DateTime encoded value không dùng `>` như numeric clock ordering.
20. Snapshot contract không tạo MTF bullish/bearish conclusion.

---

## 4. Bảng quyết định cần chủ dự án phê duyệt

| Mã | Đề xuất | Khuyến nghị |
|---|---|---|
| S01 | Current-state Daily/Weekly/Monthly only | Chấp thuận rất mạnh |
| S02 | Publisher chỉ serialize canonical Composite | Chấp thuận rất mạnh |
| S03 | Native timeframe gate | Chấp thuận rất mạnh |
| S04 | Không mặc định last higher bar đã hoàn tất | Chấp thuận rất mạnh |
| S05 | Monotonic period ordinal | Chấp thuận mạnh |
| S06 | Chỉ previous calendar-completed period | Chấp thuận rất mạnh |
| S07 | Không manual completion override v0.1 | Chấp thuận mạnh |
| S08 | Tìm đúng expected period, không BarCount-2 assumption | Chấp thuận rất mạnh |
| S09 | Namespace theo symbol + timeframe | Chấp thuận mạnh |
| S10 | Schema/producer version bắt buộc | Chấp thuận rất mạnh |
| S11 | Provenance bắt buộc | Chấp thuận rất mạnh |
| S12 | Persistent scalar snapshot | Chấp thuận mạnh |
| S13 | Không static array v0.1 | Chấp thuận rất mạnh |
| S14 | Commit protocol Ready-last | Chấp thuận rất mạnh |
| S15 | Double-read generation guard | Chấp thuận rất mạnh |
| S16 | Generation không dùng làm market recency | Chấp thuận |
| S17 | Singleton Composite payload | Chấp thuận mạnh |
| S18 | Multiple-context diagnostics | Chấp thuận rất mạnh |
| S19 | Event provenance tách timeframe | Chấp thuận rất mạnh |
| S20 | Validity enum chi tiết | Chấp thuận mạnh |
| S21 | Freshness bằng period identity | Chấp thuận rất mạnh |
| S22 | Future period hard reject | Chấp thuận rất mạnh |
| S23 | Missing/stale không fallback | Chấp thuận rất mạnh |
| S24 | ProvisionalFlag hard gate | Chấp thuận rất mạnh |
| S25 | DateTime comparison đúng semantics AmiBroker | Chấp thuận rất mạnh |
| S26 | Local system clock basis minh bạch | Chấp thuận mạnh |
| S27 | Source revision != algorithmic repaint | Chấp thuận mạnh |
| S28 | Không giả định autosave tần suất cao | Chấp thuận |
| S29 | Publisher/Consumer Exploration audit | Chấp thuận rất mạnh |
| S30 | Consumer không làm Aggregator | Chấp thuận rất mạnh |
| S31 | Khóa contract trước implementation/Aggregator | Chấp thuận rất mạnh |
| S32 | Không trading logic | Chấp thuận rất mạnh |

---

## 5. Kết luận dự thảo

Điểm thiết kế quan trọng nhất là **không truyền historical higher-timeframe arrays qua StaticVar trong v0.1**. Vì Multi-Timeframe hiện chỉ cần current authoritative context, scalar snapshot có version + period identity + generation guard là đơn giản hơn, dễ audit hơn và tránh hầu hết rủi ro timestamp synchronization của static arrays.

Quy tắc an toàn chủ chốt:

`ONLY PREVIOUS CALENDAR-COMPLETED HIGHER PERIOD → SERIALIZE SCALAR STATE → VERSION/PERIOD/GENERATION VALIDATE → FAIL CLOSED`.

Sau khi S01–S32 được chủ dự án duyệt, mới triển khai Snapshot Publisher/Consumer; MTF Aggregator tiếp tục bị chặn cho đến khi contract này có implementation source/interface ổn định.