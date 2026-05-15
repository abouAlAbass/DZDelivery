import 'package:drift/drift.dart';
import '../../../../core/database/database.dart' as db;
import '../../../clients/domain/entities/client.dart' as entity;
import '../../domain/entities/invoice.dart' as entity;
import '../../domain/entities/invoice_item.dart' as entity;
import '../../domain/entities/invoice_status.dart';
import '../../domain/repositories/invoice_repository.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final db.AppDatabase _database;

  InvoiceRepositoryImpl(this._database);

  @override
  Future<List<entity.Invoice>> getInvoices({
    InvoiceStatus? status,
    String? query,
  }) async {
    final statement = _database.select(_database.invoices).join([
      leftOuterJoin(
        _database.clients,
        _database.clients.id.equalsExp(_database.invoices.clientId),
      ),
      leftOuterJoin(
        _database.projects,
        _database.projects.id.equalsExp(_database.invoices.projectId),
      ),
    ])..orderBy([OrderingTerm.desc(_database.invoices.id)]);

    if (status != null) {
      statement.where(_database.invoices.status.equals(status.index));
    }

    if (query != null && query.isNotEmpty) {
      statement.where(
        _database.invoices.invoiceNumber.like('%$query%') |
            _database.clients.name.like('%$query%'),
      );
    }

    final rows = await statement.get();
    return Future.wait(
      rows.map((row) async {
        final invoiceRow = row.readTable(_database.invoices);
        final clientRow = row.readTableOrNull(_database.clients);
        final projectRow = row.readTableOrNull(_database.projects);
        final items = await _getInvoiceItems(invoiceRow.id);
        return _mapToEntity(invoiceRow, clientRow, projectRow, items);
      }),
    );
  }

  @override
  Stream<List<entity.Invoice>> watchInvoices({InvoiceStatus? status}) {
    final query = _database.select(_database.invoices).join([
      leftOuterJoin(
        _database.clients,
        _database.clients.id.equalsExp(_database.invoices.clientId),
      ),
      leftOuterJoin(
        _database.projects,
        _database.projects.id.equalsExp(_database.invoices.projectId),
      ),
    ])..orderBy([OrderingTerm.desc(_database.invoices.id)]);

    if (status != null) {
      query.where(_database.invoices.status.equals(status.index));
    }

    return query.watch().asyncMap(
      (rows) => Future.wait(
        rows.map((row) async {
          final invoiceRow = row.readTable(_database.invoices);
          final clientRow = row.readTableOrNull(_database.clients);
          final projectRow = row.readTableOrNull(_database.projects);
          final items = await _getInvoiceItems(invoiceRow.id);
          return _mapToEntity(invoiceRow, clientRow, projectRow, items);
        }),
      ),
    );
  }

  @override
  Future<entity.Invoice?> getInvoiceById(int id) async {
    final query = _database.select(_database.invoices).join([
      leftOuterJoin(
        _database.clients,
        _database.clients.id.equalsExp(_database.invoices.clientId),
      ),
      leftOuterJoin(
        _database.projects,
        _database.projects.id.equalsExp(_database.invoices.projectId),
      ),
    ])..where(_database.invoices.id.equals(id));

    final row = await query.getSingleOrNull();
    if (row == null) return null;

    final invoiceRow = row.readTable(_database.invoices);
    final clientRow = row.readTableOrNull(_database.clients);
    final projectRow = row.readTableOrNull(_database.projects);
    final items = await _getInvoiceItems(invoiceRow.id);
    return _mapToEntity(invoiceRow, clientRow, projectRow, items);
  }

  @override
  Future<int> createInvoice(entity.Invoice invoice) async {
    final invoiceToSave = invoice.recalculateTotals();
    return _database.transaction(() async {
      final invoiceId = await _database
          .into(_database.invoices)
          .insert(
            db.InvoicesCompanion.insert(
              clientId: invoiceToSave.clientId,
              projectId: Value(invoiceToSave.projectId),
              invoiceNumber: invoiceToSave.invoiceNumber,
              status: invoiceToSave.status,
              issueDate: invoiceToSave.issueDate,
              dueDate: Value(invoiceToSave.dueDate),
              lastReminderAt: Value(invoiceToSave.lastReminderAt),
              notes: Value(invoiceToSave.notes),
              subtotal: Value(invoiceToSave.subtotal),
              taxRate: Value(invoiceToSave.taxRate),
              discountAmount: Value(invoiceToSave.discountAmount),
              total: Value(invoiceToSave.total),
            ),
          );

      for (final item in invoiceToSave.items) {
        await _database
            .into(_database.invoiceItems)
            .insert(
              db.InvoiceItemsCompanion.insert(
                invoiceId: invoiceId,
                description: item.description,
                quantity: Value(item.quantity),
                unitPrice: Value(item.unitPrice),
                amount: Value(item.amount),
              ),
            );
      }

      return invoiceId;
    });
  }

  @override
  Future<void> updateInvoice(entity.Invoice invoice) async {
    final invoiceToUpdate = invoice.recalculateTotals();  
    return _database.transaction(() async {
      await _database
          .update(_database.invoices)
          .replace(
            db.InvoicesCompanion(
              id: Value(invoiceToUpdate.id!),
              clientId: Value(invoiceToUpdate.clientId),
              projectId: Value(invoiceToUpdate.projectId),
              invoiceNumber: Value(invoiceToUpdate.invoiceNumber),
              status: Value(invoiceToUpdate.status),
              issueDate: Value(invoiceToUpdate.issueDate),
              dueDate: Value(invoiceToUpdate.dueDate),
              lastReminderAt: Value(invoiceToUpdate.lastReminderAt),
              notes: Value(invoiceToUpdate.notes),
              subtotal: Value(invoiceToUpdate.subtotal),
              taxRate: Value(invoiceToUpdate.taxRate),
              discountAmount: Value(invoiceToUpdate.discountAmount),
              total: Value(invoiceToUpdate.total),
              updatedAt: Value(DateTime.now()),
            ),
          );

      await (_database.delete(
        _database.invoiceItems,
      )..where((t) => t.invoiceId.equals(invoiceToUpdate.id!))).go();

      for (final item in invoiceToUpdate.items) {
        await _database
            .into(_database.invoiceItems)
            .insert(
              db.InvoiceItemsCompanion.insert(
                invoiceId: invoiceToUpdate.id!,
                description: item.description,
                quantity: Value(item.quantity),
                unitPrice: Value(item.unitPrice),
                amount: Value(item.amount),
              ),
            );
      }
    });
  }

  @override
  Future<void> updateLastReminderAt(int invoiceId, DateTime date) {
    return (_database.update(
      _database.invoices,
    )..where((t) => t.id.equals(invoiceId))).write(
      db.InvoicesCompanion(
        lastReminderAt: Value(date),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteInvoice(int id) async {
    final payments = await (_database.select(_database.payments)
          ..where((t) => t.invoiceId.equals(id)))
        .get();

    if (payments.isNotEmpty) {
      throw Exception('HAS_PAYMENTS');
    }

    await (_database.delete(_database.invoices)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<String> generateNextInvoiceNumber() async {
    final query = _database.select(_database.invoices)
      ..orderBy([(t) => OrderingTerm.desc(t.id)])
      ..limit(1);
    final lastInvoice = await query.getSingleOrNull();

    if (lastInvoice == null) return 'INV-0001';

    final lastNumber =
        int.tryParse(lastInvoice.invoiceNumber.split('-').last) ?? 0;
    return 'INV-${(lastNumber + 1).toString().padLeft(4, '0')}';
  }

  Future<List<entity.InvoiceItem>> _getInvoiceItems(int invoiceId) async {
    final rows = await (_database.select(
      _database.invoiceItems,
    )..where((t) => t.invoiceId.equals(invoiceId))).get();
    return rows
        .map(
          (row) => entity.InvoiceItem(
            id: row.id,
            invoiceId: row.invoiceId,
            description: row.description,
            quantity: row.quantity,
            unitPrice: row.unitPrice,
            amount: row.amount,
          ),
        )
        .toList();
  }

  entity.Invoice _mapToEntity(
    db.InvoiceData invoiceRow,
    db.ClientData? clientRow,
    db.ProjectData? projectRow,
    List<entity.InvoiceItem> items,
  ) {
    return entity.Invoice(
      id: invoiceRow.id,
      clientId: invoiceRow.clientId,
      projectId: invoiceRow.projectId,
      invoiceNumber: invoiceRow.invoiceNumber,
      status: invoiceRow.status,
      issueDate: invoiceRow.issueDate,
      dueDate: invoiceRow.dueDate,
      lastReminderAt: invoiceRow.lastReminderAt,
      notes: invoiceRow.notes,
      subtotal: invoiceRow.subtotal,
      taxRate: invoiceRow.taxRate,
      discountAmount: invoiceRow.discountAmount,
      total: invoiceRow.total,
      createdAt: invoiceRow.createdAt,
      updatedAt: invoiceRow.updatedAt,
      items: items,
      projectName: projectRow?.name,
      client: clientRow != null
          ? entity.Client(
              id: clientRow.id,
              name: clientRow.name,
              email: clientRow.email,
              phone: clientRow.phone,
              address: clientRow.address,
            )
          : null,
    );
  }
}
