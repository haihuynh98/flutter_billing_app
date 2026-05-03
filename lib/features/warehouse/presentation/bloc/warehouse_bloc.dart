import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart' show ValidationFailure;
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/warehouse.dart';
import '../../domain/usecases/warehouse_usecases.dart';

part 'warehouse_event.dart';
part 'warehouse_state.dart';

class WarehouseBloc extends Bloc<WarehouseEvent, WarehouseState> {
  final GetWarehousesUseCase getWarehousesUseCase;
  final AddWarehouseUseCase addWarehouseUseCase;
  final UpdateWarehouseUseCase updateWarehouseUseCase;
  final DeleteWarehouseUseCase deleteWarehouseUseCase;
  final CountActiveBatchesInWarehouseUseCase countActiveBatchesInWarehouseUseCase;

  WarehouseBloc({
    required this.getWarehousesUseCase,
    required this.addWarehouseUseCase,
    required this.updateWarehouseUseCase,
    required this.deleteWarehouseUseCase,
    required this.countActiveBatchesInWarehouseUseCase,
  }) : super(const WarehouseState()) {
    on<LoadWarehousesEvent>(_onLoad);
    on<AddWarehouseEvent>(_onAdd);
    on<UpdateWarehouseEvent>(_onUpdate);
    on<DeleteWarehouseEvent>(_onDelete);
  }

  Future<void> _onLoad(
      LoadWarehousesEvent event, Emitter<WarehouseState> emit) async {
    emit(state.copyWith(status: WarehouseStatus.loading));
    final result = await getWarehousesUseCase(NoParams());
    result.fold(
      (f) => emit(state.copyWith(
          status: WarehouseStatus.error, message: f.message)),
      (list) => emit(state.copyWith(
          status: WarehouseStatus.loaded, warehouses: list)),
    );
  }

  bool _nameExists(String name, {String? excludeId}) {
    final n = name.trim().toLowerCase();
    return state.warehouses.any((w) =>
        w.id != excludeId && w.name.trim().toLowerCase() == n);
  }

  Future<void> _onAdd(
      AddWarehouseEvent event, Emitter<WarehouseState> emit) async {
    if (_nameExists(event.warehouse.name)) {
      emit(state.copyWith(
          status: WarehouseStatus.error,
          message: const ValidationFailure('Tên kho đã tồn tại').message));
      return;
    }
    emit(state.copyWith(status: WarehouseStatus.loading));
    final result = await addWarehouseUseCase(event.warehouse);
    result.fold(
      (f) => emit(state.copyWith(
          status: WarehouseStatus.error, message: f.message)),
      (_) {
        emit(state.copyWith(
            status: WarehouseStatus.success,
            message: 'Đã thêm kho'));
        add(const LoadWarehousesEvent());
      },
    );
  }

  Future<void> _onUpdate(
      UpdateWarehouseEvent event, Emitter<WarehouseState> emit) async {
    if (_nameExists(event.warehouse.name, excludeId: event.warehouse.id)) {
      emit(state.copyWith(
          status: WarehouseStatus.error,
          message: const ValidationFailure('Tên kho đã tồn tại').message));
      return;
    }
    emit(state.copyWith(status: WarehouseStatus.loading));
    final result = await updateWarehouseUseCase(event.warehouse);
    result.fold(
      (f) => emit(state.copyWith(
          status: WarehouseStatus.error, message: f.message)),
      (_) {
        emit(state.copyWith(
            status: WarehouseStatus.success,
            message: 'Đã cập nhật kho'));
        add(const LoadWarehousesEvent());
      },
    );
  }

  Future<void> _onDelete(
      DeleteWarehouseEvent event, Emitter<WarehouseState> emit) async {
    final countResult =
        await countActiveBatchesInWarehouseUseCase(event.id);
    final blocked = countResult.fold((_) => -1, (c) => c);
    if (blocked > 0) {
      emit(state.copyWith(
          status: WarehouseStatus.error,
          message:
              'Không thể xóa khi còn $blocked lô hàng có tồn trong kho này'));
      return;
    }
    emit(state.copyWith(status: WarehouseStatus.loading));
    final result = await deleteWarehouseUseCase(event.id);
    result.fold(
      (f) => emit(state.copyWith(
          status: WarehouseStatus.error, message: f.message)),
      (_) {
        emit(state.copyWith(
            status: WarehouseStatus.success, message: 'Đã xóa kho'));
        add(const LoadWarehousesEvent());
      },
    );
  }
}
