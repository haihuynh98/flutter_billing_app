import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/stock_batch.dart';
import '../entities/stock_movement.dart';

abstract class StockRepository {
  Future<Either<Failure, List<StockBatch>>> listBatchesByProduct(String productId);
  Future<Either<Failure, List<StockBatch>>> listBatchesByWarehouse(
      String warehouseId);
  Future<Either<Failure, List<StockBatch>>> listExpiringBatches(
      {int withinDays = 30});
  Future<Either<Failure, int>> totalStock(String productId);
  Future<Either<Failure, Map<String, int>>> totalStockByProductIds(
      Iterable<String> productIds);

  /// Merge when (productId, warehouseId, importDate, importPrice, supplierName, expiryDate) all match.
  Future<Either<Failure, ({StockBatch batch, bool merged})>> importStock({
    required String productId,
    required String warehouseId,
    required DateTime date,
    required int quantity,
    required double importPrice,
    String? supplierName,
    DateTime? expiryDate,
  });

  Future<Either<Failure, void>> deductFromBatches(
    List<StockDeductionLine> lines,
  );

  Future<Either<Failure, List<StockMovement>>> listMovements({
    String? productId,
    String? warehouseId,
    MovementType? type,
    int limit = 200,
  });

  Future<Either<Failure, List<String>>> distinctSupplierNames();

  Future<Either<Failure, int>> countActiveBatchesInWarehouse(String warehouseId);
  Future<Either<Failure, int>> countDistinctProductsInWarehouse(
      String warehouseId);

  Future<Either<Failure, StockBatch>> getBatch(String batchId);
}

class StockDeductionLine {
  final String batchId;
  final int quantity;
  final String invoiceId;
  final String productId;
  final String warehouseId;

  const StockDeductionLine({
    required this.batchId,
    required this.quantity,
    required this.invoiceId,
    required this.productId,
    required this.warehouseId,
  });
}
