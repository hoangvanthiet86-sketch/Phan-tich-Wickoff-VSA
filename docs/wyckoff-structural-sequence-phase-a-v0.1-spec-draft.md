# Wyckoff Structural Sequence Engine — Dự thảo đặc tả PS / SC / AR / ST và PSY / BC / AR / ST v0.1

**Trạng thái:** DỰ THẢO ĐỂ CHỦ DỰ ÁN PHÊ DUYỆT. Chưa khóa, chưa phải tiêu chí nghiệm thu, chưa có AFL triển khai. Tài liệu này được xây dựng sau bước nghiên cứu riêng về Phase A/stopping action và không được dùng để tuyên bố một trading range là Accumulation hoặc Distribution.

## 1. Mục tiêu

Mô-đun này là lớp **Structural Sequence** nằm giữa Event Engine và Phase/Context Engine. Nhiệm vụ của nó là ghép các bằng chứng sự kiện đơn lẻ thành hai chuỗi stopping-action có thứ tự nhân quả:

### Chuỗi phía đáy

`PS-LIKE → SC-LIKE → AUTOMATIC-RALLY-LIKE → ST-LIKE`

### Chuỗi phía đỉnh

`PSY-LIKE → BC-LIKE → AUTOMATIC-REACTION-LIKE → ST-LIKE`

Luồng kiến trúc:

`Core → Candidate → Structure/Location → Confirmation → Event → Structural Sequence → Phase/Context`

Mô-đun **không** được tự gán `ACCUMULATION`, `DISTRIBUTION`, `REACCUMULATION`, `REDISTRIBUTION` hay Phase A/B/C/D/E.

## 2. Cơ sở nghiên cứu trước khi đặc tả

### 2.1. Nguồn chính

- Wyckoff Analytics — Wyckoff Method: https://www.wyckoffanalytics.com/wyckoff-method/
- StockCharts ChartSchool — The Wyckoff Method: A Tutorial: https://chartschool.stockcharts.com/table-of-contents/market-analysis/wyckoff-analysis-articles/the-wyckoff-method-a-tutorial
- StockCharts — Wyckoff Power Charting. Let's Review: https://articles.stockcharts.com/article/articles-wyckoff-2015-07-wyckoff-power-charting-lets-review/
- StockCharts — The Stopping Action of a Downtrend: https://articles.stockcharts.com/article/articles-wyckoff-2015-05-the-stopping-of-a-downtrend/
- StockCharts — Distribution Definitions: https://stockcharts.com/articles/wyckoff/2015/09/distribution-definitions.html
- StockCharts — Context is King: https://articles.stockcharts.com/article/articles-wyckoff-2015-09-context-is-king/
- StockCharts — Action - Test: https://stockcharts.com/articles/wyckoff/2016/09/action--test.html
- StockCharts — Rev Up with Reaccumulation Trading Ranges: https://articles.stockcharts.com/article/articles-wyckoff-2015-07-rev-up-with-reaccumulation-trading-ranges.html

### 2.2. Kết luận nghiên cứu có ảnh hưởng trực tiếp tới thiết kế

1. PS/SC/AR/ST là chuỗi stopping action điển hình phía cuối một markdown; PS không bắt buộc phải xuất hiện rõ trong mọi trường hợp.
2. PSY/BC/Automatic Reaction/ST là chuỗi stopping action điển hình phía cuối một uptrend; tuy nhiên uptrend cũng có thể kết thúc bằng sự cạn kiệt demand mà không có climactic action rõ.
3. AR không chỉ là một thanh k+1. Automatic Rally/Reaction là **một counter-swing** sau climax và cực trị của swing đó giúp định nghĩa biên trading range.
4. Automatic Rally sau SC là bằng chứng làm rõ rằng climax đã hoàn tất; tương tự Automatic Reaction giúp xác nhận BC.
5. ST là **Action–Test** của vùng climax. Có thể có nhiều ST. Test tốt thường cho thấy effort giảm, nhưng test vẫn có thể được gọi là test dù volume còn cao; khi đó chất lượng test thấp và supply/demand còn hiện diện.
6. Một successful test phía SC có thể dừng trên, tại, hoặc thậm chí dưới SC low. Do đó `ST Low >= SC Low` không được dùng làm điều kiện định nghĩa tuyệt đối.
7. Tương tự phía BC, một ST có thể chạm hoặc hơi vượt đỉnh BC. Nếu vượt mạnh/failure pattern, Event/Phase Engine khác có thể gọi Upthrust; Structural Sequence không được loại test chỉ vì High vượt BC.
8. BC + Automatic Reaction + ST **không tự chứng minh Distribution**. Cùng stopping sequence này cũng có thể khởi đầu Reaccumulation.
9. SC + Automatic Rally + ST **không tự chứng minh Accumulation**; trong bối cảnh downtrend lớn hơn có thể phát triển thành Redistribution.
10. Vì dự án chưa có Trend/Phase Engine hoàn chỉnh, v0.1 phải phát hiện **hình thái chuỗi** chứ không được tuyên bố nguyên nhân/pha thị trường.

