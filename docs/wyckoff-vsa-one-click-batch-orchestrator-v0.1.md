# Wyckoff VSA One-Click Scanner v0.1 — AmiBroker 6.20.01 Batch Orchestrator Pivot

## Status

Native target: AmiBroker 6.20.01 Windows 32-bit.

Observed:
- N03 unified stock D/W/M: PASS.
- N04A stock + VNINDEX D/W/M + MTF: PASS.
- N04C Daily + RS exact equivalence: PASS.
- N06A cache-contract-only infrastructure: PASS.
- N05/N05.1/N05D/N05E/N05F and N06B/N06C terminate AmiBroker during Verify Syntax / check-time execution when heavy domains are combined into one AFL evaluation.

Decision:
- stop all further attempts to execute the complete cold-rebuild graph inside one AFL evaluation;
- preserve the user-level goal of **one action -> final list** by using AmiBroker 6.20 native Batch orchestration;
- final filtering remains the single snapshot consumer `WyckoffVSA_FastScanner_v0.2.afl`;
- producer stages run sequentially in separate Analysis projects, so the 32-bit process never evaluates the entire graph in one formula instance.

## Why this is valid

AmiBroker 6.20 Batch can sequentially:
1. load an Analysis Project (.APX),
2. run Exploration,
3. load another APX,
4. run Exploration,
5. export the final result.

APX contains formula, Apply-To, Range and Analysis settings. A saved batch (.ABB) can therefore automate the complete prerequisite chain without manual publisher runs.

## Operational pipeline v0.1

The first production batch will use the existing validated publisher/consumer architecture:

1. Higher-Timeframe Publisher — Weekly — stock universe.
2. Higher-Timeframe Publisher — Monthly — stock universe.
3. Higher-Timeframe Publisher — Weekly — VNINDEX.
4. Higher-Timeframe Publisher — Monthly — VNINDEX.
5. Selection-Context Publisher — VNINDEX Daily, completed-bar declaration.
6. Daily Publisher v0.2 — stock universe.
7. Fast Scanner v0.2 — stock universe — final Exploration.

If group benchmark is empty (current default), no group publisher stages are included.

## Current / Bar Replay

All producer entrypoints use the visible-data operational clock. The same batch is intended for ordinary current/EOD execution and Bar Replay. Replay acceptance still requires a dedicated no-lookahead native gate after batch orchestration is assembled.

## User experience

Target becomes:

`ONE USER ACTION -> batch -> final FastScanner list`

rather than:

`ONE AFL EVALUATION -> full cold rebuild -> final list`

This is an implementation-form change forced by native 32-bit stability evidence. It does not change Wyckoff/VSA methodology, thresholds, candidate-class semantics, production-filter semantics or snapshot decision surface.

## One-time setup artifacts

AmiBroker must save the following APX files from native Analysis windows because APX is AmiBroker's own self-contained project format:

- `WVSA_OC_01_TF_WEEKLY_STOCK.apx`
- `WVSA_OC_02_TF_MONTHLY_STOCK.apx`
- `WVSA_OC_03_TF_WEEKLY_VNINDEX.apx`
- `WVSA_OC_04_TF_MONTHLY_VNINDEX.apx`
- `WVSA_OC_05_SELECTION_VNINDEX_DAILY.apx`
- `WVSA_OC_06_DAILY_PUBLISHER_STOCK.apx`
- `WVSA_OC_07_FAST_SCANNER_STOCK.apx`

Then create and save:
- `WVSA_OneClick_v0.1.abb`

The batch order must match the seven stages above.

## Launcher

A tiny AFL launcher may call:
`ShellExecute("runbatch", <batch path>, "");`
behind a `ParamTrigger`. This launcher contains no analytical stack and is not the scanner itself.

## Acceptance gates

1. Batch step completion: all seven stages Completed.
2. Publisher status:
   - HTF snapshots ready,
   - Selection context ready,
   - Daily Publisher committed.
3. Fast Scanner snapshot status valid.
4. Universe decision equivalence remains 100%.
5. Current/EOD repeat run.
6. Bar Replay same-date repeat.
7. Replay +1 day.
8. Weekly rollover.
9. Monthly rollover.
10. No future-date cache acceptance.
