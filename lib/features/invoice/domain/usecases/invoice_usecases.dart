import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/invoice.dart';
import '../entities/invoice_item.dart';
import '../repositories/invoice_repository.dart';

class CreateDraftInvoiceParams {
  final String? customerId;
  final String customerName;

  const CreateDraftInvoiceParams({
    this.customerId,
    this.customerName = 'Khách hàng lẻ',
  });
}

class CreateDraftInvoiceUseCase
    implements UseCase<Invoice, CreateDraftInvoiceParams> {
  final InvoiceRepository repository;
  CreateDraftInvoiceUseCase(this.repository);

  @override
  Future<Either<Failure, Invoice>> call(CreateDraftInvoiceParams params) {
    return repository.createDraft(
      customerId: params.customerId,
      customerName: params.customerName,
    );
  }
}

class SetInvoiceCustomerParams {
  final String invoiceId;
  final String? customerId;
  final String customerName;

  const SetInvoiceCustomerParams({
    required this.invoiceId,
    this.customerId,
    required this.customerName,
  });
}

class SetInvoiceCustomerUseCase
    implements UseCase<Invoice, SetInvoiceCustomerParams> {
  final InvoiceRepository repository;
  SetInvoiceCustomerUseCase(this.repository);

  @override
  Future<Either<Failure, Invoice>> call(SetInvoiceCustomerParams params) {
    return repository.setCustomer(
      invoiceId: params.invoiceId,
      customerId: params.customerId,
      customerName: params.customerName,
    );
  }
}

class GetInvoiceUseCase implements UseCase<Invoice?, String> {
  final InvoiceRepository repository;
  GetInvoiceUseCase(this.repository);

  @override
  Future<Either<Failure, Invoice?>> call(String id) {
    return repository.getInvoice(id);
  }
}

class AddOrIncrementInvoiceItemParams {
  final String invoiceId;
  final InvoiceItem itemDelta;

  const AddOrIncrementInvoiceItemParams({
    required this.invoiceId,
    required this.itemDelta,
  });
}

class AddOrIncrementInvoiceItemUseCase
    implements UseCase<Invoice, AddOrIncrementInvoiceItemParams> {
  final InvoiceRepository repository;
  AddOrIncrementInvoiceItemUseCase(this.repository);

  @override
  Future<Either<Failure, Invoice>> call(AddOrIncrementInvoiceItemParams params) {
    return repository.addOrIncrementItem(
      invoiceId: params.invoiceId,
      itemDelta: params.itemDelta,
    );
  }
}

class UpdateInvoiceItemQuantityParams {
  final String invoiceId;
  final String productId;
  final String sourceBatchId;
  final int quantity;

  const UpdateInvoiceItemQuantityParams({
    required this.invoiceId,
    required this.productId,
    required this.sourceBatchId,
    required this.quantity,
  });
}

class UpdateInvoiceItemQuantityUseCase
    implements UseCase<Invoice, UpdateInvoiceItemQuantityParams> {
  final InvoiceRepository repository;
  UpdateInvoiceItemQuantityUseCase(this.repository);

  @override
  Future<Either<Failure, Invoice>> call(
      UpdateInvoiceItemQuantityParams params) {
    return repository.updateItemQuantity(
      invoiceId: params.invoiceId,
      productId: params.productId,
      sourceBatchId: params.sourceBatchId,
      quantity: params.quantity,
    );
  }
}

class RemoveInvoiceItemParams {
  final String invoiceId;
  final String productId;
  final String sourceBatchId;

  const RemoveInvoiceItemParams({
    required this.invoiceId,
    required this.productId,
    required this.sourceBatchId,
  });
}

class RemoveInvoiceItemUseCase implements UseCase<Invoice, RemoveInvoiceItemParams> {
  final InvoiceRepository repository;
  RemoveInvoiceItemUseCase(this.repository);

  @override
  Future<Either<Failure, Invoice>> call(RemoveInvoiceItemParams params) {
    return repository.removeItem(
      invoiceId: params.invoiceId,
      productId: params.productId,
      sourceBatchId: params.sourceBatchId,
    );
  }
}

class ConfirmInvoiceUseCase implements UseCase<Invoice, String> {
  final InvoiceRepository repository;
  ConfirmInvoiceUseCase(this.repository);

  @override
  Future<Either<Failure, Invoice>> call(String invoiceId) {
    return repository.confirm(invoiceId);
  }
}

class CancelDraftInvoiceUseCase implements UseCase<void, String> {
  final InvoiceRepository repository;
  CancelDraftInvoiceUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String invoiceId) {
    return repository.cancelDraft(invoiceId);
  }
}

class ListDraftInvoicesUseCase implements UseCase<List<Invoice>, NoParams> {
  final InvoiceRepository repository;
  ListDraftInvoicesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Invoice>>> call(NoParams params) {
    return repository.listDrafts();
  }
}

class ListConfirmedInvoicesUseCase implements UseCase<List<Invoice>, int> {
  final InvoiceRepository repository;
  ListConfirmedInvoicesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Invoice>>> call(int limit) {
    return repository.listConfirmed(limit: limit);
  }
}

class ListInvoicesByCustomerParams {
  final String? customerId;

  const ListInvoicesByCustomerParams({this.customerId});
}

class ListInvoicesByCustomerUseCase
    implements UseCase<List<Invoice>, ListInvoicesByCustomerParams> {
  final InvoiceRepository repository;
  ListInvoicesByCustomerUseCase(this.repository);

  @override
  Future<Either<Failure, List<Invoice>>> call(
      ListInvoicesByCustomerParams params) {
    return repository.listByCustomer(customerId: params.customerId);
  }
}
