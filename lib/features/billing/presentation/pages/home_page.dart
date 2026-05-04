import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';

import '../../../../core/utils/money_format.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../invoice/domain/entities/invoice_item.dart';
import '../../../product/domain/entities/product.dart';
import '../../../stock/domain/entities/stock_batch.dart';
import '../../../invoice/domain/entities/invoice_status.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../warehouse/domain/entities/warehouse.dart';
import '../../../warehouse/presentation/bloc/warehouse_bloc.dart';
import '../bloc/billing_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    returnImage: false,
  );

  bool _isCameraOn = false;
  bool _isFlashOn = false;
  final Map<String, DateTime> _lastScanTimes = {};
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  static const double _scannerFractionWhenOn = 0.4;
  static const double _scannerFractionWhenOff = 0.18;

  double _scannerSectionHeight(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    return _isCameraOn ? h * _scannerFractionWhenOn : h * _scannerFractionWhenOff;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isCameraOn) return;
      _scannerController.stop();
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<Product> _productsMatchingQuery(String query, List<Product> products) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return products
        .where((p) {
          final name = p.name.toLowerCase();
          final code = p.barcode.toLowerCase();
          return name.contains(q) || code.contains(q);
        })
        .toList();
  }

  void _onDetect(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    final now = DateTime.now();

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final rawValue = barcode.rawValue!;

        if (_lastScanTimes.containsKey(rawValue)) {
          final lastScan = _lastScanTimes[rawValue]!;
          if (now.difference(lastScan).inSeconds < 2) {
            continue;
          }
        }

        _lastScanTimes[rawValue] = now;

        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          Vibration.vibrate();
        }

        if (mounted) {
          context.read<BillingBloc>().add(ScanBarcodeEvent(rawValue));
        }
        break;
      }
    }
  }

  String _warehouseName(String id, List<Warehouse> warehouses) {
    try {
      return warehouses.firstWhere((w) => w.id == id).name;
    } catch (_) {
      return id;
    }
  }

  Future<void> _maybeShowSourceSheet(BillingState state) async {
    if (!state.needsSourcePick) return;
    final product = state.pendingProduct!;
    final df = DateFormat('dd/MM/yyyy');
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final warehouses = context.watch<WarehouseBloc>().state.warehouses;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chọn lô xuất · ${product.name}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: state.pendingSources.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final b = state.pendingSources[i];
                      final wName = _warehouseName(b.warehouseId, warehouses);
                      final hsd = b.expiryDate != null
                          ? ' · HSD ${df.format(b.expiryDate!)}'
                          : '';
                      final ncc = (b.supplierName != null &&
                              b.supplierName!.isNotEmpty)
                          ? ' · NCC ${b.supplierName}'
                          : '';
                      return ListTile(
                        title: Text(
                            '$wName · Nhập ${df.format(b.importDate)}$ncc'),
                        subtitle: Text(
                            'Còn ${b.quantity}$hsd',
                            style: TextStyle(
                                color: b.isExpired || b.isExpiringSoon
                                    ? Colors.red
                                    : null)),
                        onTap: () async {
                          if (b.isExpired) {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (dCtx) => AlertDialog(
                                title: const Text('Lô đã hết hạn'),
                                content: const Text(
                                    'Lô này đã hết hạn. Vẫn dùng để bán?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dCtx, false),
                                    child: const Text('Hủy'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dCtx, true),
                                    child: const Text('Tiếp tục'),
                                  ),
                                ],
                              ),
                            );
                            if (ok != true) return;
                          }
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          if (!mounted) return;
                          context.read<BillingBloc>().add(
                                PickSourceEvent(product: product, batch: b),
                              );
                        },
                      );
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context
                        .read<BillingBloc>()
                        .add(const ClearPendingPickEvent());
                  },
                  child: const Text('Hủy'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<BillingBloc, BillingState>(
            listenWhen: (previous, current) =>
                previous.error != current.error && current.error != null,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          BlocListener<BillingBloc, BillingState>(
            listenWhen: (p, c) {
              String? key(Product? prod, List<StockBatch> batches) {
                if (prod == null || batches.isEmpty) return null;
                return '${prod.id}:${batches.map((b) => b.id).join(',')}';
              }

              return key(c.pendingProduct, c.pendingSources) !=
                  key(p.pendingProduct, p.pendingSources);
            },
            listener: (context, state) {
              if (!state.needsSourcePick) return;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) _maybeShowSourceSheet(state);
              });
            },
          ),
        ],
        child: Builder(
          builder: (context) {
            final scannerH = _scannerSectionHeight(context);
            return Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: scannerH,
                  child: _buildScannerSection(),
                ),
                Positioned(
                  top: scannerH - 24,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBottomPanel(),
                ),
              ],
            );
          },
        ),
      ),
      bottomSheet:
          BlocBuilder<BillingBloc, BillingState>(builder: (context, state) {
        return PrimaryButton(
          onPressed: state.cartItems.isEmpty
              ? null
              : () async {
                  _scannerController.stop();
                  await context.push('/checkout');
                  if (_isCameraOn && mounted) _scannerController.start();
                },
          icon: Icons.payment,
          label: 'Xem đơn hàng',
        );
      }),
    );
  }

  Widget _buildScannerSection() {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          if (!_isCameraOn) _buildCameraOffState(),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 8,
            child: _isCameraOn ? _buildScannerOverlayColumn() : _buildScannerOverlayRow(),
          ),
          if (_isCameraOn)
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    _buildCorner(Alignment.topLeft),
                    _buildCorner(Alignment.topRight),
                    _buildCorner(Alignment.bottomLeft),
                    _buildCorner(Alignment.bottomRight),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraOffState() {
    return Container(
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.fromLTRB(
          12, 8, 120, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFF334155),
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.videocam_off, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Camera đã tắt',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Chạm biểu tượng camera góc phải để bật — hoặc thêm hàng bằng ô tìm kiếm bên dưới.',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlayColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildOverlayButton(
          icon: Icons.receipt_long,
          onPressed: () async {
            _scannerController.stop();
            await context.push('/invoices');
            if (_isCameraOn && mounted) _scannerController.start();
          },
        ),
        const SizedBox(height: 16),
        _buildOverlayButton(
          icon: Icons.settings,
          onPressed: () async {
            _scannerController.stop();
            await context.push('/settings');
            if (_isCameraOn && mounted) _scannerController.start();
          },
        ),
        const SizedBox(height: 16),
        _buildOverlayButton(
          icon: _isFlashOn ? Icons.flashlight_off : Icons.flashlight_on,
          onPressed: () {
            setState(() => _isFlashOn = !_isFlashOn);
            _scannerController.toggleTorch();
          },
        ),
        const SizedBox(height: 16),
        _buildOverlayButton(
          icon: Icons.videocam_off,
          onPressed: () {
            setState(() => _isCameraOn = false);
            _scannerController.stop();
          },
        ),
      ],
    );
  }

  Widget _buildScannerOverlayRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildOverlayButton(
          icon: Icons.receipt_long,
          stackVertically: false,
          onPressed: () async {
            _scannerController.stop();
            await context.push('/invoices');
            if (_isCameraOn && mounted) _scannerController.start();
          },
        ),
        const SizedBox(width: 8),
        _buildOverlayButton(
          icon: Icons.settings,
          stackVertically: false,
          onPressed: () async {
            _scannerController.stop();
            await context.push('/settings');
            if (_isCameraOn && mounted) _scannerController.start();
          },
        ),
        const SizedBox(width: 8),
        _buildOverlayButton(
          icon: Icons.videocam,
          stackVertically: false,
          onPressed: () {
            setState(() => _isCameraOn = true);
            _scannerController.start();
          },
        ),
      ],
    );
  }

  Widget _buildOverlayButton(
      {required IconData icon,
      required VoidCallback onPressed,
      Color? color,
      bool stackVertically = true}) {
    return Container(
      width: 44,
      height: 44,
      margin: stackVertically
          ? const EdgeInsets.only(bottom: 12)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: color ?? Colors.black45,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border(
            top: (alignment == Alignment.topLeft ||
                    alignment == Alignment.topRight)
                ? const BorderSide(color: Colors.greenAccent, width: 4)
                : BorderSide.none,
            bottom: (alignment == Alignment.bottomLeft ||
                    alignment == Alignment.bottomRight)
                ? const BorderSide(color: Colors.greenAccent, width: 4)
                : BorderSide.none,
            left: (alignment == Alignment.topLeft ||
                    alignment == Alignment.bottomLeft)
                ? const BorderSide(color: Colors.greenAccent, width: 4)
                : BorderSide.none,
            right: (alignment == Alignment.topRight ||
                    alignment == Alignment.bottomRight)
                ? const BorderSide(color: Colors.greenAccent, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 15, offset: Offset(0, -5))
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BlocBuilder<ProductBloc, ProductState>(
              buildWhen: (prev, next) => prev.products != next.products,
              builder: (context, productState) {
                return RawAutocomplete<Product>(
                  textEditingController: _searchController,
                  focusNode: _searchFocusNode,
                  displayStringForOption: (Product p) => p.name,
                  optionsBuilder: (TextEditingValue value) {
                    if (productState.products.isEmpty) {
                      return const Iterable<Product>.empty();
                    }
                    return _productsMatchingQuery(value.text, productState.products)
                        .take(40);
                  },
                  onSelected: (Product selection) {
                    _searchController.clear();
                    _searchFocusNode.unfocus();
                    if (!context.mounted) return;
                    context
                        .read<BillingBloc>()
                        .add(SelectProductForCartEvent(selection));
                  },
                  fieldViewBuilder: (
                    BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: productState.products.isEmpty
                            ? 'Chưa có sản phẩm trong danh mục'
                            : 'Gõ tên hoặc mã — chọn trong danh sách',
                        prefixIcon: const Icon(Icons.search, size: 22),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => onFieldSubmitted(),
                    );
                  },
                  optionsViewBuilder: (
                    BuildContext context,
                    AutocompleteOnSelected<Product> onSelected,
                    Iterable<Product> options,
                  ) {
                    final optionList = options.toList();
                    if (optionList.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final maxW = MediaQuery.sizeOf(context).width - 32;
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior: Clip.antiAlias,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 280,
                            maxWidth: maxW,
                          ),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            shrinkWrap: true,
                            itemCount: optionList.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (BuildContext context, int index) {
                              final p = optionList[index];
                              return ListTile(
                                dense: true,
                                title: Text(
                                  p.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  'Mã: ${p.barcode} · ${formatMoney(p.price)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                onTap: () => onSelected(p),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          BlocBuilder<BillingBloc, BillingState>(
            builder: (context, state) {
              final totalItems =
                  state.cartItems.fold<int>(0, (sum, i) => sum + i.quantity);
              final inv = state.currentInvoice;
              final subtitle = inv != null && inv.status == InvoiceStatus.draft
                  ? (inv.sequenceNumber != null
                      ? 'Đơn #${inv.sequenceNumber}'
                      : 'Đơn #${inv.id.substring(0, 8)}')
                  : (inv != null && inv.status == InvoiceStatus.confirmed
                      ? (inv.sequenceNumber != null
                          ? 'Đã xác nhận · #${inv.sequenceNumber}'
                          : 'Đã xác nhận')
                      : 'Trong giỏ hàng');
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(subtitle,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        Text('Tổng $totalItems sản phẩm',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('TỔNG TIỀN',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                letterSpacing: 1.2)),
                        Text(
                          formatMoney(state.totalAmount),
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).primaryColor),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<BillingBloc, BillingState>(
              builder: (context, state) {
                if (state.cartItems.isEmpty) {
                  return _buildEmptyCart();
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(
                      left: 15, right: 15, top: 16, bottom: 100),
                  itemCount: state.cartItems.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = state.cartItems[index];
                    return BlocBuilder<WarehouseBloc, WarehouseState>(
                      builder: (context, whState) {
                        return _buildCartItemCard(
                          context,
                          item,
                          whState.warehouses,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child:
                Icon(Icons.shopping_basket, size: 40, color: Colors.grey[300]),
          ),
          const SizedBox(height: 16),
          const Text('Danh sách trống',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Quét mã bằng camera phía trên, hoặc gõ tên / mã vào ô tìm kiếm để thêm vào giỏ.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(
    BuildContext context,
    InvoiceItem item,
    List<Warehouse> warehouses,
  ) {
    String wName;
    try {
      wName = warehouses.firstWhere((w) => w.id == item.sourceWarehouseId).name;
    } catch (_) {
      wName = item.sourceWarehouseId;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${formatMoney(item.price)} · $wName · lô ${item.sourceBatchId.substring(0, 6)}',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _circularIconButton(
                    icon: Icons.remove,
                    onPressed: () {
                      if (item.quantity > 1) {
                        context.read<BillingBloc>().add(UpdateQuantityEvent(
                              item.productId,
                              item.sourceBatchId,
                              item.quantity - 1,
                            ));
                      } else {
                        context.read<BillingBloc>().add(
                              RemoveProductFromCartEvent(
                                item.productId,
                                item.sourceBatchId,
                              ),
                            );
                      }
                    }),
                SizedBox(
                  width: 32,
                  child: Text(
                    '${item.quantity}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                _circularIconButton(
                    icon: Icons.add,
                    onPressed: () {
                      context.read<BillingBloc>().add(UpdateQuantityEvent(
                            item.productId,
                            item.sourceBatchId,
                            item.quantity + 1,
                          ));
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circularIconButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 20, color: Colors.grey[600]),
      ),
    );
  }
}
