class ArticleStockOverview {
  final int articleId;
  final String articleName;
  final String? articleCode;
  final double salePrice;
  final double purchasePrice;
  final List<WarehouseStockQuantity> warehouseStocks;

  const ArticleStockOverview({
    required this.articleId,
    required this.articleName,
    this.articleCode,
    required this.salePrice,
    required this.purchasePrice,
    required this.warehouseStocks,
  });
}

class WarehouseStockQuantity {
  final int warehouseId;
  final String warehouseName;
  final String warehouseType;
  final double quantity;

  const WarehouseStockQuantity({
    required this.warehouseId,
    required this.warehouseName,
    required this.warehouseType,
    required this.quantity,
  });
}
