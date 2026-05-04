import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money_format.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../stock/domain/entities/stock_batch.dart';
import '../../../stock/presentation/bloc/stock_bloc.dart';
import '../../domain/entities/warehouse.dart';

class WarehouseDetailPage extends StatefulWidget {
  final Warehouse warehouse;
  const WarehouseDetailPage({super.key, required this.warehouse});

  @override
  State<WarehouseDetailPage> createState() => _WarehouseDetailPageState();
}

class _WarehouseDetailPageState extends State<WarehouseDetailPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<StockBloc>()
        .add(LoadBatchesForWarehouseEvent(widget.warehouse.id));
  }

  String _productName(String productId, List<Product> products) {
    try {
      return products.firstWhere((p) => p.id == productId).name;
    } catch (_) {
      return productId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.warehouse.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.chevron_left,
              size: 28, color: Theme.of(context).primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<StockBloc, StockState>(
        builder: (context, stockState) {
          final batches = stockState.batches
              .where((b) => b.warehouseId == widget.warehouse.id)
              .toList();
          final products = context.watch<ProductBloc>().state.products;

          if (batches.isEmpty) {
            return const Center(child: Text('Chưa có lô hàng trong kho này.'));
          }

          final byProduct = <String, List<StockBatch>>{};
          for (final b in batches) {
            byProduct.putIfAbsent(b.productId, () => []).add(b);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final entry in byProduct.entries) ...[
                Text(
                  _productName(entry.key, products),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...entry.value.map((b) => Card(
                      child: ListTile(
                        title: Text(
                            'Nhập ${df.format(b.importDate)} · Giá ${formatMoney(b.importPrice)} · Còn ${b.quantity}'),
                        subtitle: Text(
                          b.supplierName == null || b.supplierName!.isEmpty
                              ? 'NCC: —'
                              : 'NCC: ${b.supplierName}',
                        ),
                        trailing: b.expiryDate != null
                            ? Text('HSD ${df.format(b.expiryDate!)}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: b.isExpired
                                        ? Colors.red
                                        : (b.isExpiringSoon
                                            ? Colors.redAccent
                                            : Colors.grey)))
                            : null,
                      ),
                    )),
                const SizedBox(height: 16),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          '/warehouses/${widget.warehouse.id}/import',
          extra: widget.warehouse,
        ),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Nhập kho'),
      ),
    );
  }
}
