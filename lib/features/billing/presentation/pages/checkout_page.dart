import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../../invoice/domain/entities/invoice_status.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../../warehouse/presentation/bloc/warehouse_bloc.dart';
import '../bloc/billing_bloc.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE5E5EA);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        await _onBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thanh toán',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.chevron_left,
                size: 28, color: Theme.of(context).primaryColor),
            onPressed: _onBack,
          ),
        ),
        body: BlocConsumer<BillingBloc, BillingState>(
          listenWhen: (p, c) =>
              (p.printSuccess != c.printSuccess && c.printSuccess) ||
              (p.confirmSuccess != c.confirmSuccess && c.confirmSuccess) ||
              (p.error != c.error && c.error != null),
          listener: (context, state) {
            if (state.printSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('In hóa đơn thành công'),
                  backgroundColor: Colors.green));
            }
            if (state.confirmSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Đã xác nhận đơn, tồn kho đã trừ'),
                  backgroundColor: Colors.green));
            }
            if (state.error != null && state.isPrinting == false) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.error!),
                  backgroundColor: Colors.red));
            }
          },
          builder: (context, billingState) {
            return BlocBuilder<ShopBloc, ShopState>(
                builder: (context, shopState) {
              String upiId = '';
              String shopName = 'Cửa hàng';

              if (shopState is ShopLoaded) {
                upiId = shopState.shop.upiId;
                shopName = shopState.shop.name;
              }

              final inv = billingState.currentInvoice;
              final isDraft = inv?.status == InvoiceStatus.draft;
              final df = DateFormat('dd/MM HH:mm');

              return Column(
                children: [
                  if (inv != null && inv.status == InvoiceStatus.confirmed)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Chip(
                        label: Text(
                            'Đã xác nhận ${inv.confirmedAt != null ? df.format(inv.confirmedAt!) : ''}'),
                        backgroundColor: Colors.teal.shade50,
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Table(
                                border: const TableBorder(
                                  horizontalInside:
                                      BorderSide(color: borderColor),
                                  bottom: BorderSide(color: borderColor),
                                ),
                                children: [
                                  TableRow(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF8FAFC),
                                      border: Border(
                                          bottom:
                                              BorderSide(color: borderColor)),
                                    ),
                                    children: [
                                      _buildHeaderCell(
                                          'Sản phẩm', TextAlign.left),
                                      _buildHeaderCell('Nguồn', TextAlign.left),
                                      _buildHeaderCell(
                                          'Đơn giá', TextAlign.right),
                                      _buildHeaderCell(
                                          'Thành tiền', TextAlign.right),
                                    ],
                                  ),
                                  ...billingState.cartItems.map((item) {
                                    return TableRow(
                                      children: [
                                        _buildDataCell(
                                          '${item.quantity} × ${item.productName}',
                                          TextAlign.left,
                                        ),
                                        BlocBuilder<WarehouseBloc,
                                            WarehouseState>(
                                          builder: (context, wh) {
                                            String wName;
                                            try {
                                              wName = wh.warehouses
                                                  .firstWhere((w) =>
                                                      w.id ==
                                                      item.sourceWarehouseId)
                                                  .name;
                                            } catch (_) {
                                              wName = item.sourceWarehouseId;
                                            }
                                            return _buildDataCell(
                                              wName,
                                              TextAlign.left,
                                              isSubtitle: true,
                                            );
                                          },
                                        ),
                                        _buildDataCell(
                                            '₹${item.price.toStringAsFixed(2)}',
                                            TextAlign.right,
                                            isSubtitle: true),
                                        _buildDataCell(
                                            '₹${item.lineTotal.toStringAsFixed(2)}',
                                            TextAlign.right,
                                            isBold: true),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(24),
                        right: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              upiId.isNotEmpty
                                  ? Column(
                                      children: [
                                        const Text(
                                          'Quét mã để thanh toán',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                            letterSpacing: 1.1,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: 180,
                                          height: 180,
                                          child: PrettyQrView.data(
                                            data:
                                                'upi://pay?pa=$upiId&pn=$shopName&am=${billingState.totalAmount.toStringAsFixed(2)}&cu=INR',
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'TỔNG CỘNG',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[400],
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  Text(
                                    '₹${billingState.totalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (isDraft) ...[
                          PrimaryButton(
                            onPressed: billingState.cartItems.isEmpty
                                ? null
                                : () => context
                                    .read<BillingBloc>()
                                    .add(const ConfirmInvoiceEvent()),
                            label: 'Xác nhận đơn',
                            icon: Icons.check_circle,
                            isLoading: billingState.isConfirming,
                          ),
                          const SizedBox(height: 8),
                        ],
                        PrimaryButton(
                          onPressed: () {
                            if (shopState is ShopLoaded) {
                              context.read<BillingBloc>().add(PrintReceiptEvent(
                                    shopName: shopState.shop.name,
                                    address1: shopState.shop.addressLine1,
                                    address2: shopState.shop.addressLine2,
                                    phone: shopState.shop.phoneNumber,
                                    footer: shopState.shop.footerText));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Chưa tải thông tin cửa hàng'),
                                      backgroundColor: Colors.red));
                            }
                          },
                          label: isDraft
                              ? 'In hóa đơn (Chưa xác nhận)'
                              : 'In hóa đơn',
                          icon: Icons.print,
                          isLoading: billingState.isPrinting,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            });
          },
        ),
      ),
    );
  }

  Future<void> _onBack() async {
    final inv = context.read<BillingBloc>().state.currentInvoice;
    if (inv != null && inv.status == InvoiceStatus.draft) {
      final choice = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Rời khỏi thanh toán'),
          content: const Text('Bạn muốn giữ đơn đang thực hiện hay hủy đơn?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'keep'),
              child: const Text('Tạm để sau'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'cancel'),
              child: const Text('Hủy đơn', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (choice == 'cancel') {
        context.read<BillingBloc>().add(const ClearCartEvent());
      }
      context.go('/');
      return;
    }
    if (mounted) context.go('/');
  }

  Widget _buildHeaderCell(String text, TextAlign align) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Text(
        text.toUpperCase(),
        textAlign: align,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, TextAlign align,
      {bool isBold = false, bool isSubtitle = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: isSubtitle ? 11 : 12,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          color: isSubtitle ? Colors.grey[600] : Colors.black87,
        ),
      ),
    );
  }
}
