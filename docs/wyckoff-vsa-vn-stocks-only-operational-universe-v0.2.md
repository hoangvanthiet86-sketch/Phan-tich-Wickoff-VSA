# Wyckoff VSA — VN STOCKS ONLY Operational Universe v0.2

## Mục tiêu

Khóa universe vận hành cho Performance Runtime v0.2 trước khi nghiệm thu cuối.

Watchlist chuẩn phải có tên chính xác:

`VN STOCKS ONLY`

Universe này chỉ gồm cổ phiếu niêm yết/giao dịch trên HOSE, HNX và UPCoM.

Bắt buộc loại khỏi universe:
- chứng quyền có bảo đảm (CW);
- hợp đồng phái sinh/futures;
- chỉ số;
- ETF/quỹ giao dịch;
- các mã không phải cổ phiếu thường dù có dữ liệu giá.

## Quy tắc phân loại

1. Không được dùng heuristic dựa trên hình dạng ticker/prefix/suffix để xác định loại chứng khoán.
2. Ưu tiên metadata/category sẵn có trong database AmiBroker: Market, Group, Sector, Industry và Full Name để kiểm tra cấu trúc phân loại hiện hữu.
3. Chỉ khi metadata hiện hữu chứng minh được ranh giới cổ phiếu so với CW/futures/index/ETF mới được tự động hóa việc tạo watchlist.
4. Nếu metadata không đủ phân biệt một loại tài sản, phải fail-closed: không tự động đưa mã mơ hồ vào `VN STOCKS ONLY`.
5. Không sửa methodology, không sửa scanner decision surface và không thay đổi kết quả phân tích của Runtime v0.2.

## Trình tự nghiệm thu

### U1 — Metadata Audit
Chạy probe `WyckoffVSA_VNStocksOnly_MetadataAudit_v0.2.afl` trên cùng database/universe đang dùng cho benchmark.

Probe chỉ xuất metadata nhận diện:
- Symbol;
- Full Name;
- Market ID / Market Name;
- Group ID / Group Name;
- Sector ID / Sector Name;
- Industry ID / Industry Name;
- ngày dữ liệu gần nhất.

Mục đích của U1 là xác định database hiện tại có đủ metadata để tách chính xác cổ phiếu HOSE/HNX/UPCoM khỏi CW/futures/index/ETF hay không.

### U2 — Classification Contract
Sau khi xem kết quả U1, lập bảng ánh xạ category/metadata được phép dùng để xác định cổ phiếu. Không được suy ra bằng ticker pattern.

### U3 — Watchlist Build
Tạo/đồng bộ watchlist `VN STOCKS ONLY` chỉ từ classification contract đã xác minh.

### U4 — Native Operational Run
Chạy:
`DailyPublisher -> FastScanner`
trên đúng `VN STOCKS ONLY`, cùng ngày dữ liệu, cùng cấu hình Runtime v0.2.

Ghi nhận:
- số mã trong watchlist;
- số mã snapshot hợp lệ;
- số mã Data Eligible;
- phân bố Candidate Class / Stage;
- thời gian Analysis thực tế của DailyPublisher;
- thời gian Analysis thực tế của FastScanner.

## Tiêu chí PASS

Universe chỉ được gọi PASS khi:
- không có CW/futures/index/ETF trong watchlist;
- không có mã cổ phiếu HOSE/HNX/UPCoM bị loại sai do quy tắc heuristic;
- không dùng ticker pattern;
- metadata/classification rule có thể lặp lại;
- FastScanner chỉ đọc snapshot hợp lệ và giữ nguyên decision surface.

Không được gọi `VN STOCKS ONLY = PASS` trước khi có bằng chứng native U1-U4.
