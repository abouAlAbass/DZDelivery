import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hissab_dz/core/theme/theme.dart';
import 'package:hissab_dz/core/widgets/app_drawer.dart';
import 'package:hissab_dz/core/widgets/app_empty_state.dart';
import 'package:hissab_dz/core/widgets/contextual_fab.dart';
import 'package:hissab_dz/core/widgets/responsive_content.dart';
import 'package:hissab_dz/features/purchases/presentation/providers/purchase_providers.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';

class PurchaseListScreen extends ConsumerWidget {
  const PurchaseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final purchasesAsync = ref.watch(purchasesListProvider);
    final currencyFormat = NumberFormat.currency(locale: 'en', symbol: l10n.currencySymbol);
    final dateFormat = DateFormat('dd/MM/yyyy', 'en');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.purchases)),
      drawer: MediaQuery.sizeOf(context).width >= 1100
          ? null
          : const AppDrawer(),
      body: purchasesAsync.when(
        data: (purchases) {
          if (purchases.isEmpty) {
            return AppEmptyState(
              icon: Icons.add_shopping_cart_outlined,
              title: l10n.noPurchasesFound,
              subtitle: l10n.localeName == 'ar'
                  ? 'قم بإنشاء شراء لإدخال المخزون إلى المستودع.'
                  : l10n.localeName == 'en'
                      ? 'Create a purchase to enter stock in depot.'
                      : 'Créez un achat pour entrer du stock au dépôt.',
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
              itemCount: purchases.length,
              itemBuilder: (context, index) {
                final purchase = purchases[index];
                final isConfirmed = purchase.status == 'confirmed';

                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: ListTile(
                    onTap: () => context.push('/purchases/${purchase.id}'),
                    leading: CircleAvatar(
                      backgroundColor:
                          (isConfirmed ? AppColors.success : AppColors.warning)
                              .withValues(alpha: 0.14),
                      child: Icon(
                        isConfirmed
                            ? Icons.check_circle_outline
                            : Icons.pending_actions_outlined,
                        color: isConfirmed
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                    title: Text('${l10n.purchaseLabel} #${purchase.id ?? '-'}'),
                    subtitle: Text(
                      '${dateFormat.format(purchase.date)} - ${purchase.items.length} ${l10n.products.toLowerCase()} - ${isConfirmed ? l10n.validated : l10n.draft}',
                    ),
                    trailing: Text(
                      currencyFormat.format(purchase.total),
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
        onPressed: () => context.pushNamed('create_purchase'),
        tooltip: l10n.newPurchase,
        icon: Icons.add,
        label: l10n.newPurchase,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
