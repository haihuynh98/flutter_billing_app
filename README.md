# Ứng Dụng Bán Hàng POS Di Động

Ứng dụng thanh toán và bán hàng tại điểm bán (POS) hoạt động offline, được xây dựng bằng Flutter. Thiết kế cho hoạt động bán lẻ với tính năng quét mã vạch, in hóa đơn nhiệt qua Bluetooth và lưu trữ dữ liệu cục bộ.

## Video giới thiệu


https://github.com/user-attachments/assets/f2d16454-5408-43b3-b207-cd843bbc2c9e


## Tính năng chính

- **Quản lý sản phẩm**: Thêm, sửa, xóa sản phẩm với hỗ trợ mã vạch/QR code.
- **Thanh toán thông minh**: Quét mã vạch bằng camera hoặc nhập thủ công, tự động tính tổng tiền.
- **In hóa đơn nhiệt Bluetooth**: Kết nối trực tiếp với máy in nhiệt qua Bluetooth (`print_bluetooth_thermal`).
- **Cài đặt cửa hàng**: Quản lý thông tin cửa hàng hiển thị trên hóa đơn.
- **Hoạt động offline**: Sử dụng `Hive` để lưu trữ dữ liệu NoSQL cục bộ, không cần internet.

## Công nghệ sử dụng

Xây dựng theo kiến trúc Clean Architecture & Feature-Driven Design.

- **Framework**: [Flutter](https://flutter.dev/) (SDK >=3.1.0)
- **Quản lý trạng thái**: `flutter_bloc`
- **Dependency Injection**: `get_it`
- **Điều hướng**: `go_router`
- **Cơ sở dữ liệu cục bộ**: `hive` & `hive_flutter`
- **Mô hình dữ liệu**: `json_serializable`, `equatable`
- **Lập trình hàm**: `fpdart`
- **Tích hợp phần cứng**: `mobile_scanner` (quét mã vạch), `print_bluetooth_thermal` (in Bluetooth)

## Cấu trúc thư mục

Mã nguồn được tổ chức theo mô hình **Feature-First Clean Architecture**.

```text
lib/
├── core/                       # Các tiện ích và thành phần dùng chung
│   ├── data/                   # Nguồn dữ liệu toàn cục (khởi tạo Hive)
│   ├── error/                  # Mô hình Failure/Exception (tương thích fpdart)
│   ├── theme/                  # Giao diện, kiểu chữ, phong cách
│   ├── usecase/                # Hợp đồng UseCase cơ sở
│   ├── utils/                  # Trợ giúp (PrinterHelper, định dạng...)
│   ├── widgets/                # Widget UI tái sử dụng
│   └── service_locator.dart    # Cài đặt dependency injection (get_it)
│
└── features/                   # Các module tính năng độc lập
    ├── billing/                # Thanh toán: Giỏ hàng, Checkout, Tạo hóa đơn
    ├── product/                # Quản lý sản phẩm: Thêm, Danh sách, Quét mã
    ├── settings/               # Cài đặt: Kết nối máy in, Cấu hình ứng dụng
    └── shop/                   # Cấu hình thông tin cửa hàng
```

*Ghi chú: Mỗi tính năng được chia thành các lớp Clean Architecture: `data`, `domain` và `presentation`.*

## Hướng dẫn cài đặt & Build

### Yêu cầu hệ thống

- **Flutter SDK** phiên bản `>=3.1.0`
- **Android Studio** (cho Android) hoặc **Xcode** (cho iOS)
- **Dart SDK** (đi kèm Flutter)
- *Tùy chọn*: Thiết bị Android/iOS thật và máy in nhiệt Bluetooth để kiểm thử tính năng phần cứng.

### Bước 1: Clone dự án

```bash
git clone <đường_dẫn_repository>
cd billing_app
```

### Bước 2: Cài đặt dependencies

```bash
flutter pub get
```

### Bước 3: Chạy code generation

Bắt buộc cho Hive adapters và JSON serialization:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Bước 4: Chạy ứng dụng

```bash
# Chạy ở chế độ debug
flutter run

# Build APK (Android)
flutter build apk --release

# Build IPA (iOS)
flutter build ios --release
```

## Cấu hình máy in Bluetooth

### Các bước kết nối máy in nhiệt:

1. **Bật Bluetooth** trên điện thoại.
2. **Ghép nối máy in** trong phần Cài đặt Bluetooth của điện thoại.
3. Mở ứng dụng, vào **Cài đặt** > phần **Phần cứng**.
4. Nhấn nút **Làm mới** để ứng dụng tìm và kết nối máy in đã ghép nối.
5. Khi hiện trạng thái **"ĐÃ KẾT NỐI"**, máy in sẵn sàng sử dụng.

### Máy in được hỗ trợ

- Các dòng máy in nhiệt Bluetooth hỗ trợ giao thức ESC/POS (58mm, 80mm).
- Ví dụ: Xprinter, GOOJPRT, MTP-II, v.v.

### Quyền truy cập cần thiết

| Quyền | Mục đích |
|--------|----------|
| Camera | Quét mã vạch sản phẩm |
| Bluetooth | Kết nối máy in nhiệt |
| Vị trí | Tìm thiết bị Bluetooth gần đây (yêu cầu của Android) |

## Cấu hình cửa hàng

Truy cập **Cài đặt** > **Thông tin cửa hàng** để thiết lập:

- **Tên cửa hàng**: Hiển thị trên đầu hóa đơn
- **Địa chỉ**: Dòng 1 và dòng 2 (tùy chọn)
- **Số điện thoại**: Hiển thị trên hóa đơn
- **Mã thanh toán (UPI/QR)**: Tạo mã QR thanh toán trên màn hình checkout
- **Chân trang hóa đơn**: Lời nhắn cuối hóa đơn (VD: "Cảm ơn quý khách!")

## Quản lý sản phẩm

### Thêm sản phẩm mới

1. Vào **Cài đặt** > **Sản phẩm** > nhấn nút **+**.
2. Quét mã vạch bằng camera hoặc nhập thủ công.
3. Điền tên sản phẩm và giá.
4. Nhấn **Thêm sản phẩm**.

### Sửa / Xóa sản phẩm

- Nhấn biểu tượng **bút chì** để sửa sản phẩm.
- Nhấn biểu tượng **thùng rác** để xóa sản phẩm.

## Quy trình thanh toán

1. Mở ứng dụng → Camera tự động quét mã vạch.
2. Sản phẩm được thêm vào giỏ hàng tự động.
3. Điều chỉnh số lượng bằng nút **+/-**.
4. Nhấn **Xem đơn hàng** để vào trang thanh toán.
5. Nhấn **In hóa đơn** để in qua máy in Bluetooth.

## Hướng dẫn đóng góp

1. **Tuân thủ Clean Architecture**: Duy trì ranh giới rõ ràng giữa các lớp `domain`, `data` và `presentation`.
2. **Trạng thái bất biến**: Chỉ emit trạng thái bất biến từ BLoC sử dụng `equatable`.
3. **Không dùng Exception trực tiếp trong Domain**: Sử dụng pattern `Either<Failure, Type>` của `fpdart` để xử lý lỗi.
