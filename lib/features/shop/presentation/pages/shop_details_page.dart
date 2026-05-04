import 'dart:io';

import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/shop.dart';
import '../bloc/shop_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';

class ShopDetailsPage extends StatefulWidget {
  const ShopDetailsPage({super.key});

  @override
  State<ShopDetailsPage> createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _phoneController;
  late TextEditingController _upiController;
  late TextEditingController _footerController;
  late TextEditingController _invoiceTitleController;
  late TextEditingController _invoiceCodePrefixController;
  late TextEditingController _sellerLabelController;
  late TextEditingController _buyerLabelController;
  late TextEditingController _signatureNoteController;
  String _logoImagePath = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _address1Controller = TextEditingController();
    _address2Controller = TextEditingController();
    _phoneController = TextEditingController();
    _upiController = TextEditingController();
    _footerController = TextEditingController();
    _invoiceTitleController = TextEditingController();
    _invoiceCodePrefixController = TextEditingController();
    _sellerLabelController = TextEditingController();
    _buyerLabelController = TextEditingController();
    _signatureNoteController = TextEditingController();

    // Load shop data
    context.read<ShopBloc>().add(LoadShopEvent());
  }

  void _updateControllers(Shop shop) {
    if (_nameController.text.isEmpty && shop.name.isNotEmpty) {
      _nameController.text = shop.name;
      _address1Controller.text = shop.addressLine1;
      _address2Controller.text = shop.addressLine2;
      _phoneController.text = shop.phoneNumber;
      _upiController.text = shop.upiId;
      _footerController.text = shop.footerText;
      _invoiceTitleController.text = shop.invoiceTitle;
      _invoiceCodePrefixController.text = shop.invoiceCodePrefix;
      _sellerLabelController.text = shop.sellerLabel;
      _buyerLabelController.text = shop.buyerLabel;
      _signatureNoteController.text = shop.signatureNote;
      setState(() {
        _logoImagePath = shop.logoImagePath;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _phoneController.dispose();
    _upiController.dispose();
    _footerController.dispose();
    _invoiceTitleController.dispose();
    _invoiceCodePrefixController.dispose();
    _sellerLabelController.dispose();
    _buyerLabelController.dispose();
    _signatureNoteController.dispose();
    super.dispose();
  }

  void _saveShop() {
    if (_formKey.currentState!.validate()) {
      final shop = Shop(
        name: _nameController.text,
        addressLine1: _address1Controller.text,
        addressLine2: _address2Controller.text,
        phoneNumber: _phoneController.text,
        upiId: _upiController.text,
        footerText: _footerController.text,
        invoiceTitle: _invoiceTitleController.text,
        invoiceCodePrefix: _invoiceCodePrefixController.text,
        sellerLabel: _sellerLabelController.text,
        buyerLabel: _buyerLabelController.text,
        signatureNote: _signatureNoteController.text,
        logoImagePath: _logoImagePath,
      );

      context.read<ShopBloc>().add(UpdateShopEvent(shop));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Thông tin cửa hàng'),
        ),
        body: BlocConsumer<ShopBloc, ShopState>(
          listener: (context, state) {
            if (state is ShopLoaded) {
              _updateControllers(state.shop);
            } else if (state is ShopOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Đã lưu thông tin cửa hàng!'),
                  backgroundColor: Colors.green));
              context.pop();
            } else if (state is ShopError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red));
            }
          },
          buildWhen: (previous, current) =>
              current is ShopLoading || current is ShopLoaded,
          builder: (context, state) {
            if (state is ShopLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Thông tin chung',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppTheme.primaryColor.withValues(alpha: 0.8),
                        )),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Các thông tin này sẽ hiển thị trên hóa đơn điện tử và hóa đơn in.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 24),
                    const InputLabel(text: 'Tên cửa hàng'),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'ví dụ: Tạp hóa Thành Đạt',
                      validator: AppValidators.required('Bắt buộc'),
                    ),
                    const SizedBox(height: 15),
                    const InputLabel(text: 'Địa chỉ dòng 1'),
                    _buildTextField(
                      controller: _address1Controller,
                      hint: 'Samrajpet, Mecheri',
                      validator: AppValidators.required('Bắt buộc'),
                    ),
                    const SizedBox(height: 15),
                    const InputLabel(text: 'Địa chỉ dòng 2 (Tùy chọn)'),
                    _buildTextField(
                      controller: _address2Controller,
                      hint: 'Salem - 636453',
                    ),
                    const SizedBox(height: 15),
                    const InputLabel(text: 'Số điện thoại'),
                    _buildTextField(
                      controller: _phoneController,
                      hint: '+91 7010674588',
                      keyboardType: TextInputType.phone,
                      validator: AppValidators.required('Bắt buộc'),
                    ),
                    const SizedBox(height: 15),
                    const InputLabel(text: 'UPI ID'),
                    _buildTextField(
                      controller: _upiController,
                      hint: 'dineshsowndar@oksbi',
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const InputLabel(text: 'Nội dung chân hóa đơn'),
                        Text('Tối đa 150 ký tự',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[400])),
                      ],
                    ),
                    _buildTextField(
                      controller: _footerController,
                      hint: 'Cảm ơn quý khách, hẹn gặp lại!',
                      maxLines: 2,
                      maxLength: 60,
                    ),
                    const SizedBox(height: 24),
                    Text('Mẫu hóa đơn',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppTheme.primaryColor.withValues(alpha: 0.8),
                        )),
                    const SizedBox(height: 5),
                    Text(
                      'Các trường dưới đây giúp định dạng bill in/ảnh theo mẫu của bạn.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 16),
                    const InputLabel(text: 'Logo hóa đơn (tùy chọn)'),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickLogoImage,
                            icon: const Icon(Icons.image_outlined),
                            label: Text(
                              _logoImagePath.isEmpty
                                  ? 'Chọn ảnh logo'
                                  : 'Đổi ảnh logo',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_logoImagePath.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setState(() => _logoImagePath = '');
                            },
                            child: const Text('Xóa'),
                          ),
                      ],
                    ),
                    if (_logoImagePath.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_logoImagePath),
                          height: 72,
                          width: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 72,
                            width: 72,
                            alignment: Alignment.center,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 15),
                    const InputLabel(text: 'Tiêu đề hóa đơn'),
                    _buildTextField(
                      controller: _invoiceTitleController,
                      hint: 'HÓA ĐƠN BÁN HÀNG',
                      validator: AppValidators.required('Bắt buộc'),
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 15),
                    const InputLabel(text: 'Tiền tố mã hóa đơn'),
                    _buildTextField(
                      controller: _invoiceCodePrefixController,
                      hint: 'HD',
                      maxLength: 10,
                    ),
                    const SizedBox(height: 15),
                    const InputLabel(text: 'Nhãn chữ ký người bán'),
                    _buildTextField(
                      controller: _sellerLabelController,
                      hint: 'Người bán hàng',
                      validator: AppValidators.required('Bắt buộc'),
                    ),
                    const SizedBox(height: 15),
                    const InputLabel(text: 'Nhãn chữ ký người mua'),
                    _buildTextField(
                      controller: _buyerLabelController,
                      hint: 'Người mua hàng',
                      validator: AppValidators.required('Bắt buộc'),
                    ),
                    const SizedBox(height: 15),
                    const InputLabel(text: 'Ghi chú chữ ký'),
                    _buildTextField(
                      controller: _signatureNoteController,
                      hint: '(Ký, ghi rõ họ tên)',
                      validator: AppValidators.required('Bắt buộc'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: PrimaryButton(
          onPressed: _saveShop,
          icon: Icons.save,
          label: 'Lưu thông tin',
        ));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
    TextCapitalization textCapitalization = TextCapitalization.words,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
      ),
    );
  }

  Future<void> _pickLogoImage() async {
    final XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 90,
    );
    if (file == null) return;
    if (!mounted) return;
    setState(() => _logoImagePath = file.path);
  }
}
