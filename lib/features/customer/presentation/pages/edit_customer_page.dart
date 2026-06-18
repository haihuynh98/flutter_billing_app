import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_validators.dart';
import '../../domain/entities/customer.dart';
import '../bloc/customer_bloc.dart';

class EditCustomerPage extends StatefulWidget {
  final Customer customer;

  const EditCustomerPage({super.key, required this.customer});

  @override
  State<EditCustomerPage> createState() => _EditCustomerPageState();
}

class _EditCustomerPageState extends State<EditCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _phone;
  late String _address;
  late String _note;

  @override
  void initState() {
    super.initState();
    _name = widget.customer.name;
    _phone = widget.customer.phone;
    _address = widget.customer.address;
    _note = widget.customer.note;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final c = widget.customer.copyWith(
        name: _name.trim(),
        phone: _phone.trim(),
        address: _address.trim(),
        note: _note.trim(),
      );
      context.read<CustomerBloc>().add(UpdateCustomerEvent(c));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa khách hàng',
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
                  initialValue: _name,
                  decoration: const InputDecoration(hintText: 'Bắt buộc'),
                  validator: AppValidators.required('Vui lòng nhập tên'),
                  onSaved: (v) => _name = v!,
                ),
                const SizedBox(height: 24),
                const InputLabel(text: 'Số điện thoại'),
                TextFormField(
                  initialValue: _phone,
                  decoration:
                      const InputDecoration(hintText: 'Không bắt buộc'),
                  keyboardType: TextInputType.phone,
                  onSaved: (v) => _phone = v ?? '',
                ),
                const SizedBox(height: 24),
                const InputLabel(text: 'Địa chỉ'),
                TextFormField(
                  initialValue: _address,
                  decoration:
                      const InputDecoration(hintText: 'Không bắt buộc'),
                  onSaved: (v) => _address = v ?? '',
                ),
                const SizedBox(height: 24),
                const InputLabel(text: 'Ghi chú'),
                TextFormField(
                  initialValue: _note,
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
        label: 'Lưu thay đổi',
      ),
    );
  }
}
