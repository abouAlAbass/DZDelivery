import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hissab_dz/core/utils/app_formatters.dart';
import 'package:hissab_dz/core/theme/theme.dart';
import 'package:hissab_dz/core/widgets/app_drawer.dart';
import 'package:hissab_dz/features/search/domain/entities/global_search_result.dart';
import 'package:hissab_dz/features/search/presentation/providers/global_search_providers.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final query = ref.watch(globalSearchQueryProvider);
    final resultsAsync = ref.watch(globalSearchResultsProvider);

    return Scaffold(
      drawer: MediaQuery.sizeOf(context).width >= 1100
          ? null
          : const AppDrawer(),
      appBar: AppBar(title: Text(l10n.globalSearch)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchEverything,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l10n.cancel,
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _controller.clear();
                          ref.read(globalSearchQueryProvider.notifier).state =
                              '';
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                ref.read(globalSearchQueryProvider.notifier).state = value;
              },
            ),
          ),
          Expanded(
            child: query.trim().length < 2
                ? _SearchEmptyHint(l10n: l10n)
                : resultsAsync.when(
                    data: (results) {
                      if (results.isEmpty) {
                        return Center(child: Text(l10n.noSearchResults));
                      }
                      final grouped = _groupResults(results);
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 112),
                        children: grouped.entries.expand((entry) {
                          return [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
                              child: Text(
                                _typeLabel(l10n, entry.key),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            ...entry.value.map(
                              (result) => Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Icon(result.icon, size: 20),
                                  ),
                                  title: Text(
                                    result.title.isEmpty
                                        ? _typeLabel(l10n, result.type)
                                        : result.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  subtitle: Text(
                                    [
                                          result.subtitle,
                                          if (result.date != null)
                                            l10n.localeName == 'ar'
                                                ? DateFormat('dd/MM/yyyy', 'en').format(result.date!)
                                                : DateFormat.yMMMd(l10n.localeName).format(result.date!),
                                        ]
                                        .where((value) => value.isNotEmpty)
                                        .join(' - '),
                                  ),
                                  trailing: result.amount == null
                                      ? const Icon(Icons.chevron_right)
                                      : Text(
                                          AppFormatters.formatCurrency(result.amount!, l10n),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                  onTap: () => _openResult(context, result),
                                ),
                              ),
                            ),
                          ];
                        }).toList(),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(child: Text('${l10n.error}: $e')),
                  ),
          ),
        ],
      ),
    );
  }

  Map<GlobalSearchType, List<GlobalSearchResult>> _groupResults(
    List<GlobalSearchResult> results,
  ) {
    final grouped = <GlobalSearchType, List<GlobalSearchResult>>{};
    for (final result in results) {
      grouped.putIfAbsent(result.type, () => []).add(result);
    }
    return grouped;
  }

  String _typeLabel(AppLocalizations l10n, GlobalSearchType type) {
    switch (type) {
      case GlobalSearchType.client:
        return l10n.clients;
      case GlobalSearchType.invoice:
        return l10n.invoices;
      case GlobalSearchType.project:
        return l10n.projects;
      case GlobalSearchType.article:
        return l10n.articles;
      case GlobalSearchType.payment:
        return l10n.payments;
    }
  }

  void _openResult(BuildContext context, GlobalSearchResult result) {
    switch (result.type) {
      case GlobalSearchType.client:
        context.pushNamed(
          'client_details',
          pathParameters: {'id': result.id.toString()},
        );
        break;
      case GlobalSearchType.invoice:
      case GlobalSearchType.payment:
        context.pushNamed(
          'invoice_details',
          pathParameters: {'id': result.id.toString()},
        );
        break;
      case GlobalSearchType.project:
        context.pushNamed(
          'project_details',
          pathParameters: {'id': result.id.toString()},
        );
        break;
      case GlobalSearchType.article:
        context.pushNamed(
          'edit_article',
          pathParameters: {'id': result.id.toString()},
        );
        break;
    }
  }
}

class _SearchEmptyHint extends StatelessWidget {
  final AppLocalizations l10n;

  const _SearchEmptyHint({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final chips = [
      l10n.clients,
      l10n.invoices,
      l10n.projects,
      l10n.articles,
      l10n.payments,
    ];
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.manage_search,
              size: 72,
              color: AppColors.textMuted.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.globalSearchHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: chips.map((label) => Chip(label: Text(label))).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
