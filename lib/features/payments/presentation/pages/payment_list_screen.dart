import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hissab_dz/core/utils/app_formatters.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../invoices/domain/entities/invoice_status.dart';
import '../../../invoices/presentation/providers/invoice_providers.dart';
import '../providers/payment_providers.dart';

class PaymentListScreen extends ConsumerWidget {
  const PaymentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final paymentsAsync = ref.watch(paymentsListProvider);
    final invoicesAsync = ref.watch(invoicesListProvider());

    return Scaffold(
      appBar: AppBar(title: Text(l10n.payments)),
      drawer: MediaQuery.sizeOf(context).width >= 1100
          ? null
          : const AppDrawer(),
      body: paymentsAsync.when(
        data: (payments) => invoicesAsync.when(
          data: (invoices) {
            final paidByInvoice = <int, double>{};
            for (final payment in payments) {
              paidByInvoice[payment.invoiceId] =
                  (paidByInvoice[payment.invoiceId] ?? 0) + payment.amount;
            }
            final unpaidInvoices = invoices.where((invoice) {
              final remaining =
                  invoice.total - (paidByInvoice[invoice.id] ?? 0);
              return invoice.status != InvoiceStatus.paid && remaining > 0;
            }).toList();
            final unpaidTotal = unpaidInvoices.fold(0.0, (sum, invoice) {
              return sum + invoice.total - (paidByInvoice[invoice.id] ?? 0);
            });
            final today = DateTime.now();
            final overdueCount = unpaidInvoices.where((invoice) {
              final dueDate = invoice.dueDate;
              return dueDate != null && dueDate.isBefore(today);
            }).length;

            if (payments.isEmpty && unpaidInvoices.isEmpty) {
              return AppEmptyState(
                icon: Icons.payments_outlined,
                title: l10n.noPayments,
              );
            }

            return ResponsiveContent(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.bottomNavClearance,
                ),
                children: [
                  _buildPaymentSummary(
                    context,
                    l10n,
                    unpaidInvoices.length,
                    unpaidTotal,
                    overdueCount,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.unpaidInvoices,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (unpaidInvoices.isEmpty)
                    Card(child: ListTile(title: Text(l10n.noInvoices)))
                  else
                    ...unpaidInvoices.map((invoice) {
                      final paid = paidByInvoice[invoice.id] ?? 0;
                      final remaining = invoice.total - paid;
                      return Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.pending_actions,
                            color: AppColors.warning,
                          ),
                          title: Text(
                            invoice.client?.name ?? l10n.unknownClient,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(invoice.invoiceNumber),
                              Text(
                                '${l10n.paidAmount}: ${AppFormatters.formatCurrency(paid, l10n)}',
                              ),
                              Text(
                                '${l10n.lastReminder}: ${invoice.lastReminderAt == null ? l10n.notProvided : (l10n.localeName == 'ar' ? DateFormat('dd/MM/yyyy', 'en').format(invoice.lastReminderAt!) : DateFormat.yMMMd(l10n.localeName).format(invoice.lastReminderAt!))}',
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                AppFormatters.formatCurrency(remaining, l10n),
                                style: const TextStyle(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(l10n.remainingToPay),
                            ],
                          ),
                          onTap: () => context.pushNamed(
                            'invoice_details',
                            pathParameters: {'id': invoice.id.toString()},
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 16),
                  if (unpaidInvoices.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: unpaidInvoices.take(3).map((invoice) {
                        return OutlinedButton.icon(
                          onPressed: () => _sendReminder(context, ref, invoice),
                          icon: const Icon(Icons.notifications_active_outlined),
                          label: Text(
                            '${l10n.sendReminder} ${invoice.invoiceNumber}',
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.history,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (payments.isEmpty)
                    Card(child: ListTile(title: Text(l10n.noPayments)))
                  else
                    ...payments.map((payment) {
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.successSoft,
                            child: Icon(
                              Icons.call_received,
                              color: AppColors.success,
                            ),
                          ),
                          title: Text(
                            payment.client?.name ?? l10n.unknownClient,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${l10n.invoiceNumberShort}${payment.invoiceId} - ${l10n.localeName == 'ar' ? DateFormat('dd/MM/yyyy', 'en').format(payment.date) : DateFormat.yMMMd(l10n.localeName).format(payment.date)}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              if (payment.method != null)
                                Text(
                                  '${l10n.paymentMethod}: ${payment.method == 'cash' ? l10n.cash : payment.method == 'transfer' ? l10n.transfer : payment.method}',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Text(
                            AppFormatters.formatCurrency(payment.amount, l10n),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.income,
                            ),
                          ),
                          onTap: () {
                            context.pushNamed(
                              'client_details',
                              pathParameters: {
                                'id': payment.clientId.toString(),
                              },
                            );
                          },
                        ),
                      );
                    }),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('${l10n.error}: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('${l10n.error}: $e')),
      ),
    );
  }

  Widget _buildPaymentSummary(
    BuildContext context,
    AppLocalizations l10n,
    int unpaidCount,
    double unpaidTotal,
    int overdueCount,
  ) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= AppBreakpoints.tablet ? 3 : 1;
    final cards = [
      (
        label: l10n.unpaidInvoices,
        value: unpaidCount.toString(),
        icon: Icons.pending_actions,
        color: AppColors.warning,
      ),
      (
        label: l10n.remainingToPay,
        value: AppFormatters.formatCurrency(unpaidTotal, l10n),
        icon: Icons.account_balance_wallet_outlined,
        color: AppColors.expense,
      ),
      (
        label: l10n.overdue,
        value: overdueCount.toString(),
        icon: Icons.warning_amber_rounded,
        color: AppColors.overdue,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: width >= AppBreakpoints.tablet ? 2.8 : 3.6,
      ),
      itemBuilder: (context, index) {
        final card = cards[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: card.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Icon(card.icon, color: card.color),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        card.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendReminder(
    BuildContext context,
    WidgetRef ref,
    dynamic invoice,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final clientName = invoice.client?.name ?? l10n.unknownClient;
    await Share.share(
      '${l10n.sendReminder}: ${invoice.invoiceNumber}\n'
      '${l10n.clientName}: $clientName\n'
      '${l10n.remainingToPay}: ${AppFormatters.formatCurrency(invoice.total, l10n)}',
      subject: '${l10n.sendReminder} ${invoice.invoiceNumber}',
    );
    await ref
        .read(invoiceRepositoryProvider)
        .updateLastReminderAt(invoice.id, DateTime.now());
    ref.invalidate(invoicesListProvider());
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.reminderLogged)));
  }
}
