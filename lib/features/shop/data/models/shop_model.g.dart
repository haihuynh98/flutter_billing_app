// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShopModelAdapter extends TypeAdapter<ShopModel> {
  @override
  final int typeId = 1;

  @override
  ShopModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShopModel(
      name: fields[0] as String,
      addressLine1: fields[1] as String,
      addressLine2: fields[2] as String,
      phoneNumber: fields[3] as String,
      upiId: fields[4] as String,
      footerText: fields[5] as String,
      invoiceTitle:
          fields[6] == null ? 'HÓA ĐƠN BÁN HÀNG' : fields[6] as String,
      invoiceCodePrefix: fields[7] == null ? 'HD' : fields[7] as String,
      sellerLabel: fields[8] == null ? 'Người bán hàng' : fields[8] as String,
      buyerLabel: fields[9] == null ? 'Người mua hàng' : fields[9] as String,
      signatureNote:
          fields[10] == null ? '(Ký, ghi rõ họ tên)' : fields[10] as String,
      logoImagePath: fields[11] == null ? '' : fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ShopModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.addressLine1)
      ..writeByte(2)
      ..write(obj.addressLine2)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(4)
      ..write(obj.upiId)
      ..writeByte(5)
      ..write(obj.footerText)
      ..writeByte(6)
      ..write(obj.invoiceTitle)
      ..writeByte(7)
      ..write(obj.invoiceCodePrefix)
      ..writeByte(8)
      ..write(obj.sellerLabel)
      ..writeByte(9)
      ..write(obj.buyerLabel)
      ..writeByte(10)
      ..write(obj.signatureNote)
      ..writeByte(11)
      ..write(obj.logoImagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
