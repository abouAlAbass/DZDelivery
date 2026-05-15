import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hissab_dz/core/utils/app_formatters.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/entity_card.dart';
import '../../../../core/widgets/metric_card.dart';
import '../../../../core/widgets/quick_action_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../clients/presentation/pages/client_list_screen.dart';
import '../../../invoices/domain/entities/invoice.dart';
import '../../../projects/presentation/widgets/expense_form_sheet.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        actions: [
          IconButton(
            tooltip: 'Toggle Theme',
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          IconButton(
            tooltip: l10n.globalSearch,
            icon: const Icon(Icons.search),
            onPressed: () => context.pushNamed('global_search'),
          ),
        ],
      ),
      drawer: MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop
          ? null
          : const AppDrawer(),
      body: statsAsync.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () => ref.refresh(dashboardStatsProvider.future),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final horizontalPadding = width >= AppBreakpoints.desktop
                  ? AppSpacing.desktopPage
                  : AppSpacing.page;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  AppSpacing.md,
                  horizontalPadding,
                  width < AppBreakpoints.tablet
                      ? AppSpacing.bottomNavClearance
                      : AppSpacing.desktopPage,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppBreakpoints.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDashboardHero(context, l10n, stats),
                        const SizedBox(height: AppSpacing.lg),
                        _buildQuickActions(context, l10n),
                        const SizedBox(height: AppSpacing.lg),
                        _buildSummaryGrid(context, l10n, stats),
                        const SizedBox(height: AppSpacing.lg),
                        if ((stats['overdueInvoices'] as List).isNotEmpty) ...[
                          _buildOverdueAlert(
                            context,
                            l10n,
                            stats['overdueInvoices'] as List<Invoice>,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        Text(
                          l10n.recentInvoices,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _buildRecentInvoices(
                          context,
                          l10n,
                          stats['recentInvoices'] as List<Invoice>,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('${l10n.error}: $e')),
      ),
    );
  }

  Widget _buildDashboardHero(
    BuildContext context,
    AppLocalizations l10n,
    Map<String, dynamic> stats,
  ) {

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < AppBreakpoints.tablet;
            final mainPanel = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appTitle,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.dashboard,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontSize: compact ? 26 : 30,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  AppFormatters.formatCurrency(stats['collectedThisMonth'], l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontSize: compact ? 28 : 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  l10n.collectedThisMonth,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.80),
                  ),
                ),
              ],
            );
            final sidePanel = Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.construction_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    '${stats['ongoingProjects']}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    l10n.ongoingProjects,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    AppFormatters.formatCurrency(stats['outstandingAmount'], l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                  Text(
                    l10n.outstanding,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                ],
              ),
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  mainPanel,
                  const SizedBox(height: AppSpacing.md),
                  sidePanel,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: mainPanel),
                const SizedBox(width: AppSpacing.lg),
                Expanded(flex: 2, child: sidePanel),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    final actions = [
      (
        label: l10n.createQuote,
        icon: Icons.request_quote_outlined,
        color: AppColors.quote,
        onTap: () => context.pushNamed('create_quote'),
      ),
      (
        label: l10n.addExpense,
        icon: Icons.receipt_long_outlined,
        color: AppColors.expense,
        onTap: () => _showExpenseSheet(context),
      ),
      (
        label: l10n.quickClient,
        icon: Icons.person_add_alt_1_outlined,
        color: AppColors.info,
        onTap: () => _showClientSheet(context),
      ),
      (
        label: l10n.quickArticle,
        icon: Icons.add_box_outlined,
        color: AppColors.success,
        onTap: () => context.pushNamed('add_article'),
      ),
    ];

    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= AppBreakpoints.desktop ? 4 : 2;
    final childAspectRatio = width >= AppBreakpoints.desktop ? 3.2 : 2.45;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return QuickActionCard(
          label: action.label,
          icon: action.icon,
          color: action.color,
          onTap: action.onTap,
        );
      },
    );
  }

  void _showExpenseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const ExpenseFormSheet(),
    );
  }

  void _showClientSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          const Padding(padding: EdgeInsets.all(16), child: AddClientForm()),
    );
  }

  Widget _buildSummaryGrid(
    BuildContext context,
    AppLocalizations l10n,
    Map<String, dynamic> stats,
  ) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= AppBreakpoints.tablet ? 3 : 2;
    final childAspectRatio = width >= AppBreakpoints.tablet ? 2.0 : 1.45;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      childAspectRatio: childAspectRatio,
      children: [
        MetricCard(
          label: l10n.collectedThisMonth,
          value: AppFormatters.formatCurrency(stats['collectedThisMonth'], l10n),
          icon: Icons.account_balance_wallet_outlined,
          color: AppColors.income,
          emphasized: true,
        ),
        MetricCard(
          label: l10n.outstanding,
          value: AppFormatters.formatCurrency(stats['outstandingAmount'], l10n),
          icon: Icons.pending_actions,
          color: AppColors.warning,
        ),
        MetricCard(
          label: l10n.monthlyExpenses,
          value: AppFormatters.formatCurrency(stats['expensesThisMonth'], l10n),
          icon: Icons.receipt_long_outlined,
          color: AppColors.expense,
        ),
        MetricCard(
          label: l10n.estimatedProfit,
          value: AppFormatters.formatCurrency(stats['estimatedProfit'], l10n),
          icon: Icons.trending_up,
          color: AppColors.profit,
          emphasized: true,
        ),
        MetricCard(
          label: l10n.ongoingProjects,
          value: '${stats['ongoingProjects']}',
          icon: Icons.construction_outlined,
          color: AppColors.project,
        ),
        MetricCard(
          label: l10n.overdueInvoices,
          value: '${stats['overdueInvoiceCount']}',
          icon: Icons.warning_amber_rounded,
          color: AppColors.overdue,
        ),
      ],
    );
  }

  Widget _buildOverdueAlert(
    BuildContext context,
    AppLocalizations l10n,
    List<Invoice> overdue,
  ) {
    return Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkDangerSoft
          : AppColors.dangerSoft,
      child: ListTile(
        leading: const Icon(
          Icons.warning_amber_rounded,
          color: AppColors.danger,
        ),
        title: Text(
          l10n.overdueAlert(overdue.length),
          style: const TextStyle(
            color: AppColors.danger,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          l10n.immediateAction,
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.pushNamed('invoices'),
      ),
    );
  }

  Widget _buildRecentInvoices(
    BuildContext context,
    AppLocalizations l10n,
    List<Invoice> invoices,
  ) {
    if (invoices.isEmpty) {
      return AppEmptyState(
        icon: Icons.description_outlined,
        title: l10n.noRecentInvoices,
      );
    }

    return Column(
      children: invoices
          .map(
            (invoice) => EntityCard(
              icon: Icons.description_outlined,
              color: AppColors.invoice,
              title: invoice.invoiceNumber,
              subtitle: invoice.client?.name ?? '',
              amount: AppFormatters.formatCurrency(invoice.total, l10n),
              badge: StatusBadge(status: invoice.status),
              onTap: () => context.pushNamed(
                'invoice_details',
                pathParameters: {'id': invoice.id.toString()},
              ),
            ),
          )
          .toList(),
    );
  }
}