## 3. Nguyên tắc kiến trúc tổng quát

Structural Sequence không tính lại RVOL, RSpread, ATR, pivot hoặc Event. Nó chỉ tiêu thụ output upstream đã biết tại thời điểm hiện tại.

Nguồn dependency chính khi triển khai:

- `WyckoffVSA_Event_StoppingClimacticAbsorption_v0.1.afl` cho Climactic/Elevated/Stopping/Absorption evidence;
- Structure/Location transitive outputs cho confirmed pivot High/Low và tọa độ confirmation;
- các Event khác như Spring/Shakeout, Upthrust, SOS/LPS chỉ là context tương lai, không hard-gate v0.1.

Không dùng Zig/Peak/Trough nhìn tương lai. Không dùng ValueWhen/LastValue theo cách làm mất point-in-time causality. Stateful loop được phép nếu chỉ đọc current/past confirmed data.

## 4. D01 — Chính sách nhãn

Event/Sequence layer v0.1 được phép công bố:

- `PS-LIKE`;
- `SC-LIKE`;
- `AUTOMATIC-RALLY-LIKE`;
- `LOWER-ST-LIKE`;
- `PSY-LIKE`;
- `BC-LIKE`;
- `AUTOMATIC-REACTION-LIKE`;
- `UPPER-ST-LIKE`;
- `LOWER STOPPING SEQUENCE-LIKE`;
- `UPPER STOPPING SEQUENCE-LIKE`.

Không công bố trực tiếp:

- `ACCUMULATION`;
- `DISTRIBUTION`;
- `REACCUMULATION`;
- `REDISTRIBUTION`;
- `PHASE A COMPLETE` theo nghĩa canonical Wyckoff.

Lý do: cùng một upper stopping sequence có thể dẫn đến Distribution hoặc Reaccumulation; cùng một lower stopping sequence có thể dẫn đến Accumulation hoặc Redistribution tùy bối cảnh lớn hơn.

## 5. D02 — Sequence dùng confirmed pivots làm xương sống cấu trúc

Các điểm PS/SC/AR/ST và PSY/BC/AR/ST không được chọn từ mọi thanh tùy ý.

V0.1 dùng confirmed point-in-time pivots của Structure/Location:

- lower structural point → confirmed Pivot Low;
- upper structural point → confirmed Pivot High.

Tọa độ phải mang cả:

- ExtremeBarIndex/DateTime;
- ConfirmBarIndex/DateTime;
- ConfirmationLag.

Sequence event chỉ được công bố khi các pivot cần thiết đã được xác nhận tại thời điểm hiện tại.

## 6. D03 — Lower Climax Seed cho SC-LIKE

Một confirmed Pivot Low có thể trở thành `LowerClimaxSeed` khi tại **extreme bar** của pivot đó có:

```text
WE_ER_ClimacticEffortCode == 2
AND WE_ER_DownsidePressureObserved == 1
```

Không yêu cầu `StoppingVolumeCode==2` vì SC có thể đóng ở nhiều vị trí khác nhau. `StoppingVolume`, Absorption, ClosePosition và RVOL/RSpread được snapshot như quality evidence.

`LowerClimaxSeed` chưa phải SC-LIKE được công bố.

## 7. D04 — Upper Climax Seed cho BC-LIKE

Một confirmed Pivot High có thể trở thành `UpperClimaxSeed` khi tại extreme bar có:

```text
WE_ER_ClimacticEffortCode == 2
AND WE_ER_UpsidePressureObserved == 1
```

