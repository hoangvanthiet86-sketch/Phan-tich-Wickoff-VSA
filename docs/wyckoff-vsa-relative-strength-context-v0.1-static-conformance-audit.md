# Wyckoff VSA Relative Strength Context v0.1 — Kiểm toán phù hợp tĩnh

**Kết luận:** `STATIC SPEC CONFORMANCE = PASS WITH R35 NATIVE GATE PENDING`

Đây là kiểm toán source/interface, không phải AmiBroker native acceptance.

## R01–R05 — phạm vi và benchmark — PASS

- Official integration v0.1 là Daily.
- Stock-vs-Market bắt buộc.
- Stock-vs-Group và Group-vs-Market chỉ hoạt động khi Group benchmark explicit.
- Không silent fallback từ Group sang Market.
- Benchmark identity được export.

## R06–R08 — ratio semantics — PASS

- Ratio = Close numerator / Close denominator.
- Không RSI.
- Không dùng raw ratio level làm score/rank.
- Không fixed 20d/3m/6m/12m return làm identity.

## R09–R12, R35 — causal derived pivots — SOURCE PASS / NATIVE PENDING

- RS ratio được đưa vào `WDP_RunDerivedSeries`.
- Dùng `SL_PivotLeft/SL_PivotRight`.
- Derived kernel giữ candidate `i-B`, full `A+B+1` valid window, strict-left/inclusive-right, confirm-time publication, Extreme/Confirm coordinates và Latest/LatestPrior semantics.
- Không Zig/Peak/Trough/future access/backfill.
- K27–K29 equivalence harness tồn tại ở PR #34.
- **Cell-by-cell execution chưa chạy trên AmiBroker 6.20.01**, do đó R35 chưa native PASS.

## R11, R14–R16 — structure và non-confirmation — PASS

- RS rising = HH + HL trên hai confirmed highs/lows gần nhất.
- RS falling = LH + LL.
- Các tổ hợp khác = mixed.
- Price Structure lấy từ confirmed Structure/Location price pivot events.
- Price/RS relationship dùng categorical R15.
- Không gọi DNC/UNC canonical nếu chưa có matching-swing contract.

## R13 — completed RS wave descriptor — PASS

- Có direction, start/end ratio, percentage change, timestamps/coordinates và duration bars.
- Chỉ completed khi hai pivot publication gần nhất là opposite kind.
- Không dùng magnitude làm confidence/rank.

## R17–R21 — pairwise và leadership — PASS

- Stock-vs-Market luôn được giữ trực tiếp.
- Stock-vs-Group không overwrite Stock-vs-Market.
- Group-vs-Market là channel riêng.
- Leadership Chain categorical theo R20.
- Không suy Stock-vs-Market bằng logic bắc cầu.

## R22–R24 — Phase/VSA/MTF diagnostics — PASS Ở CẤP INTERFACE

- Phase/RS, VSA/RS, MTF/RS là diagnostics riêng.
- Không field nào sửa Phase/Family/VSA/MTF upstream.
- Trên development branch hiện tại, `WCI_*`/`WMTF_*` được đọc như optional upstream public variables; khi integration caller chưa nạp upstream stack, diagnostic fail closed thay vì copy logic upstream.
- Integration runtime với PR #25/#27/#31 chưa kiểm thử.

## R25–R30 — timeframe, data validity, provenance — PASS

- Không internal Daily→Weekly→Monthly compression/expansion trong RS engine.
- Benchmark Close dùng `Foreign(...,"C",0)`.
- Không fill-forward benchmark hole.
- Close numerator/denominator phải finite và >0.
- Adjustment basis declaration/status được export.
- Context production-valid bị chặn nếu adjustment basis chưa verified-compatible.
- Native interval/schema/source DateTime/pivot config được công bố.
- Không benchmark volume trong identity.

## R31–R32 — provisional và source revision — PASS Ở CẤP CONTRACT

- Provisional latest bar có runtime flag, đồng thời có thể nhận Composite provisional flag nếu upstream loaded.
- Confirmed pivots vẫn chỉ publication tại right-side confirmation.
- Source revision được tách khỏi repaint trong contract; in-formula status hiện là `NOT ASSESSED`, vì phát hiện vendor revision cần persisted prior run.

## R33–R34 — public interface và Exploration-first — PASS

- Prefix `WRS_`.
- Có data health, benchmark provenance, pairwise ratios/structures/pivots, price structure, relationship, leadership, Phase/VSA/MTF diagnostics.
- `WyckoffVSA_RelativeStrengthContext_Exploration_v0.1.afl` là acceptance surface đầu tiên.

## R36 — non-goals — PASS

Không có:

- Buy/Sell/Short/Cover;
- PositionSize;
- stop/target;
- confidence/probability;
- percentile;
- universe rank;
- Top-N scanner.

## Acceptance blockers còn mở

1. AmiBroker 6.20.01 Verify Syntax.
2. Derived kernel cell-by-cell equivalence execution K27–K29.
3. Benchmark missingness/data-status fixtures.
4. Ratio pivot boundary/tie fixtures.
5. Composite/MTF integration test.
6. Causal-prefix/append/source-revision/forming-bar/performance tests.

`STATIC SPEC CONFORMANCE = PASS WITH R35 NATIVE GATE PENDING`