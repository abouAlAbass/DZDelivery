import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hissab_dz/features/projects/domain/entities/project_expense.dart';
import 'package:hissab_dz/features/projects/presentation/providers/project_providers.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';

class ExpenseFormSheet extends ConsumerStatefulWidget {
  final int? initialProjectId;

  const ExpenseFormSheet({super.key, this.initialProjectId});

  @override
  ConsumerState<ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends ConsumerState<ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _amountController = TextEditingController();
  final _supplierController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _notesController = TextEditingController();
  int? _projectId;
  int? _expenseTypeId;
  String? _receiptPath;

  @override
  void initState() {
    super.initState();
    _projectId = widget.initialProjectId;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _amountController.dispose();
    _supplierController.dispose();
    _paymentMethodController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typesAsync = ref.watch(expenseTypesProvider);
    final projectsAsync = ref.watch(projectsListProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.addExpense,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                projectsAsync.when(
                  data: (projects) => DropdownButtonFormField<int?>(
                    initialValue: _projectId,
                    decoration: InputDecoration(
                      labelText: l10n.optionalProject,
                      prefixIcon: const Icon(Icons.folder_open_outlined),
                    ),
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text(l10n.noProject),
                      ),
                      ...projects.map(
                        (project) => DropdownMenuItem<int?>(
                          value: project.id,
                          child: Text(project.name),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => _projectId = value),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, st) => Text('${l10n.error}: $e'),
                ),
                const SizedBox(height: 12),
                typesAsync.when(
                  data: (types) => DropdownButtonFormField<int>(
                    initialValue: _expenseTypeId,
                    decoration: InputDecoration(
                      labelText: l10n.expenseType,
                      prefixIcon: const Icon(Icons.category_outlined),
                    ),
                    items: types
                        .map(
                          (type) => DropdownMenuItem(
                            value: type.id,
                            child: Text(type.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _expenseTypeId = value),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, st) => Text('${l10n.error}: $e'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _labelController,
                  decoration: InputDecoration(
                    labelText: l10n.name,
                    prefixIcon: const Icon(Icons.receipt_long_outlined),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.requiredField
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: l10n.amount,
                    prefixIcon: const Icon(Icons.payments_outlined),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final amount = double.tryParse(value?.replaceAll(',', '.') ?? '') ?? 0;
                    return amount <= 0 ? l10n.requiredField : null;
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _supplierController,
                  decoration: InputDecoration(
                    labelText: l10n.supplier,
                    prefixIcon: const Icon(Icons.store_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _paymentMethodController,
                  decoration: InputDecoration(
                    labelText: l10n.paymentMethod,
                    prefixIcon: const Icon(Icons.credit_card_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _pickReceipt,
                  icon: const Icon(Icons.document_scanner_outlined),
                  label: Text(
                    _receiptPath == null
                        ? l10n.attachReceipt
                        : l10n.changeReceipt,
                  ),
                ),
                if (_receiptPath != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _receiptPath!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: l10n.notes,
                    prefixIcon: const Icon(Icons.notes_outlined),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(l10n.save),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickReceipt() async {
    const typeGroup = XTypeGroup(
      label: 'Receipts',
      extensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null || !mounted) return;
    setState(() => _receiptPath = file.path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final label = _labelController.text.trim();
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;
    final navigator = Navigator.of(context);
    await ref
        .read(projectRepositoryProvider)
        .addExpense(
          ProjectExpense(
            projectId: _projectId,
            expenseTypeId: _expenseTypeId,
            label: label,
            amount: amount,
            date: DateTime.now(),
            supplier: _supplierController.text.trim().isEmpty
                ? null
                : _supplierController.text.trim(),
            paymentMethod: _paymentMethodController.text.trim().isEmpty
                ? null
                : _paymentMethodController.text.trim(),
            receiptPath: _receiptPath,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          ),
        );
    ref.invalidate(expensesListProvider);
    if (_projectId != null) {
      ref.invalidate(projectDetailsProvider(_projectId!));
    }
    if (mounted) navigator.pop();
  }
}
