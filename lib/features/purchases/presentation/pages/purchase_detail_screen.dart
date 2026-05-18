import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hissab_dz/core/theme/theme.dart';
import 'package:hissab_dz/core/widgets/responsive_content.dart';
import 'package:hissab_dz/features/articles/presentation/providers/article_providers.dart';
import 'package:hissab_dz/features/purchases/data/repositories/purchase_repository.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';

class PurchaseDetailScreen extends ConsumerWidget {
  final int purchaseId;

  const PurchaseDetailScreen({super.key, required this.purchaseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(locale: 'en', symbol: l10n.currencySymbol);
    final articles = ref.watch(articlesListProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(title: Text('${l10n.purchaseLabel} #$purchaseId')),
      body: FutureBuilder(
        future: ref
            .watch(purchaseRepositoryProvider)
            .getPurchaseById(purchaseId),
        builder: (context, snapshot) {
          final purchase = snapshot.data;
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (purchase == null) {
            return Center(child: Text(l10n.purchaseNotFound));
          }

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
                      purchase.status == 'confirmed' ? l10n.validated : l10n.draft,
                    ),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy', 'en').format(purchase.date),
                    ),
                    trailing: Text(currencyFormat.format(purchase.total)),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...purchase.items.map((item) {
                  final article = articles
                      .where((a) => a.id == item.articleId)
                      .firstOrNull;
                  return Card(
                    child: ListTile(
                      title: Text(article?.name ?? 'Article ${item.articleId}'),
                      subtitle: Text('${l10n.quantity} : ${item.quantity}'),
                      trailing: Text(currencyFormat.format(item.total)),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
