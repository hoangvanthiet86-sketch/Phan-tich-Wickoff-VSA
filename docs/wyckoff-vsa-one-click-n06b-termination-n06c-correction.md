# N06B Verify-Syntax termination and N06C correction

Native observation:
- N06A cache-contract-only probe = PASS.
- N04A market D/W/M + MTF/selection = PASS.
- N06B, which combined OneClickCacheContract helper functions with the heavy generated body, terminated AmiBroker 6.20.01 32-bit during Verify Syntax.

N06B is superseded and must not be rerun.

N06C correction:
- no OneClickCacheContract include;
- zero new cache user-defined functions;
- inline schema/fingerprint/prefix/metadata validation;
- inline writer lock + generation commit;
- heavy market path remains N04A-shaped;
- cold miss rebuild; warm hit bypasses heavy body.

The cache semantics remain the same as OneClickCacheContract v0.1; only the AFL compilation/orchestration form changes.
