import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hissab_dz/core/theme/theme.dart';
import 'package:hissab_dz/core/widgets/app_drawer.dart';
import 'package:hissab_dz/core/widgets/responsive_content.dart';
import 'package:hissab_dz/features/articles/domain/entities/article.dart';
import 'package:hissab_dz/features/articles/presentation/providers/article_providers.dart';
import 'package:hissab_dz/features/sales/data/repositories/sale_repository.dart';
import 'package:hissab_dz/features/sales/domain/entities/sale.dart';
import 'package:hissab_dz/features/stock/presentation/providers/stock_providers.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';
import 'package:hissab_dz/features/pos/presentation/providers/delivery_route_providers.dart';

class QuickSaleScreen extends ConsumerStatefulWidget {
  const QuickSaleScreen({super.key});

  @override
  ConsumerState<QuickSaleScreen> createState() => _QuickSaleScreenState();
}

class _QuickSaleScreenState extends ConsumerState<QuickSaleScreen> {
  final _searchController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _paidController = TextEditingController(text: '0');
  final _cart = <_CartLine>[];
  int? _warehouseId;
  String _query = '';
  String _paymentMethod = 'cash';
  bool _isSaving = false;

  @override
  void dispose() {
    _searchController.dispose();
    _discountController.dispose();
    _paidController.dispose();
    super.dispose();
  }

