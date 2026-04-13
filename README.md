# POS Bán hàng Flutter

Ứng dụng POS/billing offline được xây dựng bằng Flutter, phục vụ quy trình bán hàng tại cửa hàng nhỏ và vừa. App hỗ trợ quét mã vạch bằng camera, quản lý sản phẩm, lưu dữ liệu offline bằng Hive và in hóa đơn qua máy in nhiệt Bluetooth.

## Tính năng chính

- Quản lý sản phẩm: thêm, sửa, xóa, tìm kiếm theo tên hoặc mã vạch.
- Quét mã vạch bằng camera để đưa sản phẩm vào giỏ hàng nhanh.
- Thanh toán và in hóa đơn trực tiếp từ thiết bị di động.
- Cấu hình thông tin cửa hàng để hiển thị trên hóa đơn.
- Lưu trữ dữ liệu offline, không phụ thuộc Internet để vận hành cơ bản.

## Công nghệ sử dụng

- Flutter
- flutter_bloc
- go_router
- get_it
- Hive / hive_flutter
- fpdart
- mobile_scanner
- print_bluetooth_thermal
- pretty_qr_code

## Cấu trúc thư mục

```text
lib/
├── core/
│   ├── data/                # Khởi tạo Hive, dữ liệu dùng chung
│   ├── error/               # Failure / error model
│   ├── theme/               # Theme giao diện
│   ├── usecase/             # Base usecase
│   ├── utils/               # Helper, printer helper, validator...
│   ├── widgets/             # Widget dùng chung
│   └── service_locator.dart # Đăng ký dependency với get_it
└── features/
    ├── billing/             # Quét mã, giỏ hàng, thanh toán, in hóa đơn
    ├── product/             # Quản lý sản phẩm
    ├── settings/            # Kết nối máy in, cài đặt
    └── shop/                # Thông tin cửa hàng
```

Mỗi feature được chia theo các lớp `data`, `domain`, `presentation`.

## Yêu cầu môi trường

- Flutter SDK `>=3.1.0`
- Dart đi kèm Flutter
- Android Studio hoặc VS Code + Flutter extension
- Nếu build iOS: cần macOS + Xcode
- Nếu test in thực tế: cần điện thoại thật và máy in nhiệt Bluetooth

## Cài đặt và chạy dự án

### 1. Lấy source code

```bash
git clone <repository_url>
cd billing_app
```

### 2. Cài dependency

```bash
flutter pub get
```

### 3. Chạy code generation

Dự án dùng Hive generator và JSON serialization, vì vậy cần chạy:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Nếu bạn thay đổi model / adapter và cần tạo lại file sinh tự động, hãy chạy lại lệnh này.

### 4. Chạy app

```bash
flutter run
```

Nếu muốn chạy trên thiết bị cụ thể:

```bash
flutter devices
flutter run -d <device_id>
```

## Build bản phát hành

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

Lưu ý: build iOS cần thực hiện trên macOS có cài Xcode.

## Hướng dẫn cấu hình app sau khi cài đặt

### 1. Cấu hình thông tin cửa hàng

Vào:

`Cài đặt` -> `Thông tin cửa hàng`

Nhập các trường:

- Tên cửa hàng
- Địa chỉ dòng 1
- Địa chỉ dòng 2 (không bắt buộc)
- Số điện thoại
- Mã UPI (không bắt buộc)
- Nội dung chân hóa đơn

Sau đó bấm `Lưu thông tin`.

### 2. Cấu hình QR thanh toán

App hiện tại tạo QR thanh toán theo định dạng UPI và giá trị tiền tệ `INR`.

- Nếu trường `Mã UPI` để trống, khu vực QR thanh toán sẽ không hiển thị.
- Nếu bạn cần chuyển sang hệ thống QR ngân hàng/VietQR, cần sửa phần logic sinh QR trong màn hình thanh toán.

### 3. Kết nối máy in Bluetooth

Vào:

`Cài đặt` -> `Thiết bị in`

Thực hiện theo thứ tự:

1. Bật Bluetooth trên điện thoại.
2. Ghép đôi máy in trong phần cài đặt Bluetooth của hệ điều hành.
3. Quay lại app.
4. Nhấn nút làm mới trong màn hình `Thiết bị in`.
5. App sẽ quét danh sách thiết bị đã ghép đôi và thử kết nối.

Nếu kết nối thành công, app sẽ lưu:

- `printer_mac`
- `printer_name`

vào Hive để tự động sử dụng lại cho lần sau.

## Quyền truy cập cần cấp

App có thể yêu cầu các quyền sau:

- Camera: để quét mã vạch
- Bluetooth: để kết nối máy in nhiệt
- Vị trí: cần cho một số thiết bị Android khi quét thiết bị Bluetooth

Nếu app không tìm thấy máy in, hãy kiểm tra lại:

- Bluetooth đã bật chưa
- Máy in đã ghép đôi trong hệ điều hành chưa
- Quyền Bluetooth / vị trí đã được cấp chưa

## Lưu trữ dữ liệu

App sử dụng Hive để lưu dữ liệu local trên thiết bị:

- Danh sách sản phẩm
- Thông tin cửa hàng
- Cấu hình máy in

Điều này giúp app hoạt động offline trong nhiều trường hợp có kết nối mạng kém ổn định.

## Kiểm tra chất lượng mã nguồn

### Phân tích lỗi / warning

```bash
flutter analyze
```

### Chạy test

```bash
flutter test
```

## Lưu ý khi in tiếng Việt

Giao diện app đã được Việt hóa, tuy nhiên việc in dấu tiếng Việt trên máy in nhiệt phụ thuộc vào:

- model máy in
- bảng mã ký tự mà máy in hỗ trợ
- cách xử lý encoding của firmware máy in

Trong implementation hiện tại, helper in đang gửi raw bytes đơn giản. Vì vậy một số máy in có thể không hiển thị đúng các ký tự có dấu. Trong mã nguồn hiện tại, dữ liệu trước khi in đã được chuẩn hóa về dạng không dấu để tăng khả năng tương thích với nhiều máy in nhiệt Bluetooth.

Nếu bạn cần hóa đơn tiếng Việt đầy đủ có dấu, nên:

- dùng máy in hỗ trợ Unicode / UTF-8 hoặc bảng mã phù hợp
- hoặc nâng cấp lớp in để map bảng mã ESC/POS tương ứng với model máy in

## Quy trình sử dụng nhanh

1. Vào `Cài đặt` để cập nhật thông tin cửa hàng.
2. Kết nối máy in Bluetooth.
3. Vào `Sản phẩm` để thêm danh mục.
4. Quay lại màn hình chính để quét mã vạch.
5. Bấm `Xem đơn hàng` -> `In hóa đơn`.

## Góp ý phát triển

Khi mở rộng dự án, nên giữ đúng cấu trúc hiện tại:

- `domain` không phụ thuộc trực tiếp vào UI
- `data` xử lý repository / datasource
- `presentation` xử lý bloc và màn hình
- State nên bất biến và sử dụng `equatable`
