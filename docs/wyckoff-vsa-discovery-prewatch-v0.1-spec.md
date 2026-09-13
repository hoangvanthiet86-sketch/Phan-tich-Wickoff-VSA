# Wyckoff VSA Discovery / Pre-Watch v0.1 — Đặc tả

**Trạng thái:** Dự thảo kỹ thuật để con người phê duyệt; chưa triển khai AFL production.

**Ngày:** 14/09/2026.

**Nền cố định:** `integration/wyckoff-vsa-production-candidate-v0.1`.

**Commit nền tại thời điểm tạo nhánh:** `ab80b2f98ac2809278bf2cfed886166308d3dca9`.

**Môi trường đích:** AmiBroker 6.20.01, tối thiểu 6.20+.

**Tệp triển khai dự kiến:** `afl/WyckoffVSA_DiscoveryPreWatch_v0.1.afl`.

## 1. Mục đích

Discovery / Pre-Watch v0.1 là một lớp **khám phá nghiên cứu độc lập với Production Scanner**. Nó chỉ trả lời câu hỏi hẹp:

> Trong các mã đã có dữ liệu hợp lệ nhưng chưa đạt `WATCH` production, mã nào đang ở giai đoạn hình thành/phát triển vùng đủ gần để đáng đưa vào danh sách quan sát sớm, trong khi nguyên nhân bị chặn chủ yếu là ambiguity sớm thay vì xung đột phương pháp rõ ràng?

Lớp này **không thay đổi** `Candidate Class`, `WATCH`, `DEVELOPING`, `QUALIFIED`, `ReviewFlag`, `MethodBlockMask` hoặc bất kỳ quyết định production nào.

Luồng kiến trúc dự kiến:

```text
Daily Publisher -> Daily Snapshot -> Fast Scanner (PRODUCTION, GIỮ NGUYÊN)
                              \
                               -> Discovery / Pre-Watch v0.1 (RESEARCH, MỚI)
```

Discovery / Pre-Watch là một consumer song song. Nó không nằm trên đường quyết định production và không được ghi ngược kết quả vào production state.

## 2. Động cơ và bằng chứng hiện tại

Checkpoint native hiện có cho thấy Production Scanner đang rất bảo thủ trên snapshot 11/09/2026:

- `1,066` mã Data Eligible;
- `1,051` mã ở `REVIEW - CONFLICT / AMBIGUITY`;
- `14` mã `NOT A CURRENT CANDIDATE`;
- `1` mã `WATCH` là SNZ;
- `0` `DEVELOPING`;
- `0` `QUALIFIED`.

Phân tích MTF cho thấy:

- `1,029` mã có `MTF Directional Alignment = 6`;
- `668/1,029` có `Daily ContextMultiplicity = 2`;
- `246/1,029` Daily chỉ một vùng nhưng directional context vẫn mixed/conflicting;
- `115/1,029` nguyên nhân chính nằm ở Weekly và/hoặc Monthly.

Deep diagnostic `ContextMultiplicity=2` trên toàn bộ tập Daily cho thấy:

- `975` mã có `ContextMultiplicity=2`;
- `934/975` thực sự có 2 range active;
- `38/975` chỉ có 1 range active;
- `3/975` không còn range active;
- `41/975` có mismatch `ContextPresent` so với public-active semantics.

Trong tập `668` mã liên quan trực tiếp tới MTF=6 / Data Eligible:

- `636/668` thực sự có 2 range active;
- `30/668` chỉ có 1 range active;
- `2/668` không còn range active;
- `32/668` có dấu hiệu đếm rộng;
- trong `636` mã hai range active: `232` tách rời, `219` lồng nhau, `185` chồng lấn một phần;
- `263` là cặp Pha B / Pha B;
- `487` là cặp `UNRESOLVED LOWER RANGE` + `UNRESOLVED UPPER RANGE`.

Bằng chứng này **không đủ để nới Production Scanner**. Nó chỉ đủ để biện minh cho một lớp discovery riêng nhằm quan sát sớm mà không làm thay đổi decision surface đã khóa.

