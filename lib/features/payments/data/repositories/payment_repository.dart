import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hissab_dz/core/database/database.dart';
import 'package:hissab_dz/core/database/database_provider.dart';
import 'package:hissab_dz/features/payments/domain/entities/payment.dart';
import 'package:hissab_dz/features/clients/domain/entities/client.dart';

abstract class PaymentRepository {
  Stream<List<Payment>> watchPayments();
  Stream<List<Payment>> watchPaymentsForInvoice(int invoiceId);
  Future<int> addPayment(Payment payment);
  Future<void> deletePayment(int id);
}

class PaymentRepositoryImpl implements PaymentRepository {
  final AppDatabase _db;

  PaymentRepositoryImpl(this._db);

  @override
  Stream<List<Payment>> watchPayments() {
    final query = _db.select(_db.payments).join([
      leftOuterJoin(_db.clients, _db.clients.id.equalsExp(_db.payments.clientId)),
      leftOuterJoin(_db.invoices, _db.invoices.id.equalsExp(_db.payments.invoiceId)),
    ])..orderBy([OrderingTerm.desc(_db.payments.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final paymentData = row.readTable(_db.payments);
        final clientData = row.readTableOrNull(_db.clients);
        
        return Payment(
          id: paymentData.id,
          invoiceId: paymentData.invoiceId,
          clientId: paymentData.clientId,
          amount: paymentData.amount,
          date: paymentData.date,
          method: paymentData.method,
          notes: paymentData.notes,
          client: clientData != null ? Client(
            id: clientData.id,
            name: clientData.name,
            email: clientData.email,
            phone: clientData.phone,
            address: clientData.address,
          ) : null,
        );
      }).toList();
    });
  }

  @override
  Stream<List<Payment>> watchPaymentsForInvoice(int invoiceId) {
    return (_db.select(_db.payments)
          ..where((t) => t.invoiceId.equals(invoiceId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch()
        .map((rows) => rows.map((r) => _mapToEntity(r)).toList());
  }

  @override
  Future<int> addPayment(Payment payment) {
    return _db.into(_db.payments).insert(
      PaymentsCompanion.insert(
        invoiceId: payment.invoiceId,
        clientId: payment.clientId,
        amount: payment.amount,
        date: Value(payment.date),
        method: Value(payment.method),
        notes: Value(payment.notes),
      ),
    );
  }

  @override
  Future<void> deletePayment(int id) {
    return (_db.delete(_db.payments)..where((t) => t.id.equals(id))).go();
  }

  Payment _mapToEntity(PaymentData data) {
    return Payment(
      id: data.id,
      invoiceId: data.invoiceId,
      clientId: data.clientId,
      amount: data.amount,
      date: data.date,
      method: data.method,
      notes: data.notes,
    );
  }
}

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PaymentRepositoryImpl(db);
});
