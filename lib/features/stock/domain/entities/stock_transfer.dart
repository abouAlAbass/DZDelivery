class StockTransfer {
  final int? id;
  final int fromWarehouseId;
  final int toWarehouseId;
  final DateTime date;
  final String status;
  final DateTime? confirmedAt;
  final String? note;
  final List<StockTransferItem> items;
  final int? routeId;

  const StockTransfer({
    this.id,
    required this.fromWarehouseId,
    required this.toWarehouseId,
    required this.date,
    this.status = 'draft',
    this.confirmedAt,
    this.note,
    this.items = const [],
    this.routeId,
  });
}

class StockTransferItem {
  final int? id;
  final int? transferId;
  final int articleId;
  final double quantity;

  const StockTransferItem({
    this.id,
    this.transferId,
    required this.articleId,
    required this.quantity,
  });
}
