import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hissab_dz/core/theme/theme.dart';
import 'package:hissab_dz/core/widgets/responsive_content.dart';
import 'package:hissab_dz/features/articles/domain/entities/article.dart';
import 'package:hissab_dz/features/articles/presentation/providers/article_providers.dart';
import 'package:hissab_dz/features/stock/data/repositories/stock_transfer_repository.dart';
import 'package:hissab_dz/features/stock/domain/entities/stock_transfer.dart';
import 'package:hissab_dz/features/stock/presentation/providers/stock_providers.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';
import 'package:hissab_dz/features/pos/presentation/providers/delivery_route_providers.dart';

class StockTransferFormScreen extends ConsumerStatefulWidget {
  const StockTransferFormScreen({super.key});

  @override
  ConsumerState<StockTransferFormScreen> createState() =>
      _StockTransferFormScreenState();
}

class _StockTransferFormScreenState
    extends ConsumerState<StockTransferFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final _items = <_TransferLine>[_TransferLine()];
  DateTime _date = DateTime.now();
  int? _fromWarehouseId;
  int? _toWarehouseId;
  bool _isSaving = false;

  @override
  void dispose() {
    _noteController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeRouteAsync = ref.watch(activeDeliveryRouteProvider);

    return activeRouteAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Erreur : $err')),
      ),
      data: (activeRoute) {
        if (activeRoute == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.newTruckLoading)),
            body: Center(
              child: Card(
                margin: const EdgeInsets.all(AppSpacing.lg),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_outline, size: 64, color: AppTheme.primaryIndigo),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        l10n.localeName == 'ar' ? 'الرجاء بدء الجولة' : 'Tournée non démarrée',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.localeName == 'ar' 
                            ? 'يجب بدء جولة يومية قبل التمكن من شحن الشاحنة.' 
                            : 'Vous devez démarrer une tournée avant de pouvoir charger le camion.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton.icon(
                        onPressed: () => context.go('/pos/delivery-route'),
                        icon: const Icon(Icons.play_arrow),
                        label: Text(l10n.localeName == 'ar' ? 'بدء جولة اليوم' : 'Démarrer la tournée'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final articles = (ref.watch(articlesListProvider).value ?? [])
            .where(
              (article) =>
                  article.isActive &&
                  article.deletedAt == null &&
                  article.type != 'service',
            )
            .toList();
        final depots = ref.watch(depotWarehousesProvider).value ?? [];
        final dateFormat = DateFormat('dd/MM/yyyy', l10n.localeName);
        final quantityFormat = NumberFormat.decimalPattern(l10n.localeName);

        _fromWarehouseId ??= depots.isEmpty ? null : depots.first.id;
        _toWarehouseId = activeRoute.warehouseId; // Force destination warehouse to be the active route's truck!

        final availableStock = _fromWarehouseId == null
            ? <int, double>{}
            : ref.watch(warehouseArticleStockProvider(_fromWarehouseId!)).value ??
                  {};

        return Scaffold(
          appBar: AppBar(title: Text(l10n.newTruckLoading)),
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
                  DropdownButtonFormField<int>(
                    key: ValueKey(_fromWarehouseId),
                    initialValue: _fromWarehouseId,
                    decoration: InputDecoration(labelText: l10n.sourceDepot),
                    items: depots
                        .map(
                          (warehouse) => DropdownMenuItem<int>(
                            value: warehouse.id,
                            child: Text(warehouse.name),
                          ),
                        )
                        .toList(),
                    validator: (value) =>
                        value == null ? l10n.selectDepot : null,
                    onChanged: (value) => setState(() => _fromWarehouseId = value),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Card(
                    color: AppTheme.primaryIndigo.withValues(alpha: 0.05),
                    child: ListTile(
                      leading: const Icon(Icons.local_shipping, color: AppTheme.primaryIndigo),
                      title: Text(l10n.localeName == 'ar' 
                          ? 'شاحنة الجولة: ${activeRoute.driverName ?? "الموزع"}'
                          : 'Camion de la tournée : ${activeRoute.driverName ?? "Livreur"}'),
                      subtitle: Text(l10n.localeName == 'ar'
                          ? 'عداد البداية: ${activeRoute.startKm ?? "-"} كم'
                          : 'KM de départ : ${activeRoute.startKm ?? "-"} km'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: l10n.date),
                      child: Text(dateFormat.format(_date)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.articles,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _addLine,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.addItem),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...List.generate(
                    _items.length,
                    (index) => _buildLineCard(
                      context,
                      index,
                      articles,
                      availableStock,
                      quantityFormat,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _noteController,
                    decoration: InputDecoration(labelText: l10n.note),
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  OutlinedButton.icon(
                    onPressed: _isSaving ? null : () => _save(confirm: false),
                    icon: const Icon(Icons.save_outlined),
                    label: Text(l10n.saveDraft),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : () => _save(confirm: true),
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(l10n.confirmLoading),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLineCard(
    BuildContext context,
    int index,
    List<Article> articles,
    Map<int, double> availableStock,
    NumberFormat quantityFormat,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final line = _items[index];
    final available = line.articleId == null
        ? 0.0
        : availableStock[line.articleId!] ?? 0.0;

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
                    decoration: InputDecoration(labelText: l10n.article),
                    items: articles
                        .map(
                          (article) => DropdownMenuItem<int>(
                            value: article.id,
                            child: Text(article.name),
                          ),
                        )
                        .toList(),
                    validator: (value) =>
                        value == null ? l10n.selectProduct : null,
                    onChanged: (value) =>
                        setState(() => line.articleId = value),
                  ),
                ),
                if (_items.length > 1)
                  IconButton(
                    tooltip: l10n.delete,
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
                    decoration: InputDecoration(
                      labelText: l10n.quantity,
                      helperText:
                          '${l10n.available} : ${_formatQuantity(quantityFormat, available)}',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    validator: (value) => _quantityValidator(context, value, available),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _quantityValidator(BuildContext context, String? value, double available) {
    final l10n = AppLocalizations.of(context)!;
    final parsed = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) return l10n.invalidValue;
    if (parsed > available) return l10n.insufficientStock;
    return null;
  }

  void _addLine() {
    setState(() => _items.add(_TransferLine()));
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

  Future<void> _save({required bool confirm}) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_fromWarehouseId == null || _toWarehouseId == null) return;
    if (confirm) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.confirmLoading),
          content: Text(l10n.confirmLoadingMsg),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.confirm),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => _isSaving = true);
    try {
      final activeRoute = ref.read(activeDeliveryRouteProvider).value;
      final transfer = StockTransfer(
        fromWarehouseId: _fromWarehouseId!,
        toWarehouseId: _toWarehouseId!,
        date: _date,
        routeId: activeRoute?.id,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        items: _items
            .map(
              (line) => StockTransferItem(
                articleId: line.articleId!,
                quantity: line.quantity,
              ),
            )
            .toList(),
      );

      final repository = ref.read(stockTransferRepositoryProvider);
      final transferId = await repository.addTransfer(transfer);
      if (confirm) {
        await repository.confirmStockTransfer(transferId);
      }

      if (!mounted) return;
      context.pop();
    } on StateError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _TransferLine {
  int? articleId;
  final quantityController = TextEditingController(text: '1');

  double get quantity =>
      double.tryParse(quantityController.text.replaceAll(',', '.')) ?? 0;

  void dispose() {
    quantityController.dispose();
  }
}

String _formatQuantity(NumberFormat formatter, double value) {
  if (value == value.roundToDouble()) {
    return formatter.format(value.round());
  }
  return formatter.format(value);
}
