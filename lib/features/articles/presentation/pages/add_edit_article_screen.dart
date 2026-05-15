import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';
import 'package:hissab_dz/features/articles/domain/entities/article.dart';
import 'package:hissab_dz/features/articles/data/repositories/article_repository.dart';
import 'package:hissab_dz/features/articles/presentation/providers/article_providers.dart';

class AddEditArticleScreen extends ConsumerStatefulWidget {
  final int? articleId;
  const AddEditArticleScreen({super.key, this.articleId});

  @override
  ConsumerState<AddEditArticleScreen> createState() =>
      _AddEditArticleScreenState();
}

class _AddEditArticleScreenState extends ConsumerState<AddEditArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _priceController;
  late TextEditingController _taxRateController;
  late TextEditingController _marginRateController;
  late TextEditingController _defaultQuantityController;
  late TextEditingController _quickTemplateOrderController;
  String _selectedUnit = 'pieces';
  String _selectedType = 'physical';
  String _selectedCategory = 'materials';
  String _selectedQuickTemplate = 'none';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _codeController = TextEditingController();
    _priceController = TextEditingController();
    _taxRateController = TextEditingController(text: '0');
    _marginRateController = TextEditingController(text: '0');
    _defaultQuantityController = TextEditingController(text: '1');
    _quickTemplateOrderController = TextEditingController(text: '0');

    if (widget.articleId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final articles = ref.read(articlesListProvider).value ?? [];
        final article = articles.firstWhere((a) => a.id == widget.articleId);
        _nameController.text = article.name;
        _codeController.text = article.code ?? '';
        _priceController.text = article.price.toString();
        _taxRateController.text = article.taxRate.toString();
        _marginRateController.text = article.marginRate.toString();
        _defaultQuantityController.text = article.defaultQuantity.toString();
        _quickTemplateOrderController.text = article.quickTemplateOrder
            .toString();
        setState(() {
          _selectedUnit = article.unit;
          _selectedType = article.type;
          _selectedCategory = article.category;
          _selectedQuickTemplate = article.quickTemplate ?? 'none';
        });
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _priceController.dispose();
    _taxRateController.dispose();
    _marginRateController.dispose();
    _defaultQuantityController.dispose();
    _quickTemplateOrderController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final article = Article(
      id: widget.articleId,
      name: _nameController.text,
      code: _codeController.text.isEmpty ? null : _codeController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      unit: _selectedUnit,
      type: _selectedType,
      category: _selectedCategory,
      taxRate: double.tryParse(_taxRateController.text) ?? 0.0,
      marginRate: double.tryParse(_marginRateController.text) ?? 0.0,
      quickTemplate: _selectedQuickTemplate == 'none'
          ? null
          : _selectedQuickTemplate,
      defaultQuantity: double.tryParse(_defaultQuantityController.text) ?? 1.0,
      quickTemplateOrder: int.tryParse(_quickTemplateOrderController.text) ?? 0,
    );

    if (widget.articleId == null) {
      await ref.read(articleRepositoryProvider).addArticle(article);
    } else {
      await ref.read(articleRepositoryProvider).updateArticle(article);
    }

    if (mounted) context.pop();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.yes, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(articleRepositoryProvider)
          .deleteArticle(widget.articleId!);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.articleId != null;
    final units = {
      'kg': l10n.kg,
      'm2': l10n.m2,
      'm3': l10n.m3,
      'pieces': l10n.pieces,
    };
    final categories = {
      'labor': l10n.laborCategory,
      'materials': l10n.materialsCategory,
      'travel': l10n.travelCategory,
      'rental': l10n.rentalCategory,
      'service': l10n.service,
      'supply': l10n.supplyCategory,
    };
    final quickTemplates = {
      'none': l10n.noQuickTemplate,
      'painting': l10n.paintingRoom,
      'plumbing': l10n.plumbingRepair,
      'electrical': l10n.electricalJob,
      'masonry': l10n.masonryWork,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editArticle : l10n.addArticle),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Type Selector ──
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'physical',
                  label: Text(l10n.physical),
                  icon: const Icon(Icons.inventory_2),
                ),
                ButtonSegment(
                  value: 'service',
                  label: Text(l10n.service),
                  icon: const Icon(Icons.build_circle),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (val) =>
                  setState(() => _selectedType = val.first),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.name,
                border: const OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.isEmpty) ? l10n.noData : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: l10n.code,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.price,
                prefixText: '${l10n.currencySymbol} ',
                border: const OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.isEmpty) ? l10n.noData : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: l10n.articleCategory,
                border: const OutlineInputBorder(),
              ),
              items: categories.entries
                  .map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedUnit,
              decoration: InputDecoration(
                labelText: l10n.unit,
                border: const OutlineInputBorder(),
              ),
              items: units.entries
                  .map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedUnit = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedQuickTemplate,
              decoration: InputDecoration(
                labelText: l10n.quickTemplateTrade,
                border: const OutlineInputBorder(),
              ),
              items: quickTemplates.entries
                  .map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                  )
                  .toList(),
              onChanged: (v) =>
                  setState(() => _selectedQuickTemplate = v ?? 'none'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _defaultQuantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.defaultQuantity,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _quickTemplateOrderController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.quickTemplateOrder,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _taxRateController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.defaultTax,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _marginRateController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.margin,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: Text(
                l10n.save,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
