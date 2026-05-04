import 'package:equatable/equatable.dart';

class Shop extends Equatable {
  final String name;
  final String addressLine1;
  final String addressLine2;
  final String phoneNumber;
  final String upiId;
  final String footerText;
  final String invoiceTitle;
  final String invoiceCodePrefix;
  final String sellerLabel;
  final String buyerLabel;
  final String signatureNote;
  final String logoImagePath;

  const Shop({
    this.name = '',
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.phoneNumber = '',
    this.upiId = '',
    this.footerText = '',
    this.invoiceTitle = 'HÓA ĐƠN BÁN HÀNG',
    this.invoiceCodePrefix = 'HD',
    this.sellerLabel = 'Người bán hàng',
    this.buyerLabel = 'Người mua hàng',
    this.signatureNote = '(Ký, ghi rõ họ tên)',
    this.logoImagePath = '',
  });

  Shop copyWith({
    String? name,
    String? addressLine1,
    String? addressLine2,
    String? phoneNumber,
    String? upiId,
    String? footerText,
    String? invoiceTitle,
    String? invoiceCodePrefix,
    String? sellerLabel,
    String? buyerLabel,
    String? signatureNote,
    String? logoImagePath,
  }) {
    return Shop(
      name: name ?? this.name,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      upiId: upiId ?? this.upiId,
      footerText: footerText ?? this.footerText,
      invoiceTitle: invoiceTitle ?? this.invoiceTitle,
      invoiceCodePrefix: invoiceCodePrefix ?? this.invoiceCodePrefix,
      sellerLabel: sellerLabel ?? this.sellerLabel,
      buyerLabel: buyerLabel ?? this.buyerLabel,
      signatureNote: signatureNote ?? this.signatureNote,
      logoImagePath: logoImagePath ?? this.logoImagePath,
    );
  }

  @override
  List<Object?> get props => [
        name,
        addressLine1,
        addressLine2,
        phoneNumber,
        upiId,
        footerText,
        invoiceTitle,
        invoiceCodePrefix,
        sellerLabel,
        buyerLabel,
        signatureNote,
        logoImagePath,
      ];
}
