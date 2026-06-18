import 'package:go_router/go_router.dart';

import '../../features/billing/presentation/pages/checkout_page.dart';
import '../../features/billing/presentation/pages/home_page.dart';
import '../../features/billing/presentation/pages/scanner_page.dart';
import '../../features/customer/domain/entities/customer.dart';
import '../../features/customer/presentation/pages/add_customer_page.dart';
import '../../features/customer/presentation/pages/customer_invoice_history_page.dart';
import '../../features/customer/presentation/pages/customer_list_page.dart';
import '../../features/customer/presentation/pages/edit_customer_page.dart';
import '../../features/invoice/domain/entities/invoice.dart';
import '../../features/invoice/presentation/pages/invoice_detail_page.dart';
import '../../features/invoice/presentation/pages/invoice_history_page.dart';
import '../../features/product/domain/entities/product.dart';
import '../../features/product/presentation/pages/add_product_page.dart';
import '../../features/product/presentation/pages/edit_product_page.dart';
import '../../features/product/presentation/pages/product_list_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/shop/presentation/pages/shop_details_page.dart';
import '../../features/stock/presentation/pages/import_stock_page.dart';
import '../../features/stock/presentation/pages/product_stock_page.dart';
import '../../features/warehouse/domain/entities/warehouse.dart';
import '../../features/warehouse/presentation/pages/add_warehouse_page.dart';
import '../../features/warehouse/presentation/pages/edit_warehouse_page.dart';
import '../../features/warehouse/presentation/pages/warehouse_detail_page.dart';
import '../../features/warehouse/presentation/pages/warehouse_list_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'scanner',
          builder: (context, state) => const ScannerPage(),
        ),
        GoRoute(
          path: 'checkout',
          builder: (context, state) => const CheckoutPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductListPage(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const AddProductPage(),
        ),
        GoRoute(
          path: 'edit/:id',
          builder: (context, state) {
            final product = state.extra as Product?;
            if (product == null) {
              return const ProductListPage();
            }
            return EditProductPage(product: product);
          },
        ),
        GoRoute(
          path: ':productId/import',
          builder: (context, state) {
            final productId = state.pathParameters['productId']!;
            final product = state.extra as Product?;
            return ImportStockPage(
              presetProductId: productId,
              presetProduct: product,
            );
          },
        ),
        GoRoute(
          path: ':productId/stock',
          builder: (context, state) {
            final productId = state.pathParameters['productId']!;
            return ProductStockPage(productId: productId);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/warehouses',
      builder: (context, state) => const WarehouseListPage(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const AddWarehousePage(),
        ),
        GoRoute(
          path: 'edit/:id',
          builder: (context, state) {
            final w = state.extra as Warehouse?;
            if (w == null) return const WarehouseListPage();
            return EditWarehousePage(warehouse: w);
          },
        ),
        GoRoute(
          path: ':id/import',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final w = state.extra as Warehouse?;
            return ImportStockPage(
              presetWarehouseId: id,
              presetWarehouse: w,
            );
          },
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final w = state.extra as Warehouse?;
            if (w == null) return const WarehouseListPage();
            return WarehouseDetailPage(warehouse: w);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/invoices',
      builder: (context, state) => const InvoiceHistoryPage(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final inv = state.extra as Invoice?;
            if (inv == null) return const InvoiceHistoryPage();
            return InvoiceDetailPage(invoice: inv);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/shop',
      builder: (context, state) => const ShopDetailsPage(),
    ),
    GoRoute(
      path: '/customers',
      builder: (context, state) => const CustomerListPage(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const AddCustomerPage(),
        ),
        GoRoute(
          path: 'edit/:id',
          builder: (context, state) {
            final c = state.extra as Customer?;
            if (c == null) return const CustomerListPage();
            return EditCustomerPage(customer: c);
          },
        ),
        GoRoute(
          path: 'retail/invoices',
          builder: (context, state) =>
              const CustomerInvoiceHistoryPage.retail(),
        ),
        GoRoute(
          path: ':id/invoices',
          builder: (context, state) {
            final c = state.extra as Customer?;
            if (c == null) return const CustomerListPage();
            return CustomerInvoiceHistoryPage(customer: c);
          },
        ),
      ],
    ),
  ],
);