Không yêu cầu weak close hoặc Absorption làm hard gate. Các trường này chỉ là quality evidence.

`UpperClimaxSeed` chưa phải BC-LIKE được công bố.

## 8. D05 — Terminal-extreme contract trước khi xác nhận climax

Một LowerClimaxSeed chỉ còn đủ điều kiện để được xác nhận là SC-LIKE nếu từ extreme của seed đến extreme của Automatic Rally tương lai **không xuất hiện Low thấp hơn seed Low**.

Nếu Low thấp hơn xuất hiện trước khi Automatic Rally được xác nhận:

- seed cũ không được nâng thành SC-LIKE;
- nếu low mới tạo một LowerClimaxSeed mới, seed mới thay thế candidate;
- seed cũ vẫn được giữ như historical climactic/stopping observation và có thể trở thành PS-like context nếu thỏa điều kiện riêng.

Đối xứng phía trên: UpperClimaxSeed chỉ còn đủ điều kiện BC-LIKE nếu trước Automatic Reaction không xuất hiện High cao hơn seed High.

Mục tiêu: tránh gọi một climax quá sớm khi xu hướng vẫn tạo cực trị mới trước counter-swing thực sự.

## 9. D06 — Automatic Rally là counter-swing, không phải k+1

Sau một LowerClimaxSeed còn hợp lệ, `AUTOMATIC-RALLY-LIKE` được xác định bởi **confirmed Pivot High đầu tiên có extreme sau SC seed** và thỏa terminal-extreme contract D05.

Không đặt `MaxBarsAfterSC`.

Không yêu cầu một ngưỡng ATR cứng để gọi AR, vì tài liệu mô tả AR là counter-swing tự động/sharp rally nhưng không đưa ra ngưỡng định lượng cố định.

Phải xuất descriptor:

- AR excursion = `ARHigh - SCLow`;
- AR excursion / SC PriorATR nếu hợp lệ;
- AR excursion / SC raw spread nếu hợp lệ;
- Bars SC extreme → AR extreme;
- Bars SC confirmation → AR confirmation.

## 10. D07 — Automatic Reaction là counter-swing phía trên

Sau UpperClimaxSeed còn hợp lệ, `AUTOMATIC-REACTION-LIKE` là **confirmed Pivot Low đầu tiên có extreme sau BC seed** và thỏa D05 phía trên.

Không đặt timeout hoặc minimum ATR hard gate.

Xuất:

- reaction excursion = `BCHigh - ARLow`;
- excursion / BC PriorATR;
- excursion / BC spread;
- thời gian giữa các extreme/confirmation.

## 11. D08 — SC/BC chỉ được nâng cấp khi AR tương ứng được xác nhận

Đây là quy tắc nhân quả trung tâm.

Tại thời điểm climax bar k, hệ thống chỉ có `LowerClimaxSeed` hoặc `UpperClimaxSeed`.

Khi Automatic Rally/Reaction được xác nhận tại thời điểm t>k:

- lower seed được nâng thành `SC-LIKE`;
- upper seed được nâng thành `BC-LIKE`;
- Sequence Engine phát sự kiện xác nhận tại t và mang tọa độ climax origin k.

Không backfill `SC-LIKE/BC-LIKE` về thanh k như thể nhãn đã biết tại k.

## 12. D09 — Provisional range được hình thành bởi Climax + Automatic counter-swing

Khi lower pair SC-like + Automatic Rally-like xác nhận:

```text
LowerBoundary = SCLow
UpperBoundary = ARHigh
```

Khi upper pair BC-like + Automatic Reaction-like xác nhận:

```text
UpperBoundary = BCHigh
LowerBoundary = ARLow
```

Đây là **provisional structural range**, không phải tuyên bố Accumulation/Distribution.

RangeWidth phải hữu hạn và >0; nếu không, pair không hợp lệ về cấu trúc.

## 13. D10 — PS-LIKE là preliminary action được nhận diện theo chuỗi, không gán tức thời

PS có thể không xuất hiện rõ. Vì vậy PS-LIKE là optional.

Khi SC-LIKE được xác nhận, Sequence Engine tìm **confirmed Pivot Low gần nhất trước SC** thỏa toàn bộ:

