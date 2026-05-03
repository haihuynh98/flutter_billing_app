import 'package:hive/hive.dart';

import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_status.dart';
import 'invoice_item_model.dart';

part 'invoice_model.g.dart';

@HiveType(typeId: 5)
class InvoiceModel extends HiveObject {
  @HiveField(0)
  final String id;

  /// 0 draft, 1 confirmed, 2 cancelled
  @HiveField(1)
  final int statusIndex;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final DateTime? confirmedAt;

  @HiveField(4)
  final List<InvoiceItemModel> items;

  @HiveField(5)
  final double totalSnapshot;

  InvoiceModel({
    required this.id,
    required this.statusIndex,
    required this.createdAt,
    this.confirmedAt,
    required this.items,
    required this.totalSnapshot,
  });

  InvoiceStatus get _status => InvoiceStatus.values[statusIndex.clamp(0, 2)];

  Invoice toEntity() => Invoice(
        id: id,
        status: _status,
        createdAt: createdAt,
        confirmedAt: confirmedAt,
        items: items.map((e) => e.toEntity()).toList(),
      );

  factory InvoiceModel.fromEntity(Invoice inv) => InvoiceModel(
        id: inv.id,
        statusIndex: inv.status.index,
        createdAt: inv.createdAt,
        confirmedAt: inv.confirmedAt,
        items: inv.items.map(InvoiceItemModel.fromEntity).toList(),
        totalSnapshot: inv.total,
      );
}
