part of 'warehouse_bloc.dart';

enum WarehouseStatus { initial, loading, loaded, error, success }

class WarehouseState extends Equatable {
  final WarehouseStatus status;
  final List<Warehouse> warehouses;
  final String? message;

  const WarehouseState({
    this.status = WarehouseStatus.initial,
    this.warehouses = const [],
    this.message,
  });

  WarehouseState copyWith({
    WarehouseStatus? status,
    List<Warehouse>? warehouses,
    String? message,
  }) {
    return WarehouseState(
      status: status ?? this.status,
      warehouses: warehouses ?? this.warehouses,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, warehouses, message];
}
