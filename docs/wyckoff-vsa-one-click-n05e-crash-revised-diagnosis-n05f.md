# N05E Verify-Syntax Crash — Revised Diagnosis and N05F

Native observation: N05E also terminated AmiBroker during Verify Syntax.

Important correction: AmiBroker's own Knowledge Base states that Verify Syntax executes the formula using up to 200 recent bars. Therefore these terminations cannot be classified as parser/compiler-only from UI behavior alone; check-time formula execution is also in scope.

Empirical project pattern:
- PASS/stable: N04A, N04B, N05C — no new wrapper user-defined functions.
- TERMINATED: N05, N05.1, N05D, N05E — every one introduced at least one additional wrapper user-defined function.

N05F therefore:
- defines ZERO new user-defined functions;
- uses N04A-style market and stock loops;
- executes market D/W/M first;
- executes stock W/M/D second with stock Daily last;
- executes RS only after all generated-body executions;
- then runs MTF / Market Selection / compact Candidate Decision.

Safety: first action is Verify Syntax only.