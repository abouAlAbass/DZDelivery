import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hissab_dz/core/theme/theme.dart';
import 'package:hissab_dz/core/widgets/app_drawer.dart';
import 'package:hissab_dz/core/widgets/app_empty_state.dart';
import 'package:hissab_dz/core/widgets/responsive_content.dart';
import 'package:hissab_dz/features/stock/domain/entities/stock_overview.dart';
import 'package:hissab_dz/features/stock/presentation/providers/stock_providers.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';

class StockOverviewScreen extends ConsumerWidget {
  const StockOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final overviewAsync = ref.watch(articleStockOverviewProvider);
    final currencyFormat = NumberFormat.currency(symbol: l10n.currencySymbol);
    final quantityFormat = NumberFormat.decimalPattern(l10n.localeName);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.stockPos)),
      drawer: MediaQuery.sizeOf(context).width >= 1100
          ? null
          : const AppDrawer(),
      body: overviewAsync.when(
        data: (rows) {
          if (rows.isEmpty) {
            return AppEmptyState(
              icon: Icons.inventory_2_outlined,
              title: l10n.noStock,
              subtitle: l10n.noStockInstructions,
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
              itemCount: rows.length,
              itemBuilder: (context, index) {
                return _StockOverviewCard(
                  row: rows[index],
                  currencyFormat: currencyFormat,
                  quantityFormat: quantityFormat,
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
      ),
    );
  }
}

class _StockOverviewCard extends StatelessWidget {
  final ArticleStockOverview row;
  final NumberFormat currencyFormat;
  final NumberFormat quantityFormat;

  const _StockOverviewCard({
    required this.row,
    required this.currencyFormat,
    required this.quantityFormat,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              row.articleName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (row.articleCode != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                row.articleCode!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${l10n.sale} : ${currencyFormat.format(row.salePrice)} | ${l10n.purchaseLabel} : ${currencyFormat.format(row.purchasePrice)}',
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: row.warehouseStocks
                  .map(
                    (stock) => Chip(
                      avatar: Icon(
                        stock.warehouseType == 'truck'
                            ? Icons.local_shipping_outlined
                            : Icons.warehouse_outlined,
                        size: 18,
                      ),
                      label: Text(
                        '${stock.warehouseName}: ${_formatQuantity(quantityFormat, stock.quantity)}',
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatQuantity(NumberFormat formatter, double value) {
  if (value == value.roundToDouble()) {
    return formatter.format(value.round());
  }
  return formatter.format(value);
}
