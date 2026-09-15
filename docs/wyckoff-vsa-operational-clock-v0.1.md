# Wyckoff VSA Operational Clock v0.1

## Purpose

The production stack previously used `Now()` directly in higher-timeframe and cross-symbol publication contracts. That was valid only for live execution. During AmiBroker Bar Replay, `Now()` continues to represent the computer clock while the visible quote set is truncated at the replay position, so period validation could mix two different time bases.

Operational Clock v0.1 removes that ambiguity without changing Wyckoff/VSA methodology.

## Clock contract

`afl/WyckoffVSA_OperationalClock_v0.1.afl` is the single operational as-of source.

- `WCLK_ModeCode = 1` — LIVE SYSTEM. `WCLK_AsOfDateTime = Now(5)`.
- `WCLK_ModeCode = 2` — BAR REPLAY. `WCLK_AsOfDateTime = GetPlaybackDateTime()`.

`GetPlaybackDateTime()` returns zero when Bar Replay is inactive, so the mode switch is automatic.

The contract derives from the same as-of value:

- business-date key;
- current Weekly ordinal;
- current Monthly ordinal;
- expected previous completed Weekly ordinal;
- expected previous completed Monthly ordinal;
- clock-basis provenance.

## Updated consumers

### Timeframe Snapshot Publisher

All current/expected period ordinals are derived from WCLK. A snapshot written during Bar Replay is stamped with clock-basis code 2 and replay as-of publication time.

### Timeframe Snapshot Consumer

Expected Weekly/Monthly ordinals are derived from WCLK. The snapshot clock basis must equal the active consumer clock basis. This prevents a live snapshot generation from being silently reused as if it were a replay generation, and vice versa.

### Cross-Symbol Selection Context Publisher / Consumer

The current business date and publication time come from WCLK. In Bar Replay, a same-day replay-visible historical Daily bar receives explicit completion provenance code 3 (`BAR REPLAY POSITION`) instead of requiring the live EOD operator toggle.

The consumer accepts completion code 3 only while Bar Replay is active and only when snapshot clock basis is also BAR REPLAY.

Live behavior remains unchanged: a same-day Daily source still requires explicit operator completion declaration.

## Bar Replay operating order

At any replay position T:

1. Run the Weekly snapshot publisher at native Weekly interval. It publishes the calendar-completed week immediately preceding T.
2. Run the Monthly snapshot publisher at native Monthly interval. It publishes the calendar-completed month immediately preceding T.
3. Run the Market/Group cross-symbol publisher at native Daily interval. Its source data and completion checks are evaluated against T.
4. Run the Production Candidate Daily scan.

AmiBroker Bar Replay truncates formula-visible quote data at the playback position, so future quotes are not available to the engine. WCLK ensures the calendar/provenance side uses the same replay position instead of the real computer date.

## Persistent-state safety

Live and replay publications currently use the existing canonical StaticVar keys. Clock-basis provenance prevents a replay generation from being silently accepted in live mode and prevents a live generation from being silently accepted in replay mode.

Because replay publication may overwrite the latest live StaticVar generation, **after leaving Bar Replay the live Weekly, Monthly and Market/Group publishers must be rerun before a live Production Candidate scan is considered valid**. Until that is done the consumers should fail closed on clock-basis/provenance validation.

This behavior is intentional for v0.1 acceptance: correctness is preferred over silently reusing state created under a different clock basis.

## Native audit surface

Use `afl/WyckoffVSA_OperationalClock_Exploration_v0.1.afl` first with Bar Replay OFF and then with Bar Replay ON.

Expected live result:

- `Clock Mode Code = 1`
- `Bar Replay Active = 0`
- `Operational As-Of` = system time

Expected replay result:

- `Clock Mode Code = 2`
- `Bar Replay Active = 1`
- `Operational As-Of` = replay playback position, not the computer date

## Non-goals

This patch does not change:

- event definitions;
- Phase/Family inference;
- CandidateClass logic;
- RS methodology;
- P&F geometry or Cause/Objective rules;
- trading signals, ranking or risk management.

Status remains `NATIVE ACCEPTANCE PENDING` until the integrated stack is rerun in AmiBroker 6.20.01 in both live and Bar Replay modes.
