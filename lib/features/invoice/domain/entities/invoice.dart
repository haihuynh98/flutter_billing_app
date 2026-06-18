import 'package:equatable/equatable.dart';

import '../../../customer/domain/entities/customer.dart';
import 'invoice_item.dart';
import 'invoice_status.dart';

class Invoice extends Equatable {
  final String id;
  final InvoiceStatus status;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final List<InvoiceItem> items;

  /// Assigned when the invoice is confirmed; used for display and receipt "Mã số".
  final int? sequenceNumber;

  /// `null` means retail / walk-in customer ([RetailCustomer.name]).
  final String? customerId;
  final String customerName;

  const Invoice({
    required this.id,
    required this.status,
    required this.createdAt,
    this.confirmedAt,
    this.items = const [],
    this.sequenceNumber,
    this.customerId,
    this.customerName = RetailCustomer.name,
  });

  double get total =>
      items.fold<double>(0, (sum, i) => sum + i.price * i.quantity);

  Invoice copyWith({
    InvoiceStatus? status,
    DateTime? confirmedAt,
    List<InvoiceItem>? items,
    int? sequenceNumber,
    String? customerId,
    bool clearCustomerId = false,
    String? customerName,
  }) {
    return Invoice(
      id: id,
      status: status ?? this.status,
      createdAt: createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      items: items ?? this.items,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      customerId: clearCustomerId ? null : (customerId ?? this.customerId),
      customerName: customerName ?? this.customerName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        status,
        createdAt,
        confirmedAt,
        items,
        sequenceNumber,
        customerId,
        customerName,
      ];
}