```text
PS ExtremeBarIndex < SC ExtremeBarIndex
PS Low > SC Low
DownsidePressureObserved at PS extreme == 1
AND (
    WE_ER_ElevatedExpansionObservation == 1
    OR WE_ER_StoppingVolumeCode == 2
)
```

Đồng thời phải tồn tại ít nhất một confirmed Pivot High có extreme nằm giữa PS extreme và SC extreme để chứng minh đã có một pause/bounce trước khi decline tiếp tục tới SC.

Nếu nhiều candidate thỏa, dùng candidate gần SC nhất và xuất `EligiblePSCount` để giữ thông tin số lượng.

PS-LIKE chỉ được công bố tại thời điểm SC/AR pair đã xác nhận; không backfill nhãn PS về quá khứ.

## 14. D11 — PSY-LIKE phía trên

Khi BC-LIKE được xác nhận, tìm confirmed Pivot High gần nhất trước BC thỏa:

```text
PSY ExtremeBarIndex < BC ExtremeBarIndex
PSY High < BC High
UpsidePressureObserved at PSY extreme == 1
AND WE_ER_ElevatedExpansionObservation == 1
```

Phải có ít nhất một confirmed Pivot Low có extreme giữa PSY và BC để chứng minh đã có pullback/pause rồi advance tiếp tới BC.

Nếu nhiều candidate thỏa, dùng candidate gần BC nhất và xuất `EligiblePSYCount`.

PSY-LIKE là optional; không có PSY không làm hỏng BC/AR/ST sequence.

## 15. D12 — Không yêu cầu PS/PSY để xác nhận SC/BC

Đây là quy tắc bắt buộc.

- `PS-LIKE` absent không làm SC-like invalid.
- `PSY-LIKE` absent không làm BC-like invalid.

Nguồn Wyckoff mô tả PS là sự kiện có thể không luôn xuất hiện rõ và Phase A có biến thể không climactic. Sequence Engine không được ép dữ liệu vào schematic lý tưởng.

## 16. D13 — ST là pivot test sau Automatic counter-swing

Lower ST candidate phải là một confirmed Pivot Low có extreme **sau AR extreme**.

Upper ST candidate phải là một confirmed Pivot High có extreme **sau Automatic Reaction extreme**.

Không dùng một thanh đơn k+1 làm ST.

Việc pivot đã được confirmed chính là bằng chứng rằng candidate tạo local reaction/turning point mà không cần nhìn trước ngoài confirmation lag đã khóa của Structure Engine.

## 17. D14 — Vùng SC/BC được định nghĩa bằng chính climax bar, không bằng ATR tolerance tùy ý

Để tránh tạo `0.5 ATR`, `1 ATR` hoặc percentage tolerance không có nguồn, v0.1 dùng **full price range của climax bar** làm “climax area”.

Lower ST enters SC area khi:

```text
STLow <= SCHigh
```

Điều này bao gồm:

- ST dừng trong range của SC bar;
- ST tại SC low;
- ST undercut xuống dưới SC low.

Upper ST enters BC area khi:

```text
STHigh >= BCLow
```

Điều này bao gồm ST dưới/ở/trên BC high nếu nó đã quay lại price area của climax bar.

Các pivot không quay lại climax-bar area chỉ được xuất là `SAME-SIDE RETEST PIVOT OBSERVATION`, chưa gọi ST-LIKE.

## 18. D15 — Không dùng SC Low/BC High làm hard rejection của ST

Lower ST relation code:

- 1 = `ABOVE SC LOW`;
- 2 = `AT SC LOW`;
- 3 = `BELOW SC LOW`.

Upper ST relation code:

- 1 = `BELOW BC HIGH`;
- 2 = `AT BC HIGH`;
- 3 = `ABOVE BC HIGH`.

Cả ba relation đều có thể là ST-LIKE về mặt Action–Test nếu D13–D14 thỏa.

Undercut/overthrow chỉ là structural descriptor. Spring/Shakeout hoặc Upthrust classification thuộc Event/Phase Engine khác.

## 19. D16 — ST identity tách khỏi ST quality

`ST-LIKE` trả lời câu hỏi **“giá đã quay lại test vùng climax hay chưa?”**.

`STQuality` trả lời câu hỏi **“effort tại test đã giảm chưa?”**.

Không dùng volume/spread giảm làm hard gate của ST identity vì nguồn nghiên cứu cho thấy có ST đầu tiên vẫn có volume cao, hàm ý supply/demand còn đáng kể và cần thêm test sau đó.

