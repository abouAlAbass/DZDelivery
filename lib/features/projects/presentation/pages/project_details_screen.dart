import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hissab_dz/core/utils/app_formatters.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:hissab_dz/core/widgets/status_badge.dart';
import 'package:hissab_dz/core/widgets/contextual_fab.dart';
import 'package:hissab_dz/features/invoices/domain/entities/invoice.dart';
import 'package:hissab_dz/features/invoices/domain/entities/invoice_status.dart';
import 'package:hissab_dz/features/invoices/presentation/providers/invoice_providers.dart';
import 'package:hissab_dz/features/payments/presentation/providers/payment_providers.dart';
import 'package:hissab_dz/features/projects/domain/entities/project.dart';
import 'package:hissab_dz/features/projects/domain/entities/project_status.dart';
import 'package:hissab_dz/features/projects/domain/entities/project_expense.dart';
import 'package:hissab_dz/features/projects/presentation/providers/project_providers.dart';
import 'package:hissab_dz/features/projects/presentation/widgets/expense_form_sheet.dart';
import 'package:hissab_dz/features/projects/services/pdf_project_report_service.dart';
import 'package:hissab_dz/features/projects/presentation/widgets/project_photos_section.dart';
import 'package:hissab_dz/features/projects/presentation/widgets/photo_capture_sheet.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';
import 'package:hissab_dz/features/refunds/presentation/providers/refund_providers.dart';
import 'package:hissab_dz/features/refunds/data/repositories/refund_repository_impl.dart';
import 'package:hissab_dz/features/refunds/domain/entities/refund.dart';

class ProjectDetailsScreen extends ConsumerWidget {
  final int projectId;

