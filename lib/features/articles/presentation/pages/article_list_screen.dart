import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hissab_dz/core/theme/theme.dart';
import 'package:hissab_dz/core/widgets/app_empty_state.dart';
import 'package:hissab_dz/core/widgets/contextual_fab.dart';
import 'package:hissab_dz/core/widgets/responsive_content.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';
import 'package:hissab_dz/core/widgets/app_drawer.dart';
import 'package:hissab_dz/features/articles/domain/entities/article.dart';
import 'package:hissab_dz/features/articles/presentation/providers/article_providers.dart';

enum _ArticleFilter { all, physical, service, lowStock, inactive }

class ArticleListScreen extends ConsumerStatefulWidget {
  const ArticleListScreen({super.key});

  @override
  ConsumerState<ArticleListScreen> createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends ConsumerState<ArticleListScreen> {
  final _searchController = TextEditingController();
  _ArticleFilter _filter = _ArticleFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final articlesAsync = ref.watch(articlesListProvider);
    final stockSummariesAsync = ref.watch(articleStockSummariesProvider);
    final currencyFormat = NumberFormat.currency(symbol: l10n.currencySymbol);
    final quantityFormat = NumberFormat.decimalPattern(l10n.localeName);
    final isAr = l10n.localeName == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.articles)),
      drawer: MediaQuery.sizeOf(context).width >= 1100
          ? null
          : const AppDrawer(),
      body: articlesAsync.when(
        data: (articles) {
          final stockSummaries = stockSummariesAsync.value ?? const {};
          final filtered = _filterArticles(articles, stockSummaries);
          if (articles.isEmpty) {
            return AppEmptyState(
              icon: Icons.inventory_2_outlined,
              title: l10n.noArticles,
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
              itemCount: filtered.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _ArticleSearchAndFilters(
                    controller: _searchController,
                    hintText: l10n.searchArticles,
                    resultCount: filtered.length,
                    filter: _filter,
                    isAr: isAr,
                    onSearchChanged: (_) => setState(() {}),
                    onFilterChanged: (filter) =>
                        setState(() => _filter = filter),
                  );
                }

                final article = filtered[index - 1];
                final stock = stockSummaries[article.id ?? -1];

                return _ArticleStockCard(
                  article: article,
                  depotStock: stock?.depotQuantity ?? 0,
                  truckStock: stock?.truckQuantity ?? 0,
                  currencyFormat: currencyFormat,
                  quantityFormat: quantityFormat,
                  onEdit: () => context.pushNamed(
                    'edit_article',
                    pathParameters: {'id': article.id.toString()},
                  ),
                  onViewDetails: article.id == null
                      ? null
                      : () => context.pushNamed(
                          'article_details',
                          pathParameters: {'id': article.id.toString()},
                        ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('${l10n.error}: $e')),
      ),
      floatingActionButton: ContextualFab(
        onPressed: () => context.pushNamed('add_article'),
        tooltip: l10n.addArticle,
        icon: Icons.add,
        label: l10n.addArticle,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  List<Article> _filterArticles(
    List<Article> articles,
    Map<int, ArticleStockSummary> stockSummaries,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    return articles.where((article) {
      final stock = stockSummaries[article.id ?? -1];
      final totalStock =
          (stock?.depotQuantity ?? 0) + (stock?.truckQuantity ?? 0);
      final lowStock =
          article.type != 'service' &&
          article.minStock > 0 &&
          totalStock <= article.minStock;
      final haystack = [
        article.name,
        article.code,
        article.barcode,
        article.category,
        article.unit,
      ].whereType<String>().join(' ').toLowerCase();
      final matchesQuery = query.isEmpty || haystack.contains(query);
      final matchesFilter = switch (_filter) {
        _ArticleFilter.all => true,
        _ArticleFilter.physical =>
          article.type != 'service' && article.isActive,
        _ArticleFilter.service => article.type == 'service' && article.isActive,
        _ArticleFilter.lowStock => lowStock && article.isActive,
        _ArticleFilter.inactive => !article.isActive,
      };
      return matchesQuery && matchesFilter;
    }).toList();
  }
}

class _ArticleSearchAndFilters extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int resultCount;
  final _ArticleFilter filter;
  final bool isAr;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<_ArticleFilter> onFilterChanged;

  const _ArticleSearchAndFilters({
    required this.controller,
    required this.hintText,
    required this.resultCount,
    required this.filter,
    required this.isAr,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          controller.clear();
                          onSearchChanged('');
                        },
                      ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _chip(_ArticleFilter.all, isAr ? 'الكل' : 'Tous'),
                _chip(_ArticleFilter.physical, isAr ? 'مخزون' : 'Physiques'),
                _chip(_ArticleFilter.service, isAr ? 'خدمات' : 'Services'),
                _chip(
                  _ArticleFilter.lowStock,
                  isAr ? 'مخزون منخفض' : 'Stock bas',
                ),
                _chip(_ArticleFilter.inactive, isAr ? 'غير نشط' : 'Inactifs'),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isAr ? '$resultCount نتيجة' : '$resultCount produit(s)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(_ArticleFilter value, String label) {
    return FilterChip(
      selected: filter == value,
      label: Text(label),
      onSelected: (_) => onFilterChanged(value),
    );
  }
}

class _ArticleStockCard extends StatelessWidget {
  final Article article;
  final double depotStock;
  final double truckStock;
  final NumberFormat currencyFormat;
  final NumberFormat quantityFormat;
  final VoidCallback onEdit;
  final VoidCallback? onViewDetails;

  const _ArticleStockCard({
    required this.article,
    required this.depotStock,
    required this.truckStock,
    required this.currencyFormat,
    required this.quantityFormat,
    required this.onEdit,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final salePrice = article.salePrice == 0
        ? article.price
        : article.salePrice;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: const Icon(Icons.inventory_2, color: AppColors.info),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (article.barcode != null || article.code != null) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          [article.code, article.barcode]
                              .whereType<String>()
                              .where((value) => value.isNotEmpty)
                              .join(' - '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Vente : ${currencyFormat.format(salePrice)} | Achat : ${currencyFormat.format(article.purchasePrice)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Depot : ${_formatQuantity(quantityFormat, depotStock)} | Camion : ${_formatQuantity(quantityFormat, truckStock)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Modifier article'),
                ),
                OutlinedButton.icon(
                  onPressed: onViewDetails,
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Détails & Mouvements'),
                ),
              ],
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
