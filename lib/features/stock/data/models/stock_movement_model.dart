import 'package:hive/hive.dart';

import '../../domain/entities/stock_movement.dart';

part 'stock_movement_model.g.dart';

/// typeIndex: 0 import, 1 sale, 2 adjustment
@HiveType(typeId: 4)
class StockMovementModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  final String warehouseId;

  @HiveField(3)
  final String? batchId;

  @HiveField(4)
  final int typeIndex;

  @HiveField(5)
  final int quantityDelta;

  @HiveField(6)
  final DateTime timestamp;

  @HiveField(7)
  final String? refInvoiceId;

  @HiveField(8)
  final String? note;

  @HiveField(9)
  final double? unitImportPrice;

  @HiveField(10)
  final String? supplierName;

  StockMovementModel({
    required this.id,
    required this.productId,
    required this.warehouseId,
    this.batchId,
    required this.typeIndex,
    required this.quantityDelta,
    required this.timestamp,
    this.refInvoiceId,
    this.note,
    this.unitImportPrice,
    this.supplierName,
  });

  MovementType get _type => MovementType.values[typeIndex.clamp(0, 2)];

  StockMovement toEntity() => StockMovement(
        id: id,
        productId: productId,
        warehouseId: warehouseId,
        batchId: batchId,
        type: _type,
        quantityDelta: quantityDelta,
        timestamp: timestamp,
        refInvoiceId: refInvoiceId,
        unitImportPrice: unitImportPrice,
        supplierName: supplierName,
        note: note,
      );

  factory StockMovementModel.fromEntity(StockMovement e) =>
      StockMovementModel(
        id: e.id,
        productId: e.productId,
        warehouseId: e.warehouseId,
        batchId: e.batchId,
        typeIndex: e.type.index,
        quantityDelta: e.quantityDelta,
        timestamp: e.timestamp,
        refInvoiceId: e.refInvoiceId,
        note: e.note,
        unitImportPrice: e.unitImportPrice,
        supplierName: e.supplierName,
      );
}
