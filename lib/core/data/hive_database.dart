import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../features/invoice/data/models/invoice_item_model.dart';
import '../../features/invoice/data/models/invoice_model.dart';
import '../../features/product/data/models/product_model.dart';
import '../../features/shop/data/models/shop_model.dart';
import '../../features/stock/data/models/stock_batch_model.dart';
import '../../features/stock/data/models/stock_movement_model.dart';
import '../../features/warehouse/data/models/warehouse_model.dart';
import '../utils/stock_constants.dart';

class HiveDatabase {
  static const String productBoxName = 'products';
  static const String shopBoxName = 'shop';
  static const String settingsBoxName = 'settings';
  static const String warehouseBoxName = 'warehouses';
  static const String stockBatchBoxName = 'stock_batches';
  static const String stockMovementBoxName = 'stock_movements';
  static const String invoiceBoxName = 'invoices';

  static Future<void> init() async {
    await Hive.initFlutter();

    _registerAdapters();

    await Hive.openBox<ProductModel>(productBoxName);
    await Hive.openBox<ShopModel>(shopBoxName);
    await Hive.openBox(settingsBoxName);
    await Hive.openBox<WarehouseModel>(warehouseBoxName);
    await Hive.openBox<StockBatchModel>(stockBatchBoxName);
    await Hive.openBox<StockMovementModel>(stockMovementBoxName);
    await Hive.openBox<InvoiceModel>(invoiceBoxName);

    await _runStockMigration();
  }

  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ShopModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(WarehouseModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(StockBatchModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(StockMovementModelAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(InvoiceModelAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(InvoiceItemModelAdapter());
    }
  }

  /// VM tests only: avoids [Hive.initFlutter] / path_provider (not available in widget tests).
  static Future<void> initForTests() async {
    final dir = Directory.systemTemp.createTempSync('billing_hive_test_');
    Hive.init(dir.path);
    _registerAdapters();
    await Hive.openBox<ProductModel>(productBoxName);
    await Hive.openBox<ShopModel>(shopBoxName);
    await Hive.openBox(settingsBoxName);
    await Hive.openBox<WarehouseModel>(warehouseBoxName);
    await Hive.openBox<StockBatchModel>(stockBatchBoxName);
    await Hive.openBox<StockMovementModel>(stockMovementBoxName);
    await Hive.openBox<InvoiceModel>(invoiceBoxName);
    await _runStockMigration();
  }

  static Future<void> _runStockMigration() async {
    final warehouseBox = Hive.box<WarehouseModel>(warehouseBoxName);
    final productBox = Hive.box<ProductModel>(productBoxName);
    final batchBox = Hive.box<StockBatchModel>(stockBatchBoxName);

    String defaultWarehouseId;
    if (warehouseBox.isEmpty) {
      defaultWarehouseId = const Uuid().v4();
      await warehouseBox.put(
        defaultWarehouseId,
        WarehouseModel(
          id: defaultWarehouseId,
          name: 'Kho chính',
          location: null,
        ),
      );
    } else {
      defaultWarehouseId = warehouseBox.values.first.id;
    }

    if (batchBox.isEmpty) {
      final now = dateOnly(DateTime.now());
      for (final p in productBox.values) {
        if (p.stock <= 0) continue;
        final bid = const Uuid().v4();
        await batchBox.put(
          bid,
          StockBatchModel(
            id: bid,
            productId: p.id,
            warehouseId: defaultWarehouseId,
            importDate: now,
            quantity: p.stock,
            importPrice: 0,
            supplierName: null,
            expiryDate: null,
          ),
        );
      }
    }
  }

  static Box<ProductModel> get productBox =>
      Hive.box<ProductModel>(productBoxName);
  static Box<ShopModel> get shopBox => Hive.box<ShopModel>(shopBoxName);
  static Box get settingsBox => Hive.box(settingsBoxName);
  static Box<WarehouseModel> get warehouseBox =>
      Hive.box<WarehouseModel>(warehouseBoxName);
  static Box<StockBatchModel> get stockBatchBox =>
      Hive.box<StockBatchModel>(stockBatchBoxName);
  static Box<StockMovementModel> get stockMovementBox =>
      Hive.box<StockMovementModel>(stockMovementBoxName);
  static Box<InvoiceModel> get invoiceBox =>
      Hive.box<InvoiceModel>(invoiceBoxName);
}