## 3. Phạm vi và bất biến

### 3.1. Bao gồm

- Chỉ dùng trạng thái current-state đã được publish hợp lệ.
- Chỉ xét mã `Data Eligible`.
- Chỉ xét `Candidate Stage = 1` — `WATCH - RANGE FORMATION / DEVELOPMENT`.
- Dùng RS so với thị trường để yêu cầu cấu trúc RS đã có hướng (`RISING` hoặc `FALLING`).
- Phân biệt ambiguity sớm có thể chấp nhận cho discovery với conflict/risk concern không được coi là `PRE-WATCH NEAR`.
- Giữ nguyên mọi enum production và hiển thị chúng song song để kiểm toán.
- Xuất lý do vì sao mã chưa phải Production Watch.

### 3.2. Không bao gồm

- Không sửa `WyckoffVSA_MarketScanner_v0.1.afl`.
- Không sửa `WyckoffVSA_FastScanner_v0.2.afl` để thay đổi filter semantics.
- Không sửa `DailyPublisher`, Daily Snapshot contract, Composite, Phase/Context, MTF hoặc RS.
- Không thay đổi threshold, weight, phase rule, family rule, event rule hoặc range lifecycle.
- Không tạo Buy/Sell/Short/Cover.
- Không tạo `PositionScore` hoặc numeric ranking.
- Không tạo xác suất, confidence hoặc điểm hấp dẫn.
- Không backtest lợi nhuận.
- Không historical backfill.
- Không suy ra rằng một mã Pre-Watch sẽ trở thành Watch/Developing/Qualified.
- Không dùng P&F trong v0.1.

### 3.3. Bất biến production

1. Một mã vào `PRE-WATCH` **không được** thay đổi Candidate Class production.
2. Production `WATCH` luôn có ưu tiên ngữ nghĩa cao hơn Discovery; Discovery không được đổi Watch thành Pre-Watch.
3. `REVIEW` production vẫn là `REVIEW`; Discovery chỉ thêm một nhãn nghiên cứu song song.
4. Method block bit vẫn là bit mask chẩn đoán, không phải score.
5. Không được “trừ điểm” hoặc “cộng điểm” từ các bit.
6. Không có bất kỳ thay đổi nào đối với tập Filter 0–5 của Fast Scanner production.

## 4. Nguồn dữ liệu v0.1

Triển khai tương lai phải ưu tiên consumer nhẹ:

```afl
#include_once <WyckoffVSA_DailySnapshotConsumer_v0.2.afl>
```

Discovery v0.1 không được include heavy analytical stack chỉ để tái tính trạng thái đã có trong snapshot.

Các trường cần dùng ở mức tối thiểu:

- Snapshot valid/status;
- `DataEligible`;
- `CandidateClass`;
- `Side`;
- `Stage`;
- `Review`;
- `MethodBlockMask`;
- `ContextMultiplicity`;
- `PhaseState`;
- `FamilyHypothesis`;
- `RangeLocationCoherent` / `RangeLocationConflict` nếu contract hiện hành công bố được;
- `MTFDirectionalAlignment`;
- `RSStockVsMarketStructure`;
- `RSPriceRelationship`;
- Market/Group selection status để hiển thị audit khi có.

Nếu một trường bắt buộc cho quy tắc khóa không có trong Daily Snapshot consumer hiện hành, implementation **không được tái tạo logic upstream bằng công thức gần đúng**. Khi đó phải dừng và lập thay đổi contract riêng để phê duyệt.

## 5. Enum Discovery v0.1

`DiscoveryStatusCode` là enum, **không phải ranking**:

| Code | Tên chuẩn | Ý nghĩa |
|---:|---|---|
| 0 | `DISCOVERY_NONE` | Không thuộc tập discovery v0.1 |
| 1 | `PRE_WATCH_NEAR` | Gần Watch về cấu trúc sớm; chỉ còn ambiguity mềm được cho phép |
| 2 | `DISCOVERY_REVIEW_ONLY` | Có cấu trúc sớm nhưng còn concern/xung đột không được phép gọi Near |
| 3 | `PRODUCTION_WATCH_REFERENCE` | Đã là Production Watch; chỉ hiển thị đối chiếu, không phải Pre-Watch |

