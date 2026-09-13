# Wyckoff VSA — VN STOCKS ONLY U4 Native Operational Run v0.2

## Purpose

Complete U4 after U3 watchlist build/audit has passed.

This run does not change methodology or decision logic. It validates actual stock-only production operation:

`DailyPublisher -> persistent Daily Snapshot -> FastScanner`

on watchlist:

`VN STOCKS ONLY`

## Locked prerequisites

- U3 watchlist size: 1,668 symbols.
- U3 membership audit mismatch rows: 0.
- Runtime configuration must remain identical between publisher and consumers.
- Periodicity: Daily.
- Range: 1 recent bar.
- `1.3 Treat Last Bar As Provisional = No` for publication.
- P&F remains deferred from DAILY FAST SCAN.

## U4-A — Daily Publisher

Formula:

`WyckoffVSA_DailyPublisher_v0.2.afl`

Run:

- Apply to: `VN STOCKS ONLY`
- Periodicity: Daily
- Range: 1 recent bar
- Explore

Record the AmiBroker Analysis wall-clock elapsed time displayed by the Analysis window.

Export the Exploration result to TXT.

Acceptance for this step:

- 1,668 publisher rows are expected because the watchlist contains 1,668 symbols;
- every row must report publisher status 1 / COMMITTED;
- same canonical business date for the operational run;
- no writer-busy / invalid-config / invalid-payload / commit-verify failure rows.

## U4-B — Snapshot Coverage Audit

Formula:

`WyckoffVSA_VNStocksOnly_OperationalSnapshotAudit_v0.2.afl`

Run on the same `VN STOCKS ONLY`, Daily, 1 recent bar.

Export result to TXT.

This formula emits every watchlist member and is used to count:

- total watchlist rows;
- valid vs invalid snapshot count;
- Data Eligible count;
- Candidate Class distribution;
- Stage distribution;
- Qualified / Developing / Watch / Review distribution;
- exclusion and method-block masks.

Expected structural condition:

- 1,668 rows;
- snapshot status 1 and `U4_SnapshotValid=1` for every row after a successful same-day publisher run;
- any invalid snapshot blocks U4 PASS until explained and corrected.

## U4-C — Fast Scanner Operational Run

Formula:

`WyckoffVSA_FastScanner_v0.2.afl`

Run:

- Apply to: `VN STOCKS ONLY`
- Periodicity: Daily
- Range: 1 recent bar
- `1.2 Production Filter = 4 All Eligible`
- Explore

Record the AmiBroker Analysis wall-clock elapsed time displayed by the Analysis window.

Export result to TXT.

The Fast Scanner must read snapshot only. It must not execute the heavy analytical Runtime stack.

Acceptance for this step:

- every emitted row has Snapshot Status 1;
- emitted row count equals the `U4_DataEligible=1` count from U4-B;
- Candidate Class / Stage / Watch / Review / Method Block values must match the snapshot audit on the same symbols;
- no stale/future/config/schema/generation/payload failures.

## U4 evidence package

For final U4 evaluation, retain:

1. Daily Publisher TXT.
2. U4 Snapshot Audit TXT.
3. Fast Scanner TXT.
4. Publisher Analysis wall-clock elapsed time.
5. Fast Scanner Analysis wall-clock elapsed time.

Do not call final Performance Runtime v0.2 acceptance before native U4 evidence is evaluated.
