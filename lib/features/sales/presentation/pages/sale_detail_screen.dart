import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hissab_dz/core/theme/theme.dart';
import 'package:hissab_dz/core/widgets/responsive_content.dart';
import 'package:hissab_dz/features/articles/domain/entities/article.dart';
import 'package:hissab_dz/features/articles/presentation/providers/article_providers.dart';
import 'package:hissab_dz/features/clients/presentation/providers/client_providers.dart';
import 'package:hissab_dz/features/sales/data/repositories/sale_repository.dart';
import 'package:hissab_dz/features/sales/domain/entities/sale.dart';
import 'package:hissab_dz/features/sales/presentation/providers/sale_providers.dart';
import 'package:hissab_dz/features/pos/presentation/providers/delivery_route_providers.dart';
import 'package:hissab_dz/features/sales/services/pdf_pos_receipt_service.dart';
import 'package:hissab_dz/features/settings/domain/entities/business_profile.dart';
import 'package:hissab_dz/features/settings/presentation/providers/settings_providers.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';

class SaleDetailScreen extends ConsumerWidget {
  final int saleId;

  const SaleDetailScreen({super.key, required this.saleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final saleAsync = ref.watch(saleDetailsProvider(saleId));
    final paymentsAsync = ref.watch(salePaymentsProvider(saleId));
    final returnsAsync = ref.watch(saleReturnsProvider(saleId));
    final articles = ref.watch(articlesListProvider).value ?? [];
    final clients = ref.watch(clientsListProvider).value ?? [];
    final profile = ref.watch(businessProfileProvider).value;
    final currencyFormat = NumberFormat.currency(locale: 'en', symbol: '');
    String formatCurrency(double amount) {
      final formatted = currencyFormat.format(amount).trim();
      return l10n.localeName == 'ar'
          ? '\u200F$formatted ${l10n.currencySymbol}'
          : '${l10n.currencySymbol} $formatted';
    }

    return Scaffold(
      appBar: AppBar(title: Text('${l10n.sale} #$saleId')),
      body: saleAsync.when(
        data: (sale) {
          if (sale == null) {
            return Center(child: Text(l10n.saleNotFound));
          }
          final remaining = sale.total - sale.paidAmount;
          return ResponsiveContent(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.bottomNavClearance,
              ),
              children: [
                Card(
                  child: ListTile(
                    title: Text(sale.saleNumber),
                    subtitle: Text('${sale.status} - ${sale.paymentStatus}'),
                    trailing: Text(formatCurrency(sale.total)),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    FilledButton.icon(
                      onPressed: remaining <= 0
                          ? null
                          : () => _showPaymentDialog(context, ref, sale),
                      icon: const Icon(Icons.payments_outlined),
                      label: Text(l10n.addPayment),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          context.push('/pos/sales/${sale.id}/return'),
                      icon: const Icon(Icons.assignment_return_outlined),
                      label: Text(l10n.returnLabel),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _generateInvoice(context, ref, sale.id!),
                      icon: const Icon(Icons.description_outlined),
                      label: Text(l10n.invoiceLabel),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _shareReceiptPdf(
                        context,
                        sale,
                        articles,
                        clients
                            .where((client) => client.id == sale.clientId)
                            .firstOrNull
                            ?.name,
                        profile,
                        l10n,
                      ),
                      icon: const Icon(Icons.share_outlined),
                      label: Text(l10n.pdfReceipt),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.products,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ...sale.items.map((item) {
                  final article = articles
                      .where((a) => a.id == item.articleId)
                      .firstOrNull;
                  return Card(
                    child: ListTile(
                      title: Text(article?.name ?? 'Article ${item.articleId}'),
                      subtitle: Text('x ${item.quantity}'),
                      trailing: Text(formatCurrency(item.total)),
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.payments,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                paymentsAsync.when(
                  data: (payments) => payments.isEmpty
                      ? ListTile(title: Text(l10n.noPayments))
                      : Column(
                          children: payments
                              .map(
                                (payment) => Card(
                                  child: ListTile(
                                    title: Text(
                                      formatCurrency(payment.amount),
                                    ),
                                    subtitle: Text(payment.method),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                  loading: () => const LinearProgressIndicator(),
                  error: (error, _) => Text('$error'),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(l10n.returns, style: Theme.of(context).textTheme.titleMedium),
                returnsAsync.when(
                  data: (returns) => returns.isEmpty
                      ? ListTile(title: Text(l10n.noReturns))
                      : Column(
                          children: returns
                              .map(
                                (saleReturn) => Card(
                                  child: ListTile(
                                    title: Text('${l10n.returnLabel} #${saleReturn.id}'),
                                    subtitle: Text(saleReturn.status),
                                    trailing: Text(
                                      formatCurrency(saleReturn.total),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                  loading: () => const LinearProgressIndicator(),
                  error: (error, _) => Text('$error'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
      ),
    );
  }

  Future<void> _showPaymentDialog(
    BuildContext context,
    WidgetRef ref,
    Sale sale,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final isAr = l10n.localeName == 'ar';
    final amountController = TextEditingController(
      text: (sale.total - sale.paidAmount).toStringAsFixed(2),
    );
    var method = 'cash';
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.addPayment),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: l10n.amount),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: method,
                decoration: InputDecoration(labelText: l10n.paymentMethod),
                items: [
                  DropdownMenuItem(value: 'cash', child: Text(l10n.cash)),
                  DropdownMenuItem(value: 'card', child: Text(l10n.card)),
                  DropdownMenuItem(
                    value: 'baridimob',
                    child: Text(l10n.baridiMob),
                  ),
                  DropdownMenuItem(value: 'credit', child: Text(l10n.credit)),
                ],
                onChanged: (value) => setState(() => method = value ?? 'cash'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final amt = double.tryParse(amountController.text.replaceAll(',', '.'));
                if (amt == null || amt <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isAr
                            ? 'الرجاء إدخال مبلغ صالح أكبر من الصفر'
                            : 'Veuillez saisir un montant valide supérieur à zéro',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                final remaining = sale.total - sale.paidAmount;
                if (amt > remaining) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isAr
                            ? 'المبلغ المدفوع لا يمكن أن يتجاوز المبلغ المتبقي'
                            : 'Le montant payé ne peut pas dépasser le solde restant',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.of(context).pop(true);
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
    if (saved != true || !context.mounted) return;

    final parsedAmount = double.parse(amountController.text.replaceAll(',', '.'));

    // Check active delivery route and warehouse match
    final activeRoute = ref.read(activeDeliveryRouteProvider).value;
    int? routeId;
    if (activeRoute != null) {
      if (activeRoute.warehouseId == sale.warehouseId) {
        routeId = activeRoute.id;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isAr
                    ? 'تنبيه: مستودع الجولة يختلف عن مستودع البيع. لن يتم ربط الدفع بالجولة.'
                    : 'Attention : le dépôt de la tournée diffère de celui de la vente. Le paiement ne sera pas lié.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }

    try {
      await ref
          .read(saleRepositoryProvider)
          .addSalePayment(
            saleId: sale.id!,
            amount: parsedAmount,
            method: method,
            routeId: routeId,
          );
      ref.invalidate(saleDetailsProvider(sale.id!));
      ref.invalidate(salePaymentsProvider(sale.id!));
      if (activeRoute != null && routeId != null) {
        // Also invalidate the report for active route to update aggregates immediately
        ref.invalidate(deliveryRouteReportProvider(routeId));
      }
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  Future<void> _generateInvoice(
    BuildContext context,
    WidgetRef ref,
    int saleId,
  ) async {
    final invoiceId = await ref
        .read(saleRepositoryProvider)
        .generateInvoiceFromSale(saleId);
    if (!context.mounted) return;
    context.push('/invoices/$invoiceId');
  }

  Future<void> _shareReceiptPdf(
    BuildContext context,
    Sale sale,
    List<Article> articles,
    String? clientName,
    BusinessProfile? profile,
    AppLocalizations l10n,
  ) async {
    try {
      final file = await PdfPosReceiptService.generateReceiptPdf(
        sale: sale,
        articles: articles,
        l10n: l10n,
        profile: profile,
        clientName: clientName,
      );
      await Share.shareXFiles([
        XFile(file.path),
      ], text: '${l10n.pdfReceipt} ${sale.saleNumber}');
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }
}