Code không biểu thị độ tốt tăng dần. Không được sort mặc định theo code như một thang điểm chất lượng.

## 6. Điều kiện nền Discovery

`DiscoveryBase = 1` chỉ khi tất cả điều kiện sau đúng:

1. Daily Snapshot hợp lệ và cùng business date chuẩn.
2. `DataEligible = 1`.
3. `CandidateStage = 1`.
4. `RS vs Market Structure` thuộc `{1, 2}` tương ứng cấu trúc RS tăng hoặc giảm.
5. Không phải terminal/superseded stage.

Không yêu cầu stock side phải bullish hoặc bearish. `Side = 0` vẫn hợp lệ cho Discovery vì mục tiêu là phát hiện sớm trước khi hướng được giải quyết.

Không dùng RS tăng/giảm để tự suy ra side.

## 7. Phân loại ambiguity mềm và concern cứng cho Discovery

### 7.1. Ambiguity mềm được phép ở `PRE_WATCH_NEAR`

Các Method Block bit sau được phép tồn tại mà không tự động loại khỏi `PRE_WATCH_NEAR`:

- bit `1`: bối cảnh thị trường chưa thuận / chưa rõ;
- bit `2`: pha còn quá sớm;
- bit `4`: hướng cổ phiếu chưa rõ;
- bit `8`: MTF conflict/complex **chỉ khi** `MTFDirectionalAlignment` không phải code 4 hoặc 5;
- bit `256`: có nhiều range context.

Lý do: đây là các trạng thái có thể xuất hiện tự nhiên ở giai đoạn quan sát sớm và chính là phần cần discovery theo bằng chứng native hiện tại.

### 7.2. Concern không được phép gọi `PRE_WATCH_NEAR`

Các Method Block bit sau làm mã chuyển sang `DISCOVERY_REVIEW_ONLY`:

- bit `16`: RS chưa đủ / hỗn hợp;
- bit `32`: VSA mixed/conflicting;
- bit `64`: Price/RS non-confirmation;
- bit `128`: Group leadership conflict;
- bit `512`: Market/Group role/config conflict;
- bit `1024`: A/B range-location conflict.

Ngoài ra:

- `MTFDirectionalAlignment = 4` (`BASE COUNTER TO HIGHER CONTEXT`) là concern;
- `MTFDirectionalAlignment = 5` (`HIGHER TIMEFRAMES CONFLICT`) là concern.

`MTFDirectionalAlignment = 6` được phép cho Pre-Watch vì v0.1 coi đây là ambiguity cần quan sát, **không phải xác nhận bullish/bearish**.

## 8. Quy tắc khóa `PRE_WATCH_NEAR`

Một mã có `DiscoveryStatusCode = 1` khi:

```text
DiscoveryBase = 1
AND ProductionWatch = 0
AND không có concern bit {16,32,64,128,512,1024}
AND MTFDirectionalAlignment NOT IN {4,5}
```

Các bit mềm `{1,2,4,8,256}` có thể cùng tồn tại.

Nếu production `Review=1`, mã vẫn có thể là `PRE_WATCH_NEAR`; nhãn Review production phải được giữ nguyên và hiển thị rõ.

`PRE_WATCH_NEAR` chỉ có nghĩa:

> “Đủ đáng để người dùng xem sớm trước Watch; nguyên nhân bị chặn còn lại thuộc nhóm ambiguity mềm của lớp discovery.”

Nó **không có nghĩa** “gần mua”, “sắp breakout”, “xác suất cao”, “rủi ro thấp” hoặc “sẽ được nâng hạng”.

## 9. Quy tắc `DISCOVERY_REVIEW_ONLY`

Một mã có `DiscoveryStatusCode = 2` khi:

