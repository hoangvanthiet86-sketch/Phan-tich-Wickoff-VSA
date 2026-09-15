# Daily Context Multiplicity — Design Review v0.1

**Trang thai:** `DRAFT / NON-NORMATIVE / NO PRODUCTION CHANGE`

## Ly do mo review

Native deep diagnostic cho thay `ContextMultiplicity = 2` dang gom hai van de khac nhau:

1. mot phan nho la mismatch giua `ContextPresent` va public-active lifecycle;
2. phan lon la hai RangeContext thuc su active, nhung kien truc hien tai coi moi coexistence la ambiguity/mixed.

Muc tieu tai lieu nay la tach cac lua chon thiet ke. Tai lieu KHONG sua methodology va KHONG thay doi decision surface.

## Bang chung native hien tai

Toan bo Daily multiplicity=2:

- 975 ma;
- 934 co 2 range thuc su active;
- 38 chi 1 range active;
- 3 khong range nao active;
- 41/975 (4.21%) dem rong neu y nghia mong muon la `active ranges`.

Tap con lien quan truc tiep den MTF=6 / Data Eligible:

- 668 ma;
- 636 co 2 range thuc su active;
- 30 chi 1 range active;
- 2 khong range nao active;
- 32/668 (4.79%) dem rong.

Trong 636 ma co hai range active:

- 232 range tach roi;
- 219 range long nhau;
- 185 range overlap mot phan;
- 263 Pha B / Pha B;
- 487 unresolved-lower + unresolved-upper.

## Semantics hien tai

ConsumerFacade dem:

`ContextPresentLower + ContextPresentUpper`

Composite khi count=2:

- gan `ContextAmbiguous = 1`;
- singleton Family = mixed/conflicting;
- singleton DirectionalContext = mixed/conflicting.

MTF khi bat ky timeframe co multiplicity ambiguous hoac directional mixed:

- gan `DirectionalAlignment = 6`.

Market Scanner sau do coi MTF mixed/complex la mot review trigger / method block.

Do do pipeline hien tai la co chu y bao thu: coexistence cua hai context duoc xu ly nhu ambiguity cung cap.

## Van de 1 — Present khong dong nghia Active

41/975 case native cho thay hai `ContextPresent` co the van ton tai trong khi public-active count < 2.

### Lua chon A — Sua semantics multiplicity ve PublicActive

Y tuong:

- dem `WPCP_L_RangeActivePublic + WPCP_U_RangeActivePublic` cho y nghia `ACTIVE RANGE CONTEXTS`;
- van giu diagnostics ContextPresent rieng cho audit/lifecycle.

Uu diem:

- nhan va semantics khop nhau;
- loai ambiguity gia do terminal context;
- thay doi nho, co ly do source + native ro rang.

Rui ro:

- van thay doi decision surface;
- can regression/equivalence va native acceptance rieng;
- chi giai quyet khoang 4.8% tap 668, khong giai quyet nut that lon.

## Van de 2 — Hai range active khong nhat thiet dong nghia xung dot

636/668 case lien quan truc tiep den MTF=6 co hai range active that. Tuy nhien 76.57% la cap family unresolved-lower + unresolved-upper va 41.35% la Pha B/Pha B.

Do do can phan biet:

- coexistence/ambiguity vi dang bao toan hai gia thuyet som;
- xung dot directional da co bang chung;
- hai context co quan he hinh hoc long nhau/overlap/tach roi;
- context cu/tre va lifecycle cua tung range.

### Lua chon B — Them taxonomy `compatible/coexisting` va `conflicting`

Day la thay doi methodology/decision surface lon hon.

Khong duoc tu dong quy dinh tieu chi. Neu duoc phe duyet nghien cuu, spec moi can xem xet toi thieu:

- public-active lifecycle;
- lower/upper Family da resolved hay unresolved;
- directional evidence co doi nghich that hay khong;
- geometry: nested / partial overlap / disjoint;
- current price/range relationship;
- age va supersession/invalidation history;
- Phase state cua tung context;
- MTF higher-timeframe context.

Bat ky rule nao cung phai co historical/native evidence va acceptance moi truoc production.

### Lua chon C — Giu Production strict, them Discovery / Pre-Watch rieng

Y tuong:

- Production Scanner giu nguyen `Review`/MTF semantics hien tai;
- tao mot lop Discovery rieng de surface cac ma co cau truc som nhung bi hard-review boi multiplicity/MTF;
- label ro `DISCOVERY / NOT PRODUCTION QUALIFIED`;
- khong nang Watch/Developing/Qualified hien tai;
- dung de thu thap evidence va backtest lich su truoc khi can nhac sua methodology.

Uu diem:

- khong pha equivalence cua Production Scanner;
- tang tinh thuc dung cho nguoi dung ngay;
- tao du lieu thuc nghiem de danh gia B;
- de rollback vi la lop bo sung, khong thay rules hien tai.

Rui ro:

- them mot be mat output moi;
- can spec ro de nguoi dung khong hieu Discovery la buy signal.

## De xuat trinh tu

1. **A — tach semantics Present vs Active**: mo mot correction spec nho rieng; khong sua production truoc khi acceptance duoc khoa.
2. **C — Discovery / Pre-Watch**: uu tien neu muc tieu la tim them ung vien thuc dung ma khong lam yeu Production Scanner.
3. **B — compatible vs conflicting multiplicity**: chi nghien cuu sau khi co historical evidence/backtest cua Discovery population.

## Acceptance toi thieu neu tien hanh A

- fixture cho 2 present / 2 active;
- fixture cho 2 present / 1 active + 1 terminal;
- fixture cho 2 present / 0 active;
- exact regression cho single-active contexts;
- snapshot contract versioning neu payload semantics thay doi;
- MTF and Market Scanner downstream equivalence report;
- native AmiBroker 6.20.01 test tren VN STOCKS ONLY.

## Acceptance toi thieu neu tien hanh C

- Production outputs bit-for-bit khong doi;
- Discovery label khong duoc map vao Buy/Sell;
- co ly do inclusion ro rang theo tung ma;
- co historical scanner de do forward outcomes;
- tach report Production va Discovery;
- khong dung Discovery de claim Qualified.

## Ket luan

Native evidence khong ung ho viec noi MTF mot cach truc tiep. Mismatch Present-vs-Active la co that nhung nho. Nut that lon la chinh sach hard ambiguity cho hai RangeContext thuc su active.

Huong an toan nhat ve kien truc la giu Production strict, sua semantics active/present bang correction rieng neu duoc phe duyet, va dung Discovery/Pre-Watch de thu thap bang chung truoc khi can nhac thay doi multiplicity methodology.
