part of 'invoice_bloc.dart';

enum InvoiceListStatus { initial, loading, loaded, error, success }

class InvoiceListState extends Equatable {
  final InvoiceListStatus status;
  final List<Invoice> drafts;
  final List<Invoice> confirmed;
  final String? message;

  const InvoiceListState({
    this.status = InvoiceListStatus.initial,
    this.drafts = const [],
    this.confirmed = const [],
    this.message,
  });

  InvoiceListState copyWith({
    InvoiceListStatus? status,
    List<Invoice>? drafts,
    List<Invoice>? confirmed,
    String? message,
  }) {
    return InvoiceListState(
      status: status ?? this.status,
      drafts: drafts ?? this.drafts,
      confirmed: confirmed ?? this.confirmed,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, drafts, confirmed, message];
}
