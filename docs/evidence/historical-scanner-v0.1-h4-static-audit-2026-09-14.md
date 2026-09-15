# Historical Scanner v0.1 — H4 Static Conformance Audit

Date: 2026-09-14
Base integration commit: `80b7ce56b29cfd326d540bfa7e96b4d063ee5ab7`
Branch: `feature/historical-scanner-h4-v0.1`

## Scope

Audit H4 source truoc native AmiBroker run:
- `afl/WyckoffVSA_HistoricalStockTimelinePublisher_v0.1.afl`
- `afl/WyckoffVSA_HistoricalScanner_v0.1.afl`
- `tests/historical-scanner-v0.1-h4-single-symbol-test-plan.md`

## Static result

### 1. Historical source boundaries

PASS.

H4 Scanner doc duy nhat:
- `WVSA_HIST_STOCK_v01_<SYMBOL>_*`
- `WVSA_HIST_MKT_v01_<MARKET>_*`

H4 Stock Publisher tai su dung H2 historical MTF proof, trong do W/M source da khoa la:
- `WVSA_HIST_MTF_v01_<SYMBOL>_W_*`
- `WVSA_HIST_MTF_v01_<SYMBOL>_M_*`

Khong co executable read/include cua current Daily Snapshot, current cross-symbol selection snapshot, hoac current MTF snapshot trong H4 decision adapter.

### 2. Market exact-date contract

PASS static.

H4 Scanner bat buoc dong thoi:
- source `DateNum()` == stock `DateNum()`;
- source DateTime == stock DateTime;
- source DateTime <= stock DateTime;
- H3 `SourceValid == 1`;
- market payload day du.

Khong co nearest-date/future-date substitution.

### 3. RS source contract

PASS static / cho native.

H4 Stock Publisher tai dung stock-vs-market ratio va confirmed-pivot structure semantics cua RelativeStrengthContext v0.1.

Benchmark:
`Foreign(HST_RSMarketSymbol,"C",0)`

`fixup=0` duoc dung de ngay benchmark thieu khong bi forward-fill ngam. Pivot left/right lay tu fixed Historical Runtime Defaults, khong tao threshold moi.

Price/RS relationship tai dung exact mapping canonical:
- price up + RS up -> 1;
- price up + RS down -> 2;
- price down + RS up -> 3;
- price down + RS down -> 4;
- cac cau truc con lai -> 5;
- insufficient -> 0.

### 4. Production Scanner behavioral semantics

PASS static / cho native terminal equivalence.

H4 tai dung:
- `SelectionContext`;
- `StageFromPhase`;
- production exclusion bit meanings;
- range-location coherence/conflict MS41;
- Review predicates;
- MethodBlock bit meanings;
- Watch / Developing / Qualified predicates;
- Candidate Class priority;
- Candidate Side mapping.

Full Top-Down Group duoc deferred dung spec Historical v0.1; market-only profile khong tao class 5/8.

### 5. Trading semantics

PASS.

H4 khong gan trading actions, khong ranking va khong P&L. Cac ten trading bi cam chi xuat hien trong comment/test assertion de neu ro prohibition, khong co executable assignment.

### 6. UI / HS14

PASS cho text moi cua H4.

Tat ca Param/cot/status moi la tieng Viet khong dau. Historical Scanner khong them cot Ticker/Date duplicate; dung cot mac dinh cua AmiBroker.

Luu y: H4 Stock Publisher la harness tinh toan nang ke thua H2/runtime stack nen legacy upstream co the van tao cac cot Exploration cu. Day la presentation debt upstream da biet; H4 Scanner decision output rieng duoc giu gon. Khong duoc tuyen bo final all-stack presentation acceptance cho den khi debt nay duoc xu ly.

## Native required

Static audit khong thay the native AmiBroker 6.20.01 run.

Can:
1. H4-A publish SNZ stock timeline.
2. H4-B export full SNZ historical timeline.
3. Terminal `11/09/2026` phai exact control:
   `Class=2, Side=0, Stage=1, Phase=2, Family=1, RangePosition=0.3500, MTF=0, RS=2, Review=0, MethodBlockMask=7`.

Static checkpoint:

`HISTORICAL_SCANNER_V01_H4_STATIC = PASS_FOR_NATIVE`
