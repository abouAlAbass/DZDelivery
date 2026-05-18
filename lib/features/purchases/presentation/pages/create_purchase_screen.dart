import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hissab_dz/core/theme/theme.dart';
import 'package:hissab_dz/core/widgets/responsive_content.dart';
import 'package:hissab_dz/features/articles/domain/entities/article.dart';
import 'package:hissab_dz/features/articles/presentation/providers/article_providers.dart';
import 'package:hissab_dz/features/purchases/data/repositories/purchase_repository.dart';
import 'package:hissab_dz/features/purchases/domain/entities/purchase.dart';
import 'package:hissab_dz/features/purchases/presentation/providers/purchase_providers.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';

class PurchaseFormScreen extends ConsumerStatefulWidget {
  const PurchaseFormScreen({super.key});

  @override
  ConsumerState<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class CreatePurchaseScreen extends PurchaseFormScreen {
  const CreatePurchaseScreen({super.key});
}

class _PurchaseFormScreenState extends ConsumerState<PurchaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final _items = <_PurchaseLine>[_PurchaseLine()];
  DateTime _date = DateTime.now();
  int? _supplierId;
  int? _warehouseId;
  bool _isSaving = false;

  @override
  void dispose() {
    _noteController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  double get _total => _items.fold(0, (sum, item) => sum + item.total);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final articles = (ref.watch(articlesListProvider).value ?? [])
        .where(
          (article) =>
              article.isActive &&
              article.deletedAt == null &&
              article.type != 'service',
        )
        .toList();
    final suppliers = ref.watch(suppliersListProvider).value ?? [];
    final depots = ref.watch(depotWarehousesProvider).value ?? [];
    final currencyFormat = NumberFormat.currency(symbol: l10n.currencySymbol);
    final dateFormat = DateFormat('dd/MM/yyyy', l10n.localeName);

    _warehouseId ??= depots.isEmpty ? null : depots.first.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvel achat')),
      body: Form(
        key: _formKey,
        child: ResponsiveContent(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.bottomNavClearance,
            ),
            children: [
              DropdownButtonFormField<int?>(
                initialValue: _supplierId,
                decoration: const InputDecoration(labelText: 'Fournisseur'),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Optionnel'),
                  ),
                  ...suppliers.map(
                    (supplier) => DropdownMenuItem<int?>(
                      value: supplier.id,
                      child: Text(supplier.name),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _supplierId = value),
              ),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(AppRadii.sm),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date'),
                  child: Text(dateFormat.format(_date)),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<int>(
                key: ValueKey(_warehouseId),
                initialValue: _warehouseId,
                decoration: const InputDecoration(labelText: 'Depot'),
                items: depots
                    .map(
                      (depot) => DropdownMenuItem<int>(
                        value: depot.id,
                        child: Text(depot.name),
                      ),
                    )
                    .toList(),
                validator: (value) =>
                    value == null ? 'Selectionnez un depot' : null,
                onChanged: (value) => setState(() => _warehouseId = value),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Articles',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _addLine,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter article'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ...List.generate(
                _items.length,
                (index) =>
                    _buildLineCard(context, index, articles, currencyFormat),
              ),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total achat',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        currencyFormat.format(_total),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note'),
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: _isSaving ? null : () => _save(validate: false),
                icon: const Icon(Icons.save_outlined),
                label: const Text('Enregistrer brouillon'),
              ),
              const SizedBox(height: AppSpacing.sm),
              FilledButton.icon(
                onPressed: _isSaving ? null : () => _save(validate: true),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Valider achat'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineCard(
    BuildContext context,
    int index,
    List<Article> articles,
    NumberFormat currencyFormat,
  ) {
    final line = _items[index];

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    key: ValueKey(line),
                    initialValue: line.articleId,
                    decoration: const InputDecoration(labelText: 'Article'),
                    items: articles
                        .map(
                          (article) => DropdownMenuItem<int>(
                            value: article.id,
                            child: Text(article.name),
                          ),
                        )
                        .toList(),
                    validator: (value) =>
                        value == null ? 'Selectionnez un article' : null,
                    onChanged: (value) {
                      final article = articles.firstWhere(
                        (article) => article.id == value,
                      );
                      setState(() {
                        line.articleId = value;
                        line.purchaseController.text = article.purchasePrice
                            .toStringAsFixed(2);
                      });
                    },
                  ),
                ),
                if (_items.length > 1)
                  IconButton(
                    tooltip: 'Supprimer',
                    onPressed: () => _removeLine(index),
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: line.quantityController,
                    decoration: const InputDecoration(labelText: 'Quantite'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    validator: _quantityValidator,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: line.purchaseController,
                    decoration: const InputDecoration(labelText: 'Prix achat'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    validator: _priceValidator,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total : ${currencyFormat.format(line.total)}',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _quantityValidator(String? value) {
    final parsed = _parseNumber(value);
    if (parsed == null || parsed <= 0) return 'Valeur invalide';
    return null;
  }

  String? _priceValidator(String? value) {
    final parsed = _parseNumber(value);
    if (parsed == null || parsed < 0) return 'Valeur invalide';
    return null;
  }

  double? _parseNumber(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  void _addLine() {
    setState(() => _items.add(_PurchaseLine()));
  }

  void _removeLine(int index) {
    final removed = _items.removeAt(index);
    removed.dispose();
    setState(() {});
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save({required bool validate}) async {
    if (!_formKey.currentState!.validate()) return;
    if (_warehouseId == null) return;
    if (validate) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Valider achat'),
          content: const Text('Confirmer cet achat et ajouter le stock ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmer'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => _isSaving = true);
    try {
      final purchase = Purchase(
        supplierId: _supplierId,
        date: _date,
        total: _total,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        items: _items
            .map(
              (line) => PurchaseItem(
                articleId: line.articleId!,
                quantity: line.quantity,
                purchasePrice: line.purchasePrice,
              ),
            )
            .toList(),
      );

      final repository = ref.read(purchaseRepositoryProvider);
      final purchaseId = await repository.addPurchase(purchase);
      if (validate) {
        await repository.confirmPurchase(purchaseId, warehouseId: _warehouseId);
      }

      if (!mounted) return;
      context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _PurchaseLine {
  int? articleId;
  final quantityController = TextEditingController(text: '1');
  final purchaseController = TextEditingController(text: '0');

  double get quantity =>
      double.tryParse(quantityController.text.replaceAll(',', '.')) ?? 0;
  double get purchasePrice =>
      double.tryParse(purchaseController.text.replaceAll(',', '.')) ?? 0;
  double get total => quantity * purchasePrice;

  void dispose() {
    quantityController.dispose();
    purchaseController.dispose();
  }
}
