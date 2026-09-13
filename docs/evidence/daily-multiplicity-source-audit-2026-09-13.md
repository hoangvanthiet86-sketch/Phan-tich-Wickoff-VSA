# Daily Context Multiplicity — Source Audit 2026-09-13

**Trang thai:** `SOURCE AUDIT / NATIVE DEEP DIAGNOSTIC PENDING`

## Muc tieu

Dieu tra vi sao 668/1,029 ma `MTF Directional Alignment = 6` co `Daily ContextMultiplicity = 2`, ma khong thay doi methodology va khong noi Fast Scanner/MTF truoc khi biet nguyen nhan upstream.

## Bang chung da co

Diagnostic native `MTF_CODE6_DIAGNOSTIC_V01_20260913_A` tren `VN STOCKS ONLY` cho thay:

- 1,029 ma co MTF code trong Daily Snapshot = 6;
- 1,029/1,029 phep tinh lai MTF = 6;
- 1,029/1,029 doi chieu logic = khop;
- 668/1,029 ma co `Daily - so vung = Nhieu vung`;
- 246/1,029 ma Daily chi mot vung nhung directional context van mixed/conflicting;
- 115/1,029 ma Daily khong mixed, nguyen nhan code 6 den tu Weekly va/hoac Monthly.

Nhu vay 914/1,029 (88.8%) da co ambiguity/mixed state tu tang Daily truoc khi xet quan he da khung.

## Phat hien tu source

### 1. Phase/Context duy tri hai channel doc lap

`WyckoffVSA_PhaseContext_v0.1.afl` duy tri lower-derived va upper-derived `RangeContext` doc lap. Moi channel cong bo rieng:

- `ContextPresent`;
- `RangeContextID`;
- frozen range low/high/width;
- `RangeActive`;
- `RangeTerminal`;
- Phase/Family va diagnostics lien quan.

### 2. PublicSnapshot co khai niem active rieng

`WyckoffVSA_PhaseContext_PublicSnapshot_v0.1.afl` xay `WPCP_L_RangeActivePublic` va `WPCP_U_RangeActivePublic` voi lifecycle:

- invalidated context -> status 3, active = 0;
- Phase-E terminal context -> status 2, active = 0;
- valid non-terminal present context -> status 1, active = 1.

Invalidation duoc giu sticky trong cung mot `RangeContextID`.

### 3. ConsumerFacade dem ContextPresent, khong dem PublicActive

`WyckoffVSA_PhaseContext_ConsumerFacade_v0.1.afl` hien tai dung:

`WPCF_CurrentRangeContextCount = WPC_L_ContextPresent + WPC_U_ContextPresent`

Sau do Composite chuyen count > 1 thanh:

- `ContextMultiplicityCode = 2`;
- context ambiguous;
- singleton family = mixed/conflicting;
- directional context = mixed/conflicting.

Do do, ve mat source, `ContextMultiplicity = 2` hien tai co nghia **hai context van PRESENT**, chua du de chung minh **hai range deu ACTIVE theo public lifecycle**.

## Gia thuyet can kiem chung native

Co kha nang mot phan trong 668 ma bi gan `MULTIPLE ACTIVE RANGE CONTEXTS` thuc te chi co:

- 1 range dang active + 1 range terminal;
- 1 range active + 1 range invalidated;
- hoac ca hai khong con active nhung object context van present.

Neu xay ra, multiplicity/ambiguity co the dang dem rong hon y nghia nhan hien thi `multiple active ranges`.

**Day moi la gia thuyet source-level, chua duoc phep ket luan la bug cho den khi co native deep diagnostic.**

## Diagnostic da bo sung

### A. Lightweight watchlist builder

`afl/WyckoffVSA_DailyMultiplicity_WatchlistBuilder_v0.1.afl`

- chi doc Daily Snapshot;
- target: `WDSC_Valid AND WDSC_ContextMultiplicity==2`;
- tao/sync watchlist `WVSA DAILY MULTI RANGE`;
- khong chay heavy analytical stack.

### B. Deep lifecycle diagnostic

`afl/WyckoffVSA_DailyMultiplicity_DeepDiagnostic_v0.1.afl`

- chi chay tren watchlist 668 ma o tren;
- dung cung generated Phase/Context Runtime v0.2 stack voi DailyPublisher;
- khong chay DailyPublisher va khong ghi snapshot;
- tai lap rieng public active/status lifecycle bang O(N) loop de tranh full PublicSnapshot coordinate-audit loops;
- so sanh:
  - snapshot context multiplicity;
  - live `ContextPresent` count;
  - public-equivalent active count;
  - lower/upper terminal/invalid/active state;
  - geometry cua hai range neu ca hai thuc su active.

## Native checkpoint can thu

Can thong ke toi thieu tren 668 ma:

1. `PublicActiveCount = 2`;
2. `PublicActiveCount = 1`;
3. `PublicActiveCount = 0`;
4. lower/upper status phan bo active / terminal / invalidated;
5. neu ca hai active: long nhau / overlap mot phan / tach roi;
6. `SnapshotMultiplicity=2` co khop live `ContextPresentCount=2` hay khong.

Chi sau checkpoint nay moi du bang chung de quyet dinh co can sua semantics multiplicity o Phase/Composite hay khong.

## Bao ve pham vi

- Khong sua methodology.
- Khong sua Fast Scanner.
- Khong sua MTF rules.
- Khong sua Candidate Class.
- Khong thay nguong.
- Khong claim production bug truoc native evidence.
- Khong merge diagnostic vao integration neu chua duoc chu du an phe duyet.
