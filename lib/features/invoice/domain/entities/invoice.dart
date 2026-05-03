import 'package:equatable/equatable.dart';

import 'invoice_item.dart';
import 'invoice_status.dart';

class Invoice extends Equatable {
  final String id;
  final InvoiceStatus status;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final List<InvoiceItem> items;

  const Invoice({
    required this.id,
    required this.status,
    required this.createdAt,
    this.confirmedAt,
    this.items = const [],
  });

  double get total =>
      items.fold<double>(0, (sum, i) => sum + i.price * i.quantity);

  Invoice copyWith({
    InvoiceStatus? status,
    DateTime? confirmedAt,
    List<InvoiceItem>? items,
  }) {
    return Invoice(
      id: id,
      status: status ?? this.status,
      createdAt: createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [id, status, createdAt, confirmedAt, items];
}
