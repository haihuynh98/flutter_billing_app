import 'package:equatable/equatable.dart';

class InvoiceItem extends Equatable {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String sourceWarehouseId;
  final String sourceBatchId;

  const InvoiceItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.sourceWarehouseId,
    required this.sourceBatchId,
  });

  double get lineTotal => price * quantity;

  InvoiceItem copyWith({int? quantity}) => InvoiceItem(
        productId: productId,
        productName: productName,
        price: price,
        quantity: quantity ?? this.quantity,
        sourceWarehouseId: sourceWarehouseId,
        sourceBatchId: sourceBatchId,
      );

  @override
  List<Object?> get props => [
        productId,
        productName,
        price,
        quantity,
        sourceWarehouseId,
        sourceBatchId,
      ];
}
