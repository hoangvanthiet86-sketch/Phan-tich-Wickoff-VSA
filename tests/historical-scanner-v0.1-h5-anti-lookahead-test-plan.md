# Historical Scanner v0.1 — H5 Anti-lookahead Test Plan

## Muc tieu

H5 kiem dinh cac bat bien anti-lookahead con lai sau H2/H3/H4:

- HS03: pivot chi duoc cong bo tai bar xac nhan;
- HS04: Range/Phase/Family chi duoc dung tu KnownAt boundary tro di;
- HS05/HS06: tai xac nhan W/M chi dung ky lich da hoan tat truoc T;
- HS07: truncation invariance;
- HS08: benchmark source khong den tu tuong lai;
- HS09: missing benchmark fail closed da PASS o H3 va khong rerun vo ich.

H5 khong tao trading semantics.

## Checkpoint dau vao

- H2A rollover = PASS.
- H2B historical W/M payload = PASS.
- H2C terminal MTF equivalence = PASS.
- H3 Market Context point-in-time + missing benchmark fail closed = PASS.
- H4 Single-symbol Historical Scanner = PASS.
- Integration base sau PR #53: `aa08ac53954c1c5aea659325a0bc1046f5491902`.

## H5-A — Causal publication / boundary proof

AFL:
`WyckoffVSA_HistoricalCausalityProof_v0.1.afl`

Chay:
- Apply to: `SNZ`
- Periodicity: `Daily`
- Range: `From-To`, 01/01/2019 den hien tai (hoac All quotes)
- Explore va xuat TXT.

### Semantics fail-closed bat buoc

W/M StaticVar timeline va Market StaticVar co the de lai payload carry-forward tai mot bar Daily ma payload do khong con dung previous completed calendar period, hoac benchmark khong co exact-date bar. Day khong tu dong la lookahead violation.

Bat bien can kiem la:
- payload stale / sai ngay phai bi gate tu choi;
- payload duoc chap nhan moi bat buoc dung completed-calendar / exact-date / source < T;
- khong duoc bien dong bi tu choi thanh context hop le.

Vi vay cac cot diagnostic `... bi loai` co the > 0. Cac cot `Loi ... da chap nhan` bat buoc bang 0.

Acceptance:
- co pivot dinh va pivot day da xac nhan;
- `Loi thoi diem cong bo pivot = 0`;
- `Loi pivot den tu tuong lai = 0`;
- `Loi Range KnownAt = 0`;
- `Loi Phase KnownAt = 0`;
- `Loi Family KnownAt = 0`;
- `Loi bien Tuan da chap nhan = 0`;
- `Loi bien Thang da chap nhan = 0`;
- `Loi benchmark future da chap nhan = 0`;
- `Loi benchmark sai ngay da chap nhan = 0`;
- `Trang thai H5A = Dat kiem tra causal / boundary`.

Diagnostic khong phai failure neu guard da loai dung:
- `Dong Tuan stale bi loai`;
- `Dong Thang stale bi loai`;
- `Benchmark future bi loai`;
- `Benchmark sai ngay bi loai`.

Checkpoint neu dat:
`HISTORICAL_SCANNER_V01_H5A_CAUSAL_BOUNDARY = PASS`

## H5-B — Truncation invariance

AFL:
`WyckoffVSA_HistoricalTruncationProof_v0.1.afl`

Harness doc baseline H4 da persist, sau do cat toan bo OHLCV stock sau moc T thanh Null truoc khi chay lai canonical causal runtime. Higher-timeframe payload va Market context tiep tuc dung historical namespaces da duoc H2/H3 kiem dinh.

Day la future-masked range truncation proof; no ket hop voi H1 static causality audit de loai duong current-snapshot/future-state. Khong sua database nguoi dung.

Chay tren `SNZ`, Daily, Range 01/01/2019 den hien tai. Chay 3 lan voi `1.1 Moc cat du lieu`:

1. `2019-08-30`
2. `2022-01-28`
3. `2024-06-28`

Moi lan chi xuat 1 dong tai T.

Acceptance cho tung moc:
- `So bar future da cat > 0`;
- tat ca cot `Khop ... = Co`:
  - du lieu hop le;
  - lop ung vien;
  - huong;
  - giai doan;
  - pha;
  - gia thuyet;
  - vi tri vung;
  - MTF;
  - RS;
  - can xem xet;
  - ma chan phuong phap;
- `Lop baseline = Lop sau cat`;
- `Ma chan baseline = Ma chan sau cat`;
- `Trang thai H5B = Khop baseline sau khi cat future`.

Neu ca 3 moc dat:
`HISTORICAL_SCANNER_V01_H5B_TRUNCATION_INVARIANCE = PASS`

## H5-C — Evidence reuse, khong rerun vo ich

Khong rerun H2/H3 neu H5-A khong phat hien mismatch moi.

H5 su dung lai evidence da khoa:
- H2A/H2B: completed calendar W/M, zero ordinal/date violation tren payload duoc chap nhan;
- H3-B: benchmark exact-date/source <= T tren context duoc chap nhan;
- H3-C: missing benchmark fail closed.

Neu H5-A + H5-B dat va evidence H2/H3 van hop le:

`HISTORICAL_SCANNER_V01_H5_ANTI_LOOKAHEAD = PASS`

Sau H5 moi chuyen H6 terminal/universe equivalence.

## Neu co loi

- Compile/include error: sua dependency/path truoc; Verify Formula/Verify Syntax; khong sua decision logic de ne loi.
- H5-A violation: lap mismatch report theo nhom pivot / KnownAt / W/M / benchmark truoc khi sua.
- Khong duoc danh dong stale / benchmark sai ngay da bi fail-closed la causal violation.
- H5-B mismatch: ghi ro moc T va field lech; khong noi long threshold/filter.
- Khong thay doi methodology, enum, weight, threshold hoac production scanner semantics trong H5.
