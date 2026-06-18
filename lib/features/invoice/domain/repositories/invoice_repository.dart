import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/invoice.dart';
import '../entities/invoice_item.dart';

abstract class InvoiceRepository {
  Future<Either<Failure, Invoice>> createDraft({
    String? customerId,
    String customerName = 'Khách hàng lẻ',
  });
  Future<Either<Failure, Invoice?>> getInvoice(String id);
  Future<Either<Failure, Invoice>> setCustomer({
    required String invoiceId,
    String? customerId,
    required String customerName,
  });
  Future<Either<Failure, Invoice>> addOrIncrementItem({
    required String invoiceId,
    required InvoiceItem itemDelta,
  });
  Future<Either<Failure, Invoice>> updateItemQuantity({
    required String invoiceId,
    required String productId,
    required String sourceBatchId,
    required int quantity,
  });
  Future<Either<Failure, Invoice>> removeItem({
    required String invoiceId,
    required String productId,
    required String sourceBatchId,
  });
  Future<Either<Failure, Invoice>> confirm(String id);
  Future<Either<Failure, void>> cancelDraft(String id);
  Future<Either<Failure, List<Invoice>>> listDrafts();
  Future<Either<Failure, List<Invoice>>> listConfirmed({int limit = 100});
}
