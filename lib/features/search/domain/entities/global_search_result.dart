import 'package:flutter/material.dart';

enum GlobalSearchType { client, invoice, project, article, payment }

class GlobalSearchResult {
  final GlobalSearchType type;
  final int id;
  final String title;
  final String subtitle;
  final double? amount;
  final DateTime? date;

  const GlobalSearchResult({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    this.amount,
    this.date,
  });

  IconData get icon {
    switch (type) {
      case GlobalSearchType.client:
        return Icons.person_outline;
      case GlobalSearchType.invoice:
        return Icons.description_outlined;
      case GlobalSearchType.project:
        return Icons.folder_open_outlined;
      case GlobalSearchType.article:
        return Icons.inventory_2_outlined;
      case GlobalSearchType.payment:
        return Icons.payments_outlined;
    }
  }
}
