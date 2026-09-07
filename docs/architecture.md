# Kiến trúc

Dự án được tổ chức thành các layer để measurement không bị trộn với interpretation.

## v1.0 — Measurement Engine (đã triển khai)

- RVOL
- RSpread
- Close Position
- Directional Progress
- Effort vs Directional Result

Năm dimension được xuất riêng; không có composite score và không có trading signal.

## Future roadmap (chưa triển khai)

- VSA Candidate Engine
- Structure / Location Engine
- Confirmation Engine
- Wyckoff Event Engine
- Sequence Engine
- Multi-Timeframe Engine
- Market Scanner

Các tên trên chỉ mô tả roadmap. Không có logic của các module tương lai trong Core Engine v1.0; mỗi layer cần specification và human review riêng trước khi triển khai.
