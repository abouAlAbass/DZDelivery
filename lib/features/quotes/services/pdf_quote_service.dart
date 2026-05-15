import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';


import '../../../l10n/app_localizations.dart';
import '../../settings/domain/entities/business_profile.dart';
import '../domain/entities/quote.dart';
import '../domain/entities/quote_status.dart';

class PdfQuoteService {
  static const _ink = PdfColors.blueGrey900;
  static const _muted = PdfColors.blueGrey600;
  static const _line = PdfColors.blueGrey100;
  static const _soft = PdfColors.grey100;
  static const _accent = PdfColors.deepPurple700;

  static Future<File> generateQuotePdf({
    required Quote quote,
    BusinessProfile? profile,
    required AppLocalizations l10n,
  }) async {
    final isRtl = l10n.localeName == 'ar';
    final textDirection = isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    
    // Load Fonts
    final notoRegular = await PdfGoogleFonts.notoSansRegular();
    final notoBold = await PdfGoogleFonts.notoSansBold();
    
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

    pw.MemoryImage? logoImage;
    if (profile?.logoPath != null) {
      final logoFile = File(profile!.logoPath!);
      if (logoFile.existsSync()) {
        logoImage = pw.MemoryImage(await logoFile.readAsBytes());
      }
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

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 34, vertical: 30),
        textDirection: textDirection,
        build: (context) => [
          _header(quote, profile, logoImage, l10n, isRtl),
          pw.SizedBox(height: 16),
          _infoRow(quote, l10n, isRtl),
          pw.SizedBox(height: 20),
          _itemsTable(quote, l10n, textDirection, isRtl),
          pw.SizedBox(height: 18),
          _totals(quote, l10n, isRtl),
        ],
        footer: (context) => _footer(context, l10n, isRtl),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File(
      p.join(output.path, 'quote_${quote.quoteNumber}.pdf'),
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _header(
    Quote quote,
    BusinessProfile? profile,
    pw.MemoryImage? logo,
    AppLocalizations l10n,
    bool isRtl,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: _ink,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 6,
            child: _businessBlock(profile, logo, l10n, isRtl),
          ),
          pw.SizedBox(width: 18),
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: isRtl
                  ? pw.CrossAxisAlignment.start
                  : pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  _headline(l10n.quoteLabel, isRtl),
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 25,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  quote.quoteNumber,
                  style: const pw.TextStyle(
                    color: PdfColors.blueGrey100,
                    fontSize: 11,
                  ),
                ),
                pw.SizedBox(height: 10),
                _statusPill(quote.status, l10n),
                pw.SizedBox(height: 10),
                _headerMeta(
                  l10n.issueDate,
                  _formatDate(quote.issueDate, l10n, isRtl),
                  isRtl,
                ),
                if (quote.validUntil != null)
                  _headerMeta(
                    l10n.validUntil,
                    _formatDate(quote.validUntil!, l10n, isRtl),
                    isRtl,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _businessBlock(
    BusinessProfile? profile,
    pw.MemoryImage? logo,
    AppLocalizations l10n,
    bool isRtl,
  ) {
    final profileName = profile?.companyName.trim();
    final companyName = profileName != null && profileName.isNotEmpty
        ? profileName
        : l10n.companyName;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _logoMark(logo, companyName),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: isRtl
                ? pw.CrossAxisAlignment.end
                : pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                companyName,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              if (profile?.address != null && profile!.address!.isNotEmpty)
                _businessLine(profile.address!),
              if (profile?.phone != null && profile!.phone!.isNotEmpty)
                _businessLine(profile.phone!),
              if (profile?.email != null && profile!.email!.isNotEmpty)
                _businessLine(profile.email!),
              if (profile?.website != null && profile!.website!.isNotEmpty)
                _businessLine(profile.website!),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _logoMark(pw.MemoryImage? logo, String companyName) {
    if (logo != null) {
      return pw.Container(
        width: 62,
        height: 62,
        padding: const pw.EdgeInsets.all(5),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Image(logo, fit: pw.BoxFit.contain),
      );
    }

    final letters = companyName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.substring(0, 1))
        .join()
        .toUpperCase();

    return pw.Container(
      width: 62,
      height: 62,
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Center(
        child: pw.Text(
          letters.isEmpty ? 'HD' : letters,
          style: pw.TextStyle(
            color: _ink,
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static pw.Widget _businessLine(String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Text(
        value,
        style: const pw.TextStyle(color: PdfColors.blueGrey100, fontSize: 9),
      ),
    );
  }

  static pw.Widget _headerMeta(String label, String value, bool isRtl) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 2),
      child: pw.Row(
        mainAxisAlignment: isRtl
            ? pw.MainAxisAlignment.start
            : pw.MainAxisAlignment.end,
        children: [
          pw.Text(
            '$label: ',
            style: const pw.TextStyle(
              color: PdfColors.blueGrey100,
              fontSize: 8.5,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _infoRow(
    Quote quote,
    AppLocalizations l10n,
    bool isRtl,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 6,
          child: _panel(
            title: l10n.billTo,
            child: pw.Column(
              crossAxisAlignment: isRtl
                  ? pw.CrossAxisAlignment.end
                  : pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  quote.client?.name ?? l10n.unknownClient,
                  style: pw.TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                if (quote.client?.email != null)
                  _detailLine(quote.client!.email!),
                if (quote.client?.phone != null)
                  _detailLine(quote.client!.phone!),
                if (quote.client?.address != null)
                  _detailLine(quote.client!.address!),
                if (quote.projectName != null && quote.projectName!.isNotEmpty)
                  _detailLine('${l10n.project}: ${quote.projectName!}'),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 14),
        pw.Expanded(
          flex: 4,
          child: _panel(
            title: l10n.quoteDetails,
            child: pw.Column(
              children: [
                _infoLine(l10n.quoteNumber, quote.quoteNumber, isRtl),
                _thinDivider(),
                _infoLine(
                  l10n.issueDate,
                  _formatDate(quote.issueDate, l10n, isRtl),
                  isRtl,
                ),
                if (quote.validUntil != null) ...[
                  _thinDivider(),
                  _infoLine(
                    l10n.validUntil,
                    _formatDate(quote.validUntil!, l10n, isRtl),
                    isRtl,
                  ),
                ],
                _thinDivider(),
                _infoLine(
                  l10n.status,
                  _quoteStatusLabel(quote.status, l10n),
                  isRtl,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _panel({required String title, required pw.Widget child}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(13),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: _line, width: 0.8),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              color: _muted,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  static pw.Widget _detailLine(String value) {
    if (value.trim().isEmpty) return pw.SizedBox();
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Text(
        value,
        style: const pw.TextStyle(color: PdfColors.blueGrey700, fontSize: 9.5),
      ),
    );
  }

  static pw.Widget _infoLine(String label, String value, bool isRtl) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              color: PdfColors.blueGrey600,
              fontSize: 9,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: _ink,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _itemsTable(
    Quote quote,
    AppLocalizations l10n,
    pw.TextDirection textDirection,
    bool isRtl,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(l10n.items),
        pw.TableHelper.fromTextArray(
          headers: isRtl 
            ? [l10n.amount, l10n.price, l10n.quantity, l10n.description]
            : [l10n.description, l10n.quantity, l10n.price, l10n.amount],
          data: quote.items.map((item) {
            final row = [
              item.description,
              _quantity(item.quantity),
              _formatCurrency(item.unitPrice, l10n, isRtl),
              _formatCurrency(item.amount, l10n, isRtl),
            ];
            return isRtl ? row.reversed.toList() : row;
          }).toList(),
          border: const pw.TableBorder(
            top: pw.BorderSide(color: _line, width: 0.8),
            bottom: pw.BorderSide(color: _line, width: 0.8),
            horizontalInside: pw.BorderSide(
              color: PdfColors.grey200,
              width: 0.5,
            ),
          ),
          headerDecoration: const pw.BoxDecoration(color: _ink),
          oddRowDecoration: const pw.BoxDecoration(color: _soft),
          headerStyle: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
          ),
          cellStyle: const pw.TextStyle(
            color: PdfColors.blueGrey800,
            fontSize: 9,
          ),
          cellPadding: const pw.EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          headerPadding: const pw.EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          headerAlignment: pw.Alignment.center,
          cellAlignment: pw.Alignment.centerLeft,
          cellAlignments: isRtl ? {
            3: pw.Alignment.centerRight,
          } : {
            0: pw.Alignment.centerLeft,
          },
          columnWidths: isRtl ? const {
            0: pw.FlexColumnWidth(1.8), // Amount
            1: pw.FlexColumnWidth(1.8), // Price
            2: pw.FlexColumnWidth(1.1), // Qty
            3: pw.FlexColumnWidth(5),   // Description
          } : const {
            0: pw.FlexColumnWidth(5),
            1: pw.FlexColumnWidth(1.1),
            2: pw.FlexColumnWidth(1.8),
            3: pw.FlexColumnWidth(1.8),
          },
        ),
      ],
    );
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          pw.Container(width: 4, height: 15, color: _accent),
          pw.SizedBox(width: 7),
          pw.Text(
            title,
            style: pw.TextStyle(
              color: _ink,
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _totals(
    Quote quote,
    AppLocalizations l10n,
    bool isRtl,
  ) {
    final taxAmount = quote.subtotal * quote.taxRate / 100;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(flex: 5, child: _notes(quote.notes, l10n)),
        pw.SizedBox(width: 18),
        pw.Expanded(
          flex: 4,
          child: pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _line, width: 0.8),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              children: [
                _totalRow(
                  l10n.subtotal,
                  _formatCurrency(quote.subtotal, l10n, isRtl),
                  isRtl,
                ),
                _thinDivider(),
                _totalRow(
                  '${l10n.totalTax} (${_quantity(quote.taxRate)}%)',
                  _formatCurrency(taxAmount, l10n, isRtl),
                  isRtl,
                ),
                _thinDivider(),
                _totalRow(
                  l10n.discount,
                  '- ${_formatCurrency(quote.discountAmount, l10n, isRtl)}',
                  isRtl,
                ),
                _totalRow(
                  l10n.total,
                  _formatCurrency(quote.total, l10n, isRtl),
                  isRtl,
                  isHighlighted: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _notes(String? notes, AppLocalizations l10n) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(13),
      decoration: pw.BoxDecoration(
        color: _soft,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            l10n.notes,
            style: pw.TextStyle(
              color: _muted,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 7),
          pw.Text(
            notes?.trim().isNotEmpty == true
                ? notes!.trim()
                : l10n.paymentTerms,
            style: const pw.TextStyle(
              color: PdfColors.blueGrey700,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _totalRow(
    String label,
    String value,
    bool isRtl, {
    bool isHighlighted = false,
  }) {
    final color = isHighlighted ? PdfColors.white : _ink;
    return pw.Container(
      color: isHighlighted ? _ink : PdfColors.white,
      padding: pw.EdgeInsets.symmetric(
        horizontal: 12,
        vertical: isHighlighted ? 10 : 7,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              color: color,
              fontSize: isHighlighted ? 12 : 9,
              fontWeight: isHighlighted ? pw.FontWeight.bold : null,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: color,
              fontSize: isHighlighted ? 13 : 9,
              fontWeight: isHighlighted ? pw.FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _footer(
    pw.Context context,
    AppLocalizations l10n,
    bool isRtl,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _line, width: 0.8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            l10n.thankyou,
            style: pw.TextStyle(
              color: _ink,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            '${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(color: _muted, fontSize: 8),
          ),
        ],
      ),
    );
  }

  static pw.Widget _statusPill(QuoteStatus status, AppLocalizations l10n) {
    final colors = _statusColors(status);
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: pw.BoxDecoration(
        color: colors.$1,
        borderRadius: pw.BorderRadius.circular(20),
      ),
      child: pw.Text(
        _quoteStatusLabel(status, l10n),
        style: pw.TextStyle(
          color: colors.$2,
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static (PdfColor, PdfColor) _statusColors(QuoteStatus status) {
    switch (status) {
      case QuoteStatus.accepted:
        return (PdfColors.green100, PdfColors.green800);
      case QuoteStatus.sent:
        return (PdfColors.blue100, PdfColors.blue800);
      case QuoteStatus.converted:
        return (PdfColors.indigo100, PdfColors.indigo800);
      case QuoteStatus.rejected:
        return (PdfColors.red100, PdfColors.red800);
      case QuoteStatus.draft:
        return (PdfColors.blueGrey100, PdfColors.blueGrey800);
      case QuoteStatus.expired:
        return (PdfColors.orange100, PdfColors.orange800);
    }
  }

  static String _quoteStatusLabel(QuoteStatus status, AppLocalizations l10n) {
    switch (status) {
      case QuoteStatus.draft:
        return l10n.draft;
      case QuoteStatus.sent:
        return l10n.sent;
      case QuoteStatus.accepted:
        return l10n.accepted;
      case QuoteStatus.converted:
        return l10n.converted;
      case QuoteStatus.rejected:
        return l10n.rejected;
      case QuoteStatus.expired:
        return l10n.expired;
    }
  }

  static pw.Widget _thinDivider() {
    return pw.Container(height: 0.7, color: _line);
  }

  static String _quantity(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }

  static String _headline(String value, bool isRtl) {
    return isRtl ? value : value.toUpperCase();
  }

  static String _formatDate(DateTime date, AppLocalizations l10n, bool isRtl) {
    if (!isRtl) return DateFormat.yMMMd(l10n.localeName).format(date);
    return DateFormat('dd/MM/yyyy', 'en').format(date);
  }

  static String _formatCurrency(double amount, AppLocalizations l10n, bool isRtl) {
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '');
    final formattedAmount = formatter.format(amount).trim();
    if (!isRtl) return '${l10n.currencySymbol} $formattedAmount';
    if (isRtl) {
      return '\u200F$formattedAmount ${l10n.currencySymbol}';
    }
    return '${l10n.currencySymbol} $formattedAmount';
  }
}

