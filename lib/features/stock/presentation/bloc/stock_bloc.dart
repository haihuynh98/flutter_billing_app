import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/stock_batch.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/usecases/stock_usecases.dart';

part 'stock_event.dart';
part 'stock_state.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  final ListBatchesByProductUseCase listBatchesByProductUseCase;
  final ListBatchesByWarehouseUseCase listBatchesByWarehouseUseCase;
  final ListMovementsUseCase listMovementsUseCase;
  final ImportStockUseCase importStockUseCase;
  final GetTotalStockMapUseCase getTotalStockMapUseCase;

  final ListExpiringBatchesUseCase listExpiringBatchesUseCase;

  StockBloc({
    required this.listBatchesByProductUseCase,
    required this.listBatchesByWarehouseUseCase,
    required this.listMovementsUseCase,
    required this.importStockUseCase,
    required this.getTotalStockMapUseCase,
    required this.listExpiringBatchesUseCase,
  }) : super(const StockState()) {
    on<LoadBatchesForProductEvent>(_onLoadProduct);
    on<LoadBatchesForWarehouseEvent>(_onLoadWarehouse);
    on<LoadMovementsEvent>(_onLoadMovements);
    on<ImportStockEvent>(_onImport);
    on<LoadTotalStockMapEvent>(_onLoadTotals);
    on<LoadExpiringProductIdsEvent>(_onLoadExpiringIds);
    on<LoadProductStockOverviewEvent>(_onLoadProductOverview);
  }

  Future<void> _onLoadProduct(
      LoadBatchesForProductEvent event, Emitter<StockState> emit) async {
    emit(state.copyWith(status: StockStatus.loading));
    final r = await listBatchesByProductUseCase(event.productId);
    r.fold(
      (f) => emit(state.copyWith(status: StockStatus.error, message: f.message)),
      (b) => emit(state.copyWith(
          status: StockStatus.loaded, batches: b, message: null)),
    );
  }

  Future<void> _onLoadWarehouse(
      LoadBatchesForWarehouseEvent event, Emitter<StockState> emit) async {
    emit(state.copyWith(status: StockStatus.loading));
    final r = await listBatchesByWarehouseUseCase(event.warehouseId);
    r.fold(
      (f) => emit(state.copyWith(status: StockStatus.error, message: f.message)),
      (b) => emit(state.copyWith(
          status: StockStatus.loaded, batches: b, message: null)),
    );
  }

  Future<void> _onLoadMovements(
      LoadMovementsEvent event, Emitter<StockState> emit) async {
    emit(state.copyWith(status: StockStatus.loading));
    final r = await listMovementsUseCase(ListMovementsParams(
      productId: event.productId,
      warehouseId: event.warehouseId,
    ));
    r.fold(
      (f) => emit(state.copyWith(status: StockStatus.error, message: f.message)),
      (m) => emit(state.copyWith(
          status: StockStatus.loaded, movements: m, message: null)),
    );
  }

  Future<void> _onImport(
      ImportStockEvent event, Emitter<StockState> emit) async {
    emit(state.copyWith(status: StockStatus.loading));
    final r = await importStockUseCase(event.params);
    r.fold(
      (f) => emit(state.copyWith(status: StockStatus.error, message: f.message)),
      (res) {
        emit(state.copyWith(
            status: StockStatus.success,
            message: res.merged
                ? 'Đã cộng dồn vào lô cùng ngày / giá / NCC / HSD'
                : 'Đã tạo lô mới'));
        add(LoadBatchesForProductEvent(event.params.productId));
      },
    );
  }

  Future<void> _onLoadTotals(
      LoadTotalStockMapEvent event, Emitter<StockState> emit) async {
    if (event.productIds.isEmpty) return;
    final r = await getTotalStockMapUseCase(event.productIds);
    r.fold(
      (f) => emit(state.copyWith(status: StockStatus.error, message: f.message)),
      (map) {
        final merged = Map<String, int>.from(state.totalStockMap)..addAll(map);
        emit(state.copyWith(
            status: StockStatus.loaded,
            totalStockMap: merged,
            message: null));
      },
    );
  }

  Future<void> _onLoadExpiringIds(
      LoadExpiringProductIdsEvent event, Emitter<StockState> emit) async {
    final r = await listExpiringBatchesUseCase(30);
    r.fold(
      (_) {},
      (batches) {
        final ids = batches.map((b) => b.productId).toSet();
        emit(state.copyWith(expiringProductIds: ids));
      },
    );
  }

  Future<void> _onLoadProductOverview(
      LoadProductStockOverviewEvent event, Emitter<StockState> emit) async {
    emit(state.copyWith(status: StockStatus.loading));
    final batchesR = await listBatchesByProductUseCase(event.productId);
    await batchesR.fold<Future<void>>(
      (f) async {
        emit(state.copyWith(status: StockStatus.error, message: f.message));
      },
      (batches) async {
        final movementsR = await listMovementsUseCase(ListMovementsParams(
          productId: event.productId,
        ));
        await movementsR.fold<Future<void>>(
          (f2) async {
            emit(state.copyWith(
                status: StockStatus.error, message: f2.message));
          },
          (movements) async {
            emit(state.copyWith(
              status: StockStatus.loaded,
              batches: batches,
              movements: movements,
              message: null,
            ));
          },
        );
      },
    );
  }
}