```text
DiscoveryBase = 1
AND ProductionWatch = 0
AND (
    có ít nhất một concern bit {16,32,64,128,512,1024}
    OR MTFDirectionalAlignment IN {4,5}
)
```

Mục đích của class này là giữ khả năng audit và nghiên cứu, không phải đưa vào danh sách Pre-Watch mặc định.

Default Exploration v0.1 không cần hiển thị class 2 trừ khi người dùng bật chế độ audit.

## 10. Quy tắc `PRODUCTION_WATCH_REFERENCE`

Nếu `ProductionWatch = 1` và `DiscoveryBase = 1`:

```text
DiscoveryStatusCode = 3
```

Mục đích chỉ để kiểm tra continuity giữa discovery và production. Mã này không được đếm là Pre-Watch.

Production Watch không được thay đổi bởi Discovery.

## 11. Thứ tự quyết định

Thứ tự xác định enum:

```text
if NOT DiscoveryBase:
    DISCOVERY_NONE
else if ProductionWatch:
    PRODUCTION_WATCH_REFERENCE
else if concern exists or MTF in {4,5}:
    DISCOVERY_REVIEW_ONLY
else:
    PRE_WATCH_NEAR
```

Đây là precedence logic, không phải ranking.

## 12. Đầu ra mặc định

### 12.1. Chế độ người dùng

Mặc định chỉ xuất:

```text
DiscoveryStatusCode = PRE_WATCH_NEAR
```

Mục tiêu là tạo shortlist nhỏ, dễ đọc.

### 12.2. Chế độ audit

Có thể có `ParamToggle` để xuất cả:

- `PRE_WATCH_NEAR`;
- `DISCOVERY_REVIEW_ONLY`;
- `PRODUCTION_WATCH_REFERENCE`.

Toggle chỉ thay đổi hiển thị, không thay đổi classification.

### 12.3. Cột bắt buộc

Hiển thị AmiBroker dùng **tiếng Việt không dấu** để tránh lỗi encoding đã quan sát trên AmiBroker 6.20.01.

Tối thiểu:

- `Ticker` và `Date/Time` mặc định của AmiBroker;
- `Trang thai Discovery`;
- `Phan loai Production`;
- `Review Production`;
- `Giai doan ung vien`;
- `Pha Wyckoff`;
- `Gia thuyet cau truc`;
- `So vung / Context Multiplicity`;
- `MTF`;
- `RS so voi thi truong`;
- `Method Block Mask`;
- `Ly do chua la Watch`;
- phiên bản Discovery.

Không thêm lại cột `Ma co phieu` hoặc ngày dữ liệu nếu trùng `Ticker` / `Date/Time` mặc định.

## 13. Giải mã lý do

Discovery phải giữ **hai lớp lý do tách biệt**:

1. `Ly do production`: decode nguyên `MethodBlockMask` theo mapping production hiện hành.
2. `Phan loai discovery`: cho biết các lý do đó thuộc `ambiguity mem` hay `concern` trong Discovery v0.1.

Không được sửa, đổi nghĩa hoặc ghi đè MethodBlockMask gốc.

Không được gọi bit `256` “không xung đột” — chỉ được gọi là ambiguity được **cho phép để quan sát sớm**.

## 14. Multiple-range semantics

Discovery v0.1 **không sửa** `ContextMultiplicity`.

Vì deep diagnostic đã xác nhận một mismatch nhỏ giữa `ContextPresent` và public-active:

- v0.1 chỉ coi multiplicity bit `256` là warning/ambiguity;
- không tự động giả định hai range đều active;
- không tự suy ra range chính;
- không tự hợp nhất hai range;
- không tự chọn lower hoặc upper range làm authoritative.

Nếu tương lai production muốn đổi từ present-count sang active-count, đó là một thay đổi semantics upstream riêng, cần đặc tả, equivalence/acceptance mới và không thuộc Discovery v0.1.

## 15. MTF semantics

Discovery không thay đổi MTF code.

