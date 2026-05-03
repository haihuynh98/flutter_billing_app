import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/service_locator.dart' as di;
import '../../../../core/utils/app_validators.dart';
import '../../../warehouse/domain/usecases/warehouse_usecases.dart';
import '../../domain/entities/warehouse.dart';
import '../bloc/warehouse_bloc.dart';

class EditWarehousePage extends StatefulWidget {
  final Warehouse warehouse;
  const EditWarehousePage({super.key, required this.warehouse});

  @override
  State<EditWarehousePage> createState() => _EditWarehousePageState();
}

class _EditWarehousePageState extends State<EditWarehousePage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _location;

  @override
  void initState() {
    super.initState();
    _name = widget.warehouse.name;
    _location = widget.warehouse.location ?? '';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final countUseCase = di.sl<CountDistinctProductsWithBatchesInWarehouseUseCase>();
    final countResult = await countUseCase(widget.warehouse.id);
    final count = countResult.fold((_) => 0, (c) => c);

    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận lưu'),
        content: Text(
          'Có $count sản phẩm đang lưu kho này. Tiếp tục lưu thông tin mới?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final updated = Warehouse(
      id: widget.warehouse.id,
      name: _name.trim(),
      location: _location.trim().isEmpty ? null : _location.trim(),
    );
    context.read<WarehouseBloc>().add(UpdateWarehouseEvent(updated));
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa kho',
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
                  initialValue: _name,
                  decoration: const InputDecoration(hintText: 'Bắt buộc'),
                  validator: AppValidators.required('Vui lòng nhập tên kho'),
                  onSaved: (v) => _name = v!,
                ),
                const SizedBox(height: 24),
                const InputLabel(text: 'Vị trí kho'),
                TextFormField(
                  initialValue: _location,
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
        label: 'Lưu thay đổi',
      ),
    );
  }
}
