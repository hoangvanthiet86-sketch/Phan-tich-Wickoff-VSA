# Daily Context Multiplicity PublicActive v0.1 — Implementation Audit

Trang thai: `SOURCE COMPLETE / NATIVE PENDING / NO PRODUCTION MERGE`

Spec normative: PR #62, `DAILY_CONTEXT_MULTIPLICITY_ACTIVE_SEMANTICS_V01_SPEC = APPROVED`.

## Thay doi source da thuc hien

### Phase/Context Consumer Facade

`WPCF_CurrentRangeContextCount` khong con dem `WPC_L_ContextPresent + WPC_U_ContextPresent`.

Semantics moi:

`WPCF_CurrentRangeContextCount = WPCF_L_PublicActive + WPCF_U_PublicActive`

Trong do PublicActive duoc lay truc tiep tu:
- `WPCP_L_RangeActivePublic`;
- `WPCP_U_RangeActivePublic`.

`ContextPresent` van duoc bao toan rieng de audit/lifecycle.

Khi count=1, ID/Phase/Family singleton phai chon dung side PublicActive. Khi count=2, ambiguity van strict va khong co winner.

### Composite

Tat ca singleton projection co nguy co chon terminal-but-present context da duoc chuyen sang active-side selector. Bao gom:
- primary range low/high/width;
- range age/position/status;
- prior trend;
- hypothesis revision/known-at;
- mixed evidence;
- current bullish/bearish evidence;
- linked event/evidence counts.

Composite cong bo dong thoi:
- `WCI_L_ContextPresent` / `WCI_U_ContextPresent`;
- `WCI_L_PublicActive` / `WCI_U_PublicActive`;
- `WCI_ContextMultiplicityCode`.

### Composite public schema

`WCI_PublicSchemaMinor` duoc tang `0 -> 1` de danh dau public multiplicity semantics moi.

### Daily Snapshot

`WDS_SchemaMinor` duoc tang `0 -> 1` va `WDS_ContractVersion` tu `0.2` -> `0.2.1`.

Muc dich: snapshot cu mang old Present-based multiplicity phai fail closed sau khi consumer code moi duoc cai, thay vi bi doc ngam nhu cung semantics.

`WDS_ConfigFingerprint` khong doi vi correction khong sua RuntimeConfig/threshold/methodology controls.

Audit Daily Publisher xac nhan old oracle dung dung cac persisted key ma regression probe doc truc tiep: `BusinessDateKey`, `ContextMultiplicity`, `CandidateClass`, `Stage`, `Review`, `MethodBlockMask`, `MTFDirectionalAlignment`, cung commit markers `Ready` va `CommittedGenerationID`. Vi vay probe co the doc snapshot cu read-only ma khong can consumer va khong republish.

### Timeframe Snapshot W/M

Publisher/Consumer da duoc version-guard theo Composite public schema 1.1 va payload PublicActive. Snapshot W/M cu khong duoc doc nhu payload semantics moi.

### Cross-Symbol Selection Context

Top-level `WXS_SchemaMajor/Minor` van 1.0 de base consumer hien huu co the deserialize va chuyen tiep cho version guard, nhung semantic contract da duoc tang:
- `ProducerContractVersion = 0.1.1`;
- `CompositeSchema = 1.1`;
- `MTFSchema = 1.1`;
- persist rieng `L_PublicActive` / `U_PublicActive` ben canh `L_ContextPresent` / `U_ContextPresent`;
- publisher bat buoc `ContextMultiplicityCode == L_PublicActive + U_PublicActive`.

`WyckoffVSA_CrossSymbolSelectionContext_ConsumerVersionGuard_v0.1.afl` yeu cau dong thoi:
- `ProducerContractVersion=0.1.1`;
- Composite schema 1.1;
- MTF schema 1.1;
- hai PublicActive flags ton tai, chi nhan 0/1 va tong cua chung bang transported multiplicity.

