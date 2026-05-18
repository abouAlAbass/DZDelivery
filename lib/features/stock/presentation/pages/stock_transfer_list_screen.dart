import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hissab_dz/core/theme/theme.dart';
import 'package:hissab_dz/core/widgets/app_drawer.dart';
import 'package:hissab_dz/core/widgets/app_empty_state.dart';
import 'package:hissab_dz/core/widgets/contextual_fab.dart';
import 'package:hissab_dz/core/widgets/responsive_content.dart';
import 'package:hissab_dz/features/stock/presentation/providers/stock_providers.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';

class StockTransferListScreen extends ConsumerWidget {
  const StockTransferListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final transfersAsync = ref.watch(stockTransfersListProvider);
    final dateFormat = DateFormat('dd/MM/yyyy', l10n.localeName);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.truckLoading)),
      drawer: MediaQuery.sizeOf(context).width >= 1100
          ? null
          : const AppDrawer(),
      body: transfersAsync.when(
        data: (transfers) {
          if (transfers.isEmpty) {
            return AppEmptyState(
              icon: Icons.local_shipping_outlined,
              title: l10n.noLoadingYet,
              subtitle: l10n.createLoadingInstructions,
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
              itemCount: transfers.length,
              itemBuilder: (context, index) {
                final transfer = transfers[index];
                final confirmed = transfer.status == 'confirmed';

                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: ListTile(
                    onTap: () =>
                        context.push('/pos/truck-loading/${transfer.id}'),
                    leading: CircleAvatar(
                      backgroundColor:
                          (confirmed ? AppColors.success : AppColors.warning)
                              .withValues(alpha: 0.14),
                      child: Icon(
                        confirmed
                            ? Icons.check_circle_outline
                            : Icons.pending_actions_outlined,
                        color: confirmed
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                    title: Text('${l10n.truckLoading} #${transfer.id ?? '-'}'),
                    subtitle: Text(
                      '${dateFormat.format(transfer.date)} - ${transfer.items.length} ${l10n.articles.toLowerCase()} - ${confirmed ? l10n.validated : l10n.draft}',
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
        onPressed: () => context.pushNamed('create_stock_transfer'),
        tooltip: l10n.newTruckLoading,
        icon: Icons.add,
        label: l10n.newTruckLoading,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
