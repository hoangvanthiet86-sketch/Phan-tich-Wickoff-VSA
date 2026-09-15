# Historical Scanner v0.1 — H1 Source Causality Audit

**Trang thai:** STATIC DESIGN AUDIT — DAT de sang H2A; native truncation validation van dang cho.

**Base dac ta:** PR #49 / `docs/wyckoff-vsa-historical-scanner-v0.1-spec.md`.

## 1. Muc tieu

Phan loai cac nguon ma can cho Historical Scanner v0.1 theo kha nang tai su dung tai tung thoi diem qua khu, khong dung current snapshot de gia lap lich su.

Bon nhom:

- `REUSE_CAUSAL_ARRAY`: source da co semantics array causal ro rang o static review.
- `REUSE_WITH_VALIDATION`: co nen tang array/causal nhung phai qua native truncation/alignment test.
- `HISTORICAL_ADAPTER_REQUIRED`: logic/contract co the tai su dung, implementation current-state khong the dung truc tiep.
- `PROHIBITED_CURRENT_SNAPSHOT`: cam dung lam nguon historical state.

## 2. Bang phan loai

| Module | Phan loai H1 | Ly do / rang buoc |
|---|---|---|
| `WyckoffVSA_DerivedSeriesPivotKernel_v0.1.afl` | `REUSE_CAUSAL_ARRAY` | Pivot candidate o `i-rightBars` nhung chi publish tai confirmation bar `i`; khong back-date ket qua. |
| `WyckoffVSA_StructureLocation_v1.0.afl` | `REUSE_WITH_VALIDATION` | Co confirmed-pivot/structure arrays; phai qua truncation invariance tren control dates truoc khi khoa PASS. |
| `WyckoffVSA_PhaseContext_v0.1.afl` | `REUSE_WITH_VALIDATION` | State machine chay tu bar dau den bar cuoi, co `KnownAt...`; can native truncation proof. |
| `WyckoffVSA_PhaseContext_PublicSnapshot_v0.1.afl` / facade | `REUSE_WITH_VALIDATION` | La projection cua state causal; phai kiem tra khong co scalar/current-only projection chen vao historical path. |
| `WyckoffVSA_CompositeIndicator_v0.1.afl` | `REUSE_WITH_VALIDATION` | Core projection la arrays, nhung co runtime provisional Param va Exploration presentation; historical consumer chi duoc tai su dung analytical arrays sau validation. |
| `WyckoffVSA_RelativeStrengthContext_v0.1.afl` | `REUSE_WITH_VALIDATION` | Dung `Foreign()` + derived-series confirmed pivots; can benchmark date/alignment va missing-date fail-closed validation. |
| `WyckoffVSA_MultiTimeframeContext_v0.1.afl` | `HISTORICAL_ADAPTER_REQUIRED` | Current-state aggregator; Daily dung `LastValue`, Weekly/Monthly dung scalar snapshot, public arrays lap current state. |
| `WyckoffVSA_TimeframeSnapshot_Publisher_v0.1.afl` | `HISTORICAL_ADAPTER_REQUIRED` | Contract previous calendar-completed period la authoritative reference; StaticVar publisher current implementation khong phai historical timeline. |
| `WyckoffVSA_TimeframeSnapshot_Consumer_v0.1.afl` | `PROHIBITED_CURRENT_SNAPSHOT` | Deserialize current Weekly/Monthly StaticVars; khong duoc dung cho ngay qua khu. |
| `WyckoffVSA_CrossSymbolSelectionContext_Publisher_v0.1.afl` | `PROHIBITED_CURRENT_SNAPSHOT` | Serialize `LastValue(...)` Market/Group current state vao StaticVars. |
| `WyckoffVSA_CrossSymbolSelectionContext_Consumer_v0.1.afl` + version guard | `PROHIBITED_CURRENT_SNAPSHOT` | Doc current scalar Market/Group context; khong ap nguoc vao history. |
| `WyckoffVSA_DailySnapshotConsumer_v0.2.afl` | `PROHIBITED_CURRENT_SNAPSHOT` | Snapshot-only current operational state. |
| `WyckoffVSA_FastScanner_v0.2.afl` | `PROHIBITED_CURRENT_SNAPSHOT` | Fast current snapshot consumer; khong tai dung nhu historical engine. |
| `WyckoffVSA_MarketScanner_v0.1.afl` | `HISTORICAL_ADAPTER_REQUIRED` | Chi tai su dung behavioral decision semantics; implementation current-state EOD/`LastValue` bi cam lam timeline. |
| `WyckoffVSA_OperationalClock_v0.1.afl` | `HISTORICAL_ADAPTER_REQUIRED` | Current operational as-of la last visible quotation; historical adapter can tai su dung epoch/ordinal semantics nhung phai tinh theo tung bar T. |
| `WyckoffVSA_RuntimeConfig_v0.2.afl` | `REUSE_WITH_VALIDATION` | Gia tri cau hinh co the tai su dung; user-facing Param labels phai theo chinh sach tieng Viet ASCII va khong doi default/range/step/meaning. |

## 3. Ket luan H1

### 3.1 Duoc phep tai su dung truc tiep ve semantics

Confirmed-pivot publication timing cua `DerivedSeriesPivotKernel` la nen tang causal ro rang nhat de tai su dung.

### 3.2 Can native validation truoc khi khoa causal PASS

`StructureLocation`, `PhaseContext`, `Composite` va `RelativeStrength` chua duoc gan nhan native causal PASS chi tu static review. H5 se phai co truncation/alignment controls.

### 3.3 Can adapter rieng

Ranh gio lon nhat la MTF va Market context. Current snapshot/StaticVar architecture tuyet doi khong duoc dung de backfill history.

H2 duoc tach thanh:

- **H2A:** proof calendar rollover / availability boundary;
- **H2B:** reconstruction payload Weekly/Monthly va categorical MTF sau khi H2A dat.

## 4. Chinh sach hien thi

Moi AFL proof/harness moi tu H2 tro di phai dung **tieng Viet khong dau** cho toan bo user-facing UI, bao gom `Parameters`, ten cot, status va canh bao, theo `HS14`.

## 5. Checkpoint

`HISTORICAL_SCANNER_V01_H1_STATIC_CAUSALITY_AUDIT = PASS_FOR_H2A`

Day khong phai native no-lookahead PASS va khong thay the HS03-HS09/H5 native tests.
