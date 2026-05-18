import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:hissab_dz/features/articles/domain/entities/article.dart';
import 'package:hissab_dz/features/sales/domain/entities/sale.dart';
import 'package:hissab_dz/features/settings/domain/entities/business_profile.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';

class PdfPosReceiptService {
  static const _muted = PdfColors.grey700;
  static const _line = PdfColors.grey400;

  static Future<File> generateReceiptPdf({
    required Sale sale,
    required List<Article> articles,
    required AppLocalizations l10n,
    BusinessProfile? profile,
    String? clientName,
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
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'en');
    final pageHeight = (170 + (sale.items.length * 14))
        .clamp(190, 360)
        .toDouble();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat(
          80 * PdfPageFormat.mm,
          pageHeight * PdfPageFormat.mm,
        ),
        margin: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        textDirection: textDirection,
        build: (context) => [
          _header(profile),
          pw.SizedBox(height: 8),
          _meta(l10n.sale, sale.saleNumber, isRtl),
          _meta(l10n.date, dateFormat.format(sale.date), isRtl),
          if (clientName != null && clientName.trim().isNotEmpty)
            _meta(l10n.clientName, clientName.trim(), isRtl),
          pw.SizedBox(height: 8),
          _separator(),
          _itemsHeader(l10n, isRtl),
          _separator(),
          ...sale.items.map((item) => _itemRow(item, articles, l10n, isRtl)),
          _separator(),
          pw.SizedBox(height: 6),
          _totalRow(l10n.total, sale.total, l10n, isRtl, bold: true),
          _totalRow(l10n.paidAmount, sale.paidAmount, l10n, isRtl),
          _totalRow(
            l10n.remainingToPay,
            (sale.total - sale.paidAmount).clamp(0, double.infinity),
            l10n,
            isRtl,
          ),
          pw.SizedBox(height: 14),
          pw.Center(
            child: pw.Text(
              l10n.thankyou,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File(
      p.join(output.path, 'pos_receipt_${_safeFileName(sale.saleNumber)}_${DateTime.now().millisecondsSinceEpoch}.pdf'),
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _header(BusinessProfile? profile) {
    final companyName = profile?.companyName.trim().isNotEmpty == true
        ? profile!.companyName.trim()
        : 'DeliveryDZ';
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Center(
          child: pw.Text(
            companyName,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ),
        if (profile?.address?.trim().isNotEmpty == true)
          pw.Center(
            child: pw.Text(
              profile!.address!.trim(),
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 8, color: _muted),
            ),
          ),
        if (profile?.phone?.trim().isNotEmpty == true)
          pw.Center(
            child: pw.Text(
              profile!.phone!.trim(),
              style: const pw.TextStyle(fontSize: 8, color: _muted),
            ),
          ),
      ],
    );
  }
  static pw.Widget _meta(String label, String value, bool isRtl) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '$label :',
            style: const pw.TextStyle(
              fontSize: 8,
              color: _muted,
            ),
          ),
          pw.Text(
            value,
            style: const pw.TextStyle(
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
  static pw.Widget _itemsHeader(AppLocalizations l10n, bool isRtl) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          _cell(l10n.article, flex: 9, bold: true, align: isRtl ? pw.TextAlign.right : pw.TextAlign.left),
          _cell(l10n.quantity, flex: 3, align: isRtl ? pw.TextAlign.right : pw.TextAlign.right, bold: true),
          _cell(l10n.price, flex: 4, align: isRtl ? pw.TextAlign.right : pw.TextAlign.right, bold: true),
          _cell(l10n.total, flex: 5, align: isRtl ? pw.TextAlign.right : pw.TextAlign.right, bold: true),
        ],
      ),
    );
  }

  static pw.Widget _itemRow(
    SaleItem item,
    List<Article> articles,
    AppLocalizations l10n,
    bool isRtl,
  ) {
    final article = articles.where((article) => article.id == item.articleId);
    final articleName = article.isEmpty
        ? 'Article ${item.articleId}'
        : article.first.name;

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _cell(articleName, flex: 9, align: isRtl ? pw.TextAlign.right : pw.TextAlign.left),
          _cell(
            _formatQuantity(item.quantity),
            flex: 3,
            align: isRtl ? pw.TextAlign.right : pw.TextAlign.right,
          ),
          _cell(
            _formatMoney(item.unitPrice, l10n),
            flex: 4,
            align: isRtl ? pw.TextAlign.right : pw.TextAlign.right,
          ),
          _cell(
            _formatMoney(item.total, l10n),
            flex: 5,
            align: isRtl ? pw.TextAlign.right : pw.TextAlign.right,
          ),
        ],
      ),
    );
  }

  static pw.Widget _cell(
    String value, {
    required int flex,
    pw.TextAlign align = pw.TextAlign.left,
    bool bold = false,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Text(
        value,
        textAlign: align,
        maxLines: 2,
        style: pw.TextStyle(
          fontSize: 7.5,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _totalRow(
    String label,
    double value,
    AppLocalizations l10n,
    bool isRtl, {
    bool bold = false,
  }) {
    final formattedValue = _formatMoney(value, l10n);
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '$label :',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            formattedValue,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _separator() {
    return pw.Container(height: 0.5, color: _line);
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
