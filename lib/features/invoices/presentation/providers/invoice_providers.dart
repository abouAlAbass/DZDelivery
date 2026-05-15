import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/repositories/invoice_repository_impl.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_status.dart';
import '../../domain/repositories/invoice_repository.dart';

part 'invoice_providers.g.dart';

@riverpod
InvoiceRepository invoiceRepository(InvoiceRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return InvoiceRepositoryImpl(db);
}

@riverpod
Stream<List<Invoice>> invoicesList(InvoicesListRef ref, {InvoiceStatus? status}) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return repository.watchInvoices(status: status);
}

@riverpod
class InvoiceFilterStatus extends _$InvoiceFilterStatus {
  @override
  InvoiceStatus? build() => null;

  void set(InvoiceStatus? status) => state = status;
}

@riverpod
class InvoiceSearchQuery extends _$InvoiceSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@riverpod
Future<List<Invoice>> filteredInvoices(FilteredInvoicesRef ref) {
  final status = ref.watch(invoiceFilterStatusProvider);
  final query = ref.watch(invoiceSearchQueryProvider);
  final repository = ref.watch(invoiceRepositoryProvider);
  
  return repository.getInvoices(status: status, query: query);
}
@riverpod
Future<Invoice?> invoiceById(InvoiceByIdRef ref, int id) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return repository.getInvoiceById(id);
}
