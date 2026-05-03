import 'package:hive/hive.dart';

import '../../domain/entities/invoice_item.dart';

part 'invoice_item_model.g.dart';

@HiveType(typeId: 6)
class InvoiceItemModel extends HiveObject {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final int quantity;

  @HiveField(4)
  final String sourceWarehouseId;

  @HiveField(5)
  final String sourceBatchId;

  InvoiceItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.sourceWarehouseId,
    required this.sourceBatchId,
  });

  InvoiceItem toEntity() => InvoiceItem(
        productId: productId,
        productName: productName,
        price: price,
        quantity: quantity,
        sourceWarehouseId: sourceWarehouseId,
        sourceBatchId: sourceBatchId,
      );

  factory InvoiceItemModel.fromEntity(InvoiceItem e) => InvoiceItemModel(
        productId: e.productId,
        productName: e.productName,
        price: e.price,
        quantity: e.quantity,
        sourceWarehouseId: e.sourceWarehouseId,
        sourceBatchId: e.sourceBatchId,
      );
}
