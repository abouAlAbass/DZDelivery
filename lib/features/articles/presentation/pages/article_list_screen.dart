import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hissab_dz/core/theme/theme.dart';
import 'package:hissab_dz/core/widgets/app_empty_state.dart';
import 'package:hissab_dz/core/widgets/contextual_fab.dart';
import 'package:hissab_dz/core/widgets/entity_card.dart';
import 'package:hissab_dz/core/widgets/responsive_content.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';
import 'package:hissab_dz/core/widgets/app_drawer.dart';
import 'package:hissab_dz/features/articles/presentation/providers/article_providers.dart';

class ArticleListScreen extends ConsumerWidget {
  const ArticleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final articlesAsync = ref.watch(filteredArticlesProvider);
    final currencyFormat = NumberFormat.currency(symbol: l10n.currencySymbol);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.articles),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (value) =>
                  ref.read(articleSearchQueryProvider.notifier).update(value),
              decoration: InputDecoration(
                hintText: l10n.searchArticles,
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      drawer: MediaQuery.sizeOf(context).width >= 1100
          ? null
          : const AppDrawer(),
      body: articlesAsync.when(
        data: (articles) {
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
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                final isService = article.type == 'service';
                final categoryLabel = _categoryLabel(l10n, article.category);
                return EntityCard(
                  icon: isService ? Icons.build_circle : Icons.inventory_2,
                  color: isService ? AppColors.warning : AppColors.info,
                  title: article.name,
                  subtitle:
                      '${article.code != null ? "${article.code} - " : ""}${article.unit} - $categoryLabel - ${isService ? l10n.service : l10n.physical}',
                  amount: currencyFormat.format(article.price),
                  onTap: () => context.pushNamed(
                    'edit_article',
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  String _categoryLabel(AppLocalizations l10n, String category) {
    switch (category) {
      case 'labor':
        return l10n.laborCategory;
      case 'materials':
        return l10n.materialsCategory;
      case 'travel':
        return l10n.travelCategory;
      case 'rental':
        return l10n.rentalCategory;
      case 'service':
        return l10n.service;
      case 'supply':
        return l10n.supplyCategory;
      default:
        return category;
    }
  }
}
