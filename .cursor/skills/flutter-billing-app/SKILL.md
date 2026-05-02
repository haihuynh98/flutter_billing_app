---
name: flutter-billing-app
description: >-
  Flutter offline POS in this repo (Hive, Bloc, go_router, thermal printer).
  Use when editing billing_app, scanner, checkout, products, shop settings,
  or Bluetooth receipt printing.
disable-model-invocation: false
---

# flutter_billing_app

1. Read **AGENTS.md** at repository root first (structure, routes, DI, Hive, flows).
2. Follow existing patterns in `features/<feature>/{data,domain,presentation}/`.
3. After changing Hive or JSON models: `dart run build_runner build --delete-conflicting-outputs`.
4. Printer logic lives in `lib/core/utils/printer_helper.dart` and `features/settings/` (PrinterBloc).
