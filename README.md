# DZDelivery (Smart Delivery)

A Flutter application specialized in managing delivery routes, invoicing, quotes, and tracking stocks across main warehouses and delivery trucks.

---

## Core Features

- **Sales & POS Management:** Record quick sales, collect payments, and manage returns.
- **Delivery Routes:** Track driver routes, log start/end odometer readings, manage start/end cash, and generate daily delivery reports.
- **Inventory Control:** Manage multiple warehouses (e.g., main depot and delivery trucks) with real-time stock movements and stock transfers.
- **Invoices & Documents:** Generate, manage, and print PDF invoices, quotes, and refund notes.
- **Project Tracking:** Keep track of expenses by project and upload on-site photos.

---

## Database Architecture (Drift)

The local SQLite database uses **Drift**. The database schema has been modularized by business domains into separate files for better readability and maintainability:

- [`lib/core/database/tables/`](file:///c:/costructor/deliverydz/DZDelivery/lib/core/database/tables/)
  - `clients_tables.dart`: Client entity (`Clients`).
  - `projects_tables.dart`: Projects, expense types, project expenses, and project photos.
  - `invoices_tables.dart`: Invoices, invoice items, quotes, quote items, payments, refunds, and refund items.
  - `articles_tables.dart`: Articles, stock movements, warehouses, suppliers, purchases, purchase items, stock transfers, and stock transfer items.
  - `sales_tables.dart`: Sales, sale items, sale payments, sale returns, sale return items, and delivery routes (`DeliveryRoutes`).
  - `settings_tables.dart`: Business settings and user preferences.

The central database configuration and migration logic are defined in [`lib/core/database/database.dart`](file:///c:/costructor/deliverydz/DZDelivery/lib/core/database/database.dart).

---

## Developer Commands

### Code Generation (Drift & Riverpod)

This project relies on `build_runner` to generate boilerplate code (such as `database.g.dart`):

```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

### Running Unit Tests

To run the unit tests verifying inventory and delivery route business rules:

```powershell
flutter test
```