- code 0: chưa đủ dữ liệu MTF — có thể discovery;
- code 1: unresolved/non-directional — có thể discovery;
- code 2/3: alignment directional — có thể discovery;
- code 4: base counter higher context — chỉ Review-only;
- code 5: higher timeframes conflict — chỉ Review-only;
- code 6: mixed/complex — có thể Pre-Watch Near nhưng phải hiển thị cảnh báo.

Cho phép code 6 trong Discovery **không đồng nghĩa** nới production MTF.

## 16. RS semantics

V0.1 yêu cầu RS vs Market Structure phải là:

- code 1: rising; hoặc
- code 2: falling.

Code 0 hoặc 3 không vào `DiscoveryBase`.

RS falling không có nghĩa bearish signal; RS rising không có nghĩa bullish signal. Discovery chỉ yêu cầu RS đã có cấu trúc xác định, không dùng nó để suy ra side.

## 17. Hiệu năng và runtime

V0.1 phải là consumer nhẹ của Daily Snapshot:

- `SetBarsRequired(1,0)` hoặc tương đương current-state-only;
- không chạy heavy Wyckoff/VSA analytical stack;
- không publish snapshot;
- không thay đổi StaticVar production;
- không yêu cầu chạy lại DailyPublisher chỉ để quét Discovery sau khi snapshot ngày hiện tại đã hợp lệ.

Không đặt mục tiêu benchmark wall-clock mới trước native test. Chỉ yêu cầu kiến trúc không nặng hơn Fast Snapshot consumer một cách vô lý.

## 18. Causality và lịch sử

Discovery v0.1 là **current-state only**.

Không được kéo Range From-To rồi coi output hiện tại như historical classification. Snapshot current-state không phải timeline lịch sử.

Historical Scanner / backtest là lớp riêng sau này. Khi xây historical version phải đảm bảo tại ngày `t` chỉ dùng dữ liệu đã biết đến `t`, không dùng future-confirmed pivot hoặc snapshot tương lai.

Không được dùng kết quả Discovery v0.1 để tuyên bố hiệu quả chiến lược trong quá khứ.

## 19. Acceptance criteria khóa

### DP01–DP08: Production invariance

- **DP01**: không sửa Market Scanner production.
- **DP02**: không sửa Fast Scanner filter semantics.
- **DP03**: không sửa Candidate Class production.
- **DP04**: không sửa ReviewFlag production.
- **DP05**: không sửa MethodBlockMask production.
- **DP06**: không sửa Composite/Phase/MTF/RS semantics.
- **DP07**: không ghi snapshot production.
- **DP08**: không có Buy/Sell/Short/Cover/PositionScore.

### DP09–DP16: Input và base

- **DP09**: snapshot invalid -> `DISCOVERY_NONE`.
- **DP10**: `DataEligible=0` -> `DISCOVERY_NONE`.
- **DP11**: Stage khác 1 -> `DISCOVERY_NONE` trong v0.1.
- **DP12**: RS code 0 -> `DISCOVERY_NONE`.
- **DP13**: RS code 3 -> `DISCOVERY_NONE`.
- **DP14**: RS code 1 hoặc 2 có thể vào `DiscoveryBase`.
- **DP15**: Side 0 không tự loại khỏi DiscoveryBase.
- **DP16**: không suy ra Side từ RS.

### DP17–DP25: Classification

- **DP17**: ProductionWatch=1 -> `PRODUCTION_WATCH_REFERENCE`, không phải Pre-Watch.
- **DP18**: bit 16 -> `DISCOVERY_REVIEW_ONLY`.
- **DP19**: bit 32 -> `DISCOVERY_REVIEW_ONLY`.
- **DP20**: bit 64 -> `DISCOVERY_REVIEW_ONLY`.
- **DP21**: bit 128 -> `DISCOVERY_REVIEW_ONLY`.
- **DP22**: bit 512 -> `DISCOVERY_REVIEW_ONLY`.
- **DP23**: bit 1024 -> `DISCOVERY_REVIEW_ONLY`.
- **DP24**: MTF code 4 hoặc 5 -> `DISCOVERY_REVIEW_ONLY`.
- **DP25**: chỉ còn các bit mềm {1,2,4,8,256} và MTF không 4/5 -> `PRE_WATCH_NEAR`.

