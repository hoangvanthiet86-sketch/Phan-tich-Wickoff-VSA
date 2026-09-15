# Wyckoff VSA — VN STOCKS ONLY Operational Universe v0.2

## Mục tiêu

Khóa universe vận hành cho Performance Runtime v0.2 trước khi nghiệm thu cuối.

Watchlist chuẩn phải có tên chính xác:

`VN STOCKS ONLY`

Universe này chỉ gồm cổ phiếu thường giao dịch trên HOSE/HSX, HNX và UPCoM.

Bắt buộc loại khỏi universe:
- chứng quyền có bảo đảm (CW);
- hợp đồng phái sinh/futures;
- chỉ số;
- ETF/quỹ giao dịch/quỹ niêm yết;
- các mã không đủ metadata để xác nhận là cổ phiếu thường.

## Quy tắc phân loại nền tảng

1. Không được dùng heuristic dựa trên hình dạng ticker/prefix/suffix/độ dài ticker để xác định loại chứng khoán.
2. Ưu tiên metadata/category sẵn có trong database AmiBroker: Market, Group, Sector, Industry và Full Name.
3. Chỉ khi metadata hiện hữu chứng minh được ranh giới cổ phiếu so với CW/futures/index/ETF/quỹ mới được tự động hóa việc tạo watchlist.
4. Nếu metadata không đủ xác nhận một symbol là cổ phiếu thường, phải fail-closed: không tự động đưa symbol đó vào `VN STOCKS ONLY`.
5. Không sửa methodology, không sửa scanner decision surface và không thay đổi kết quả phân tích của Runtime v0.2.

## U1 — Metadata Audit: native evidence 2026-09-13

Probe: `WyckoffVSA_VNStocksOnly_MetadataAudit_v0.2.afl`

Native export được kiểm tra toàn bộ 2.297 symbols. Category thực tế của database:

- `Market=UPCOM, Group=Co phieu`: 953
- `Market=HSX, Group=Co phieu`: 433
- `Market=HNX, Group=Co phieu`: 401
- `Market=HSX, Group=Chung quyen`: 287
- `Market=HNX, Group=Phai sinh`: 16
- `Market=CHI SO, Group=Chi so Viet Nam`: 207

Tổng cộng: 2.297 symbols.

### Phát hiện quan trọng

`Group=Co phieu` một mình KHÔNG đủ để tạo stock-only universe.

Trong 1.787 symbols thuộc `Group=Co phieu` ở UPCOM/HSX/HNX:

- có 25 quỹ/ETF/REIT; metadata `FullName` của cả 25 bắt đầu bằng `Quy ` / `QUY `;
- có 94 symbols HNX có `FullName` rỗng và `SectorID=0`, nên metadata không đủ xác nhận là cổ phiếu thường và phải fail-closed;
- có cổ phiếu thực sự nhưng `SectorID=0`, ví dụ `GTX`, `KAI`, `LPS`, `SLD`, `ULG`, `V68`, do đó không được dùng điều kiện `SectorID > 0` làm tiêu chí bắt buộc.

Cũng không được tìm chuỗi `QUY` ở bất kỳ vị trí nào trong FullName. Làm vậy có thể loại sai doanh nghiệp có tên chứa từ/chuỗi này, ví dụ các tên liên quan `Ngo Quyen`, `Ac quy`, `Da quy`, `Quy Nhon`, hoặc công ty quản lý quỹ. Ranh giới native đã xác minh là **FullName bắt đầu bằng `QUY `**, không phải ticker pattern và không phải substring tùy ý.

## U2 — Classification Contract đã khóa

Một symbol được đưa vào `VN STOCKS ONLY` khi và chỉ khi thỏa **tất cả** điều kiện sau:

1. `MarketID` thuộc `{1,2,3}` tương ứng `UPCOM`, `HSX`, `HNX`;
2. `GroupID == 1` và `GroupName == Co phieu` trong database hiện tại;
3. `FullName` không rỗng;
4. sau khi chuẩn hóa `FullName` sang uppercase, **4 ký tự đầu KHÔNG phải `QUY `**.

`SectorID`, `IndustryID` vẫn được giữ làm metadata kiểm tra/provenance nhưng không được dùng làm điều kiện bắt buộc để một cổ phiếu được vào universe, vì native evidence có cổ phiếu thực sự với `SectorID=0`.

### Fail-closed exclusions

- Market ngoài UPCOM/HSX/HNX;
- Group khác `Co phieu`;
- `FullName` rỗng;
- `FullName` bắt đầu bằng `Quy ` / `QUY `, xác định quỹ/ETF/REIT theo metadata mô tả trong database.

Contract này không sử dụng prefix/suffix/độ dài/pattern của ticker.

### Kết quả dự kiến khi áp U2 vào native export U1

`VN STOCKS ONLY` = **1.668 symbols**:

- UPCOM: 953
- HSX: 408
- HNX: 307

Excluded = **629 symbols**:

- chỉ số / Market ngoài stock markets: 207
- Group không phải `Co phieu` (CW + futures): 303
- quỹ/ETF/REIT xác định từ FullName bắt đầu `QUY `: 25
- metadata mơ hồ fail-closed (`FullName` rỗng): 94

Kiểm tra tổng: `1668 + 629 = 2297`.

## U3 — Watchlist Build

Builder: `WyckoffVSA_VNStocksOnly_WatchlistBuilder_v0.2.afl`

Builder phải:

- tạo hoặc tìm watchlist có tên chính xác `VN STOCKS ONLY`;
- khi chạy trên `All quotations`, add symbol nếu đạt U2 contract;
- remove symbol nếu không đạt U2 contract;
- không sửa Market/Group/Sector/Industry của database;
- không chạy Wyckoff/VSA analytical engines.

Audit sau build: `WyckoffVSA_VNStocksOnly_WatchlistAudit_v0.2.afl`.

Audit chỉ PASS khi membership thực tế của `VN STOCKS ONLY` khớp hoàn toàn U2 contract trên toàn database. Mọi mismatch phải được xuất ra Exploration để điều tra; zero-row mismatch mới đạt U3.

## U4 — Native Operational Run

Sau khi U3 đạt, chạy:

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
- không có CW/futures/index/ETF/quỹ trong watchlist;
- không có cổ phiếu HOSE/HSX, HNX, UPCoM bị loại sai do ticker heuristic;
- không dùng ticker pattern;
- metadata/classification rule có thể lặp lại;
- U3 audit cho zero mismatch;
- FastScanner chỉ đọc snapshot hợp lệ và giữ nguyên decision surface.

Không được gọi `VN STOCKS ONLY = PASS` trước khi có bằng chứng native U3-U4.
