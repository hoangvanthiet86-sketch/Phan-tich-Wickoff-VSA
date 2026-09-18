# N05D Verify-Syntax Crash and N05E Compact Boundary Plan

Native result: N05C verified without terminating AmiBroker; N05D terminated AmiBroker during Verify Syntax.

Passed/failed compile matrix:
- N04A: two generated-body sites + MTF/decision, no RS: native PASS.
- N04B: one generated-body site + RS: native PASS.
- N05C: one generated-body site + RS + MTF/decision: Verify Syntax stable.
- N05D: two generated-body sites + RS + MTF/decision + decision wrapper: Verify Syntax crashes AmiBroker 6.20.01 32-bit.

Therefore N05D is superseded. We will not ask the owner to rerun it.

N05E reduces the next test to one generated-body include and a compact six-context switching shell, with NO RS execution yet. This isolates whether the orchestration shell itself is compiler-safe before RS is reintroduced.

Safety: Verify Syntax only; no Explore.