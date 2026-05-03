import 'package:equatable/equatable.dart';

class Warehouse extends Equatable {
  final String id;
  final String name;
  final String? location;

  const Warehouse({
    required this.id,
    required this.name,
    this.location,
  });

  @override
  List<Object?> get props => [id, name, location];
}
