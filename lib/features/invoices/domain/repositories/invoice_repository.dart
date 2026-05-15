import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_status.dart';

abstract class InvoiceRepository {
  Future<List<Invoice>> getInvoices({InvoiceStatus? status, String? query});
  Stream<List<Invoice>> watchInvoices({InvoiceStatus? status});
  Future<Invoice?> getInvoiceById(int id);
  Future<int> createInvoice(Invoice invoice);
  Future<void> updateInvoice(Invoice invoice);
  Future<void> updateLastReminderAt(int invoiceId, DateTime date);
  Future<void> deleteInvoice(int id);
  Future<String> generateNextInvoiceNumber();
}
