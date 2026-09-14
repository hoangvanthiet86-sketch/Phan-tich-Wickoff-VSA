# Wyckoff VSA Historical Scanner v0.1 — Phe duyet dac ta va chinh sach hien thi

Ngay phe duyet: 14/09/2026.

## 1. Trang thai phe duyet

Chu du an da phe duyet `docs/wyckoff-vsa-historical-scanner-v0.1-spec.md` de tiep tuc trien khai theo thu tu H1 -> H2 -> H3 -> H4 -> H5 -> H6.

Khong duoc mo rong pham vi sang trading backtest/P&L truoc khi Historical Scanner v0.1 dat cac checkpoint no-lookahead va terminal-date equivalence theo dac ta.

## 2. CHINH SACH HIEN THI BAT BUOC — TIENG VIET TOAN BO

Tu checkpoint nay, moi giao dien huong toi nguoi dung cua cac bo loc/AFL moi hoac duoc sua trong du an phai hien thi hoan toan bang tieng Viet de de hieu.

Do AmiBroker 6.20.01 da tung gap loi ma hoa voi dau tieng Viet, lop hien thi trong AFL su dung **tieng Viet khong dau (ASCII)** cho toi khi co mot checkpoint native rieng chung minh Unicode hien thi on dinh.

Pham vi bat buoc gom:

1. Ten nhom trong cua so `Parameters`.
2. Ten tung tham so `Param`, `ParamToggle`, `ParamList`, `ParamStr`.
3. Lua chon hien thi cua `ParamToggle` / `ParamList`.
4. Tieu de cot Exploration.
5. Chuoi trang thai, canh bao, ly do chan, mo ta ket qua.
6. Ten che do loc va huong dan van hanh hien tren AFL.
7. Panel/chart text neu co.

Khong de lai nhan giao dien kieu `RUN MODE`, `Production Filter`, `Treat Last Bar As Provisional`, `Volume Lookback`, `Market Benchmark`, `Group Benchmark`, `Adjustment Basis` neu chung la thong tin nguoi dung truc tiep nhin thay.

Vi du cach dat nhan moi:

- `01. CHE DO CHAY`
- `1.1 Ho so chay: 0=Quet nhanh hang ngay 1=Ra soat sau 2=Kiem toan / Hoi quy`
- `1.2 Bo loc san xuat: 0=Dat chuan 1=Dang phat trien+ 2=Theo doi+ 3=Ra soat 4=Tat ca du dieu kien 5=Ra soat P&F`
- `1.3 Xem thanh cuoi la tam thoi`
- `02. DU LIEU VSA`
- `2.1 So phien nhin lai khoi luong`
- `2.2 So phien nhin lai bien do`
- `2.3 Chu ky ATR`
- `03. CAU TRUC / VI TRI`
- `3.4 So thanh ben trai cua pivot`
- `3.5 So thanh ben phai cua pivot`
- `06. SUC MANH TUONG DOI`
- `6.1 Chi so thi truong doi chieu`
- `6.2 Chi so nhom doi chieu`
- `6.3 Khai bao co so dieu chinh`
- `6.4 Trang thai co so dieu chinh: 0=Chua xac minh 1=Da khai bao tuong thich 2=Khong tuong thich`
- `07. BOI CANH THI TRUONG / NHOM`
- `7.1 Chi so thi truong dung cho boi canh`

## 3. Quy tac ky thuat khi doi ten Parameters

Ten tham so trong AmiBroker co the anh huong den viec luu/gian tiep phuc hoi gia tri Parameters. Vi vay:

- khong doi nhan Parameters production hang loat ma khong co regression;
- moi patch dich giao dien production phai giu nguyen default, min/max/step, thu tu va y nghia gia tri;
- phai doi chieu output truoc/sau de chung minh decision surface khong doi;
- neu viec doi nhan lam AmiBroker reset gia tri da luu, phai ghi ro va cung cap mapping/cau hinh khoi phuc;
- thay doi nay la PRESENTATION-ONLY, khong duoc thay threshold/methodology.

## 4. Acceptance bo sung cho Historical Scanner

### HS14 — Vietnamese-only user-visible UI

PASS chi khi toan bo nhan nguoi dung nhin thay cua Historical Scanner/H2 proof harness da dung tieng Viet khong dau, bao gom cua so `Parameters`, Exploration columns va status text.

Khong chap nhan giao dien tron Anh-Viet ngoai tru identifier ky thuat bat buoc nhu `ATR`, `VSA`, `MTF`, `RS`, `P&F`, ma co phieu va ten file/version.

## 5. Tiep tuc trien khai

Sau approval nay, buoc hop le tiep theo la:

- H1 Source Causality Audit;
- H2 Historical MTF proof harness.

Tat ca AFL moi cua H2 phai tuan thu HS14 ngay tu ban dau.
