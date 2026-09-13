# VN STOCKS ONLY — U3 Native Evidence — 2026-09-13

## Scope

Performance Runtime v0.2, branch `feature/performance-runtime-v0.2`.

This evidence records only U3 — Watchlist Build / Membership Audit. It does not claim U4 or final Performance Runtime acceptance.

## Native input and result

Native AmiBroker output from `WyckoffVSA_VNStocksOnly_WatchlistBuilder_v0.2.afl` used probe version:

`VN_STOCKS_ONLY_WATCHLIST_BUILDER_V02_20260913_B`

Observed:

- Builder rows: 1,668
- Unique symbols: 1,668
- `U_ExpectedStock = 1` for all emitted rows
- `U_WatchlistMemberAfter = 1` for all emitted rows
- `U_ContractMatch = 1` for all emitted rows
- Watchlist name: `VN STOCKS ONLY`

The subsequent native `WyckoffVSA_VNStocksOnly_WatchlistAudit_v0.2.afl` exploration returned zero rows. By audit design, it emits only membership mismatches; zero rows therefore means no mismatch was observed across the scanned database under the locked metadata classification contract.

## Locked U3 checkpoint

`VN_STOCKS_ONLY_U3_WATCHLIST_BUILD_AUDIT = PASS_1668_OF_1668`

`AUDIT_MISMATCH_ROWS = 0`

## Boundary

No claim is made here about:

- current-day snapshot validity across all 1,668 watchlist members;
- Data Eligible count after stock-only restriction;
- Candidate Class / Stage distribution on stock-only universe;
- AmiBroker Analysis wall-clock time for DailyPublisher or FastScanner;
- U4 or final release acceptance.
