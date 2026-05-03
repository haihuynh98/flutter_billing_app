// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_batch_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockBatchModelAdapter extends TypeAdapter<StockBatchModel> {
  @override
  final int typeId = 3;

  @override
  StockBatchModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockBatchModel(
      id: fields[0] as String,
      productId: fields[1] as String,
      warehouseId: fields[2] as String,
      importDate: fields[3] as DateTime,
      quantity: fields[4] as int,
      importPrice: fields[5] as double,
      supplierName: fields[6] as String?,
      expiryDate: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, StockBatchModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.warehouseId)
      ..writeByte(3)
      ..write(obj.importDate)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.importPrice)
      ..writeByte(6)
      ..write(obj.supplierName)
      ..writeByte(7)
      ..write(obj.expiryDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockBatchModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
