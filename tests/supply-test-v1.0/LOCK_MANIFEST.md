# Supply Test v1.0 — Lock manifest

Các artefact dưới đây được khóa **trước khi có AFL Event**.

- `docs/wyckoff-event-supply-test-v1.0-spec.md` — đặc tả chính thức cho giai đoạn mô hình/fixture.
- `tests/wyckoff-event-supply-test-v1.0-test-plan.md` — kế hoạch kiểm thử đã khóa.
- `tests/supply-test-v1.0/reference_model.py` — mô hình tham chiếu độc lập. SHA-256 cục bộ: `447eb6a28fec869179951b330952b820818d292f610d645e3b197fc4242e146e`.
- `tests/supply-test-v1.0/fixtures.json` — 20 fixture ban đầu. SHA-256 cục bộ: `7df333444f69a7d347b575e77c4435089aac17f0468b58cf9879ba9d1f74e9c6`.
- `tests/supply-test-v1.0/expected.json` — expected sinh từ mô hình đã khóa và kiểm tra các bất biến biên/xác nhận/chồng lấn/không xác nhận muộn. SHA-256 cục bộ: `89e455285f00ec8472d6c6dd5753d0f64f4a9fed8cf6d43a8d2860d553508ccd`.

Nguồn upstream khóa tại thời điểm thiết kế:

- Core blob `c03a9599a246849d562ea162975f202781049f90`.
- Candidate blob `589575722c2e2188513f635f089fd97ed2ee7b59`.
- Structure/Location blob `f54fd8c24c7cb21beb4966737120b3e3b516e699`.
- Confirmation blob `48061c9dd763814dc31f27e1dcf19ed61065aee5`.
- main nền `c31e61fccdd7867f417bc036c3b9705c0256dc53`.

Không được sửa expected sau khi xem kết quả AFL chỉ để ép PASS. Mọi thay đổi đặc tả/ngưỡng 0,50 ATR sau khóa phải có quyết định riêng và kéo theo tái tạo fixture/expected trước khi tiếp tục lập trình.