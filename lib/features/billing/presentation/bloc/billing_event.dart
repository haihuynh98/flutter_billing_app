part of 'billing_bloc.dart';

abstract class BillingEvent extends Equatable {
  const BillingEvent();
  @override
  List<Object?> get props => [];
}

class ScanBarcodeEvent extends BillingEvent {
  final String barcode;
  const ScanBarcodeEvent(this.barcode);
  @override
  List<Object?> get props => [barcode];
}

class PickSourceEvent extends BillingEvent {
  final StockBatch batch;
  final Product product;
  const PickSourceEvent({required this.batch, required this.product});
  @override
  List<Object?> get props => [batch, product];
}

class ClearPendingPickEvent extends BillingEvent {
  const ClearPendingPickEvent();
}

class UpdateQuantityEvent extends BillingEvent {
  final String productId;
  final String sourceBatchId;
  final int quantity;
  const UpdateQuantityEvent(this.productId, this.sourceBatchId, this.quantity);
  @override
  List<Object?> get props => [productId, sourceBatchId, quantity];
}

class RemoveProductFromCartEvent extends BillingEvent {
  final String productId;
  final String sourceBatchId;
  const RemoveProductFromCartEvent(this.productId, this.sourceBatchId);
  @override
  List<Object?> get props => [productId, sourceBatchId];
}

class ClearCartEvent extends BillingEvent {
  const ClearCartEvent();
}

class ClearCurrentInvoiceEvent extends BillingEvent {
  const ClearCurrentInvoiceEvent();
}

class OpenDraftInvoiceEvent extends BillingEvent {
  final String invoiceId;
  const OpenDraftInvoiceEvent(this.invoiceId);
  @override
  List<Object?> get props => [invoiceId];
}

class ConfirmInvoiceEvent extends BillingEvent {
  const ConfirmInvoiceEvent();
}

class PrintReceiptEvent extends BillingEvent {
  final String shopName;
  final String address1;
  final String address2;
  final String phone;
  final String footer;

  const PrintReceiptEvent({
    required this.shopName,
    required this.address1,
    required this.address2,
    required this.phone,
    required this.footer,
  });

  @override
  List<Object?> get props => [shopName, address1, address2, phone, footer];
}
