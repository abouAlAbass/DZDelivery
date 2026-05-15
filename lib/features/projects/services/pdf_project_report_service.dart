import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';


import '../../../l10n/app_localizations.dart';
import '../../invoices/domain/entities/invoice.dart';
import '../../invoices/domain/entities/invoice_status.dart';
import '../../payments/domain/entities/payment.dart';
import '../domain/entities/project.dart';
import '../domain/entities/project_expense.dart';
import '../domain/entities/project_status.dart';
import '../../refunds/domain/entities/refund.dart';

class PdfProjectReportService {
  static const _ink = PdfColors.blueGrey900;
  static const _muted = PdfColors.blueGrey600;
  static const _line = PdfColors.blueGrey100;
  static const _soft = PdfColors.grey100;
  static const _accent = PdfColors.teal700;

  static Future<File> generateProjectReportPdf({
    required Project project,
    required List<Invoice> invoices,
    required List<ProjectExpense> expenses,
    required List<Payment> payments,
    required List<Refund> refunds,
    required AppLocalizations l10n,
  }) async {
    final isRtl = l10n.localeName == 'ar';
    final textDirection = isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    
    // Load Fonts
    final regular = await PdfGoogleFonts.notoSansRegular();
    final bold = await PdfGoogleFonts.notoSansBold();
    
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

    final paidByInvoice = <int, double>{};
    for (final payment in payments) {
      paidByInvoice[payment.invoiceId] =
          (paidByInvoice[payment.invoiceId] ?? 0) + payment.amount;
    }

    final invoiceTotal = invoices.fold(0.0, (sum, item) => sum + item.total);
    final expenseTotal = expenses.fold(0.0, (sum, item) => sum + item.amount);
    final paidTotal = payments.fold(0.0, (sum, item) => sum + item.amount);
    final remainingTotal = invoices.fold(0.0, (sum, invoice) {
      final remaining = invoice.total - (paidByInvoice[invoice.id] ?? 0);
      return sum + (remaining > 0 ? remaining : 0);
    });

    final refundTotal = refunds.fold(0.0, (sum, item) => sum + item.totalAmount);
    final profit = (invoiceTotal - refundTotal) - expenseTotal;
    final invoiceById = {
      for (final invoice in invoices)
        if (invoice.id != null) invoice.id!: invoice,
    };

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: isRtl ? arabicRegular : regular,
        bold: isRtl ? arabicBold : bold,
        fontFallback: isRtl ? [regular, bold] : [arabicRegular, arabicBold],
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        textDirection: textDirection,
        build: (context) => [
          _header(project, l10n, isRtl),
          pw.SizedBox(height: 16),
          _summaryGrid(
            l10n,
            invoiceTotal,
            expenseTotal,
            paidTotal,
            remainingTotal,
            profit,
            isRtl,
          ),
          pw.SizedBox(height: 20),
          _sectionTitle(l10n.relatedInvoices),
          _invoicesTable(
            invoices,
            paidByInvoice,
            l10n,
            textDirection,
            isRtl,
          ),
          pw.SizedBox(height: 18),
          _sectionTitle(l10n.expenses),
          _expensesTable(
            expenses,
            l10n,
            textDirection,
            isRtl,
          ),
          pw.SizedBox(height: 18),
          _sectionTitle(l10n.payments),
          _paymentsTable(
            payments,
            invoiceById,
            l10n,
            textDirection,
            isRtl,
          ),
          if (refunds.isNotEmpty) ...[
            pw.SizedBox(height: 18),
            _sectionTitle(l10n.refunds),
            _refundsTable(
              refunds,
              invoiceById,
              l10n,
              textDirection,
              isRtl,
            ),
          ],
        ],
        footer: (context) => _footer(context, project, l10n, isRtl),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File(
      p.join(output.path, 'project_report_${_safeFileName(project.name)}.pdf'),
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _header(
    Project project,
    AppLocalizations l10n,
    bool isRtl,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: _ink,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: isRtl
            ? pw.CrossAxisAlignment.end
            : pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: isRtl
                      ? pw.CrossAxisAlignment.end
                      : pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      l10n.projectDetails,
                      style: pw.TextStyle(
                        color: PdfColors.blueGrey100,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      project.name,
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _statusPill(project.status, l10n),
            ],
          ),
          pw.SizedBox(height: 14),
          pw.Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _headerChip(
                l10n.clientName,
                project.clientName ?? l10n.notProvided,
              ),
              _headerChip(l10n.date, _formatDate(DateTime.now(), l10n, isRtl)),
              if (project.siteAddress != null &&
                  project.siteAddress!.isNotEmpty)
                _headerChip(l10n.siteAddress, project.siteAddress!),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _headerChip(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey800,
        borderRadius: pw.BorderRadius.circular(20),
      ),
      child: pw.Text(
        '$label: $value',
        style: const pw.TextStyle(color: PdfColors.white, fontSize: 8.5),
      ),
    );
  }

