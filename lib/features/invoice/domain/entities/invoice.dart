import 'package:equatable/equatable.dart';

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

  const Invoice({
    required this.id,
    required this.status,
    required this.createdAt,
    this.confirmedAt,
    this.items = const [],
    this.sequenceNumber,
  });

  double get total =>
      items.fold<double>(0, (sum, i) => sum + i.price * i.quantity);

  Invoice copyWith({
    InvoiceStatus? status,
    DateTime? confirmedAt,
    List<InvoiceItem>? items,
    int? sequenceNumber,
  }) {
    return Invoice(
      id: id,
      status: status ?? this.status,
      createdAt: createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      items: items ?? this.items,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    );
  }

  @override
  List<Object?> get props =>
      [id, status, createdAt, confirmedAt, items, sequenceNumber];
}
