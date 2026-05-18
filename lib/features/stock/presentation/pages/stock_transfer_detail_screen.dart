import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hissab_dz/core/database/database_provider.dart';
import 'package:hissab_dz/core/theme/theme.dart';
import 'package:hissab_dz/core/widgets/responsive_content.dart';
import 'package:hissab_dz/features/articles/presentation/providers/article_providers.dart';
import 'package:hissab_dz/features/stock/data/repositories/stock_transfer_repository.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';

class StockTransferDetailScreen extends ConsumerWidget {
  final int transferId;

  const StockTransferDetailScreen({super.key, required this.transferId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(articlesListProvider).value ?? [];
    final db = ref.watch(appDatabaseProvider);

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text('${l10n.truckLoading} #$transferId')),
      body: FutureBuilder(
        future: ref
            .watch(stockTransferRepositoryProvider)
            .getTransferById(transferId),
        builder: (context, snapshot) {
          final transfer = snapshot.data;
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (transfer == null) {
            return Center(child: Text(l10n.loadingNotFound));
          }

          return FutureBuilder(
            future: db.select(db.warehouses).get(),
            builder: (context, warehousesSnapshot) {
              final warehouses = warehousesSnapshot.data ?? [];
              final from = warehouses
                  .where(
                    (warehouse) => warehouse.id == transfer.fromWarehouseId,
                  )
                  .firstOrNull;
              final to = warehouses
                  .where((warehouse) => warehouse.id == transfer.toWarehouseId)
                  .firstOrNull;

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
                        title: Text(
                          transfer.status == 'confirmed'
                              ? l10n.validated
                              : l10n.draft,
                        ),
                        subtitle: Text(
                          '${DateFormat('dd/MM/yyyy').format(transfer.date)}\n${from?.name ?? '-'} -> ${to?.name ?? '-'}',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...transfer.items.map((item) {
                      final article = articles
                          .where((a) => a.id == item.articleId)
                          .firstOrNull;
                      return Card(
                        child: ListTile(
                          title: Text(
                            article?.name ?? '${l10n.article} ${item.articleId}',
                          ),
                          trailing: Text('x ${item.quantity}'),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
