class RefundItem {
  final int? id;
  final int? refundId;
  final int invoiceItemId;
  final double quantity;
  final double unitPrice;
  final double amount;
  final String? description; // Optional: copied from invoice item for display

  RefundItem({
    this.id,
    this.refundId,
    required this.invoiceItemId,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
    this.description,
  });

  RefundItem copyWith({
    int? id,
    int? refundId,
    int? invoiceItemId,
    double? quantity,
    double? unitPrice,
    double? amount,
    String? description,
  }) {
    return RefundItem(
      id: id ?? this.id,
      refundId: refundId ?? this.refundId,
      invoiceItemId: invoiceItemId ?? this.invoiceItemId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      amount: amount ?? this.amount,
      description: description ?? this.description,
    );
  }
}
