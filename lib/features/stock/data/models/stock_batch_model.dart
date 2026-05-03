import 'package:hive/hive.dart';

import '../../domain/entities/stock_batch.dart';

part 'stock_batch_model.g.dart';

@HiveType(typeId: 3)
class StockBatchModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  final String warehouseId;

  @HiveField(3)
  final DateTime importDate;

  @HiveField(4)
  final int quantity;

  @HiveField(5)
  final double importPrice;

  @HiveField(6)
  final String? supplierName;

  @HiveField(7)
  final DateTime? expiryDate;

  StockBatchModel({
    required this.id,
    required this.productId,
    required this.warehouseId,
    required this.importDate,
    required this.quantity,
    required this.importPrice,
    this.supplierName,
    this.expiryDate,
  });

  StockBatch toEntity() => StockBatch(
        id: id,
        productId: productId,
        warehouseId: warehouseId,
        importDate: importDate,
        quantity: quantity,
        importPrice: importPrice,
        supplierName: supplierName,
        expiryDate: expiryDate,
      );

  factory StockBatchModel.fromEntity(StockBatch e) => StockBatchModel(
        id: e.id,
        productId: e.productId,
        warehouseId: e.warehouseId,
        importDate: e.importDate,
        quantity: e.quantity,
        importPrice: e.importPrice,
        supplierName: e.supplierName,
        expiryDate: e.expiryDate,
      );

  StockBatchModel copyWith({int? quantity}) => StockBatchModel(
        id: id,
        productId: productId,
        warehouseId: warehouseId,
        importDate: importDate,
        quantity: quantity ?? this.quantity,
        importPrice: importPrice,
        supplierName: supplierName,
        expiryDate: expiryDate,
      );
}