## 20. D17 — Lower ST quality: kiểm tra sự suy giảm supply evidence

Khi Lower ST-LIKE được xác nhận, so với SC extreme:

```text
VolumeContractedVsSC = RVOL_ST < RVOL_SC
SpreadContractedVsSC = RSpread_ST < RSpread_SC
```

QualityCode đề xuất:

- 0 = `INSUFFICIENT QUALITY DATA`;
- 1 = `SUPPLY NOT CLEARLY DIMINISHED`;
- 2 = `MIXED TEST QUALITY`;
- 3 = `DIMINISHED SUPPLY EVIDENCE`.

Code3 khi cả RVOL và RSpread cùng thấp hơn SC.

Một ST Low dưới SC Low vẫn có thể QualityCode=3; giá relation và effort quality là hai chiều độc lập.

## 21. D18 — Upper ST quality: kiểm tra sự suy giảm demand evidence

So với BC extreme:

```text
VolumeContractedVsBC = RVOL_ST < RVOL_BC
SpreadContractedVsBC = RSpread_ST < RSpread_BC
```

QualityCode:

- 0 = insufficient;
- 1 = `DEMAND NOT CLEARLY DIMINISHED`;
- 2 = mixed;
- 3 = `DIMINISHED DEMAND EVIDENCE`.

Không dùng quality này để tự kết luận Distribution; Reaccumulation cũng có thể khởi đầu từ BC/AR sequence tương tự.

## 22. D19 — Nhiều ST được phép trên cùng một sequence anchor

Một SC/AR pair hoặc BC/AR pair có thể có nhiều ST.

Mỗi ST phải có:

- `STOrdinal` = 1,2,3,...;
- event key riêng;
- frozen SC/BC + AR anchor coordinates;
- price relation và quality riêng.

Không có cờ “đã có ST thì cấm ST khác”.

## 23. D20 — Sequence completion morphology

`LOWER STOPPING SEQUENCE-LIKE` được coi là morphology-complete khi:

```text
SC-LIKE confirmed
AND AUTOMATIC-RALLY-LIKE confirmed
AND có ít nhất 1 LOWER-ST-LIKE
```

PS-LIKE không bắt buộc.

`UPPER STOPPING SEQUENCE-LIKE` complete khi:

```text
BC-LIKE confirmed
AND AUTOMATIC-REACTION-LIKE confirmed
AND có ít nhất 1 UPPER-ST-LIKE
```

PSY-LIKE không bắt buộc.

Tên `morphology-complete` **không đồng nghĩa Phase A canonical complete**.

## 24. D21 — Không hard-code prior trend trong v0.1

Canonical PS/SC yêu cầu prior down-move; PSY/BC yêu cầu prior up-move. Dự án chưa có Trend Engine được phê duyệt.

Do đó v0.1:

- không tự tạo MA slope/filter;
- không đếm N thanh tăng/giảm như trend oracle;
- không dùng S/M/L position làm trend substitute;
- dùng hậu tố `-LIKE` cho toàn bộ structural labels;
- snapshot S/M/L location, prior pivots và directional context để Phase Engine dùng sau.

Sau khi Trend/Phase Engine tồn tại, nó có thể nâng `LOWER STOPPING SEQUENCE-LIKE` thành candidate Phase A của Accumulation/Redistribution tùy prior trend, và upper sequence thành Distribution/Reaccumulation candidate.

## 25. D22 — Non-climactic termination là out-of-scope hợp lệ

Nguồn Wyckoff ghi nhận uptrend có thể kết thúc mà không có climactic action rõ, bằng narrowing spread/volume và giảm upward progress.

Nếu không có UpperClimaxSeed, v0.1 không được ép một pivot thành BC.

Tương tự, các lower trend endings không thỏa Climactic seed không được ép thành SC.

Kết quả là `NO CLIMACTIC STOPPING SEQUENCE` chứ không phải lỗi dữ liệu nếu input hợp lệ.

Non-climactic Phase-A morphology sẽ là module/version tương lai.

## 26. D23 — Supersession của climax candidate trước AR

Trước khi AR pair xác nhận:

### Lower side

Nếu xuất hiện LowerClimaxSeed mới có Low thấp hơn candidate hiện tại, candidate mới thay thế candidate cũ.

