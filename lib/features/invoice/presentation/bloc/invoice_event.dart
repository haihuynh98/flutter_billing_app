part of 'invoice_bloc.dart';

abstract class InvoiceListEvent extends Equatable {
  const InvoiceListEvent();
  @override
  List<Object?> get props => [];
}

class LoadDraftInvoicesEvent extends InvoiceListEvent {
  const LoadDraftInvoicesEvent();
}

class LoadConfirmedInvoicesEvent extends InvoiceListEvent {
  const LoadConfirmedInvoicesEvent();
}

class DeleteDraftInvoiceEvent extends InvoiceListEvent {
  final String id;
  const DeleteDraftInvoiceEvent(this.id);
  @override
  List<Object?> get props => [id];
}
