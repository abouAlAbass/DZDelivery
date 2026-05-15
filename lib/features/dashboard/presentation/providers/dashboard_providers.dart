import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../clients/presentation/providers/client_providers.dart';
import '../../../invoices/domain/entities/invoice_status.dart';
import '../../../invoices/presentation/providers/invoice_providers.dart';
import '../../../payments/presentation/providers/payment_providers.dart';
import '../../../projects/domain/entities/project_status.dart';
import '../../../projects/presentation/providers/project_providers.dart';

part 'dashboard_providers.g.dart';

@riverpod
class DashboardStats extends _$DashboardStats {
  @override
  Future<Map<String, dynamic>> build() async {
    final invoices = await ref.watch(invoicesListProvider().future);
    final clients = await ref.watch(clientsListProvider.future);
    final payments = await ref.watch(paymentsListProvider.future);
    final expenses = await ref.watch(expensesListProvider.future);
    final projects = await ref.watch(projectsListProvider.future);
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final nextMonthStart = DateTime(now.year, now.month + 1);

    final collectedThisMonth = payments
        .where(
          (payment) =>
              !payment.date.isBefore(monthStart) &&
              payment.date.isBefore(nextMonthStart),
        )
        .fold(0.0, (sum, payment) => sum + payment.amount);

    final paidByInvoice = <int, double>{};
    for (final payment in payments) {
      paidByInvoice[payment.invoiceId] =
          (paidByInvoice[payment.invoiceId] ?? 0) + payment.amount;
    }

    final outstandingAmount = invoices.fold(0.0, (sum, invoice) {
      if (invoice.status == InvoiceStatus.paid ||
          invoice.status == InvoiceStatus.cancelled) {
        return sum;
      }
      final remaining = invoice.total - (paidByInvoice[invoice.id] ?? 0);
      return sum + (remaining > 0 ? remaining : 0);
    });

    final expensesThisMonth = expenses
        .where(
          (expense) =>
              !expense.date.isBefore(monthStart) &&
              expense.date.isBefore(nextMonthStart),
        )
        .fold(0.0, (sum, expense) => sum + expense.amount);

    final estimatedProfit = collectedThisMonth - expensesThisMonth;

    final ongoingProjects = projects
        .where((project) => project.status == ProjectStatus.inProgress)
        .length;

    final invoicesThisMonth = invoices
        .where(
          (i) => i.issueDate.month == now.month && i.issueDate.year == now.year,
        )
        .length;

    final recentInvoices = [...invoices]
      ..sort((a, b) => b.issueDate.compareTo(a.issueDate));

    final overdueInvoices = invoices
        .where(
          (i) =>
              i.status == InvoiceStatus.overdue ||
              (i.dueDate != null &&
                  i.dueDate!.isBefore(now) &&
                  i.status != InvoiceStatus.paid &&
                  i.status != InvoiceStatus.cancelled),
        )
        .toList();

    return {
      'collectedThisMonth': collectedThisMonth,
      'outstandingAmount': outstandingAmount,
      'expensesThisMonth': expensesThisMonth,
      'estimatedProfit': estimatedProfit,
      'ongoingProjects': ongoingProjects,
      'overdueInvoiceCount': overdueInvoices.length,
      'totalClients': clients.length,
      'invoicesThisMonth': invoicesThisMonth,
      'recentInvoices': recentInvoices.take(5).toList(),
      'overdueInvoices': overdueInvoices,
    };
  }
}
