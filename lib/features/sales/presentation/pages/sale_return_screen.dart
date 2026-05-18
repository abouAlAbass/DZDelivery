import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hissab_dz/core/theme/theme.dart';
import 'package:hissab_dz/core/widgets/responsive_content.dart';
import 'package:hissab_dz/features/articles/presentation/providers/article_providers.dart';
import 'package:hissab_dz/features/sales/data/repositories/sale_repository.dart';
import 'package:hissab_dz/features/sales/domain/entities/sale.dart';
import 'package:hissab_dz/features/sales/presentation/providers/sale_providers.dart';
import 'package:hissab_dz/features/pos/presentation/providers/delivery_route_providers.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';

class SaleReturnScreen extends ConsumerStatefulWidget {
  final int saleId;

  const SaleReturnScreen({super.key, required this.saleId});

  @override
  ConsumerState<SaleReturnScreen> createState() => _SaleReturnScreenState();
}

class _SaleReturnScreenState extends ConsumerState<SaleReturnScreen> {
  final _controllers = <int, TextEditingController>{};
  bool _isSaving = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final saleAsync = ref.watch(saleDetailsProvider(widget.saleId));
    final articles = ref.watch(articlesListProvider).value ?? [];
    final currencyFormat = NumberFormat.currency(locale: 'en', symbol: l10n.currencySymbol);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.saleReturn)),
      body: saleAsync.when(
        data: (sale) {
          if (sale == null) {
            return Center(child: Text(l10n.saleNotFound));
          }
          for (final item in sale.items) {
            _controllers.putIfAbsent(
              item.articleId,
              () => TextEditingController(text: '0'),
            );
          }
          final total = _returnTotal(sale);

          return ResponsiveContent(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.bottomNavClearance,
              ),
              children: [
                ...sale.items.map((item) {
                  final article = articles
                      .where((a) => a.id == item.articleId)
                      .firstOrNull;
                  return Card(
                    child: ListTile(
                      title: Text(article?.name ?? 'Article ${item.articleId}'),
                      subtitle: Text('Vendu : ${item.quantity}'),
                      trailing: SizedBox(
                        width: 110,
                        child: TextField(
                          controller: _controllers[item.articleId],
                          decoration: InputDecoration(
                            labelText: l10n.returnLabel,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.,]'),
                            ),
                          ],
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.md),
                Card(
                  child: ListTile(
                    title: Text(l10n.totalReturn),
                    trailing: Text(currencyFormat.format(total)),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: _isSaving ? null : () => _confirmReturn(sale),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(l10n.confirmReturn),
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

  double _returnTotal(Sale sale) {
    return sale.items.fold(0, (sum, item) {
      final quantity = _parse(_controllers[item.articleId]?.text ?? '0');
      return sum + (quantity * item.unitPrice);
    });
  }

  Future<void> _confirmReturn(Sale sale) async {
    final l10n = AppLocalizations.of(context)!;
    final items = sale.items
        .map((item) {
          final quantity = _parse(_controllers[item.articleId]?.text ?? '0');
          return SaleReturnItem(
            articleId: item.articleId,
            quantity: quantity,
            unitPrice: item.unitPrice,
            total: quantity * item.unitPrice,
          );
        })
        .where((item) => item.quantity > 0)
        .toList();
    if (items.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmReturn),
        content: Text(l10n.confirmReturnMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isSaving = true);
    try {
      final isAr = l10n.localeName == 'ar';
      final activeRoute = ref.read(activeDeliveryRouteProvider).value;
      int? routeId;
      if (activeRoute != null) {
        if (activeRoute.warehouseId == sale.warehouseId) {
          routeId = activeRoute.id;
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isAr
                      ? 'تنبيه: مستودع الجولة يختلف عن مستودع البيع. لن يتم ربط الإرجاع بالجولة.'
                      : 'Attention : le dépôt de la tournée diffère de celui de la vente. Le retour ne sera pas lié.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }

      final saleReturn = SaleReturn(
        saleId: sale.id,
        clientId: sale.clientId,
        warehouseId: sale.warehouseId,
        date: DateTime.now(),
        total: items.fold(0, (sum, item) => sum + item.total),
        items: items,
        routeId: routeId,
      );
      final repository = ref.read(saleRepositoryProvider);
      final returnId = await repository.createSaleReturn(saleReturn);
      await repository.confirmSaleReturn(returnId);
      ref.invalidate(saleReturnsProvider(sale.id!));
      if (activeRoute != null && routeId != null) {
        ref.invalidate(deliveryRouteReportProvider(routeId));
      }
      if (!mounted) return;
      context.pop();
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  double _parse(String value) =>
      double.tryParse(value.replaceAll(',', '.')) ?? 0;
}
