# Structural Sequence v0.1 — Kiểm toán phù hợp tĩnh D01–D32

**Kết luận:** `STATIC SPEC CONFORMANCE = PASS` trong phạm vi đọc mã nguồn. Đây **không** phải nghiệm thu AmiBroker/runtime.

## Phạm vi kiểm toán

Đối chiếu:

- đặc tả đã khóa tại PR #20 / merge `e3a2c342c435aa2fd905fff4ae7ea14d060dafcf`;
- `afl/WyckoffVSA_StructuralSequence_PhaseA_v0.1.afl`;
- `afl/WyckoffVSA_StructuralSequence_PhaseA_Snapshot_v0.1.afl`;
- hợp đồng triển khai và hồ sơ rà soát trên PR #21.

## Ma trận D01–D32

| Quyết định | Trạng thái tĩnh | Bằng chứng triển khai chính |
|---|---|---|
| D01 | PASS | Chỉ phát nhãn `-LIKE`; không gán phase canonical. |
| D02 | PASS | Chỉ dùng `SL_PivotLow/HighEventCode==2` và tọa độ pivot confirmed. |
| D03 | PASS | LowerClimaxSeed = Climactic Effort + downside pressure tại pivot-low extreme. |
| D04 | PASS | UpperClimaxSeed = Climactic Effort + upside pressure tại pivot-high extreme. |
| D05 | PASS | Quét Low/High từ seed extreme đến counter-swing extreme để giữ terminal-extreme contract. |
| D06 | PASS | Automatic Rally là first confirmed Pivot High sau lower seed; không timeout/ATR gate. |
| D07 | PASS | Automatic Reaction là first confirmed Pivot Low sau upper seed. |
| D08 | PASS | SC/BC chỉ phát tại confirmation bar của counter-swing; origin và KnownAt tách riêng. |
| D09 | PASS | Pair tạo frozen provisional range `SC Low↔AR High` / `Reaction Low↔BC High`. |
| D10 | PASS | PS optional, tìm prior confirmed Pivot Low gần nhất có evidence + pause trung gian. |
| D11 | PASS | PSY optional theo đối xứng phía trên. |
| D12 | PASS | Không có PS/PSY vẫn không chặn pair SC/AR hoặc BC/Reaction. |
| D13 | PASS | ST chỉ từ confirmed same-side pivot sau automatic swing. |
| D14 | PASS | Lower ST gate `STLow<=SCHigh`; Upper ST gate `STHigh>=BCLow`. |
| D15 | PASS | Above/At/Below SC low và Below/At/Above BC high chỉ là relation code. |
| D16 | PASS | ST identity tách khỏi RVOL/RSpread quality. |
| D17 | PASS | Lower ST quality so RVOL/RSpread ST với SC. |
| D18 | PASS | Upper ST quality so RVOL/RSpread ST với BC. |
| D19 | PASS | ST ordinal tăng; không có cờ chặn ST thứ hai trở đi. |
| D20 | PASS | Morphology code chuyển thành observed sau ST đầu tiên. |
| D21 | PASS | Không có MA/trend counter làm hard gate. |
| D22 | PASS | Không có climactic seed thì không ép SC/BC. |
| D23 | PASS | Seed candidate chỉ supersede bởi climax seed có extreme mạnh hơn; không timeout. |
| D24 | PASS | Pair mới chỉ thay active future-ST anchor sau khi pair confirmed. |
| D25 | PASS | Lower và Upper state machine độc lập. |
| D26 | PASS | Validity chia theo bước; ST identity không phụ thuộc quality validity. |
| D27 | PASS | `OriginExtreme*` và `KnownAt*` tách biệt; không backfill nhãn. |
| D28 | PASS | Sequence ordinal + climax/automatic pivot coordinates; ST mang anchor coordinates. |
| D29 | PASS | Facade D29 xuất frozen OHLC, measurement+validity, quality evidence, PS/PSY evidence, S/M/L context, active snapshot và ST anchor snapshot. |
| D30 | PASS | Không chuyển ST undercut/overthrow thành Spring/Upthrust trong Sequence Engine. |
| D31 | PASS | Không xuất Accumulation/Distribution/Reaccumulation/Redistribution. |
| D32 | PASS | Không Buy/Sell/Short/Cover/PositionSize; không Zig/Peak/Trough; thiết kế current/past confirmed. |

## Kiểm toán D29 chi tiết

D29 trước đây còn thiếu output-completeness. Phần bổ sung `WyckoffVSA_StructuralSequence_PhaseA_Snapshot_v0.1.afl` hiện cung cấp:

1. **Climax snapshot:** OHLC, RVOL, RSpread, ClosePosition, DirectionalProgress và validity.
2. **Quality/context:** ClimacticDirection, StoppingVolume, Absorption, pressure, ElevatedExpansion, UltraEffort.
3. **Automatic swing:** OHLC và S/M/L context tại AR/Reaction extreme.
4. **PS/PSY:** tọa độ từ state machine gốc và evidence dùng để lựa chọn candidate.
5. **Frozen active snapshot:** sequence ordinal, climax anchor, automatic-swing anchor, provisional range, quality và context được carry forward sau KnownAt.
6. **ST anchor snapshot:** tại mỗi ST event, snapshot của climax/PS-PSY anchor được materialize trước/đúng thứ tự supersession để không bị pair mới cùng thanh ghi đè lịch sử.

## Kiểm tra ranh giới kiến trúc

- Facade D29 chỉ `#include_once` state-machine AFL rồi materialize snapshot; không tính lại rolling RVOL/RSpread/ATR/pivot.
- Không có logic giao dịch.
- Không có phân loại phase canonical.
- Không dùng Zig/Peak/Trough hoặc API nhìn tương lai.
- Không sửa các event upstream.

## Những gì chưa được kiểm chứng

`STATIC SPEC CONFORMANCE = PASS` không chứng minh các nội dung sau:

- AmiBroker 6.20.01 Verify Syntax;
- semantics runtime của array/scalar assignment trong toàn bộ stateful loop;
- fixture/expected cho từng D01–D32;
- hồi quy upstream;
- causality prefix / append stability;
- forming-bar/provisional behavior;
- hiệu năng nested scan PS/PSY và snapshot mapping trên lịch sử dài.

Các mục này tiếp tục được hoãn theo quyết định build-first hiện tại và phải được chạy trong chiến dịch kiểm thử tổng thể trước nghiệm thu/merge vào chuỗi production.

**STATIC SPEC CONFORMANCE = PASS**
