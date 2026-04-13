# Ứng dụng Bán hàng POS Di động

Ứng dụng thanh toán và bán hàng tại điểm bán (POS) ngoại tuyến, đầy đủ tính năng, hiệu suất cao, được xây dựng bằng Flutter. Được thiết kế cho hoạt động thanh toán bán lẻ liền mạch với tính năng quét mã vạch, in nhiệt qua Bluetooth và lưu trữ dữ liệu cục bộ mạnh mẽ.

## Ảnh chụp màn hình

https://github.com/user-attachments/assets/f2d16454-5408-43b3-b207-cd843bbc2c9e

## Phạm vi dự án

Ứng dụng này là một hệ thống POS ngoại tuyến hoàn chỉnh cho các cửa hàng bán lẻ vừa và nhỏ. Nó tối ưu hóa quy trình thanh toán, quản lý danh mục sản phẩm và tạo hóa đơn hoàn toàn trên thiết bị.

### Tính năng chính:
- **Quản lý sản phẩm**: Thao tác CRUD đầy đủ cho các mặt hàng tồn kho với hỗ trợ mã vạch/mã QR.
- **Hệ thống thanh toán thông minh**: Xây dựng giỏ hàng nhanh chóng qua quét mã vạch bằng camera hoặc nhập thủ công, tính toán đơn hàng chính xác.
- **In nhiệt qua Bluetooth**: Tích hợp trực tiếp với máy in nhiệt (`print_bluetooth_thermal`) để in hóa đơn giấy ngay lập tức.
- **Cài đặt & Tùy chỉnh cửa hàng**: Thông tin cửa hàng được quản lý tập trung và in động trên hóa đơn.
- **Kiến trúc ưu tiên ngoại tuyến**: Sử dụng `Hive` để lưu trữ dữ liệu NoSQL cục bộ nhanh chóng. Không yêu cầu kết nối internet.

## Công nghệ & Kiến trúc

Được xây dựng theo các nguyên tắc kiến trúc tiêu chuẩn (Clean Architecture & Feature-Driven Design) đảm bảo khả năng mở rộng, phân tách các mối quan tâm và khả năng kiểm thử mạnh mẽ.

