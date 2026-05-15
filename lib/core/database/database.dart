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
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
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
}

@DataClassName('ExpenseTypeData')
class ExpenseTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
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
}

class BusinessSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get companyName => text().withLength(min: 1, max: 100)();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get website => text().nullable()();
  TextColumn get logoPath => text().nullable()(); // path to logo image file
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
}

@DataClassName('ArticleData')
class Articles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get code => text().nullable()();
  RealColumn get price => real().withDefault(const Constant(0.0))();
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
}

@DataClassName('UserPreferenceData')
class UserPreferences extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get language => text().withDefault(const Constant('en'))();
  TextColumn get themeMode => text().withDefault(const Constant('system'))(); // light, dark, system
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
    ExpenseTypes,
    ProjectExpenses,
    Refunds,
    RefundItems,
    UserPreferences,
    ProjectPhotos,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 15;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedDefaultExpenseTypes();
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
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
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
    if (!await _columnExists(tableName, column.name)) {
      await m.addColumn(_tableByName(tableName), column);
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
