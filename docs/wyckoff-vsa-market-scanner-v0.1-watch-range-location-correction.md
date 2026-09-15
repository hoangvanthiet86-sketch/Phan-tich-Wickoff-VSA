# Wyckoff VSA Market Scanner v0.1 — Correction: A/B Watch Range-Location Coherence

**Trạng thái:** `APPROVED CORRECTION — DOCUMENTATION ONLY — AFL IMPLEMENTATION PENDING`

**Ngày phê duyệt:** 2026-09-12  
**Nhánh áp dụng:** `integration/wyckoff-vsa-production-candidate-v0.1`  
**Đặc tả gốc:** PR #36 — `MS01–MS40`, merge commit `b70cae9c8714cbb2b17082d155e57b50110aa13f`  
**Phạm vi correction:** chỉ Market Scanner v0.1; chưa sửa AFL trong commit tài liệu này.

## 1. Lý do correction

Native audit của Production Candidate cho thấy một khoảng trống ngữ nghĩa trong `WATCH`:

- `WATCH` hiện được tạo từ Phase A/B (`CandidateStage == 1`) cùng các gate dữ liệu/Review/RS;
- nhưng Scanner chưa kiểm tra việc **giá hiện tại còn coherent với active Trading Range hay không**;
- upstream RangeContext có thể vẫn giữ một frozen range là `ACTIVE` trong khi giá đã đi ra ngoài biên, vì lifecycle upstream chỉ supersede/invalidate khi contract cấu trúc tương ứng được thỏa mãn;
- vì vậy một symbol có thể vẫn mang Phase A/B và bị Scanner gọi `WATCH` dù current price đã nằm ngoài active range.

Đây không phải data corruption và không phải lỗi runtime AFL. Đây là thiếu một method/review gate ở lớp Scanner.

## 2. Bằng chứng native dùng để phê duyệt correction

### DTP

Tại 2026-09-11:

- Phase: `PHASE-B-LIKE`;
- lower active range xấp xỉ `67.0872–71.0336`;
- Close `58.0000`;
- normalized RangePosition `-2.3027`;
- RangeContext vẫn `ACTIVE`;
- không supersede, không invalidate.

DTP vì vậy không phù hợp để giữ `WATCH` thuần trong khi Phase vẫn A/B.

### FRT

Tại 2026-09-11:

- Phase: `PHASE-B-LIKE`;
- upper active range xấp xỉ `152.0061–172.3879`;
- Close `137.0000`;
- normalized RangePosition `-0.7363`;
- RangeContext vẫn `ACTIVE`;
- không supersede, không invalidate.

FRT vì vậy cũng không phù hợp để giữ `WATCH` thuần trong khi Phase vẫn A/B.

### SNZ — control case

Tại 2026-09-11:

- Phase: `PHASE-B-LIKE`;
- lower active range `23.0000–25.0000`;
- Close `23.7000`;
- normalized RangePosition `0.3500`;
- giá vẫn ở trong range;
- RangeContext `ACTIVE`;
- không supersede, không invalidate.

SNZ là control case cho thấy Phase B vẫn có thể là `WATCH` hợp lệ khi current price còn coherent với active range.

# QUYẾT ĐỊNH BỔ SUNG

## MS41 — A/B Watch Range-Location Coherence Gate

### MS41.1 — Chỉ áp dụng cho Watch-stage A/B

Correction này chỉ áp dụng khi:

`CandidateStage == 1`

nghĩa là Phase A-like hoặc Phase B-like theo mapping Scanner hiện hành.

Không dùng gate này để tái phân loại Phase C/D/E.

### MS41.2 — Range-location conflict là Method/Review state, không phải DataEligibility

Giá đi ra ngoài active range không làm dữ liệu trở thành invalid.

Do đó:

- không thêm vào `ExclusionReasonMask`;
- không chuyển symbol thành `DATA_GATED` chỉ vì current price ngoài range;
- giữ `DataEligibility` độc lập với correction này.

### MS41.3 — Điều kiện coherence cho A/B Watch

Một symbol Phase A/B chỉ được giữ là `WATCH` khi current usable RangeContext còn coherent với current price.

Với current single active usable RangeContext:

- current price nằm trong biên range, bao gồm hai biên, thì `RangeLocationConflict = 0`;
- current price nằm ngoài biên range thì `RangeLocationConflict = 1`.

Implementation phải ưu tiên public upstream range-location state nếu đã có; có thể dùng normalized RangePosition tương đương với điều kiện trong `[0,1]` khi provenance của range là hợp lệ.

### MS41.4 — Không thêm ngưỡng tùy ý

Cấm tạo correction bằng các threshold không có trong contract như:

- ngoài range trên X%;
- ngoài range quá Y ATR;
- ngoài range N bar rồi mới Review.

v0.1 chỉ phân biệt `inside/current-boundary` với `outside` dựa trên active RangeContext đã được upstream xuất bản.

### MS41.5 — Outside A/B phải chuyển sang Review

Nếu:

- `DataEligibility == 1`;
- `CandidateStage == 1`;
- current usable RangeContext là active;
- current price nằm ngoài range;

thì symbol không được xuất `WATCH` thuần.

Scanner phải đưa symbol vào:

`REVIEW — CONFLICT / AMBIGUITY`

với diagnostic reason:

