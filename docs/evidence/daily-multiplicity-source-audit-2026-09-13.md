# Daily Context Multiplicity — Source Audit 2026-09-13

**Trang thai:** `NATIVE DEEP DIAGNOSTIC COMPLETE / DESIGN REVIEW REQUIRED`

## Muc tieu

Dieu tra vi sao mot luong lon ma `MTF Directional Alignment = 6` co `Daily ContextMultiplicity = 2`, ma khong thay doi methodology va khong noi Fast Scanner/MTF truoc khi biet nguyen nhan upstream.

## Bang chung MTF da co

Diagnostic native `MTF_CODE6_DIAGNOSTIC_V01_20260913_A` tren `VN STOCKS ONLY` cho thay:

- 1,029 ma co MTF code trong Daily Snapshot = 6;
- 1,029/1,029 phep tinh lai MTF = 6;
- 1,029/1,029 doi chieu logic = khop;
- 668/1,029 ma MTF=6 co `Daily ContextMultiplicity = 2`;
- 246/1,029 ma Daily mot vung nhung directional context van mixed/conflicting;
- 115/1,029 ma Daily khong mixed, nguyen nhan code 6 den tu Weekly va/hoac Monthly.

Nhu vay 914/1,029 (88.8%) da co ambiguity/mixed state tu tang Daily truoc khi xet quan he da khung.

## Phat hien tu source

### 1. Phase/Context duy tri hai channel doc lap

`WyckoffVSA_PhaseContext_v0.1.afl` duy tri lower-derived va upper-derived `RangeContext` doc lap. Moi channel cong bo rieng `ContextPresent`, `RangeActive`, `RangeTerminal`, range boundaries, Phase, Family va diagnostics.

### 2. PublicSnapshot co khai niem active rieng

`WyckoffVSA_PhaseContext_PublicSnapshot_v0.1.afl` phan biet:

- invalidated context -> active = 0;
- Phase-E terminal context -> active = 0;
- valid non-terminal present context -> active = 1.

### 3. ConsumerFacade dem ContextPresent, khong dem PublicActive

`WyckoffVSA_PhaseContext_ConsumerFacade_v0.1.afl` hien tai dung:

`WPCF_CurrentRangeContextCount = WPC_L_ContextPresent + WPC_U_ContextPresent`

Composite sau do chuyen count > 1 thanh `ContextMultiplicityCode = 2`, context ambiguous, Family mixed/conflicting va DirectionalContext mixed/conflicting.

Do do nhan `MULTIPLE ACTIVE RANGE CONTEXTS` co the rong hon nghia public-active thuc te.

## Native deep diagnostic

### A. Watchlist builder

`WyckoffVSA_DailyMultiplicity_WatchlistBuilder_v0.1.afl` duoc chay tren `VN STOCKS ONLY` va tao watchlist `WVSA DAILY MULTI RANGE`.

Ket qua thuc te:

- 975 ma co Daily Snapshot hop le va `ContextMultiplicity = 2`;
- 975/975 da vao watchlist;
- 975/975 doi chieu membership = khop.

Con so 975 la toan bo Daily multiplicity=2. Trong checkpoint U4, 668/975 thuoc tap Data Eligible; 307/975 la Data Ineligible. Do do 668 truoc day la tap con lien quan truc tiep den Fast Scanner All Eligible / MTF=6, khong phai toan bo Daily multiplicity=2.

### B. Deep lifecycle diagnostic tren 975 ma

Output `DAILY_MULTIPLICITY_DEEP_DIAGNOSTIC_V01_20260913_B` cho thay:

- 975/975 snapshot count = 2 va live `ContextPresentCount = 2` khop nhau;
- `PublicActiveCount = 2`: 934 ma (95.79%);
- `PublicActiveCount = 1`: 38 ma (3.90%);
- `PublicActiveCount = 0`: 3 ma (0.31%);
- tong `Nghi ngo dem qua rong = Co`: 41/975 (4.21%).

Lifecycle theo channel:

- lower active: 951; lower terminal / Phase E: 24;
- upper active: 955; upper terminal / Phase E: 20;
- khong ghi nhan invalidated status trong output nay.

Trong 934 ma co ca hai range thuc su active:

