import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hissab_dz/features/payments/data/repositories/payment_repository.dart';
import 'package:hissab_dz/features/payments/domain/entities/payment.dart';

part 'payment_providers.g.dart';

@riverpod
Stream<List<Payment>> paymentsList(PaymentsListRef ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return repository.watchPayments();
}

@riverpod
Stream<List<Payment>> invoicePayments(InvoicePaymentsRef ref, int invoiceId) {
  final repository = ref.watch(paymentRepositoryProvider);
  return repository.watchPaymentsForInvoice(invoiceId);
}
