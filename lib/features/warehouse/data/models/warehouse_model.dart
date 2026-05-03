import 'package:hive/hive.dart';

import '../../domain/entities/warehouse.dart';

part 'warehouse_model.g.dart';

@HiveType(typeId: 2)
class WarehouseModel extends Warehouse {
  @override
  @HiveField(0)
  final String id;

  @override
  @HiveField(1)
  final String name;

  @override
  @HiveField(2)
  final String? location;

  const WarehouseModel({
    required this.id,
    required this.name,
    this.location,
  }) : super(
          id: id,
          name: name,
          location: location,
        );

  factory WarehouseModel.fromEntity(Warehouse w) {
    return WarehouseModel(
      id: w.id,
      name: w.name,
      location: w.location,
    );
  }

  Warehouse toEntity() => this;
}