Selection snapshot cu co contract 0.1, Composite/MTF minor 0, hoac thieu PublicActive se fail closed voi schema/version mismatch thay vi bi dien giai ngam theo semantics moi.

### Market Scanner compatibility

Khong doi bat ky Filter/Class/threshold/MethodBlockMask rule nao.

Chi dong bo consumer voi semantics da phe duyet:
- stock Composite schema yeu cau 1.1;
- singleton range-location chon side theo `WPCP_*_RangeActivePublic`, khong theo `ContextPresent`.

Dieu nay ngan truong hop `2 Present / 1 PublicActive` bi mat singleton range-location chi vi terminal context van con lifecycle-present.

### Historical persisted transports

Historical release tag cu van bat bien. Mainline transport moi duoc version de payload cu khong bi doc ngam:
- `WVSA_HIST_MTF_v01_*`: schema minor `0 -> 1`; luu them Present/PublicActive audit fields;
- `HistoricalMTFPayloadProof`: chi chap nhan W/M historical timeline schema 1.1;
- `WVSA_HIST_STOCK_v01_*`: schema minor `0 -> 1`; singleton range chon PublicActive; luu Present/PublicActive audit fields;
- `WVSA_HIST_MKT_v01_*`: schema minor `0 -> 1`; luu Present/PublicActive audit fields;
- `HistoricalScanner`: chi chap nhan stock/market stored timeline schema 1.1.

Khong sua formula identity/checkpoint cua release `historical-scanner-v0.1.0`; tag release cu khong bi thay doi.

## Regression probe

`afl/WyckoffVSA_ContextMultiplicity_Regression_v0.1.afl`:
- khong ghi StaticVar;
- doc old Daily Snapshot truc tiep lam oracle truoc correction;
- tinh Present count va PublicActive count song song;
- bao cao CandidateClass/Stage/MTF/Review/MethodBlockMask cu va moi;
- danh dau population muc tieu `2 Present / <2 Active`;
- danh dau bat ky decision change ngoai population muc tieu la loi.

## Audit dependency runtime

Runtime Phase/Composite files la generated artifacts, khong duoc commit vao repo. Builder `BUILD_WVRC_PHASE_COMPOSITE_RUNTIME_STACK_v0.2.2.ps1` lay canonical source lam oracle va chi redirect include/config. Vi vay source correction nam o canonical files, sau do local runtime phai regenerate.

Tuong tu, MTF/Selection/Scanner Runtime files duoc tao tu canonical source boi `BUILD_WVRC_SCANNER_RUNTIME_STACK_v0.2.4.ps1`.

Khong duoc tu tao generated runtime file trong repo de ne builder.

## DCMA-10 persisted/public payload audit

`DCMA-10 SOURCE GATE = CLOSED / STATIC PASS`

Cac transport mang `ContextMultiplicityCode` da co mot trong hai co che bat buoc:
- schema/contract minor moi; hoac
- producer-sub-schema migration guard ro rang.

Payload truoc correction khong duoc consumer moi doc ngam nhu cung semantics.

Day la source/static closure, KHONG phai native PASS. Native phai xac minh old payload fail closed va republished payload 1.1/0.1.1 duoc doc dung.

## Khong thay doi

Correction nay khong:
- sua cach xac dinh `RangeActivePublic`;
- noi long hai-range-active ambiguity;
- tao compatible/coexisting taxonomy;
- sua MTF code 6 mapping;
- sua Market Scanner class/filter/threshold;
- sua MethodBlockMask bit meanings;
- sua RuntimeConfig defaults/fingerprint controls;
- tao Buy/Sell/Short/Cover.

## Native acceptance

Chua co native PASS cho implementation nay.

Cac gate con lai: DCMA-A01..A07, bao gom old-payload fail-closed, republish contract moi va VN STOCKS ONLY regression.

Checkpoint `DAILY_CONTEXT_MULTIPLICITY_ACTIVE_SEMANTICS_V01 = PASS` bi cam su dung cho den khi cac native gate tren deu dat.
