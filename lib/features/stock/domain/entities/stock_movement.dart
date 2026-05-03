import 'package:equatable/equatable.dart';

enum MovementType { import, sale, adjustment }

class StockMovement extends Equatable {
  final String id;
  final String productId;
  final String warehouseId;
  final String? batchId;
  final MovementType type;
  final int quantityDelta;
  final DateTime timestamp;
  final String? refInvoiceId;
  final double? unitImportPrice;
  final String? supplierName;
  final String? note;

  const StockMovement({
    required this.id,
    required this.productId,
    required this.warehouseId,
    this.batchId,
    required this.type,
    required this.quantityDelta,
    required this.timestamp,
    this.refInvoiceId,
    this.unitImportPrice,
    this.supplierName,
    this.note,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        warehouseId,
        batchId,
        type,
        quantityDelta,
        timestamp,
        refInvoiceId,
        unitImportPrice,
        supplierName,
        note,
      ];
}
