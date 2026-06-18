import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String note;

  const Customer({
    required this.id,
    required this.name,
    this.phone = '',
    this.address = '',
    this.note = '',
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? note,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, address, note];
}

/// Virtual retail customer shown in pickers; not stored in Hive.
class RetailCustomer {
  static const String name = 'Khách hàng lẻ';
}
