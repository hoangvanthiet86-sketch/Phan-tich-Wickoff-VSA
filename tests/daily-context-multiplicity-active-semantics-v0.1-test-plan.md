# Daily Context Multiplicity PublicActive v0.1 — Ke hoach kiem thu

Trang thai: `IMPLEMENTATION DRAFT / NATIVE PENDING`

Nguon dac ta da duoc phe duyet: PR #62, checkpoint `DAILY_CONTEXT_MULTIPLICITY_ACTIVE_SEMANTICS_V01_SPEC = APPROVED`.

## Muc tieu

Xac minh correction chi thay `ContextMultiplicity` tu dem `ContextPresent` sang dem `PublicActive`, trong khi giu nguyen lifecycle/provenance, strict ambiguity khi co hai range active, MTF rules, Market Scanner rules, thresholds va methodology.

## Dieu kien truoc native

1. Cai cac canonical source tu implementation branch vao Include.
2. Chay lai `BUILD_WVRC_PHASE_COMPOSITE_RUNTIME_STACK_v0.2.2.ps1` de tao runtime Phase/Composite tu canonical source moi.
3. Chay lai `BUILD_WVRC_SCANNER_RUNTIME_STACK_v0.2.4.ps1` de tao runtime MTF/RS/Selection/Scanner tu canonical source moi.
4. Verify Syntax cac entrypoint can dung.
5. Khong chay DailyPublisher cho den khi da luu oracle Daily Snapshot cu va cac persisted upstream contract da duoc version-guard dung.

## DCMA-A01 — 2 Present / 2 PublicActive

Ky vong:
- `ContextPresentLower=1`, `ContextPresentUpper=1`;
- `PublicActiveLower=1`, `PublicActiveUpper=1`;
- `ContextMultiplicity=2`;
- `ContextAmbiguous=1`;
- singleton ID/Phase/Family khong chon winner;
- MTF/Market Scanner strict ambiguity semantics khong noi long.

## DCMA-A02 — 2 Present / 1 PublicActive

Ky vong:
- Present count = 2;
- Active count = 1;
- multiplicity moi = 1;
- terminal/present context van hien trong audit;
- singleton projection chon dung public-active side;
- terminal side khong tao ambiguity.

## DCMA-A03 — 2 Present / 0 PublicActive

Ky vong:
- multiplicity moi = 0;
- khong singleton context;
- no-active fail closed;
- khong tao candidate.

## DCMA-A04 — single active regression

Voi moi row co Present count=1 va Active count=1, cac truong quyet dinh phai khop oracle cu bit-for-bit:
- Candidate Class;
- Stage;
- Phase;
- Family;
- Directional Context;
- MTF Directional Alignment;
- Review;
- MethodBlockMask;
- Data Eligible.

## DCMA-A05 — two active strict ambiguity regression

Voi moi row co Active count=2:
- multiplicity van 2;
- ambiguity van 1;
- Family/Directional singleton van mixed/fail-closed nhu truoc;
- khong co compatible/coexisting shortcut;
- khong doi MTF code-6 mapping rules.

## DCMA-A06 — VN STOCKS ONLY universe regression

Dung cung locked as-of/oracle snapshot khi co the tai lap. Chay `WyckoffVSA_ContextMultiplicity_Regression_v0.1.afl` tren `VN STOCKS ONLY`, Daily, 1 recent bar tai as-of can kiem thu.

Bao cao bat buoc:
- tong ticker;
- Data Eligible count;
- Present multiplicity distribution;
- Active multiplicity distribution;
- so ticker `2 Present / <2 Active`;
- danh sach ticker co CandidateClass thay doi;
- danh sach ticker co MTF thay doi;
- danh sach ticker co Review thay doi;
- danh sach ticker co MethodBlockMask thay doi;
- `LOI thay doi ngoai tap muc tieu` phai bang 0.

Khong duoc sua code de ep ket qua ve baseline cu neu khac biet la he qua dung cua correction da duoc phe duyet.

## DCMA-A07 — downstream report

Xac minh rieng:
- Composite;
- MTF;
- Fast Scanner;
- Market Scanner.

Moi mismatch so voi oracle cu phai truy vet duoc ve `PresentMultiplicity != ActiveMultiplicity`. Bat ky mismatch ngoai tap nay la FAIL va phai dieu tra truoc khi merge.

## Persisted contract gates

Vì multiplicity la payload duoc persist, tat ca snapshot/transport lien quan phai co version guard. Snapshot cu phai fail closed sau khi consumer code moi duoc cai. Chi republish sau khi da xac minh guard.

Thu tu operational du kien khi source/static gate dat:
1. republish Weekly snapshot;
2. republish Monthly snapshot;
3. republish Selection Market/Group snapshot can thiet;
4. chay DailyPublisher mot lan tren VN STOCKS ONLY;
5. chay Fast Scanner va regression probe.

Khong rerun publisher nang neu chua den dung gate nay.

## Checkpoint

Chi khi A01-A07 va persisted-contract gates deu dat moi duoc ghi:

`DAILY_CONTEXT_MULTIPLICITY_ACTIVE_SEMANTICS_V01 = PASS`
