# Phân tích Wyckoff VSA

Bộ công cụ đo lường Price và Volume cho **AmiBroker 6.20+**, viết bằng **AFL**. Phiên bản tối thiểu này cần cho `AddMultiTextColumn()` trong Exploration.

> Machine measures. Trader interprets.

Dự án không hứa hẹn lợi nhuận, không suy đoán ai đang giao dịch và không phải trading system.

## Core Engine v1.0

Engine giữ đúng năm measurement dimension độc lập:

- Relative Volume (`RVOL`)
- Relative Spread (`RSpread`)
- Close Position (`ClosePosition`)
- Directional Progress (`DirectionalProgress`)
- Effort vs Directional Result State (`EffortDirectionalResultState`)

Nền tảng toán học là **Current Observation vs Prior Reference**: current Volume được so với baseline Volume của 20 bar trước; current High-Low RawSpread được so với baseline RawSpread của 20 bar trước; current directional move được chuẩn hóa bằng ATR đã biết tại bar trước. Current bar không tham gia reference dùng để đánh giá chính nó.

File AFL cung cấp candlestick chart tối giản, selected-bar debug title tùy chọn và Exploration bar-aware để kiểm toán cả numeric state code lẫn categorical text. Không có Buy/Sell hay composite score.

## Tài liệu

- [Kiến trúc và roadmap](docs/architecture.md)
- [Phương pháp luận](docs/methodology.md)
- [Đặc tả Core Engine v1.0](docs/core-engine-v1.0-spec.md)
- [Kế hoạch kiểm thử](tests/README.md)

Các layer interpretation chỉ là roadmap tương lai và cần specification cùng human review riêng.
