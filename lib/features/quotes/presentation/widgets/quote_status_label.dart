import 'package:flutter/material.dart';
import 'package:hissab_dz/core/theme/theme.dart';
import 'package:hissab_dz/features/quotes/domain/entities/quote_status.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';

String quoteStatusText(AppLocalizations l10n, QuoteStatus status) {
  switch (status) {
    case QuoteStatus.draft:
      return l10n.draft;
    case QuoteStatus.sent:
      return l10n.sent;
    case QuoteStatus.accepted:
      return l10n.accepted;
    case QuoteStatus.rejected:
      return l10n.rejected;
    case QuoteStatus.converted:
      return l10n.converted;
    case QuoteStatus.expired:
      return l10n.expired;
  }
}

Color quoteStatusColor(QuoteStatus status) {
  switch (status) {
    case QuoteStatus.draft:
      return AppColors.neutral;
    case QuoteStatus.sent:
      return AppColors.info;
    case QuoteStatus.accepted:
      return AppColors.success;
    case QuoteStatus.rejected:
      return AppColors.danger;
    case QuoteStatus.converted:
      return AppColors.quote;
    case QuoteStatus.expired:
      return AppColors.textMuted;
  }
}

class QuoteStatusChip extends StatelessWidget {
  final QuoteStatus status;

  const QuoteStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = quoteStatusColor(status);
    return Chip(
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: color.withValues(alpha: 0.2)),
      backgroundColor: color.withValues(alpha: 0.1),
      label: Text(
        quoteStatusText(l10n, status),
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
