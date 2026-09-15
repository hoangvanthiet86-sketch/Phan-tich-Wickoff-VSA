# Historical Scanner v0.1 — H2C Native Evidence — 2026-09-14

## Pham vi

Control symbol: `SNZ`.
AmiBroker: 6.20.01.
H2C version: `HISTORICAL_MTF_TERMINAL_COMPARISON_V01_20260914_C`.

Muc tieu: doi chieu terminal-date historical reconstruction voi persisted Daily Snapshot production tren cung ngay 11/09/2026, trong khi production snapshot chi duoc dung lam terminal oracle.

## Ket qua native

Native output tra ve dung 1 dong SNZ tai ngay 11/09/2026.

### San sang / contract
- `Daily Snapshot san sang = Co`
- `Co ngay snapshot trong lich su = Co`
- `Historical MTF contract hop le = Co`

### Daily categorical equivalence
Tat ca deu khop:
- so vung: historical `1` = production `1`
- pha: historical `2` = production `2`
- gia thuyet: historical `1` = production `1`
- huong: historical `1` = production `1`
- bang chung: historical `0` = production `0`

### MTF categorical equivalence
Tat ca deu khop:
- MTF contract: `Co`
- MTF huong: historical `0` = production `0`
- MTF bang chung: historical `0` = production `0`
- MTF quan he pha: historical `4` = production `4`

### Overall
`Trang thai doi chieu terminal = Khop hoan toan terminal`

## Ghi chu native setup

Trong AmiBroker 6.20.01 tren moi truong native hien tai, H2C can `WyckoffVSA_HistoricalMTFPayloadProof_v0.1.afl` co san trong Standard Include Path (`Formulas\Include`). Hai loi setup/compatibility da duoc sua va native-xac nhan truoc run dat:
- Error 42: include dependency location;
- Error 17: `Sum()` thieu tham so, da thay bang `Cum()` de kiem tra ton tai ngay snapshot.

Cac sua doi nay khong thay doi methodology hoac analytical decision semantics.

## Checkpoint

`HISTORICAL_SCANNER_V01_H2C_TERMINAL_EQUIVALENCE = PASS`

H2A + H2B + H2C da du bang chung native de dong giai doan H2 va chuyen sang H3 Historical Market context proof.
