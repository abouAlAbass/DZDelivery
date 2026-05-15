class QuoteItem {
  final int? id;
  final int quoteId;
  final String description;
  final double quantity;
  final double unitPrice;
  final double amount;

  const QuoteItem({
    this.id,
    required this.quoteId,
    required this.description,
    this.quantity = 1,
    this.unitPrice = 0,
    this.amount = 0,
  });
}
