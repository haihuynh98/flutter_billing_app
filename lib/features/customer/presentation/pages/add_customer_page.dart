import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/app_validators.dart';
import '../../domain/entities/customer.dart';
import '../bloc/customer_bloc.dart';

class AddCustomerPage extends StatefulWidget {
  const AddCustomerPage({super.key});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _phone = '';
  String _address = '';
  String _note = '';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final c = Customer(
        id: const Uuid().v4(),
        name: _name.trim(),
        phone: _phone.trim(),
        address: _address.trim(),
        note: _note.trim(),
      );
      context.read<CustomerBloc>().add(AddCustomerEvent(c));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm khách hàng',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.chevron_left,
              size: 28, color: Theme.of(context).primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const InputLabel(text: 'Tên khách hàng'),
                TextFormField(
                  decoration: const InputDecoration(hintText: 'Bắt buộc'),
                  validator: AppValidators.required('Vui lòng nhập tên'),
                  onSaved: (v) => _name = v!,
                ),
                const SizedBox(height: 24),
                const InputLabel(text: 'Số điện thoại'),
                TextFormField(
                  decoration:
                      const InputDecoration(hintText: 'Không bắt buộc'),
                  keyboardType: TextInputType.phone,
                  onSaved: (v) => _phone = v ?? '',
                ),
                const SizedBox(height: 24),
                const InputLabel(text: 'Địa chỉ'),
                TextFormField(
                  decoration:
                      const InputDecoration(hintText: 'Không bắt buộc'),
                  onSaved: (v) => _address = v ?? '',
                ),
                const SizedBox(height: 24),
                const InputLabel(text: 'Ghi chú'),
                TextFormField(
                  decoration:
                      const InputDecoration(hintText: 'Không bắt buộc'),
                  maxLines: 3,
                  onSaved: (v) => _note = v ?? '',
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: PrimaryButton(
        onPressed: _submit,
        icon: Icons.save,
        label: 'Thêm khách hàng',
      ),
    );
  }
}
