import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../features/invoices/domain/entities/invoice_status.dart';
import '../../features/quotes/domain/entities/quote_status.dart';

part 'database.g.dart';

@DataClassName('ClientData')
class Clients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get addressName => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DataClassName('InvoiceData')
class Invoices extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clientId => integer().references(Clients, #id)();
  IntColumn get projectId => integer().nullable().references(
    Projects,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get saleId => integer().nullable().references(
    Sales,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get invoiceNumber => text().withLength(min: 1, max: 20)();
  IntColumn get status => intEnum<InvoiceStatus>()();
  DateTimeColumn get issueDate => dateTime()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get lastReminderAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  RealColumn get subtotal => real().withDefault(const Constant(0.0))();
  RealColumn get taxRate => real().withDefault(const Constant(0.0))();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  RealColumn get total => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DataClassName('ProjectData')
class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clientId => integer().nullable().references(
    Clients,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get siteAddress => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('planned'))();
  TextColumn get description => text().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DataClassName('ExpenseTypeData')
class ExpenseTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DataClassName('ProjectExpenseData')
class ProjectExpenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer().nullable().references(
    Projects,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get expenseTypeId => integer().nullable().references(
    ExpenseTypes,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get label => text().withLength(min: 1, max: 160)();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get supplier => text().nullable()();
  TextColumn get paymentMethod => text().nullable()();
  TextColumn get receiptPath => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DataClassName('InvoiceItemData')
class InvoiceItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get invoiceId =>
      integer().references(Invoices, #id, onDelete: KeyAction.cascade)();
  TextColumn get description => text()();
  RealColumn get quantity => real().withDefault(const Constant(1.0))();
  RealColumn get unitPrice => real().withDefault(const Constant(0.0))();
  RealColumn get amount => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DataClassName('QuoteData')
class Quotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clientId => integer().references(Clients, #id)();
  IntColumn get projectId => integer().nullable().references(
    Projects,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get quoteNumber => text().withLength(min: 1, max: 24)();
  IntColumn get status => intEnum<QuoteStatus>()();
  DateTimeColumn get issueDate => dateTime()();
  DateTimeColumn get validUntil => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get approvalName => text().nullable()();
  DateTimeColumn get approvedAt => dateTime().nullable()();
  RealColumn get subtotal => real().withDefault(const Constant(0.0))();
  RealColumn get taxRate => real().withDefault(const Constant(0.0))();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  RealColumn get total => real().withDefault(const Constant(0.0))();
  IntColumn get convertedInvoiceId => integer().nullable().references(
    Invoices,
    #id,
    onDelete: KeyAction.setNull,
  )();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DataClassName('QuoteItemData')
class QuoteItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get quoteId =>
      integer().references(Quotes, #id, onDelete: KeyAction.cascade)();
  TextColumn get description => text()();
  RealColumn get quantity => real().withDefault(const Constant(1.0))();
  RealColumn get unitPrice => real().withDefault(const Constant(0.0))();
  RealColumn get amount => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

class BusinessSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get companyName => text().withLength(min: 1, max: 100)();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get website => text().nullable()();
  TextColumn get logoPath => text().nullable()(); // path to logo image file
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('PaymentData')
class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get invoiceId =>
      integer().references(Invoices, #id, onDelete: KeyAction.cascade)();
  IntColumn get clientId =>
      integer().references(Clients, #id, onDelete: KeyAction.cascade)();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get method => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

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

@DataClassName('WarehouseData')
class Warehouses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get type => text()(); // depot, truck
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

@DataClassName('RefundData')
class Refunds extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get invoiceId =>
      integer().references(Invoices, #id, onDelete: KeyAction.cascade)();
  TextColumn get refundNumber => text().withLength(min: 1, max: 20)();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get reason => text().nullable()();
  RealColumn get totalAmount => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isValidated => boolean().withDefault(const Constant(false))();
}

@DataClassName('RefundItemData')
class RefundItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get refundId =>
      integer().references(Refunds, #id, onDelete: KeyAction.cascade)();
  IntColumn get invoiceItemId =>
      integer().references(InvoiceItems, #id, onDelete: KeyAction.cascade)();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();
  RealColumn get amount => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DataClassName('UserPreferenceData')
class UserPreferences extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get language => text().withDefault(const Constant('en'))();
  TextColumn get themeMode =>
      text().withDefault(const Constant('system'))(); // light, dark, system
}

@DataClassName('ProjectPhotoData')
class ProjectPhotos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId =>
      integer().references(Projects, #id, onDelete: KeyAction.cascade)();
  TextColumn get imagePath => text()();
  TextColumn get category => text()(); // before, during, after
  TextColumn get comment => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

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

@DriftDatabase(
  tables: [
    Clients,
    Projects,
    Invoices,
    InvoiceItems,
    Quotes,
    QuoteItems,
    BusinessSettings,
    Payments,
    Articles,
    Warehouses,
    Suppliers,
    StockMovements,
    Purchases,
    PurchaseItems,
    StockTransfers,
    StockTransferItems,
    Sales,
    SaleItems,
    SalePayments,
    SaleReturns,
    SaleReturnItems,
    ExpenseTypes,
    ProjectExpenses,
    Refunds,
    RefundItems,
    UserPreferences,
    ProjectPhotos,
    DeliveryRoutes,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 25;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedDefaultExpenseTypes();
      await _seedDefaultWarehouses();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await _createTableIfMissing(m, businessSettings);
      }
      if (from < 3) {
        await _addColumnIfMissing(
          m,
          businessSettings.actualTableName,
          businessSettings.logoPath,
        );
      }
      if (from < 4) {
        await _createTableIfMissing(m, payments);
      }
      if (from < 5) {
        await _createTableIfMissing(m, articles);
      }
      if (from < 6) {
        // Added type column to Articles in v6
        await _addColumnIfMissing(m, articles.actualTableName, articles.type);
      }
      if (from < 7) {
        await _createTableIfMissing(m, projects);
        await _createTableIfMissing(m, expenseTypes);
        await _createTableIfMissing(m, projectExpenses);
        await _addColumnIfMissing(
          m,
          invoices.actualTableName,
          invoices.projectId,
        );
        await _seedDefaultExpenseTypes();
      }
      if (from < 8) {
        await _addColumnIfMissing(
          m,
          projects.actualTableName,
          projects.clientId,
        );
      }
      if (from < 9) {
        await _createTableIfMissing(m, quotes);
        await _createTableIfMissing(m, quoteItems);
        await _addColumnIfMissing(
          m,
          articles.actualTableName,
          articles.category,
        );
        await _addColumnIfMissing(
          m,
          articles.actualTableName,
          articles.taxRate,
        );
        await _addColumnIfMissing(
          m,
          articles.actualTableName,
          articles.marginRate,
        );
      }
      if (from < 10) {
        await _addColumnIfMissing(
          m,
          projects.actualTableName,
          projects.siteAddress,
        );
        await _addColumnIfMissing(m, projects.actualTableName, projects.status);
        await _addColumnIfMissing(
          m,
          invoices.actualTableName,
          invoices.lastReminderAt,
        );
      }
      if (from < 11) {
        final needsExpenseRebuild =
            await _tableExists(projectExpenses.actualTableName) &&
            !await _columnExists(
              projectExpenses.actualTableName,
              projectExpenses.supplier.name,
            );
        if (needsExpenseRebuild) {
          await customStatement(
            'ALTER TABLE project_expenses RENAME TO project_expenses_old',
          );
          await _createTableIfMissing(m, projectExpenses);
          await customStatement('''
            INSERT INTO project_expenses
              (id, project_id, expense_type_id, label, amount, date, supplier, payment_method, receipt_path, notes)
            SELECT id, project_id, expense_type_id, label, amount, date, NULL, NULL, NULL, notes
            FROM project_expenses_old
          ''');
          await customStatement('DROP TABLE project_expenses_old');
        } else {
          await _createTableIfMissing(m, projectExpenses);
        }
      }
      if (from < 12) {
        await _addColumnIfMissing(
          m,
          articles.actualTableName,
          articles.quickTemplate,
        );
        await _addColumnIfMissing(
          m,
          articles.actualTableName,
          articles.defaultQuantity,
        );
        await _addColumnIfMissing(
          m,
          articles.actualTableName,
          articles.quickTemplateOrder,
        );
      }
      if (from < 13) {
        await _createTableIfMissing(m, refunds);
        await _createTableIfMissing(m, refundItems);
      }
      if (from < 14) {
        await _createTableIfMissing(m, userPreferences);
      }
      if (from < 15) {
        await _createTableIfMissing(m, projectPhotos);
      }
      if (from < 16) {
        await _addColumnIfMissing(
          m,
          articles.actualTableName,
          articles.salePrice,
        );
        await _addColumnIfMissing(
          m,
          articles.actualTableName,
          articles.purchasePrice,
        );
        await _createTableIfMissing(m, stockMovements);
      }
      if (from < 17) {
        await _createTableIfMissing(m, purchases);
        await _createTableIfMissing(m, purchaseItems);
      }
      if (from < 18) {
        await _createTableIfMissing(m, warehouses);
        await _addColumnIfMissing(
          m,
          stockMovements.actualTableName,
          stockMovements.warehouseId,
        );
      }
      if (from < 19) {
        await _createTableIfMissing(m, stockTransfers);
        await _createTableIfMissing(m, stockTransferItems);
      }
      if (from < 20) {
        await _createTableIfMissing(m, sales);
        await _createTableIfMissing(m, saleItems);
        await _createTableIfMissing(m, salePayments);
        await _createTableIfMissing(m, saleReturns);
        await _createTableIfMissing(m, saleReturnItems);
      }
      if (from < 21) {
        await _createTableIfMissing(m, suppliers);

        await _addColumnIfMissing(m, invoices.actualTableName, invoices.saleId);

        await _addColumnIfMissing(
          m,
          articles.actualTableName,
          articles.barcode,
        );
        await _addColumnIfMissing(
          m,
          articles.actualTableName,
          articles.minStock,
        );
        await _addColumnIfMissing(
          m,
          articles.actualTableName,
          articles.isActive,
        );

        await _addColumnIfMissing(
          m,
          purchases.actualTableName,
          purchases.status,
        );
        await _addColumnIfMissing(
          m,
          purchases.actualTableName,
          purchases.confirmedAt,
        );
        await _addColumnIfMissing(
          m,
          stockTransfers.actualTableName,
          stockTransfers.status,
        );
        await _addColumnIfMissing(
          m,
          stockTransfers.actualTableName,
          stockTransfers.confirmedAt,
        );

        await _addAuditColumnsIfMissing(
          m,
          clients.actualTableName,
          updatedAt: clients.updatedAt,
          deletedAt: clients.deletedAt,
        );
        await _addAuditColumnsIfMissing(
          m,
          invoices.actualTableName,
          deletedAt: invoices.deletedAt,
        );
        await _addAuditColumnsIfMissing(
          m,
          projects.actualTableName,
          updatedAt: projects.updatedAt,
          deletedAt: projects.deletedAt,
        );
        await _addAuditColumnsIfMissing(
          m,
          quotes.actualTableName,
          deletedAt: quotes.deletedAt,
        );
        await _addAuditColumnsIfMissing(
          m,
          expenseTypes.actualTableName,
          updatedAt: expenseTypes.updatedAt,
          deletedAt: expenseTypes.deletedAt,
        );
        await _addAuditColumnsIfMissing(
          m,
          projectExpenses.actualTableName,
          createdAt: projectExpenses.createdAt,
          updatedAt: projectExpenses.updatedAt,
          deletedAt: projectExpenses.deletedAt,
        );
        await _addAuditColumnsIfMissing(
          m,
          invoiceItems.actualTableName,
          createdAt: invoiceItems.createdAt,
          updatedAt: invoiceItems.updatedAt,
          deletedAt: invoiceItems.deletedAt,
        );
        await _addAuditColumnsIfMissing(
          m,
          quoteItems.actualTableName,
          createdAt: quoteItems.createdAt,
          updatedAt: quoteItems.updatedAt,
          deletedAt: quoteItems.deletedAt,
        );
        await _addColumnIfMissing(
          m,
          businessSettings.actualTableName,
          businessSettings.updatedAt,
        );
        await _addAuditColumnsIfMissing(
          m,
          payments.actualTableName,
          createdAt: payments.createdAt,
          updatedAt: payments.updatedAt,
          deletedAt: payments.deletedAt,
        );
        await _addAuditColumnsIfMissing(
          m,
          articles.actualTableName,
          updatedAt: articles.updatedAt,
          deletedAt: articles.deletedAt,
        );
        await _addAuditColumnsIfMissing(
          m,
          stockMovements.actualTableName,
          updatedAt: stockMovements.updatedAt,
          deletedAt: stockMovements.deletedAt,
        );
        await _addAuditColumnsIfMissing(
          m,
          warehouses.actualTableName,
          createdAt: warehouses.createdAt,
          updatedAt: warehouses.updatedAt,
          deletedAt: warehouses.deletedAt,
        );
        await _addAuditColumnsIfMissing(
          m,
          purchases.actualTableName,
          createdAt: purchases.createdAt,
          updatedAt: purchases.updatedAt,
          deletedAt: purchases.deletedAt,
        );
        await _addAuditColumnsIfMissing(
          m,
          purchaseItems.actualTableName,
          createdAt: purchaseItems.createdAt,
          updatedAt: purchaseItems.updatedAt,
          deletedAt: purchaseItems.deletedAt,
        );
        await _addAuditColumnsIfMissing(
          m,
          stockTransfers.actualTableName,
          createdAt: stockTransfers.createdAt,
          updatedAt: stockTransfers.updatedAt,
          deletedAt: stockTransfers.deletedAt,
        );
        await _addAuditColumnsIfMissing(
          m,
          stockTransferItems.actualTableName,
          createdAt: stockTransferItems.createdAt,
          updatedAt: stockTransferItems.updatedAt,
          deletedAt: stockTransferItems.deletedAt,
        );
        await _addAuditColumnsIfMissing(
          m,
          sales.actualTableName,
          updatedAt: sales.updatedAt,
          deletedAt: sales.deletedAt,
        );
        await _addAuditColumnsIfMissing(
          m,
          saleItems.actualTableName,
          createdAt: saleItems.createdAt,
          updatedAt: saleItems.updatedAt,
          deletedAt: saleItems.deletedAt,
        );
        await _addAuditColumnsIfMissing(
          m,
          salePayments.actualTableName,
          createdAt: salePayments.createdAt,
          updatedAt: salePayments.updatedAt,
          deletedAt: salePayments.deletedAt,
        );
        await _addAuditColumnsIfMissing(
          m,
          saleReturns.actualTableName,
          updatedAt: saleReturns.updatedAt,
          deletedAt: saleReturns.deletedAt,
        );
        await _addAuditColumnsIfMissing(
          m,
          saleReturnItems.actualTableName,
          createdAt: saleReturnItems.createdAt,
          updatedAt: saleReturnItems.updatedAt,
          deletedAt: saleReturnItems.deletedAt,
        );
        await _addAuditColumnsIfMissing(
          m,
          refunds.actualTableName,
          updatedAt: refunds.updatedAt,
          deletedAt: refunds.deletedAt,
        );
        await _addAuditColumnsIfMissing(
          m,
          refundItems.actualTableName,
          createdAt: refundItems.createdAt,
          updatedAt: refundItems.updatedAt,
          deletedAt: refundItems.deletedAt,
        );
      }
      if (from < 22) {
        await _addColumnIfMissing(
          m,
          saleReturns.actualTableName,
          saleReturns.status,
        );
        await _addColumnIfMissing(
          m,
          saleReturns.actualTableName,
          saleReturns.confirmedAt,
        );
      }
      if (from < 23) {
        await _addColumnIfMissing(
          m,
          clients.actualTableName,
          clients.addressName,
        );
        await _addColumnIfMissing(
          m,
          clients.actualTableName,
          clients.latitude,
        );
        await _addColumnIfMissing(
          m,
          clients.actualTableName,
          clients.longitude,
        );
      }
      if (from < 24) {
        await _createTableIfMissing(m, deliveryRoutes);
        await _addColumnIfMissing(m, sales.actualTableName, sales.routeId);
        await _addColumnIfMissing(m, stockTransfers.actualTableName, stockTransfers.routeId);
        await _addColumnIfMissing(m, salePayments.actualTableName, salePayments.routeId);
        await _addColumnIfMissing(m, saleReturns.actualTableName, saleReturns.routeId);
      }
      if (from < 25) {
        await _addColumnIfMissing(m, deliveryRoutes.actualTableName, deliveryRoutes.routeNumber);
        await _addColumnIfMissing(m, deliveryRoutes.actualTableName, deliveryRoutes.depotWarehouseId);
        await _addColumnIfMissing(m, deliveryRoutes.actualTableName, deliveryRoutes.truckWarehouseId);
        await _addColumnIfMissing(m, deliveryRoutes.actualTableName, deliveryRoutes.openedAt);
        await _addColumnIfMissing(m, deliveryRoutes.actualTableName, deliveryRoutes.updatedAt);
        await _addColumnIfMissing(m, deliveryRoutes.actualTableName, deliveryRoutes.deletedAt);

        await customStatement('''
          UPDATE delivery_routes
          SET truck_warehouse_id = warehouse_id,
              opened_at = created_at
          WHERE truck_warehouse_id IS NULL OR opened_at IS NULL
        ''');
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement(
        "UPDATE delivery_routes SET status = 'open' WHERE status = 'active'",
      );
      await _seedDefaultWarehouses();
    },
  );

  Future<void> _seedDefaultExpenseTypes() async {
    await batch((batch) {
      batch.insertAll(expenseTypes, [
        ExpenseTypesCompanion.insert(name: 'Materials'),
        ExpenseTypesCompanion.insert(name: 'Labor'),
        ExpenseTypesCompanion.insert(name: 'Transport'),
      ], mode: InsertMode.insertOrIgnore);
    });
  }

  Future<void> _seedDefaultWarehouses() async {
    await _insertWarehouseIfMissing(name: 'Depot principal', type: 'depot');
    await _insertWarehouseIfMissing(name: 'Camion 1', type: 'truck');
  }

  Future<void> _insertWarehouseIfMissing({
    required String name,
    required String type,
  }) async {
    if (!await _tableExists(warehouses.actualTableName)) return;

    final existing = await (select(
      warehouses,
    )..where((warehouse) => warehouse.name.equals(name))).getSingleOrNull();

    if (existing != null) return;

    await into(
      warehouses,
    ).insert(WarehousesCompanion.insert(name: name, type: type));
  }

  Future<void> _createTableIfMissing(Migrator m, TableInfo table) async {
    if (!await _tableExists(table.actualTableName)) {
      await m.createTable(table);
    }
  }

  Future<void> _addColumnIfMissing(
    Migrator m,
    String tableName,
    GeneratedColumn column,
  ) async {
    if (!await _tableExists(tableName)) return;
    if (!await _columnExists(tableName, column.name)) {
      if (_needsSqliteCompatibleTimestampDefault(column)) {
        await _addTimestampColumnWithConstantDefault(tableName, column.name);
        return;
      }
      await m.addColumn(_tableByName(tableName), column);
    }
  }

  bool _needsSqliteCompatibleTimestampDefault(GeneratedColumn column) {
    return column.name == 'created_at' || column.name == 'updated_at';
  }

  Future<void> _addTimestampColumnWithConstantDefault(
    String tableName,
    String columnName,
  ) async {
    final table = _escapeSqlIdentifier(tableName);
    final column = _escapeSqlIdentifier(columnName);
    final trigger = _escapeSqlIdentifier(
      '${tableName}_${columnName}_default_insert',
    );

    await customStatement(
      'ALTER TABLE $table ADD COLUMN $column INTEGER NOT NULL DEFAULT 0',
    );
    await customStatement('''
      UPDATE $table
      SET $column = CAST(strftime('%s', 'now') AS INTEGER)
      WHERE $column = 0
      ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS $trigger
      AFTER INSERT ON $table
      WHEN NEW.$column = 0
      BEGIN
        UPDATE $table
        SET $column = CAST(strftime('%s', 'now') AS INTEGER)
        WHERE rowid = NEW.rowid;
      END
      ''');
  }

  String _escapeSqlIdentifier(String identifier) {
    return '"${identifier.replaceAll('"', '""')}"';
  }

  Future<void> _addAuditColumnsIfMissing(
    Migrator m,
    String tableName, {
    GeneratedColumn? createdAt,
    GeneratedColumn? updatedAt,
    GeneratedColumn? deletedAt,
  }) async {
    if (createdAt != null) {
      await _addColumnIfMissing(m, tableName, createdAt);
    }
    if (updatedAt != null) {
      await _addColumnIfMissing(m, tableName, updatedAt);
    }
    if (deletedAt != null) {
      await _addColumnIfMissing(m, tableName, deletedAt);
    }
  }

  TableInfo _tableByName(String tableName) {
    return allTables.firstWhere((table) => table.actualTableName == tableName);
  }

  Future<bool> _tableExists(String tableName) async {
    final rows = await customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      variables: [Variable.withString(tableName)],
    ).get();
    return rows.isNotEmpty;
  }

  Future<bool> _columnExists(String tableName, String columnName) async {
    if (!await _tableExists(tableName)) return false;
    final escapedTable = tableName.replaceAll('"', '""');
    final rows = await customSelect('PRAGMA table_info("$escapedTable")').get();
    return rows.any((row) => row.data['name'] == columnName);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'invoice_manager.db'));
    return NativeDatabase.createInBackground(file);
  });
}
