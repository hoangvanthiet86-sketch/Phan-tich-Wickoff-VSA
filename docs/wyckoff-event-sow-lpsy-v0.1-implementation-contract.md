# Wyckoff VSA SOW / LPSY v0.1 — Hợp đồng triển khai

**Trạng thái:** `SPEC-ALIGNED / UNTESTED DEVELOPMENT`.

## Mốc chuẩn

- Đặc tả D01–D31 đã được chủ dự án phê duyệt và khóa tại PR #23.
- Merge commit của PR #23: `7670532a230eb051cf5d362be092e2d81283fb92`.
- Tệp đặc tả trên `main`: `docs/wyckoff-event-sow-lpsy-v0.1-spec-draft.md`. Hậu tố `draft` chỉ là tên vật lý còn lại sau quy trình review; trạng thái logic đã được khóa qua PR #23.
- Upstream trực tiếp: `afl/WyckoffVSA_StructuralSequence_PhaseA_Snapshot_v0.1.afl` trên nhánh PR #21.
- AFL triển khai: `afl/WyckoffVSA_RangeContext_SOWLPSY_v0.1.afl`.

## Vị trí kiến trúc

`Core → Candidate → Structure/Location → Confirmation → Event → Structural Sequence → Range-Context Event (SOW/LPSY) → Phase/Context`

Mô-đun không tính lại Structural Sequence và không triển khai logic Phase/Context.

## Hai kênh range độc lập

Mô-đun duy trì hai channel riêng:

- `L` — lower-sequence-derived range: `SC Low ↔ Automatic Rally High`;
- `U` — upper-sequence-derived range: `Automatic Reaction Low ↔ BC High`.

Mỗi channel dùng frozen snapshot gồm `SequenceOrdinal`, climax extreme, automatic-swing extreme, `RangeLow`, `RangeHigh`, `RangeWidth`. Cùng một thanh có thể phát SOW-LIKE trên cả hai channel; không có cơ chế winner-takes-all.

## Hợp đồng SOW-LIKE

Price Challenge tại thanh k chỉ cần dữ liệu giá/range hợp lệ và:

```text
PreviousClose >= RangeLow
Low <= RangeLow
Close < PreviousClose
```

SOW-LIKE chỉ được nâng khi thêm:

```text
RSpread >= 1.20
RVOL >= 1.25
```

Price Challenge và SOW classification có validity riêng. Effort thiếu không làm mất price observation đã hợp lệ.

Các trường bắt buộc được công bố cho từng channel:

- Range validity và side code;
- Price Challenge observation;
- `SOWCode` 0/1/2;
- support relation, accepted breakdown, support-challenge-only;
- SOW ordinal trong range;
- SOW BI/DT, OHLC, PreviousClose;
- frozen range key constituents và boundaries;
- RVOL/RSpread, ClosePosition, DirectionalProgress, AbsDirectionalProgress, Effort/Result;
- Stopping Volume/Absorption và S/M/L context;
- immediate response tại k+1: FurtherWeakness, SupportStillLost, RecoveredSupport;
- active SOW anchor và BarsSinceSOW.

SOW mới cùng RangeAnchorKey thay active SOW cho **future** LPSY nhưng không sửa sự kiện lịch sử.

## Hợp đồng LPSY-LIKE

LPSY chỉ KnownAt tại confirmation bar của một confirmed Pivot High. Identity yêu cầu:

```text
PivotHighExtremeBI > SOWBarIndex
PivotHighPrice > SOWClose
PivotHighPrice < FrozenRangeHigh
```

Nếu `PivotHighPrice >= FrozenRangeHigh`, không tạo LPSY-LIKE mà phát `UpperRangeChallengeAfterSOW` observation.

LPSY identity không yêu cầu No Demand, low RVOL hay narrow spread. Các trường quality/evidence gồm:

- NarrowSpread `<0.80` và VeryNarrow `<0.60`;
- RVOL/RSpread contraction so với frozen SOW;
- ClosePosition, DirectionalProgress, Effort/Result tại pivot extreme;
- NoDemandCandidate tại extreme;
- CE NoDemand confirmation khớp extreme;
- số NoDemand confirmed nằm trong rally SOW→LPSY;
- Upthrust overlap tại extreme;
- high-effort/poor-result descriptor;
- categorical `LPSYEvidenceClass` 0..4, không phải weighted score.

Evidence class:

- 0 `INSUFFICIENT QUALITY DATA`;
- 1 `STRUCTURAL LPSY ONLY`;
- 2 `DIMINISHED-DEMAND COMPATIBLE`;
- 3 `HIGH-EFFORT / POOR-RESULT COMPATIBLE`;
- 4 `MIXED WEAK-RALLY EVIDENCE`.

Class 2 dùng CE No Demand confirmed tại extreme hoặc NarrowSpread + RVOL contraction. Class 3 dùng high-effort band cùng Core Effort/Directional Result code `HIGH EFFORT / LOW DIRECTIONAL RESULT`. Các bằng chứng weak-rally khác hoặc hai route đồng thời đi vào Class 4.

## Event key contract

Không tạo hash tổng hợp có nguy cơ collision. Downstream phải coi key là tuple bất biến:

```text
RangeAnchorKey = Symbol + SideCode + SequenceOrdinal + ClimaxExtremeBI + AutomaticSwingExtremeBI
SOWEventKey    = RangeAnchorKey + SOWBarIndex + SOWDateTime
LPSYEventKey   = SOWEventKey + LPSYExtremeBI + LPSYConfirmBI
```

AFL công bố toàn bộ constituent fields để Phase/Context ghép key mà không phải tái suy luận.

## Quy tắc nhân quả

- Không Zig/Peak/Trough nhìn tương lai.
- Không backfill SOW hoặc LPSY label.
- SOW KnownAt tại chính completed bar k.
- LPSY KnownAt tại pivot confirmation bar, origin giữ riêng tại pivot extreme.
- Forming bar là provisional.
- Source revision có thể thay lịch sử nguồn và phải được phân biệt với algorithmic repaint.

## D38 và Phase/Context

Hợp đồng này cung cấp interface riêng mà Phase/Context v0.1 cần cho nhánh weakness. Phase Engine không được viết lại SOW/LPSY bên trong chính nó.

Khi static conformance của PR triển khai được đóng, implementation contract được coi là **ổn định ở cấp source/interface**, đủ để mở nhánh phát triển Phase/Context theo D38. Điều này không có nghĩa SOW/LPSY đã nghiệm thu AmiBroker/native.

## Kiểm thử

Theo quyết định build-first hiện tại, Verify Syntax AmiBroker 6.20.01, fixture/expected, regression, causality/append, source-revision và forming-bar audit được hoãn đến chiến dịch kiểm thử tổng thể.
