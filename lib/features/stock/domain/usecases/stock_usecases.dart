import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/stock_batch.dart';
import '../entities/stock_movement.dart';
import '../repositories/stock_repository.dart';

class ImportStockParams {
  final String productId;
  final String warehouseId;
  final DateTime date;
  final int quantity;
  final double importPrice;
  final String? supplierName;
  final DateTime? expiryDate;

  const ImportStockParams({
    required this.productId,
    required this.warehouseId,
    required this.date,
    required this.quantity,
    required this.importPrice,
    this.supplierName,
    this.expiryDate,
  });
}

class ImportStockUseCase implements UseCase<({StockBatch batch, bool merged}), ImportStockParams> {
  final StockRepository repository;
  ImportStockUseCase(this.repository);

  @override
  Future<Either<Failure, ({StockBatch batch, bool merged})>> call(
      ImportStockParams params) {
    return repository.importStock(
      productId: params.productId,
      warehouseId: params.warehouseId,
      date: params.date,
      quantity: params.quantity,
      importPrice: params.importPrice,
      supplierName: params.supplierName,
      expiryDate: params.expiryDate,
    );
  }
}

class ListBatchesByProductUseCase
    implements UseCase<List<StockBatch>, String> {
  final StockRepository repository;
  ListBatchesByProductUseCase(this.repository);

  @override
  Future<Either<Failure, List<StockBatch>>> call(String productId) {
    return repository.listBatchesByProduct(productId);
  }
}

class ListBatchesByWarehouseUseCase
    implements UseCase<List<StockBatch>, String> {
  final StockRepository repository;
  ListBatchesByWarehouseUseCase(this.repository);

  @override
  Future<Either<Failure, List<StockBatch>>> call(String warehouseId) {
    return repository.listBatchesByWarehouse(warehouseId);
  }
}

class ListExpiringBatchesUseCase
    implements UseCase<List<StockBatch>, int> {
  final StockRepository repository;
  ListExpiringBatchesUseCase(this.repository);

  @override
  Future<Either<Failure, List<StockBatch>>> call(int withinDays) {
    return repository.listExpiringBatches(withinDays: withinDays);
  }
}

class GetTotalStockUseCase implements UseCase<int, String> {
  final StockRepository repository;
  GetTotalStockUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(String productId) {
    return repository.totalStock(productId);
  }
}

class GetTotalStockMapUseCase
    implements UseCase<Map<String, int>, List<String>> {
  final StockRepository repository;
  GetTotalStockMapUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, int>>> call(List<String> productIds) {
    return repository.totalStockByProductIds(productIds);
  }
}

class ListMovementsParams {
  final String? productId;
  final String? warehouseId;
  final MovementType? type;
  final int limit;

  const ListMovementsParams({
    this.productId,
    this.warehouseId,
    this.type,
    this.limit = 200,
  });
}

class ListMovementsUseCase
    implements UseCase<List<StockMovement>, ListMovementsParams> {
  final StockRepository repository;
  ListMovementsUseCase(this.repository);

  @override
  Future<Either<Failure, List<StockMovement>>> call(
      ListMovementsParams params) {
    return repository.listMovements(
      productId: params.productId,
      warehouseId: params.warehouseId,
      type: params.type,
      limit: params.limit,
    );
  }
}

class DistinctSupplierNamesUseCase implements UseCase<List<String>, NoParams> {
  final StockRepository repository;
  DistinctSupplierNamesUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) {
    return repository.distinctSupplierNames();
  }
}
