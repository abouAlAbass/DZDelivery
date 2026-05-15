class ProjectExpense {
  final int? id;
  final int? projectId;
  final int? expenseTypeId;
  final String label;
  final double amount;
  final DateTime date;
  final String? supplier;
  final String? paymentMethod;
  final String? receiptPath;
  final String? notes;
  final String? expenseTypeName;
  final String? projectName;

  const ProjectExpense({
    this.id,
    this.projectId,
    this.expenseTypeId,
    required this.label,
    required this.amount,
    required this.date,
    this.supplier,
    this.paymentMethod,
    this.receiptPath,
    this.notes,
    this.expenseTypeName,
    this.projectName,
  });
}
