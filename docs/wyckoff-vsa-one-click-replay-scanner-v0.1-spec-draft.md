# Wyckoff VSA One-Click Replay Scanner v0.1 — Đặc tả dự thảo

**Trạng thái:** SUPERSEDED — yêu cầu đã hợp nhất vào Unified One-Click Scanner  
**Nhánh:** `feature/one-click-scanner-v0.1`  
**Baseline:** `c3b3b45bc3adb18b55d25abae07693c5b7e4df2b`  
**Mục tiêu cũ:** Replay point-in-time một-click. Không còn entrypoint riêng; toàn bộ yêu cầu trong tài liệu này được thực thi bởi `WyckoffVSA_OneClickScanner_v0.1.afl` unified.

---

## 1. Yêu cầu người dùng

Trong Bar Replay, người dùng chỉ phải:

1. đưa Bar Replay tới ngày cần kiểm tra;
2. mở `WyckoffVSA_OneClickReplayScanner_v0.1.afl`;
3. `Apply to = VN STOCKS ONLY`;
4. `Periodicity = Daily`;
5. `Range = 1 Recent Bar` hoặc range được profile replay quy định;
6. chọn Production Filter;
7. bấm `Explore` đúng một lần.

Không chạy trước Historical W/M Publisher, Historical Market Publisher, Historical Stock Timeline Publisher hay Historical Scanner cache builder.

---

## 2. No-lookahead bắt buộc

Mọi dữ liệu dùng để phân loại tại replay date T phải thỏa:

- Daily stock source <= T;
- Daily VNINDEX source <= T;
- Weekly authoritative source phải thuộc tuần đã hoàn tất trước T;
- Monthly authoritative source phải thuộc tháng đã hoàn tất trước T;
- RS chỉ dùng stock/benchmark bar đã biết tại T;
- confirmed pivot/event phải giữ nguyên confirmation lag canonical;
- không dùng snapshot/timeline được tạo từ tương lai nếu provenance vượt T.

Nếu không chứng minh được causal provenance thì fail closed.

---

## 3. Một lõi phân tích chung

Replay Scanner không được duy trì một methodology riêng.

Live One-Click và Replay One-Click phải dùng cùng:

- RuntimeConfig;
- Core/Candidate/Structure/Confirmation;
- Event/Sequence/Phase/Composite;
- PublicActive ContextMultiplicity;
- MTF relation logic;
- Relative Strength semantics;
- Market Scanner decision logic.

Khác biệt chỉ nằm ở nguồn `as-of` và cache key.

---

## 4. Tối ưu thời gian

### 4.1 Market pre-processing một lần

Dùng top-level:

`if (Status("stocknum")==0) { ... }`

để khởi tạo/cache VNINDEX context cho đúng replay as-of trước khi các symbol thread còn lại chạy.

Không tính lại full VNINDEX stack cho từng cổ phiếu.

### 4.2 Cache theo kỳ causal

Cache key phải chứa tối thiểu:

- mode LIVE/REPLAY;
- as-of DateNum;
- config fingerprint;
- schema/runtime version;
- symbol;
- timeframe;
- completed weekly ordinal hoặc completed monthly ordinal.

Weekly/Monthly cache chỉ recompute khi completed-period key thay đổi.

### 4.3 Stock-specific work

Mỗi cổ phiếu chỉ tính phần Daily bắt buộc cho replay as-of và đọc/recompute W/M của chính nó theo cache hợp lệ.

### 4.4 Không historical backfill bắt buộc

Replay filtering tại một ngày không được yêu cầu publish toàn bộ historical timeline trước.

Historical timeline v0.1 vẫn giữ cho audit/regression hoặc nghiên cứu nhiều ngày, nhưng không là dependency bắt buộc cho một-click replay.

---

## 5. Kết quả đầu ra

Production Filter:

- 0 Qualified
- 1 Developing+
- 2 Watch+
- 3 Review/Audit
- 4 All Eligible

Output compact tương đương One-Click Live:

- Ticker
- Replay as-of
- Data status
- Data Eligible
- Candidate Class
- Side
- Stage
- Phase
- Family
- Range Position
- MTF Alignment
- RS vs Market
- Review
- Method Block reason

---

## 6. Nghiệm thu

### OR01 — Cold replay
Không có cache lịch sử liên quan; một Explore phải cho kết quả hoặc fail closed vì nguồn thật sự thiếu, không vì chưa chạy publisher.

### OR02 — Same replay date repeat
Lần chạy sau phải dùng cache hợp lệ và giữ nguyên decision surface.

### OR03 — Replay step +1 ngày
Daily/market daily recompute đúng as-of mới; W/M không recompute nếu completed period chưa đổi.

### OR04 — Replay qua tuần mới
Weekly context tự chuyển sang completed week mới, không thao tác publisher.

### OR05 — Replay qua tháng mới
Monthly context tự chuyển sang completed month mới.

### OR06 — No future provenance
Không trường hợp nào có SourceDateTime > replay as-of.

### OR07 — Historical equivalence
Tại các ngày control đã có historical timeline hợp lệ, kết quả One-Click Replay phải khớp Historical Scanner/canonical decision surface 100% trên các trường khóa.

### OR08 — Append stability
Append dữ liệu tương lai không được đổi kết quả ở replay date cũ.

### OR09 — Timing
Đo cold/warm time. Warm replay phải tránh recompute benchmark và higher timeframe không đổi.

Chỉ chốt:

`ONE_CLICK_REPLAY_SCANNER_V01 = PASS`

khi OR01-OR09 đạt native trên AmiBroker 6.20.01.
