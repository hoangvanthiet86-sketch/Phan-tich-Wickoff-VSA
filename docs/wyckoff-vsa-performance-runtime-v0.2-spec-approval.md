# Wyckoff VSA Performance Runtime v0.2 — Owner Approval Record

**Status:** OWNER APPROVED  
**Approved specification:** `docs/wyckoff-vsa-performance-runtime-v0.2-spec-draft.md`  
**Specification commit:** `2ddba24e0322c68edcd0cb8b4130ecbbfc226c87`  
**Approval date:** 2026-09-12

## Approval scope

Owner approval covers the Performance Runtime v0.2 architecture and contracts defined in the approved specification, including:

- Publisher → persistent snapshot → Fast Scanner → Deep Review/P&F architecture;
- result-preservation invariant;
- correctness exception requiring correction-spec + native evidence;
- causal/no-lookahead equivalence;
- fail-closed snapshot validation;
- runtime profiles;
- centralized Parameter authority;
- hierarchical visible Parameter IDs;
- operational defaults;
- stable Parameter IDs while retaining editability of legitimate configurable values;
- regression and AmiBroker 6.20.01 native acceptance requirements.

## Non-negotiable result-preservation rule

Implementation v0.2 MAY change internal calculation method, algorithm, AFL statements, loops, array/scalar implementation, cache/snapshot mechanism, file organization, and execution strategy.

Implementation v0.2 MUST NOT change analytical results or the decision surface when the same input data and equivalent configuration are used.

A result difference is permitted only when the legacy implementation is demonstrated to be wrong. Any such correction requires a reproducible case, root cause, specification/correction note, AmiBroker native test, and bounded regression evidence before acceptance.

## Development gate

This approval authorizes the next design step: build the exact v0.1 → v0.2 Parameter mapping and implementation plan.

It does **not** authorize silently changing canonical analytical semantics, merging to `main`, creating a release/tag, or claiming native PASS before AmiBroker evidence exists.
