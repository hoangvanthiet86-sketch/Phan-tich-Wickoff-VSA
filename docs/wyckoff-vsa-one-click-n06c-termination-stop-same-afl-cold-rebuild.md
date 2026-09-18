# N06C native termination — stop same-AFL cold rebuild path

Native owner report: N06C still terminates AmiBroker 6.20.01 32-bit during Verify Syntax/check-time execution.

This closes the experimental branch that attempted to self-heal a cold market cache from inside the same heavy AFL formula.

Evidence matrix:
- N04A heavy market context alone: stable / PASS.
- N04C Daily + RS: stable / PASS.
- N06A cache contract alone: stable / PASS.
- combining cold-rebuild/cache/orchestration domains in N05/N06 variants repeatedly terminates the target 32-bit process.

Decision:
`ONE_CLICK_EXECUTION_FORM_V01 = NATIVE_BATCH_PRODUCER_CONSUMER`

No further N05/N06 cold-rebuild-in-one-AFL variants are authorized unless the native target changes or new evidence removes the 32-bit constraint.
