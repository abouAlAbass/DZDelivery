import 'package:drift/drift.dart';
import 'clients_tables.dart';
import 'articles_tables.dart';

@DataClassName('DeliveryRouteData')
class DeliveryRoutes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get warehouseId =>
      integer().references(Warehouses, #id, onDelete: KeyAction.restrict)();
  
  TextColumn get routeNumber => text().nullable()();
  @ReferenceName('deliveryRoutesDepot')
  IntColumn get depotWarehouseId =>
      integer().nullable().references(Warehouses, #id, onDelete: KeyAction.restrict)();
  @ReferenceName('deliveryRoutesTruck')
  IntColumn get truckWarehouseId =>
      integer().nullable().references(Warehouses, #id, onDelete: KeyAction.restrict)();
  DateTimeColumn get openedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  DateTimeColumn get date => dateTime()();
  TextColumn get driverName => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('open'))(); // draft, open, closed, cancelled
  RealColumn get startKm => real().nullable()();
  RealColumn get endKm => real().nullable()();
  RealColumn get startCash => real().withDefault(const Constant(0.0))();
  RealColumn get endCash => real().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get closedAt => dateTime().nullable()();
}

@DataClassName('SaleData')
class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get saleNumber => text().withLength(min: 1, max: 24)();
  IntColumn get clientId => integer().nullable().references(
    Clients,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get warehouseId =>
      integer().references(Warehouses, #id, onDelete: KeyAction.restrict)();
  DateTimeColumn get date => dateTime()();
  RealColumn get subtotal => real().withDefault(const Constant(0.0))();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  RealColumn get total => real().withDefault(const Constant(0.0))();
  RealColumn get paidAmount => real().withDefault(const Constant(0.0))();
  TextColumn get paymentStatus =>
      text().withDefault(const Constant('unpaid'))();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get validatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get routeId => integer().nullable().references(
    DeliveryRoutes,
    #id,
    onDelete: KeyAction.setNull,
  )();
}

@DataClassName('SaleItemData')
class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId =>
      integer().references(Sales, #id, onDelete: KeyAction.cascade)();
  IntColumn get articleId =>
      integer().references(Articles, #id, onDelete: KeyAction.restrict)();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real().withDefault(const Constant(0.0))();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  RealColumn get total => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DataClassName('SalePaymentData')
class SalePayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId =>
      integer().references(Sales, #id, onDelete: KeyAction.cascade)();
  RealColumn get amount => real()();
  TextColumn get method => text()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
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

@DataClassName('SaleReturnData')
class SaleReturns extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId => integer().nullable().references(
    Sales,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get clientId => integer().nullable().references(
    Clients,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get warehouseId =>
      integer().references(Warehouses, #id, onDelete: KeyAction.restrict)();
  DateTimeColumn get date => dateTime()();
  RealColumn get total => real().withDefault(const Constant(0.0))();
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

@DataClassName('SaleReturnItemData')
class SaleReturnItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get returnId =>
      integer().references(SaleReturns, #id, onDelete: KeyAction.cascade)();
  IntColumn get articleId =>
      integer().references(Articles, #id, onDelete: KeyAction.restrict)();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real().withDefault(const Constant(0.0))();
  RealColumn get total => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}