- **Framework**: [Flutter](https://flutter.dev/) (SDK >=3.1.0)
- **Quản lý trạng thái**: `flutter_bloc`
- **Dependency Injection**: `get_it`
- **Điều hướng**: `go_router`
- **Cơ sở dữ liệu cục bộ**: `hive` & `hive_flutter`
- **Mô hình hóa dữ liệu**: `json_serializable`, `equatable`
- **Lập trình hàm**: `fpdart`
- **Tích hợp phần cứng**: `mobile_scanner` (mã vạch), `print_bluetooth_thermal` (máy in)

## Cấu trúc thư mục

Mã nguồn được tổ chức theo kiến trúc **Feature-First Clean Architecture** sử dụng các khái niệm domain-driven.

```text
lib/
├── core/                       # Tiện ích cốt lõi và thành phần dùng chung
│   ├── data/                   # Nguồn dữ liệu toàn cục (VD: khởi tạo Hive)
│   ├── error/                  # Mô hình Failure/Exception chuẩn hóa (tương thích fpdart)
│   ├── theme/                  # Giao diện, kiểu chữ, phong cách UI
│   ├── usecase/                # Hợp đồng UseCase cơ sở
│   ├── utils/                  # Tiện ích (VD: PrinterHelper, bộ định dạng)
│   ├── widgets/                # Widget UI tái sử dụng toàn cục
│   └── service_locator.dart    # Cấu hình dependency injection (get_it)
│
└── features/                   # Các module tính năng độc lập
    ├── billing/                # Thao tác POS: Giỏ hàng, Thanh toán, Tạo hóa đơn
    ├── product/                # Quản lý sản phẩm: Thêm, Liệt kê, Quét sản phẩm
    ├── settings/               # Cấu hình ứng dụng: Kết nối máy in, Cài đặt
    └── shop/                   # Cấu hình thông tin cửa hàng
```

*Ghi chú: Mỗi tính năng được chia nhỏ thêm theo các tầng Clean Architecture: `data`, `domain` và `presentation`.*

## Các trường hợp sử dụng

- **Nhập đơn hàng nhanh**: Thu ngân mở ứng dụng, sử dụng camera thiết bị để quét mã vạch sản phẩm ngay lập tức. Sản phẩm được thêm vào giỏ hàng, tổng tiền được tính toán và hóa đơn được hoàn tất.
- **Tạo hóa đơn giấy**: Sau khi xác nhận thanh toán, ứng dụng kích hoạt máy in nhiệt Bluetooth bên ngoài để in hóa đơn chi tiết ngay lập tức với tiêu đề cửa hàng.
- **Quản lý kho hàng**: Quản lý mở tính năng Sản phẩm để thêm hàng mới vào cơ sở dữ liệu cục bộ, chụp ảnh mã vạch để liên kết SKU cho các lần thanh toán nhanh trong tương lai.
- **Hoạt động không cần mạng**: Doanh nghiệp hoạt động tại gian hàng triển lãm với mạng kém. Ứng dụng hoạt động hoàn toàn qua cơ sở dữ liệu Hive cục bộ và Bluetooth, không bị ảnh hưởng bởi mất kết nối mạng.

## Hướng dẫn Cài đặt & Build

### Yêu cầu hệ thống

- **Flutter SDK** phiên bản `>=3.1.0` trở lên
- **Dart SDK** (đi kèm với Flutter)
- **Android Studio** (cho phát triển Android) hoặc **Xcode** (cho phát triển iOS)
- **Git** đã cài đặt trên hệ thống
- *Tùy chọn*: Thiết bị Android/iOS thật và Máy in nhiệt Bluetooth để kiểm thử tích hợp phần cứng

### Bước 1: Cài đặt Flutter

Nếu chưa cài đặt Flutter, tải và cài đặt từ [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install).

Kiểm tra cài đặt:
```bash
flutter doctor
```

Đảm bảo tất cả các mục kiểm tra đều hiển thị dấu tích xanh (hoặc ít nhất Flutter và nền tảng mục tiêu).

### Bước 2: Clone dự án

```bash
git clone <đường_dẫn_repository>
cd billing_app
```

### Bước 3: Cài đặt các gói phụ thuộc

```bash
flutter pub get
```

### Bước 4: Tạo mã tự động (Code Generation)

Dự án sử dụng `build_runner` để tạo các Hive adapter và JSON serialization. Chạy lệnh sau:

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Ghi chú**: Nếu bạn gặp lỗi xung đột, tham số `--delete-conflicting-outputs` sẽ tự động xóa các file cũ và tạo lại.

### Bước 5: Chạy ứng dụng

#### Chạy trên Android:
```bash
flutter run
```

#### Chạy trên iOS:
```bash
cd ios && pod install && cd ..
flutter run
```

#### Build APK (Android):
```bash
flutter build apk --release
```
File APK sẽ được tạo tại `build/app/outputs/flutter-apk/app-release.apk`.

#### Build App Bundle (Android - cho Google Play):
```bash
flutter build appbundle --release
```

#### Build iOS (yêu cầu macOS):
```bash
flutter build ios --release
```

## Cấu hình Máy in Bluetooth

### Thiết lập kết nối máy in:

1. **Bật Bluetooth** trên thiết bị di động của bạn.
2. **Ghép nối máy in**: Vào Cài đặt Bluetooth của điện thoại, tìm và ghép nối với máy in nhiệt.
3. **Mở ứng dụng** > vào **Cài đặt** > mục **Phần cứng**.
4. Nhấn nút **Làm mới** (biểu tượng refresh) để ứng dụng tìm và kết nối tự động với máy in đã ghép nối.
5. Khi kết nối thành công, trạng thái sẽ hiển thị **"ĐÃ KẾT NỐI"**.

### Yêu cầu quyền:
Ứng dụng sẽ yêu cầu các quyền sau:
- **Camera**: Để quét mã vạch
- **Bluetooth**: Để kết nối với máy in nhiệt
- **Vị trí**: Để tìm kiếm thiết bị Bluetooth gần đây (yêu cầu trên Android)

### Máy in được hỗ trợ:
Ứng dụng hỗ trợ các máy in nhiệt Bluetooth tiêu chuẩn sử dụng giao thức ESC/POS. Hầu hết các máy in nhiệt Bluetooth phổ biến trên thị trường đều tương thích.

## Cấu hình Thông tin Cửa hàng

1. Mở ứng dụng > **Cài đặt** > **Thông tin cửa hàng**.
2. Điền các thông tin sau:
   - **Tên cửa hàng**: Tên hiển thị trên hóa đơn
   - **Địa chỉ dòng 1**: Địa chỉ chính
   - **Địa chỉ dòng 2**: Địa chỉ phụ (tùy chọn)
   - **Số điện thoại**: Số liên hệ
   - **UPI ID**: ID thanh toán UPI (tùy chọn, dùng để tạo mã QR thanh toán)
   - **Chân trang hóa đơn**: Văn bản hiển thị cuối hóa đơn
3. Nhấn **Lưu thông tin** để lưu lại.

Các thông tin này sẽ tự động hiển thị trên mỗi hóa đơn được in.

## Quản lý Sản phẩm

### Thêm sản phẩm mới:
1. Vào **Cài đặt** > **Sản phẩm** > nhấn nút **+**.
2. Quét mã vạch bằng camera hoặc nhập thủ công.
3. Nhập tên sản phẩm và giá.
4. Nhấn **Thêm sản phẩm**.

### Sửa sản phẩm:
1. Trong danh sách sản phẩm, nhấn biểu tượng **chỉnh sửa** bên cạnh sản phẩm.
2. Cập nhật tên hoặc giá.
3. Nhấn **Lưu thay đổi**.

### Xóa sản phẩm:
1. Nhấn biểu tượng **xóa** bên cạnh sản phẩm.
2. Xác nhận xóa trong hộp thoại.

## Quy trình Thanh toán

1. Trên màn hình chính, camera sẽ tự động quét mã vạch sản phẩm.
2. Sản phẩm quét được sẽ xuất hiện trong danh sách phía dưới.
3. Điều chỉnh số lượng bằng nút **+** / **-**.
4. Nhấn **Xem đơn hàng** để chuyển sang trang thanh toán.
5. Kiểm tra đơn hàng và nhấn **In hóa đơn** để in qua máy in Bluetooth.

## Hướng dẫn Đóng góp

1. **Quy tắc Clean Architecture**: Duy trì ranh giới nghiêm ngặt giữa các tầng `domain`, `data` và `presentation`.
2. **Trạng thái bất biến**: Chỉ phát ra các trạng thái bất biến từ BLoC sử dụng `equatable`.
3. **Không dùng Exception trực tiếp trong Domain**: Sử dụng pattern `Either<Failure, Type>` của `fpdart` để xử lý luồng điều khiển ngoại lệ.
