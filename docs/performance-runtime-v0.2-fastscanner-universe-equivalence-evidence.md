# Performance Runtime v0.2 — Fast Scanner Universe Equivalence Evidence

Status: NATIVE CHECKPOINT PASS

Branch: `feature/performance-runtime-v0.2`

Native environment: AmiBroker 6.20.01, Daily, 1 recent bar, as-of 2026-09-11 data.

## Inputs

- Prior Runtime v0.2 universe-equivalence oracle: `RUNTIME_UNIVERSE_EQ_V02_20260912_A`.
- Daily Publisher result: `DAILY_PUBLISHER_V02_20260912_A`.
- Fast Scanner snapshot-only universe probe: `FAST_SCANNER_UNIVERSE_EQ_V02_20260913_A`.

## Daily Publisher native result

- Rows processed: 2,297 unique symbols.
- Publisher Status = `1 / COMMITTED`: 2,297 / 2,297.
- Business DateNum = `1260911`: 2,297 / 2,297.
- Runtime Version = `0.2`: 2,297 / 2,297.
- Eligible snapshots: 1,558.
- Ineligible snapshots: 739.
- No duplicate symbols.
- Snapshot generation: 2,296 symbols at generation 1; DTP at generation 2 because DTP had already been published during the prior single-symbol native checkpoint. This is expected per-symbol persistent-generation behavior.

## Fast Scanner universe result

- Eligible output rows: 1,558.
- Unique symbols: 1,558.
- Duplicate symbols: 0.
- Snapshot Status = `1 / VALID`: 1,558 / 1,558.
- Snapshot Business DateNum = `1260911`: 1,558 / 1,558.
- Probe Version = `FAST_SCANNER_UNIVERSE_EQ_V02_20260913_A`: 1,558 / 1,558.

Distribution:

- Candidate Class 9 / Review: 1,426.
- Candidate Class 1 / Not candidate: 128.
- Candidate Class 2 / Watch: 4.
- Developing: 0.
- Qualified: 0.

## Exact decision-surface comparison

The Fast Scanner result was joined by symbol against the prior Runtime v0.2 oracle. Symbol set matched exactly: 1,558 / 1,558, with no missing or extra symbol.

Exact mismatch counts:

- `DataEligible`: 0
- `CandidateClass`: 0
- `Side`: 0
- `Stage`: 0
- `Qualified`: 0
- `Developing`: 0
- `Watch`: 0
- `Review`: 0
- `ExclusionMask`: 0
- `MethodBlockMask`: 0

Total rows with any decision-surface mismatch: **0 / 1,558**.

The eligible subset serialized by Daily Publisher was also joined against the Fast Scanner output; all 1,558 symbols matched, with zero mismatches in the Publisher-visible fields `DataEligible`, `CandidateClass`, `Stage`, `Watch`, `Review`, and `MethodBlockMask`.

## Checkpoint conclusion

`PERFORMANCE_RUNTIME_V02_FAST_SCANNER_UNIVERSE_EQUIVALENCE = PASS_1558_OF_1558`

This is a scoped native equivalence checkpoint only. It proves snapshot serialization + snapshot-only scanning preserve the approved Scanner decision surface for equivalent input/configuration. It is not final release acceptance and does not yet establish a performance multiplier because elapsed execution-time evidence was not included in the exported result files.
