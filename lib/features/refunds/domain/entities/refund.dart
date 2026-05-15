import 'refund_item.dart';

class Refund {
  final int? id;
  final int invoiceId;
  final String refundNumber;
  final DateTime date;
  final String? reason;
  final double totalAmount;
  final DateTime? createdAt;
  final bool isValidated;
  final List<RefundItem> items;

  Refund({
    this.id,
    required this.invoiceId,
    required this.refundNumber,
    required this.date,
    this.reason,
    required this.totalAmount,
    this.createdAt,
    this.isValidated = false,
    this.items = const [],
  });

  Refund copyWith({
    int? id,
    int? invoiceId,
    String? refundNumber,
    DateTime? date,
    String? reason,
    double? totalAmount,
    DateTime? createdAt,
    bool? isValidated,
    List<RefundItem>? items,
  }) {
    return Refund(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      refundNumber: refundNumber ?? this.refundNumber,
      date: date ?? this.date,
      reason: reason ?? this.reason,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      isValidated: isValidated ?? this.isValidated,
      items: items ?? this.items,
    );
  }
}
