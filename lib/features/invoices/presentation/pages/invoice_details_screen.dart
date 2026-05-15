import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hissab_dz/core/utils/app_formatters.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:hissab_dz/features/payments/presentation/providers/payment_providers.dart';
import 'package:hissab_dz/features/payments/presentation/widgets/payment_record_dialog.dart';
import 'package:hissab_dz/features/refunds/presentation/providers/refund_providers.dart';
import 'package:hissab_dz/features/refunds/data/repositories/refund_repository_impl.dart';
import 'package:hissab_dz/features/invoices/presentation/providers/invoice_providers.dart';
import 'package:hissab_dz/features/invoices/domain/entities/invoice.dart';
import 'package:hissab_dz/features/invoices/domain/entities/invoice_status.dart';
import 'package:hissab_dz/core/theme/theme.dart';
import 'package:hissab_dz/core/widgets/status_badge.dart';
import 'package:hissab_dz/features/invoices/services/pdf_invoice_service.dart';
import 'package:hissab_dz/features/settings/presentation/providers/settings_providers.dart';
import 'package:hissab_dz/features/settings/domain/entities/business_profile.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';
import 'package:hissab_dz/features/refunds/domain/entities/refund.dart';

class InvoiceDetailsScreen extends ConsumerWidget {
  final int invoiceId;
  const InvoiceDetailsScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoicesListProvider());
    final businessProfileAsync = ref.watch(businessProfileProvider);
    final businessProfile = businessProfileAsync.value;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.invoiceDetails),
        actions: [
          IconButton(
            tooltip: l10n.downloadPdf,
            icon: const Icon(Icons.download_outlined),
            onPressed: () => _handlePdfAction(context, ref, businessProfile, isShare: false),
          ),
          IconButton(
            tooltip: l10n.share,
            icon: const Icon(Icons.share),
            onPressed: () => _handlePdfAction(context, ref, businessProfile, isShare: true),
          ),
          IconButton(
            tooltip: l10n.editInvoice,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.pushNamed(
              'edit_invoice',
              pathParameters: {'id': invoiceId.toString()},
            ),
          ),
          IconButton(
            tooltip: l10n.delete,
            icon: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => _confirmDeleteInvoice(context, ref, l10n),
          ),
        ],
      ),
      body: invoicesAsync.when(
        data: (invoices) {
          final index = invoices.indexWhere((i) => i.id == invoiceId);
          if (index == -1) {
            return Center(child: Text(l10n.invoiceNotFound));
          }
          final invoice = invoices[index];
          return Hero(
            tag: 'invoice_${invoice.id}',
            child: Material(
              color: Colors.transparent,
              child: _InvoiceDetailsBody(
                invoice: invoice,
                onSharePdf: () => _handlePdfAction(context, ref, businessProfile, isShare: true),
                onDownloadPdf: () => _handlePdfAction(context, ref, businessProfile, isShare: false),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('${l10n.error}: $e')),
      ),
    );
  }

  Future<void> _handlePdfAction(
    BuildContext context,
    WidgetRef ref,
    BusinessProfile? profile, {
    required bool isShare,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final includePayments = await _showPdfOptionsDialog(context, l10n);
    if (includePayments == null) return;

    if (isShare) {
      if (!context.mounted) return;
      await _sharePdf(context, ref, profile, includePayments: includePayments);
    } else {
      if (!context.mounted) return;
      await _downloadPdf(context, ref, profile, includePayments: includePayments);
    }
  }

  Future<bool?> _showPdfOptionsDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        bool includePayments = false;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(l10n.exportPdf),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: Text(l10n.includePayments),
                    subtitle: Text(l10n.paymentHistoryAndBalance),
                    value: includePayments,
                    onChanged: (val) =>
                        setDialogState(() => includePayments = val ?? false),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, includePayments),
                  child: Text(l10n.confirm),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _downloadPdf(
    BuildContext context,
    WidgetRef ref,
    BusinessProfile? profile, {
    bool includePayments = false,
  }) async {
    final invoices = ref.read(invoicesListProvider()).value ?? [];
    final index = invoices.indexWhere((i) => i.id == invoiceId);
    if (index == -1) return;

    final invoice = invoices[index];
    final payments = ref.read(invoicePaymentsProvider(invoiceId)).value;
    final l10n = AppLocalizations.of(context)!;

    try {
      final tempFile = await PdfInvoiceService.generateInvoicePdf(
        invoice: invoice,
        profile: profile,
        l10n: l10n,
        payments: payments,
        showPayments: includePayments,
      );

      // Save to Downloads folder
      Directory? downloadsDir;
      if (Platform.isWindows) {
        downloadsDir = await getDownloadsDirectory();
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      final saveDir = Directory(p.join(downloadsDir!.path, 'InvoicePro'));
      if (!saveDir.existsSync()) saveDir.createSync(recursive: true);

      String savedPath = p.join(
        saveDir.path,
        'invoice_${invoice.invoiceNumber}.pdf',
      );
      final targetFile = File(savedPath);

      try {
        if (targetFile.existsSync()) {
          await targetFile.delete();
        }
      } catch (e) {
        // If file is locked/open, use a timestamped filename
        final timestamp = DateFormat('HHmmss').format(DateTime.now());
        savedPath = p.join(
          saveDir.path,
          'invoice_${invoice.invoiceNumber}_$timestamp.pdf',
        );
      }

      await tempFile.copy(savedPath);

      // Open the file immediately
      await OpenFilex.open(savedPath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l10n.pdfDownloadedAndOpened}\n${p.basename(savedPath)}',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sharePdf(
    BuildContext context,
    WidgetRef ref,
    BusinessProfile? profile, {
    bool includePayments = false,
  }) async {
    final invoices = ref.read(invoicesListProvider()).value ?? [];
    final index = invoices.indexWhere((i) => i.id == invoiceId);
    if (index == -1) return;

    final invoice = invoices[index];
    final payments = ref.read(invoicePaymentsProvider(invoiceId)).value;
    final l10n = AppLocalizations.of(context)!;

    try {
      final file = await PdfInvoiceService.generateInvoicePdf(
        invoice: invoice,
        profile: profile,
        l10n: l10n,
        payments: payments,
        showPayments: includePayments,
      );
      await Share.shareXFiles([
        XFile(file.path),
      ], subject: '${l10n.invoiceLabel} ${invoice.invoiceNumber}');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorGeneratingPdf}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteInvoice(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.deleteInvoiceConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(invoiceRepositoryProvider).deleteInvoice(invoiceId);
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.invoiceDeleted)),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!context.mounted) return;

        String message = l10n.error;
        if (e.toString().contains('HAS_PAYMENTS')) {
          message = l10n.deleteInvoiceErrorHasPayments;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

// ── Stateful body widget ──────────────────────────────────────────────────────
class _InvoiceDetailsBody extends ConsumerStatefulWidget {
  final Invoice invoice;
  final VoidCallback onSharePdf;
  final VoidCallback onDownloadPdf;

  const _InvoiceDetailsBody({
    required this.invoice,
    required this.onSharePdf,
    required this.onDownloadPdf,
  });

  @override
  ConsumerState<_InvoiceDetailsBody> createState() =>
      _InvoiceDetailsBodyState();
}

class _InvoiceDetailsBodyState extends ConsumerState<_InvoiceDetailsBody> {
  late InvoiceStatus _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.invoice.status;
  }

  @override
  void didUpdateWidget(_InvoiceDetailsBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.invoice.status != widget.invoice.status) {
      _currentStatus = widget.invoice.status;
    }
  }

  // ─── Status Update ────────────────────────────────────────────────────────
  Future<void> _updateStatus(InvoiceStatus newStatus) async {
    final updated = widget.invoice.copyWith(status: newStatus);
    await ref.read(invoiceRepositoryProvider).updateInvoice(updated);
    if (mounted) setState(() => _currentStatus = newStatus);
  }

  void _showStatusDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.updateStatus),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: InvoiceStatus.values.map((status) {
            String label;
            switch (status) {
              case InvoiceStatus.draft:
                label = l10n.draft;
                break;
              case InvoiceStatus.sent:
                label = l10n.sent;
                break;
              case InvoiceStatus.accepted:
                label = l10n.accepted;
                break;
              case InvoiceStatus.converted:
                label = l10n.converted;
                break;
              case InvoiceStatus.paid:
                label = l10n.paid;
                break;
              case InvoiceStatus.unpaid:
                label = l10n.unpaid;
                break;
              case InvoiceStatus.cancelled:
                label = l10n.cancelled;
                break;
              case InvoiceStatus.overdue:
                label = l10n.overdue;
                break;
            }

            return ListTile(
              leading: _statusIcon(status),
              title: Text(label),
              trailing: _currentStatus == status
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () async {
                Navigator.pop(ctx);
                if (status != _currentStatus) {
                  await _updateStatus(status);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${l10n.statusUpdated}: $label')),
                    );
                  }
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  Icon _statusIcon(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Icon(Icons.edit_note, color: Theme.of(context).textTheme.bodySmall?.color);
      case InvoiceStatus.sent:
        return const Icon(Icons.send, color: AppTheme.statusIssued);
      case InvoiceStatus.accepted:
        return const Icon(
          Icons.check_circle_outline,
          color: AppTheme.statusAccepted,
        );
      case InvoiceStatus.converted:
        return const Icon(
          Icons.description_outlined,
          color: AppTheme.statusConverted,
        );
      case InvoiceStatus.paid:
        return const Icon(Icons.check_circle, color: AppTheme.statusPaid);
      case InvoiceStatus.unpaid:
        return const Icon(Icons.money_off, color: AppTheme.statusOverdue);
      case InvoiceStatus.cancelled:
        return const Icon(
          Icons.cancel_outlined,
          color: AppTheme.statusCancelled,
        );
      case InvoiceStatus.overdue:
        return const Icon(Icons.warning, color: AppTheme.statusOverdue);
    }
  }

  // ─── Record Payment ───────────────────────────────────────────────────────
  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (_) => PaymentRecordDialog(invoice: widget.invoice),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final invoice = widget.invoice;
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invoice.invoiceNumber,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            l10n.localeName == 'ar'
                                ? DateFormat('dd/MM/yyyy', 'en').format(invoice.issueDate)
                                : DateFormat.yMMMd().format(invoice.issueDate),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          if (invoice.dueDate != null)
                            Text(
                              l10n.localeName == 'ar'
                                  ? '${l10n.dueDate}: ${DateFormat('dd/MM/yyyy', 'en').format(invoice.dueDate!)}'
                                  : '${l10n.dueDate}: ${DateFormat.yMMMd().format(invoice.dueDate!)}',
                              style: TextStyle(
                                color: invoice.status == InvoiceStatus.overdue
                                    ? Colors.red
                                    : Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          if (invoice.projectName != null)
                            Text(
                              '${l10n.project}: ${invoice.projectName}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StatusBadge(status: _currentStatus),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _showStatusDialog,
                            icon: const Icon(Icons.swap_horiz, size: 16),
                            label: Text(
                              l10n.changeStatus,
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showPaymentDialog,
                  icon: const Icon(Icons.payments_outlined),
                  label: Text(l10n.recordPayment),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onDownloadPdf,
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: Text(l10n.exportPdf),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Create Refund Button
          if (invoice.status != InvoiceStatus.cancelled && invoice.status != InvoiceStatus.draft)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.pushNamed(
                  'create_refund',
                  pathParameters: {'id': invoice.id!.toString()},
                ),
                icon: const Icon(Icons.assignment_return_outlined),
                label: Text(l10n.createRefund),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Bill To
          _sectionTitle(l10n.billTo),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text((invoice.client?.name ?? '?')[0].toUpperCase()),
              ),
              title: Text(
                invoice.client?.name ?? l10n.unknownClient,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (invoice.client?.email != null)
                    Text(invoice.client!.email!),
                  if (invoice.client?.phone != null)
                    Text(invoice.client!.phone!),
                  if (invoice.client?.address != null)
                    Text(invoice.client!.address!),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          _buildRefundsSection(invoice, l10n),
          const SizedBox(height: 20),

          // Items
          _sectionTitle('${l10n.items} (${invoice.items.length})'),
          Card(
            child: Column(
              children: [
                // header row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.description,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: Text(
                          l10n.quantity,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          l10n.price,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          l10n.amount,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...invoice.items.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  return Container(
                    color: i.isOdd ? Colors.grey.withAlpha(20) : null,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(item.description)),
                        SizedBox(
                          width: 60,
                          child: Text(
                            item.quantity.toString(),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: Text(
                            AppFormatters.formatCurrency(item.unitPrice, l10n),
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: Text(
                            AppFormatters.formatCurrency(item.amount, l10n),
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Totals / Balance
          _sectionTitle(l10n.summary),
          ref.watch(invoicePaymentsProvider(invoice.id!)).when(
            data: (payments) {
              final paidAmount = payments.fold(0.0, (sum, p) => sum + p.amount);
              final remainingAmount = invoice.total - paidAmount;
              
              final netAmountAsync = ref.watch(FutureProvider((ref) => 
                ref.watch(refundRepositoryProvider).calculateInvoiceNetAmount(invoice.id!)));

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _totalRow(l10n.subtotal, AppFormatters.formatCurrency(invoice.subtotal, l10n)),
                      const SizedBox(height: 6),
                      _totalRow(
                        '${l10n.totalTax} (${invoice.taxRate}%)',
                        AppFormatters.formatCurrency(invoice.subtotal * invoice.taxRate / 100, l10n),
                      ),
                      const SizedBox(height: 6),
                      _totalRow(l10n.discount, '- ${AppFormatters.formatCurrency(invoice.discountAmount, l10n)}'),
                      const Divider(height: 20),
                      _totalRow(
                        l10n.total,
                        AppFormatters.formatCurrency(invoice.total, l10n),
                        isBold: true,
                        fontSize: 16,
                      ),
                      netAmountAsync.maybeWhen(
                        data: (netAmount) => invoice.total != netAmount ? Column(
                          children: [
                            const SizedBox(height: 6),
                            _totalRow(
                              l10n.refundAmount,
                              '- ${AppFormatters.formatCurrency(invoice.total - netAmount, l10n)}',
                              color: Colors.red,
                            ),
                            _totalRow(
                              l10n.netAmount,
                              AppFormatters.formatCurrency(netAmount, l10n),
                              isBold: true,
                              fontSize: 16,
                              color: Colors.teal,
                            ),
                          ],
                        ) : const SizedBox.shrink(),
                        orElse: () => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 6),
                      _totalRow(
                        l10n.paidAmount,
                        AppFormatters.formatCurrency(paidAmount, l10n),
                        color: Colors.green,
                        fontSize: 16,
                      ),
                      const Divider(height: 20),
                      _totalRow(
                        l10n.remaining,
                        AppFormatters.formatCurrency(remainingAmount < 0 ? 0 : remainingAmount, l10n),
                        isBold: true,
                        fontSize: 18,
                        color: remainingAmount > 0 ? Colors.red : Colors.green,
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),

          const SizedBox(height: 20),

          // Related Payments
          _sectionTitle(l10n.relatedPayments),
          ref
              .watch(invoicePaymentsProvider(invoice.id!))
              .when(
                data: (payments) {
                  if (payments.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            l10n.noPayments,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return Card(
                    child: Column(
                      children: payments
                          .map(
                            (p) => ListTile(
                              dense: true,
                              leading: const Icon(
                                Icons.payment,
                                size: 18,
                                color: Colors.green,
                              ),
                              title: Text(
                                AppFormatters.formatCurrency(p.amount, l10n),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${l10n.localeName == 'ar' ? DateFormat('dd/MM/yyyy', 'en').format(p.date) : DateFormat.yMMMd(l10n.localeName).format(p.date)}${p.method != null ? ' • ${p.method == 'cash' ? l10n.cash : p.method == 'transfer' ? l10n.transfer : p.method}' : ''}',
                              ),
                              trailing: p.notes != null
                                  ? const Icon(Icons.info_outline, size: 14)
                                  : null,
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),

          const SizedBox(height: 20),
          _buildRefundsSection(invoice, l10n),

          // Notes
          if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
            const SizedBox(height: 20),
            _sectionTitle(l10n.notes),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  invoice.notes!,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _totalRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 14,
    Color? color,
  }) {
    final style = TextStyle(
      fontWeight: isBold ? FontWeight.bold : null,
      fontSize: fontSize,
      color: color,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }

  Widget _buildRefundsSection(Invoice invoice, AppLocalizations l10n) {
    final refundsAsync = ref.watch(invoiceRefundsProvider(invoice.id!));

    return refundsAsync.when(
      data: (refunds) {
        if (refunds.isEmpty) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.refunds,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...refunds.map((Refund refund) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: () => context.pushNamed(
                  'refund_details',
                  pathParameters: {'id': refund.id!.toString()},
                ),
                leading: const Icon(Icons.assignment_return_outlined, color: Colors.orange),
                title: Text(refund.refundNumber),
                subtitle: Text(DateFormat.yMMMd(l10n.localeName).format(refund.date)),
                trailing: Text(
                  '- ${AppFormatters.formatCurrency(refund.totalAmount, l10n)}',
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            )),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Text(l10n.error),
    );
  }
}
