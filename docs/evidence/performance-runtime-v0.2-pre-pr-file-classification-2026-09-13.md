# Performance Runtime v0.2 — Pre-PR File Classification

Date: 2026-09-13
Branch: `feature/performance-runtime-v0.2`
Base: `integration/wyckoff-vsa-production-candidate-v0.1`

## Purpose

Classify the net branch changes before opening a pull request. Categories are limited to:

- `PRODUCTION`: runtime/operational code or supporting production documentation/build tooling intended to remain.
- `TEST`: probes, audits, benchmarks, equivalence/fail-closed harnesses, and test installers retained for reproducibility.
- `EVIDENCE`: native-result evidence records retained for traceability.
- `OBSOLETE`: abandoned or superseded files that must not remain in the PR.

## PRODUCTION

### AFL/runtime
- `afl/WyckoffVSA_Candidate_Runtime_v0.2.afl`
- `afl/WyckoffVSA_Core_Runtime_v0.2.afl`
- `afl/WyckoffVSA_DailyPublisher_v0.2.afl`
- `afl/WyckoffVSA_DailySnapshotConsumer_v0.2.afl`
- `afl/WyckoffVSA_DailySnapshotContract_v0.2.afl`
- `afl/WyckoffVSA_FastScanner_v0.2.afl`
- `afl/WyckoffVSA_RuntimeConfig_v0.2.afl`
- `afl/WyckoffVSA_StructureLocation_Runtime_v0.2.afl`
- `afl/WyckoffVSA_VNStocksOnly_WatchlistBuilder_v0.2.afl`

### Production/support tooling
- `tools/BUILD_WVRC_PHASE_COMPOSITE_RUNTIME_STACK_v0.2.2.ps1`
- `tools/BUILD_WVRC_SCANNER_RUNTIME_STACK_v0.2.4.ps1`
- `tools/RUN_BUILD_WVRC_PHASE_COMPOSITE_RUNTIME_STACK_v0.2.2.cmd`
- `tools/RUN_BUILD_WVRC_SCANNER_RUNTIME_STACK_v0.2.4.cmd`
- `tools/INSTALL_WVRC_RUNTIME_CONFIG_v0.2.5.cmd`
- `tools/INSTALL_WVRC_DAILY_SNAPSHOT_v0.2.7.cmd`
- `tools/INSTALL_WVRC_FAST_SCANNER_v0.2.8.cmd`
- `tools/INSTALL_WVRC_VN_STOCKS_ONLY_WATCHLIST_v0.2.13.cmd`

### Production/specification documentation
- `docs/wyckoff-vsa-performance-runtime-v0.2-spec-draft.md`
- `docs/wyckoff-vsa-performance-runtime-v0.2-spec-approval.md`
- `docs/wyckoff-vsa-performance-runtime-v0.2-parameter-mapping.md`
- `docs/wyckoff-vsa-performance-runtime-v0.2-runtime-config-snapshot-contract.md`
- `docs/wyckoff-vsa-vn-stocks-only-operational-universe-v0.2.md`
- `docs/wyckoff-vsa-vn-stocks-only-u4-native-operational-run-v0.2.md`

## TEST

### AFL probes/audits/benchmarks
- `afl/WyckoffVSA_Composite_Runtime_v0.2_Probe.afl`
- `afl/WyckoffVSA_Core_Runtime_v0.2_Probe.afl`
- `afl/WyckoffVSA_DailySnapshot_ConsumerProbe_v0.2.afl`
- `afl/WyckoffVSA_DailySnapshot_FailClosedGroupedProbe_v0.2.afl`
- `afl/WyckoffVSA_FastScanner_UniverseEquivalenceProbe_v0.2.afl`
- `afl/WyckoffVSA_MarketScanner_Runtime_v0.2_ExplicitOrderProbe.afl`
- `afl/WyckoffVSA_PerformanceBenchmark_FastSnapshot_v0.2.afl`
- `afl/WyckoffVSA_PerformanceBenchmark_FullRuntime_v0.2.afl`
- `afl/WyckoffVSA_RuntimeConfig_OutputProbe_v0.2.afl`
- `afl/WyckoffVSA_RuntimeUniverse_EquivalenceProbe_v0.2.afl`
- `afl/WyckoffVSA_StructureLocation_Runtime_v0.2_Probe.afl`
- `afl/WyckoffVSA_VNStocksOnly_MetadataAudit_v0.2.afl`
- `afl/WyckoffVSA_VNStocksOnly_OperationalSnapshotAudit_v0.2.afl`
- `afl/WyckoffVSA_VNStocksOnly_WatchlistAudit_v0.2.afl`

