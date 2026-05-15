import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/theme.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(appLocaleProvider);
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ... (keep previous header)
            Container(
              height: 180,
              decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/iconHissabDZ.jpg',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.appTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ... (keep other menu items)
            ListTile(
              leading: const Icon(Icons.search),
              title: Text(l10n.globalSearch),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed('global_search');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: Text(l10n.dashboard),
              onTap: () {
                Navigator.pop(context);
                context.go('/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: Text(l10n.projects),
              onTap: () {
                Navigator.pop(context);
                context.go('/projects');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: Text(l10n.clients),
              onTap: () {
                Navigator.pop(context);
                context.go('/clients');
              },
            ),
            ListTile(
              leading: const Icon(Icons.request_quote),
              title: Text(l10n.quotes),
              onTap: () {
                Navigator.pop(context);
                context.go('/quotes');
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: Text(l10n.invoices),
              onTap: () {
                Navigator.pop(context);
                context.go('/invoices');
              },
            ),
            ListTile(
              leading: const Icon(Icons.payments),
              title: Text(l10n.payments),
              onTap: () {
                Navigator.pop(context);
                context.go('/payments');
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_return),
              title: Text(l10n.refunds),
              onTap: () {
                Navigator.pop(context);
                context.go('/refunds');
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text(l10n.expenses),
              onTap: () {
                Navigator.pop(context);
                context.go('/expenses');
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: Text(l10n.articles),
              onTap: () {
                Navigator.pop(context);
                context.go('/articles');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(l10n.settings),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed('settings');
              },
            ),
            SwitchListTile(
              secondary: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: isDarkMode ? Colors.amber : Colors.blueGrey,
              ),
              title: Text(isDarkMode ? 'Dark Mode' : 'Light Mode'),
              value: isDarkMode,
              onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.selectLanguage),
              trailing: Text(
                supportedLocalesInfo.firstWhere(
                  (m) =>
                      (m['locale'] as Locale).languageCode ==
                      currentLocale.languageCode,
                  orElse: () => supportedLocalesInfo.first,
                )['flag'] as String,
                style: const TextStyle(fontSize: 22),
              ),
              onTap: () =>
                  _showLanguageDialog(context, ref, l10n, currentLocale),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Invoice Pro v1.0',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Locale current,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: supportedLocalesInfo.map((info) {
            final locale = info['locale'] as Locale;
            final isSelected = locale.languageCode == current.languageCode;
            return ListTile(
              leading: Text(
                info['flag'] as String,
                style: const TextStyle(fontSize: 22),
              ),
              title: Text(info['native'] as String),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () {
                ref.read(appLocaleProvider.notifier).setLocale(locale);
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
