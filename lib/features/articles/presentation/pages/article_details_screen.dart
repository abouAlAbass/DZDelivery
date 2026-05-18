import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hissab_dz/core/theme/theme.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';
import '../providers/article_details_providers.dart';

class ArticleDetailsScreen extends ConsumerStatefulWidget {
  final int articleId;

  const ArticleDetailsScreen({super.key, required this.articleId});

  @override
  ConsumerState<ArticleDetailsScreen> createState() => _ArticleDetailsScreenState();
}

class _ArticleDetailsScreenState extends ConsumerState<ArticleDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final currentRange = ref.read(articleDetailsDateFilterProvider);
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: currentRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Adjust end date to include the whole day
      final adjustedRange = DateTimeRange(
        start: picked.start,
        end: picked.end.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1)),
      );
      ref.read(articleDetailsDateFilterProvider.notifier).setFilter(adjustedRange);
    }
  }
  @override
  Widget build(BuildContext context) {
    final articleAsync = ref.watch(articleDetailsProvider(widget.articleId));
    final dateFilter = ref.watch(articleDetailsDateFilterProvider);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: articleAsync.when(
          data: (article) => Text(article?.name ?? l10n.productDetails),
          loading: () => Text(l10n.localeName == 'ar' ? 'جاري التحميل...' : 'Chargement...'),
          error: (_, __) => Text(l10n.localeName == 'ar' ? 'خطأ' : 'Erreur'),
        ),
        actions: [
          IconButton(
            icon: Icon(dateFilter != null ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: _selectDateRange,
            tooltip: l10n.filterDate,
          ),
          if (dateFilter != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => ref.read(articleDetailsDateFilterProvider.notifier).setFilter(null),
              tooltip: l10n.clearFilter,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.salesTab),
            Tab(text: l10n.purchasesTab),
            Tab(text: l10n.movementsTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SalesTab(articleId: widget.articleId),
          _PurchasesTab(articleId: widget.articleId),
          _StockMovementsTab(articleId: widget.articleId),
        ],
      ),
    );
  }
}

class _SalesTab extends ConsumerWidget {
  final int articleId;

  const _SalesTab({required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(articleSalesFilteredProvider(articleId));
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(locale: 'en', symbol: l10n.currencySymbol);
    final quantityFormat = NumberFormat.decimalPattern('en');

    return salesAsync.when(
      data: (sales) {
        if (sales.isEmpty) {
          return Center(child: Text(l10n.noSalesFound));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: sales.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final enriched = sales[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.receipt_long, color: AppColors.success),
              title: Text(enriched.sale.saleNumber),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('dd/MM/yyyy', 'en').format(enriched.sale.date)),
                  if (enriched.client != null)
                    Text('Client: ${enriched.client!.name}'),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_formatQuantity(quantityFormat, enriched.item.quantity)} x ${currencyFormat.format(enriched.item.unitPrice)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    currencyFormat.format(enriched.item.total),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }
}

class _PurchasesTab extends ConsumerWidget {
  final int articleId;

  const _PurchasesTab({required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasesAsync = ref.watch(articlePurchasesFilteredProvider(articleId));
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(locale: 'en', symbol: l10n.currencySymbol);
    final quantityFormat = NumberFormat.decimalPattern('en');

    return purchasesAsync.when(
      data: (purchases) {
        if (purchases.isEmpty) {
          return Center(child: Text(l10n.noPurchasesFound));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: purchases.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final enriched = purchases[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.shopping_cart, color: AppColors.warning),
              title: Text('${l10n.purchaseLabel} #${enriched.purchase.id}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('dd/MM/yyyy', 'en').format(enriched.purchase.date)),
                  if (enriched.supplier != null)
                    Text('Fournisseur: ${enriched.supplier!.name}'),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_formatQuantity(quantityFormat, enriched.item.quantity)} x ${currencyFormat.format(enriched.item.purchasePrice)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    currencyFormat.format(enriched.item.quantity * enriched.item.purchasePrice),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }
}

class _StockMovementsTab extends ConsumerWidget {
  final int articleId;

  const _StockMovementsTab({required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movementsAsync = ref.watch(articleStockMovementsFilteredProvider(articleId));
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(locale: 'en', symbol: l10n.currencySymbol);
    final quantityFormat = NumberFormat.decimalPattern('en');

    return movementsAsync.when(
      data: (movements) {
        if (movements.isEmpty) {
          return Center(child: Text(l10n.noMovementsFound));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: movements.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final enriched = movements[index];
            final movement = enriched.movement;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                movement.quantity >= 0
                    ? Icons.add_circle_outline
                    : Icons.remove_circle_outline,
                color: movement.quantity >= 0 ? AppColors.success : AppColors.danger,
              ),
              title: Text(movement.type),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('dd/MM/yyyy HH:mm', 'en').format(movement.createdAt)),
                  if (enriched.warehouse != null)
                    Text(
                      'Dépôt: ${enriched.warehouse!.name}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (enriched.sourceName != null)
                    Text(
                      enriched.sourceName!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatQuantity(quantityFormat, movement.quantity),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    currencyFormat.format(movement.unitPrice),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }
}

String _formatQuantity(NumberFormat formatter, double value) {
  if (value == value.roundToDouble()) {
    return formatter.format(value.round());
  }
  return formatter.format(value);
}
