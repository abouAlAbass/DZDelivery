import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hissab_dz/core/theme/theme.dart';
import 'package:hissab_dz/core/widgets/app_drawer.dart';
import 'package:hissab_dz/core/widgets/responsive_content.dart';
import 'package:hissab_dz/features/sales/domain/entities/sale.dart';
import 'package:hissab_dz/features/sales/presentation/providers/sale_providers.dart';
import 'package:hissab_dz/features/sales/services/pdf_driver_day_report_service.dart';
import 'package:hissab_dz/features/settings/domain/entities/business_profile.dart';
import 'package:hissab_dz/features/settings/presentation/providers/settings_providers.dart';
import 'package:hissab_dz/features/stock/presentation/providers/stock_providers.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';

class DailyPosReportScreen extends ConsumerStatefulWidget {
  const DailyPosReportScreen({super.key});

  @override
  ConsumerState<DailyPosReportScreen> createState() =>
      _DailyPosReportScreenState();
}

class _DailyPosReportScreenState extends ConsumerState<DailyPosReportScreen> {
  DateTime _date = DateTime.now();
  int? _warehouseId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final trucks = ref.watch(truckWarehousesProvider).value ?? [];
    _warehouseId ??= trucks.isEmpty ? null : trucks.first.id;

    final request = PosDailyReportRequest(
      date: _date,
      warehouseId: _warehouseId,
    );
    final reportAsync = ref.watch(posDailyReportProvider(request));
    final profile = ref.watch(businessProfileProvider).value;
    final currencyFormat = NumberFormat.currency(locale: 'en', symbol: l10n.currencySymbol);
    final quantityFormat = NumberFormat.decimalPattern('en');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dailyReport)),
      drawer: MediaQuery.sizeOf(context).width >= 1100
          ? null
          : const AppDrawer(),
      body: ResponsiveContent(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.bottomNavClearance,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    key: ValueKey(_warehouseId),
                    initialValue: _warehouseId,
                    decoration: InputDecoration(labelText: l10n.truck),
                    items: trucks
                        .map(
                          (truck) => DropdownMenuItem<int>(
                            value: truck.id,
                            child: Text(truck.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _warehouseId = value),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton.filledTonal(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined),
                  tooltip: l10n.date,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            reportAsync.when(
              data: (report) => _ReportBody(
                report: report,
                currencyFormat: currencyFormat,
                quantityFormat: quantityFormat,
                onShare: () => _shareTextReport(report, l10n, quantityFormat),
                onExportPdf: () => _exportPdf(report, l10n, profile),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('$error')),
            ),
          ],
        ),
      ),
    );
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

  void _shareTextReport(
    PosDailyReport report,
    AppLocalizations l10n,
    NumberFormat quantityFormat,
  ) {
    final money = NumberFormat.decimalPattern('en');
    Share.share(
      [
        '${l10n.dailyReport} - ${report.warehouseName}',
        DateFormat('dd/MM/yyyy', 'en').format(report.date),
        '',
        '${l10n.stockLoaded} : ${_formatQuantity(quantityFormat, report.loadedQuantity)} ${l10n.articles.toLowerCase()}',
        '${l10n.sold} : ${_formatQuantity(quantityFormat, report.soldQuantity)} ${l10n.articles.toLowerCase()}',
        '${l10n.truckReturn} : ${_formatQuantity(quantityFormat, report.truckReturnQuantity)} ${l10n.articles.toLowerCase()}',
        '',
        '${l10n.totalSales} : ${money.format(report.salesTotal)} ${l10n.currencySymbol}',
        '${l10n.cash} : ${money.format(report.cashTotal)} ${l10n.currencySymbol}',
        '${l10n.clientCredit} : ${money.format(report.creditTotal)} ${l10n.currencySymbol}',
        '${l10n.returns} : ${money.format(report.returnsTotal)} ${l10n.currencySymbol}',
      ].join('\n'),
    );
  }

  Future<void> _exportPdf(
    PosDailyReport report,
    AppLocalizations l10n,
    BusinessProfile? profile,
  ) async {
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
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }
}

class _ReportBody extends StatelessWidget {
  final PosDailyReport report;
  final NumberFormat currencyFormat;
  final NumberFormat quantityFormat;
  final VoidCallback onShare;
  final VoidCallback onExportPdf;

  const _ReportBody({
    required this.report,
    required this.currencyFormat,
    required this.quantityFormat,
    required this.onShare,
    required this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${l10n.dailyReport} - ${report.warehouseName}',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(DateFormat('dd/MM/yyyy', 'en').format(report.date)),
        const SizedBox(height: AppSpacing.lg),
        _Metric(
          l10n.stockLoaded,
          '${_formatQuantity(quantityFormat, report.loadedQuantity)} ${l10n.articles.toLowerCase()}',
          Icons.inventory_2_outlined,
        ),
        _Metric(
          l10n.sold,
          '${_formatQuantity(quantityFormat, report.soldQuantity)} ${l10n.articles.toLowerCase()}',
          Icons.point_of_sale_outlined,
        ),
        _Metric(
          l10n.truckReturn,
          '${_formatQuantity(quantityFormat, report.truckReturnQuantity)} ${l10n.articles.toLowerCase()}',
          Icons.local_shipping_outlined,
        ),
        const SizedBox(height: AppSpacing.md),
        _Metric(
          l10n.totalSales,
          currencyFormat.format(report.salesTotal),
          Icons.receipt_long_outlined,
        ),
        _Metric(
          l10n.cash,
          currencyFormat.format(report.cashTotal),
          Icons.payments,
        ),
        _Metric(
          l10n.clientCredit,
          currencyFormat.format(report.creditTotal),
          Icons.account_balance_wallet_outlined,
        ),
        _Metric(
          l10n.returns,
          currencyFormat.format(report.returnsTotal),
          Icons.assignment_return_outlined,
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          onPressed: onShare,
          icon: const Icon(Icons.share_outlined),
          label: Text(l10n.shareReport),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: onExportPdf,
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: Text(l10n.exportPdf),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _Metric(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

String _formatQuantity(NumberFormat formatter, double value) {
  if (value == value.roundToDouble()) return formatter.format(value.round());
  return formatter.format(value);
}
