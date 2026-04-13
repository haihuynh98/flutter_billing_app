# 🛒 Ứng Dụng Tính Tiền & Bán Hàng (Mobile POS)

Ứng dụng POS (Point of Sale) và tính tiền offline đa nền tảng, hiệu suất cao được xây dựng bằng Flutter. Được thiết kế để phục vụ quy trình thanh toán bán lẻ liền mạch với tính năng quét mã vạch, in hoá đơn qua Bluetooth nhiệt, và lưu trữ dữ liệu cục bộ mạnh mẽ.

---

## 🎯 Tính Năng Chính

- **Quản Lý Sản Phẩm**: Thêm, sửa, xoá sản phẩm kho hàng với hỗ trợ mã vạch/QR.
- **Thanh Toán Thông Minh**: Xây dựng giỏ hàng nhanh chóng bằng camera quét mã vạch hoặc nhập tay.
- **In Hoá Đơn Bluetooth**: Kết nối trực tiếp với máy in nhiệt để in hoá đơn giấy ngay lập tức.
- **Cài Đặt Cửa Hàng**: Quản lý thông tin cửa hàng được in động trên hoá đơn.
- **Hoạt Động Offline**: Powered by `Hive` — không cần kết nối Internet.

---

## 🛠 Công Nghệ Sử Dụng

| Thành phần | Công nghệ |
|---|---|
| Framework | Flutter (SDK >=3.1.0) |
| State Management | flutter_bloc |
| Dependency Injection | get_it |
| Routing | go_router |
| Cơ sở dữ liệu cục bộ | hive & hive_flutter |
| Quét mã vạch | mobile_scanner |
| In nhiệt Bluetooth | print_bluetooth_thermal |
| Lập trình hàm | fpdart |

---

## 📁 Cấu Trúc Thư Mục

```text
lib/
├── core/                       # Tiện ích và widget dùng chung
│   ├── data/                   # Nguồn dữ liệu toàn cục (Hive init)
│   ├── error/                  # Mô hình lỗi chuẩn hoá
│   ├── theme/                  # Giao diện, màu sắc, kiểu chữ
│   ├── usecase/                # Hợp đồng UseCase cơ sở
│   ├── utils/                  # Helpers (PrinterHelper, validators,...)
│   ├── widgets/                # Widget tái sử dụng toàn cục
│   └── service_locator.dart    # Cấu hình Dependency Injection (get_it)
│
└── features/                   # Các module tính năng độc lập
    ├── billing/                # Thanh toán: giỏ hàng, checkout, in hoá đơn
    ├── product/                # Quản lý kho: thêm, liệt kê, quét sản phẩm
    ├── settings/               # Cài đặt: kết nối máy in, thông số ứng dụng
    └── shop/                   # Thông tin cửa hàng
```

---

## 🚀 Hướng Dẫn Cài Đặt & Build

### Yêu Cầu Môi Trường

