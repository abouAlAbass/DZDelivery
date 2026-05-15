import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hissab_dz/core/utils/app_formatters.dart';
import 'package:hissab_dz/core/theme/theme.dart';
import 'package:hissab_dz/core/widgets/app_empty_state.dart';
import 'package:hissab_dz/core/widgets/app_drawer.dart';
import 'package:hissab_dz/core/widgets/contextual_fab.dart';
import 'package:hissab_dz/core/widgets/entity_card.dart';
import 'package:hissab_dz/core/widgets/responsive_content.dart';
import 'package:hissab_dz/features/quotes/presentation/providers/quote_providers.dart';
import 'package:hissab_dz/features/quotes/presentation/widgets/quote_status_label.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';

class QuoteListScreen extends ConsumerWidget {
  const QuoteListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final quotesAsync = ref.watch(quotesListProvider);
    final dateFormat = l10n.localeName == 'ar'
        ? DateFormat('dd/MM/yyyy', 'en')
        : DateFormat.yMMMd(l10n.localeName);

    return Scaffold(
      drawer: MediaQuery.sizeOf(context).width >= 1100
          ? null
          : const AppDrawer(),
      appBar: AppBar(title: Text(l10n.quotes)),
      body: quotesAsync.when(
        data: (quotes) {
          if (quotes.isEmpty) {
            return AppEmptyState(
              icon: Icons.request_quote_outlined,
              title: l10n.noQuotes,
              action: ElevatedButton.icon(
                onPressed: () => context.pushNamed('create_quote'),
                icon: const Icon(Icons.add),
                label: Text(l10n.createQuote),
              ),
            );
          }

          return ResponsiveContent(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.bottomNavClearance,
              ),
              itemCount: quotes.length,
              itemBuilder: (context, index) {
                final quote = quotes[index];
                return EntityCard(
                  icon: Icons.request_quote_outlined,
                  color: AppColors.quote,
                  title: quote.client?.name ?? l10n.unknownClient,
                  subtitle: [
                    '${quote.quoteNumber} - ${dateFormat.format(quote.issueDate)}',
                    if (quote.projectName != null)
                      '${l10n.project}: ${quote.projectName}',
                  ].join('\n'),
                  amount: AppFormatters.formatCurrency(quote.total, l10n),
                  badge: QuoteStatusChip(status: quote.status),
                  onTap: () => context.pushNamed(
                    'quote_details',
                    pathParameters: {'id': quote.id.toString()},
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
        onPressed: () => context.pushNamed('create_quote'),
        tooltip: l10n.createQuote,
        icon: Icons.add,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
