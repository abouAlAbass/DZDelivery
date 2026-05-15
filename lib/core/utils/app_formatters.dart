import 'package:intl/intl.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';

class AppFormatters {
  static String formatCurrency(double amount, AppLocalizations l10n) {
    // Use en_US locale for numbers to ensure Western digits (1, 2, 3)
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '');
    final formattedAmount = formatter.format(amount).trim();
    
    if (l10n.localeName == 'ar') {
      return '\u200F$formattedAmount ${l10n.currencySymbol}';
    }
    return '${l10n.currencySymbol} $formattedAmount';
  }
}
