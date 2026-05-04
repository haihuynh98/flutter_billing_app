import 'dart:async';

import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/stock_constants.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../stock/domain/usecases/stock_usecases.dart';
import '../../../warehouse/domain/entities/warehouse.dart';
import '../../../warehouse/presentation/bloc/warehouse_bloc.dart';
import '../bloc/stock_bloc.dart';

/// Owns [TextEditingController]s so they are disposed after the route unmounts,
/// avoiding framework assertions during dialog teardown.
class _QuickCreateProductDialog extends StatefulWidget {
  const _QuickCreateProductDialog({required this.barcode});

  final String barcode;

  @override
  State<_QuickCreateProductDialog> createState() =>
      _QuickCreateProductDialogState();
}

class _QuickCreateProductDialogState extends State<_QuickCreateProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(
      context,
      Product(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        barcode: widget.barcode,
        price: double.parse(_priceController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tạo sản phẩm nhanh'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: widget.barcode,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Mã vạch'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                validator: AppValidators.required('Vui lòng nhập tên'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Giá bán',
                ),
                validator: AppValidators.price,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

class ImportStockPage extends StatefulWidget {
  final String? presetProductId;
  final Product? presetProduct;
  final String? presetWarehouseId;
  final Warehouse? presetWarehouse;

  const ImportStockPage({
    super.key,
    this.presetProductId,
    this.presetProduct,
    this.presetWarehouseId,
    this.presetWarehouse,
  });

  @override
  State<ImportStockPage> createState() => _ImportStockPageState();
}

class _ImportStockPageState extends State<ImportStockPage> {
  final _formKey = GlobalKey<FormState>();
  String? _productId;
  String? _warehouseId;
  DateTime _importDate = dateOnly(DateTime.now());
  int _quantity = 1;
  double _importPrice = 0;
  String _supplier = '';
  DateTime? _expiryDate;

  @override
  void initState() {
    super.initState();
    _productId = widget.presetProductId ?? widget.presetProduct?.id;
    _warehouseId = widget.presetWarehouseId ?? widget.presetWarehouse?.id;
  }

  Future<void> _pickDate(bool isImport) async {
    final initial = isImport ? _importDate : (_expiryDate ?? _importDate);
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d == null) return;
    setState(() {
      if (isImport) {
        _importDate = dateOnly(d);
      } else {
        _expiryDate = dateOnly(d);
      }
    });
  }

  Future<void> _scanAndSelectProduct() async {
    final barcode = await context.push<String>('/scanner');
    if (!mounted || barcode == null || barcode.trim().isEmpty) return;
    final normalized = barcode.trim();

    Product? matched;
    for (final p in context.read<ProductBloc>().state.products) {
      if (p.barcode.trim() == normalized) {
        matched = p;
        break;
      }
    }

    if (matched != null) {
      setState(() => _productId = matched!.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã chọn sản phẩm: ${matched.name}'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    final shouldCreate = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mã sản phẩm chưa tồn tại'),
        content: Text(
            'Mã "$normalized" chưa có trong hệ thống. Tạo sản phẩm nhanh để nhập lô?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tạo nhanh'),
          ),
        ],
      ),
    );

    if (shouldCreate != true || !mounted) return;
    final quickProduct = await _showQuickCreateProductDialog(normalized);
    if (quickProduct == null || !mounted) return;
    await _createProductAndSelect(quickProduct);
  }

  Future<Product?> _showQuickCreateProductDialog(String barcode) {
    return showDialog<Product>(
      context: context,
      builder: (ctx) => _QuickCreateProductDialog(barcode: barcode),
    );
  }

  Future<void> _createProductAndSelect(Product product) async {
    final productBloc = context.read<ProductBloc>();
    productBloc.add(AddProduct(product));

    try {
      final next = await productBloc.stream.firstWhere((state) {
        final hasById = state.products.any((p) => p.id == product.id);
        final hasByBarcode =
            state.products.any((p) => p.barcode == product.barcode);
        return hasById || hasByBarcode || state.status == ProductStatus.error;
      }).timeout(const Duration(seconds: 8));

      if (!mounted) return;
      void finish() {
        if (!mounted) return;
        if (next.status == ProductStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.message ?? 'Không thể tạo sản phẩm'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        Product? created;
        for (final p in next.products) {
          if (p.id == product.id || p.barcode == product.barcode) {
            created = p;
            break;
          }
        }
        if (created == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Đã tạo sản phẩm nhưng chưa tải lại danh sách')),
          );
          return;
        }

        setState(() => _productId = created!.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã tạo và chọn: ${created.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Avoid setState / InheritedWidget updates in the same frame as Bloc emits.
      WidgetsBinding.instance.addPostFrameCallback((_) => finish());
    } on TimeoutException {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo sản phẩm quá thời gian, vui lòng thử lại'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    if (_productId == null || _warehouseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Chọn sản phẩm và kho'),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (_expiryDate != null && _expiryDate!.isBefore(_importDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('HSD phải sau hoặc cùng ngày nhập'),
            backgroundColor: Colors.red),
      );
      return;
    }

    context.read<StockBloc>().add(ImportStockEvent(ImportStockParams(
          productId: _productId!,
          warehouseId: _warehouseId!,
          date: _importDate,
          quantity: _quantity,
          importPrice: _importPrice,
          supplierName: _supplier.trim().isEmpty ? null : _supplier.trim(),
          expiryDate: _expiryDate,
        )));
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhập kho',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.chevron_left,
              size: 28, color: Theme.of(context).primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<StockBloc, StockState>(
        listener: (context, state) {
          if (state.status == StockStatus.error && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message!), backgroundColor: Colors.red),
            );
          } else if (state.status == StockStatus.success &&
              state.message != null) {
            if (_expiryDate != null) {
              final days =
                  _expiryDate!.difference(dateOnly(DateTime.now())).inDays;
              if (days >= 0 && days <= kExpiryWarningDays) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lưu ý: HSD còn $days ngày'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message!),
                  backgroundColor: Colors.green),
            );
            context.read<ProductBloc>().add(LoadProducts());
            context.pop();
          }
        },
        builder: (context, state) {
          final products = context.watch<ProductBloc>().state.products;
          final warehouses = context.watch<WarehouseBloc>().state.warehouses;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const InputLabel(text: 'Sản phẩm'),
                  if (widget.presetProduct != null)
                    Text(widget.presetProduct!.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16))
                  else
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            key: ValueKey('product_${_productId ?? 'none'}'),
                            initialValue: _productId,
                            items: products
                                .map((p) => DropdownMenuItem(
                                      value: p.id,
                                      child: Text(p.name),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _productId = v),
                            validator: (v) => v == null ? 'Chọn sản phẩm' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Quét mã sản phẩm',
                          onPressed: _scanAndSelectProduct,
                          icon: const Icon(Icons.qr_code_scanner),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  const InputLabel(text: 'Kho'),
                  if (widget.presetWarehouse != null)
                    Text(widget.presetWarehouse!.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16))
                  else
                    DropdownButtonFormField<String>(
                      key: ValueKey('warehouse_${_warehouseId ?? 'none'}'),
                      initialValue: _warehouseId,
                      items: warehouses
                          .map((w) => DropdownMenuItem(
                                value: w.id,
                                child: Text(w.name),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _warehouseId = v),
                      validator: (v) => v == null ? 'Chọn kho' : null,
                    ),
                  const SizedBox(height: 20),
                  const InputLabel(text: 'Ngày nhập'),
                  OutlinedButton(
                    onPressed: () => _pickDate(true),
                    child: Text(df.format(_importDate)),
                  ),
                  const SizedBox(height: 20),
                  const InputLabel(text: 'Số lượng'),
                  TextFormField(
                    initialValue: '$_quantity',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '> 0'),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Nhập số nguyên > 0';
                      return null;
                    },
                    onSaved: (v) => _quantity = int.parse(v!),
                  ),
                  const SizedBox(height: 20),
                  const InputLabel(text: 'Giá nhập / đơn vị'),
                  TextFormField(
                    initialValue: _importPrice.toStringAsFixed(2),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: '0.00',
                    ),
                    validator: AppValidators.price,
                    onSaved: (v) => _importPrice = double.parse(v!),
                  ),
                  const SizedBox(height: 20),
                  const InputLabel(text: 'Nhà cung cấp (tuỳ chọn)'),
                  TextFormField(
                    initialValue: _supplier,
                    decoration: const InputDecoration(hintText: 'Tên NCC'),
                    onChanged: (v) => _supplier = v,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(child: InputLabel(text: 'Hạn sử dụng')),
                      if (_expiryDate != null)
                        TextButton(
                          onPressed: () => setState(() => _expiryDate = null),
                          child: const Text('Xóa HSD'),
                        ),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: () => _pickDate(false),
                    child: Text(_expiryDate == null
                        ? 'Chọn HSD (tuỳ chọn)'
                        : df.format(_expiryDate!)),
                  ),
                  const SizedBox(height: 32),
                  if (state.status == StockStatus.loading)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<StockBloc, StockState>(
        builder: (context, state) {
          return PrimaryButton(
            onPressed: state.status == StockStatus.loading ? null : _submit,
            icon: Icons.inventory_2,
            label: 'Nhập kho',
            isLoading: state.status == StockStatus.loading,
          );
        },
      ),
    );
  }
}
