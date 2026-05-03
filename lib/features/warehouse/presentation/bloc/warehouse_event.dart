part of 'warehouse_bloc.dart';

abstract class WarehouseEvent extends Equatable {
  const WarehouseEvent();
  @override
  List<Object?> get props => [];
}

class LoadWarehousesEvent extends WarehouseEvent {
  const LoadWarehousesEvent();
}


class AddWarehouseEvent extends WarehouseEvent {
  final Warehouse warehouse;
  const AddWarehouseEvent(this.warehouse);
  @override
  List<Object?> get props => [warehouse];
}

class UpdateWarehouseEvent extends WarehouseEvent {
  final Warehouse warehouse;
  const UpdateWarehouseEvent(this.warehouse);
  @override
  List<Object?> get props => [warehouse];
}

class DeleteWarehouseEvent extends WarehouseEvent {
  final String id;
  const DeleteWarehouseEvent(this.id);
  @override
  List<Object?> get props => [id];
}
