# Huong dan tieng Viet - Mobile POS & Billing App

Day la tai lieu huong dan nhanh bang tieng Viet cho ung dung ban hang/POS viet bang Flutter.

## 1) Tong quan

Ung dung ho tro:
- Quet ma vach bang camera de them san pham vao gio.
- Quan ly san pham (them, sua, xoa).
- Luu du lieu offline bang Hive (khong can Internet de van hanh).
- In hoa don qua may in nhiet Bluetooth.
- Cau hinh thong tin cua hang de in tren hoa don.

## 2) Yeu cau moi truong

- Flutter SDK >= 3.1.0
- Dart SDK theo Flutter
- Android Studio / VS Code (co plugin Flutter + Dart)
- Thiet bi Android that (khuyen nghi) de test camera/Bluetooth/may in

## 3) Cai dat va chay ung dung

### Buoc 1: Tai source code

```bash
git clone <repository_url>
cd billing_app
```

### Buoc 2: Cai dependency

```bash
flutter pub get
```

### Buoc 3: Sinh code (bat buoc voi Hive/JSON)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Buoc 4: Chay app

```bash
flutter run
```

## 4) Build phien ban phat hanh

### Android APK

```bash
flutter build apk --release
```

APK tao ra tai:
`build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (AAB)

```bash
flutter build appbundle --release
```

## 5) Cau hinh trong app

### 5.1 Cau hinh thong tin cua hang

Trong app vao:
**Cai dat -> Thong tin cua hang**

Cap nhat cac truong:
- Ten cua hang
- Dia chi
- So dien thoai
- Ma UPI (neu dung thanh toan UPI)
- Noi dung cuoi hoa don

Thong tin nay duoc luu local va in tren hoa don.

### 5.2 Quan ly san pham

Trong app vao:
**Cai dat -> San pham**

Co the:
- Them san pham moi (ten, ma vach, gia)
- Quet ma vach de nhap nhanh
- Sua/Xoa san pham da ton tai

### 5.3 Ket noi may in Bluetooth

Trong app vao:
**Cai dat -> May in**

Quy trinh khuyen nghi:
1. Bat Bluetooth tren dien thoai.
2. Nhan icon banh rang de mo cai dat Bluetooth he thong.
3. Pair (ghep doi) may in nhiet.
4. Quay lai app, bam **Lam moi** de app ket noi may in da ghep doi.
5. Thu in hoa don tu man hinh Thanh toan.

## 6) Quyen truy cap tren Android

App can cac quyen:
- Camera
- Bluetooth / Bluetooth Scan / Bluetooth Connect
- Vi tri (location) de quet thiet bi Bluetooth tren mot so phien ban Android

Neu tu choi quyen, tinh nang quet ma vach hoac ket noi may in se khong hoat dong dung.

## 7) Luu tru du lieu

Ung dung dung Hive va mo 3 box chinh:
- `products`: danh sach san pham
- `shop`: thong tin cua hang
- `settings`: cau hinh he thong (vi du may in da luu)

## 8) Cau truc thu muc chinh

```text
lib/
├── core/
│   ├── data/
│   ├── error/
│   ├── theme/
│   ├── usecase/
│   ├── utils/
│   └── widgets/
└── features/
    ├── billing/
    ├── product/
    ├── settings/
    └── shop/
```

## 9) Cac loi thuong gap

- **Khong quet duoc ma vach**  
  Kiem tra quyen Camera va thu khoi dong lai app.

- **Khong ket noi duoc may in**  
  Kiem tra da pair may in trong cai dat Bluetooth cua dien thoai chua, sau do bam Lam moi.

- **Loi do code generation**  
  Chay lai:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```

