# Wyckoff VSA One-Click v0.1 — N05D Safe Full-Decision Gate

N05C compile-boundary probe verified without terminating AmiBroker. Therefore the analytical body + RS + MTF + ScannerDecision include set is compile-safe.

N05D replaces the superseded N05/N05.1 wrappers.

Architecture:
- two textual generated-body sites, matching native-passing N04A;
- stock loop order W -> M -> D, leaving Daily live for RS;
- RS executes after stock Daily;
- market loop D -> W -> M;
- compact default-profile decision surface.

Safety sequence:
1. Verify Syntax only.
2. If zero errors and AmiBroker remains open, run SNZ / Daily / 1 Recent Bar / 1.3=Khong.

Expected control if 2026-09-18 data are unchanged:
- Config Valid 1
- RS Valid 1 / Status 0 / Structure 3
- Market Foreign OK 1
- Stock MTF Valid 1
- Market MTF Valid 1
- Data Eligible 1
- Exclusion Mask 0
- Review 1
- Candidate Class 9
- Reference Class 9
- Kernel Class Match 1
- Qualified/Developing/Watch 0/0/0.