# Historical Scanner v0.1 — H2C Terminal Comparison Test Plan

## Muc tieu

Doi chieu terminal-date historical reconstruction voi persisted Daily Snapshot production tren cung control symbol, khong dung production snapshot lam historical source.

AFL:
`afl/WyckoffVSA_HistoricalMTFTerminalComparison_v0.1.afl`

## Cau hinh native

- Apply to: `SNZ`
- Periodicity: `Daily`
- Range: From-To phai bao gom ngay snapshot production; voi checkpoint hien tai can bao gom 11/09/2026.
- Khong can chay lai DailyPublisher.
- B1/B2 historical W/M timeline da ghi thanh cong va duoc giu nguyen.

AFL se tu tim `BusinessDateKey` cua persisted Daily Snapshot va chi loc dong Daily co cung ngay. Neu khong co ngay do trong range/history dang nap, phai fail closed.

## Acceptance

### H2C-N01 — Snapshot san sang
`Daily Snapshot san sang = Co`.

### H2C-N02 — Ngay terminal ton tai
`Co ngay snapshot trong lich su = Co` va ngay Daily dang doi chieu trung BusinessDateKey cua snapshot.

### H2C-N03 — Historical MTF contract
`Historical MTF contract hop le = Co` tai terminal date.

### H2C-N04 — Daily categorical exact match
Tat ca phai `Co`:
- `Khop so vung`
- `Khop pha`
- `Khop gia thuyet`
- `Khop huong`
- `Khop bang chung`

### H2C-N05 — MTF exact match
Tat ca phai `Co`:
- `Khop MTF contract`
- `Khop MTF huong`
- `Khop MTF bang chung`
- `Khop MTF quan he pha`

### H2C-N06 — Terminal overall
`Trang thai doi chieu terminal = Khop hoan toan terminal`.

### H2C-N07 — No historical leakage
Production snapshot chi duoc doc o lop terminal oracle. Toan bo historical W/M selection va Daily causal calculation van den tu H2B reconstruction.

### H2C-N08 — UI
Cac cot va status do H2C them vao dung tieng Viet khong dau. Global legacy runtime diagnostic columns/Parameters van duoc xu ly trong presentation cleanup rieng; khong duoc coi la final Historical Scanner UI acceptance.

## Checkpoint khi dat

`HISTORICAL_SCANNER_V01_H2C_TERMINAL_EQUIVALENCE = PASS`

Sau H2C moi tiep tuc H3 Historical Market/Group context adapter.