### DP26–DP32: Presentation / audit

- **DP26**: default output chỉ hiển thị `PRE_WATCH_NEAR`.
- **DP27**: audit toggle không thay đổi classification.
- **DP28**: user-facing AFL labels là tiếng Việt không dấu.
- **DP29**: không lặp cột Symbol/Date nếu AmiBroker đã có `Ticker`/`Date/Time`.
- **DP30**: MethodBlockMask gốc luôn có thể audit.
- **DP31**: `PRE_WATCH_NEAR` phải hiển thị rõ “khong phai tin hieu mua”.
- **DP32**: code enum không được dùng như score/ranking.

### DP33–DP38: Runtime / regression

- **DP33**: consumer không include heavy full runtime stack.
- **DP34**: không yêu cầu DailyPublisher rerun nếu current snapshot hợp lệ.
- **DP35**: chạy Discovery không làm thay đổi snapshot generation ID.
- **DP36**: chạy Discovery không làm thay đổi kết quả Fast Scanner production cùng snapshot.
- **DP37**: SNZ production Watch phải vẫn là Production Watch, không bị hạ thành Pre-Watch.
- **DP38**: native test phải chứng minh output deterministic trên cùng snapshot/config.

## 20. Bộ ca kiểm thử tối thiểu dự kiến

1. Snapshot invalid.
2. DataEligible=0.
3. Stage=0.
4. Stage=2.
5. Stage=1 + RS=0.
6. Stage=1 + RS=3.
7. Stage=1 + RS=1 + production Watch=1.
8. Stage=1 + RS=2 + chỉ soft bits `1+2+4+8+256` + MTF=6.
9. Như ca 8 nhưng có bit 32.
10. Như ca 8 nhưng có bit 64.
11. Như ca 8 nhưng MTF=4.
12. Như ca 8 nhưng MTF=5.
13. Stage=1 + RS directional + multiple range only.
14. Regression SNZ.
15. Regression toàn universe: production Fast Scanner trước/sau Discovery phải giống tuyệt đối.

## 21. Điều kiện để chuyển từ đặc tả sang implementation

Chỉ bắt đầu AFL sau khi con người phê duyệt tối thiểu các điểm:

1. Discovery là lớp research song song, không thay Production Scanner.
2. v0.1 chỉ xét Stage 1.
3. RS phải directional code 1/2.
4. bit mềm được phép là `{1,2,4,8,256}` với MTF 4/5 vẫn bị loại khỏi Near.
5. concern bits `{16,32,64,128,512,1024}` chuyển sang Review-only.
6. code 6 MTF được phép ở Pre-Watch nhưng phải cảnh báo.
7. default chỉ hiển thị `PRE_WATCH_NEAR`.
8. không historical/backtest trong v0.1.

## 22. Các vấn đề cố ý hoãn

Không giải quyết trong v0.1:

- Có nên dùng active-count thay present-count trong production.
- Có nên phân biệt hai active range tương thích với hai active range xung đột.
- Có nên thêm Stage 2/3 vào Discovery.
- Có nên xây ranking.
- Có nên dùng P&F.
- Có nên dùng Discovery làm input cho trade strategy.
- Historical Scanner và backtest.

Các vấn đề trên phải có đặc tả và acceptance riêng. Không được mở rộng âm thầm trong implementation v0.1.

## 23. Kết luận thiết kế

Discovery / Pre-Watch v0.1 không nới Production Scanner. Nó tạo một **research funnel có kiểm soát** ở phía trước `WATCH`, dùng đúng current snapshot hiện hành, cho phép một số ambiguity sớm nhưng giữ các conflict/risk concern quan trọng ở lớp Review-only.

Mục tiêu là tăng khả năng phát hiện sớm mà vẫn bảo toàn hoàn toàn decision surface production đã được nghiệm thu.
