import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart' show ValidationFailure;
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/customer.dart';
import '../../domain/usecases/customer_usecases.dart';

part 'customer_event.dart';
part 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final GetCustomersUseCase getCustomersUseCase;
  final AddCustomerUseCase addCustomerUseCase;
  final UpdateCustomerUseCase updateCustomerUseCase;
  final DeleteCustomerUseCase deleteCustomerUseCase;

  CustomerBloc({
    required this.getCustomersUseCase,
    required this.addCustomerUseCase,
    required this.updateCustomerUseCase,
    required this.deleteCustomerUseCase,
  }) : super(const CustomerState()) {
    on<LoadCustomersEvent>(_onLoad);
    on<AddCustomerEvent>(_onAdd);
    on<UpdateCustomerEvent>(_onUpdate);
    on<DeleteCustomerEvent>(_onDelete);
  }

  Future<void> _onLoad(
      LoadCustomersEvent event, Emitter<CustomerState> emit) async {
    emit(state.copyWith(status: CustomerStatus.loading));
    final result = await getCustomersUseCase(NoParams());
    result.fold(
      (f) => emit(state.copyWith(
          status: CustomerStatus.error, message: f.message)),
      (list) => emit(state.copyWith(
          status: CustomerStatus.loaded, customers: list)),
    );
  }

  bool _nameExists(String name, {String? excludeId}) {
    final n = name.trim().toLowerCase();
    return state.customers.any((c) =>
        c.id != excludeId && c.name.trim().toLowerCase() == n);
  }

  Future<void> _onAdd(
      AddCustomerEvent event, Emitter<CustomerState> emit) async {
    if (_nameExists(event.customer.name)) {
      emit(state.copyWith(
          status: CustomerStatus.error,
          message: const ValidationFailure('Tên khách hàng đã tồn tại').message));
      return;
    }
    emit(state.copyWith(status: CustomerStatus.loading));
    final result = await addCustomerUseCase(event.customer);
    result.fold(
      (f) => emit(state.copyWith(
          status: CustomerStatus.error, message: f.message)),
      (_) {
        emit(state.copyWith(
            status: CustomerStatus.success,
            message: 'Đã thêm khách hàng'));
        add(const LoadCustomersEvent());
      },
    );
  }

  Future<void> _onUpdate(
      UpdateCustomerEvent event, Emitter<CustomerState> emit) async {
    if (_nameExists(event.customer.name, excludeId: event.customer.id)) {
      emit(state.copyWith(
          status: CustomerStatus.error,
          message: const ValidationFailure('Tên khách hàng đã tồn tại').message));
      return;
    }
    emit(state.copyWith(status: CustomerStatus.loading));
    final result = await updateCustomerUseCase(event.customer);
    result.fold(
      (f) => emit(state.copyWith(
          status: CustomerStatus.error, message: f.message)),
      (_) {
        emit(state.copyWith(
            status: CustomerStatus.success,
            message: 'Đã cập nhật khách hàng'));
        add(const LoadCustomersEvent());
      },
    );
  }

  Future<void> _onDelete(
      DeleteCustomerEvent event, Emitter<CustomerState> emit) async {
    emit(state.copyWith(status: CustomerStatus.loading));
    final result = await deleteCustomerUseCase(event.id);
    result.fold(
      (f) => emit(state.copyWith(
          status: CustomerStatus.error, message: f.message)),
      (_) {
        emit(state.copyWith(
            status: CustomerStatus.success, message: 'Đã xóa khách hàng'));
        add(const LoadCustomersEvent());
      },
    );
  }
}