### Upper side

Nếu xuất hiện UpperClimaxSeed mới có High cao hơn candidate hiện tại, candidate mới thay thế.

Không xóa historical seed cũ. Candidate replacement chỉ ảnh hưởng sequence đang hình thành.

Không dùng timeout theo số thanh.

## 27. D24 — Supersession của active sequence sau khi pair đã xác nhận

Sau khi SC/AR hoặc BC/AR pair được xác nhận, anchor đó vẫn là historical sequence object và có thể nhận nhiều ST.

Một stopping sequence cùng phía mới hơn chỉ trở thành anchor mặc định cho **future ST candidates** khi pair climax + automatic counter-swing mới đã được xác nhận đầy đủ.

Không sửa các ST đã gắn với anchor cũ.

## 28. D25 — Lower và Upper sequence là hai state machine độc lập

Không dùng một `SequenceSide` duy nhất khiến sự kiện phía này xóa phía kia.

Có thể tồn tại historical lower sequence và upper sequence chồng thời gian trên các cấu trúc dài.

Composite/Phase Engine chịu trách nhiệm quyết định cấu trúc nào đang chi phối.

## 29. D26 — Data validity tách theo từng bước

Không có một `AllSequenceInputsValid` chung.

- thiếu Climactic data → climax seed insufficient;
- thiếu pivot confirmation → sequence chờ, không phải reject;
- thiếu RVOL/RSpread tại ST → ST identity vẫn có thể được đánh giá từ price/pivot, nhưng STQuality=0;
- thiếu PS evidence → PS absent/insufficient tùy dependency, không làm SC/AR/ST mất;
- thiếu prior trend engine → canonical phase unavailable, nhưng structural sequence vẫn chạy.

## 30. D27 — Event-time và origin-time phải tách biệt

Mỗi nhãn có ít nhất hai lớp thời gian:

- `OriginExtremeBarIndex/DateTime`: nơi hiện tượng giá xảy ra;
- `KnownAtBarIndex/DateTime`: khi đủ confirmation để hệ thống được phép công bố nhãn.

Ví dụ SC-like origin ở climax low nhưng chỉ KnownAt khi Automatic Rally được xác nhận.

Không được vẽ/ghi lịch sử theo kiểu làm người dùng tưởng SC đã được biết ở origin.

## 31. D28 — Event keys

Đề xuất:

### Lower sequence

```text
Symbol
+ SCExtremeBarIndex
+ SCConfirmBarIndex
+ ARExtremeBarIndex
+ ARConfirmBarIndex
```

### Lower ST

```text
LowerSequenceKey
+ STExtremeBarIndex
+ STConfirmBarIndex
```

Upper side tương tự với BC/Automatic Reaction.

PS/PSY coordinates là optional fields trong sequence snapshot, không dùng để thay đổi primary key.

## 32. D29 — Snapshot bất biến

Khi pair SC/AR hoặc BC/AR được xác nhận, snapshot tối thiểu phải đóng băng:

- climax OHLC;
- climax RVOL/RSpread/ClosePosition/DirectionalProgress và validity;
- Stopping/Absorption/Climactic quality flags;
- climax pivot extreme/confirm coordinates;
- automatic swing extreme/confirm coordinates và prices;
- provisional range boundaries/width;
- optional PS/PSY coordinates và evidence;
- S/M/L context tại climax và automatic swing nếu xuất.

ST sau này phải tham chiếu snapshot frozen này, không lấy pivot/event mới để thay anchor lịch sử.

## 33. D30 — Quan hệ với Spring/Shakeout và Upthrust

Structural Sequence không tự phân loại:

- ST below SC thành Spring;
- ST above BC thành Upthrust.

Nếu các Event Engine tương ứng tồn tại, Phase Engine sau này có thể liên kết cùng tọa độ để nâng interpretation.

Một event có thể đồng thời là `ST-LIKE` trong sequence test và `SPRING-LIKE`/`UPTHRUST-LIKE` trong Event layer nếu mỗi engine thỏa hợp đồng riêng. Không ưu tiên/ghi đè.

## 34. D31 — Không suy ra Accumulation/Distribution từ completed sequence

Sau `SC/AR/ST-like`, chỉ được nói:

