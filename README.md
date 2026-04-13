# 🛒 Ứng dụng POS / bán hàng trên di động

Đây là ứng dụng bán hàng offline-first viết bằng Flutter, phục vụ các nhu cầu quét mã vạch, quản lý sản phẩm, thanh toán tại quầy và in hóa đơn bằng máy in nhiệt Bluetooth.

## 1. Tính năng chính

- Quản lý sản phẩm: thêm, sửa, xóa, tìm kiếm theo tên hoặc mã vạch.
- Quét mã vạch bằng camera để thêm nhanh sản phẩm vào giỏ hàng.
- Thanh toán và tính tổng tiền trực tiếp trên thiết bị.
- In hóa đơn qua máy in nhiệt Bluetooth.
- Lưu cấu hình cửa hàng và thông tin máy in cục bộ bằng Hive.
- Hoạt động không cần Internet.

## 2. Công nghệ sử dụng

- **Framework**: Flutter
- **Ngôn ngữ**: Dart
- **State management**: `flutter_bloc`
- **Dependency injection**: `get_it`
- **Điều hướng**: `go_router`
- **Cơ sở dữ liệu cục bộ**: `hive`, `hive_flutter`
- **Sinh mã**: `build_runner`, `json_serializable`
- **Quét mã vạch**: `mobile_scanner`
- **In Bluetooth**: `print_bluetooth_thermal`

## 3. Cấu trúc thư mục

```text
lib/
├── core/
│   ├── data/
│   ├── error/
│   ├── theme/
│   ├── usecase/
│   ├── utils/
│   ├── widgets/
│   └── service_locator.dart
└── features/
    ├── billing/
    ├── product/
    ├── settings/
    └── shop/
```

Dự án được tổ chức theo hướng **feature-first** kết hợp **clean architecture** (`data`, `domain`, `presentation`) để dễ mở rộng và bảo trì.

## 4. Yêu cầu môi trường

Trước khi chạy dự án, cần chuẩn bị:

- Flutter SDK `>= 3.1.0`
- Dart SDK tương thích theo `pubspec.yaml`
- Android Studio hoặc VS Code + Flutter extension
- Xcode nếu build iOS
- Thiết bị thật Android/iOS nếu cần test camera hoặc máy in Bluetooth

Kiểm tra môi trường Flutter:

```bash
flutter doctor
```

## 5. Cài đặt dự án

### Bước 1: Clone mã nguồn

```bash
git clone <repository_url>
cd billing_app
```

### Bước 2: Cài dependencies

```bash
flutter pub get
```

### Bước 3: Sinh code

Lệnh này cần thiết cho Hive adapter và các model dùng `json_serializable`.

```bash
dart run build_runner build --delete-conflicting-outputs
```

Khi phát triển, có thể dùng chế độ watch:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## 6. Chạy ứng dụng

### Chạy debug

```bash
flutter run
```

Nếu có nhiều thiết bị:

```bash
flutter devices
flutter run -d <device_id>
```

## 7. Build ứng dụng

### Build APK Android

```bash
flutter build apk --release
```

File đầu ra thường nằm tại:

```text
build/app/outputs/flutter-apk/app-release.apk
```

### Build Android App Bundle

```bash
flutter build appbundle --release
```

### Build iOS

```bash
flutter build ios --release
```

Lưu ý: build iOS yêu cầu chạy trên macOS và cấu hình signing phù hợp trong Xcode.

## 8. Hướng dẫn cấu hình sau khi cài app

### 8.1. Cấu hình thông tin cửa hàng

Trong app, vào:

```text
Cài đặt > Thông tin cửa hàng
```

Nhập các thông tin:

- Tên cửa hàng
- Địa chỉ dòng 1
- Địa chỉ dòng 2 (nếu có)
- Số điện thoại
- Mã UPI (nếu dùng QR thanh toán)
- Nội dung cuối hóa đơn

Thông tin này sẽ được dùng khi hiển thị và in hóa đơn.

### 8.2. Cấu hình máy in Bluetooth

Trong app, vào:

```text
Cài đặt > Thiết bị in
```

Quy trình kết nối:

1. Mở phần Bluetooth của điện thoại.
2. Ghép đôi máy in nhiệt với điện thoại trước.
3. Quay lại app.
4. Nhấn **Làm mới** để app tìm và kết nối máy in đã ghép đôi.

### 8.3. Quyền truy cập cần cấp

Ứng dụng có thể yêu cầu các quyền sau:

- Camera: để quét mã vạch
- Bluetooth / Bluetooth Scan / Bluetooth Connect: để tìm và kết nối máy in
- Location: một số phiên bản Android yêu cầu khi quét thiết bị Bluetooth

Nếu bị từ chối quyền, hãy vào phần cài đặt của hệ điều hành để cấp lại.

## 9. Lưu ý khi in hóa đơn

- Một số máy in nhiệt Bluetooth giá rẻ không hỗ trợ Unicode đầy đủ.
- Nếu nội dung in bị lỗi font/dấu tiếng Việt, nên thử:
  - dùng nội dung không dấu cho phần cuối hóa đơn,
  - hoặc thay đổi model máy in / bộ mã hóa mà máy in hỗ trợ.
- Ứng dụng hiện lưu dữ liệu cục bộ, nên khi xóa dữ liệu app hoặc gỡ cài đặt, thông tin sản phẩm/cấu hình có thể bị mất.

## 10. Một số lệnh hữu ích

### Phân tích mã nguồn

```bash
flutter analyze
```

### Chạy test

```bash
flutter test
```

### Dọn build cache

```bash
flutter clean
flutter pub get
```

## 11. Luồng sử dụng cơ bản

1. Vào **Cài đặt** để cấu hình cửa hàng và máy in.
2. Vào **Sản phẩm** để thêm danh mục hàng hóa.
3. Tại màn hình chính, dùng camera quét mã vạch.
4. Kiểm tra giỏ hàng và chọn **Xem đơn hàng**.
5. Thực hiện thanh toán và **In hóa đơn**.

## 12. Ghi chú phát triển

- Nếu thay đổi model/Hive type hoặc file dùng `json_serializable`, hãy chạy lại:

```bash
dart run build_runner build --delete-conflicting-outputs
```

- Kiến trúc chính:
  - `core/`: thành phần dùng chung
  - `features/product`: quản lý sản phẩm
  - `features/billing`: quét mã, giỏ hàng, thanh toán
  - `features/settings`: cấu hình máy in
  - `features/shop`: thông tin cửa hàng
