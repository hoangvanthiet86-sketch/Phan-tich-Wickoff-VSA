# Wyckoff VSA Performance Runtime v0.2 — Native Universe Equivalence Evidence

**Date:** 2026-09-12  
**Branch:** `feature/performance-runtime-v0.2`  
**Native platform:** AmiBroker 6.20.01  
**Status:** PASS for the scoped scanner decision-surface equivalence checkpoint; not a final release acceptance.

## Evidence set

The owner ran `WyckoffVSA_RuntimeUniverse_EquivalenceProbe_v0.2.afl` natively on the same database/as-of date used by the post-MS41 baseline.

Baseline oracle:

- 1,558 eligible symbols
- as-of 2026-09-11
- post-MS41 scanner behavior

Runtime v0.2 output:

- 1,558 rows
- 1,558 unique symbols
- symbol set exactly equal to baseline
- no missing symbols
- no extra symbols
- `EQ_ConfigValid = 1` for all 1,558 rows
- `EQ_RSAdjustmentBasis = ADJUSTED PRICE` for all 1,558 rows
- `EQ_RSAdjustmentStatus = 1` for all 1,558 rows
- probe version `RUNTIME_UNIVERSE_EQ_V02_20260912_A` for all 1,558 rows

## Exact field-by-field comparison

The following decision-surface fields matched exactly for **1,558 / 1,558 symbols**:

- `Data Eligible`
- `Candidate Class Code`
- `Candidate Side Code`
- `Candidate Stage Code`
- `Qualified`
- `Developing`
- `Watch`
- `Scanner Review`
- `Scanner Exclusion Mask`
- `Scanner Method Block Mask`

Mismatch count for every field above: **0**.

## Distribution cross-check

Runtime v0.2 reproduced the post-MS41 universe distribution:

- Review / class 9: 1,426
- Not candidate / class 1: 128
- Watch / class 2: 4
- Developing: 0
- Qualified: 0

The four Watch rows remained:

- `SNZ`
- `41I2GC000`
- `CFPT2612`
- `CTCB2523`

This confirms the previously identified mixed-universe operational issue remains outside the analytical equivalence result; stock-only universe operationalization is still a separate workflow concern.

## Control cases

Previously native-validated MS41 controls remain consistent:

- DTP: Review, method mask 1031, range position about -2.3027
- FRT: Review, method mask 1031, range position about -0.7363
- SNZ: Watch, method mask 7, range position 0.3500

## Scope of PASS

This PASS means Runtime v0.2 reproduces the approved scanner decision surface on the 1,558-symbol post-MS41 baseline for the fields listed above.

It does **not** yet mean Performance Runtime v0.2 is complete. Remaining work includes:

1. persistent Daily Publisher snapshot;
2. fail-closed Fast Scanner consumer;
3. publisher/consumer native equivalence;
4. stock-only operational universe workflow;
5. native performance measurement on the same machine/database/settings;
6. causal/replay regression and final release acceptance.
