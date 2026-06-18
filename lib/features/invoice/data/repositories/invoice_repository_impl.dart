import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../../stock/domain/repositories/stock_repository.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';
import '../../domain/entities/invoice_status.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../models/invoice_item_model.dart';
import '../models/invoice_model.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  InvoiceRepositoryImpl(this._stockRepository);

  final StockRepository _stockRepository;

  double _totalItems(List<InvoiceItemModel> items) {
    double sum = 0;
    for (final i in items) {
      sum += i.price * i.quantity;
    }
    return sum;
  }

  int _nextSequenceNumber(Box<InvoiceModel> box) {
    int max = 0;
    for (final i in box.values) {
      final n = i.sequenceNumber;
      if (n != null && n > max) max = n;
    }
    return max + 1;
  }

  InvoiceModel _rebuild(
    InvoiceModel inv, {
    List<InvoiceItemModel>? items,
    int? statusIndex,
    DateTime? confirmedAt,
    int? sequenceNumber,
    String? customerId,
    bool clearCustomerId = false,
    String? customerName,
  }) {
    final nextItems = items ?? inv.items;
    return InvoiceModel(
      id: inv.id,
      statusIndex: statusIndex ?? inv.statusIndex,
      createdAt: inv.createdAt,
      confirmedAt: confirmedAt ?? inv.confirmedAt,
      items: nextItems,
      totalSnapshot: _totalItems(nextItems),
      sequenceNumber: sequenceNumber ?? inv.sequenceNumber,
      customerId: clearCustomerId ? null : (customerId ?? inv.customerId),
      customerName: customerName ?? inv.customerName,
    );
  }

  @override
  Future<Either<Failure, Invoice>> createDraft({
    String? customerId,
    String customerName = RetailCustomer.name,
  }) async {
    try {
      final box = HiveDatabase.invoiceBox;
      final id = const Uuid().v4();
      final seq = _nextSequenceNumber(box);
      final m = InvoiceModel(
        id: id,
        statusIndex: InvoiceStatus.draft.index,
        createdAt: DateTime.now(),
        confirmedAt: null,
        items: [],
        totalSnapshot: 0,
        sequenceNumber: seq,
        customerId: customerId,
        customerName: customerName,
      );
      await box.put(id, m);
      return Right(m.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Invoice?>> getInvoice(String id) async {
    try {
      final box = HiveDatabase.invoiceBox;
      var m = box.get(id);
      if (m != null &&
          m.statusIndex == InvoiceStatus.draft.index &&
          m.sequenceNumber == null) {
        final seq = _nextSequenceNumber(box);
        m = _rebuild(m, sequenceNumber: seq);
        await box.put(id, m);
      }
      return Right(m?.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Invoice>> setCustomer({
    required String invoiceId,
    String? customerId,
    required String customerName,
  }) async {
    try {
      final box = HiveDatabase.invoiceBox;
      final inv = box.get(invoiceId);
      if (inv == null) {
        return Left(ValidationFailure('Không tìm thấy hóa đơn'));
      }
      if (inv.statusIndex != InvoiceStatus.draft.index) {
        return Left(ValidationFailure('Chỉ sửa được đơn đang thực hiện'));
      }
      final updated = _rebuild(
        inv,
        customerId: customerId,
        clearCustomerId: customerId == null,
        customerName: customerName,
      );
      await box.put(invoiceId, updated);
      return Right(updated.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Invoice>> addOrIncrementItem({
    required String invoiceId,
    required InvoiceItem itemDelta,
  }) async {
    try {
      final box = HiveDatabase.invoiceBox;
      final inv = box.get(invoiceId);
      if (inv == null) {
        return Left(ValidationFailure('Không tìm thấy hóa đơn'));
      }
      if (inv.statusIndex != InvoiceStatus.draft.index) {
        return Left(ValidationFailure('Chỉ sửa được đơn đang thực hiện'));
      }
      var seq = inv.sequenceNumber;
      if (seq == null) {
        seq = _nextSequenceNumber(box);
      }
      final items = List<InvoiceItemModel>.from(inv.items);
      final idx = items.indexWhere((e) =>
          e.productId == itemDelta.productId &&
          e.sourceBatchId == itemDelta.sourceBatchId);
      if (idx >= 0) {
        final cur = items[idx];
        items[idx] = InvoiceItemModel(
          productId: cur.productId,
          productName: cur.productName,
          price: cur.price,
          quantity: cur.quantity + itemDelta.quantity,
          sourceWarehouseId: cur.sourceWarehouseId,
          sourceBatchId: cur.sourceBatchId,
        );
      } else {
        items.add(InvoiceItemModel.fromEntity(itemDelta));
      }
      final updated = _rebuild(inv, items: items, sequenceNumber: seq);
      await box.put(invoiceId, updated);
      return Right(updated.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Invoice>> updateItemQuantity({
    required String invoiceId,
    required String productId,
    required String sourceBatchId,
    required int quantity,
  }) async {
    try {
      final box = HiveDatabase.invoiceBox;
      final inv = box.get(invoiceId);
      if (inv == null) {
        return Left(ValidationFailure('Không tìm thấy hóa đơn'));
      }
      if (inv.statusIndex != InvoiceStatus.draft.index) {
        return Left(ValidationFailure('Chỉ sửa được đơn đang thực hiện'));
      }
      var seq = inv.sequenceNumber;
      if (seq == null) {
        seq = _nextSequenceNumber(box);
      }
      final items = List<InvoiceItemModel>.from(inv.items);
      final idx = items.indexWhere((e) =>
          e.productId == productId && e.sourceBatchId == sourceBatchId);
      if (idx < 0) {
        return Left(ValidationFailure('Không tìm thấy dòng hàng'));
      }
      if (quantity <= 0) {
        items.removeAt(idx);
      } else {
        final cur = items[idx];
        items[idx] = InvoiceItemModel(
          productId: cur.productId,
          productName: cur.productName,
          price: cur.price,
          quantity: quantity,
          sourceWarehouseId: cur.sourceWarehouseId,
          sourceBatchId: cur.sourceBatchId,
        );
      }
      final updated = _rebuild(inv, items: items, sequenceNumber: seq);
      await box.put(invoiceId, updated);
      return Right(updated.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Invoice>> removeItem({
    required String invoiceId,
    required String productId,
    required String sourceBatchId,
  }) async {
    return updateItemQuantity(
      invoiceId: invoiceId,
      productId: productId,
      sourceBatchId: sourceBatchId,
      quantity: 0,
    );
  }

  @override
  Future<Either<Failure, Invoice>> confirm(String id) async {
    try {
      final box = HiveDatabase.invoiceBox;
      final inv = box.get(id);
      if (inv == null) {
        return Left(ValidationFailure('Không tìm thấy hóa đơn'));
      }
      if (inv.statusIndex != InvoiceStatus.draft.index) {
        return Left(ValidationFailure('Đơn đã được xác nhận hoặc đã hủy'));
      }
      if (inv.items.isEmpty) {
        return Left(ValidationFailure('Giỏ hàng trống'));
      }

      final lines = <StockDeductionLine>[];
      for (final i in inv.items) {
        lines.add(StockDeductionLine(
          batchId: i.sourceBatchId,
          quantity: i.quantity,
          invoiceId: id,
          productId: i.productId,
          warehouseId: i.sourceWarehouseId,
        ));
      }

      final deduct = await _stockRepository.deductFromBatches(lines);
      return await deduct.fold(
        (f) async => Left(f),
        (_) async {
          final seq =
              inv.sequenceNumber ?? _nextSequenceNumber(box);
          final updated = _rebuild(
            inv,
            statusIndex: InvoiceStatus.confirmed.index,
            confirmedAt: DateTime.now(),
            sequenceNumber: seq,
          );
          await box.put(id, updated);
          return Right(updated.toEntity());
        },
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelDraft(String id) async {
    try {
      final box = HiveDatabase.invoiceBox;
      final inv = box.get(id);
      if (inv == null) return const Right(null);
      if (inv.statusIndex != InvoiceStatus.draft.index) {
        return Left(ValidationFailure('Chỉ hủy được đơn đang thực hiện'));
      }
      await box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Invoice>>> listDrafts() async {
    try {
      final box = HiveDatabase.invoiceBox;
      final list = box.values
          .where((i) => i.statusIndex == InvoiceStatus.draft.index)
          .map((e) => e.toEntity())
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Right(list);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Invoice>>> listConfirmed({int limit = 100}) async {
    try {
      final box = HiveDatabase.invoiceBox;
      var list = box.values
          .where((i) => i.statusIndex == InvoiceStatus.confirmed.index)
          .map((e) => e.toEntity())
          .toList()
        ..sort((a, b) {
          final ca = a.confirmedAt ?? a.createdAt;
          final cb = b.confirmedAt ?? b.createdAt;
          return cb.compareTo(ca);
        });
      if (list.length > limit) {
        list = list.take(limit).toList();
      }
      return Right(list);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  bool _matchesCustomer(InvoiceModel invoice, String? customerId) {
    if (customerId == null) return invoice.customerId == null;
    return invoice.customerId == customerId;
  }

  @override
  Future<Either<Failure, List<Invoice>>> listByCustomer({
    required String? customerId,
    int limit = 200,
  }) async {
    try {
      final box = HiveDatabase.invoiceBox;
      var list = box.values
          .where((i) => _matchesCustomer(i, customerId))
          .map((e) => e.toEntity())
          .toList()
        ..sort((a, b) {
          final da = a.confirmedAt ?? a.createdAt;
          final db = b.confirmedAt ?? b.createdAt;
          return db.compareTo(da);
        });
      if (list.length > limit) {
        list = list.take(limit).toList();
      }
      return Right(list);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