`LOWER STOPPING SEQUENCE-LIKE OBSERVED`.

Sau `BC/AR/ST-like`, chỉ:

`UPPER STOPPING SEQUENCE-LIKE OBSERVED`.

Không được nói “đang tích lũy” hoặc “đang phân phối”.

Phase Engine phải kết hợp prior trend, evolution inside range, tests, strength/weakness, Spring/UTAD/SOS/SOW/LPS/LPSY và các evidence khác.

## 35. D32 — Thanh hoàn tất, nhân quả và không giao dịch

Phạm vi hiện tại: Daily completed bars.

- thanh cuối chưa được nguồn xác nhận hoàn tất chỉ provisional;
- không dùng BarCount để giả định thanh đã đóng;
- chỉ dùng current/past confirmed data;
- source revision phải phân biệt với algorithmic repaint;
- không backfill nhãn;
- không tạo Buy/Sell/Short/Cover/PositionSize/stop/target/probability score.

## 36. Đầu ra tối thiểu

### Lower sequence

- LowerClimaxSeedCode/coordinates;
- PSLikeCode/coordinates/evidence/count;
- SCLikeCode + SC origin/known-at coordinates;
- AutomaticRallyLikeCode + pivot coordinates;
- provisional lower/upper boundary + width;
- LowerSTLikeCode/ordinal/coordinates;
- STRelationToSCLow;
- STVolume/Spread contraction flags + quality;
- LowerStoppingSequenceMorphologyCode;
- active/superseded sequence identifiers.

### Upper sequence

- UpperClimaxSeedCode/coordinates;
- PSYLikeCode/coordinates/evidence/count;
- BCLikeCode + BC origin/known-at coordinates;
- AutomaticReactionLikeCode + pivot coordinates;
- provisional boundaries;
- UpperSTLikeCode/ordinal/coordinates;
- STRelationToBCHigh;
- STVolume/Spread contraction flags + quality;
- UpperStoppingSequenceMorphologyCode;
- active/superseded identifiers.

## 37. Phản ví dụ bắt buộc

1. Climactic down bar chưa có Automatic Rally confirmed → chỉ LowerClimaxSeed, chưa SC-like.
2. Climactic up bar chưa có Automatic Reaction → chỉ UpperClimaxSeed, chưa BC-like.
3. Lower seed xuất hiện rồi Low mới thấp hơn trước AR → seed cũ không được xác nhận SC-like.
4. Upper seed xuất hiện rồi High mới cao hơn trước AR → seed cũ không được xác nhận BC-like.
5. SC seed có AR nhưng không có PS trước đó → SC/AR vẫn hợp lệ, PS absent.
6. BC seed có AR nhưng không có PSY → BC/AR vẫn hợp lệ.
7. Counter move chỉ 1 thanh nhưng chưa thành confirmed pivot → chưa Automatic Rally/Reaction.
8. First confirmed pivot High sau SC → AR-like; không cần arbitrary ATR threshold.
9. Pivot Low sau AR nhưng chưa quay lại SC bar area (`Low > SCHigh`) → same-side pivot observation, chưa ST-like.
10. ST Low trong SC range và thấp hơn SC Low → vẫn ST-like; relation=BELOW SC LOW.
11. ST High vào BC area và cao hơn BC High → vẫn có thể ST-like; relation=ABOVE BC HIGH.
12. ST volume/spread thấp hơn SC → diminished supply evidence.
13. ST volume cao hơn SC → vẫn ST-like nhưng quality không tốt.
14. ST thiếu RVOL nhưng pivot/price đủ → ST identity có thể có; quality insufficient.
15. Nhiều ST vào cùng SC area → STOrdinal tăng, không ghi đè.
16. New lower sequence hoàn chỉnh xuất hiện → future ST gắn anchor mới; historical ST cũ không đổi.
17. Upper stopping sequence sau uptrend có thể là Reaccumulation hoặc Distribution → Sequence Engine không chọn một trong hai.
18. Lower stopping sequence trong larger downtrend có thể trở thành Redistribution → không tự gọi Accumulation.
19. Uptrend kết thúc bằng volume/spread cạn dần, không có climactic seed → không ép BC.
20. ST undercut trùng Spring-like → giữ cả hai kênh nếu mỗi engine thỏa hợp đồng.
21. ST overthrow trùng Upthrust-like → giữ cả hai.
22. Forming bar thay đổi pivot/event evidence → chỉ provisional, không được coi completed sequence.

