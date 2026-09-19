# Wyckoff VSA One-Click v0.1 — Native Batch assembly protocol

Target batch:
`E:\\WyckoffVSA\\batch\\WVSA_OneClick_v0.1.abb`

Required APX files, in strict execution order:

1. `WVSA_OC_01_TF_WEEKLY_STOCK.apx`
2. `WVSA_OC_02_TF_MONTHLY_STOCK.apx`
3. `WVSA_OC_03_TF_WEEKLY_VNINDEX.apx`
4. `WVSA_OC_04_TF_MONTHLY_VNINDEX.apx`
5. `WVSA_OC_05_SELECTION_VNINDEX_DAILY.apx`
6. `WVSA_OC_06_DAILY_PUBLISHER_STOCK.apx`
7. `WVSA_OC_07_FAST_SCANNER_STOCK.apx`

For each APX pair add:
- Load Analysis Project
- Explore

Therefore the batch contains 14 steps.

First native acceptance run:
- execute the batch manually from the Batch window;
- every step must finish as Completed;
- do not add Export or launcher automation until the 14-step chain itself passes;
- after completion, inspect the final Fast Scanner result and compare it to the direct APX 07 result for the same visible as-of date.

Only after this gate passes:
- save the .ABB;
- add optional export/logging;
- validate AFL `ShellExecute("runbatch", ...)` launcher;
- proceed to current/replay no-lookahead acceptance.
