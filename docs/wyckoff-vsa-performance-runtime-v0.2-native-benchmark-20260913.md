# Wyckoff VSA Performance Runtime v0.2 — Native Benchmark Evidence — 2026-09-13

## Scope

This document records native AmiBroker 6.20.01 benchmark evidence for the already-validated Runtime v0.2 decision path versus the persistent Daily Snapshot consumer path.

This is a performance/runtime evidence record only. It does not change methodology, scanner semantics, candidate classes, ranking, or trading logic.

## Native inputs

- Full Runtime probe: `PERF_BENCH_FULL_RUNTIME_V02_20260913_A`
- Fast Snapshot probe: `PERF_BENCH_FAST_SNAPSHOT_V02_20260913_A`
- Periodicity: Daily
- Range: 1 recent bar
- Business date in both exports: `2026-09-11`
- Matched symbols: `1558 / 1558`
- Missing symbols: `0`
- Duplicate symbols: `0`
- Full Runtime `BM_DataEligible = 1`: `1558 / 1558`
- Fast Snapshot `BM_SnapshotStatus = 1`: `1558 / 1558`

The benchmark-surface fields available in both exports were compared by symbol:

- `BM_DataEligible`
- `BM_CandidateClass`
- `BM_Stage`
- `BM_Watch`
- `BM_Review`
- `BM_MethodBlockMask`

Result: `0` mismatches across all 1558 matched symbols.

The broader locked scanner decision-surface equivalence remains covered by the earlier `1558 / 1558` Runtime universe-equivalence checkpoint.

## Formula-local per-symbol timing results

### Full Runtime

- Median: `1874.690 ms/symbol`
- Mean: `4115.609 ms/symbol`
- P95: `14178.315 ms/symbol`
- P99: `19842.105 ms/symbol`
- Minimum: `732.306 ms`
- Maximum: `31716.242 ms`
- Sum of per-symbol measurements: `6412119.228 ms`

### Fast Snapshot

- Median: `1.362 ms/symbol`
- Mean: `1.480 ms/symbol`
- P95: `2.119 ms/symbol`
- P99: `2.313 ms/symbol`
- Minimum: `1.214 ms`
- Maximum: `4.014 ms`
- Sum of per-symbol measurements: `2305.471 ms`

## Speed ratios

Ratios are computed from matched native measurements.

- Ratio of medians: `1376.42x`
- Ratio of means: `2781.26x`
- Ratio of P95 values: `6690.57x`
- Ratio of P99 values: `8576.88x`
- Ratio of summed per-symbol measurements: `2781.26x`
- Median of paired per-symbol Full/Fast ratios: `1290.38x`
- Minimum paired per-symbol ratio: `315.28x`
- Maximum paired per-symbol ratio: `22589.92x`

## Interpretation boundary

These figures are **formula-local per-symbol execution timings** measured inside the AFL probes using `GetPerformanceCounter(1)`. They are not AmiBroker Analysis-window wall-clock elapsed times. AmiBroker can execute symbols concurrently, so summed per-symbol milliseconds must not be presented as elapsed user wait time.

The evidence supports the conclusion that the snapshot-only scan path removes the heavy canonical calculation cost from repeated scanning while preserving the validated scanner surface for the matched universe.

## Checkpoint

`PERFORMANCE_RUNTIME_V02_NATIVE_FORMULA_BENCHMARK = PASS_1558_OF_1558`

This checkpoint does not constitute final release acceptance. Remaining operational work includes establishing and validating the stock-only production universe (`VN STOCKS ONLY`) and then recording production workflow timing/acceptance on that universe.
