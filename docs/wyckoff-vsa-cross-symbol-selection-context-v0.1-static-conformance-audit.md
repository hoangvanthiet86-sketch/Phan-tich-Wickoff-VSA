# Wyckoff VSA Cross-Symbol Selection Context Snapshot v0.1 — Kiểm toán phù hợp tĩnh

**Kết luận:** `STATIC SPEC CONFORMANCE = PASS`

**Giới hạn:** PASS ở cấp source/interface review; không phải AmiBroker native acceptance và không phải CSN01–CSN20 PASS.

## XS01–XS06 — scope / canonical source / readiness — PASS

- Native Daily current-state only.
- Publisher role-neutral theo `Name()` của source symbol.
- Không Group auto-routing.
- Publisher include public Composite + MTF projection; không tái tạo Event/Phase/Composite/MTF.
- Embedded MTF phải valid và Daily/Weekly/Monthly đều valid trước official commit.

## XS07–XS12 — Daily completion / source date — PASS

- Không suy completed chỉ vì latest bar.
- Same-day default deny qua `ParamToggle` mặc định `Not declared`.
- Completion basis tách `CALENDAR DAY ROLLED OVER` và `OPERATOR EOD COMPLETION DECLARATION`.
- `BusinessDateKey` riêng dùng `YYYYMMDD` integer; source DateTime vẫn giữ provenance.
- Latest source invalid thì publication fail; không lùi sang bar trước.

## XS13–XS16 — namespace / schema / provenance / persistent scalar — PASS

- Namespace `WVSA_SELCTX_v01_<SourceSymbol>_...`.
- SchemaMajor/Minor, producer contract/Composite/MTF versions và sub-schema được ghi explicit.
- SourceSymbol/interval/business date/source datetime/publish datetime/completion/generation được ghi.
- Transport dùng scalar `StaticVarSet`/`StaticVarSetText`; không static array.

## XS17–XS23 — pipeline / concurrency / transaction — PASS

- Publisher là formula riêng; Consumer không publish.
- Không dùng `Status("stocknum")==0` làm benchmark routing.
- Không dùng `SetForeign()` trong Cross-Symbol transport.
- Per-source writer semaphore dùng `StaticVarCompareExchange`.
- Writer protocol: Ready low → bundle → generation → Ready high → release lock.
- Consumer không lấy writer lock; dùng double-read Ready/Generation.
- Generation chỉ transaction token, không dùng làm market freshness.

## XS24–XS27 — payload preservation — PASS

- Composite singleton fields được serialize.
- Lower/upper RangeContext được giữ riêng, không chọn winner.
- MTF Daily/Weekly/Monthly Directional/Phase/Family/Evidence cùng alignment/conflict status được giữ.
- Weekly/Monthly source period, DateTime, generation và schema provenance được giữ.
- Projection facade chỉ công bố field upstream đã có; không tính lại MTF logic.

## XS28–XS35 — consumer semantics / fail closed — PASS

- Transport không tạo MarketSelectionContext/GroupSelectionContext/candidate/rank.
- Shared consumer tạo hai wrapper role `WXSM_` và `WXSG_` trên cùng schema.
- Group không requested trả status 2 `NOT REQUESTED`.
- Consumer status 0–14 giữ nguyên các lớp lỗi chính của XS30.
- Business-date equality được kiểm tra per stock reader: stale/future đều fail closed.
- Exact SourceSymbol match bắt buộc.
- Market/Group requested symbol trùng nhau được export thành configuration conflict.
- Embedded MTF invalid làm official snapshot unusable.
- Persistence không bỏ qua freshness/version checks.
- Explicit version guard kiểm tra contract + Composite + MTF producer/sub-schema.

## XS36–XS38 — operation / audit / non-goals — PASS

- Không mutate watchlist/universe.
- Publisher và Consumer đều có Exploration-first audit surfaces.
- Không Buy/Sell/Short/Cover, PositionSize, P&F target, liquidity rule, ranking, confidence/probability, historical cross-symbol backfill hay hidden benchmark engine execution.

## Acceptance blockers còn mở

1. CSN01 Verify Syntax trên AmiBroker 6.20.01.
2. CSN02–CSN04 completion semantics.
3. CSN05 persistence/restart.
4. CSN06–CSN12 business-date/schema/symbol fixtures.
5. CSN13–CSN16 concurrency/transaction fixtures.
6. CSN17–CSN19 embedded MTF/multiple-context/source-revision fixtures.
7. CSN20 performance comparison.

`STATIC SPEC CONFORMANCE = PASS`