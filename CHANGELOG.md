# Changelog

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
