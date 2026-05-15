import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hissab_dz/core/utils/app_formatters.dart';
import 'package:hissab_dz/core/theme/theme.dart';
import 'package:hissab_dz/core/widgets/app_empty_state.dart';
import 'package:hissab_dz/core/widgets/app_drawer.dart';
import 'package:hissab_dz/core/widgets/contextual_fab.dart';
import 'package:hissab_dz/core/widgets/entity_card.dart';
import 'package:hissab_dz/core/widgets/responsive_content.dart';
import 'package:hissab_dz/features/projects/presentation/providers/project_providers.dart';
import 'package:hissab_dz/features/projects/presentation/widgets/expense_form_sheet.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';

class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final expensesAsync = ref.watch(expensesListProvider);

    return Scaffold(
      drawer: MediaQuery.sizeOf(context).width >= 1100
          ? null
          : const AppDrawer(),
      appBar: AppBar(title: Text(l10n.expenses)),
      body: expensesAsync.when(
        data: (expenses) {
          if (expenses.isEmpty) {
            return AppEmptyState(
              icon: Icons.receipt_long_outlined,
              title: l10n.noExpenses,
              action: FilledButton.icon(
                onPressed: () => _showExpenseSheet(context),
                icon: const Icon(Icons.add),
                label: Text(l10n.addExpense),
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
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return EntityCard(
                  icon: expense.receiptPath == null
                      ? Icons.receipt_long_outlined
                      : Icons.document_scanner_outlined,
                  color: AppColors.expense,
                  title: expense.label,
                  subtitle: [
                    [
                          expense.projectName ?? l10n.noProject,
                          expense.expenseTypeName,
                          expense.supplier,
                        ]
                        .whereType<String>()
                        .where((value) => value.isNotEmpty)
                        .join(' - '),
                    l10n.localeName == 'ar'
                        ? DateFormat('dd/MM/yyyy', 'en').format(expense.date)
                        : DateFormat.yMMMd(l10n.localeName).format(expense.date),
                    if (expense.paymentMethod != null)
                      '${l10n.paymentMethod}: ${expense.paymentMethod}',
                  ].join('\n'),
                  trailing: Text(
                    AppFormatters.formatCurrency(expense.amount, l10n),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.expense,
                      fontWeight: FontWeight.w900,
                    ),
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
        onPressed: () => _showExpenseSheet(context),
        tooltip: l10n.addExpense,
        icon: Icons.add,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
}
