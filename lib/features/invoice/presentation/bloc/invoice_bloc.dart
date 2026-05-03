import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/invoice.dart';
import '../../domain/usecases/invoice_usecases.dart';
import '../../../../core/usecase/usecase.dart';

part 'invoice_event.dart';
part 'invoice_state.dart';

class InvoiceBloc extends Bloc<InvoiceListEvent, InvoiceListState> {
  final ListDraftInvoicesUseCase listDraftInvoicesUseCase;
  final ListConfirmedInvoicesUseCase listConfirmedInvoicesUseCase;
  final CancelDraftInvoiceUseCase cancelDraftInvoiceUseCase;

  InvoiceBloc({
    required this.listDraftInvoicesUseCase,
    required this.listConfirmedInvoicesUseCase,
    required this.cancelDraftInvoiceUseCase,
  }) : super(const InvoiceListState()) {
    on<LoadDraftInvoicesEvent>(_onLoadDrafts);
    on<LoadConfirmedInvoicesEvent>(_onLoadConfirmed);
    on<DeleteDraftInvoiceEvent>(_onDeleteDraft);
  }

  Future<void> _onLoadDrafts(
      LoadDraftInvoicesEvent event, Emitter<InvoiceListState> emit) async {
    emit(state.copyWith(status: InvoiceListStatus.loading));
    final r = await listDraftInvoicesUseCase(NoParams());
    r.fold(
      (f) => emit(state.copyWith(
          status: InvoiceListStatus.error, message: f.message)),
      (list) => emit(state.copyWith(
          status: InvoiceListStatus.loaded, drafts: list, message: null)),
    );
  }

  Future<void> _onLoadConfirmed(
      LoadConfirmedInvoicesEvent event, Emitter<InvoiceListState> emit) async {
    emit(state.copyWith(status: InvoiceListStatus.loading));
    final r = await listConfirmedInvoicesUseCase(100);
    r.fold(
      (f) => emit(state.copyWith(
          status: InvoiceListStatus.error, message: f.message)),
      (list) => emit(state.copyWith(
          status: InvoiceListStatus.loaded, confirmed: list, message: null)),
    );
  }

  Future<void> _onDeleteDraft(
      DeleteDraftInvoiceEvent event, Emitter<InvoiceListState> emit) async {
    final r = await cancelDraftInvoiceUseCase(event.id);
    r.fold(
      (f) => emit(state.copyWith(
          status: InvoiceListStatus.error, message: f.message)),
      (_) {
        emit(state.copyWith(
            status: InvoiceListStatus.success, message: 'Đã xóa đơn'));
        add(const LoadDraftInvoicesEvent());
      },
    );
  }
}
