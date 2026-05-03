import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/stock_constants.dart';
import '../../domain/entities/stock_batch.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/repositories/stock_repository.dart';
import '../models/stock_batch_model.dart';
import '../models/stock_movement_model.dart';

class StockRepositoryImpl implements StockRepository {
  bool _sameExpiry(DateTime? a, DateTime? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return dateOnly(a) == dateOnly(b);
  }

  bool _sameSupplier(String? a, String? b) {
    final na = (a ?? '').trim();
    final nb = (b ?? '').trim();
    if (na.isEmpty && nb.isEmpty) return true;
    return na == nb;
  }

  @override
  Future<Either<Failure, List<StockBatch>>> listBatchesByProduct(
      String productId) async {
    try {
      final box = HiveDatabase.stockBatchBox;
      final list = box.values
          .where((b) => b.productId == productId && b.quantity > 0)
          .map((e) => e.toEntity())
          .toList();
      _sortBatchesForPick(list);
      return Right(list);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  /// Sort: non-expired first (soonest expiry first), then FIFO importDate; expired last.
  void _sortBatchesForPick(List<StockBatch> list) {
    int score(StockBatch b) {
      if (b.isExpired) return 2;
      if (b.expiryDate != null) return 0;
      return 1;
    }

    list.sort((a, b) {
      final sa = score(a);
      final sb = score(b);
      if (sa != sb) return sa.compareTo(sb);
      if (a.expiryDate != null && b.expiryDate != null) {
        final c = dateOnly(a.expiryDate!).compareTo(dateOnly(b.expiryDate!));
        if (c != 0) return c;
      }
      return a.importDate.compareTo(b.importDate);
    });
  }

  @override
  Future<Either<Failure, List<StockBatch>>> listBatchesByWarehouse(
      String warehouseId) async {
    try {
      final box = HiveDatabase.stockBatchBox;
      final list = box.values
          .where((b) => b.warehouseId == warehouseId)
          .map((e) => e.toEntity())
          .toList()
        ..sort((a, b) => a.importDate.compareTo(b.importDate));
      return Right(list);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StockBatch>>> listExpiringBatches(
      {int withinDays = 30}) async {
    try {
      final box = HiveDatabase.stockBatchBox;
      final today = dateOnly(DateTime.now());
      final horizon = today.add(Duration(days: withinDays));
      final list = <StockBatch>[];
      for (final b in box.values) {
        if (b.quantity <= 0) continue;
        if (b.expiryDate == null) continue;
        final exp = dateOnly(b.expiryDate!);
        if (exp.isAfter(horizon)) continue;
        list.add(b.toEntity());
      }
      _sortBatchesForPick(list);
      return Right(list);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> totalStock(String productId) async {
    try {
      final box = HiveDatabase.stockBatchBox;
      var sum = 0;
      for (final b in box.values) {
        if (b.productId == productId) sum += b.quantity;
      }
      return Right(sum);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> totalStockByProductIds(
      Iterable<String> productIds) async {
    try {
      final set = productIds.toSet();
      final map = <String, int>{for (final id in set) id: 0};
      final box = HiveDatabase.stockBatchBox;
      for (final b in box.values) {
        if (map.containsKey(b.productId)) {
          map[b.productId] = (map[b.productId] ?? 0) + b.quantity;
        }
      }
      return Right(map);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ({StockBatch batch, bool merged})>> importStock({
    required String productId,
    required String warehouseId,
    required DateTime date,
    required int quantity,
    required double importPrice,
    String? supplierName,
    DateTime? expiryDate,
  }) async {
    try {
      if (quantity <= 0) {
        return Left(ValidationFailure('Số lượng phải lớn hơn 0'));
      }
      final normDate = dateOnly(date);
      final normSupplier = supplierName?.trim();
      final supplierOrNull =
          normSupplier == null || normSupplier.isEmpty ? null : normSupplier;
      final normExpiry = expiryDate == null ? null : dateOnly(expiryDate);

      final box = HiveDatabase.stockBatchBox;
      StockBatchModel? existing;
      for (final b in box.values) {
        if (b.productId != productId || b.warehouseId != warehouseId) continue;
        if (dateOnly(b.importDate) != normDate) continue;
        if (b.importPrice != importPrice) continue;
        if (!_sameSupplier(b.supplierName, supplierOrNull)) continue;
        if (!_sameExpiry(b.expiryDate, normExpiry)) continue;
        existing = b;
        break;
      }

      final movementBox = HiveDatabase.stockMovementBox;
      final now = DateTime.now();
      final movementId = const Uuid().v4();

      if (existing != null) {
        final updated = existing.copyWith(quantity: existing.quantity + quantity);
        await box.put(updated.id, updated);
        await movementBox.put(
          movementId,
          StockMovementModel(
            id: movementId,
            productId: productId,
            warehouseId: warehouseId,
            batchId: updated.id,
            typeIndex: MovementType.import.index,
            quantityDelta: quantity,
            timestamp: now,
            refInvoiceId: null,
            note: null,
            unitImportPrice: importPrice,
            supplierName: supplierOrNull,
          ),
        );
        return Right((batch: updated.toEntity(), merged: true));
      }

      final id = const Uuid().v4();
      final model = StockBatchModel(
        id: id,
        productId: productId,
        warehouseId: warehouseId,
        importDate: normDate,
        quantity: quantity,
        importPrice: importPrice,
        supplierName: supplierOrNull,
        expiryDate: normExpiry,
      );
      await box.put(id, model);
      await movementBox.put(
        movementId,
        StockMovementModel(
          id: movementId,
          productId: productId,
          warehouseId: warehouseId,
          batchId: id,
          typeIndex: MovementType.import.index,
          quantityDelta: quantity,
          timestamp: now,
          refInvoiceId: null,
          note: null,
          unitImportPrice: importPrice,
          supplierName: supplierOrNull,
        ),
      );
      return Right((batch: model.toEntity(), merged: false));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deductFromBatches(
      List<StockDeductionLine> lines) async {
    try {
      final box = HiveDatabase.stockBatchBox;
      final movementBox = HiveDatabase.stockMovementBox;

      for (final line in lines) {
        final batch = box.get(line.batchId);
        if (batch == null) {
          return Left(ValidationFailure('Không tìm thấy lô hàng'));
        }
        if (batch.quantity < line.quantity) {
          return Left(ValidationFailure(
              'Lô hàng không đủ tồn (${batch.quantity} < ${line.quantity})'));
        }
      }

      final now = DateTime.now();
      for (final line in lines) {
        final batch = box.get(line.batchId)!;
        final updated = batch.copyWith(quantity: batch.quantity - line.quantity);
        await box.put(updated.id, updated);
        final mid = const Uuid().v4();
        await movementBox.put(
          mid,
          StockMovementModel(
            id: mid,
            productId: line.productId,
            warehouseId: line.warehouseId,
            batchId: line.batchId,
            typeIndex: MovementType.sale.index,
            quantityDelta: -line.quantity,
            timestamp: now,
            refInvoiceId: line.invoiceId,
            note: null,
            unitImportPrice: null,
            supplierName: null,
          ),
        );
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StockMovement>>> listMovements({
    String? productId,
    String? warehouseId,
    MovementType? type,
    int limit = 200,
  }) async {
    try {
      final box = HiveDatabase.stockMovementBox;
      var list = box.values.map((e) => e.toEntity()).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      if (productId != null) {
        list = list.where((m) => m.productId == productId).toList();
      }
      if (warehouseId != null) {
        list = list.where((m) => m.warehouseId == warehouseId).toList();
      }
      if (type != null) {
        list = list.where((m) => m.type == type).toList();
      }
      if (list.length > limit) {
        list = list.take(limit).toList();
      }
      return Right(list);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> distinctSupplierNames() async {
    try {
      final box = HiveDatabase.stockBatchBox;
      final names = <String>{};
      for (final b in box.values) {
        final n = b.supplierName?.trim();
        if (n != null && n.isNotEmpty) names.add(n);
      }
      final sorted = names.toList()..sort();
      return Right(sorted);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> countActiveBatchesInWarehouse(
      String warehouseId) async {
    try {
      final box = HiveDatabase.stockBatchBox;
      var n = 0;
      for (final b in box.values) {
        if (b.warehouseId == warehouseId && b.quantity > 0) n++;
      }
      return Right(n);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StockBatch>> getBatch(String batchId) async {
    try {
      final box = HiveDatabase.stockBatchBox;
      final b = box.get(batchId);
      if (b == null) {
        return Left(ValidationFailure('Không tìm thấy lô hàng'));
      }
      return Right(b.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> countDistinctProductsInWarehouse(
      String warehouseId) async {
    try {
      final box = HiveDatabase.stockBatchBox;
      final ids = <String>{};
      for (final b in box.values) {
        if (b.warehouseId == warehouseId && b.quantity > 0) {
          ids.add(b.productId);
        }
      }
      return Right(ids.length);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
