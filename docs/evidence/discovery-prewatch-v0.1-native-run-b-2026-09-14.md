# Discovery / Pre-Watch v0.1 — Native Run B Evidence

**Ngay:** 14/09/2026

**Moi truong:** AmiBroker 6.20.01, Daily, `VN STOCKS ONLY`, `1 recent bar`.

**Che do:** `Discovery: che do hien thi = Tat ca Discovery`.

**Snapshot:** 11/09/2026.

## Ket qua tong hop

TXT export native co 136 dong, 136 ticker duy nhat.

Phan bo dung checkpoint:

- `PRE_WATCH_NEAR` = 42
- `DISCOVERY_REVIEW_ONLY` = 93
- `PRODUCTION_WATCH_REFERENCE` = 1
- tong `DiscoveryBase` = 136

Tat ca 136 dong deu:

- `Candidate Stage = 1`;
- RS vs Market thuoc {RISING, FALLING};
- phien ban `DISCOVERY_PREWATCH_V01_20260914_A`;
- hien thi Vietnamese ASCII khong dau.

## SNZ continuity

`SNZ` xuat hien dung mot lan va giu nguyen Production semantics:

- Discovery = `Production Watch - doi chieu`;
- Production Candidate Class = `Theo doi` / WATCH;
- Production Review = `Khong`;
- Stage = 1;
- Phase = B;
- Family = unresolved lower range;
- Range Position = 35.0%;
- MTF = insufficient;
- RS vs Market = falling;
- Method Block Mask = 7;
- range-location conflict = 0;
- range-location coherent = 1.

Discovery khong doi SNZ thanh Pre-Watch.

## Hard-concern separation

Trong 93 dong `DISCOVERY_REVIEW_ONLY`:

- bit 1024 / A-B range-location conflict: 81
- bit 32 / VSA mixed-conflicting: 44
- bit 64 / Price-RS non-confirmation: 12
- bit 16 / RS insufficient-mixed: 0
- bit 128 / Group leadership conflict: 0
- bit 512 / Market-Group config conflict: 0

Co overlap giua cac bit tren.

42 dong `PRE_WATCH_NEAR` khong co bat ky hard-concern bit {16,32,64,128,512,1024}; khong co MTF code 4/5.

## Native checkpoints

- DP-N04 Audit count: PASS 136/136
- DP-N05 Audit distribution: PASS 42/93/1
- DP-N06 SNZ continuity: PASS
- DP-N07 Hard concern exclusion: PASS
- DP-N08 MTF hard conflict exclusion: PASS
- DP-N09 MTF code 6 allowed: PASS
- DP-N10 Stage gate: PASS 136/136
- DP-N11 RS gate: PASS 136/136
- DP-N14 Presentation: PASS

Checkpoint:

`DISCOVERY_PREWATCH_V01_NATIVE_RUN_B = PASS_136_OF_136`

## Con lai

Chua danh dau full native PASS cho den khi chay production regression sau Discovery de xac minh DP-N12 va DP-N13 tren cung snapshot, khong can chay lai DailyPublisher.
