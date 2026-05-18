import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hissab_dz/core/theme/theme.dart';
import 'package:hissab_dz/core/widgets/app_drawer.dart';
import 'package:hissab_dz/core/widgets/app_empty_state.dart';
import 'package:hissab_dz/core/widgets/contextual_fab.dart';
import 'package:hissab_dz/core/widgets/responsive_content.dart';
import 'package:hissab_dz/features/sales/presentation/providers/sale_providers.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';

class SaleListScreen extends ConsumerWidget {
  const SaleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final salesAsync = ref.watch(salesListProvider);
    final currencyFormat = NumberFormat.currency(locale: 'en', symbol: '');
    String formatCurrency(double amount) {
      final formatted = currencyFormat.format(amount).trim();
      return l10n.localeName == 'ar'
          ? '\u200F$formatted ${l10n.currencySymbol}'
          : '${l10n.currencySymbol} $formatted';
    }
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'en');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sales)),
      drawer: MediaQuery.sizeOf(context).width >= 1100
          ? null
          : const AppDrawer(),
      body: salesAsync.when(
        data: (sales) {
          if (sales.isEmpty) {
            return AppEmptyState(
              icon: Icons.point_of_sale_outlined,
              title: l10n.noSales,
              subtitle: l10n.createQuickSaleInstructions,
            );
          }
          return ResponsiveContent(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xs,
                AppSpacing.xs,
                AppSpacing.xs,
                AppSpacing.bottomNavClearance,
              ),
              itemCount: sales.length,
              itemBuilder: (context, index) {
                final sale = sales[index];
                return Card(
                  child: ListTile(
                    onTap: () => context.push('/pos/sales/${sale.id}'),
                    leading: const CircleAvatar(
                      child: Icon(Icons.receipt_long),
                    ),
                    title: Text(sale.saleNumber),
                    subtitle: Text(
                      '${dateFormat.format(sale.date)} - ${sale.paymentStatus}',
                    ),
                    trailing: Text(
                      formatCurrency(sale.total),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
      ),
      floatingActionButton: ContextualFab(
        onPressed: () => context.go('/pos/quick-sale'),
        tooltip: l10n.quickSale,
        icon: Icons.add,
        label: l10n.quickSale,
      ),
    );
  }
}
