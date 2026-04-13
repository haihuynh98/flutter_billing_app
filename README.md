# Ứng dụng bán hàng (POS) - Flutter

Ứng dụng POS hoạt động **offline-first** với Flutter, hỗ trợ:
- Quét mã vạch bằng camera
- Quản lý sản phẩm (thêm/sửa/xóa)
- Thanh toán và in hóa đơn qua máy in nhiệt Bluetooth
- Lưu trữ dữ liệu cục bộ bằng Hive (không cần internet để vận hành cơ bản)

## 1) Công nghệ sử dụng

- Flutter (SDK >= 3.1.0)
- `flutter_bloc` (quản lý state)
- `go_router` (điều hướng)
- `get_it` (dependency injection)
- `hive`, `hive_flutter` (lưu trữ local)
- `mobile_scanner` (quét mã vạch)
- `print_bluetooth_thermal` (in Bluetooth)

## 2) Cấu trúc thư mục chính

```text
lib/
├── core/            # Thành phần dùng chung (theme, helper, db, widget...)
├── config/          # Cấu hình route
└── features/
    ├── billing/     # Bán hàng, giỏ hàng, thanh toán, in hóa đơn
    ├── product/     # Quản lý sản phẩm
    ├── shop/        # Thông tin cửa hàng
    └── settings/    # Cài đặt máy in và cấu hình hệ thống
```

## 3) Yêu cầu môi trường

- Flutter SDK 3.1.0 trở lên
- Android Studio / Xcode (tùy nền tảng build)
- Thiết bị thật (khuyến nghị) để test:
  - Camera quét mã vạch
  - Bluetooth máy in nhiệt

## 4) Cài đặt và chạy dự án

### Bước 1: Cài dependencies

```bash
flutter pub get
```

### Bước 2: Generate code (khi có thay đổi model/adapters)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Bước 3: Chạy app ở chế độ debug

```bash
flutter run
```

## 5) Build ứng dụng

### Android (APK release)

```bash
flutter build apk --release
```

### Android (App Bundle)

```bash
flutter build appbundle --release
```

### iOS (cần macOS + Xcode)

```bash
flutter build ios --release
```

### Web

```bash
flutter build web
```

## 6) Hướng dẫn cấu hình trong app

### 6.1 Cấu hình thông tin cửa hàng

Vào **Cài đặt -> Thông tin cửa hàng** và nhập:
- Tên cửa hàng
- Địa chỉ
- Số điện thoại
- Mã thanh toán (UPI nếu bạn dùng)
- Lời nhắn cuối hóa đơn

Thông tin này sẽ hiển thị trên hóa đơn in ra.

### 6.2 Kết nối máy in Bluetooth

1. Mở **Cài đặt** trong app.  
2. Nhấn biểu tượng bánh răng để mở phần Bluetooth của điện thoại.  
3. Ghép đôi máy in nhiệt với điện thoại (pair).  
4. Quay lại app và nhấn **Làm mới** để app tự kết nối máy in đã ghép đôi.  
5. Khi thấy trạng thái **ĐÃ KẾT NỐI**, bạn có thể in hóa đơn.

> Lưu ý: App cần quyền Bluetooth và vị trí (tùy phiên bản Android) để quét thiết bị.

## 7) Quy trình sử dụng nhanh

1. Vào **Sản phẩm** để tạo danh mục hàng hóa.
2. Quét mã ở màn hình chính để thêm hàng vào giỏ.
3. Nhấn **Xem đơn hàng** để vào màn hình thanh toán.
4. Nhấn **In hóa đơn** để in qua máy in đã kết nối.

## 8) Dữ liệu local và reset dữ liệu

- Dữ liệu được lưu bằng Hive trên thiết bị.
- Box chính:
  - `products`
  - `shop`
  - `settings`

Nếu cần reset hoàn toàn dữ liệu, xóa app hoặc xóa local data của app trên thiết bị.

## 9) Một số lỗi thường gặp

- **Không tìm thấy máy in**: kiểm tra đã cấp quyền Bluetooth/vị trí và đã ghép đôi trước trong cài đặt hệ điều hành.
- **Không quét được mã vạch**: kiểm tra quyền camera và ánh sáng môi trường.
- **Không in được**: kiểm tra trạng thái kết nối máy in trong màn hình Cài đặt.

---

Nếu bạn muốn mở rộng dự án (đa ngôn ngữ, quản lý khách hàng, đồng bộ cloud), có thể bắt đầu từ các module trong `features/` theo đúng kiến trúc hiện tại.
