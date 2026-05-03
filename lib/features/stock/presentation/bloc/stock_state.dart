part of 'stock_bloc.dart';

enum StockStatus { initial, loading, loaded, error, success }

class StockState extends Equatable {
  final StockStatus status;
  final List<StockBatch> batches;
  final List<StockMovement> movements;
  final Map<String, int> totalStockMap;
  final Set<String> expiringProductIds;
  final String? message;

  const StockState({
    this.status = StockStatus.initial,
    this.batches = const [],
    this.movements = const [],
    this.totalStockMap = const {},
    this.expiringProductIds = const <String>{},
    this.message,
  });

  StockState copyWith({
    StockStatus? status,
    List<StockBatch>? batches,
    List<StockMovement>? movements,
    Map<String, int>? totalStockMap,
    Set<String>? expiringProductIds,
    String? message,
  }) {
    return StockState(
      status: status ?? this.status,
      batches: batches ?? this.batches,
      movements: movements ?? this.movements,
      totalStockMap: totalStockMap ?? this.totalStockMap,
      expiringProductIds: expiringProductIds ?? this.expiringProductIds,
      message: message,
    );
  }

  @override
  List<Object?> get props =>
      [status, batches, movements, totalStockMap, expiringProductIds, message];
}
