import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/app_validators.dart';
import '../../domain/entities/warehouse.dart';
import '../bloc/warehouse_bloc.dart';

class AddWarehousePage extends StatefulWidget {
  const AddWarehousePage({super.key});

  @override
  State<AddWarehousePage> createState() => _AddWarehousePageState();
}

class _AddWarehousePageState extends State<AddWarehousePage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _location = '';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final w = Warehouse(
        id: const Uuid().v4(),
        name: _name.trim(),
        location: _location.trim().isEmpty ? null : _location.trim(),
      );
      context.read<WarehouseBloc>().add(AddWarehouseEvent(w));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm kho',
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
                const InputLabel(text: 'Tên kho'),
                TextFormField(
                  decoration: const InputDecoration(hintText: 'Bắt buộc'),
                  validator: AppValidators.required('Vui lòng nhập tên kho'),
                  onSaved: (v) => _name = v!,
                ),
                const SizedBox(height: 24),
                const InputLabel(text: 'Vị trí kho'),
                TextFormField(
                  decoration:
                      const InputDecoration(hintText: 'Không bắt buộc'),
                  onSaved: (v) => _location = v ?? '',
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: PrimaryButton(
        onPressed: _submit,
        icon: Icons.save,
        label: 'Thêm kho',
      ),
    );
  }
}
