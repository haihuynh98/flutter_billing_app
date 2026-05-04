import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/data/hive_database.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/printer_helper.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../domain/entities/invoice.dart';

class InvoiceDetailPage extends StatefulWidget {
  final Invoice invoice;
  const InvoiceDetailPage({super.key, required this.invoice});

  @override
  State<InvoiceDetailPage> createState() => _InvoiceDetailPageState();
}

class _InvoiceDetailPageState extends State<InvoiceDetailPage> {
  bool _isExportingReceiptImage = false;

  Future<void> _print() async {
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
        if (!mounted) return;
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
      final items = widget.invoice.items
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
        total: widget.invoice.total,
        footer: shop.footerText,
        invoiceTitle: shop.invoiceTitle,
        invoiceCodePrefix: shop.invoiceCodePrefix,
        invoiceId: widget.invoice.id,
        invoiceSequence: widget.invoice.sequenceNumber,
        createdAt: widget.invoice.createdAt,
        sellerLabel: shop.sellerLabel,
        buyerLabel: shop.buyerLabel,
        signatureNote: shop.signatureNote,
        logoImagePath: shop.logoImagePath,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('In hóa đơn thành công'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi in: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _exportReceiptImage() async {
    final shopState = context.read<ShopBloc>().state;
    if (shopState is! ShopLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Chưa tải thông tin cửa hàng'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() => _isExportingReceiptImage = true);
    try {
      final inv = widget.invoice;
      final now = DateTime.now();
      final Uint8List bytes = await PrinterHelper().buildReceiptImageBytes(
        shopName: shopState.shop.name,
        address1: shopState.shop.addressLine1,
        address2: shopState.shop.addressLine2,
        phone: shopState.shop.phoneNumber,
        items: inv.items
            .map((item) => {
                  'name': item.productName,
                  'qty': item.quantity.toString(),
                  'price': formatMoney(item.price),
                  'total': formatMoney(item.lineTotal),
                })
            .toList(),
        total: inv.total,
        footer: shopState.shop.footerText,
        invoiceTitle: shopState.shop.invoiceTitle,
        invoiceCodePrefix: shopState.shop.invoiceCodePrefix,
        invoiceId: inv.id,
        invoiceSequence: inv.sequenceNumber,
        sellerLabel: shopState.shop.sellerLabel,
        buyerLabel: shopState.shop.buyerLabel,
        signatureNote: shopState.shop.signatureNote,
        logoImagePath: shopState.shop.logoImagePath,
        createdAt: inv.createdAt,
      );

      final bool hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        await Gal.requestAccess(toAlbum: true);
      }
      await Gal.putImageBytes(
        bytes,
        album: 'Tiger Retail',
        name: 'bill_${DateFormat('yyyyMMdd_HHmmss').format(now)}',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Đã lưu ảnh bill vào thư viện'),
        backgroundColor: Colors.green,
      ));

      final Directory tempDir = await getTemporaryDirectory();
      final String fileName =
          'bill_${DateFormat('yyyyMMdd_HHmmss').format(now)}.png';
      final File file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Hóa đơn từ ${shopState.shop.name}',
        subject: 'Bill ${DateFormat('dd/MM/yyyy HH:mm').format(now)}',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Xuất ảnh bill thất bại: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) {
        setState(() => _isExportingReceiptImage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy HH:mm');
    final inv = widget.invoice;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            inv.sequenceNumber != null
                ? 'Đơn #${inv.sequenceNumber}'
                : 'Đơn #${inv.id.substring(0, 8)}',
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
            'Xác nhận: ${inv.confirmedAt != null ? df.format(inv.confirmedAt!) : '—'}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ...inv.items.map((i) => ListTile(
                title: Text(i.productName),
                subtitle: Text('${i.quantity} × ${formatMoney(i.price)}'),
                trailing: Text(formatMoney(i.lineTotal)),
              )),
          const Divider(),
          ListTile(
            title: const Text('Tổng cộng',
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text(
              formatMoney(inv.total),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: PrimaryButton(
                outerPadding: const EdgeInsets.fromLTRB(16, 8, 6, 16),
                onPressed: _print,
                label: 'In lại',
                icon: Icons.print,
              ),
            ),
            Expanded(
              child: PrimaryButton(
                outerPadding: const EdgeInsets.fromLTRB(6, 8, 16, 16),
                onPressed: _isExportingReceiptImage ? null : _exportReceiptImage,
                label: 'Lưu & chia sẻ ảnh bill',
                icon: Icons.image_outlined,
                isLoading: _isExportingReceiptImage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
