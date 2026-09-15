# Historical Scanner v0.1 — H4 Native Evidence — 2026-09-14

## Moi truong
- AmiBroker 6.20.01 native.
- Control symbol: `SNZ`.
- Periodicity: Daily.
- Historical range: 01/01/2019 den 14/09/2026; du lieu thuc te xuat den 11/09/2026.

## H4-A — Stock Timeline Publisher
Native export da xac nhan:
- `Ma co phieu = SNZ`
- `So ngay stock payload hop le = 1970`
- `Trang thai ghi = Da ghi timeline co phieu`
- `Phien ban H4 publisher = HISTORICAL_STOCK_TIMELINE_PUBLISHER_V01_20260914_B`

Checkpoint:
`HISTORICAL_SCANNER_V01_H4A_STOCK_TIMELINE_PUBLISHER = PASS`

## H4-B — Single-symbol Historical Scanner
File export co 1,800 dong lich su.

Phan bo trang thai:
- 1,778/1,800: `Da phan loai point-in-time`
- 17/1,800: `Market context khong hop le / khong khop ngay` -> Data gated / fail closed
- 5/1,800: `Data gated theo production semantics`

Phan bo lop ung vien:
- Review: 1,741
- Watch: 27
- Data gated: 22
- Khong phai ung vien hien tai: 10

Kiem tra bat bien tren toan bo export:
- Data gated -> Class 0: 0 mismatch.
- Class 0 tren dong DataEligible: 0 mismatch.
- Review flag -> Class 9: 0 mismatch.
- Class 9 -> Review flag: 0 mismatch.
- 27/27 Watch deu DataEligible, khong Review, Stage 1, RS = tang/giam, range position nam trong [0,100%].
- 27/27 Watch co `MethodBlockMask = 7` trong native export nay.
- Version: 1,800/1,800 = `HISTORICAL_SCANNER_V01_H4_20260914_A`.

## Terminal SNZ — 11/09/2026
Native row:
- DataEligible = 1
- Class = 2 / Watch
- Side = 0 / unresolved
- Stage = 1 / Watch
- Phase = 2 / B
- Family = 1 / unresolved lower
- RangePosition = 35.00% = 0.3500
- MTF = 0 / insufficient
- RS = 2 / falling
- Review = 0
- MethodBlockMask = 7
- ExclusionMask = 0
- Status = `Da phan loai point-in-time`

Terminal checkpoint exact-match voi production control da khoa.

## Static semantic comparison
H4 adapter tai dung production behavioral semantics cho:
- SelectionContext
- StageFromPhase
- hard-data exclusion bits (Market-only profile)
- Review predicates
- MethodBlockMask bit meanings
- Watch / Developing / Qualified Market predicates
- Candidate Class priority
- Candidate Side

Full Top-Down Group class 5/8 duoc deferred dung Historical Scanner v0.1 spec; khong doi enum/schema.

## Pham vi chua tuyen bo
H4 PASS khong tu dong co nghia:
- H5 truncation invariance / anti-lookahead PASS;
- HS13 universe equivalence PASS;
- final Historical Scanner release acceptance.

Presentation debt con lai: mot so dong range-position khong hop le hien thi AFL Null sentinel dang so am rat lon; day la presentation-only debt, khong tham gia decision semantics va khong lam thay doi H4 native logic checkpoint. Se xu ly truoc final Historical Scanner UI acceptance, khong yeu cau rerun H4-B logic.

## Checkpoint
`HISTORICAL_SCANNER_V01_H4_SINGLE_SYMBOL_TIMELINE = PASS`
