import 'package:get_it/get_it.dart';

import '../features/customer/data/repositories/customer_repository_impl.dart';
import '../features/customer/domain/repositories/customer_repository.dart';
import '../features/customer/domain/usecases/customer_usecases.dart';
import '../features/customer/presentation/bloc/customer_bloc.dart';
import '../features/invoice/data/repositories/invoice_repository_impl.dart';
import '../features/invoice/domain/repositories/invoice_repository.dart';
import '../features/invoice/domain/usecases/invoice_usecases.dart';
import '../features/invoice/presentation/bloc/invoice_bloc.dart';
import '../features/product/data/repositories/product_repository_impl.dart';
import '../features/product/domain/repositories/product_repository.dart';
import '../features/product/domain/usecases/product_usecases.dart';
import '../features/product/presentation/bloc/product_bloc.dart';
import '../features/settings/data/repositories/printer_repository_impl.dart';
import '../features/settings/domain/repositories/printer_repository.dart';
import '../features/settings/presentation/bloc/printer_bloc.dart';
import '../features/shop/data/repositories/shop_repository_impl.dart';
import '../features/shop/domain/repositories/shop_repository.dart';
import '../features/shop/domain/usecases/shop_usecases.dart';
import '../features/shop/presentation/bloc/shop_bloc.dart';
import '../features/stock/data/repositories/stock_repository_impl.dart';
import '../features/stock/domain/repositories/stock_repository.dart';
import '../features/stock/domain/usecases/stock_usecases.dart';
import '../features/stock/presentation/bloc/stock_bloc.dart';
import '../features/warehouse/data/repositories/warehouse_repository_impl.dart';
import '../features/warehouse/domain/repositories/warehouse_repository.dart';
import '../features/warehouse/domain/usecases/warehouse_usecases.dart';
import '../features/warehouse/presentation/bloc/warehouse_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Repositories (order: Stock before Invoice)
  sl.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl());
  sl.registerLazySingleton<ShopRepository>(() => ShopRepositoryImpl());
  sl.registerLazySingleton<PrinterRepository>(() => PrinterRepositoryImpl());
  sl.registerLazySingleton<WarehouseRepository>(
      () => WarehouseRepositoryImpl());
  sl.registerLazySingleton<StockRepository>(() => StockRepositoryImpl());
  sl.registerLazySingleton<InvoiceRepository>(
      () => InvoiceRepositoryImpl(sl()));
  sl.registerLazySingleton<CustomerRepository>(() => CustomerRepositoryImpl());

  // Product use cases
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => AddProductUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProductUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProductUseCase(sl()));
  sl.registerLazySingleton(() => GetProductByBarcodeUseCase(sl()));

  // Shop use cases
  sl.registerLazySingleton(() => GetShopUseCase(sl()));
  sl.registerLazySingleton(() => UpdateShopUseCase(sl()));

  // Warehouse use cases
  sl.registerLazySingleton(() => GetWarehousesUseCase(sl()));
  sl.registerLazySingleton(() => EnsureDefaultWarehouseUseCase(sl()));
  sl.registerLazySingleton(() => AddWarehouseUseCase(sl()));
  sl.registerLazySingleton(() => UpdateWarehouseUseCase(sl()));
  sl.registerLazySingleton(() => DeleteWarehouseUseCase(sl()));
  sl.registerLazySingleton(
      () => CountActiveBatchesInWarehouseUseCase(sl()));
  sl.registerLazySingleton(
      () => CountDistinctProductsWithBatchesInWarehouseUseCase(sl()));

  // Stock use cases
  sl.registerLazySingleton(() => ImportStockUseCase(sl()));
  sl.registerLazySingleton(() => ListBatchesByProductUseCase(sl()));
  sl.registerLazySingleton(() => ListBatchesByWarehouseUseCase(sl()));
  sl.registerLazySingleton(() => ListExpiringBatchesUseCase(sl()));
  sl.registerLazySingleton(() => GetTotalStockUseCase(sl()));
  sl.registerLazySingleton(() => GetTotalStockMapUseCase(sl()));
  sl.registerLazySingleton(() => ListMovementsUseCase(sl()));
  sl.registerLazySingleton(() => DistinctSupplierNamesUseCase(sl()));

  // Invoice use cases
  sl.registerLazySingleton(() => CreateDraftInvoiceUseCase(sl()));
  sl.registerLazySingleton(() => SetInvoiceCustomerUseCase(sl()));
  sl.registerLazySingleton(() => GetInvoiceUseCase(sl()));
  sl.registerLazySingleton(() => AddOrIncrementInvoiceItemUseCase(sl()));
  sl.registerLazySingleton(() => UpdateInvoiceItemQuantityUseCase(sl()));
  sl.registerLazySingleton(() => RemoveInvoiceItemUseCase(sl()));
  sl.registerLazySingleton(() => ConfirmInvoiceUseCase(sl()));
  sl.registerLazySingleton(() => CancelDraftInvoiceUseCase(sl()));
  sl.registerLazySingleton(() => ListDraftInvoicesUseCase(sl()));
  sl.registerLazySingleton(() => ListConfirmedInvoicesUseCase(sl()));
  sl.registerLazySingleton(() => ListInvoicesByCustomerUseCase(sl()));

  // Customer use cases
  sl.registerLazySingleton(() => GetCustomersUseCase(sl()));
  sl.registerLazySingleton(() => AddCustomerUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCustomerUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCustomerUseCase(sl()));

  // Blocs
  sl.registerFactory(
    () => ProductBloc(
      getProductsUseCase: sl(),
      addProductUseCase: sl(),
      updateProductUseCase: sl(),
      deleteProductUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ShopBloc(
      getShopUseCase: sl(),
      updateShopUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => PrinterBloc(repository: sl()),
  );

  sl.registerFactory(
    () => WarehouseBloc(
      getWarehousesUseCase: sl(),
      addWarehouseUseCase: sl(),
      updateWarehouseUseCase: sl(),
      deleteWarehouseUseCase: sl(),
      countActiveBatchesInWarehouseUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => StockBloc(
      listBatchesByProductUseCase: sl(),
      listBatchesByWarehouseUseCase: sl(),
      listMovementsUseCase: sl(),
      importStockUseCase: sl(),
      getTotalStockMapUseCase: sl(),
      listExpiringBatchesUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => InvoiceBloc(
      listDraftInvoicesUseCase: sl(),
      listConfirmedInvoicesUseCase: sl(),
      cancelDraftInvoiceUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => CustomerBloc(
      getCustomersUseCase: sl(),
      addCustomerUseCase: sl(),
      updateCustomerUseCase: sl(),
      deleteCustomerUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => CustomerInvoiceHistoryBloc(
      listInvoicesByCustomerUseCase: sl(),
    ),
  );
}
