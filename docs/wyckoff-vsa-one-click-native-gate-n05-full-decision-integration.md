# Wyckoff VSA One-Click v0.1 — Native Gate N05: Full Candidate Decision Integration

Prerequisites locked:
- N03 unified stock D/W/M = PASS
- N04A stock + VNINDEX D/W/M + MTF = PASS
- N04C RS exact equivalence = PASS

Scope:
- default production profile, no Group symbol;
- no publisher and no snapshot warm-up;
- direct stock D/W/M + RS + VNINDEX D/W/M + MTF + Market Selection + Candidate Decision.

Run:
- SNZ only
- Daily
- 1 Recent Bar
- RuntimeConfig defaults
- last bar provisional = No

Required sanity:
- Config Valid = 1
- W Ord and M Ord equal OperationalClock completed periods
- Stock MTF Valid = 1
- RS Valid = 1, Status = 0
- Market Foreign OK = 1
- Market MTF Valid = 1
- Market Config Match = 1
- Role Conflict = 0
- Data Eligible = 1
- Exclusion Mask = 0
- Kernel Class Match = 1

Expected SNZ state on the 2026-09-18 control, if data do not change:
- RS Structure = 3
- Market Selection = 1
- Candidate Stage = 1
- Review = 1
- Candidate Class = 9
- Candidate Side = 0
- Qualified/Developing/Watch = 0/0/0.

PASS checkpoint:
`ONE_CLICK_NATIVE_N05_FULL_DECISION_INTEGRATION = PASS`