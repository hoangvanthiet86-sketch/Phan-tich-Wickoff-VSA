# Wyckoff VSA Adaptive One-Click Controller v0.1

## Decision

The validated seven-stage batch is retained as `FULL_RECOVERY`.
Daily production operation moves to an adaptive controller that launches only
the stages required by visible-data freshness.

## Route table

| Route | Conditions | Heavy stages |
|---|---|---|
| FAST_ONLY | same business date; W/M/Selection/Daily markers fresh | APX 07 |
| DAILY_REFRESH | new business date, same W/M ordinals | APX 05 -> 06 -> 07 |
| WEEKLY_REFRESH | expected completed Weekly ordinal changed | APX 01 -> 03 -> 05 -> 06 -> 07 |
| MONTHLY_REFRESH | expected completed Monthly ordinal changed | APX 02 -> 04 -> 05 -> 06 -> 07 |
| FULL_RECOVERY | both W/M stale, identity/config/universe changed, or state absent | APX 01 -> 02 -> 03 -> 04 -> 05 -> 06 -> 07 |

Every adaptive batch MUST finish with:
- Load Project: `WVSA_OC_08_ADAPTIVE_COMMIT.apx`
- Explore

The commit marker consumes a Pending token written by the controller and only
advances persistent freshness markers if the visible as-of and critical
snapshot state still match.

## State identity

Prefix:
`WVSA_AOC_v01_`

Persistent identity:
- schema 1.0
- canonical universe name and exact universe symbol list
- exact Daily Snapshot analytical ConfigFingerprint
- market symbol

Freshness:
- completed Weekly ordinal
- completed Monthly ordinal
- Selection business date
- Daily business date

## Replay behavior

The controller uses the same visible-data operational clock as the production
runtime. A live/current marker cannot match a historical replay position.
Backward/forward replay therefore routes to FULL/WEEKLY/MONTHLY/DAILY refresh
as required by the visible as-of. No system-calendar shortcut is used.

## Bootstrap

Because the owner already completed and visually verified the full seven-stage
baseline on 2026-09-18 business data, the controller includes an explicit
`BOOTSTRAP` trigger. It is enabled only when:
- VNINDEX W snapshot is current;
- VNINDEX M snapshot is current;
- VNINDEX Selection snapshot is current;
- every symbol in `VN STOCKS ONLY` has a stable current Daily Snapshot with
  the exact config fingerprint.

This bootstrap avoids an unnecessary repeat FULL_RECOVERY run.

## AmiBroker 6.20 boundary

No GuiButton/GuiGetEvent API is used because on-chart GUI controls were added
after AmiBroker 6.20. The controller uses ParamTrigger and the 6.20-supported
`ShellExecute("runbatch", ...)` mechanism.

`ADAPTIVE_ONE_CLICK_CONTROLLER_V01 = IMPLEMENTED_PENDING_NATIVE`
