# Daily Context Multiplicity PublicActive v0.1 — Implementation Audit

Trang thai: `SOURCE IMPLEMENTATION IN PROGRESS / NATIVE PENDING / NO PRODUCTION MERGE`

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

## Regression probe

`afl/WyckoffVSA_ContextMultiplicity_Regression_v0.1.afl`:
- khong ghi StaticVar;
- doc old Daily Snapshot truc tiep lam oracle truoc correction;
- tinh Present count va PublicActive count song song;
- bao cao CandidateClass/Stage/MTF/Review/MethodBlockMask cu va moi;
- danh dau population muc tieu `2 Present / <2 Active`;
- danh dau bat ky decision change ngoai population muc tieu la loi.

## Audit dependency runtime

Runtime Phase/Composite files la generated artifacts, khong duoc commit vao repo. Builder `BUILD_WVRC_PHASE_COMPOSITE_RUNTIME_STACK_v0.2.2.ps1` lay canonical source lam oracle va chi redirect include/config. Vi vay source correction phai nam o canonical files, sau do local runtime duoc regenerate.

Tuong tu, MTF/Selection/Scanner Runtime files duoc tao tu canonical source boi `BUILD_WVRC_SCANNER_RUNTIME_STACK_v0.2.4.ps1`.

Khong duoc tu tao mot generated runtime file trong repo de ne builder.

## Persisted/public payload audit con phai dong

Ngoai Daily Snapshot, `ContextMultiplicityCode` con duoc persist qua:
- Timeframe Snapshot W/M;
- Cross-Symbol Selection Context;
- Historical Market/Stock timeline.

Do DCMA-10 cam silently reuse old schema cho payload doi semantics, implementation chua duoc coi la source-complete cho toi khi cac transport nay co version/migration guard ro rang.

Historical Scanner release `historical-scanner-v0.1.0` da dong va tag release khong bi sua. Neu mainline Historical transport duoc version sau release, release tag cu van bat bien.

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

Checkpoint `DAILY_CONTEXT_MULTIPLICITY_ACTIVE_SEMANTICS_V01 = PASS` bi cam su dung cho den khi DCMA-A01..A07 va persisted-contract gates deu dat.
