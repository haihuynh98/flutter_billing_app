import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money_format.dart';
import '../../../billing/presentation/bloc/billing_bloc.dart';
import '../../../invoice/domain/entities/invoice.dart';
import '../../domain/entities/customer.dart';
import '../bloc/customer_invoice_history_bloc.dart';

class CustomerInvoiceHistoryPage extends StatelessWidget {
  final Customer? customer;
  final bool isRetail;

  const CustomerInvoiceHistoryPage({
    super.key,
    required this.customer,
  }) : isRetail = false;

  const CustomerInvoiceHistoryPage.retail({super.key})
      : customer = null,
        isRetail = true;

  String get _displayName =>
      isRetail ? RetailCustomer.name : customer!.name;

  String? get _customerId => isRetail ? null : customer!.id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CustomerInvoiceHistoryBloc>()
        ..add(LoadCustomerInvoiceHistoryEvent(customerId: _customerId)),
      child: _CustomerInvoiceHistoryView(
        displayName: _displayName,
        customer: customer,
        isRetail: isRetail,
      ),
    );
  }
}

class _CustomerInvoiceHistoryView extends StatefulWidget {
  final String displayName;
  final Customer? customer;
  final bool isRetail;

  const _CustomerInvoiceHistoryView({
    required this.displayName,
    required this.customer,
    required this.isRetail,
  });

  @override
  State<_CustomerInvoiceHistoryView> createState() =>
      _CustomerInvoiceHistoryViewState();
}

class _CustomerInvoiceHistoryViewState extends State<_CustomerInvoiceHistoryView>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

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
        title: Text(
          'Lịch sử đơn · ${widget.displayName}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left,
              size: 28, color: Theme.of(context).primaryColor),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Đã xác nhận'),
            Tab(text: 'Đang thực hiện'),
          ],
        ),
      ),
      body: BlocConsumer<CustomerInvoiceHistoryBloc, CustomerInvoiceHistoryState>(
        listener: (context, state) {
          if (state.status == CustomerInvoiceHistoryStatus.error &&
              state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == CustomerInvoiceHistoryStatus.loading &&
              state.confirmed.isEmpty &&
              state.drafts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildSummary(context, state),
              if (!widget.isRetail && widget.customer != null)
                _buildCustomerInfo(widget.customer!),
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _buildInvoiceList(
                      context,
                      state.confirmed,
                      df,
                      emptyMessage: 'Chưa có đơn đã xác nhận.',
                      isDraft: false,
                    ),
                    _buildInvoiceList(
                      context,
                      state.drafts,
                      df,
                      emptyMessage: 'Không có đơn đang thực hiện.',
                      isDraft: true,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummary(
      BuildContext context, CustomerInvoiceHistoryState state) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              label: 'Đã xác nhận',
              value: '${state.confirmedCount} đơn',
            ),
          ),
          Container(width: 1, height: 36, color: Colors.grey.shade200),
          Expanded(
            child: _SummaryItem(
              label: 'Tổng doanh thu',
              value: formatMoney(state.totalRevenue),
              valueColor: AppTheme.primaryColor,
            ),
          ),
          Container(width: 1, height: 36, color: Colors.grey.shade200),
          Expanded(
            child: _SummaryItem(
              label: 'Đang thực hiện',
              value: '${state.draftCount} đơn',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(Customer customer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          [
            if (customer.phone.isNotEmpty) customer.phone,
            if (customer.address.isNotEmpty) customer.address,
          ].join(' · '),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildInvoiceList(
    BuildContext context,
    List<Invoice> invoices,
    DateFormat df, {
    required String emptyMessage,
    required bool isDraft,
  }) {
    if (invoices.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: invoices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final inv = invoices[index];
        final date = isDraft
            ? inv.createdAt
            : (inv.confirmedAt ?? inv.createdAt);
        return ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text(
            inv.sequenceNumber != null
                ? 'Đơn #${inv.sequenceNumber}'
                : 'Đơn #${inv.id.substring(0, 8)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${df.format(date)} · ${inv.items.length} dòng',
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatMoney(inv.total),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (!isDraft)
                Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
            ],
          ),
          onTap: () {
            if (isDraft) {
              context.read<BillingBloc>().add(OpenDraftInvoiceEvent(inv.id));
              context.go('/');
              return;
            }
            context.push('/invoices/${inv.id}', extra: inv);
          },
        );
      },
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
