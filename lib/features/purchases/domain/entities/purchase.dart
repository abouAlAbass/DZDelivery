class Purchase {
  final int? id;
  final int? supplierId;
  final DateTime date;
  final double total;
  final String status;
  final DateTime? confirmedAt;
  final String? note;
  final List<PurchaseItem> items;

  const Purchase({
    this.id,
    this.supplierId,
    required this.date,
    required this.total,
    this.status = 'draft',
    this.confirmedAt,
    this.note,
    this.items = const [],
  });
}

class PurchaseItem {
  final int? id;
  final int? purchaseId;
  final int articleId;
  final double quantity;
  final double purchasePrice;

  const PurchaseItem({
    this.id,
    this.purchaseId,
    required this.articleId,
    required this.quantity,
    required this.purchasePrice,
  });

  double get total => quantity * purchasePrice;
}
