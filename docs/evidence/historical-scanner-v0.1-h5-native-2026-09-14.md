# Historical Scanner v0.1 — H5 Anti-lookahead Native Evidence — 2026-09-14

## Pham vi
Native AmiBroker 6.20.01 tren SNZ, Daily. H5 gom H5-A causal/boundary va H5-B truncation invariance. Khong thay methodology, threshold, enum hay decision surface.

## H5-A — Causal / boundary proof
Version: `HISTORICAL_ANTI_LOOKAHEAD_CAUSALITY_V01_20260914_B`

- Pivot dinh da xac nhan: 198
- Pivot day da xac nhan: 221
- Loi thoi diem cong bo pivot: 0
- Loi pivot den tu tuong lai: 0
- So dong mot vung: 806
- Loi Range KnownAt: 0
- Loi Phase KnownAt: 0
- Loi Family KnownAt: 0
- Dong Tuan stale bi loai: 38
- Loi bien Tuan da chap nhan: 0
- Dong Thang stale bi loai: 0
- Loi bien Thang da chap nhan: 0
- Benchmark future bi loai: 0
- Benchmark sai ngay bi loai: 2
- Loi benchmark future da chap nhan: 0
- Loi benchmark sai ngay da chap nhan: 0
- Trang thai: `Dat kiem tra causal / boundary`

Checkpoint:
`HISTORICAL_SCANNER_V01_H5A_CAUSAL_BOUNDARY = PASS`

## H5-B — Truncation invariance
Version: `HISTORICAL_TRUNCATION_PROOF_V01_20260914_A`

### Moc 1 — 2019-08-30
- Future bars cat: 1670
- Tat ca truong so sanh: `Co`
- Lop baseline / sau cat: 2 / 2
- Ma chan baseline / sau cat: 7 / 7
- Trang thai: `Khop baseline sau khi cat future`

### Moc 2 — 2022-01-28
- Future bars cat: 1068
- Tat ca truong so sanh: `Co`
- Lop baseline / sau cat: 9 / 9
- Ma chan baseline / sau cat: 319 / 319
- Trang thai: `Khop baseline sau khi cat future`

### Moc 3 — 2024-06-28
- Future bars cat: 490
- Tat ca truong so sanh: `Co`
- Lop baseline / sau cat: 9 / 9
- Ma chan baseline / sau cat: 31 / 31
- Trang thai: `Khop baseline sau khi cat future`

Checkpoint:
`HISTORICAL_SCANNER_V01_H5B_TRUNCATION_INVARIANCE = PASS`

## Tong ket H5
Khong phat hien future leakage trong cac kiem soat H5 da khoa. Payload stale / benchmark sai ngay neu xuat hien deu bi gate fail-closed; khong co truong hop nao duoc chap nhan sai. Ba moc truncation deu giu nguyen day du decision state da so sanh.

Checkpoint tong:
`HISTORICAL_SCANNER_V01_H5_ANTI_LOOKAHEAD = PASS`
