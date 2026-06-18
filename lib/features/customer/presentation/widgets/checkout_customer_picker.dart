import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../billing/presentation/bloc/billing_bloc.dart';
import '../../domain/entities/customer.dart';
import '../bloc/customer_bloc.dart';
import 'quick_add_customer_dialog.dart';

class CheckoutCustomerPicker extends StatelessWidget {
  const CheckoutCustomerPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BillingBloc, BillingState>(
      builder: (context, billingState) {
        return BlocBuilder<CustomerBloc, CustomerState>(
          builder: (context, customerState) {
            final selectedId = billingState.selectedCustomerId;
            final selectedName = billingState.selectedCustomerName;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E5EA)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(
                children: [
                  Icon(Icons.person_outline,
                      color: Theme.of(context).primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Khách hàng',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500],
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () => _showPicker(
                            context,
                            customers: customerState.customers,
                            selectedId: selectedId,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  selectedName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(Icons.arrow_drop_down,
                                  color: Colors.grey[600]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Thêm khách hàng nhanh',
                    onPressed: () => _quickAdd(context),
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _quickAdd(BuildContext context) async {
    final customer = await showQuickAddCustomerDialog(context);
    if (customer == null || !context.mounted) return;
    context.read<BillingBloc>().add(SelectCustomerEvent(
          customerId: customer.id,
          customerName: customer.name,
        ));
  }

  Future<void> _showPicker(
    BuildContext context, {
    required List<Customer> customers,
    required String? selectedId,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Chọn khách hàng',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.storefront_outlined),
                title: Text(RetailCustomer.name),
                subtitle: const Text('Mặc định'),
                selected: selectedId == null,
                onTap: () {
                  context.read<BillingBloc>().add(const SelectCustomerEvent(
                        customerName: RetailCustomer.name,
                      ));
                  Navigator.pop(ctx);
                },
              ),
              if (customers.isNotEmpty) const Divider(height: 1),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: customers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final c = customers[index];
                    return ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(c.name),
                      subtitle: c.phone.isNotEmpty ? Text(c.phone) : null,
                      selected: selectedId == c.id,
                      onTap: () {
                        context.read<BillingBloc>().add(SelectCustomerEvent(
                              customerId: c.id,
                              customerName: c.name,
                            ));
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
