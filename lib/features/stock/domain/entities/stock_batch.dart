import 'package:equatable/equatable.dart';

import '../../../../core/utils/stock_constants.dart';

class StockBatch extends Equatable {
  final String id;
  final String productId;
  final String warehouseId;
  final DateTime importDate;
  final int quantity;
  final double importPrice;
  final String? supplierName;
  final DateTime? expiryDate;

  const StockBatch({
    required this.id,
    required this.productId,
    required this.warehouseId,
    required this.importDate,
    required this.quantity,
    required this.importPrice,
    this.supplierName,
    this.expiryDate,
  });

  bool get isExpired {
    if (expiryDate == null) return false;
    final today = dateOnly(DateTime.now());
    return dateOnly(expiryDate!).isBefore(today);
  }

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final today = dateOnly(DateTime.now());
    final exp = dateOnly(expiryDate!);
    if (exp.isBefore(today)) return false;
    final diff = exp.difference(today).inDays;
    return diff >= 0 && diff <= kExpiryWarningDays;
  }

  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    final today = dateOnly(DateTime.now());
    return dateOnly(expiryDate!).difference(today).inDays;
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        warehouseId,
        importDate,
        quantity,
        importPrice,
        supplierName,
        expiryDate,
      ];
}