## 38. Bảng quyết định cần chủ dự án phê duyệt

| Mã | Đề xuất | Khuyến nghị |
|---|---|---|
| D01 | Structural labels dùng hậu tố `-LIKE`; không gọi phase canonical | Chấp thuận mạnh |
| D02 | Confirmed pivots làm xương sống sequence | Chấp thuận mạnh |
| D03 | SC seed = Climactic Effort + downside pressure tại confirmed Pivot Low | Chấp thuận |
| D04 | BC seed = Climactic Effort + upside pressure tại confirmed Pivot High | Chấp thuận |
| D05 | Climax seed phải là terminal extreme trước automatic counter-swing | Chấp thuận mạnh |
| D06 | Automatic Rally = first confirmed Pivot High sau SC seed, không k+1/timeout | Chấp thuận mạnh |
| D07 | Automatic Reaction = first confirmed Pivot Low sau BC seed | Chấp thuận mạnh |
| D08 | SC/BC chỉ nâng nhãn khi AR tương ứng đã confirmed | Chấp thuận mạnh |
| D09 | SC+AR / BC+AR tạo provisional range | Chấp thuận mạnh |
| D10 | PS optional, nhận diện retrospectively-without-backfill từ prior structural evidence | Chấp thuận |
| D11 | PSY optional theo cấu trúc đối xứng | Chấp thuận |
| D12 | PS/PSY không phải gate SC/BC | Chấp thuận mạnh |
| D13 | ST dùng confirmed same-side pivot sau AR | Chấp thuận mạnh |
| D14 | Climax area = full range của SC/BC bar; không ATR tolerance | Chấp thuận |
| D15 | ST có thể above/at/below SC hoặc below/at/above BC | Chấp thuận mạnh |
| D16 | ST identity tách khỏi effort quality | Chấp thuận mạnh |
| D17 | Lower ST quality so RVOL/RSpread với SC | Chấp thuận mạnh |
| D18 | Upper ST quality so RVOL/RSpread với BC | Chấp thuận mạnh |
| D19 | Cho phép nhiều ST | Chấp thuận mạnh |
| D20 | Morphology complete = Climax+AR+ít nhất 1 ST; preliminary optional | Chấp thuận |
| D21 | Không hard-code prior trend khi chưa có Trend Engine | Chấp thuận mạnh |
| D22 | Non-climactic termination out-of-scope hợp lệ | Chấp thuận mạnh |
| D23 | Climax candidate supersession theo extreme mới, không timeout | Chấp thuận |
| D24 | Sequence mới chỉ supersede future anchor sau khi pair mới complete | Chấp thuận |
| D25 | Lower/Upper state machine độc lập | Chấp thuận mạnh |
| D26 | Validity tách theo bước | Chấp thuận mạnh |
| D27 | Origin-time tách KnownAt-time; tuyệt đối không backfill | Chấp thuận mạnh |
| D28 | Event key ổn định theo climax+AR pivot coordinates | Chấp thuận |
| D29 | Frozen snapshot cho mọi ST | Chấp thuận mạnh |
| D30 | Spring/Upthrust có thể overlap ST, không ghi đè | Chấp thuận mạnh |
| D31 | Completed sequence không tự suy ra Accumulation/Distribution | Chấp thuận mạnh |
| D32 | Daily completed-bar, causal, no trading | Chấp thuận mạnh |

## 39. Điều kiện chuyển sang triển khai

Chỉ sau khi chủ dự án phê duyệt D01–D32 mới:

1. đổi trạng thái đặc tả sang ĐÃ KHÓA;
2. merge đặc tả vào `main` làm source-of-truth;
3. tạo nhánh AFL phát triển xếp chồng trên Stopping/Climactic/Absorption implementation hiện hành;
4. AFL Sequence phải include đúng upstream Event module, không tính lại measurement;
5. do chiến lược hiện tại vẫn hoãn kiểm thử, mã sau triển khai chỉ được gọi `SPEC-ALIGNED / UNTESTED DEVELOPMENT`;
6. sau Structural Sequence mới nghiên cứu Phase/Context Engine để phân biệt Accumulation/Distribution/Reaccumulation/Redistribution và Phase A–E.
