import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../stock/domain/entities/stock_batch.dart';
import '../../../warehouse/domain/entities/warehouse.dart';
import '../../../warehouse/presentation/bloc/warehouse_bloc.dart';
import '../bloc/stock_bloc.dart';

class ProductStockPage extends StatefulWidget {
  final String productId;
  const ProductStockPage({super.key, required this.productId});

  @override
  State<ProductStockPage> createState() => _ProductStockPageState();
}

class _ProductStockPageState extends State<ProductStockPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<StockBloc>()
        .add(LoadProductStockOverviewEvent(widget.productId));
  }

  Product? _findProduct(List<Product> products) {
    try {
      return products.firstWhere((p) => p.id == widget.productId);
    } catch (_) {
      return null;
    }
  }

  String _warehouseName(String id, List<Warehouse> warehouses) {
    try {
      return warehouses.firstWhere((w) => w.id == id).name;
    } catch (_) {
      return id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    final products = context.watch<ProductBloc>().state.products;
    final warehouses = context.watch<WarehouseBloc>().state.warehouses;
    final product = _findProduct(products);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(product?.name ?? 'Tồn kho',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.chevron_left,
                size: 28, color: Theme.of(context).primaryColor),
            onPressed: () => context.pop(),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Lô hàng'),
              Tab(text: 'Lịch sử'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BlocBuilder<StockBloc, StockState>(
              builder: (context, state) {
                final batches = state.batches;
                if (batches.isEmpty) {
                  return const Center(child: Text('Chưa có lô hàng.'));
                }
                final byWarehouse = <String, List<StockBatch>>{};
                for (final b in batches) {
                  byWarehouse.putIfAbsent(b.warehouseId, () => []).add(b);
                }
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final e in byWarehouse.entries) ...[
                      Text(
                        _warehouseName(e.key, warehouses),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      ...e.value.map((b) => _BatchCard(batch: b, df: df)),
                      const SizedBox(height: 16),
                    ],
                  ],
                );
              },
            ),
            BlocBuilder<StockBloc, StockState>(
              builder: (context, state) {
                final moves = state.movements;
                if (moves.isEmpty) {
                  return const Center(child: Text('Chưa có giao dịch.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: moves.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final m = moves[i];
                    return ListTile(
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      title: Text(
                          '${m.type.name} · ${m.quantityDelta > 0 ? '+' : ''}${m.quantityDelta}'),
                      subtitle: Text(
                        '${df.format(m.timestamp)} · ${m.unitImportPrice != null ? 'Giá nhập ₹${m.unitImportPrice!.toStringAsFixed(2)}' : ''} ${m.supplierName != null ? '· NCC ${m.supplierName}' : ''}',
                        maxLines: 2,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push(
            '/products/${widget.productId}/import',
            extra: product,
          ),
          backgroundColor: AppTheme.primaryColor,
          icon: const Icon(Icons.add),
          label: const Text('Nhập kho'),
        ),
      ),
    );
  }
}

class _BatchCard extends StatelessWidget {
  final StockBatch batch;
  final DateFormat df;

  const _BatchCard({required this.batch, required this.df});

  @override
  Widget build(BuildContext context) {
    Color? bg;
    Color fg = Colors.black87;
    String? hsdLine;
    if (batch.expiryDate != null) {
      if (batch.isExpired) {
        bg = Colors.red;
        fg = Colors.white;
        hsdLine = 'ĐÃ HẾT HẠN · ${df.format(batch.expiryDate!)}';
      } else if (batch.isExpiringSoon) {
        bg = Colors.red.shade100;
        fg = Colors.red.shade900;
        hsdLine =
            'HSD: ${df.format(batch.expiryDate!)} (còn ${batch.daysUntilExpiry} ngày)';
      } else {
        hsdLine =
            'HSD: ${df.format(batch.expiryDate!)} (còn ${batch.daysUntilExpiry} ngày)';
      }
    }

    return Card(
      color: bg,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              batch.supplierName == null || batch.supplierName!.isEmpty
                  ? 'Không rõ NCC'
                  : 'NCC: ${batch.supplierName}',
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13, color: fg),
            ),
            const SizedBox(height: 4),
            Text(
              'Nhập ${df.format(batch.importDate)} · Giá ₹${batch.importPrice.toStringAsFixed(2)} · Còn ${batch.quantity}',
              style: TextStyle(fontSize: 13, color: fg),
            ),
            if (hsdLine != null) ...[
              const SizedBox(height: 6),
              Text(hsdLine,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: fg)),
            ],
          ],
        ),
      ),
    );
  }
}
