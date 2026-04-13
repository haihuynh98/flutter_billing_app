# Ứng dụng POS & thanh toán (Flutter)

Ứng dụng bán hàng, quét mã vạch và in hóa đơn nhiệt qua Bluetooth, hoạt động chủ yếu **ngoại tuyến** với dữ liệu lưu cục bộ (Hive).

## Yêu cầu môi trường

- [Flutter](https://flutter.dev/) SDK `>=3.1.0 <4.0.0` (xem `pubspec.yaml`)
- Android Studio (SDK Android, thiết bị/emulator) hoặc Xcode (iOS, chỉ trên macOS)
- Thiết bị thật khuyến nghị khi kiểm tra **camera quét mã** và **máy in nhiệt Bluetooth**

## Cài đặt và build

Trong thư mục gốc dự án (chứa `pubspec.yaml`):

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Chạy ứng dụng:

```bash
flutter run
```

Build file cài đặt:

```bash
# APK (Android)
flutter build apk

# App Bundle để đưa lên CH Play
flutter build appbundle
```

Trên iOS cần chứng chỉ và cấu hình Xcode; xem [tài liệu Flutter iOS](https://docs.flutter.dev/deployment/ios).

## Cấu hình & kết nối

### Thông tin cửa hàng

1. Mở màn hình chính (quét mã), chạm **biểu tượng bánh răng** (Cài đặt).
2. Chọn **Thông tin cửa hàng**.
3. Điền tên cửa hàng, địa chỉ, số điện thoại, chân hóa đơn.
4. Trường **ID thanh toán UPI** là tùy chọn: dùng cho mã QR thanh toán theo chuẩn UPI (thường dùng tại Ấn Độ). Nếu không dùng UPI, có thể để trống; phần QR trên màn **Thanh toán** sẽ không hiển thị.

### Sản phẩm

- Vào **Cài đặt** → **Sản phẩm** để thêm/sửa/xóa hàng hóa, gắn **mã vạch** (có thể quét bằng camera).

### Máy in nhiệt Bluetooth

1. Ghép nối máy in với điện thoại trong **Cài đặt hệ thống → Bluetooth** (máy in phải ở chế độ ghép nối).
2. Trong app: **Cài đặt** → mục **Máy in** → chạm **làm mới** (biểu tượng mũi tên tròn).
3. Nếu cần cấp quyền Bluetooth/vị trí (Android), làm theo hộp thoại hệ thống hoặc mở cài đặt bằng biểu tượng bánh răng nhỏ cạnh đó.

Ứng dụng lưu MAC/tên máy in trong Hive (`settings` box) để lần sau tự kết nối khi in.

### Quyền (Android)

Trong `android/app/src/main/AndroidManifest.xml` cần có các quyền phù hợp cho camera, Bluetooth và (nếu bản Android yêu cầu) vị trí khi quét thiết bị BLE cổ điển. Sau khi chỉnh manifest, build lại app.

## Giao diện tiếng Việt

Toàn bộ nhãn, thông báo lỗi và văn bản hướng dẫn trong app đã được chuyển sang **tiếng Việt**. Giá hiển thị theo ký hiệu **₫** (số nguyên trên giao diện chính).

## Cấu trúc mã nguồn (tóm tắt)

- `lib/features/billing` — giỏ hàng, thanh toán, in
- `lib/features/product` — CRUD sản phẩm
- `lib/features/shop` — thông tin cửa hàng trên hóa đơn
- `lib/features/settings` — cài đặt, máy in
- `lib/core` — Hive, theme, validator, `PrinterHelper`

## Kiểm thử

```bash
flutter test
```

## Tài liệu thêm (tiếng Anh)

Xem `README.md` cho mô tả tổng quan dự án và stack kỹ thuật.
