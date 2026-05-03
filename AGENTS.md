# Agent context: flutter_billing_app

Offline POS/billing Flutter app: product catalog, barcode scan, cart, checkout, Bluetooth thermal receipt. Package name: `billing_app`.

## Stack

| Area | Package |
|------|---------|
| State | `flutter_bloc`, `equatable` |
| DI | `get_it` (`lib/core/service_locator.dart`, alias `sl`) |
| Nav | `go_router` (`lib/config/routes/app_routes.dart`) |
| DB | `hive` / `hive_flutter` (`lib/core/data/hive_database.dart`) |
| Errors / FP | `fpdart` (`Either`, `Failure` in `lib/core/error/failure.dart`) |
| Models | `json_serializable` + Hive adapters (codegen) |
| Scan / print | `mobile_scanner`, `print_bluetooth_thermal` (see `lib/core/utils/printer_helper.dart`) |

## Boot sequence

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `HiveDatabase.init()` — register adapters (products, shop, warehouses, stock batches/movements, invoice + line items), open boxes, `_runStockMigration()` (default **Kho chính** + seed batches from legacy product stock)
3. `service_locator.init()` — register repos, use cases, blocs
4. `MultiBlocProvider`: `ProductBloc`, `ShopBloc`, `WarehouseBloc`, `StockBloc`, `InvoiceBloc`, `BillingBloc`, `PrinterBloc` (initial: load products, shop, warehouses, init printer)
5. `MaterialApp.router` + `router` from `app_routes.dart`

## Layout (`lib/`)

```
core/           theme, widgets, utils (printer_helper, validators), hive init, service_locator, usecase base, failure
config/routes/  go_router
features/
  billing/      scan UX, checkout, draft invoice lines in BillingBloc (pick warehouse batch), print
  product/      CRUD, list/add/edit, barcode in domain
  shop/         single shop profile for receipt header
  warehouse/    CRUD warehouses, default warehouse migration
  stock/        batches (import price, supplier, expiry), movements, import UI
  invoice/      draft → confirm (stock deduction), history/detail
  settings/     printer pairing / PrinterBloc, SettingsPage
```

Each feature: `data` (repos, models), `domain` (entities, repo interfaces, use cases), `presentation` (bloc, pages).

## Routes

| Path | Screen |
|------|--------|
| `/` | `HomePage` (scanner + cart entry) |
| `/scanner` | `ScannerPage` |
| `/checkout` | `CheckoutPage` |
| `/settings` | `SettingsPage` |
| `/products` | `ProductListPage` |
| `/products/add` | `AddProductPage` |
| `/products/edit/:id` | `EditProductPage` — expects `state.extra` as `Product` |
| `/products/:productId/import` | `ImportStockPage` |
| `/products/:productId/stock` | `ProductStockPage` |
| `/warehouses` | `WarehouseListPage` |
| `/warehouses/add` | `AddWarehousePage` |
| `/warehouses/edit/:id` | `EditWarehousePage` — `state.extra` optional `Warehouse` |
| `/warehouses/:id` | `WarehouseDetailPage` |
| `/warehouses/:id/import` | `ImportStockPage` (preset warehouse) |
| `/invoices` | `InvoiceHistoryPage` |
| `/invoices/:id` | `InvoiceDetailPage` — `state.extra` as `Invoice` |
| `/shop` | `ShopDetailsPage` |

## DI (`service_locator.dart`)

- **Factory**: `ProductBloc`, `ShopBloc`, `PrinterBloc`, `WarehouseBloc`, `StockBloc`, `InvoiceBloc`
- **Singletons**: product/shop/printer/warehouse/stock/invoice repos and their use cases
- **BillingBloc** is not in GetIt — constructed in `main.dart` with invoice + stock use cases (barcode, draft lines, confirm/cancel, list batches for pick)

## Hive

| Box | Type | Role |
|-----|------|------|
| `products` | `ProductModel` | catalog |
| `shop` | `ShopModel` | shop info on receipts |
| `settings` | untyped | key-value; e.g. `printer_mac` for receipt auto-connect |
| `warehouses` | `WarehouseModel` | warehouse master |
| `stock_batches` | `StockBatchModel` | qty per product/warehouse/lot (import price, supplier, expiry) |
| `stock_movements` | `StockMovementModel` | audit trail |
| `invoices` | `InvoiceModel` | draft/confirmed/cancelled POS invoices + lines |

## Main flows

1. **Catalog**: `ProductBloc` → `ProductRepository` → Hive `products` box.
2. **Shop profile**: `ShopBloc` → `shop` box.
3. **Billing / invoice lifecycle**: Scanner → draft invoice + pick batch when needed → line updates → checkout **confirm** runs `ConfirmInvoiceUseCase` (stock deduction) → `PrintReceiptEvent` uses persisted invoice lines; `PrinterHelper` + paired device from settings.
4. **Printer**: `PrinterBloc` + `PrinterRepository`; hardware via `print_bluetooth_thermal`.

## Conventions

- New feature code stays in `features/<name>/` with data/domain/presentation separation.
- Use cases extend/core-usecase pattern; repositories return `Either<Failure, T>` where used.
- Bloc states/events: `equatable`; UI may use Vietnamese strings — keep new identifiers and agent-facing docs in English.
- After changing `@HiveType` / `@JsonSerializable` models: `dart run build_runner build --delete-conflicting-outputs`.

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```
