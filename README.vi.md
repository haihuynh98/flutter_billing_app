# Billing App - Huong dan tieng Viet

Ung dung Flutter ho tro ban hang/tinh tien offline, quet ma vach bang camera va in hoa don qua may in Bluetooth.

## 1) Yeu cau moi truong

- Flutter SDK >= 3.1.0
- Dart SDK di kem Flutter
- Android Studio (khuyen nghi cho Android)
- Xcode (neu build iOS/macOS)
- Thiet bi Android that (khuyen nghi de test Bluetooth/may in)

Kiem tra moi truong:

```bash
flutter doctor
```

## 2) Cai dat du an

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

> Lenh `build_runner` can thiet de tao code cho Hive adapter va JSON serialization.

## 3) Chay ung dung

```bash
flutter run
```

Neu muon chay tren thiet bi cu the:

```bash
flutter devices
flutter run -d <device_id>
```

## 4) Build ban phat hanh

### Android APK

```bash
flutter build apk --release
```

File ket qua:

`build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (Play Store)

```bash
flutter build appbundle --release
```

File ket qua:

`build/app/outputs/bundle/release/app-release.aab`

### iOS (neu cau hinh du chung chi)

```bash
flutter build ios --release
```

## 5) Cau hinh va su dung trong app

### 5.1 Quan ly san pham

1. Vao **Cai dat** -> **San pham**
2. Them san pham moi (Ten, Ma vach, Gia)
3. Co the bam icon quet de lay ma vach tu camera

### 5.2 Cau hinh thong tin cua hang

1. Vao **Cai dat** -> **Thong tin cua hang**
2. Cap nhat:
   - Ten cua hang
   - Dia chi dong 1, dong 2
   - So dien thoai
   - UPI ID (neu co)
   - Noi dung chan hoa don
3. Bam **Luu thong tin**

### 5.3 Ket noi may in Bluetooth

1. Vao **Cai dat** -> **May in**
2. Bam icon banh rang de mo trang cai dat Bluetooth cua dien thoai
3. Ghep doi (pair) may in trong he thong
4. Quay lai app, bam icon **Lam moi** de app quet va ket noi may in
5. Khi thanh cong, trang thai may in se hien thi **DA KET NOI**

> Neu app hoi quyen Bluetooth/Location, can cap quyen day du de quet va ket noi.

### 5.4 Quy trinh tinh tien

1. O man hinh chinh, dua ma vach vao khung quet
2. San pham se duoc them vao gio
3. Bam **Xem don hang** -> **In hoa don**
4. Neu co UPI ID, app hien thi ma QR de thanh toan

## 6) Du lieu luu o dau?

App dung **Hive** de luu du lieu local (offline), gom:

- Danh sach san pham
- Thong tin cua hang
- MAC/ten may in da ket noi

Nen app van hoat dong khi khong co Internet.

## 7) Cau truc ma nguon (rut gon)

```text
lib/
  core/         # thanh phan dung chung (theme, db, utils, widget...)
  config/       # route
  features/
    billing/    # quet ma, gio hang, thanh toan, in hoa don
    product/    # CRUD san pham
    shop/       # thong tin cua hang
    settings/   # cai dat va ket noi may in
```

## 8) Lenh huu ich

```bash
flutter analyze
flutter test
```

Neu doi model/entity co generated file:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 9) Loi thuong gap

- **Khong tim thay may in da ghep doi**
  - Kiem tra da pair may in trong Bluetooth he thong
  - Cap quyen Bluetooth/Location cho app
  - Bam Lam moi trong man hinh Cai dat -> May in

- **Khong quet duoc ma vach**
  - Kiem tra da cap quyen camera
  - Canh ma vach vao dung khung quet, du anh sang

- **In that bai**
  - Kiem tra may in con pin/giay
  - Thu ngat ket noi va Lam moi lai

