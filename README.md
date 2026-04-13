# POS Ban hang Flutter

Ung dung POS/billing offline duoc xay dung bang Flutter, phuc vu quy trinh ban hang tai cua hang nho va vua. App ho tro quet ma vach bang camera, quan ly san pham, luu du lieu offline bang Hive va in hoa don qua may in nhiet Bluetooth.

## Tinh nang chinh

- Quan ly san pham: them, sua, xoa, tim kiem theo ten hoac ma vach.
- Quet ma vach bang camera de dua san pham vao gio hang nhanh.
- Thanh toan va in hoa don truc tiep tu thiet bi di dong.
- Cau hinh thong tin cua hang de hien thi tren hoa don.
- Luu tru du lieu offline, khong phu thuoc Internet de van hanh co ban.

## Cong nghe su dung

- Flutter
- flutter_bloc
- go_router
- get_it
- Hive / hive_flutter
- fpdart
- mobile_scanner
- print_bluetooth_thermal
- pretty_qr_code

## Cau truc thu muc

```text
lib/
├── core/
│   ├── data/                # Khoi tao Hive, du lieu dung chung
│   ├── error/               # Failure / error model
│   ├── theme/               # Theme giao dien
│   ├── usecase/             # Base usecase
│   ├── utils/               # Helper, printer helper, validator...
│   ├── widgets/             # Widget dung chung
│   └── service_locator.dart # Dang ky dependency voi get_it
└── features/
    ├── billing/             # Quet ma, gio hang, thanh toan, in hoa don
    ├── product/             # Quan ly san pham
    ├── settings/            # Ket noi may in, cai dat
    └── shop/                # Thong tin cua hang
```

Moi feature duoc chia theo cac lop `data`, `domain`, `presentation`.

## Yeu cau moi truong

- Flutter SDK `>=3.1.0`
- Dart di kem Flutter
- Android Studio hoac VS Code + Flutter extension
- Neu build iOS: can macOS + Xcode
- Neu test in thuc te: can dien thoai that va may in nhiet Bluetooth

## Cai dat va chay du an

### 1. Lay source code

```bash
git clone <repository_url>
cd billing_app
```

### 2. Cai dependency

```bash
flutter pub get
```

### 3. Chay code generation

Du an dung Hive generator va JSON serialization, vi vay can chay:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Neu ban thay doi model / adapter va can tao lai file sinh tu dong, hay chay lai lenh nay.

### 4. Chay app

```bash
flutter run
```

Neu muon chay tren thiet bi cu the:

```bash
flutter devices
flutter run -d <device_id>
```

## Build ban phat hanh

### Android APK

```bash
flutter build apk --release
```

File output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle

```bash
flutter build appbundle --release
```

File output:

```text
build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
flutter build ios --release
```

Luu y: build iOS can thuc hien tren macOS co cai Xcode.

## Huong dan cau hinh app sau khi cai dat

### 1. Cau hinh thong tin cua hang

Vao:

`Cai dat` -> `Thong tin cua hang`

Nhap cac truong:

- Ten cua hang
- Dia chi dong 1
- Dia chi dong 2 (khong bat buoc)
- So dien thoai
- Ma UPI (khong bat buoc)
- Noi dung chan hoa don

Sau do bam `Luu thong tin`.

### 2. Cau hinh QR thanh toan

App hien tai tao QR thanh toan theo dinh dang UPI va gia tri tien te `INR`.

- Neu truong `Ma UPI` de trong, khu vuc QR thanh toan se khong hien thi.
- Neu ban can chuyen sang he thong QR ngan hang/VietQR, can sua phan logic sinh QR trong man hinh thanh toan.

### 3. Ket noi may in Bluetooth

Vao:

`Cai dat` -> `Thiet bi in`

Thuc hien theo thu tu:

1. Bat Bluetooth tren dien thoai.
2. Ghep doi may in trong phan cai dat Bluetooth cua he dieu hanh.
3. Quay lai app.
4. Nhan nut lam moi trong man hinh `Thiet bi in`.
5. App se quet danh sach thiet bi da ghep doi va thu ket noi.

Neu ket noi thanh cong, app se luu:

- `printer_mac`
- `printer_name`

vao Hive de tu dong su dung lai cho lan sau.

## Quyen truy cap can cap

App co the yeu cau cac quyen sau:

- Camera: de quet ma vach
- Bluetooth: de ket noi may in nhiet
- Vi tri: can cho mot so thiet bi Android khi quet thiet bi Bluetooth

Neu app khong tim thay may in, hay kiem tra lai:

- Bluetooth da bat chua
- May in da ghep doi trong he dieu hanh chua
- Quyen Bluetooth / vi tri da duoc cap chua

## Luu tru du lieu

App su dung Hive de luu du lieu local tren thiet bi:

- Danh sach san pham
- Thong tin cua hang
- Cau hinh may in

Dieu nay giup app hoat dong offline trong nhieu truong hop co ket noi mang kem on dinh.

## Kiem tra chat luong ma nguon

### Phan tich loi / warning

```bash
flutter analyze
```

### Chay test

```bash
flutter test
```

## Luu y khi in tieng Viet

Giao dien app da duoc Viet hoa, tuy nhien viec in dau tieng Viet tren may in nhiet phu thuoc vao:

- model may in
- bang ma ky tu ma may in ho tro
- cach xu ly encoding cua firmware may in

Trong implementation hien tai, helper in dang gui raw bytes don gian. Vi vay mot so may in co the khong hien thi dung cac ky tu co dau. Neu ban can hoa don tieng Viet day du co dau, nen:

- dung may in ho tro Unicode / UTF-8 hoac bang ma phu hop
- hoac nang cap lop in de map bang ma ESC/POS tuong ung voi model may in

## Quy trinh su dung nhanh

1. Vao `Cai dat` de cap nhat thong tin cua hang.
2. Ket noi may in Bluetooth.
3. Vao `San pham` de them danh muc.
4. Quay lai man hinh chinh de quet ma vach.
5. Bam `Xem don hang` -> `In hoa don`.

## Gop y phat trien

Khi mo rong du an, nen giu dung cau truc hien tai:

- `domain` khong phu thuoc truc tiep vao UI
- `data` xu ly repository / datasource
- `presentation` xu ly bloc va man hinh
- State nen bat bien va su dung `equatable`