- **Flutter SDK** phiên bản `>=3.1.0` — [Tải tại flutter.dev](https://flutter.dev/docs/get-started/install)
- **Dart SDK** `>=3.1.0` (đi kèm Flutter)
- **Android Studio** hoặc **Xcode** (để build và chạy emulator/thiết bị thực)
- **Git**
- *(Tuỳ chọn)* Thiết bị Android/iOS thực và Máy in nhiệt Bluetooth để kiểm thử phần cứng

### Bước 1 — Cài Đặt Flutter

Tham khảo tài liệu chính thức: https://docs.flutter.dev/get-started/install

Sau khi cài đặt, kiểm tra môi trường:

```bash
flutter doctor
```

Đảm bảo không có lỗi nghiêm trọng (✓) trước khi tiếp tục.

### Bước 2 — Clone Dự Án

```bash
git clone <repository_url>
cd billing_app
```

### Bước 3 — Cài Đặt Phụ Thuộc

```bash
flutter pub get
```

### Bước 4 — Tạo Code (Code Generation)

Bước này bắt buộc để tạo Hive adapters và JSON serialization:

```bash
dart run build_runner build --delete-conflicting-outputs
```

> **Lưu ý:** Nếu bạn thay đổi các model (`.g.dart`), cần chạy lại lệnh này.

### Bước 5 — Chạy Ứng Dụng

```bash
# Chạy trên thiết bị/emulator đang kết nối
flutter run

# Chạy trên thiết bị cụ thể (xem danh sách thiết bị)
flutter devices
flutter run -d <device_id>

# Chạy ở chế độ release
flutter run --release
```

---

## 📦 Build Phát Hành (Release Build)

### Android (APK)

```bash
# Build APK debug
flutter build apk --debug

# Build APK release (cần cấu hình signing key)
flutter build apk --release

# Build App Bundle (khuyến nghị cho Google Play)
flutter build appbundle --release
```

File APK xuất ra tại: `build/app/outputs/flutter-apk/app-release.apk`

#### Cấu Hình Signing Key cho Android

1. Tạo keystore:
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias upload
   ```

2. Tạo file `android/key.properties`:
   ```properties
   storePassword=<mật_khẩu_keystore>
   keyPassword=<mật_khẩu_key>
   keyAlias=upload
   storeFile=<đường_dẫn_tuyệt_đối>/upload-keystore.jks
   ```

3. Cập nhật `android/app/build.gradle.kts` để sử dụng signing config (tham khảo [tài liệu Flutter](https://docs.flutter.dev/deployment/android)).

### iOS (IPA)

```bash
# Build iOS release (cần Mac và Xcode)
flutter build ios --release

# Xuất IPA bằng Xcode
open ios/Runner.xcworkspace
# Sau đó: Product → Archive → Distribute App
```

> **Lưu ý iOS:** Cần tài khoản Apple Developer và cấu hình Provisioning Profile.

### Web

```bash
flutter build web --release
# Kết quả tại: build/web/
```

---

## 🖨 Hướng Dẫn Kết Nối Máy In Nhiệt Bluetooth

Ứng dụng hỗ trợ kết nối máy in nhiệt qua Bluetooth (ESC/POS).

### Yêu Cầu

- Máy in nhiệt hỗ trợ Bluetooth (ví dụ: Xprinter, Goojprt, Rongta,...)
- Thiết bị Android/iOS có Bluetooth

### Các Bước Kết Nối

1. **Ghép đôi máy in với điện thoại:**
   - Mở **Cài Đặt điện thoại → Bluetooth**
   - Bật Bluetooth và chờ thiết bị quét
   - Chọn tên máy in để ghép đôi (thường là `RPP02N`, `Bluetooth Printer`, v.v.)
   - Nhập mã PIN nếu được yêu cầu (thường là `0000` hoặc `1234`)

2. **Kết nối trong ứng dụng:**
   - Mở ứng dụng → nhấn **biểu tượng Cài Đặt** (góc trên phải màn hình chính)
   - Vào mục **Phần Cứng → Máy In**
   - Nhấn **biểu tượng Làm Mới** (🔄) để quét thiết bị đã ghép đôi
   - Ứng dụng sẽ tự động kết nối với máy in đầu tiên tìm thấy
   - Trạng thái **"ĐÃ KẾT NỐI"** sẽ hiển thị khi thành công

3. **Nếu không kết nối được:**
   - Nhấn **biểu tượng bánh răng** (⚙️) để mở Cài Đặt Bluetooth hệ thống
   - Đảm bảo máy in đã được ghép đôi thành công
   - Quay lại ứng dụng và nhấn **Làm Mới** lại

### In Hoá Đơn

- Sau khi kết nối máy in, vào màn hình **Thanh Toán**
- Nhấn nút **In Hoá Đơn** để in hoá đơn nhiệt

> **Lưu ý:** Kết nối Bluetooth được lưu tự động. Lần sau mở ứng dụng, ứng dụng sẽ tự kết nối lại mà không cần thực hiện lại các bước trên.

---

## ⚙️ Hướng Dẫn Cấu Hình Ứng Dụng

### Cấu Hình Thông Tin Cửa Hàng

Thông tin cửa hàng được in trên mỗi hoá đơn. Để cập nhật:

1. Từ màn hình chính → nhấn **biểu tượng Cài Đặt**
2. Vào **Quản Lý → Thông Tin Cửa Hàng**
3. Điền các thông tin:
   - **Tên Cửa Hàng**: Tên hiển thị trên đầu hoá đơn
   - **Địa Chỉ Dòng 1**: Số nhà, tên đường
   - **Địa Chỉ Dòng 2** *(tuỳ chọn)*: Phường/Xã, Quận/Huyện
   - **Số Điện Thoại**: Số liên lạc
   - **Mã QR Thanh Toán** *(tuỳ chọn)*: Tài khoản UPI/VietQR để hiển thị mã QR thanh toán trên màn hình checkout
   - **Chân Trang Hoá Đơn**: Lời nhắn cuối hoá đơn (VD: "Cảm ơn quý khách!")
4. Nhấn **Lưu Thông Tin**

### Quản Lý Sản Phẩm

1. Từ màn hình chính → **Cài Đặt → Quản Lý → Sản Phẩm**
2. Nhấn nút **+** để thêm sản phẩm mới
3. Điền:
   - **Mã Vạch**: Nhập tay hoặc nhấn biểu tượng camera để quét
   - **Tên Sản Phẩm**: Tên hiển thị
   - **Giá**: Đơn giá sản phẩm
4. Nhấn **Thêm Sản Phẩm**

### Quy Trình Thanh Toán

1. Từ màn hình chính, đưa máy vào camera → quét mã vạch sản phẩm
2. Sản phẩm tự động thêm vào giỏ hàng
3. Điều chỉnh số lượng bằng nút **+/-** trên từng sản phẩm
4. Nhấn **Xem Đơn Hàng** để vào màn hình thanh toán
5. Xác nhận tổng tiền, hiển thị mã QR thanh toán (nếu đã cấu hình)
6. Nhấn **In Hoá Đơn** để in

---

## 🔒 Quyền Truy Cập Ứng Dụng

Ứng dụng yêu cầu các quyền sau:

| Quyền | Mục đích |
|---|---|
| Camera | Quét mã vạch sản phẩm |
| Bluetooth | Kết nối máy in nhiệt |
| Vị trí | Tìm kiếm thiết bị Bluetooth lân cận (Android yêu cầu) |

---

## 🤝 Đóng Góp

Vui lòng tuân thủ các nguyên tắc sau:

1. **Kiến trúc Clean Architecture**: Duy trì ranh giới nghiêm ngặt giữa các lớp `domain`, `data`, và `presentation`.
2. **Immutable States**: Chỉ emit các state bất biến từ BLoC sử dụng `equatable`.
3. **Xử lý lỗi**: Sử dụng pattern `Either<Failure, Type>` của `fpdart` thay vì throw exception trực tiếp.

---

## 📄 Giấy Phép

Dự án này được phân phối dưới [MIT License](LICENSE).
