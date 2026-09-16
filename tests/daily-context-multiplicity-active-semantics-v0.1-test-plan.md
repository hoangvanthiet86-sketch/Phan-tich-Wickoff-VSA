# Daily Context Multiplicity PublicActive v0.1 — Ke hoach kiem thu

Trang thai: `SOURCE COMPLETE / NATIVE PENDING`

Nguon dac ta da duoc phe duyet: PR #62, checkpoint `DAILY_CONTEXT_MULTIPLICITY_ACTIVE_SEMANTICS_V01_SPEC = APPROVED`.

## Muc tieu

Xac minh correction chi thay `ContextMultiplicity` tu dem `ContextPresent` sang dem `PublicActive`, trong khi giu nguyen lifecycle/provenance, strict ambiguity khi co hai range active, MTF rules, Market Scanner rules, thresholds va methodology.

## Dieu kien truoc native

1. Cai cac canonical source tu implementation branch vao Include.
2. Chay lai `BUILD_WVRC_PHASE_COMPOSITE_RUNTIME_STACK_v0.2.2.ps1` de tao runtime Phase/Composite tu canonical source moi.
3. Chay lai `BUILD_WVRC_SCANNER_RUNTIME_STACK_v0.2.4.ps1` de tao runtime MTF/RS/Selection/Scanner tu canonical source moi.
4. Verify Syntax cac entrypoint can dung.
5. Khong chay DailyPublisher cho den khi old Daily Snapshot da duoc dung lam oracle va full decision regression A04-A06 da hoan tat.

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

Voi moi row co Present count=1 va Active count=1, khi `Cho phep so sanh quyet dinh = 1`, cac truong quyet dinh phai khop oracle cu bit-for-bit:
- Data Eligible;
- Candidate Class;
- Stage;
- Phase;
- Family;
- Directional Context;
- MTF Directional Alignment;
- Review;
- MethodBlockMask.

## DCMA-A05 — two active strict ambiguity regression

Voi moi row co Active count=2:
- multiplicity van 2;
- ambiguity van 1;
- Family/Directional singleton van mixed/fail-closed nhu truoc;
- khong co compatible/coexisting shortcut;
- khong doi MTF code-6 mapping rules.

## DCMA-A06 — VN STOCKS ONLY universe regression

Dung cung locked as-of/oracle snapshot. Old Daily Snapshot 11/09/2026 phai van ton tai va khong duoc republish truoc gate nay.

Probe `WyckoffVSA_ContextMultiplicity_Regression_v0.1.afl` co hai che do theo readiness:
- truoc republish W/M/Selection: dung de xac minh oracle ton tai, as-of alignment, Present/PublicActive va corrected Composite multiplicity; **khong** duoc ket luan decision equivalence khi `Cho phep so sanh quyet dinh=0`;
- sau khi W/M/Selection da republish theo contract moi cung as-of, trong khi Daily oracle cu van chua bi ghi de: `Cho phep so sanh quyet dinh` phai =1, luc do moi khoa A04-A06.

Chay tren `VN STOCKS ONLY`, Daily, 1 recent bar tai locked as-of 11/09/2026.

Bao cao bat buoc:
- tong ticker;
- Data Eligible cu/moi;
- Present multiplicity distribution;
- Active multiplicity distribution;
- so ticker `2 Present / <2 Active`;
- danh sach ticker co DataEligible/Class/Stage/Phase/Family/Directional/MTF/Review/MethodBlockMask thay doi;
- `LOI thay doi ngoai tap muc tieu` phai bang 0 khi comparison enabled.

Khong duoc sua code de ep ket qua ve baseline cu neu khac biet la he qua dung cua correction da duoc phe duyet.

## DCMA-A07 — downstream report

Xac minh rieng:
- Composite;
- MTF;
- Fast Scanner;
- Market Scanner.

Moi mismatch so voi oracle cu phai truy vet duoc ve `PresentMultiplicity != ActiveMultiplicity`. Bat ky mismatch ngoai tap nay la FAIL va phai dieu tra truoc khi merge.

## DCMA-10 — persisted contract native gate

Source/static gate da dong. Native phai xac minh:
- Daily Snapshot cu schema 2.0 / contract 0.2 fail closed voi consumer moi schema 2.1 / contract 0.2.1;
- Weekly/Monthly snapshot cu schema 1.0 / contract 0.1 fail closed voi consumer moi 1.1 / 0.1.1;
- Cross-Symbol Selection snapshot cu co `ProducerContractVersion=0.1`, Composite/MTF public schema minor 0 hoac thieu `L_PublicActive/U_PublicActive` phai fail closed trong version guard;
- Cross-Symbol payload moi phai co `ProducerContractVersion=0.1.1`, Composite schema 1.1, MTF schema 1.1 va `ContextMultiplicityCode == L_PublicActive + U_PublicActive`;
- Historical W/M timeline schema 1.0 fail closed trong `HistoricalMTFPayloadProof`;
- Historical Stock/Market timeline schema 1.0 fail closed trong `HistoricalScanner`.

Sau khi xac minh fail-closed moi republish payload moi. Payload moi phai mang schema/producer guard phu hop voi PublicActive semantics.

## Thu tu native de tranh rerun nang va bao toan Daily oracle

1. Regenerate runtime stack va Verify Syntax.
2. Dat Bar Replay / locked as-of ve 11/09/2026; chay regression probe lan 1. Xac nhan `Oracle cu san sang=1`, `Oracle cung ngay=1`, va `Multiplicity dung PublicActive=1`. Decision comparison co the bi khoa vi old W/M/Selection duoc fail closed — day la mong doi.
3. Xac minh old Daily/W/M/Selection persisted payload fail closed bang consumer/diagnostic entrypoint tuong ung. Historical old-payload fail-closed co the kiem rieng, khong can republish Historical luc nay.
4. Republish Weekly snapshot **mot lan** theo contract moi tai cung replay/as-of.
5. Republish Monthly snapshot **mot lan** theo contract moi tai cung replay/as-of.
6. Republish Selection Market/Group snapshot can thiet **mot lan** theo contract moi.
7. Chay regression probe lan 2, van tai 11/09 va **chua chay DailyPublisher**. `Cho phep so sanh quyet dinh=1` tren rows co oracle; khoa A01-A06 va `LOI thay doi ngoai tap muc tieu=0`.
8. Chi sau khi regression tren dat moi chay DailyPublisher mot lan tren `VN STOCKS ONLY` de tao Daily Snapshot contract moi.
9. Chay Fast Scanner va downstream A07 tren payload moi.
10. Historical transport chi republish khi can chay regression Historical cho correction; khong rerun Historical publisher chi de xac minh source/static gate.

## Checkpoint

Chi khi A01-A07 va persisted-contract native gates deu dat moi duoc ghi:

`DAILY_CONTEXT_MULTIPLICITY_ACTIVE_SEMANTICS_V01 = PASS`