- hai vung long nhau: 344 (36.83%);
- hai vung tach roi: 322 (34.48%);
- hai vung chong lan mot phan: 268 (28.69%).

## Tap con 668 ma lien quan truc tiep den MTF=6 / Data Eligible

Doi chieu 668 ma `ContextMultiplicity=2` trong Fast Scanner All Eligible / MTF diagnostic voi deep lifecycle output:

- ca hai range thuc su active: 636/668 (95.21%);
- chi mot range active: 30/668 (4.49%);
- khong range nao active: 2/668 (0.30%);
- dem qua rong theo present-vs-active: 32/668 (4.79%).

Trong 636 ma co hai range active:

- hai vung tach roi: 232 (36.48%);
- hai vung long nhau: 219 (34.43%);
- hai vung chong lan mot phan: 185 (29.09%);
- Pha B / Pha B: 263 (41.35%);
- Family `Vung duoi chua xac nhan` + `Vung tren chua xac nhan`: 487 (76.57%).

Tuoi range trong tap 636:

- lower median 51.5 bars; P90 207 bars; max 1,295 bars;
- upper median 54 bars; P90 160.5 bars; max 783 bars;
- rieng hai vung tach roi co tuoi median cao hon: lower 69 bars, upper 77.5 bars.

## Ket luan checkpoint

### Ket luan 1 — co ton tai dem rong, nhung khong phai nguyen nhan chinh

Gia thuyet source-level duoc xac nhan mot phan: 41/975 ma bi gan multiplicity=2 theo `ContextPresent` trong khi public-active count < 2. Trong tap 668 lien quan truc tiep den MTF=6 / Data Eligible, con so nay la 32/668.

Day la mismatch semantics giua nhan `MULTIPLE ACTIVE RANGE CONTEXTS` va cach dem `ContextPresent`. Neu sua multiplicity de dem public-active, mot so ma co the duoc giai phong khoi ambiguity, nhung quy mo chi khoang 4.8% cua tap 668.

### Ket luan 2 — nut that lon hon la chinh sach ambiguity cho hai range thuc su active

636/668 ma van co hai range thuc su active. Composite hien tai co chu y khong chon winner khi hai context cung ton tai, va ep singleton Family/Directional ve mixed/conflicting. MTF sau do quy dinh bat ky multiplicity ambiguous nao cung thanh Directional Alignment = 6.

Vi vay, phan lon nut that khong phai bug snapshot hay Fast Scanner. No la he qua truc tiep cua kien truc/spec: bat ky hai RangeContext cung ton tai deu duoc xem la ambiguity cung cap, bat ke hai range long nhau, overlap hay tach roi.

### Ket luan 3 — phan lon hai-range la unresolved som, khong phai hai directional hypothesis doi nghich da xac nhan

Trong 636 ma hai range active, 76.57% la cap family `Vung duoi chua xac nhan` + `Vung tren chua xac nhan`; 41.35% la Pha B/Pha B. Day cho thay nhieu truong hop ambiguity phat sinh khi engine dang bao toan hai gia thuyet range som, chu khong nhat thiet la hai huong directional da duoc xac nhan va doi nghich.

## Y nghia thiet ke

Khong duoc tu dong noi Fast Scanner hoac xoa MTF conflict. Neu muon tang tinh thuc dung, can mot design review rieng cho multiplicity semantics, toi thieu xem xet hai van de:

1. `ContextMultiplicity` co nen dem `PublicActive` thay vi `ContextPresent` de sua mismatch 41/975 hay khong;
2. voi hai range thuc su active, co can phan loai them `compatible/coexisting` (vi du nested/overlap unresolved) tach khoi `conflicting`, thay vi ep tat ca vao cung mot mixed state hay khong.

Bat ky thay doi nao o muc 2 se thay doi decision surface va phai co spec moi + acceptance/equivalence moi truoc khi sua production code.

## Bao ve pham vi

- Khong sua methodology trong diagnostic branch.
- Khong sua Fast Scanner.
- Khong sua MTF rules.
- Khong sua Candidate Class.
- Khong thay nguong.
- Khong auto-merge PR #46.
- Ket qua nay la native diagnostic checkpoint, khong phai final release acceptance.
