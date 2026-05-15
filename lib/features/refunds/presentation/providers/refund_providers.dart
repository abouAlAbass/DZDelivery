import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hissab_dz/features/refunds/domain/entities/refund.dart';
import 'package:hissab_dz/features/refunds/data/repositories/refund_repository_impl.dart';

final invoiceRefundsProvider = FutureProvider.family<List<Refund>, int>((ref, invoiceId) {
  return ref.watch(refundRepositoryProvider).getRefundsByInvoiceId(invoiceId);
});

final projectRefundsProvider = FutureProvider.family<List<Refund>, int>((ref, projectId) {
  return ref.watch(refundRepositoryProvider).getRefundsByProjectId(projectId);
});

final refundedQuantityProvider = FutureProvider.family<double, int>((ref, invoiceItemId) {
  return ref.watch(refundRepositoryProvider).getRefundedQuantityByInvoiceItemId(invoiceItemId);
});

final allRefundsProvider = FutureProvider<List<Refund>>((ref) {
  return ref.watch(refundRepositoryProvider).getAllRefunds();
});