### Test/install helpers
- `tools/INSTALL_WVRC_RUNTIME_UNIVERSE_EQUIVALENCE_v0.2.6.cmd`
- `tools/INSTALL_WVRC_FAST_SCANNER_UNIVERSE_EQ_v0.2.9.cmd`
- `tools/INSTALL_WVRC_DAILY_SNAPSHOT_FAILCLOSED_v0.2.10.cmd`
- `tools/INSTALL_WVRC_PERFORMANCE_BENCHMARK_v0.2.11.cmd`
- `tools/INSTALL_WVRC_VN_STOCKS_ONLY_METADATA_AUDIT_v0.2.12.cmd`
- `tools/INSTALL_WVRC_VN_STOCKS_ONLY_U4_v0.2.14.cmd`

### Test protocol
- `docs/wyckoff-vsa-performance-runtime-v0.2-native-equivalence-protocol.md`

## EVIDENCE

- `docs/wyckoff-vsa-performance-runtime-v0.2-native-equivalence-20260912.md`
- `docs/performance-runtime-v0.2-fastscanner-universe-equivalence-evidence.md`
- `docs/wyckoff-vsa-performance-runtime-v0.2-native-failclosed-evidence.md`
- `docs/wyckoff-vsa-performance-runtime-v0.2-native-benchmark-20260913.md`
- `docs/evidence/wyckoff-vsa-vn-stocks-only-u3-native-evidence-2026-09-13.md`
- `docs/evidence/performance-runtime-v0.2-vn-stocks-only-u4-functional-native-2026-09-13.md`

## OBSOLETE — already removed before PR

The following abandoned/superseded files were removed from the current branch after the U4 functional checkpoint:

- `tools/APPLY_WVRC_SINGLE_CONFIG_BRIDGE_v0.2.ps1`
- `afl/WyckoffVSA_RuntimeBridge_CoreProbe_v0.2.afl`
- `afl/WyckoffVSA_RuntimeBridge_PreRSProbe_v0.2.afl`
- `afl/WyckoffVSA_RuntimeBridge_StructureProbe_v0.2.afl`
- `afl/WyckoffVSA_PerformanceRuntime_CompatibilityHarness_v0.2.afl`
- `afl/WyckoffVSA_MarketScanner_Runtime_v0.2_Probe.afl`
- `tools/BUILD_WVRC_PHASE_COMPOSITE_RUNTIME_STACK_v0.2.ps1`
- `tools/BUILD_WVRC_PHASE_COMPOSITE_RUNTIME_STACK_v0.2.1.ps1`
- `tools/RUN_BUILD_WVRC_PHASE_COMPOSITE_RUNTIME_STACK_v0.2.cmd`
- `tools/RUN_BUILD_WVRC_PHASE_COMPOSITE_RUNTIME_STACK_v0.2.1.cmd`
- `tools/BUILD_WVRC_SCANNER_RUNTIME_STACK_v0.2.3.ps1`
- `tools/RUN_BUILD_WVRC_SCANNER_RUNTIME_STACK_v0.2.3.cmd`

These removals do not alter the accepted Runtime v0.2 analytical decision surface. They remove abandoned bridge experiments and superseded builder/probe revisions only.

## Pre-PR conclusion

- Current retained files have an assigned role.
- No additional file is classified `OBSOLETE` at this checkpoint.
- Native functional evidence remains intact.
- No PR is opened by this classification step.
- No merge is performed by this classification step.
