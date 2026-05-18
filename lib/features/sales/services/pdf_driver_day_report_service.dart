import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:hissab_dz/features/sales/domain/entities/sale.dart';
import 'package:hissab_dz/features/settings/domain/entities/business_profile.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';

class PdfDriverDayReportService {
  static Future<File> generateReportPdf({
    required PosDailyReport report,
    required AppLocalizations l10n,
    BusinessProfile? profile,
  }) async {
    final isRtl = l10n.localeName == 'ar';
    final textDirection = isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;

    // Load Fonts with try-catch fallback for robust offline support
    pw.Font notoRegular;
    pw.Font notoBold;
    try {
      notoRegular = await PdfGoogleFonts.notoSansRegular();
      notoBold = await PdfGoogleFonts.notoSansBold();
    } catch (e) {
      notoRegular = pw.Font.helvetica();
      notoBold = pw.Font.helveticaBold();
    }
    
    pw.Font arabicRegular;
    pw.Font arabicBold;
    
    try {
      final arabicRegularData = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
      final arabicBoldData = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');
      arabicRegular = pw.Font.ttf(arabicRegularData);
      arabicBold = pw.Font.ttf(arabicBoldData);
    } catch (e) {
      // Fallback to Google Fonts if local assets are missing
      arabicRegular = await PdfGoogleFonts.amiriRegular();
      arabicBold = await PdfGoogleFonts.amiriBold();
    }

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: isRtl ? arabicRegular : notoRegular,
        bold: isRtl ? arabicBold : notoBold,
        fontFallback: isRtl
            ? [notoRegular, notoBold]
            : [arabicRegular, arabicBold],
      ),
    );
    final dateFormat = DateFormat('dd/MM/yyyy', 'en');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        textDirection: textDirection,
        build: (context) => [
          _header(report, profile, dateFormat, isRtl, l10n),
          pw.SizedBox(height: 24),
          _sectionTitle(l10n.stock, isRtl),
          _metricRow(l10n.stockLoaded, _formatQuantity(report.loadedQuantity), isRtl),
          _metricRow(l10n.sold, _formatQuantity(report.soldQuantity), isRtl),
          _metricRow(
            l10n.truckReturn,
            _formatQuantity(report.truckReturnQuantity),
            isRtl,
          ),
          pw.SizedBox(height: 20),
          _sectionTitle(l10n.finance, isRtl),
          _metricRow(l10n.totalSales, _formatMoney(report.salesTotal, l10n), isRtl),
          _metricRow(l10n.cash, _formatMoney(report.cashTotal, l10n), isRtl),
          _metricRow(l10n.clientCredit, _formatMoney(report.creditTotal, l10n), isRtl),
          _metricRow(l10n.returns, _formatMoney(report.returnsTotal, l10n), isRtl),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File(
      p.join(
        output.path,
        'rapport_fin_journee_${_safeFileName(report.warehouseName)}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      ),
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _header(
    PosDailyReport report,
    BusinessProfile? profile,
    DateFormat dateFormat,
    bool isRtl,
    AppLocalizations l10n,
  ) {
    final title = isRtl
        ? 'تقرير اليوم - ${report.warehouseName}'
        : 'Rapport du jour - ${report.warehouseName}';
    return pw.Column(
      crossAxisAlignment: isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          profile?.companyName.trim().isNotEmpty == true
              ? profile!.companyName.trim()
              : 'DeliveryDZ',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.Text(dateFormat.format(report.date)),
      ],
    );
  }

  static pw.Widget _sectionTitle(String label, bool isRtl) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      color: PdfColors.blueGrey50,
      child: pw.Text(
        label,
        textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _metricRow(String label, String value, bool isRtl) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: isRtl
            ? [
                pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Expanded(child: pw.Text(label, textAlign: pw.TextAlign.right)),
              ]
            : [
                pw.Expanded(child: pw.Text(label)),
                pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
      ),
    );
  }

  static String _formatMoney(double value, AppLocalizations l10n) {
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '');
    final formattedAmount = formatter.format(value).trim();
    final isRtl = l10n.localeName == 'ar';
    if (isRtl) {
      return '\u200F$formattedAmount ${l10n.currencySymbol}';
    }
    return '$formattedAmount ${l10n.currencySymbol}';
  }

  static String _formatQuantity(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }

  static String _safeFileName(String value) {
    return value.replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_');
  }
}
