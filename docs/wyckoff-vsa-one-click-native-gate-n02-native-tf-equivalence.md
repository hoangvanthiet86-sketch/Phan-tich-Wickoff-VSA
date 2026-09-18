# Wyckoff VSA One-Click v0.1 — Native Gate N02: Native Weekly/Monthly Equivalence

Goal: prove generated body matches canonical Runtime v0.2 when both run in native Weekly and native Monthly periodicities.

Control symbol: SNZ.

Run generated probe and canonical oracle twice each:

1. Periodicity = Weekly, Range = 1 Recent Bar, 1.3 = Khong.
2. Periodicity = Monthly, Range = 1 Recent Bar, 1.3 = Khong.

Both formulas select the expected completed period internally, so the displayed row is the current visible bar carrying scalar payload from the completed W/M source period.

Required:
- Config Valid = 1
- Interval Valid = 1
- Completed Period Found = 1
- Expected Completed Ordinal == Selected Source Ordinal
- exact equality on locked Composite/PublicActive surface between generated and canonical.

N02 PASS only if Weekly and Monthly both have zero mismatches.

`ONE_CLICK_NATIVE_N02_NATIVE_TF_EQUIVALENCE = PASS`