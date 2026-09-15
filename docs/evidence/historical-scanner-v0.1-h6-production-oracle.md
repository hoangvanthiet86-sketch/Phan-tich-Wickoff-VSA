# Historical Scanner v0.1 — H6 Production Oracle

Date: 2026-09-14
Target business date: 11/09/2026.

## Nguon production da merge

1. `docs/wyckoff-vsa-performance-runtime-v0.2-native-equivalence-20260912.md`
   - 1,558/1,558 decision-surface equivalence PASS.
   - DTP: Review, method mask `1031`, range position xap xi `-2.3027`.
   - FRT: Review, method mask `1031`, range position xap xi `-0.7363`.
   - SNZ: Watch, method mask `7`, range position `0.3500`.

2. `docs/evidence/performance-runtime-v0.2-vn-stocks-only-u4-functional-native-2026-09-13.md`
   - watchlist `VN STOCKS ONLY`: 1,668 symbols.
   - Daily Publisher: 1,668/1,668 committed, Business DateNum `1260911`.
   - Production Data Eligible: 1,066 symbols.
   - Fast Scanner: exact 1,066 eligible stock symbols.
   - zero mismatch tren 12 overlapping fields.
   - stock-only distribution: class 9 = 1,051; class 1 = 14; class 2 = 1; Watch duy nhat = SNZ.

## H6-B control oracle da resolve

DTP va FRT khong con o trang thai `NOT_VERIFIED` cho cac field ma evidence production thuc su khoa:

- Candidate Class = Review / class 9.
- Scanner Review = 1.
- Method Block Mask = 1031.
- DTP Range Position xap xi -2.3027.
- FRT Range Position xap xi -0.7363.

Do evidence chi ghi `about` cho Range Position DTP/FRT, H6 control check chi dung tolerance `0.005` quanh reference xap xi. Day chi la check voi reference evidence. So sanh historical-vs-production trong H6-C van dung tolerance float `0.0001` va khong noi decision rule.

Khong tu suy doan Side/Stage/Phase/Family/MTF/RS cua DTP/FRT tu evidence nay. Cac field do phai duoc doi chieu truc tiep historical-vs-production snapshot tai H6-C.

## H6-C universe oracle

Business DateNum production: `1260911`.

Expected production Data Eligible symbol count: `1066`.

Exact comparison surface:
- DataEligible
- CandidateClass
- CandidateSide
- CandidateStage
- Phase
- Family
- RangePosition
- MTFAlignment
- RSvsMarket
- ScannerReview
- MethodBlockMask
- Market selection context

Neu symbol set hoac field khac, phai xuat mismatch report; khong duoc tuyen bo PASS.
