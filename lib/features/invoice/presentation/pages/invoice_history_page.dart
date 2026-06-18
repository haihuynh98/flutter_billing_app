import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/money_format.dart';
import '../../../billing/presentation/bloc/billing_bloc.dart';
import '../../domain/entities/invoice.dart';
import '../bloc/invoice_bloc.dart';

class InvoiceHistoryPage extends StatefulWidget {
  const InvoiceHistoryPage({super.key});

  @override
  State<InvoiceHistoryPage> createState() => _InvoiceHistoryPageState();
}

class _InvoiceHistoryPageState extends State<InvoiceHistoryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  @override
  void initState() {
    super.initState();
    context.read<InvoiceBloc>().add(const LoadDraftInvoicesEvent());
    context.read<InvoiceBloc>().add(const LoadConfirmedInvoicesEvent());
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử hóa đơn',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.chevron_left,
              size: 28, color: Theme.of(context).primaryColor),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Đang thực hiện'),
            Tab(text: 'Đã xác nhận'),
          ],
        ),
      ),
      body: BlocConsumer<InvoiceBloc, InvoiceListState>(
        listener: (context, state) {
          if (state.status == InvoiceListStatus.error &&
              state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message!),
                  backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tab,
            children: [
              _buildDraftList(context, state.drafts, df),
              _buildConfirmedList(context, state.confirmed, df),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDraftList(
      BuildContext context, List<Invoice> drafts, DateFormat df) {
    if (drafts.isEmpty) {
      return const Center(child: Text('Không có đơn đang thực hiện.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: drafts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final inv = drafts[i];
        return ListTile(
          tileColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text(
            inv.sequenceNumber != null
                ? 'Đơn #${inv.sequenceNumber}'
                : 'Đơn #${inv.id.substring(0, 8)}',
          ),
          subtitle: Text(
              '${df.format(inv.createdAt)} · ${inv.customerName} · ${inv.items.length} dòng · ${formatMoney(inv.total)}'),
          onTap: () {
            context.read<BillingBloc>().add(OpenDraftInvoiceEvent(inv.id));
            context.go('/');
          },
          onLongPress: () => _confirmDeleteDraft(context, inv.id),
        );
      },
    );
  }

  Widget _buildConfirmedList(
      BuildContext context, List<Invoice> list, DateFormat df) {
    if (list.isEmpty) {
      return const Center(child: Text('Chưa có đơn đã xác nhận.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final inv = list[i];
        return ListTile(
          tileColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text(
            inv.sequenceNumber != null
                ? 'Đơn #${inv.sequenceNumber}'
                : 'Đơn #${inv.id.substring(0, 8)}',
          ),
          subtitle: Text(
              '${df.format(inv.confirmedAt ?? inv.createdAt)} · ${inv.customerName} · ${formatMoney(inv.total)}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/invoices/${inv.id}', extra: inv),
        );
      },
    );
  }

  void _confirmDeleteDraft(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa đơn nháp'),
        content: const Text('Xóa đơn đang thực hiện này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              context.read<InvoiceBloc>().add(DeleteDraftInvoiceEvent(id));
              Navigator.pop(ctx);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
