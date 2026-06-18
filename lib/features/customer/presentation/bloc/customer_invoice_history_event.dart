part of 'customer_invoice_history_bloc.dart';

abstract class CustomerInvoiceHistoryEvent extends Equatable {
  const CustomerInvoiceHistoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadCustomerInvoiceHistoryEvent extends CustomerInvoiceHistoryEvent {
  final String? customerId;

  const LoadCustomerInvoiceHistoryEvent({this.customerId});

  @override
  List<Object?> get props => [customerId];
}