  double get _subtotal => _cart.fold(0, (sum, line) => sum + line.lineTotal);
  double get _discount => _parseNumber(_discountController.text) ?? 0;
  double get _total => (_subtotal - _discount).clamp(0, double.infinity);
  double get _paidAmount => _parseNumber(_paidController.text) ?? 0;
  String get _paymentStatus {
    if (_paidAmount <= 0) return 'unpaid';
    if (_paidAmount >= _total) return 'paid';
    return 'partial';
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
            appBar: AppBar(title: Text(l10n.localeName == 'ar' ? 'بيع سريع' : 'Vente rapide')),
            drawer: MediaQuery.sizeOf(context).width >= 1100 ? null : const AppDrawer(),
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
                            ? 'يجب بدء جولة يومية قبل التمكن من إجراء المبيعات.' 
                            : 'Vous devez démarrer une tournée avant de pouvoir effectuer des ventes.',
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
            .where((article) => article.isActive && article.deletedAt == null)
            .toList();
        final currencyFormat = NumberFormat.currency(locale: 'en', symbol: l10n.currencySymbol);
        final quantityFormat = NumberFormat.decimalPattern('en');

        _warehouseId = activeRoute.warehouseId;

        final availableStock = _warehouseId == null
            ? <int, double>{}
            : ref.watch(warehouseArticleStockProvider(_warehouseId!)).value ?? {};
        final filteredArticles = articles.where((article) {
          final query = _query.trim().toLowerCase();
          if (query.isEmpty) return true;
          return article.name.toLowerCase().contains(query) ||
              (article.code?.toLowerCase().contains(query) ?? false) ||
              (article.barcode?.toLowerCase().contains(query) ?? false);
        }).toList();

        return Scaffold(
          appBar: AppBar(title: Text(l10n.localeName == 'ar' ? 'بيع سريع' : 'Vente rapide')),
          drawer: MediaQuery.sizeOf(context).width >= 1100 ? null : const AppDrawer(),
          body: ResponsiveContent(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.bottomNavClearance,
              ),
              children: [
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
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: l10n.localeName == 'ar' ? 'بحث عن منتج' : 'Rechercher article',
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildArticleResults(
                  filteredArticles,
                  availableStock,
                  currencyFormat,
                  quantityFormat,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(l10n.localeName == 'ar' ? 'السلة' : 'Panier', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                if (_cart.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(l10n.localeName == 'ar' ? 'السلة فارغة' : 'Aucun article dans le panier'),
                    ),
                  )
                else
                  ..._cart.map(
                    (line) => _buildCartLine(
                      line,
                      availableStock[line.article.id!] ?? 0,
                      currencyFormat,
                      quantityFormat,
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _discountController,
                        decoration: InputDecoration(labelText: l10n.localeName == 'ar' ? 'تخفيض' : 'Remise'),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextField(
                        controller: _paidController,
                        decoration: InputDecoration(
                          labelText: l10n.localeName == 'ar' ? 'المبلغ المدفوع' : 'Montant paye',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  initialValue: _paymentMethod,
                  decoration: InputDecoration(labelText: l10n.localeName == 'ar' ? 'طريقة الدفع' : 'Mode paiement'),
                  items: [
                    DropdownMenuItem(value: 'cash', child: Text(l10n.localeName == 'ar' ? 'نقد' : 'Cash')),
                    DropdownMenuItem(value: 'card', child: Text(l10n.localeName == 'ar' ? 'بطاقة' : 'Carte')),
                    DropdownMenuItem(value: 'baridimob', child: Text(l10n.localeName == 'ar' ? 'بريدي موب' : 'BaridiMob')),
                    DropdownMenuItem(value: 'credit', child: Text(l10n.localeName == 'ar' ? 'دين' : 'Credit')),
                  ],
                  onChanged: (value) =>
                      setState(() => _paymentMethod = value ?? 'cash'),
                ),
                const SizedBox(height: AppSpacing.md),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        _amountRow(l10n.localeName == 'ar' ? 'المجموع الفرعي' : 'Sous-total', _subtotal, currencyFormat),
                        _amountRow(l10n.localeName == 'ar' ? 'تخفيض' : 'Remise', _discount, currencyFormat),
                        const Divider(),
                        _amountRow(l10n.localeName == 'ar' ? 'الإجمالي' : 'Total', _total, currencyFormat, bold: true),
                        _amountRow(l10n.localeName == 'ar' ? 'المبلغ المدفوع' : 'Paye', _paidAmount, currencyFormat),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Chip(label: Text(_paymentStatus)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: _isSaving ? null : () => _confirmSale(availableStock),
                  icon: const Icon(Icons.point_of_sale),
                  label: Text(l10n.localeName == 'ar' ? 'تأكيد البيع' : 'Confirmer vente'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildArticleResults(
    List<Article> articles,
    Map<int, double> availableStock,
    NumberFormat currencyFormat,
    NumberFormat quantityFormat,
  ) {
    return SizedBox(
      height: 220,
      child: Card(
        child: ListView.separated(
          itemCount: articles.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final article = articles[index];
            final articleId = article.id;
            if (articleId == null) return const SizedBox.shrink();
            final available = availableStock[articleId] ?? 0;
            final salePrice = article.salePrice == 0
                ? article.price
                : article.salePrice;
            final tracksStock = _tracksStock(article);

            return ListTile(
              title: Text(article.name),
              subtitle: Text(
                tracksStock
                    ? '${currencyFormat.format(salePrice)} - Stock: ${_formatQuantity(quantityFormat, available)}'
                    : '${currencyFormat.format(salePrice)} - Service',
              ),
              trailing: IconButton(
                tooltip: 'Ajouter',
                icon: const Icon(Icons.add_circle_outline),
                onPressed: tracksStock && available <= 0
                    ? null
                    : () => _addToCart(article, available),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCartLine(
    _CartLine line,
    double available,
    NumberFormat currencyFormat,
    NumberFormat quantityFormat,
  ) {
    final tracksStock = _tracksStock(line.article);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.article.name,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    tracksStock
                        ? '${currencyFormat.format(line.unitPrice)} - Disponible: ${_formatQuantity(quantityFormat, available)}'
                        : '${currencyFormat.format(line.unitPrice)} - Service',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _changeQuantity(line, -1, available),
              icon: const Icon(Icons.remove),
            ),
            Text(_formatQuantity(quantityFormat, line.quantity)),
            IconButton(
              onPressed: tracksStock && line.quantity >= available
                  ? null
                  : () => _changeQuantity(line, 1, available),
              icon: const Icon(Icons.add),
            ),
            SizedBox(
              width: 96,
              child: Text(
                currencyFormat.format(line.lineTotal),
                textAlign: TextAlign.end,
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _cart.remove(line)),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _amountRow(
    String label,
    double value,
    NumberFormat currencyFormat, {
    bool bold = false,
  }) {
    final style = bold
        ? Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(currencyFormat.format(value), style: style),
        ],
      ),
    );
  }

  void _addToCart(Article article, double available) {
    final existing = _cart.where((line) => line.article.id == article.id);
    if (existing.isNotEmpty) {
      final line = existing.first;
      if (_tracksStock(article) && line.quantity >= available) return;
      setState(() => line.quantity += 1);
      return;
    }

    setState(() {
      _cart.add(
        _CartLine(
          article: article,
          quantity: 1,
          unitPrice: article.salePrice == 0 ? article.price : article.salePrice,
        ),
      );
    });
  }

  void _changeQuantity(_CartLine line, double delta, double available) {
    final maximum = _tracksStock(line.article) ? available : double.infinity;
    final next = (line.quantity + delta).clamp(0, maximum);
    setState(() {
      if (next <= 0) {
        _cart.remove(line);
      } else {
        line.quantity = next.toDouble();
      }
    });
  }

  Future<void> _confirmSale(Map<int, double> availableStock) async {
    if (_warehouseId == null || _cart.isEmpty) return;
    if (_discount < 0 || _discount > _subtotal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La remise ne peut pas depasser le total'),
        ),
      );
      return;
    }
    if (_paidAmount < 0 || _paidAmount > _total) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Montant paye invalide')));
      return;
    }

    final requestedByArticle = <int, double>{};
    for (final line in _cart) {
      if (!_tracksStock(line.article)) continue;
      final articleId = line.article.id!;
      requestedByArticle[articleId] =
          (requestedByArticle[articleId] ?? 0) + line.quantity;
    }

    for (final entry in requestedByArticle.entries) {
      if (entry.value > (availableStock[entry.key] ?? 0)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Stock insuffisant')));
        return;
      }
    }

    final activeRoute = ref.read(activeDeliveryRouteProvider).value;
    if (activeRoute == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer vente'),
        content: const Text('Valider cette vente et mettre a jour le stock ?'),
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

    setState(() => _isSaving = true);
    try {
      final repository = ref.read(saleRepositoryProvider);
      final saleNumber = await repository.generateNextSaleNumber();
      final sale = Sale(
        saleNumber: saleNumber,
        warehouseId: _warehouseId!,
        date: DateTime.now(),
        subtotal: _subtotal,
        discountAmount: _discount,
        total: _total,
        paidAmount: _paidAmount,
        paymentStatus: _paymentStatus,
        status: 'draft',
        routeId: activeRoute.id,
        items: _cart
            .map(
              (line) => SaleItem(
                articleId: line.article.id!,
                quantity: line.quantity,
                unitPrice: line.unitPrice,
                total: line.lineTotal,
              ),
            )
            .toList(),
        payment: _paidAmount > 0
            ? SalePayment(
                amount: _paidAmount,
                method: _paymentMethod,
                date: DateTime.now(),
                routeId: activeRoute.id,
              )
            : null,
      );

      await repository.createAndConfirmSale(sale);

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

  double? _parseNumber(String value) {
    if (value.trim().isEmpty) return null;
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  bool _tracksStock(Article article) => article.type != 'service';
}

class _CartLine {
  final Article article;
  final double unitPrice;
  double quantity;

  _CartLine({
    required this.article,
    required this.unitPrice,
    required this.quantity,
  });

  double get lineTotal => unitPrice * quantity;
}

String _formatQuantity(NumberFormat formatter, double value) {
  if (value == value.roundToDouble()) {
    return formatter.format(value.round());
  }
  return formatter.format(value);
}
