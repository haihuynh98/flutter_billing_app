# Hướng dẫn tiếng Việt cho Billing App

Tài liệu này mô tả cách cài đặt, chạy, build và cấu hình ứng dụng bán hàng Flutter trong repository này.

## 1. Tổng quan

Đây là một ứng dụng POS/billing hoạt động theo mô hình offline-first, được xây dựng bằng Flutter. Ứng dụng tập trung vào các nhu cầu:

- Quét mã vạch để thêm sản phẩm vào giỏ hàng.
- Quản lý danh sách sản phẩm trên thiết bị.
- Lưu thông tin cửa hàng để in hóa đơn.
- Kết nối máy in nhiệt Bluetooth để in hóa đơn.
- Lưu dữ liệu cục bộ bằng Hive, không phụ thuộc internet khi vận hành thông thường.

## 2. Công nghệ chính

- Flutter
- flutter_bloc
- go_router
- get_it
- hive / hive_flutter
- mobile_scanner
- print_bluetooth_thermal
- intl

## 3. Yêu cầu môi trường

Cần chuẩn bị:

- Flutter SDK 3.1.0 trở lên
- Dart SDK đi kèm với Flutter
- Android Studio hoặc VS Code + Flutter extension
- Xcode nếu build cho iOS
- Thiết bị Android/iPhone thật nếu muốn test quét mã vạch và in Bluetooth

Kiểm tra môi trường:

```bash
flutter doctor
```

## 4. Cài đặt dự án

Clone repository và cài dependency:

```bash
git clone <repository_url>
cd billing_app
flutter pub get
```

Sinh các file code generation cho Hive và JSON serialization:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Nếu cần theo dõi thay đổi liên tục khi phát triển:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## 5. Chạy ứng dụng

Chạy ở chế độ debug:

```bash
flutter run
```

Chạy với thiết bị cụ thể:

```bash
flutter devices
flutter run -d <device_id>
```

## 6. Build ứng dụng

### Build APK Android

```bash
flutter build apk --release
```

File kết quả thường nằm tại:

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

Nếu cần đóng gói/phát hành qua Xcode, mở thư mục `ios/` bằng Xcode để ký số và archive.

## 7. Cấu hình dữ liệu trong app

Ứng dụng này hiện không sử dụng file `.env`. Phần lớn cấu hình được lưu trực tiếp trong bộ nhớ cục bộ của thiết bị bằng Hive.

### 7.1. Cấu hình thông tin cửa hàng

Trong app:

1. Mở màn hình **Cài đặt**.
2. Chọn **Thông tin cửa hàng**.
3. Nhập:
   - Tên cửa hàng
   - Địa chỉ
   - Số điện thoại
   - Mã thanh toán UPI (nếu cần)
   - Nội dung cuối hóa đơn
4. Bấm **Lưu thông tin**.

Thông tin này sẽ được sử dụng trên màn hình thanh toán và khi in hóa đơn.

### 7.2. Cấu hình sản phẩm

Trong app:

1. Mở **Cài đặt** -> **Sản phẩm**.
2. Thêm sản phẩm mới bằng:
   - Tên sản phẩm
   - Mã vạch
   - Giá bán
3. Có thể mở camera quét mã vạch để điền mã nhanh hơn.
4. Có thể sửa hoặc xóa sản phẩm đã tạo.

### 7.3. Kết nối máy in Bluetooth

Trong app:

1. Mở **Cài đặt**.
2. Vào mục **Máy in**.
3. Nhấn biểu tượng cài đặt để mở phần Bluetooth của điện thoại.
4. Ghép đôi máy in nhiệt với điện thoại trước.
5. Quay lại app và nhấn **Làm mới** để app tự tìm và thử kết nối máy in đã ghép đôi.

Nếu đã lưu thông tin máy in trước đó, app sẽ cố gắng tự động kết nối lại khi in hóa đơn.

## 8. Quy trình sử dụng cơ bản

1. Cấu hình thông tin cửa hàng.
2. Thêm danh mục sản phẩm và mã vạch.
3. Ở màn hình chính, dùng camera để quét mã vạch.
4. Kiểm tra giỏ hàng.
5. Bấm **Xem đơn hàng**.
6. Ở màn hình **Thanh toán**, có thể hiện QR thanh toán nếu đã nhập mã UPI.
7. Bấm **In hóa đơn** để in.

## 9. Lưu ý quan trọng

### 9.1. Về QR thanh toán

Mã QR thanh toán hiện tại đang được tạo theo định dạng UPI và đang sử dụng `INR` trong dữ liệu QR. Nếu bạn muốn dùng cho thị trường Việt Nam hoặc đơn vị tiền tệ khác, cần cập nhật logic tạo QR ở:

```text
lib/features/billing/presentation/pages/checkout_page.dart
```

### 9.2. Về in tiếng Việt trên máy in nhiệt

Phần in hóa đơn hiện đang gửi text ở dạng byte đơn giản để tương thích với nhiều máy in nhiệt Bluetooth. Một số máy in nhiệt có thể không hiển thị đúng ký tự tiếng Việt có dấu.

Nếu cần in tiếng Việt đầy đủ có dấu, bạn có thể phải:

- Cấu hình đúng bảng mã hóa mà máy in hỗ trợ.
- Hoặc đổi sang thư viện/generator ESC/POS hỗ trợ encoding phù hợp.

Vì lý do tương thích, một số nhãn trên hóa đơn có thể đang ở dạng không dấu.

### 9.3. Về lưu trữ dữ liệu

- Dữ liệu sản phẩm, cài đặt và thông tin máy in được lưu trên thiết bị bằng Hive.
- Khi xóa app hoặc xóa dữ liệu app, dữ liệu cục bộ có thể bị mất.

## 10. Cấu trúc thư mục chính

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

## 11. Một số lệnh hữu ích

Phân tích lỗi:

```bash
flutter analyze
```

Chạy test:

```bash
flutter test
```

Format code:

```bash
dart format lib test
```

## 12. Gợi ý mở rộng

Nếu muốn nội địa hóa bài bản hơn nữa, có thể xem xét:

- Thêm hệ thống localization chính thức bằng `flutter_localizations` + ARB.
- Đổi đơn vị tiền tệ và QR thanh toán cho phù hợp thị trường mục tiêu.
- Bổ sung export/import dữ liệu sản phẩm.
- Đồng bộ dữ liệu lên cloud nếu cần vận hành đa thiết bị.
