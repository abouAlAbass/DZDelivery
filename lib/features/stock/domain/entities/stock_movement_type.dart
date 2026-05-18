abstract final class StockMovementTypes {
  static const purchase = 'purchase';
  static const sale = 'sale';
  static const returnType = 'return';
  static const adjustment = 'adjustment';
  static const truckLoad = 'truck_load';
  static const truckUnload = 'truck_unload';
  static const transferIn = 'transfer_in';
  static const transferOut = 'transfer_out';

  static const values = [
    purchase,
    sale,
    returnType,
    adjustment,
    truckLoad,
    truckUnload,
    transferIn,
    transferOut,
  ];
}

abstract final class StockMovementSourceTypes {
  static const purchase = 'purchase';
  static const stockTransfer = 'stock_transfer';
  static const sale = 'sale';
  static const saleReturn = 'sale_return';
}
