import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/warehouse.dart';
import '../../domain/repositories/warehouse_repository.dart';
import '../models/warehouse_model.dart';

class WarehouseRepositoryImpl implements WarehouseRepository {
  static const String _defaultName = 'Kho chính';

  @override
  Future<Either<Failure, List<Warehouse>>> getWarehouses() async {
    try {
      final box = HiveDatabase.warehouseBox;
      final list = box.values.map((e) => e.toEntity()).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      return Right(list);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Warehouse>> ensureDefaultWarehouse() async {
    try {
      final box = HiveDatabase.warehouseBox;
      if (box.isEmpty) {
        final w = WarehouseModel(
          id: const Uuid().v4(),
          name: _defaultName,
          location: null,
        );
        await box.put(w.id, w);
        return Right(w.toEntity());
      }
      final first = box.values.first;
      return Right(first.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addWarehouse(Warehouse warehouse) async {
    try {
      final box = HiveDatabase.warehouseBox;
      final model = WarehouseModel.fromEntity(warehouse);
      await box.put(model.id, model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateWarehouse(Warehouse warehouse) async {
    try {
      final box = HiveDatabase.warehouseBox;
      final model = WarehouseModel.fromEntity(warehouse);
      await box.put(model.id, model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWarehouse(String id) async {
    try {
      final box = HiveDatabase.warehouseBox;
      await box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Warehouse?>> getWarehouseById(String id) async {
    try {
      final box = HiveDatabase.warehouseBox;
      final m = box.get(id);
      return Right(m?.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
