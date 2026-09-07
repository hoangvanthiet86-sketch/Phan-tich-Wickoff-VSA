# Phương pháp luận

> Machine measures. Trader interprets.

> Current event must not contaminate the historical reference used to judge its abnormality.

Vì vậy, một outlier hiện tại không được tham gia own baseline rồi tự làm giảm abnormality đang được đo. Core Engine dùng **Current Observation vs Prior Reference** và chỉ dùng dữ liệu đã tồn tại trước current bar để tạo historical reference.

Các ranh giới kiến trúc:

1. **Context quan trọng hơn isolated signal.** Một phép đo đơn lẻ không đủ để kết luận.
2. **Volume một mình không cho biết bên nào thắng.** Volume chỉ đại diện activity/effort tương đối.
3. **Price response phải được đánh giá cùng Volume.** RSpread đo intrabar High-Low expansion/contraction; DirectionalProgress đo net close-to-close progress, gồm cả gap effect. Hai dimension được giữ riêng.
4. **Effort vs Directional Result là nguyên lý cốt lõi.** v1.0 so sánh RVOL với độ lớn Directional Progress nhưng chỉ đặt tên trạng thái thống kê.
5. **Cùng pattern ở location khác nhau có thể có ý nghĩa khác nhau.** v1.0 chưa đo structure/location.
6. **Measurement Engine không thay thế trader interpretation.** State không phải bằng chứng về nguyên nhân hay diễn biến tiếp theo.
7. **Không tạo certainty giả.** Classification threshold là calibration parameter, không phải universal truth.
8. **Core Engine v1.0 không có trading signal.** Không có entry, exit, position sizing hoặc backtest.

**Effort vs Directional Result is a measurement relationship, not the complete VSA Effort-vs-Result interpretation.** Core Engine chỉ đo `Effort = RVOL` và `Directional Result = abs(CurrentClose - PreviousClose) / PriorATR`. RSpread, ClosePosition và signed DirectionalProgress vẫn là các dimension độc lập.

Một interpretation VSA đầy đủ trong tương lai có thể cần Spread, Close, directional progress, follow-through, location và context. Interpretation đó không được triển khai trong Core Engine v1.0. `HIGH EFFORT / LOW DIRECTIONAL RESULT` chỉ mô tả quan hệ measurement và không giải thích nguyên nhân.


## Bar completion semantics

Core Engine v1.0 measurements được coi là **FINAL** cho completed bars. Trên live/incomplete bar, Volume còn partial, High/Low có thể tiếp tục mở rộng và Close chưa final; do đó RVOL, RSpread, ClosePosition, DirectionalProgress và Effort/Directional Result đều provisional. Live outputs không được coi là final categorical evidence. v1.0 không tự phát hiện market session hoặc tự loại current bar; runtime fixtures phải dùng completed bars.
