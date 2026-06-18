part of 'billing_bloc.dart';

class BillingState extends Equatable {
  final Invoice? currentInvoice;
  final String? pendingCustomerId;
  final String pendingCustomerName;
  final Product? pendingProduct;
  final List<StockBatch> pendingSources;
  final String? error;
  final bool isPrinting;
  final bool printSuccess;
  final bool isConfirming;
  final bool confirmSuccess;

  const BillingState({
    this.currentInvoice,
    this.pendingCustomerId,
    this.pendingCustomerName = RetailCustomer.name,
    this.pendingProduct,
    this.pendingSources = const [],
    this.error,
    this.isPrinting = false,
    this.printSuccess = false,
    this.isConfirming = false,
    this.confirmSuccess = false,
  });

  List<InvoiceItem> get cartItems => currentInvoice?.items ?? [];

  double get totalAmount => currentInvoice?.total ?? 0;

  String? get selectedCustomerId =>
      currentInvoice?.customerId ?? pendingCustomerId;

  String get selectedCustomerName =>
      currentInvoice?.customerName ?? pendingCustomerName;

  bool get needsSourcePick =>
      pendingProduct != null && pendingSources.isNotEmpty;

  BillingState copyWith({
    Invoice? currentInvoice,
    bool clearInvoice = false,
    String? pendingCustomerId,
    bool clearPendingCustomerId = false,
    String? pendingCustomerName,
    bool clearPendingCustomer = false,
    Product? pendingProduct,
    bool clearPendingProduct = false,
    List<StockBatch>? pendingSources,
    String? error,
    bool clearError = false,
    bool? isPrinting,
    bool? printSuccess,
    bool? isConfirming,
    bool? confirmSuccess,
    bool clearConfirmSuccess = false,
  }) {
    return BillingState(
      currentInvoice:
          clearInvoice ? null : (currentInvoice ?? this.currentInvoice),
      pendingCustomerId: clearPendingCustomer || clearInvoice
          ? null
          : (clearPendingCustomerId
              ? null
              : (pendingCustomerId ?? this.pendingCustomerId)),
      pendingCustomerName: clearPendingCustomer || clearInvoice
          ? RetailCustomer.name
          : (pendingCustomerName ?? this.pendingCustomerName),
      pendingProduct: clearPendingProduct
          ? null
          : (pendingProduct ?? this.pendingProduct),
      pendingSources: clearPendingProduct
          ? const []
          : (pendingSources ?? this.pendingSources),
      error: clearError ? null : (error ?? this.error),
      isPrinting: isPrinting ?? this.isPrinting,
      printSuccess: printSuccess ?? this.printSuccess,
      isConfirming: isConfirming ?? this.isConfirming,
      confirmSuccess: clearConfirmSuccess
          ? false
          : (confirmSuccess ?? this.confirmSuccess),
    );
  }

  BillingState clearInvoice() => BillingState(
        currentInvoice: null,
        pendingCustomerId: null,
        pendingCustomerName: RetailCustomer.name,
        pendingProduct: null,
        pendingSources: const [],
        error: error,
        isPrinting: isPrinting,
        printSuccess: printSuccess,
        isConfirming: isConfirming,
        confirmSuccess: confirmSuccess,
      );

  BillingState clearPending() => BillingState(
        currentInvoice: currentInvoice,
        pendingProduct: null,
        pendingSources: const [],
        error: error,
        isPrinting: isPrinting,
        printSuccess: printSuccess,
        isConfirming: isConfirming,
        confirmSuccess: confirmSuccess,
      );

  @override
  List<Object?> get props => [
        currentInvoice,
        pendingCustomerId,
        pendingCustomerName,
        pendingProduct,
        pendingSources,
        error,
        isPrinting,
        printSuccess,
        isConfirming,
        confirmSuccess,
      ];
}
