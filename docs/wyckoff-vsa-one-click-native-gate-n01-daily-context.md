# Wyckoff VSA One-Click v0.1 — Native Gate N01: Generated Daily Context

**Mục tiêu:** kiểm tra generated helper/body compile và Daily context trước mọi thử nghiệm D/W/M.

## Điều kiện

- AmiBroker 6.20.01 Windows 32-bit.
- Nhánh local: `feature/one-click-scanner-v0.1`.
- Runtime v0.2 include stack hiện hành đã cài như các bài test trước.
- Không chạy Publisher nào cho gate này.

## Bước 1 — Build generated context

Trong PowerShell tại repo:

`powershell -ExecutionPolicy Bypass -File .\tools\BUILD_WVOC_REENTRANT_CONTEXT_STACK_v0.1.ps1`

Yêu cầu builder:
- kết thúc không lỗi;
- in `WVOC re-entrant context build complete.`;
- in SHA-256 của HELPERS và BODY;
- tạo trong AmiBroker Include:
  - `WyckoffVSA_OneClickContextHelpers_Generated_v0.1.afl`
  - `WyckoffVSA_OneClickContextBody_Generated_v0.1.afl`.

## Bước 2 — Verify Syntax

Mở:

`WyckoffVSA_OneClickContext_DailyProbe_v0.1.afl`

Verify Syntax.

Yêu cầu: không error/warning làm mất khả năng chạy.

## Bước 3 — Native Exploration control

Chạy trước trên `SNZ only`:

- Periodicity: Daily
- Range: 1 Recent Bar
- Parameters: giữ production defaults hiện hành tương đương baseline; `1.3 = Khong`.

Export kết quả `.txt`.

## Bước 4 — Điều kiện PASS sơ bộ

- đúng 1 dòng SNZ;
- `Config Valid = 1`;
- tất cả cột Composite/PublicActive có giá trị hợp lệ;
- `L PublicActive + U PublicActive == Composite Multiplicity`;
- Probe Version = `ONE_CLICK_CONTEXT_DAILY_PROBE_V01_20260918_A`.

Equivalence chi tiết sẽ đối chiếu file export với oracle canonical cùng as-of trước khi mở gate W/M.

## Stop condition

Nếu builder lỗi hoặc Verify Syntax lỗi: dừng, gửi nguyên output/error; không sửa tay generated file.

Checkpoint chỉ sau khi đối chiếu:

`ONE_CLICK_NATIVE_N01_DAILY_CONTEXT = PASS`