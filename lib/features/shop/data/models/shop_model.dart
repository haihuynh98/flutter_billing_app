import 'package:hive/hive.dart';
import '../../domain/entities/shop.dart';

part 'shop_model.g.dart';

@HiveType(typeId: 1)
class ShopModel extends Shop {
  @override
  @HiveField(0)
  final String name;
  @override
  @HiveField(1)
  final String addressLine1;
  @override
  @HiveField(2)
  final String addressLine2;
  @override
  @HiveField(3)
  final String phoneNumber;
  @override
  @HiveField(4)
  final String upiId;
  @override
  @HiveField(5)
  final String footerText;
  @override
  @HiveField(6, defaultValue: 'HÓA ĐƠN BÁN HÀNG')
  final String invoiceTitle;
  @override
  @HiveField(7, defaultValue: 'HD')
  final String invoiceCodePrefix;
  @override
  @HiveField(8, defaultValue: 'Người bán hàng')
  final String sellerLabel;
  @override
  @HiveField(9, defaultValue: 'Người mua hàng')
  final String buyerLabel;
  @override
  @HiveField(10, defaultValue: '(Ký, ghi rõ họ tên)')
  final String signatureNote;
  @override
  @HiveField(11, defaultValue: '')
  final String logoImagePath;

  const ShopModel({
    required this.name,
    required this.addressLine1,
    required this.addressLine2,
    required this.phoneNumber,
    required this.upiId,
    required this.footerText,
    required this.invoiceTitle,
    required this.invoiceCodePrefix,
    required this.sellerLabel,
    required this.buyerLabel,
    required this.signatureNote,
    required this.logoImagePath,
  }) : super(
          name: name,
          addressLine1: addressLine1,
          addressLine2: addressLine2,
          phoneNumber: phoneNumber,
          upiId: upiId,
          footerText: footerText,
          invoiceTitle: invoiceTitle,
          invoiceCodePrefix: invoiceCodePrefix,
          sellerLabel: sellerLabel,
          buyerLabel: buyerLabel,
          signatureNote: signatureNote,
          logoImagePath: logoImagePath,
        );

  factory ShopModel.fromEntity(Shop shop) {
    return ShopModel(
      name: shop.name,
      addressLine1: shop.addressLine1,
      addressLine2: shop.addressLine2,
      phoneNumber: shop.phoneNumber,
      upiId: shop.upiId,
      footerText: shop.footerText,
      invoiceTitle: shop.invoiceTitle,
      invoiceCodePrefix: shop.invoiceCodePrefix,
      sellerLabel: shop.sellerLabel,
      buyerLabel: shop.buyerLabel,
      signatureNote: shop.signatureNote,
      logoImagePath: shop.logoImagePath,
    );
  }

  Shop toEntity() => this;
}
