import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/warehouse.dart';

abstract class WarehouseRepository {
  Future<Either<Failure, List<Warehouse>>> getWarehouses();
  Future<Either<Failure, Warehouse>> ensureDefaultWarehouse();
  Future<Either<Failure, void>> addWarehouse(Warehouse warehouse);
  Future<Either<Failure, void>> updateWarehouse(Warehouse warehouse);
  Future<Either<Failure, void>> deleteWarehouse(String id);
  Future<Either<Failure, Warehouse?>> getWarehouseById(String id);
}
