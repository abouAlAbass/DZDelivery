import '../../../clients/domain/entities/client.dart';
import 'quote_item.dart';
import 'quote_status.dart';

class Quote {
  final int? id;
  final int clientId;
  final int? projectId;
  final String quoteNumber;
  final QuoteStatus status;
  final DateTime issueDate;
  final DateTime? validUntil;
  final String? notes;
  final String? approvalName;
  final DateTime? approvedAt;
  final double subtotal;
  final double taxRate;
  final double discountAmount;
  final double total;
  final int? convertedInvoiceId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<QuoteItem> items;
  final Client? client;
  final String? projectName;

  const Quote({
    this.id,
    required this.clientId,
    this.projectId,
    required this.quoteNumber,
    this.status = QuoteStatus.draft,
    required this.issueDate,
    this.validUntil,
    this.notes,
    this.approvalName,
    this.approvedAt,
    this.subtotal = 0,
    this.taxRate = 0,
    this.discountAmount = 0,
    this.total = 0,
    this.convertedInvoiceId,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
    this.client,
    this.projectName,
  });
Quote recalculateTotals() {
    double calculatedSubtotal = 0.0;
    for (final item in items) {
      calculatedSubtotal += item.quantity * item.unitPrice; // À adapter selon QuoteItem
    }
    
    final taxAmount = calculatedSubtotal * (taxRate / 100);
    final calculatedTotal = calculatedSubtotal + taxAmount - discountAmount;

    return copyWith(
      subtotal: calculatedSubtotal,
      total: calculatedTotal,
    );
  }
  Quote copyWith({
    int? id,
    int? clientId,
    int? projectId,
    String? quoteNumber,
    QuoteStatus? status,
    DateTime? issueDate,
    DateTime? validUntil,
    String? notes,
    String? approvalName,
    DateTime? approvedAt,
    double? subtotal,
    double? taxRate,
    double? discountAmount,
    double? total,
    int? convertedInvoiceId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<QuoteItem>? items,
    Client? client,
    String? projectName,
  }) {
    return Quote(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      projectId: projectId ?? this.projectId,
      quoteNumber: quoteNumber ?? this.quoteNumber,
      status: status ?? this.status,
      issueDate: issueDate ?? this.issueDate,
      validUntil: validUntil ?? this.validUntil,
      notes: notes ?? this.notes,
      approvalName: approvalName ?? this.approvalName,
      approvedAt: approvedAt ?? this.approvedAt,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      discountAmount: discountAmount ?? this.discountAmount,
      total: total ?? this.total,
      convertedInvoiceId: convertedInvoiceId ?? this.convertedInvoiceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      client: client ?? this.client,
      projectName: projectName ?? this.projectName,
    );
  }
}
