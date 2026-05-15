import 'package:flutter/material.dart';
import 'package:hissab_dz/core/theme/theme.dart';
import '../../features/invoices/domain/entities/invoice_status.dart';
import '../../l10n/app_localizations.dart';

class StatusBadge extends StatelessWidget {
  final InvoiceStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Color color;
    String label;

    switch (status) {
      case InvoiceStatus.draft:
        color = AppColors.neutral;
        label = l10n.draft;
        break;
      case InvoiceStatus.sent:
        color = AppColors.invoice;
        label = l10n.sent;
        break;
      case InvoiceStatus.accepted:
        color = AppColors.success;
        label = l10n.accepted;
        break;
      case InvoiceStatus.converted:
        color = AppColors.quote;
        label = l10n.converted;
        break;
      case InvoiceStatus.paid:
        color = AppColors.success;
        label = l10n.paid;
        break;
      case InvoiceStatus.unpaid:
        color = AppColors.danger;
        label = l10n.unpaid;
        break;
      case InvoiceStatus.cancelled:
        color = AppColors.neutral;
        label = l10n.cancelled;
        break;
      case InvoiceStatus.overdue:
        color = AppColors.danger;
        label = l10n.overdue;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
