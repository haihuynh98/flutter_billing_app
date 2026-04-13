class AppValidators {
  static String? Function(String?) required(String message) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập giá bán';
    }
    if (double.tryParse(value) == null) {
      return 'Vui lòng nhập số hợp lệ';
    }
    if (double.parse(value) < 0) {
      return 'Giá bán không được nhỏ hơn 0';
    }
    return null;
  }
}