  const ProjectDetailsScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final projectAsync = ref.watch(projectDetailsProvider(projectId));
    final expensesAsync = ref.watch(projectExpensesProvider(projectId));
    final invoicesAsync = ref.watch(invoicesListProvider());
    final paymentsAsync = ref.watch(paymentsListProvider);
    final currencyFormat = NumberFormat.currency(symbol: l10n.currencySymbol);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.projectDetails),
        actions: [
          IconButton(
            tooltip: l10n.downloadPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => _exportProjectReport(context, ref, l10n),
          ),
        ],
      ),
      body: projectAsync.when(
        data: (project) {
          if (project == null) return Center(child: Text(l10n.noData));
          return paymentsAsync.when(
            data: (payments) {
              final paidByInvoice = <int, double>{};
              for (final payment in payments) {
                paidByInvoice[payment.invoiceId] =
                    (paidByInvoice[payment.invoiceId] ?? 0) + payment.amount;
              }

              return invoicesAsync.when(
                data: (allInvoices) {
                  final projectInvoices = allInvoices
                      .where((invoice) => invoice.projectId == projectId)
                      .toList();
                  final paidTotal = projectInvoices.fold(
                    0.0,
                    (sum, invoice) => sum + (paidByInvoice[invoice.id] ?? 0),
                  );
                  final unpaidTotal = projectInvoices.fold(0.0, (sum, invoice) {
                    final remaining =
                        invoice.total - (paidByInvoice[invoice.id] ?? 0);
                    return sum + (remaining > 0 ? remaining : 0);
                  });

                  return _buildProjectBody(
                    context,
                    ref,
                    l10n,
                    currencyFormat,
                    project,
                    projectInvoices,
                    paidByInvoice,
                    paidTotal,
                    unpaidTotal,
                    expensesAsync,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('${l10n.error}: $e')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('${l10n.error}: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('${l10n.error}: $e')),
      ),
      floatingActionButton: ContextualFab(
        onPressed: () => _showProjectAddSheet(context, ref, l10n),
        tooltip: l10n.addToProject,
        icon: Icons.add,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildProjectBody(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    NumberFormat currencyFormat,
    Project project,
    List<Invoice> projectInvoices,
    Map<int, double> paidByInvoice,
    double paidTotal,
    double unpaidTotal,
    AsyncValue<List<ProjectExpense>> expensesAsync,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.flag_outlined, size: 18),
                      label: Text(_statusLabel(l10n, project.status)),
                    ),
                    if (project.clientName != null)
                      Chip(
                        avatar: const Icon(Icons.person_outline, size: 18),
                        label: Text(project.clientName!),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<ProjectStatus>(
                  initialValue: project.status,
                  decoration: InputDecoration(
                    labelText: l10n.projectStatus,
                    prefixIcon: const Icon(Icons.flag_outlined),
                  ),
                  items: ProjectStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(_statusLabel(l10n, status)),
                        ),
                      )
                      .toList(),
                  onChanged: (status) {
                    if (status == null || project.id == null) return;
                    ref
                        .read(projectRepositoryProvider)
                        .updateProject(
                          Project(
                            id: project.id,
                            clientId: project.clientId,
                            name: project.name,
                            clientName: project.clientName,
                            siteAddress: project.siteAddress,
                            status: status,
                            description: project.description,
                            startDate: project.startDate,
                            endDate: project.endDate,
                            createdAt: project.createdAt,
                            invoiceTotal: project.invoiceTotal,
                            expenseTotal: project.expenseTotal,
                          ),
                        );
                    ref.invalidate(projectDetailsProvider(projectId));
                    ref.invalidate(projectsListProvider);
                  },
                ),
                if (project.siteAddress != null &&
                    project.siteAddress!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(l10n.siteAddress),
                    subtitle: Text(project.siteAddress!),
                  ),
                ],
                if (project.description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    project.description!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _metric(
                        l10n.invoices,
                        AppFormatters.formatCurrency(project.invoiceTotal, l10n),
                      ),
                    ),
                    Expanded(
                      child: _metric(
                        l10n.expenses,
                        AppFormatters.formatCurrency(project.expenseTotal, l10n),
                      ),
                    ),
                    Expanded(
                      child: _metric(
                        l10n.balance,
                        AppFormatters.formatCurrency(project.balance, l10n),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _metric(
                        l10n.paidAmount,
                        AppFormatters.formatCurrency(paidTotal, l10n),
                      ),
                    ),
                    Expanded(
                      child: _metric(
                        l10n.remainingToPay,
                        AppFormatters.formatCurrency(unpaidTotal, l10n),
                      ),
                    ),
                    Expanded(
                      child: ref.watch(FutureProvider((ref) => 
                        ref.watch(refundRepositoryProvider).calculateProjectProfitability(projectId))).when(
                        data: (profit) => _metric(
                          l10n.projectProfitability,
                          AppFormatters.formatCurrency(profit, l10n),
                          valueColor: profit >= 0 ? Colors.green : Colors.red,
                        ),
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const SizedBox(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.relatedInvoices,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton.icon(
              onPressed: () => context.pushNamed(
                'create_invoice',
                queryParameters: {'projectId': projectId.toString()},
              ),
              icon: const Icon(Icons.add),
              label: Text(l10n.createInvoice),
            ),
          ],
        ),
        if (projectInvoices.isEmpty)
          Card(child: ListTile(title: Text(l10n.noInvoices)))
        else
          Column(
            children: projectInvoices.map<Widget>((invoice) {
              final paid = paidByInvoice[invoice.id] ?? 0;
              final remaining = invoice.total - paid;
              return Card(
                child: ListTile(
                  title: Text(
                    invoice.invoiceNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${invoice.client?.name ?? l10n.unknownClient} - ${l10n.remainingToPay}: ${AppFormatters.formatCurrency(remaining < 0 ? 0 : remaining, l10n)}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        AppFormatters.formatCurrency(invoice.total, l10n),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      StatusBadge(status: invoice.status),
                    ],
                  ),
                  onTap: () => context.pushNamed(
                    'invoice_details',
                    pathParameters: {'id': invoice.id.toString()},
                  ),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 16),
        _buildRefundsSection(context, ref, l10n, currencyFormat),
        const SizedBox(height: 16),
        if (projectInvoices.any(
          (invoice) =>
              invoice.status != InvoiceStatus.paid &&
              invoice.total - (paidByInvoice[invoice.id] ?? 0) > 0,
        )) ...[
          Text(
            l10n.unpaidInvoices,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...projectInvoices
              .where(
                (invoice) =>
                    invoice.status != InvoiceStatus.paid &&
                    invoice.total - (paidByInvoice[invoice.id] ?? 0) > 0,
              )
              .map<Widget>(
                (invoice) => Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                    ),
                    title: Text(invoice.invoiceNumber),
                    subtitle: Text(
                      '${l10n.remainingToPay}: ${AppFormatters.formatCurrency(invoice.total - (paidByInvoice[invoice.id] ?? 0), l10n)}',
                    ),
                    trailing: TextButton(
                      onPressed: () => context.pushNamed(
                        'invoice_details',
                        pathParameters: {'id': invoice.id.toString()},
                      ),
                      child: Text(l10n.recordPayment),
                    ),
                  ),
                ),
              ),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.expenses, style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              onPressed: () => _showExpenseSheet(context, ref, l10n),
              icon: const Icon(Icons.add),
              label: Text(l10n.addExpense),
            ),
          ],
        ),
        expensesAsync.when(
          data: (expenses) {
            if (expenses.isEmpty) {
              return Card(child: ListTile(title: Text(l10n.noExpenses)));
            }
            return Column(
              children: expenses.map((expense) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: Text(
                      expense.label,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      [
                        expense.expenseTypeName ?? l10n.expense,
                        expense.supplier,
                        expense.paymentMethod,
                        l10n.localeName == 'ar'
                            ? DateFormat('dd/MM/yyyy', 'en').format(expense.date)
                            : DateFormat.yMMMd(l10n.localeName).format(expense.date),
                      ].whereType<String>().join(' - '),
                    ),
                    trailing: Text(
                      AppFormatters.formatCurrency(expense.amount, l10n),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (e, st) => Text('${l10n.error}: $e'),
        ),
        ProjectPhotosSection(projectId: projectId),
      ],
    );
  }

  Widget _buildRefundsSection(BuildContext context, WidgetRef ref, AppLocalizations l10n, NumberFormat currencyFormat) {
    final refundsAsync = ref.watch(projectRefundsProvider(projectId));
    
    return refundsAsync.when(
      data: (refunds) {
        if (refunds.isEmpty) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.refunds, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...refunds.map((Refund refund) => Card(
              child: ListTile(
                onTap: () => context.pushNamed(
                  'refund_details',
                  pathParameters: {'id': refund.id!.toString()},
                ),
                leading: const Icon(Icons.assignment_return_outlined, color: Colors.orange),
                title: Text(refund.refundNumber),
                subtitle: Text(
                  l10n.localeName == 'ar'
                      ? DateFormat('dd/MM/yyyy', 'en').format(refund.date)
                      : DateFormat.yMMMd(l10n.localeName).format(refund.date),
                ),
                trailing: Text(
                  '- ${AppFormatters.formatCurrency(refund.totalAmount, l10n)}',
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            )),
          ],
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _metric(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  String _statusLabel(AppLocalizations l10n, ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planned:
        return l10n.planned;
      case ProjectStatus.inProgress:
        return l10n.inProgress;
      case ProjectStatus.completed:
        return l10n.completed;
      case ProjectStatus.awaitingPayment:
        return l10n.awaitingPayment;
    }
  }

  Future<void> _exportProjectReport(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final project = ref.read(projectDetailsProvider(projectId)).value;
    final expenses = ref.read(projectExpensesProvider(projectId)).value;
    final invoices = ref.read(invoicesListProvider()).value;
    final payments = ref.read(paymentsListProvider).value;

    if (project == null ||
        expenses == null ||
        invoices == null ||
        payments == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.noData)));
      return;
    }

    final projectInvoices = invoices
        .where((invoice) => invoice.projectId == projectId)
        .toList();
    final invoiceIds = projectInvoices
        .map((invoice) => invoice.id)
        .whereType<int>()
        .toSet();
    final projectPayments = payments
        .where((payment) => invoiceIds.contains(payment.invoiceId))
        .toList();

    final refunds = await ref.read(projectRefundsProvider(projectId).future);

    try {
      final tempFile = await PdfProjectReportService.generateProjectReportPdf(
        project: project,
        invoices: projectInvoices,
        expenses: expenses,
        payments: projectPayments,
        refunds: refunds,
        l10n: l10n,
      );

      final baseDir = Platform.isWindows
          ? await getDownloadsDirectory()
          : await getApplicationDocumentsDirectory();
      final saveDir = Directory(
        p.join(baseDir!.path, 'InvoicePro', 'project_reports'),
      );
      if (!saveDir.existsSync()) saveDir.createSync(recursive: true);

      final safeProjectName = project.name
          .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
          .replaceAll(RegExp(r'\s+'), '_')
          .toLowerCase();
      var savedPath = p.join(
        saveDir.path,
        'project_report_$safeProjectName.pdf',
      );
      final targetFile = File(savedPath);

      try {
        if (targetFile.existsSync()) {
          await targetFile.delete();
        }
      } catch (_) {
        final timestamp = DateFormat('HHmmss').format(DateTime.now());
        savedPath = p.join(
          saveDir.path,
          'project_report_${safeProjectName}_$timestamp.pdf',
        );
      }

      await tempFile.copy(savedPath);
      await OpenFilex.open(savedPath);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${l10n.pdfDownloadedAndOpened}\n${p.basename(savedPath)}',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.error}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showExpenseSheet(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => ExpenseFormSheet(initialProjectId: projectId),
    );
  }

  void _showProjectAddSheet(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.addToProject,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(l10n.createInvoice),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.pushNamed(
                    'create_invoice',
                    queryParameters: {'projectId': projectId.toString()},
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.request_quote_outlined),
                title: Text(l10n.createQuote),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.pushNamed(
                    'create_quote',
                    queryParameters: {'projectId': projectId.toString()},
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: Text(l10n.addExpense),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showExpenseSheet(context, ref, l10n);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(l10n.addPhoto),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showPhotoSheet(context, ref, l10n);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoSheet(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => PhotoCaptureSheet(projectId: projectId),
    );
  }
}
