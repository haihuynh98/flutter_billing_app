import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/warehouse.dart';
import '../repositories/warehouse_repository.dart';
import '../../../stock/domain/repositories/stock_repository.dart';

class GetWarehousesUseCase implements UseCase<List<Warehouse>, NoParams> {
  final WarehouseRepository repository;
  GetWarehousesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Warehouse>>> call(NoParams params) {
    return repository.getWarehouses();
  }
}

class EnsureDefaultWarehouseUseCase implements UseCase<Warehouse, NoParams> {
  final WarehouseRepository repository;
  EnsureDefaultWarehouseUseCase(this.repository);

  @override
  Future<Either<Failure, Warehouse>> call(NoParams params) {
    return repository.ensureDefaultWarehouse();
  }
}

class AddWarehouseUseCase implements UseCase<void, Warehouse> {
  final WarehouseRepository repository;
  AddWarehouseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Warehouse params) {
    return repository.addWarehouse(params);
  }
}

class UpdateWarehouseUseCase implements UseCase<void, Warehouse> {
  final WarehouseRepository repository;
  UpdateWarehouseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Warehouse params) {
    return repository.updateWarehouse(params);
  }
}

class DeleteWarehouseUseCase implements UseCase<void, String> {
  final WarehouseRepository repository;
  DeleteWarehouseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.deleteWarehouse(params);
  }
}

class CountDistinctProductsWithBatchesInWarehouseUseCase
    implements UseCase<int, String> {
  final StockRepository stockRepository;
  CountDistinctProductsWithBatchesInWarehouseUseCase(this.stockRepository);

  @override
  Future<Either<Failure, int>> call(String warehouseId) {
    return stockRepository.countDistinctProductsInWarehouse(warehouseId);
  }
}

class CountActiveBatchesInWarehouseUseCase implements UseCase<int, String> {
  final StockRepository stockRepository;
  CountActiveBatchesInWarehouseUseCase(this.stockRepository);

  @override
  Future<Either<Failure, int>> call(String warehouseId) {
    return stockRepository.countActiveBatchesInWarehouse(warehouseId);
  }
}
