part of 'stock_bloc.dart';

abstract class StockEvent extends Equatable {
  const StockEvent();
  @override
  List<Object?> get props => [];
}

class LoadBatchesForProductEvent extends StockEvent {
  final String productId;
  const LoadBatchesForProductEvent(this.productId);
  @override
  List<Object?> get props => [productId];
}

class LoadBatchesForWarehouseEvent extends StockEvent {
  final String warehouseId;
  const LoadBatchesForWarehouseEvent(this.warehouseId);
  @override
  List<Object?> get props => [warehouseId];
}

class LoadMovementsEvent extends StockEvent {
  final String? productId;
  final String? warehouseId;
  const LoadMovementsEvent({this.productId, this.warehouseId});
  @override
  List<Object?> get props => [productId, warehouseId];
}

class ImportStockEvent extends StockEvent {
  final ImportStockParams params;
  const ImportStockEvent(this.params);
  @override
  List<Object?> get props => [params];
}

class LoadTotalStockMapEvent extends StockEvent {
  final List<String> productIds;
  const LoadTotalStockMapEvent(this.productIds);
  @override
  List<Object?> get props => [productIds];
}

class LoadExpiringProductIdsEvent extends StockEvent {
  const LoadExpiringProductIdsEvent();
}

class LoadProductStockOverviewEvent extends StockEvent {
  final String productId;
  const LoadProductStockOverviewEvent(this.productId);
  @override
  List<Object?> get props => [productId];
}
