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
      return 'Vui long nhap gia';
    }
    if (double.tryParse(value) == null) {
      return 'Vui long nhap so hop le';
    }
    if (double.parse(value) < 0) {
      return 'Gia khong duoc am';
    }
    return null;
  }
}
