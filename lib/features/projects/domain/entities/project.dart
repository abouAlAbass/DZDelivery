import 'project_status.dart';

class Project {
  final int? id;
  final int? clientId;
  final String name;
  final String? clientName;
  final String? siteAddress;
  final ProjectStatus status;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final double invoiceTotal;
  final double expenseTotal;

  const Project({
    this.id,
    this.clientId,
    required this.name,
    this.clientName,
    this.siteAddress,
    this.status = ProjectStatus.planned,
    this.description,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.invoiceTotal = 0,
    this.expenseTotal = 0,
  });

  double get balance => invoiceTotal - expenseTotal;
}
