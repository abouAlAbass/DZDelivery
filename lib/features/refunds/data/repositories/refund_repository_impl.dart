import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database.dart' as db;
import '../../../../core/database/database_provider.dart';
import '../../domain/entities/refund.dart';
import '../../domain/entities/refund_item.dart';
import '../../domain/repositories/refund_repository.dart';

class RefundRepositoryImpl implements RefundRepository {
  final db.AppDatabase _database;

  RefundRepositoryImpl(this._database);

  @override
  Future<int> createRefund(Refund refund) async {
    return _database.transaction(() async {
      final refundId = await _database.into(_database.refunds).insert(
            db.RefundsCompanion.insert(
              invoiceId: refund.invoiceId,
              refundNumber: refund.refundNumber,
              date: Value(refund.date),
              reason: Value(refund.reason),
              totalAmount: Value(refund.totalAmount),
              isValidated: Value(refund.isValidated),
            ),
          );

      for (final item in refund.items) {
        await _database.into(_database.refundItems).insert(
              db.RefundItemsCompanion.insert(
                refundId: refundId,
                invoiceItemId: item.invoiceItemId,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                amount: item.amount,
              ),
            );
      }

      return refundId;
    });
  }

  @override
  Future<Refund?> getRefundById(int id) async {
    final query = _database.select(_database.refunds)
      ..where((t) => t.id.equals(id));
    final refundRow = await query.getSingleOrNull();

    if (refundRow == null) return null;

    final items = await _getRefundItems(refundRow.id);
    return _mapToEntity(refundRow, items);
  }

  @override
  Future<List<Refund>> getRefundsByInvoiceId(int invoiceId) async {
    final query = _database.select(_database.refunds)
      ..where((t) => t.invoiceId.equals(invoiceId))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);

    final rows = await query.get();
    return Future.wait(rows.map((row) async {
      final items = await _getRefundItems(row.id);
      return _mapToEntity(row, items);
    }));
  }

  @override
  Future<List<Refund>> getRefundsByProjectId(int projectId) async {
    final query = _database.select(_database.refunds).join([
      innerJoin(_database.invoices,
          _database.invoices.id.equalsExp(_database.refunds.invoiceId))
    ])
      ..where(_database.invoices.projectId.equals(projectId))
      ..orderBy([OrderingTerm.desc(_database.refunds.date)]);

    final rows = await query.get();
    return Future.wait(rows.map((row) async {
      final refundRow = row.readTable(_database.refunds);
      final items = await _getRefundItems(refundRow.id);
      return _mapToEntity(refundRow, items);
    }));
  }
  @override
  Future<List<Refund>> getAllRefunds() async {
    final query = _database.select(_database.refunds)
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);

    final rows = await query.get();
    return Future.wait(rows.map((row) async {
      final items = await _getRefundItems(row.id);
      return _mapToEntity(row, items);
    }));
  }

  @override
  Future<double> getRefundedQuantityByInvoiceItemId(int invoiceItemId) async {
    final query = _database.select(_database.refundItems)
      ..where((t) => t.invoiceItemId.equals(invoiceItemId));
    final rows = await query.get();
    return rows.fold<double>(0.0, (sum, row) => sum + row.quantity);
  }

  @override
  Future<void> validateRefund(int refundId) {
    return (_database.update(_database.refunds)
          ..where((t) => t.id.equals(refundId)))
        .write(const db.RefundsCompanion(isValidated: Value(true)));
  }

  @override
  Future<String> generateNextRefundNumber() async {
    final query = _database.select(_database.refunds)
      ..orderBy([(t) => OrderingTerm.desc(t.id)])
      ..limit(1);
    final lastRefund = await query.getSingleOrNull();

    if (lastRefund == null) return 'AV-0001';

    final lastNumber =
        int.tryParse(lastRefund.refundNumber.split('-').last) ?? 0;
    return 'AV-${(lastNumber + 1).toString().padLeft(4, '0')}';
  }

  @override
  Future<double> calculateInvoiceNetAmount(int invoiceId) async {
    final query = _database.select(_database.invoices)
      ..where((t) => t.id.equals(invoiceId));
    final invoiceRow = await query.getSingleOrNull();
    if (invoiceRow == null) return 0;

    final refunds = await getRefundsByInvoiceId(invoiceId);
    final totalRefunded = refunds.fold(0.0, (sum, r) => sum + r.totalAmount);

    return invoiceRow.total - totalRefunded;
  }

  @override
  Future<double> calculateProjectProfitability(int projectId) async {
    // Profit = (Sum of Invoices - Sum of Refunds) - Sum of Expenses
    final invoices = await (_database.select(_database.invoices)
          ..where((t) => t.projectId.equals(projectId)))
        .get();
    final totalInvoiced = invoices.fold(0.0, (sum, i) => sum + i.total);

    final refundRows = await (_database.select(_database.refunds).join([
      innerJoin(_database.invoices,
          _database.invoices.id.equalsExp(_database.refunds.invoiceId))
    ])
          ..where(_database.invoices.projectId.equals(projectId)))
        .get();
    final totalRefunded = refundRows.fold(
        0.0, (sum, row) => sum + row.readTable(_database.refunds).totalAmount);

    final expenses = await (_database.select(_database.projectExpenses)
          ..where((t) => t.projectId.equals(projectId)))
        .get();
    final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);

    return (totalInvoiced - totalRefunded) - totalExpenses;
  }

  Future<List<RefundItem>> _getRefundItems(int refundId) async {
    final query = _database.select(_database.refundItems).join([
      leftOuterJoin(
          _database.invoiceItems,
          _database.invoiceItems.id
              .equalsExp(_database.refundItems.invoiceItemId))
    ])
      ..where(_database.refundItems.refundId.equals(refundId));

    final rows = await query.get();
    return rows.map((row) {
      final itemRow = row.readTable(_database.refundItems);
      final invItemRow = row.readTableOrNull(_database.invoiceItems);
      return RefundItem(
        id: itemRow.id,
        refundId: itemRow.refundId,
        invoiceItemId: itemRow.invoiceItemId,
        quantity: itemRow.quantity,
        unitPrice: itemRow.unitPrice,
        amount: itemRow.amount,
        description: invItemRow?.description,
      );
    }).toList();
  }

  Refund _mapToEntity(db.RefundData row, List<RefundItem> items) {
    return Refund(
      id: row.id,
      invoiceId: row.invoiceId,
      refundNumber: row.refundNumber,
      date: row.date,
      reason: row.reason,
      totalAmount: row.totalAmount,
      createdAt: row.createdAt,
      isValidated: row.isValidated,
      items: items,
    );
  }
}

final refundRepositoryProvider = Provider<RefundRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return RefundRepositoryImpl(database);
});
