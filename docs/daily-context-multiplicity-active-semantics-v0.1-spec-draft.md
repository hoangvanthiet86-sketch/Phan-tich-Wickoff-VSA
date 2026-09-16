# Daily Context Multiplicity Active Semantics v0.1 — Spec Draft

**Trang thai:** `DRAFT / NON-NORMATIVE / NO PRODUCTION CHANGE`

## 1. Muc tieu

Tach ro hai khai niem dang bi tron trong runtime hien tai:

- `ContextPresent`: context con ton tai trong lifecycle/provenance;
- `PublicActive`: context hien dang active tren public decision surface.

Muc tieu cua correction nay la de bien `ContextMultiplicity` dung nghia **so luong public-active RangeContext**, trong khi van giu `ContextPresent` rieng cho audit/lifecycle.

Tai lieu nay chi dac ta correction nho. Khong sua code production, khong merge methodology, khong mo rong Watch/Developing/Qualified trong buoc nay.

## 2. Bang chung dau vao

Native diagnostic truoc do cho thay:

- 975 ma co `ContextMultiplicity=2` theo semantics hien tai;
- 934/975 co 2 range thuc su active;
- 38/975 chi 1 range active;
- 3/975 khong range nao active;
- 41/975 (4.21%) bi dem rong neu nhan hien thi mong muon la active ranges.

Trong tap 668 ma lien quan truc tiep den MTF=6 / Data Eligible:

- 636 co 2 range active;
- 30 chi 1 range active;
- 2 khong range nao active;
- 32/668 (4.79%) bi dem rong.

Bang chung nay chi ung ho correction Present-vs-Active. No **khong** ung ho viec noi long quy tac khi hai range deu active.

## 3. Semantics bat buoc

### DCMA-01 — ContextPresent giu nguyen

`ContextPresentLower` va `ContextPresentUpper` van la lifecycle/provenance diagnostics. Khong doi nghia, khong xoa, khong tai su dung chung nhu active flag.

### DCMA-02 — PublicActive la nguon duy nhat cho multiplicity production

`ContextMultiplicity` phai duoc tinh tu:

`PublicActiveLower + PublicActiveUpper`

voi moi thanh phan chi co gia tri 0/1.

### DCMA-03 — Gia tri hop le

`ContextMultiplicity` chi co 0, 1, 2.

- 0: khong co public-active range;
- 1: mot public-active range;
- 2: hai public-active range.

### DCMA-04 — Khong doi semantics hai-active

Neu `ContextMultiplicity=2` sau correction, production van giu chinh sach bao thu hien tai:

- `ContextAmbiguous=1`;
- khong tu chon mot lower/upper winner;
- khong tu suy ra compatible/coexisting;
- singleton Family/Directional van fail closed/mixed theo logic hien tai;
- MTF/Market Scanner downstream khong duoc noi long chi vi correction nay.

Bat ky taxonomy `compatible/coexisting/conflicting` la methodology moi va nam ngoai pham vi v0.1.

### DCMA-05 — Khong doi active lifecycle

Correction nay khong duoc tu dinh nghia lai `PublicActiveLower/Upper`. No chi doi nguon dem multiplicity tu Present sang PublicActive.

### DCMA-06 — Diagnostics song song

Output audit phai co kha nang quan sat dong thoi:

- `ContextPresentLower`;
- `ContextPresentUpper`;
- `PublicActiveLower`;
- `PublicActiveUpper`;
- `ContextMultiplicity`.

Neu 2 present / 1 active, multiplicity phai =1.
Neu 2 present / 0 active, multiplicity phai =0.

## 4. Downstream contract

### DCMA-07 — Composite

Composite chi duoc xem multiplicity ambiguous khi corrected `ContextMultiplicity==2`.

### DCMA-08 — MTF

MTF chi thay doi do corrected upstream multiplicity. Khong sua mapping code 6, comparator, threshold, weighting hay conflict rules trong correction nay.

### DCMA-09 — Market Scanner

Market Scanner khong sua Filter, Candidate Class, Watch/Developing/Qualified semantics, MethodBlockMask mapping hay scoring trong correction nay.

Moi thay doi output downstream phai duoc giai thich chi boi viec terminal/present context khong con bi dem nhu active.

## 5. Versioning / identity

### DCMA-10 — Snapshot/public payload audit

Truoc implementation phai audit xem `ContextMultiplicity` hoac cac active flags co duoc persisted trong snapshot/public contract nao hay khong.

Neu semantics cua mot persisted/public payload thay doi, phai tang schema/contract version hoac tao migration guard phu hop; khong duoc giu cung version neu consumer co the dien giai sai payload cu.

### DCMA-11 — Config identity

Khong doi RuntimeConfig fingerprint, parameter defaults, threshold hay calibration chi de thuc hien correction nay.

## 6. Acceptance bat buoc

### DCMA-A01 — 2 present / 2 active

Ky vong:
- multiplicity=2;
- ambiguity giu nguyen;
- downstream output nhu truoc correction neu tat ca field khac bang nhau.

### DCMA-A02 — 2 present / 1 active + 1 terminal

Ky vong:
- multiplicity=1;
- context terminal van thay trong diagnostics Present;
- terminal context khong duoc gay ambiguity production.

### DCMA-A03 — 2 present / 0 active

Ky vong:
- multiplicity=0;
- fail closed theo no-active semantics hien hanh;
- khong tao candidate moi.

### DCMA-A04 — Single-active regression

Tat ca case da co 1 present/1 active truoc correction phai bit-for-bit equivalent tren decision fields.

### DCMA-A05 — Two-active regression

Tat ca case 2 active phai giu nguyen multiplicity=2 va giu strict ambiguity behavior.

### DCMA-A06 — VN STOCKS ONLY native audit

Chay AmiBroker 6.20.01 tren cung snapshot/universe da khoa va bao cao:

- tong Data Eligible;
- so ma multiplicity 0/1/2 truoc va sau;
- danh sach ma thay doi multiplicity;
- Candidate Class / MTF / Review / MethodBlockMask thay doi do correction;
- xac nhan khong co thay doi ngoai population 2-present/less-than-2-active.

### DCMA-A07 — Downstream equivalence boundary

Phai co report rieng cho:

- Composite;
- MTF;
- Fast Scanner / Market Scanner.

Moi mismatch phai trace ve corrected multiplicity. Neu co mismatch khong giai thich duoc, acceptance = FAIL.

## 7. Cac dieu cam

Correction v0.1 **khong duoc**:

- chon winner giua lower/upper range;
- gop hai active range thanh mot master range;
- doi Phase/Family/Directional rules;
- noi long MTF code 6;
- doi MethodBlockMask semantics;
- nang Discovery thanh Production Watch;
- them Buy/Sell/Short/Cover;
- thay threshold de tang so ung vien.

## 8. Quan he voi Discovery / Historical Scanner

Discovery/Pre-Watch va Historical Scanner duoc dung de thu thap bang chung ve population hai-active. Chinh chung khong tao quyen sua production semantics.

Correction nay chi giai quyet mismatch Present-vs-Active da co bang chung native. Taxonomy hai-active se la spec rieng neu sau nay co du bang chung va chu du an phe duyet.

## 9. Gate

Chi khi chu du an phe duyet dac ta nay moi duoc tao implementation branch.

Checkpoint sau khi spec duoc phe duyet:

`DAILY_CONTEXT_MULTIPLICITY_ACTIVE_SEMANTICS_V01_SPEC = APPROVED`

Checkpoint implementation chi duoc dat sau full native acceptance:

`DAILY_CONTEXT_MULTIPLICITY_ACTIVE_SEMANTICS_V01 = PASS`
