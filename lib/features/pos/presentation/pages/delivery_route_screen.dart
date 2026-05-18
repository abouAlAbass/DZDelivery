import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hissab_dz/core/theme/theme.dart';
import 'package:hissab_dz/core/widgets/app_drawer.dart';
import 'package:hissab_dz/core/widgets/responsive_content.dart';
import 'package:hissab_dz/core/database/database.dart';
import 'package:hissab_dz/features/pos/presentation/providers/delivery_route_providers.dart';
import 'package:hissab_dz/features/pos/data/repositories/delivery_route_repository.dart';
import 'package:hissab_dz/features/sales/domain/entities/sale.dart';
import 'package:hissab_dz/features/sales/services/pdf_driver_day_report_service.dart';
import 'package:hissab_dz/features/settings/presentation/providers/settings_providers.dart';
import 'package:hissab_dz/features/stock/presentation/providers/stock_providers.dart';
import 'package:hissab_dz/features/articles/presentation/providers/article_providers.dart';
import 'package:hissab_dz/features/articles/domain/entities/article.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';

class DeliveryRouteScreen extends ConsumerStatefulWidget {
  const DeliveryRouteScreen({super.key});

  @override
  ConsumerState<DeliveryRouteScreen> createState() =>
      _DeliveryRouteScreenState();
}

