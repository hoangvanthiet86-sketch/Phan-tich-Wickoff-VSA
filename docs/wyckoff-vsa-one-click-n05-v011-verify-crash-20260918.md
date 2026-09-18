# Wyckoff VSA One-Click v0.1 — N05 v0.1.1 Verify-Syntax Crash

Owner report: AmiBroker 6.20.01 32-bit still terminates completely during Verify Syntax on corrected N05 v0.1.1.

Implication:
- this is a compiler/parser process crash, not an AFL runtime result;
- N05 v0.1 and v0.1.1 are superseded and must not be rerun;
- the six-include expansion problem in v0.1 was real, but reducing to one body include was not sufficient;
- next action is compile-boundary isolation using the already native-passing N04B shape plus only the small MTF and ScannerDecision kernels.

Safety protocol:
- next probe is Verify Syntax only;
- no Explore until the compile boundary is known stable;
- if the boundary probe passes, the crash is in the large N05 orchestration wrapper, not in the validated body/RS/MTF/decision kernels;
- if it crashes, the combined include set crosses an AmiBroker 32-bit compiler boundary and the production architecture must isolate one or more kernels behind a smaller generated artifact.