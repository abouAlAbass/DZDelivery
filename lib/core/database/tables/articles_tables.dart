import 'package:drift/drift.dart';
import 'sales_tables.dart';

@DataClassName('ArticleData')
class Articles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get code => text().nullable()();
  TextColumn get barcode => text().nullable()();
  RealColumn get price => real().withDefault(const Constant(0.0))();
  RealColumn get salePrice => real().withDefault(const Constant(0.0))();
  RealColumn get purchasePrice => real().withDefault(const Constant(0.0))();
  RealColumn get minStock => real().withDefault(const Constant(0.0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get unit => text()(); // kg, m2, m3, pieces
  TextColumn get type =>
      text().withDefault(const Constant('physical'))(); // physical, service
  TextColumn get category =>
      text().withDefault(const Constant('materials'))(); // labor, materials...
  RealColumn get taxRate => real().withDefault(const Constant(0.0))();
  RealColumn get marginRate => real().withDefault(const Constant(0.0))();
  TextColumn get quickTemplate => text().nullable()();
  RealColumn get defaultQuantity => real().withDefault(const Constant(1.0))();
  IntColumn get quickTemplateOrder =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DataClassName('WarehouseData')
class Warehouses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get type => text()(); // depot, truck
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DataClassName('StockMovementData')
class StockMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get articleId =>
      integer().references(Articles, #id, onDelete: KeyAction.cascade)();
  IntColumn get warehouseId => integer().nullable().references(
    Warehouses,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get type => text()();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real().withDefault(const Constant(0.0))();
  TextColumn get sourceType => text().nullable()();
  IntColumn get sourceId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DataClassName('SupplierData')
class Suppliers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DataClassName('PurchaseData')
class Purchases extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get supplierId => integer().nullable().references(
    Suppliers,
    #id,
    onDelete: KeyAction.setNull,
  )();
  DateTimeColumn get date => dateTime()();
  RealColumn get total => real().withDefault(const Constant(0.0))();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  DateTimeColumn get confirmedAt => dateTime().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DataClassName('PurchaseItemData')
class PurchaseItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get purchaseId =>
      integer().references(Purchases, #id, onDelete: KeyAction.cascade)();
  IntColumn get articleId =>
      integer().references(Articles, #id, onDelete: KeyAction.restrict)();
  RealColumn get quantity => real()();
  RealColumn get purchasePrice => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DataClassName('StockTransferData')
class StockTransfers extends Table {
  IntColumn get id => integer().autoIncrement()();
  @ReferenceName('outgoingTransfers')
  IntColumn get fromWarehouseId =>
      integer().references(Warehouses, #id, onDelete: KeyAction.restrict)();
  @ReferenceName('incomingTransfers')
  IntColumn get toWarehouseId =>
      integer().references(Warehouses, #id, onDelete: KeyAction.restrict)();
  DateTimeColumn get date => dateTime()();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  DateTimeColumn get confirmedAt => dateTime().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get routeId => integer().nullable().references(
    DeliveryRoutes,
    #id,
    onDelete: KeyAction.setNull,
  )();
}

@DataClassName('StockTransferItemData')
class StockTransferItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transferId =>
      integer().references(StockTransfers, #id, onDelete: KeyAction.cascade)();
  IntColumn get articleId =>
      integer().references(Articles, #id, onDelete: KeyAction.restrict)();
  RealColumn get quantity => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}
