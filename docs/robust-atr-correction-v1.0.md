# Robust ATR Correction Specification v1.0 — Final

**Status:** APPROVED FOR CORE PATCH  
**Target:** AmiBroker 6.20+  
**Validation basis:** Controlled runtime acceptance through Harness v5 (24/24 checkpoints PASS)  
**Scope:** ATR validity, ATR state recovery, and the denominator used by DirectionalProgress only

## Purpose and locked meaning

Built-in `ATR()` may remain positive but numerically contaminated after invalid synthetic H/L/C observations. This correction replaces only the ATR state used by `DirectionalProgress`; RVOL, RSpread, ClosePosition, thresholds, state codes, and all non-ATR semantics remain locked.

```text
DirectionalProgress_t = (Close_t - Close_(t-1)) / PriorATR_t
ATRCurrent = RobustATR
PriorATR = Ref(ATRCurrent, -1)
```

## Robust True Range

Current structure is valid only when High/Low/Close are non-Null, Close is positive, High is not below Low, and Close is inside `[Low, High]`. Open is deliberately irrelevant.

At BarIndex 0, valid `RobustTR = High - Low`; it participates in the seed. After bar zero, PreviousClose must be non-Null and positive:

```text
RobustTR = max(High - Low, abs(High - PreviousClose), abs(Low - PreviousClose))
```

Zero True Range is valid.

## Robust Wilder state machine

Let `P = ATRPeriod` (default 14). The same state machine applies at startup and after errors.

1. **Seed collection:** collect and sum P consecutive valid RobustTR values. At exactly P, `InternalSeed = sum / P`; visible RobustATR remains Null.
2. **First visible ATR:** on valid observation P+1, `RobustATR = (InternalSeed * (P - 1) + RobustTR) / P`.
3. **Continuation:** later valid observations use `(PreviousRobustATR * (P - 1) + RobustTR) / P`.
4. **Invalid input:** RobustTR/RobustATR become Null and seed sum, valid count, seed-ready state, active state, and active ATR are cleared. No forward-fill, interpolation, skip, cap, or old-state continuation is allowed.

For uninterrupted P=14 data, bars 0..13 build the seed, bar 13 has no visible ATR, bar 14 has first visible RobustATR, and bar 15 first has PriorATR. After an invalid bar 100, bars 101..114 seed, 115 is first visible, and 116 may resume DirectionalProgress.

## Dependency semantics

- Invalid current H/L with valid Close resets current RobustATR, while same-bar DirectionalProgress may remain valid through PriorATR.
- Invalid current Close makes current RobustATR and DirectionalProgress Null; next-bar TR is also invalid because PreviousClose is invalid.
- `High < Low` and Close outside `[Low, High]` reset state.
- `High = Low = Close` is valid zero TR and does not reset state.
- Null Open does not invalidate ATR.

```text
PriorATRWarm = BarNumber >= ATRPeriod
PriorATRValid = PriorATRWarm AND NOT IsNull(PriorATR) AND PriorATR > 0
```

Warm is eligibility only; it may be true during recovery while PriorATRValid is false.

## Clean-data parity and causality

On uninterrupted clean data, `abs(RobustATR - AmiBroker ATR(ATRPeriod)) <= 0.00001`. No positive `Ref()`, lookahead construct, current ATR denominator, or change to the DirectionalProgress numerator is permitted.

## Explicit non-goals

This correction does not modify RVOL, RSpread, ClosePosition, Effort/Directional Result thresholds, threshold validation, state bands, or code 10. It adds no event detector, phase detector, trading signal, score, backtest, position sizing, or ATR price cap.

## Runtime acceptance status

Harness v5 approved the design with 24/24 checkpoints, but the patched Core still requires local AmiBroker compilation, Exploration, clean-data parity, invalid-data recovery, no-lookahead, and completed-bar regression. Core Engine final runtime approval is not yet granted.

## Required static invariants

1. Every existing `Ref()` remains non-forward-looking and no positive offset is introduced.
2. DirectionalProgress continues to use PriorATR, never current ATR.
3. Prior-only RVOL and RSpread formulas remain unchanged.
4. ClosePosition, threshold logic, descriptive bands, and invalid-config code 10 remain unchanged.
5. No Buy/Sell variable, trading arrow, event logic, score, or backtest rule is introduced.

## Required patched-Core runtime regression

The patch still requires AmiBroker 6.20.01 syntax verification, Exploration execution, normal SHB regression, clean-data RobustATR parity within tolerance, controlled invalid-data recovery, no-lookahead/non-repaint validation, and completed-bar validation. Harness approval of the design is not final patched-Core runtime approval.

Clean-data Harness v5 checkpoints passed at BarIndex 14, 20, 30, 60, and 90 with zero or sub-millionth-scale differences.

## Acceptance record

```text
24 / 24 checkpoints PASS
Overall Failed Tests = 0
OVERALL PASS = 1

ROBUST ATR DESIGN              = APPROVED
CORE PATCH AUTHORIZATION       = APPROVED
CORE ENGINE FINAL RUNTIME PASS = NOT YET
```
