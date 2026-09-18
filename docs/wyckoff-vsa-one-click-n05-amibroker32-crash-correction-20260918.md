# Wyckoff VSA One-Click v0.1 — N05 AmiBroker 32-bit Crash Correction

Native owner report: opening/running the initial N05 probe repeatedly terminated AmiBroker.

Root cause in source structure:
- initial N05 contained SIX textual `#include <WyckoffVSA_OneClickContextBody_Generated_v0.1.afl>` sites;
- the generated analytical body is approximately 300 KB before AFL compile expansion and contains multiple state-machine loops;
- six expansions violated the previously selected re-entrant architecture and created excessive formula expansion pressure for AmiBroker 6.20.01 32-bit.

Correction v0.1.1:
- exactly ONE textual generated-body include;
- execute six runtime contexts sequentially through a case loop;
- order: stock W, stock M, market D, market W, market M, stock D;
- stock D runs last so its SL/WCI arrays remain live for the already validated OneClick RS kernel;
- no methodology, thresholds, or decision mapping changed.

Safety:
- initial N05 is superseded and must not be rerun;
- first native action for corrected N05 is Verify Syntax only;
- Explore is allowed only after Verify Syntax returns zero errors.

Checkpoint remains pending until corrected N05 passes natively.