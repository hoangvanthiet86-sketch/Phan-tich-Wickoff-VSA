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

## Quy tắc phân loại nền tảng

1. Không được dùng heuristic dựa trên hình dạng ticker/prefix/suffix để xác định loại chứng khoán.
2. Ưu tiên metadata/category sẵn có trong database AmiBroker: Market, Group, Sector, Industry và Full Name để kiểm tra cấu trúc phân loại hiện hữu.
3. Chỉ khi metadata hiện hữu chứng minh được ranh giới cổ phiếu so với CW/futures/index/ETF mới được tự động hóa việc tạo watchlist.
4. Nếu metadata không đủ phân biệt một loại tài sản, phải fail-closed: không tự động đưa mã mơ hồ vào `VN STOCKS ONLY`.
5. Không sửa methodology, không sửa scanner decision surface và không thay đổi kết quả phân tích của Runtime v0.2.

## U1 — Metadata Audit: native evidence 2026-09-13

Probe: `WyckoffVSA_VNStocksOnly_MetadataAudit_v0.2.afl`

Native export được kiểm tra toàn bộ 2.297 symbols. Kết quả category thực tế của database:

- `Market=UPCOM, Group=Co phieu`: 953
- `Market=HSX, Group=Co phieu`: 433
- `Market=HNX, Group=Co phieu`: 401
- `Market=HSX, Group=Chung quyen`: 287
- `Market=HNX, Group=Phai sinh`: 16
- `Market=CHI SO, Group=Chi so Viet Nam`: 207

Tổng cộng: 2.297 symbols.

Điểm quan trọng của U1: `Group=Co phieu` một mình KHÔNG đủ để tạo stock-only universe.

Trong nhóm `Co phieu` có 112 symbols có `SectorID=0`:

- 94 symbols HNX có `FullName` rỗng và không có Sector/Industry đủ để xác nhận là cổ phiếu thường;
- 12 symbols HSX có `FullName` chỉ rõ là quỹ/ETF (`QUY`/`Quy`) và phải loại;
- 6 symbols thực tế là cổ phiếu nhưng Sector chưa được gán: `GTX`, `KAI`, `LPS`, `SLD`, `ULG`, `V68`.

Không sử dụng hình dạng ticker của bất kỳ nhóm nào trong logic phân loại.

## U2 — Classification Contract đã khóa

Một symbol được đưa vào `VN STOCKS ONLY` khi và chỉ khi thỏa tất cả điều kiện sau:

1. `MarketID` thuộc `{1,2,3}` tương ứng `UPCOM`, `HSX`, `HNX`;
2. `GroupID == 1` và `GroupName == Co phieu` theo database hiện tại;
3. metadata cổ phiếu được xác nhận theo một trong hai nhánh:
   - `SectorID > 0`; hoặc
   - `SectorID == 0`, `FullName` không rỗng, và `FullName` KHÔNG chứa từ `QUY` sau khi chuẩn hóa uppercase.

Fail-closed exclusions:

- Market ngoài UPCOM/HSX/HNX;
- Group khác `Co phieu`;
- `SectorID == 0` và `FullName` rỗng;
- `SectorID == 0` và `FullName` cho thấy đây là quỹ/ETF qua từ `QUY`.

Contract này không dùng prefix/suffix/ticker length/pattern.

Áp contract vào native export U1 cho kết quả dự kiến:

- `VN STOCKS ONLY`: 1.681 symbols
  - UPCOM: 953
  - HSX: 421
  - HNX: 307
- Excluded: 616 symbols
  - chỉ số / market ngoài stock markets: 207
  - group không phải `Co phieu` (CW + futures): 303
  - quỹ/ETF xác định bằng metadata FullName: 12
  - metadata mơ hồ fail-closed (`SectorID=0`, `FullName` rỗng): 94

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
- không có CW/futures/index/ETF trong watchlist;
- không có mã cổ phiếu HOSE/HNX/UPCoM bị loại sai do ticker heuristic;
- không dùng ticker pattern;
- metadata/classification rule có thể lặp lại;
- U3 audit cho zero mismatch;
- FastScanner chỉ đọc snapshot hợp lệ và giữ nguyên decision surface.

Không được gọi `VN STOCKS ONLY = PASS` trước khi có bằng chứng native U3-U4.
