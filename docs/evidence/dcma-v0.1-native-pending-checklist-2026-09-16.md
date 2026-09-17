# DCMA v0.1 — Native Pending Checklist — 2026-09-16

Trang thai: `NATIVE PENDING / DO NOT REPUBLISH DAILY YET`

## Thu tu bat buoc

1. Cai canonical source tu implementation branch.
2. Regenerate Phase/Composite runtime bang `BUILD_WVRC_PHASE_COMPOSITE_RUNTIME_STACK_v0.2.2.ps1`.
3. Regenerate Scanner runtime bang `BUILD_WVRC_SCANNER_RUNTIME_STACK_v0.2.4.ps1`.
4. Verify Syntax entrypoint regression va cac consumer/publisher lien quan.
5. Truoc moi republish, chay `WyckoffVSA_ContextMultiplicity_Regression_v0.1.afl` de doc old Daily Snapshot lam oracle.
6. Xac minh old Daily/W/M/Selection/Historical payload fail closed voi contract moi.
7. Chi sau do moi republish W, M, Selection, roi Daily mot lan theo test plan.

## First native artifact

`afl/WyckoffVSA_ContextMultiplicity_Regression_v0.1.afl`

Probe la read-only doi voi old Daily Snapshot: khong goi `StaticVarSet` cho namespace snapshot va khong thay oracle.

## Gate

Khong duoc ghi `DAILY_CONTEXT_MULTIPLICITY_ACTIVE_SEMANTICS_V01 = PASS` truoc khi DCMA-A01..A07 va persisted-contract native gate deu dat.