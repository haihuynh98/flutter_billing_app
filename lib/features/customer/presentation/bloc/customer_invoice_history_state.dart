part of 'customer_invoice_history_bloc.dart';

enum CustomerInvoiceHistoryStatus { initial, loading, loaded, error }

class CustomerInvoiceHistoryState extends Equatable {
  final CustomerInvoiceHistoryStatus status;
  final List<Invoice> drafts;
  final List<Invoice> confirmed;
  final double totalRevenue;
  final String? message;

  const CustomerInvoiceHistoryState({
    this.status = CustomerInvoiceHistoryStatus.initial,
    this.drafts = const [],
    this.confirmed = const [],
    this.totalRevenue = 0,
    this.message,
  });

  int get confirmedCount => confirmed.length;
  int get draftCount => drafts.length;

  CustomerInvoiceHistoryState copyWith({
    CustomerInvoiceHistoryStatus? status,
    List<Invoice>? drafts,
    List<Invoice>? confirmed,
    double? totalRevenue,
    String? message,
  }) {
    return CustomerInvoiceHistoryState(
      status: status ?? this.status,
      drafts: drafts ?? this.drafts,
      confirmed: confirmed ?? this.confirmed,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      message: message,
    );
  }

  @override
  List<Object?> get props =>
      [status, drafts, confirmed, totalRevenue, message];
}
