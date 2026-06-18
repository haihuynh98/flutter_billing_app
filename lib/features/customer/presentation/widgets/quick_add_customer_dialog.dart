import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/input_label.dart';
import '../../domain/entities/customer.dart';
import '../bloc/customer_bloc.dart';

/// Quick-add customer dialog; returns the created [Customer] on success.
Future<Customer?> showQuickAddCustomerDialog(BuildContext context) {
  return showDialog<Customer>(
    context: context,
    builder: (ctx) => const _QuickAddCustomerDialog(),
  );
}

class _QuickAddCustomerDialog extends StatefulWidget {
  const _QuickAddCustomerDialog();

  @override
  State<_QuickAddCustomerDialog> createState() => _QuickAddCustomerDialogState();
}

class _QuickAddCustomerDialogState extends State<_QuickAddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _phone = '';
  String _address = '';

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final trimmedName = _name.trim();
    final exists = context.read<CustomerBloc>().state.customers.any(
          (c) => c.name.trim().toLowerCase() == trimmedName.toLowerCase(),
        );
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tên khách hàng đã tồn tại'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final customer = Customer(
      id: const Uuid().v4(),
      name: trimmedName,
      phone: _phone.trim(),
      address: _address.trim(),
    );
    context.read<CustomerBloc>().add(AddCustomerEvent(customer));
    Navigator.pop(context, customer);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm khách hàng nhanh'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const InputLabel(text: 'Tên khách hàng'),
              TextFormField(
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Bắt buộc'),
                validator: AppValidators.required('Vui lòng nhập tên'),
                onSaved: (v) => _name = v!,
              ),
              const SizedBox(height: 12),
              const InputLabel(text: 'Số điện thoại'),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Không bắt buộc'),
                keyboardType: TextInputType.phone,
                onSaved: (v) => _phone = v ?? '',
              ),
              const SizedBox(height: 12),
              const InputLabel(text: 'Địa chỉ'),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Không bắt buộc'),
                onSaved: (v) => _address = v ?? '',
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
        FilledButton(
          onPressed: _submit,
          child: const Text('Thêm'),
        ),
      ],
    );
  }
}
