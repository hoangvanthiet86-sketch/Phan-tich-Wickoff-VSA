# Wyckoff VSA Production Candidate v0.1 — Operational Readiness Runbook

**Status:** integrated release candidate; native end-to-end smoke execution has run, operational data/configuration gates remain.

## Why this operational step exists

The integrated AmiBroker 6.20 entrypoint now executes far enough to emit a full Production Candidate report. The current report is data-gated because the required serialized higher-timeframe and benchmark contexts have not yet been published and adjustment-basis declarations remain unverified.

The architecture intentionally keeps these publishers explicit. It does not silently recompute benchmark Phase/Composite/MTF inside each stock scan.

## Required order

### 1. Publish Weekly snapshots for the scan universe

Use:

`WyckoffVSA_Operational_TimeframePublisher_AmiBroker620_v0.1.afl`

Set Analysis interval to **Weekly** and run over all symbols that will be scanned, plus the Market benchmark and any optional Group benchmark.

Success condition per symbol:

`OP Publisher Status = 1`
`OP Snapshot Ready = 1`

The snapshot publisher uses the previous calendar-completed week.

### 2. Publish Monthly snapshots for the same universe

Use the same formula with Analysis interval **Monthly**.

Success condition per symbol:

`OP Publisher Status = 1`
`OP Snapshot Ready = 1`

The snapshot publisher uses the previous calendar-completed month.

### 3. Publish Daily Market benchmark context

Use:

`WyckoffVSA_Operational_SelectionPublisher_AmiBroker620_v0.1.afl`

Run at **Daily** interval on the exact Market benchmark symbol that will also be used by Relative Strength and the Scanner.

If the latest database bar is the current calendar day and is already complete, set:

`Selection snapshot: current Daily bar completed = Completed`

Success conditions:

`OP Weekly Snapshot Status = 1`
`OP Monthly Snapshot Status = 1`
`OP MTF Valid = 1`
`OP Selection Publisher Status = 1`
`OP Selection Context Ready = 1`

For the default Market-only profile, Group benchmark may remain blank. Do not enable Full Top-Down requirement unless a valid Group snapshot and Group RS chain are also available.

### 4. Configure the Daily Production Candidate scan

Run:

`WyckoffVSA_ProductionCandidate_AmiBroker620_v0.1.afl`

at native **Daily** interval.

The following two symbol parameters must be exactly identical:

`RS Market Benchmark`
`Selection: Market benchmark symbol`

The symbol must exist in the AmiBroker database and must be the same symbol used in step 3.

For Market-only operation:

`Selection: Group benchmark symbol = blank`
`Scanner: require Full Top-Down profile = No`

### 5. Adjustment-basis gates

Do not set a compatibility status to 1 merely to make the scanner pass.

Set:

`RS Adjustment Basis Status = 1`

only after verifying that the stock and benchmark price series use a compatible adjustment basis.

Set:

`P&F adjustment basis = 1`

only after verifying that the database price adjustment basis is compatible with the chosen fixed `BoxSize`, `GridOrigin`, and price source.

Until verified, the correct behavior is fail-closed:
- Scanner may remain data-ineligible because RS adjustment basis is unverified.
- P&F geometry may still build, but official P&F objectives remain unavailable.

### 6. P&F identity

Set explicitly and keep stable during one acceptance generation:

`P&F fixed BoxSize`
`P&F GridOrigin`
`P&F ReversalBoxes`

Changing these values changes the P&F construction identity and invalidates direct generation-to-generation comparison.

## Current report interpretation

The first integrated report proved that the full release candidate can execute and emit output. It showed a stock-side bullish Phase-E-like reaccumulation context, but `Data Eligible = 0`.

The Scanner exclusion mask in that report was `572`, which decomposes to:

- 4 — Market benchmark / RS not ready
- 8 — adjustment basis not verified
- 16 — stock MTF not valid
- 32 — Market selection snapshot missing
- 512 — Market benchmark configuration mismatch

The operational sequence above is intended to close 4, 16, 32, and 512. Bit 8 must be closed only by an explicit verified adjustment-basis declaration.

The report also showed:

`P&F Config Valid = 1`
`P&F Mature = 1`
`P&F Adj Basis = 0`
`P&F Objective Available = 0`

This is the expected fail-closed state until P&F adjustment compatibility is verified.

## Important calendar constraint

The snapshot contracts use the local system clock and require the previous calendar-completed Weekly/Monthly periods. Cross-symbol Daily consumers require the benchmark snapshot business date to match the stock scan business date.

Therefore an old/stale database cannot reach full operational validity simply by changing parameters. The data must contain the required current completed periods, or the contracts will correctly return MISSING/STALE.

## Next acceptance checkpoint

After the four publisher/configuration steps above, rerun the Production Candidate on one controlled symbol and export the result.

The next target is:

- `WTSC_W_StatusCode = 1`
- `WTSC_M_StatusCode = 1`
- valid Market selection snapshot
- Market benchmark config match = 1
- RS context valid when adjustment basis is verified
- `Data Eligible = 1` when all hard-data gates are satisfied

Only after this checkpoint should the release candidate be expanded to a multi-symbol acceptance run.