  static pw.Widget _summaryGrid(
    AppLocalizations l10n,
    double invoiceTotal,
    double expenseTotal,
    double paidTotal,
    double remainingTotal,
    double profit,
    bool isRtl,
  ) {
    final items = [
      _SummaryItem(
        l10n.invoices,
        _formatCurrency(invoiceTotal, l10n, isRtl),
        PdfColors.indigo700,
      ),
      _SummaryItem(
        l10n.expenses,
        _formatCurrency(expenseTotal, l10n, isRtl),
        PdfColors.red700,
      ),
      _SummaryItem(
        l10n.paidAmount,
        _formatCurrency(paidTotal, l10n, isRtl),
        PdfColors.green700,
      ),
      _SummaryItem(
        l10n.remainingToPay,
        _formatCurrency(remainingTotal, l10n, isRtl),
        PdfColors.orange700,
      ),
      _SummaryItem(
        l10n.estimatedProfit,
        _formatCurrency(profit, l10n, isRtl),
        profit >= 0 ? PdfColors.teal700 : PdfColors.red700,
      ),
    ];

    return pw.Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return pw.Container(
          width: 158,
          padding: const pw.EdgeInsets.all(11),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            border: pw.Border.all(color: _line, width: 0.8),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                item.label,
                style: const pw.TextStyle(color: _muted, fontSize: 8.5),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                item.value,
                style: pw.TextStyle(
                  color: item.color,
                  fontSize: 12.5,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
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

  static pw.Widget _invoicesTable(
    List<Invoice> invoices,
    Map<int, double> paidByInvoice,
    AppLocalizations l10n,
    pw.TextDirection textDirection,
    bool isRtl,
  ) {
    if (invoices.isEmpty) return _emptyLine(l10n.noInvoices);

    final rows = invoices.map<List<dynamic>>((invoice) {
      final paid = paidByInvoice[invoice.id] ?? 0;
      final remaining = invoice.total - paid;
      return [
        invoice.invoiceNumber,
        _formatDate(invoice.issueDate, l10n, isRtl),
        _invoiceStatusPill(invoice.status, l10n),
        _formatCurrency(invoice.total, l10n, isRtl),
        _formatCurrency(paid, l10n, isRtl),
        _formatCurrency(remaining > 0 ? remaining : 0, l10n, isRtl),
      ];
    }).toList();

    return _table(
      headers: isRtl ? [
        l10n.remainingToPay,
        l10n.paidAmount,
        l10n.total,
        l10n.status,
        l10n.date,
        l10n.invoiceNumber,
      ] : [
        l10n.invoiceNumber,
        l10n.date,
        l10n.status,
        l10n.total,
        l10n.paidAmount,
        l10n.remainingToPay,
      ],
      rows: isRtl ? rows.map((r) => r.reversed.toList()).toList() : rows,
      textDirection: textDirection,
      isRtl: isRtl,
      alignments: isRtl ? {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        5: pw.Alignment.centerRight,
      } : {
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
      },
      columnWidths: isRtl ? const {
        0: pw.FlexColumnWidth(1.4),
        1: pw.FlexColumnWidth(1.3),
        2: pw.FlexColumnWidth(1.3),
        3: pw.FlexColumnWidth(1.2),
        4: pw.FlexColumnWidth(1.4),
        5: pw.FlexColumnWidth(1.5),
      } : const {
        0: pw.FlexColumnWidth(1.5),
        1: pw.FlexColumnWidth(1.4),
        2: pw.FlexColumnWidth(1.2),
        3: pw.FlexColumnWidth(1.3),
        4: pw.FlexColumnWidth(1.3),
        5: pw.FlexColumnWidth(1.4),
      },
    );
  }
  static pw.Widget _expensesTable(
    List<ProjectExpense> expenses,
    AppLocalizations l10n,
    pw.TextDirection textDirection,
    bool isRtl,
  ) {
    if (expenses.isEmpty) return _emptyLine(l10n.noExpenses);

    return _table(
      headers: isRtl ? [
        l10n.amount,
        l10n.paymentMethod,
        l10n.supplier,
        l10n.expenseType,
        l10n.expense,
        l10n.date,
      ] : [
        l10n.date,
        l10n.expense,
        l10n.expenseType,
        l10n.supplier,
        l10n.paymentMethod,
        l10n.amount,
      ],
      rows: expenses.map<List<dynamic>>((expense) {
        final row = [
          _formatDate(expense.date, l10n, isRtl),
          expense.label,
          expense.expenseTypeName ?? '',
          expense.supplier ?? '',
          expense.paymentMethod ?? '',
          _formatCurrency(expense.amount, l10n, isRtl),
        ];
        return isRtl ? row.reversed.toList() : row;
      }).toList(),
      textDirection: textDirection,
      isRtl: isRtl,
      alignments: isRtl ? {
        0: pw.Alignment.centerLeft,
        5: pw.Alignment.centerRight,
      } : {
        5: pw.Alignment.centerRight,
      },
      columnWidths: isRtl ? const {
        0: pw.FlexColumnWidth(1.2),
        1: pw.FlexColumnWidth(1.4),
        2: pw.FlexColumnWidth(1.4),
        3: pw.FlexColumnWidth(1.4),
        4: pw.FlexColumnWidth(2.2),
        5: pw.FlexColumnWidth(1.2),
      } : const {
        0: pw.FlexColumnWidth(1.2),
        1: pw.FlexColumnWidth(2.2),
        2: pw.FlexColumnWidth(1.4),
        3: pw.FlexColumnWidth(1.4),
        4: pw.FlexColumnWidth(1.4),
        5: pw.FlexColumnWidth(1.2),
      },
    );
  }
  static pw.Widget _paymentsTable(
    List<Payment> payments,
    Map<int, Invoice> invoiceById,
    AppLocalizations l10n,
    pw.TextDirection textDirection,
    bool isRtl,
  ) {
    if (payments.isEmpty) return _emptyLine(l10n.noPayments);

    return _table(
      headers: isRtl ? [
        l10n.amount,
        l10n.paymentMethod,
        l10n.clientName,
        l10n.invoiceNumber,
        l10n.date,
      ] : [
        l10n.date,
        l10n.invoiceNumber,
        l10n.clientName,
        l10n.paymentMethod,
        l10n.amount,
      ],
      rows: payments.map<List<dynamic>>((payment) {
        final invoice = invoiceById[payment.invoiceId];
        final row = [
          _formatDate(payment.date, l10n, isRtl),
          invoice?.invoiceNumber ?? '${payment.invoiceId}',
          payment.client?.name ?? invoice?.client?.name ?? '',
          payment.method ?? '',
          _formatCurrency(payment.amount, l10n, isRtl),
        ];
        return isRtl ? row.reversed.toList() : row;
      }).toList(),
      textDirection: textDirection,
      isRtl: isRtl,
      alignments: isRtl ? {
        0: pw.Alignment.centerLeft,
        4: pw.Alignment.centerRight,
      } : {
        4: pw.Alignment.centerRight,
      },
      columnWidths: isRtl ? const {
        0: pw.FlexColumnWidth(1.2),
        1: pw.FlexColumnWidth(1.4),
        2: pw.FlexColumnWidth(2),
        3: pw.FlexColumnWidth(1.4),
        4: pw.FlexColumnWidth(1.2),
      } : const {
        0: pw.FlexColumnWidth(1.2),
        1: pw.FlexColumnWidth(1.4),
        2: pw.FlexColumnWidth(2),
        3: pw.FlexColumnWidth(1.4),
        4: pw.FlexColumnWidth(1.2),
      },
    );
  }
  static pw.Widget _refundsTable(
    List<Refund> refunds,
    Map<int, Invoice> invoiceById,
    AppLocalizations l10n,
    pw.TextDirection textDirection,
    bool isRtl,
  ) {
    return _table(
      headers: isRtl ? [
        l10n.amount,
        l10n.invoiceNumberShort,
        l10n.refundNumber,
        l10n.date,
      ] : [
        l10n.date,
        l10n.refundNumber,
        l10n.invoiceNumberShort,
        l10n.amount,
      ],
      rows: refunds.map<List<dynamic>>((refund) {
        final invoice = invoiceById[refund.invoiceId];
        final row = [
          _formatDate(refund.date, l10n, isRtl),
          refund.refundNumber,
          invoice?.invoiceNumber ?? '',
          _formatCurrency(refund.totalAmount, l10n, isRtl),
        ];
        return isRtl ? row.reversed.toList() : row;
      }).toList(),
      textDirection: textDirection,
      isRtl: isRtl,
      alignments: isRtl ? {
        0: pw.Alignment.centerLeft,
        3: pw.Alignment.centerRight,
      } : {
        3: pw.Alignment.centerRight,
      },
      columnWidths: isRtl ? const {
        0: pw.FlexColumnWidth(1.2),
        1: pw.FlexColumnWidth(1.2),
        2: pw.FlexColumnWidth(1.5),
        3: pw.FlexColumnWidth(1.2),
      } : const {
        0: pw.FlexColumnWidth(1.2),
        1: pw.FlexColumnWidth(1.5),
        2: pw.FlexColumnWidth(1.2),
        3: pw.FlexColumnWidth(1.2),
      },
    );
  }

  static pw.Widget _table({
    required List<String> headers,
    required List<List<dynamic>> rows,
    required pw.TextDirection textDirection,
    required Map<int, pw.TableColumnWidth> columnWidths,
    required bool isRtl,
    Map<int, pw.AlignmentGeometry> alignments = const {},
  }) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      border: const pw.TableBorder(
        top: pw.BorderSide(color: _line, width: 0.8),
        bottom: pw.BorderSide(color: _line, width: 0.8),
        horizontalInside: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
      ),
      headerDecoration: const pw.BoxDecoration(color: _ink),
      oddRowDecoration: const pw.BoxDecoration(color: _soft),
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 8.2,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: const pw.TextStyle(
        color: PdfColors.blueGrey800,
        fontSize: 7.8,
      ),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      headerPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      headerAlignment: pw.Alignment.center,
      cellAlignment: pw.Alignment.centerLeft,
      cellAlignments: alignments,
      columnWidths: columnWidths,
    );
  }

  static pw.Widget _emptyLine(String text) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _soft,
        border: pw.Border.all(color: _line, width: 0.8),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Text(
        text,
        style: const pw.TextStyle(color: _muted, fontSize: 9),
      ),
    );
  }

  static pw.Widget _footer(
    pw.Context context,
    Project project,
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
            project.name,
            style: pw.TextStyle(
              color: _ink,
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            '${_formatDate(DateTime.now(), l10n, isRtl)} - ${context.pageNumber}/${context.pagesCount}',
            style: const pw.TextStyle(color: _muted, fontSize: 8),
          ),
        ],
      ),
    );
  }

  static pw.Widget _statusPill(ProjectStatus status, AppLocalizations l10n) {
    final colors = _projectStatusColors(status);
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: pw.BoxDecoration(
        color: colors.$1,
        borderRadius: pw.BorderRadius.circular(18),
      ),
      child: pw.Text(
        _projectStatus(l10n, status),
        style: pw.TextStyle(
          color: colors.$2,
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _invoiceStatusPill(
    InvoiceStatus status,
    AppLocalizations l10n,
  ) {
    final colors = _invoiceStatusColors(status);
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: pw.BoxDecoration(
        color: colors.$1,
        borderRadius: pw.BorderRadius.circular(15),
      ),
      child: pw.Text(
        _invoiceStatus(l10n, status),
        style: pw.TextStyle(
          color: colors.$2,
          fontSize: 7,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static (PdfColor, PdfColor) _projectStatusColors(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planned:
        return (PdfColors.blue100, PdfColors.blue800);
      case ProjectStatus.inProgress:
        return (PdfColors.orange100, PdfColors.orange800);
      case ProjectStatus.completed:
        return (PdfColors.green100, PdfColors.green800);
      case ProjectStatus.awaitingPayment:
        return (PdfColors.red100, PdfColors.red800);
    }
  }

  static (PdfColor, PdfColor) _invoiceStatusColors(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return (PdfColors.green100, PdfColors.green800);
      case InvoiceStatus.sent:
        return (PdfColors.blue100, PdfColors.blue800);
      case InvoiceStatus.accepted:
        return (PdfColors.teal100, PdfColors.teal800);
      case InvoiceStatus.converted:
        return (PdfColors.indigo100, PdfColors.indigo800);
      case InvoiceStatus.overdue:
      case InvoiceStatus.unpaid:
        return (PdfColors.red100, PdfColors.red800);
      case InvoiceStatus.cancelled:
        return (PdfColors.grey300, PdfColors.grey800);
      case InvoiceStatus.draft:
        return (PdfColors.blueGrey100, PdfColors.blueGrey800);
    }
  }

  static String _projectStatus(AppLocalizations l10n, ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planned:
        return l10n.planned;
      case ProjectStatus.inProgress:
        return l10n.inProgress;
      case ProjectStatus.completed:
        return l10n.completed;
      case ProjectStatus.awaitingPayment:
        return l10n.awaitingPayment;
    }
  }

  static String _invoiceStatus(AppLocalizations l10n, InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return l10n.draft;
      case InvoiceStatus.sent:
        return l10n.sent;
      case InvoiceStatus.accepted:
        return l10n.accepted;
      case InvoiceStatus.converted:
        return l10n.converted;
      case InvoiceStatus.paid:
        return l10n.paid;
      case InvoiceStatus.unpaid:
        return l10n.unpaid;
      case InvoiceStatus.cancelled:
        return l10n.cancelled;
      case InvoiceStatus.overdue:
        return l10n.overdue;
    }
  }

  static String _safeFileName(String value) {
    return value
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
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

class _SummaryItem {
  final String label;
  final String value;
  final PdfColor color;

  const _SummaryItem(this.label, this.value, this.color);
}
