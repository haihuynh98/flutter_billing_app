# Changelog

## 1.1.0 — 2026-05-05

### Features

- **Invoice numbering**: Sequential `sequenceNumber` per invoice (draft and confirmed), shown as “Đơn #N” in home, checkout, history, and detail; assigned on draft create with backfill for legacy drafts without a number.
- **Shop / receipt branding**: Editable invoice title, code prefix (`invoiceCodePrefix`), seller/buyer labels, signature note, optional **logo** (image picker, stored path); all flow into **Bluetooth thermal receipt** and PDF-style export.
- **Thermal receipt** (`PrinterHelper`): Expanded receipt layout—logo bitmap when set, invoice code line, formatted totals, Vietnamese text encoding improvements (charset / ESC-POS setup).
- **Share invoice image**: From checkout and invoice detail—render receipt-style preview, save via **Gal** (where supported), share image via **share_plus**.
- **Money display**: Central `formatMoney()` (`money_format.dart`) for thousands grouping (whole đồng) across billing, products, stock, warehouse, and invoices.
- **Settings**: App **version and build** from `package_info_plus` on the settings screen.

### Platform & assets

- Updated **Android**, **iOS** (including CocoaPods `Podfile.lock`), and **web** app icons and favicon / PWA icons for Tiger Retail branding.

### Dependencies

- Added: `path_provider`, `share_plus`, `gal`, `image_picker`, `package_info_plus`.

## 1.0.0 — 2026-05-02

First stable release of the offline POS / billing app (`billing_app`).

### Included

- Product catalog (CRUD, barcode) stored locally with Hive
- Shop profile for receipt header
- Home flow: camera barcode scan, cart, checkout
- Bluetooth thermal receipt printing (`print_bluetooth_thermal`)
- Settings for printer pairing and persistence

### Technical

- State: `flutter_bloc`; navigation: `go_router`; DI: `get_it`
- Widget smoke test with in-memory Hive (`HiveDatabase.initForTests`)
