# Wyckoff VSA Performance Runtime v0.2 — Native Snapshot Fail-Closed Evidence

Date: 2026-09-13
Branch: `feature/performance-runtime-v0.2`
Scope: Daily Snapshot consumer fail-closed contract only.

## Native result

The grouped AmiBroker 6.20.01 probe `DAILY_SNAPSHOT_FAILCLOSED_GROUPED_V02_20260913_A` produced exactly nine test rows and every row reported `CASE PASS = 1`.

| Symbol | Injected case | Expected | Actual | Fail-closed zero surface | Valid surface preserved | PASS |
|---|---|---:|---:|---:|---:|---:|
| ABB | SYMBOL MISMATCH | 4 | 4 | 1 | 0 | 1 |
| DTP | VALID | 1 | 1 | 0 | 1 | 1 |
| FRT | NO SNAPSHOT | 0 | 0 | 1 | 0 | 1 |
| HCM | SCHEMA MISMATCH | 3 | 3 | 1 | 0 | 1 |
| HSG | FUTURE SNAPSHOT DATE | 7 | 7 | 1 | 0 | 1 |
| SHB | STALE SNAPSHOT DATE | 6 | 6 | 1 | 0 | 1 |
| SNZ | WRITE NOT COMPLETE | 2 | 2 | 1 | 0 | 1 |
| VNM | REQUIRED PAYLOAD INVALID | 8 | 8 | 1 | 0 | 1 |
| VOS | CONFIG FINGERPRINT MISMATCH | 5 | 5 | 1 | 0 | 1 |

## Interpretation

- Every injected infrastructure/contract failure mapped to the intended status code.
- Every invalid case forced the public decision surface to zero (`Fail-Closed Zero Surface = 1`).
- The synthetic VALID control preserved its injected public surface (`Valid Surface Preserved = 1`).
- The DTP row in this grouped probe is a synthetic contract-control payload, not a re-assertion of the production DTP scanner classification used in the separate universe-equivalence checkpoint.
- The probe uses the isolated namespace `WVSA_DAILY_FC_TEST_v02_*`; production `WVSA_DAILY_v02_*` snapshots are not the test target.

## Checkpoint

`PERFORMANCE_RUNTIME_V02_DAILY_SNAPSHOT_FAILCLOSED = PASS_9_OF_9`

This is a scoped native checkpoint. It does not by itself constitute final release acceptance or a measured performance claim.