class _DeliveryRouteScreenState extends ConsumerState<DeliveryRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _driverNameController = TextEditingController();
  final _startKmController = TextEditingController(text: '0');
  final _startCashController = TextEditingController(text: '0');
  final _noteController = TextEditingController();

  final _closeFormKey = GlobalKey<FormState>();
  final _endKmController = TextEditingController();
  final _endCashController = TextEditingController();
  final _closeNoteController = TextEditingController();

  int? _selectedWarehouseId;
  bool _isSaving = false;
  bool _showClosureForm = false;

  @override
  void dispose() {
    _driverNameController.dispose();
    _startKmController.dispose();
    _startCashController.dispose();
    _noteController.dispose();
    _endKmController.dispose();
    _endCashController.dispose();
    _closeNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeRouteAsync = ref.watch(activeDeliveryRouteProvider);
    final historyAsync = ref.watch(deliveryRouteHistoryProvider);
    final isAr = l10n.localeName == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAr ? 'إدارة الجولات والكلوزينج' : 'Gestion des Tournées & Clôture',
        ),
      ),
      drawer: MediaQuery.sizeOf(context).width >= 1100
          ? null
          : const AppDrawer(),
      body: ResponsiveContent(
        child: activeRouteAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Erreur : $err')),
          data: (activeRoute) {
            if (activeRoute == null) {
              return _buildStartRouteView(context, historyAsync, isAr);
            }
            if (_showClosureForm) {
              return _buildClosureFormView(context, activeRoute, isAr);
            }
            return _buildActiveDashboardView(
              context,
              activeRoute,
              historyAsync,
              isAr,
            );
          },
        ),
      ),
    );
  }

  Widget _buildStartRouteView(
    BuildContext context,
    AsyncValue<List<DeliveryRouteData>> historyAsync,
    bool isAr,
  ) {
    final trucks = ref.watch(truckWarehousesProvider).value ?? [];

    if (_selectedWarehouseId == null && trucks.isNotEmpty) {
      _selectedWarehouseId = trucks.first.id;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryIndigo, AppTheme.primaryViolet],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  isAr
                      ? 'بدء جولة توزيع جديدة'
                      : 'Démarrer une nouvelle tournée',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isAr
                      ? 'حدد الشاحنة وسجل معلومات الانطلاق لبدء مبيعاتك اليومية'
                      : 'Sélectionnez le camion et saisissez les valeurs de départ pour commencer la journée.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Form(
            key: _formKey,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'معلومات الانطلاق' : 'Informations de départ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedWarehouseId,
                      decoration: InputDecoration(
                        labelText: isAr
                            ? 'الشاحنة / المستودع المتنقل'
                            : 'Camion / Warehouse',
                        prefixIcon: const Icon(Icons.local_shipping),
                      ),
                      items: trucks.map((truck) {
                        return DropdownMenuItem<int>(
                          value: truck.id,
                          child: Text(truck.name),
                        );
                      }).toList(),
                      validator: (val) => val == null
                          ? (isAr
                                ? 'الرجاء اختيار الشاحنة'
                                : 'Veuillez sélectionner un camion')
                          : null,
                      onChanged: (val) =>
                          setState(() => _selectedWarehouseId = val),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _driverNameController,
                      decoration: InputDecoration(
                        labelText: isAr ? 'اسم السائق' : 'Nom du chauffeur',
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _startKmController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'),
                              ),
                            ],
                            decoration: InputDecoration(
                              labelText: isAr
                                  ? 'عداد الكيلومترات'
                                  : 'Kilométrage départ (KM)',
                              prefixIcon: const Icon(Icons.speed),
                            ),
                            validator: (val) =>
                                double.tryParse(val ?? '') == null
                                ? (isAr ? 'قيمة غير صالحة' : 'Valeur invalide')
                                : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: TextFormField(
                            controller: _startCashController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'),
                              ),
                            ],
                            decoration: InputDecoration(
                              labelText: isAr
                                  ? 'رصيد الصندوق الأول'
                                  : 'Fond de caisse (DZD)',
                              prefixIcon: const Icon(Icons.attach_money),
                            ),
                            validator: (val) =>
                                double.tryParse(val ?? '') == null
                                ? (isAr ? 'قيمة غير صالحة' : 'Valeur invalide')
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _noteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: isAr
                            ? 'ملاحظة (اختياري)'
                            : 'Note (optionnel)',
                        prefixIcon: const Icon(Icons.note_alt_outlined),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                          ),
                        ),
                        onPressed: _isSaving ? null : _handleStartRoute,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.play_arrow),
                        label: Text(
                          isAr ? 'بدء جولة اليوم' : 'Démarrer la tournée',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildPastRoutesSection(historyAsync, isAr),
        ],
      ),
    );
  }

  Widget _buildActiveDashboardView(
    BuildContext context,
    DeliveryRouteData activeRoute,
    AsyncValue<List<DeliveryRouteData>> historyAsync,
    bool isAr,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final reportAsync = ref.watch(deliveryRouteReportProvider(activeRoute.id));
    final currencyFormat = NumberFormat.currency(
      locale: 'en',
      symbol: l10n.currencySymbol,
    );
    final quantityFormat = NumberFormat.decimalPattern('en');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Route Meta Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(
                  color: AppTheme.primaryIndigo.withValues(alpha: 0.3),
                ),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryIndigo.withValues(alpha: 0.02),
                    AppTheme.primaryViolet.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.fiber_manual_record,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            isAr ? 'جولة نشطة حالياً' : 'Tournée en cours',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(activeRoute.date),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const Divider(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetaItem(
                          context,
                          icon: Icons.person,
                          label: isAr ? 'اسم السائق' : 'Chauffeur',
                          value: activeRoute.driverName ?? '-',
                        ),
                      ),
                      Expanded(
                        child: _buildMetaItem(
                          context,
                          icon: Icons.local_shipping,
                          label: isAr ? 'المستودع المتنقل' : 'Camion / Stock',
                          value: activeRoute.startKm != null
                              ? 'KM : ${activeRoute.startKm}'
                              : '-',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetaItem(
                          context,
                          icon: Icons.attach_money,
                          label: isAr
                              ? 'رصيد الصندوق الافتتاحي'
                              : 'Fond de caisse',
                          value: currencyFormat.format(activeRoute.startCash),
                        ),
                      ),
                      Expanded(
                        child: _buildMetaItem(
                          context,
                          icon: Icons.notes,
                          label: isAr ? 'الملاحظة' : 'Note de départ',
                          value: activeRoute.note ?? '-',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Statistics Dashboard
          reportAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Erreur stat : $err')),
            data: (report) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr
                        ? 'إحصائيات اليوم للجولة'
                        : 'Statistiques de la journée',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 2x2 Grid of KPIs
                  GridView.count(
                    crossAxisCount: MediaQuery.sizeOf(context).width >= 600
                        ? 4
                        : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1.3,
                    children: [
                      _buildKpiCard(
                        context,
                        title: isAr ? 'المبيعات' : 'Ventes',
                        value: currencyFormat.format(report.salesTotal),
                        subtitle:
                            '${report.saleCount} ${isAr ? 'مبيعة' : 'vente(s)'}',
                        icon: Icons.point_of_sale,
                        color: AppTheme.primaryIndigo,
                      ),
                      _buildKpiCard(
                        context,
                        title: isAr ? 'التحصيل النقدي' : 'Espèces encaissées',
                        value: currencyFormat.format(report.cashTotal),
                        subtitle: isAr ? 'إجمالي المداخيل' : 'Total reçu',
                        icon: Icons.payments,
                        color: Colors.green,
                      ),
                      _buildKpiCard(
                        context,
                        title: isAr ? 'الديون الجديدة' : 'Crédits créés',
                        value: currencyFormat.format(report.creditTotal),
                        subtitle: isAr
                            ? 'باقي الدفع للزبائن'
                            : 'Restant à payer',
                        icon: Icons.assignment_late,
                        color: Colors.orange,
                      ),
                      _buildKpiCard(
                        context,
                        title: isAr ? 'حركة المنتجات' : 'Flux Articles',
                        value: quantityFormat.format(report.soldQuantity),
                        subtitle:
                            '${isAr ? 'مباع / شحن: ' : 'Sold/Loaded: '}${quantityFormat.format(report.loadedQuantity)}',
                        icon: Icons.inventory_2,
                        color: Colors.blue,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),
                  _buildReportActions(context, report, isAr),

                  const SizedBox(height: AppSpacing.lg),

                  // Stock Summary Section
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr
                                ? 'ملخص مخزون الشاحنة المتبقي'
                                : 'Stock restant dans le camion',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Divider(),
                          if (report.truckStock.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              child: Text(
                                isAr
                                    ? 'المخزون فارغ حالياً'
                                    : 'Le stock du camion est vide.',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: report.truckStock.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final entry = report.truckStock.entries
                                    .elementAt(index);
                                final stockVal = entry.value;

                                return ref
                                    .watch(articlesListProvider)
                                    .when(
                                      loading: () => const SizedBox.shrink(),
                                      error: (_, __) => const SizedBox.shrink(),
                                      data: (articles) {
                                        final art = articles.firstWhere(
                                          (a) => a.id == entry.key,
                                          orElse: () => Article(
                                            name: 'Article #${entry.key}',
                                            type: 'product',
                                            price: 0,
                                            salePrice: 0,
                                            unit: 'pcs',
                                          ),
                                        );
                                        return ListTile(
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(art.name),
                                          trailing: Text(
                                            quantityFormat.format(stockVal),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: stockVal < 5
                                                  ? Colors.red
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Action Button for Clôture
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _endKmController.text = (activeRoute.startKm ?? 0.0)
                              .toString();
                          _endCashController.text =
                              (activeRoute.startCash + report.cashTotal)
                                  .toString();
                          _showClosureForm = true;
                        });
                      },
                      icon: const Icon(Icons.check_circle),
                      label: Text(
                        isAr
                            ? 'إغلاق اليوم (الكلوزينج)'
                            : 'Clôturer la journée',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildPastRoutesSection(historyAsync, isAr),
        ],
      ),
    );
  }

  Widget _buildClosureFormView(
    BuildContext context,
    DeliveryRouteData activeRoute,
    bool isAr,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Form(
        key: _closeFormKey,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => setState(() => _showClosureForm = false),
                    ),
                    Text(
                      isAr
                          ? 'تسجيل إغلاق اليوم والكلوزينج'
                          : 'Enregistrer la Clôture',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: AppSpacing.md),
                Text(
                  isAr
                      ? 'الرجاء إدخال قراءة عداد الكيلومترات النهائي والمبلغ المتواجد في الصندوق حالياً للتأكيد.'
                      : 'Veuillez saisir le kilométrage final et le montant d\'espèces en main.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _endKmController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: InputDecoration(
                    labelText: isAr
                        ? 'عداد الكيلومترات النهائي'
                        : 'Kilométrage final (KM)',
                    prefixIcon: const Icon(Icons.speed),
                  ),
                  validator: (val) {
                    final endVal = double.tryParse(val ?? '');
                    if (endVal == null) {
                      return isAr ? 'قيمة غير صالحة' : 'Valeur invalide';
                    }
                    if (endVal < (activeRoute.startKm ?? 0.0)) {
                      return isAr
                          ? 'يجب أن يكون أكبر من عداد البداية (${activeRoute.startKm})'
                          : 'Doit être supérieur au kilométrage départ (${activeRoute.startKm})';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _endCashController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: InputDecoration(
                    labelText: isAr
                        ? 'المبلغ الفعلي في الصندوق'
                        : 'Espèces finales en caisse (DZD)',
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  validator: (val) => double.tryParse(val ?? '') == null
                      ? (isAr ? 'قيمة غير صالحة' : 'Valeur invalide')
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _closeNoteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: isAr
                        ? 'ملاحظة الختام (اختياري)'
                        : 'Note de clôture (optionnel)',
                    prefixIcon: const Icon(Icons.rate_review),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                    ),
                    onPressed: _isSaving
                        ? null
                        : () => _handleCloseRoute(activeRoute.id),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      isAr ? 'تأكيد وإغلاق الجولة' : 'Confirmer et clôturer',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPastRoutesSection(
    AsyncValue<List<DeliveryRouteData>> historyAsync,
    bool isAr,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isAr
              ? 'سجل الجولات السابقة والكلوزينج'
              : 'Historique des tournées passées',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.md),
        historyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Erreur : $err'),
          data: (history) {
            final closedList = history
                .where((r) => r.status == 'closed')
                .toList();
            if (closedList.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    isAr
                        ? 'لا توجد جولات مغلقة سابقة'
                        : 'Aucune tournée passée clôturée.',
                  ),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: closedList.length,
              itemBuilder: (context, index) {
                final route = closedList[index];
                final currencyFormat = NumberFormat.currency(
                  locale: 'en',
                  symbol: l10n.currencySymbol,
                );
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ListTile(
                    leading: const Icon(
                      Icons.history_toggle_off,
                      color: Colors.grey,
                    ),
                    title: Text(
                      '${route.driverName ?? "Chauffeur"} | ${DateFormat('dd/MM/yyyy').format(route.date)}',
                    ),
                    subtitle: Text(
                      isAr
                          ? 'عداد النهاية: ${route.endKm ?? "-"} كم | صندوق النهاية: ${currencyFormat.format(route.endCash ?? 0.0)}'
                          : 'KM Final : ${route.endKm ?? "-"} | Caisse : ${currencyFormat.format(route.endCash ?? 0.0)}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        _showHistoricalReportDialog(context, route, isAr),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _showHistoricalReportDialog(
    BuildContext context,
    DeliveryRouteData route,
    bool isAr,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAr ? 'تقرير الجولة التاريخي' : 'Rapport Historique'),
        content: Consumer(
          builder: (context, ref, _) {
            final reportAsync = ref.watch(
              deliveryRouteReportProvider(route.id),
            );
            final currencyFormat = NumberFormat.currency(
              locale: 'en',
              symbol: l10n.currencySymbol,
            );
            final quantityFormat = NumberFormat.decimalPattern('en');

            return reportAsync.when(
              loading: () => const SizedBox(
                height: 150,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, __) => Text('Erreur : $err'),
              data: (report) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDialogRow(
                        isAr ? 'تاريخ الجولة' : 'Date',
                        DateFormat('dd/MM/yyyy').format(route.date),
                      ),
                      _buildDialogRow(
                        isAr ? 'اسم السائق' : 'Chauffeur',
                        route.driverName ?? '-',
                      ),
                      _buildDialogRow(
                        isAr ? 'عداد البداية' : 'KM Départ',
                        '${route.startKm ?? "-"}',
                      ),
                      _buildDialogRow(
                        isAr ? 'عداد النهاية' : 'KM Final',
                        '${route.endKm ?? "-"}',
                      ),
                      _buildDialogRow(
                        isAr ? 'صندوق البداية' : 'Caisse Départ',
                        currencyFormat.format(route.startCash),
                      ),
                      _buildDialogRow(
                        isAr ? 'صندوق النهاية' : 'Caisse Finale',
                        currencyFormat.format(route.endCash ?? 0.0),
                      ),
                      const Divider(),
                      _buildDialogRow(
                        isAr ? 'عدد المبيعات' : 'Nombre Ventes',
                        '${report.saleCount}',
                      ),
                      _buildDialogRow(
                        isAr ? 'إجمالي المبيعات' : 'Total Ventes',
                        currencyFormat.format(report.salesTotal),
                      ),
                      _buildDialogRow(
                        isAr ? 'التحصيل الفعلي' : 'Total Espèces',
                        currencyFormat.format(report.cashTotal),
                      ),
                      _buildDialogRow(
                        isAr ? 'الديون المسجلة' : 'Crédits créés',
                        currencyFormat.format(report.creditTotal),
                      ),
                      _buildDialogRow(
                        isAr ? 'إجمالي المرتجعات' : 'Total Retours',
                        currencyFormat.format(report.returnsTotal),
                      ),
                      const Divider(),
                      _buildDialogRow(
                        isAr ? 'الكمية المشحونة' : 'Quantité Chargée',
                        quantityFormat.format(report.loadedQuantity),
                      ),
                      _buildDialogRow(
                        isAr ? 'الكمية المباعة' : 'Quantité Vendue',
                        quantityFormat.format(report.soldQuantity),
                      ),
                      if (route.note != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            isAr
                                ? 'الملاحظة: ${route.note}'
                                : 'Note : ${route.note}',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final repo = ref.read(deliveryRouteRepositoryProvider);
              final report = await repo.getRouteReport(route.id);
              if (!context.mounted) return;
              await _shareReportPdf(context, report);
            },
            icon: const Icon(Icons.share_outlined),
            label: Text(isAr ? 'Ù…Ø´Ø§Ø±ÙƒØ© PDF' : 'Partager PDF'),
          ),
          TextButton.icon(
            onPressed: () async {
              final repo = ref.read(deliveryRouteRepositoryProvider);
              final report = await repo.getRouteReport(route.id);
              if (!context.mounted) return;
              await _exportReportPdf(context, report);
            },
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: Text(isAr ? 'ØªØµØ¯ÙŠØ± PDF' : 'Exporter PDF'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(isAr ? 'إغلاق' : 'Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildReportActions(
    BuildContext context,
    PosDailyReport report,
    bool isAr,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _shareReportPdf(context, report),
            icon: const Icon(Icons.share_outlined),
            label: Text(isAr ? 'Ù…Ø´Ø§Ø±ÙƒØ© PDF' : 'Partager PDF'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _exportReportPdf(context, report),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: Text(isAr ? 'ØªØµØ¯ÙŠØ± PDF' : 'Exporter PDF'),
          ),
        ),
      ],
    );
  }

  Future<void> _shareReportPdf(
    BuildContext context,
    PosDailyReport report,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.read(businessProfileProvider).value;
    try {
      final file = await PdfDriverDayReportService.generateReportPdf(
        report: report,
        l10n: l10n,
        profile: profile,
      );
      await Share.shareXFiles([
        XFile(file.path),
      ], text: '${l10n.dailyReport} - ${report.warehouseName}');
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.errorGeneratingPdf}: $error')),
      );
    }
  }

  Future<void> _exportReportPdf(
    BuildContext context,
    PosDailyReport report,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.read(businessProfileProvider).value;
    try {
      final tempFile = await PdfDriverDayReportService.generateReportPdf(
        report: report,
        l10n: l10n,
        profile: profile,
      );
      final output = await getApplicationDocumentsDirectory();
      final safeWarehouse = report.warehouseName.replaceAll(
        RegExp(r'[^A-Za-z0-9_-]+'),
        '_',
      );
      final savedPath = p.join(
        output.path,
        'rapport_fin_journee_$safeWarehouse.pdf',
      );
      final savedFile = await tempFile.copy(savedPath);
      await OpenFilex.open(savedFile.path);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${l10n.pdfDownloadedAndOpened}\n${p.basename(savedFile.path)}',
          ),
        ),
      );
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.errorGeneratingPdf}: $error')),
      );
    }
  }

  Widget _buildMetaItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryIndigo, size: 20),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleStartRoute() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(deliveryRouteRepositoryProvider);
      await repo.startRoute(
        warehouseId: _selectedWarehouseId!,
        driverName: _driverNameController.text.trim().isEmpty
            ? null
            : _driverNameController.text.trim(),
        startKm: double.tryParse(_startKmController.text.replaceAll(',', '.')),
        startCash: double.tryParse(
          _startCashController.text.replaceAll(',', '.'),
        ),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      // Invalidate current providers to refresh all views reactively
      ref.invalidate(activeDeliveryRouteProvider);
      ref.invalidate(deliveryRouteHistoryProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.localeName == 'ar'
                ? 'تم بدء الجولة بنجاح!'
                : 'Tournée démarrée avec succès !',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleCloseRoute(int routeId) async {
    if (!_closeFormKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(deliveryRouteRepositoryProvider);
      await repo.closeRoute(
        routeId: routeId,
        endKm: double.tryParse(_endKmController.text.replaceAll(',', '.')),
        endCash: double.tryParse(_endCashController.text.replaceAll(',', '.')),
        note: _closeNoteController.text.trim().isEmpty
            ? null
            : _closeNoteController.text.trim(),
      );

      ref.invalidate(activeDeliveryRouteProvider);
      ref.invalidate(deliveryRouteHistoryProvider);

      if (!mounted) return;
      setState(() {
        _showClosureForm = false;
        _driverNameController.clear();
        _startKmController.text = '0';
        _startCashController.text = '0';
        _noteController.clear();
        _endKmController.clear();
        _endCashController.clear();
        _closeNoteController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.localeName == 'ar'
                ? 'تم تسجيل كلوزينج وإغلاق اليوم بنجاح!'
                : 'Clôture de la journée enregistrée avec succès !',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
