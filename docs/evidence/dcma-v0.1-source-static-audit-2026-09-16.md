# DCMA v0.1 — Source/Static Audit — 2026-09-16

## Pham vi

Checkpoint nay chi khoa source/static gate cho correction `ContextMultiplicity -> PublicActive` theo PR #62. Khong phai native PASS va khong cho phep merge production truoc khi DCMA-A01..A07 dat.

## Ket qua

- Phase/Context ConsumerFacade dem `WPCP_L_RangeActivePublic + WPCP_U_RangeActivePublic`.
- `ContextPresent` van ton tai rieng cho lifecycle/provenance.
- Composite singleton projections chon dung public-active side; two-active strict ambiguity van giu nguyen.
- Composite public schema minor = 1.
- Daily Snapshot schema = 2.1, contract = 0.2.1; RuntimeConfig fingerprint khong doi.
- Daily Publisher old-oracle key audit xac nhan cac key regression probe doc deu la persisted keys: `BusinessDateKey`, `ContextMultiplicity`, `CandidateClass`, `Stage`, `Review`, `MethodBlockMask`, `MTFDirectionalAlignment`, `Ready`, `CommittedGenerationID`.
- Weekly/Monthly Timeframe Snapshot duoc versioned sang schema 1.1 / contract 0.1.1 va mang PublicActive diagnostics.
- MTF selection public schema minor = 1.
- Cross-Symbol Selection transport giu top-level schema 1.0 cho base deserializer, nhung tang `ProducerContractVersion=0.1.1`, yeu cau Composite/MTF schema 1.1, persist `L_PublicActive/U_PublicActive`, va guard tong active == multiplicity.
- Market Scanner khong doi Filter/Class/threshold/MethodBlockMask semantics; chi chon singleton range-location theo PublicActive.
- Historical mainline transports duoc versioned de schema 1.0 cu fail closed; release tag `historical-scanner-v0.1.0` khong thay doi.
- Runtime generated artifacts khong commit; native phai regenerate bang builder hien hanh.

## Bat bien

Khong co thay doi duoc phep cho:
- RangeActivePublic lifecycle;
- two-active ambiguity policy;
- MTF code 6 mapping;
- Market Scanner ranking/filter methodology;
- thresholds;
- RuntimeConfig fingerprint inputs;
- Buy/Sell/Short/Cover semantics.

## Source checkpoint

`DCMA_V01_SOURCE_STATIC = PASS_FOR_NATIVE`

Native checkpoint `DAILY_CONTEXT_MULTIPLICITY_ACTIVE_SEMANTICS_V01 = PASS` chua duoc dat.