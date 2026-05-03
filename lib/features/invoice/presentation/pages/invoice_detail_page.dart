import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/printer_helper.dart';
import '../../../../core/data/hive_database.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../domain/entities/invoice.dart';

class InvoiceDetailPage extends StatelessWidget {
  final Invoice invoice;
  const InvoiceDetailPage({super.key, required this.invoice});

  Future<void> _print(BuildContext context) async {
    final shopState = context.read<ShopBloc>().state;
    if (shopState is! ShopLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Chưa tải thông tin cửa hàng'),
            backgroundColor: Colors.red),
      );
      return;
    }
    final shop = shopState.shop;
    final helper = PrinterHelper();
    if (!helper.isConnected) {
      final mac = HiveDatabase.settingsBox.get('printer_mac');
      if (mac != null) {
        final ok = await helper.connect(mac);
        if (!context.mounted) return;
        if (!ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Không kết nối được máy in'),
                backgroundColor: Colors.red),
          );
          return;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Chưa cấu hình máy in'),
              backgroundColor: Colors.red),
        );
        return;
      }
    }
    try {
      final items = invoice.items
          .map((item) => {
                'name': item.productName,
                'qty': item.quantity,
                'price': item.price,
                'total': item.lineTotal,
              })
          .toList();
      await helper.printReceipt(
        shopName: shop.name,
        address1: shop.addressLine1,
        address2: shop.addressLine2,
        phone: shop.phoneNumber,
        items: items,
        total: invoice.total,
        footer: shop.footerText,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('In hóa đơn thành công'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi in: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn #${invoice.id.substring(0, 8)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.chevron_left,
              size: 28, color: Theme.of(context).primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Xác nhận: ${invoice.confirmedAt != null ? df.format(invoice.confirmedAt!) : '—'}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ...invoice.items.map((i) => ListTile(
                title: Text(i.productName),
                subtitle: Text('${i.quantity} × ₹${i.price.toStringAsFixed(2)}'),
                trailing: Text('₹${i.lineTotal.toStringAsFixed(2)}'),
              )),
          const Divider(),
          ListTile(
            title: const Text('Tổng cộng', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text(
              '₹${invoice.total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: () => _print(context),
          icon: const Icon(Icons.print),
          label: const Text('In lại'),
        ),
      ),
    );
  }
}
