# Wyckoff VSA One-Click v0.1 — N05F termination and architecture pivot

Native result: N05F also terminated AmiBroker 6.20.01 32-bit during Verify Syntax.

Decision:
- stop all further N05 full-runtime-in-one-evaluation variants;
- do not ask the owner to rerun N05/N05.1/N05D/N05E/N05F;
- retain already passed N03/N04A/N04C evidence;
- move implementation to the locked `HYBRID_SELF_HEALING_CACHE` architecture.

Rationale:
- N04A proves stock+market D/W/M+MTF works without RS;
- N04C proves Daily+RS exact equivalence;
- combining the full workloads in one evaluation is not operationally stable on the target AmiBroker 6.20.01 32-bit;
- cache domains were explicitly designed to avoid repeating those full workloads on every symbol/evaluation.

Next native gate:
`WyckoffVSA_OneClick_N06A_CacheContractNativeProbe_v0.1.afl`

N06A is infrastructure-only and intentionally contains:
- no generated analytical body;
- no RS;
- no Market Scanner runtime;
- no candidate methodology.

It validates:
- atomic writer lock / generation commit;
- decision as-of invalidation;
- weekly/monthly completed-period invalidation;
- shared market cache date + W/M ordinal invalidation;
- analytical fingerprint binding.
