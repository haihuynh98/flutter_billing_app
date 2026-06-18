import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../invoice/domain/entities/invoice.dart';
import '../../../invoice/domain/entities/invoice_status.dart';
import '../../../invoice/domain/usecases/invoice_usecases.dart';

part 'customer_invoice_history_event.dart';
part 'customer_invoice_history_state.dart';

class CustomerInvoiceHistoryBloc
    extends Bloc<CustomerInvoiceHistoryEvent, CustomerInvoiceHistoryState> {
  final ListInvoicesByCustomerUseCase listInvoicesByCustomerUseCase;

  CustomerInvoiceHistoryBloc({
    required this.listInvoicesByCustomerUseCase,
  }) : super(const CustomerInvoiceHistoryState()) {
    on<LoadCustomerInvoiceHistoryEvent>(_onLoad);
  }

  Future<void> _onLoad(LoadCustomerInvoiceHistoryEvent event,
      Emitter<CustomerInvoiceHistoryState> emit) async {
    emit(state.copyWith(status: CustomerInvoiceHistoryStatus.loading));
    final result = await listInvoicesByCustomerUseCase(
      ListInvoicesByCustomerParams(customerId: event.customerId),
    );
    result.fold(
      (f) => emit(state.copyWith(
        status: CustomerInvoiceHistoryStatus.error,
        message: f.message,
      )),
      (invoices) {
        final drafts = invoices
            .where((i) => i.status == InvoiceStatus.draft)
            .toList();
        final confirmed = invoices
            .where((i) => i.status == InvoiceStatus.confirmed)
            .toList();
        final totalRevenue = confirmed.fold<double>(
          0,
          (sum, i) => sum + i.total,
        );
        emit(state.copyWith(
          status: CustomerInvoiceHistoryStatus.loaded,
          drafts: drafts,
          confirmed: confirmed,
          totalRevenue: totalRevenue,
          message: null,
        ));
      },
    );
  }
}
