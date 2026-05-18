class Sale {
  final int? id;
  final String saleNumber;
  final int? clientId;
  final int warehouseId;
  final DateTime date;
  final double subtotal;
  final double discountAmount;
  final double total;
  final double paidAmount;
  final String paymentStatus;
  final String status;
  final String? note;
  final List<SaleItem> items;
  final SalePayment? payment;
  final int? routeId;

  const Sale({
    this.id,
    required this.saleNumber,
    this.clientId,
    required this.warehouseId,
    required this.date,
    required this.subtotal,
    this.discountAmount = 0,
    required this.total,
    this.paidAmount = 0,
    this.paymentStatus = 'unpaid',
    this.status = 'draft',
    this.note,
    this.items = const [],
    this.payment,
    this.routeId,
  });
}

class SaleItem {
  final int? id;
  final int? saleId;
  final int articleId;
  final double quantity;
  final double unitPrice;
  final double discountAmount;
  final double total;

  const SaleItem({
    this.id,
    this.saleId,
    required this.articleId,
    required this.quantity,
    required this.unitPrice,
    this.discountAmount = 0,
    required this.total,
  });
}

class SalePayment {
  final int? id;
  final int? saleId;
  final double amount;
  final String method;
  final DateTime date;
  final String? note;
  final int? routeId;

  const SalePayment({
    this.id,
    this.saleId,
    required this.amount,
    required this.method,
    required this.date,
    this.note,
    this.routeId,
  });
}

class SaleReturn {
  final int? id;
  final int? saleId;
  final int? clientId;
  final int warehouseId;
  final DateTime date;
  final double total;
  final String status;
  final DateTime? confirmedAt;
  final String? note;
  final List<SaleReturnItem> items;
  final int? routeId;

  const SaleReturn({
    this.id,
    this.saleId,
    this.clientId,
    required this.warehouseId,
    required this.date,
    required this.total,
    this.status = 'draft',
    this.confirmedAt,
    this.note,
    this.items = const [],
    this.routeId,
  });
}

class SaleReturnItem {
  final int? id;
  final int? returnId;
  final int articleId;
  final double quantity;
  final double unitPrice;
  final double total;

  const SaleReturnItem({
    this.id,
    this.returnId,
    required this.articleId,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });
}

class PosDailyReport {
  final DateTime date;
  final int? warehouseId;
  final String warehouseName;
  final int saleCount;
  final double loadedQuantity;
  final double soldQuantity;
  final double truckReturnQuantity;
  final double salesTotal;
  final double cashTotal;
  final double creditTotal;
  final double returnsTotal;
  final double unpaidTotal;
  final double partialTotal;
  final Map<int, double> truckStock;

  const PosDailyReport({
    required this.date,
    this.warehouseId,
    required this.warehouseName,
    required this.saleCount,
    required this.loadedQuantity,
    required this.soldQuantity,
    required this.truckReturnQuantity,
    required this.salesTotal,
    required this.cashTotal,
    required this.creditTotal,
    required this.returnsTotal,
    required this.unpaidTotal,
    required this.partialTotal,
    required this.truckStock,
  });
}
