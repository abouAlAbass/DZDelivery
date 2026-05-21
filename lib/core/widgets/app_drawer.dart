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
    final location = GoRouterState.of(context).uri.path;
    final isDarkMode =
        themeMode == ThemeMode.dark ||
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
                        'assets/images/logo.png',
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
            _pushNamedTile(
              context,
              icon: Icons.search,
              title: l10n.globalSearch,
              routeName: 'global_search',
            ),
            const Divider(),
            _goTile(
              context,
              icon: Icons.dashboard,
              title: l10n.dashboard,
              path: '/',
            ),
            ExpansionTile(
              leading: const Icon(Icons.point_of_sale),
              title: Text(l10n.posVente),
              initiallyExpanded:
                  location.startsWith('/pos') &&
                  !location.startsWith('/pos/stock') &&
                  !location.startsWith('/pos/truck-loading'),
              children: [
                _goTile(
                  context,
                  icon: Icons.home_outlined,
                  title: l10n.posHome,
                  path: '/pos',
                  nested: true,
                ),
                _goTile(
                  context,
                  icon: Icons.local_shipping_outlined,
                  title: l10n.deliveryRoute,
                  path: '/pos/delivery-route',
                  nested: true,
                ),
                _goTile(
                  context,
                  icon: Icons.point_of_sale,
                  title: l10n.quickSale,
                  path: '/pos/quick-sale',
                  nested: true,
                ),
                _goTile(
                  context,
                  icon: Icons.receipt_long,
                  title: l10n.sales,
                  path: '/pos/sales',
                  nested: true,
                ),
                _goTile(
                  context,
                  icon: Icons.bar_chart,
                  title: l10n.dailyReportMenu,
                  path: '/pos/daily-report',
                  nested: true,
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.inventory_2),
              title: Text(l10n.stockAchats),
              initiallyExpanded:
                  location.startsWith('/articles') ||
                  location.startsWith('/purchases') ||
                  location.startsWith('/suppliers') ||
                  location.startsWith('/pos/stock') ||
                  location.startsWith('/pos/truck-loading'),
              children: [
                _goTile(
                  context,
                  icon: Icons.inventory_2,
                  title: l10n.articles,
                  path: '/articles',
                  nested: true,
                ),
                _goTile(
                  context,
                  icon: Icons.warehouse,
                  title: l10n.stockPos,
                  path: '/pos/stock',
                  nested: true,
                ),
                _goTile(
                  context,
                  icon: Icons.add_shopping_cart,
                  title: l10n.purchases,
                  path: '/purchases',
                  nested: true,
                ),
                _goTile(
                  context,
                  icon: Icons.local_shipping,
                  title: l10n.truckLoading,
                  path: '/pos/truck-loading',
                  nested: true,
                ),
                _goTile(
                  context,
                  icon: Icons.store,
                  title: l10n.suppliers,
                  path: '/suppliers',
                  nested: true,
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.people),
              title: Text(l10n.clientsDocuments),
              initiallyExpanded:
                  location.startsWith('/clients') ||
                  location.startsWith('/quotes') ||
                  location.startsWith('/invoices') ||
                  location.startsWith('/payments') ||
                  location.startsWith('/refunds'),
              children: [
                _goTile(
                  context,
                  icon: Icons.people,
                  title: l10n.clients,
                  path: '/clients',
                  nested: true,
                ),
                _goTile(
                  context,
                  icon: Icons.request_quote,
                  title: l10n.quotes,
                  path: '/quotes',
                  nested: true,
                ),
                _goTile(
                  context,
                  icon: Icons.description,
                  title: l10n.invoices,
                  path: '/invoices',
                  nested: true,
                ),
                _goTile(
                  context,
                  icon: Icons.payments,
                  title: l10n.payments,
                  path: '/payments',
                  nested: true,
                ),
                _goTile(
                  context,
                  icon: Icons.assignment_return,
                  title: l10n.refunds,
                  path: '/refunds',
                  nested: true,
                ),
              ],
            ),
            _goTile(
              context,
              icon: Icons.receipt_long,
              title: l10n.expenses,
              path: '/expenses',
            ),
            const Divider(),
            _pushNamedTile(
              context,
              icon: Icons.settings,
              title: l10n.settings,
              routeName: 'settings',
            ),
            SwitchListTile(
              secondary: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: isDarkMode ? Colors.amber : Colors.blueGrey,
              ),
              title: Text(isDarkMode ? l10n.darkMode : l10n.lightMode),
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
                    )['native']
                    as String,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              onTap: () =>
                  _showLanguageDialog(context, ref, l10n, currentLocale),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '${l10n.appTitle} v1.0',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _goTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String path,
    bool nested = false,
  }) {
    final location = GoRouterState.of(context).uri.path;
    final isSelected =
        location == path || (path != '/' && location.startsWith(path));

    return ListTile(
      contentPadding: EdgeInsetsDirectional.only(
        start: nested ? 32 : 16,
        end: 16,
      ),
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      selected: isSelected,
      onTap: () {
        Navigator.pop(context);
        context.go(path);
      },
    );
  }

  Widget _pushNamedTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String routeName,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        context.pushNamed(routeName);
      },
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
