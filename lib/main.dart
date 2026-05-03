import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/routes/app_routes.dart';
import 'core/data/hive_database.dart';
import 'core/service_locator.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/billing/presentation/bloc/billing_bloc.dart';
import 'features/invoice/presentation/bloc/invoice_bloc.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/settings/presentation/bloc/printer_bloc.dart';
import 'features/settings/presentation/bloc/printer_event.dart';
import 'features/shop/presentation/bloc/shop_bloc.dart';
import 'features/stock/presentation/bloc/stock_bloc.dart';
import 'features/warehouse/presentation/bloc/warehouse_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveDatabase.init();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductBloc>(
            create: (context) => di.sl<ProductBloc>()..add(LoadProducts())),
        BlocProvider<ShopBloc>(
            create: (context) => di.sl<ShopBloc>()..add(LoadShopEvent())),
        BlocProvider<WarehouseBloc>(
          create: (context) =>
              di.sl<WarehouseBloc>()..add(const LoadWarehousesEvent()),
        ),
        BlocProvider<StockBloc>(
          create: (context) => di.sl<StockBloc>(),
        ),
        BlocProvider<InvoiceBloc>(
          create: (context) => di.sl<InvoiceBloc>(),
        ),
        BlocProvider<BillingBloc>(
          create: (context) => BillingBloc(
            getProductByBarcodeUseCase: di.sl(),
            createDraftInvoiceUseCase: di.sl(),
            getInvoiceUseCase: di.sl(),
            addOrIncrementInvoiceItemUseCase: di.sl(),
            updateInvoiceItemQuantityUseCase: di.sl(),
            removeInvoiceItemUseCase: di.sl(),
            confirmInvoiceUseCase: di.sl(),
            cancelDraftInvoiceUseCase: di.sl(),
            listBatchesByProductUseCase: di.sl(),
          ),
        ),
        BlocProvider<PrinterBloc>(
            create: (context) => di.sl<PrinterBloc>()..add(InitPrinterEvent())),
      ],
      child: MaterialApp.router(
        title: 'Ứng dụng tính tiền',
        theme: AppTheme.lightTheme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
