# Billing App - Hướng dẫn tiếng Việt

Ứng dụng Flutter hỗ trợ bán hàng/tính tiền offline, quét mã vạch bằng camera và in hóa đơn qua máy in Bluetooth.

## 1) Yêu cầu môi trường

- Flutter SDK >= 3.1.0
- Dart SDK đi kèm Flutter
- Android Studio (khuyến nghị cho Android)
- Xcode (nếu build iOS/macOS)
- Thiết bị Android thật (khuyến nghị để test Bluetooth/máy in)

Kiểm tra môi trường:

```bash
flutter doctor
```

## 2) Cài đặt dự án

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

> Lệnh `build_runner` cần thiết để tạo code cho Hive adapter và JSON serialization.

## 3) Chạy ứng dụng

```bash
flutter run
```

Nếu muốn chạy trên thiết bị cụ thể:

```bash
flutter devices
flutter run -d <device_id>
```

## 4) Build bản phát hành

### Android APK

```bash
flutter build apk --release
```

File kết quả:

`build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (Play Store)

```bash
flutter build appbundle --release
```

File kết quả:

`build/app/outputs/bundle/release/app-release.aab`

### iOS (nếu cấu hình đủ chứng chỉ)

```bash
flutter build ios --release
```

## 5) Cấu hình và sử dụng trong app

### 5.1 Quản lý sản phẩm

1. Vào **Cài đặt** -> **Sản phẩm**
2. Thêm sản phẩm mới (Tên, Mã vạch, Giá)
3. Có thể bấm icon quét để lấy mã vạch từ camera

### 5.2 Cấu hình thông tin cửa hàng

1. Vào **Cài đặt** -> **Thông tin cửa hàng**
2. Cập nhật:
   - Tên cửa hàng
   - Địa chỉ dòng 1, dòng 2
   - Số điện thoại
   - UPI ID (nếu có)
   - Nội dung chân hóa đơn
3. Bấm **Lưu thông tin**

### 5.3 Kết nối máy in Bluetooth

1. Vào **Cài đặt** -> **Máy in**
2. Bấm icon bánh răng để mở trang cài đặt Bluetooth của điện thoại
3. Ghép đôi (pair) máy in trong hệ thống
4. Quay lại app, bấm icon **Làm mới** để app quét và kết nối máy in
5. Khi thành công, trạng thái máy in sẽ hiển thị **ĐÃ KẾT NỐI**

> Nếu app hỏi quyền Bluetooth/Location, cần cấp quyền đầy đủ để quét và kết nối.

### 5.4 Quy trình tính tiền

1. Ở màn hình chính, đưa mã vạch vào khung quét
2. Sản phẩm sẽ được thêm vào giỏ
3. Bấm **Xem đơn hàng** -> **In hóa đơn**
4. Nếu có UPI ID, app hiển thị mã QR để thanh toán

## 6) Dữ liệu lưu ở đâu?

App dùng **Hive** để lưu dữ liệu local (offline), gồm:

- Danh sách sản phẩm
- Thông tin cửa hàng
- MAC/tên máy in đã kết nối

Nên app vẫn hoạt động khi không có Internet.

## 7) Cấu trúc mã nguồn (rút gọn)

```text
lib/
  core/         # thành phần dùng chung (theme, db, utils, widget...)
  config/       # route
  features/
    billing/    # quét mã, giỏ hàng, thanh toán, in hóa đơn
    product/    # CRUD sản phẩm
    shop/       # thông tin cửa hàng
    settings/   # cài đặt và kết nối máy in
```

## 8) Lệnh hữu ích

```bash
flutter analyze
flutter test
```

Nếu đổi model/entity có generated file:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 9) Lỗi thường gặp

- **Không tìm thấy máy in đã ghép đôi**
  - Kiểm tra đã pair máy in trong Bluetooth hệ thống
  - Cấp quyền Bluetooth/Location cho app
  - Bấm Làm mới trong màn hình Cài đặt -> Máy in

- **Không quét được mã vạch**
  - Kiểm tra đã cấp quyền camera
  - Căn mã vạch vào đúng khung quét, đủ ánh sáng

- **In thất bại**
  - Kiểm tra máy in còn pin/giấy
  - Thử ngắt kết nối và Làm mới lại