`A/B RANGE LOCATION CONFLICT`.

### MS41.6 — Không suy hướng từ việc phá range

`RangeLocationConflict` không được tự suy ra:

- bullish candidate khi giá vượt upper boundary;
- bearish candidate khi giá thủng lower boundary.

Hướng phải tiếp tục đến từ upstream Phase/Family/Event/Composite/MTF/RS contracts.

Breakout, breakdown, Spring, Upthrust, SOW, SOS, LPS, LPSY, false-break reclaim hoặc Structural Sequence mới vẫn phải được upstream xác nhận theo contract hiện hành.

### MS41.7 — Không thay đổi lifecycle của RangeContext

Correction này **không sửa**:

- cách RangeContext được tạo;
- cách range bị supersede;
- cách range bị invalidate;
- cách Phase A/B/C/D/E chuyển trạng thái.

Scanner chỉ nhận biết sự không nhất quán giữa `A/B Watch-stage` và vị trí giá hiện tại để yêu cầu chart review.

### MS41.8 — Diagnostic variable bắt buộc khi implementation

AFL implementation dự kiến phải có scalar chẩn đoán tương đương:

`WSCN_RangeLocationConflictS`

Semantics:

- `0` = không có A/B range-location conflict;
- `1` = Phase A/B nhưng current price ngoài current usable active range.

Tên biến có thể được điều chỉnh nếu cần giữ namespace consistency, nhưng semantics không được thay đổi.

### MS41.9 — ReviewFlag phải consume RangeLocationConflict

Khi implementation:

`WSCN_ReviewFlagS`

phải bao gồm `WSCN_RangeLocationConflictS` như một method ambiguity/conflict độc lập.

Điều này đảm bảo symbol có dữ liệu hợp lệ nhưng A/B range-location không coherent sẽ đi vào Class `9 — REVIEW`, không phải Class `0 — DATA GATED`.

### MS41.10 — Watch phải fail closed trước RangeLocationConflict

`WSCN_WatchS` chỉ có thể true khi:

- `DataEligibility == 1`;
- `ReviewFlag == 0`;
- `CandidateStage == 1`;
- RS Watch condition hiện hành đạt;
- `RangeLocationConflict == 0`.

Không thay đổi các điều kiện Watch khác ngoài gate bổ sung này.

### MS41.11 — MethodBlockReasonMask mở rộng

Dành bit mới:

`1024 = A/B RANGE LOCATION CONFLICT`

Bit này:

- chỉ là diagnostic bit;
- không phải score;
- không làm thay đổi nguyên tắc `FILTER FIRST; NO NUMERIC RANKING`;
- không được trộn vào `ExclusionReasonMask`.

Các bit MethodBlock hiện hữu giữ nguyên ý nghĩa.

### MS41.12 — Multiple RangeContext vẫn theo MS12/MS30

Nếu current stock có multiple RangeContext thì logic Review hiện hành vẫn có ưu tiên độc lập.

MS41 không được chọn tùy ý một range thắng khi multiplicity đang ambiguous.

## 3. Acceptance cases bắt buộc sau khi sửa AFL

Sau implementation, native AmiBroker test phải chứng minh tối thiểu:

1. **DTP** tại trạng thái đã audit: `DataEligible = 1`, không còn Class `WATCH`, phải chuyển `REVIEW` với `A/B RANGE LOCATION CONFLICT`.
2. **FRT** tại trạng thái đã audit: `DataEligible = 1`, không còn Class `WATCH`, phải chuyển `REVIEW` với `A/B RANGE LOCATION CONFLICT`.
3. **SNZ** tại 2026-09-11: range-location gate không được chặn; nếu các gate khác không đổi thì phải vẫn Watch-capable về mặt range location.
4. Không symbol nào bị chuyển `DATA_GATED` chỉ vì correction này.
5. Không thay đổi Candidate Class semantics cho Phase C/D/E chỉ do MS41.
6. Full-universe rerun phải được thực hiện để đo tác động classification trước release acceptance.

Không được tuyên bố `NATIVE PASS` cho correction cho tới khi các case trên được chạy trực tiếp trong AmiBroker 6.20.01.

## 4. Ngoài phạm vi correction

Correction này không:

- sửa Core/Candidate/Structure/Location/Confirmation/Event/Structural Sequence/Phase/Composite;
- sửa P&F cause/objective;
- thêm Trade Risk/R:R;
- thêm Buy/Sell/Short/Cover;
- thêm PositionScore/ranking/weighted score;
- tự xây universe trong Scanner.

`MS02 — Universe do deployment cung cấp` vẫn giữ nguyên. Stock-only universe sẽ được khóa ở lớp vận hành AmiBroker/watchlist/category filter, không bằng heuristic tên ticker trong phương pháp Scanner.

## 5. Trình tự triển khai sau correction

1. Commit tài liệu correction này trên nhánh integration.
2. Rà static impact vào `WyckoffVSA_MarketScanner_v0.1.afl`.
3. Sửa AFL Scanner theo MS41, không sửa upstream methodology.
4. Native-test DTP/FRT/SNZ.
5. Rerun full stock-only universe.
6. Chỉ sau native acceptance mới cập nhật release-candidate readiness.

---

**Owner decision:** APPROVED.  
**AFL implementation status:** NOT YET APPLIED IN THIS DOCUMENTATION COMMIT.
