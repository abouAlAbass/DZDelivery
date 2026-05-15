import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../theme/theme.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/clients/presentation/pages/client_list_screen.dart';
import '../../features/clients/presentation/pages/client_details_screen.dart';
import '../../features/invoices/presentation/pages/invoice_list_screen.dart';
import '../../features/invoices/presentation/pages/invoice_details_screen.dart';
import '../../features/invoices/presentation/pages/create_invoice_screen.dart';
import '../../features/quotes/presentation/pages/create_quote_screen.dart';
import '../../features/quotes/presentation/pages/quote_details_screen.dart';
import '../../features/quotes/presentation/pages/quote_list_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';
import '../../features/payments/presentation/pages/payment_list_screen.dart';
import '../../features/articles/presentation/pages/article_list_screen.dart';
import '../../features/articles/presentation/pages/add_edit_article_screen.dart';
import '../../features/projects/presentation/pages/project_details_screen.dart';
import '../../features/projects/presentation/pages/expense_list_screen.dart';
import '../../features/projects/presentation/pages/project_list_screen.dart';
import '../../features/search/presentation/pages/global_search_screen.dart';
import '../../features/refunds/presentation/pages/create_refund_screen.dart';
import '../../features/refunds/presentation/pages/refund_details_screen.dart';
import '../../features/refunds/presentation/pages/refund_list_screen.dart';
import '../widgets/app_drawer.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

class AppRouter {
  static final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // 1. SHELL ROUTES (With Bottom Navigation Bar)
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithBottomNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/clients',
            name: 'clients',
            builder: (context, state) => const ClientListScreen(),
          ),
          GoRoute(
            path: '/quotes',
            name: 'quotes',
            builder: (context, state) => const QuoteListScreen(),
          ),
          GoRoute(
            path: '/invoices',
            name: 'invoices',
            builder: (context, state) => const InvoiceListScreen(),
          ),
          GoRoute(
            path: '/payments',
            name: 'payments',
            builder: (context, state) => const PaymentListScreen(),
          ),
          GoRoute(
            path: '/projects',
            name: 'projects',
            builder: (context, state) => const ProjectListScreen(),
          ),
          GoRoute(
            path: '/expenses',
            name: 'expenses',
            builder: (context, state) => const ExpenseListScreen(),
          ),
          GoRoute(
            path: '/articles',
            name: 'articles',
            builder: (context, state) => const ArticleListScreen(),
          ),
          GoRoute(
            path: '/refunds',
            name: 'refunds',
            builder: (context, state) => const RefundListScreen(),
          ),
        ],
      ),

      // 2. FULL SCREEN ROUTES (Above Bottom Navigation Bar)
      GoRoute(
        path: '/search',
        name: 'global_search',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const GlobalSearchScreen(),
      ),
      GoRoute(
        path: '/quotes/create',
        name: 'create_quote',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final projectIdString = state.uri.queryParameters['projectId'];
          final projectId = int.tryParse(projectIdString ?? '');
          return CreateQuoteScreen(initialProjectId: projectId);
        },
      ),
      GoRoute(
        path: '/quotes/:id/edit',
        name: 'edit_quote',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final idString = state.pathParameters['id'];
          final id = int.tryParse(idString ?? '') ?? 0;
          return CreateQuoteScreen(quoteId: id);
        },
      ),
      GoRoute(
        path: '/quotes/:id',
        name: 'quote_details',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final idString = state.pathParameters['id'];
          final id = int.tryParse(idString ?? '') ?? 0;
          return QuoteDetailsScreen(quoteId: id);
        },
      ),
      GoRoute(
        path: '/articles/add',
        name: 'add_article',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AddEditArticleScreen(),
      ),
      GoRoute(
        path: '/articles/edit/:id',
        name: 'edit_article',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final idString = state.pathParameters['id'];
          final id = int.tryParse(idString ?? '') ?? 0;
          return AddEditArticleScreen(articleId: id);
        },
      ),
      // These are siblings to the ShellRoute, so they use the root navigator
      GoRoute(
        path: '/clients/:id',
        name: 'client_details',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final idString = state.pathParameters['id'];
          final id = int.tryParse(idString ?? '') ?? 0;
          return ClientDetailsScreen(clientId: id);
        },
      ),
      GoRoute(
        path: '/invoices/create',
        name: 'create_invoice',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final projectIdString = state.uri.queryParameters['projectId'];
          final projectId = int.tryParse(projectIdString ?? '');
          return CreateInvoiceScreen(initialProjectId: projectId);
        },
      ),
      GoRoute(
        path: '/invoices/:id/edit',
        name: 'edit_invoice',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final idString = state.pathParameters['id'];
          final id = int.tryParse(idString ?? '') ?? 0;
          return CreateInvoiceScreen(invoiceId: id);
        },
      ),
      GoRoute(
        path: '/invoices/:id',
        name: 'invoice_details',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final idString = state.pathParameters['id'];
          final id = int.tryParse(idString ?? '') ?? 0;
          return InvoiceDetailsScreen(invoiceId: id);
        },
      ),
      GoRoute(
        path: '/invoices/:id/refund',
        name: 'create_refund',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final idString = state.pathParameters['id'];
          final id = int.tryParse(idString ?? '') ?? 0;
          return CreateRefundScreen(invoiceId: id);
        },
      ),
      GoRoute(
        path: '/refunds/:id',
        name: 'refund_details',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final idString = state.pathParameters['id'];
          final id = int.tryParse(idString ?? '') ?? 0;
          return RefundDetailsScreen(refundId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/projects/:id',
        name: 'project_details',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final idString = state.pathParameters['id'];
          final id = int.tryParse(idString ?? '') ?? 0;
          return ProjectDetailsScreen(projectId: id);
        },
      ),
    ],
  );
}

class ScaffoldWithBottomNavBar extends StatelessWidget {
  final Widget child;
  const ScaffoldWithBottomNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String location = GoRouterState.of(context).matchedLocation;
    final int selectedIndex = _calculateSelectedIndex(location);
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1100;
    final isTablet = width >= 720 && width < 1100;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            _DesktopSidebar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) => _goToIndex(context, index),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex.clamp(0, 6),
              minWidth: 72,
              groupAlignment: -0.85,
              labelType: NavigationRailLabelType.all,
              selectedIconTheme: const IconThemeData(
                color: AppTheme.primaryIndigo,
              ),
              selectedLabelTextStyle: const TextStyle(
                color: AppTheme.primaryIndigo,
                fontWeight: FontWeight.w700,
              ),
              onDestinationSelected: (index) => _goToIndex(context, index),
              destinations: _mainDestinations(l10n)
                  .map(
                    (item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      label: Text(item.label),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      extendBody: true, // Allow body to flow under bottom nav if needed
      drawer: const AppDrawer(),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _mobileSelectedIndex(location),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryIndigo,
        unselectedItemColor: Theme.of(context).textTheme.bodySmall?.color,
        showUnselectedLabels: true,
        onTap: (index) {
          switch (index) {
            case 0:
              context.goNamed('dashboard');
              break;
            case 1:
              context.goNamed('projects');
              break;
            case 2:
              context.goNamed('quotes');
              break;
            case 3:
              context.goNamed('invoices');
              break;
            case 4:
              context.goNamed('payments');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_rounded),
            label: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.folder_open_rounded),
            label: l10n.projects,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.request_quote_rounded),
            label: l10n.quotes,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.description_rounded),
            label: l10n.invoices,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.payments_rounded),
            label: l10n.payments,
          ),
        ],
      ),
    );
  }

  List<_ShellDestination> _mainDestinations(AppLocalizations l10n) {
    return [
      _ShellDestination(l10n.dashboard, Icons.dashboard_rounded),
      _ShellDestination(l10n.projects, Icons.folder_open_rounded),
      _ShellDestination(l10n.clients, Icons.people_rounded),
      _ShellDestination(l10n.quotes, Icons.request_quote_rounded),
      _ShellDestination(l10n.invoices, Icons.description_rounded),
      _ShellDestination(l10n.payments, Icons.payments_rounded),
      _ShellDestination(l10n.refunds, Icons.assignment_return_rounded),
      _ShellDestination(l10n.articles, Icons.inventory_2_rounded),
    ];
  }

  void _goToIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.goNamed('dashboard');
        break;
      case 1:
        context.goNamed('projects');
        break;
      case 2:
        context.goNamed('clients');
        break;
      case 3:
        context.goNamed('quotes');
        break;
      case 4:
        context.goNamed('invoices');
        break;
      case 5:
        context.goNamed('payments');
        break;
      case 6:
        context.goNamed('refunds');
        break;
      case 7:
        context.goNamed('articles');
        break;
    }
  }

  int _mobileSelectedIndex(String location) {
    if (location == '/') return 0;
    if (location.startsWith('/projects') || location.startsWith('/expenses')) {
      return 1;
    }
    if (location.startsWith('/quotes')) return 2;
    if (location.startsWith('/invoices')) return 3;
    if (location.startsWith('/payments')) return 4;
    return 0;
  }

  int _calculateSelectedIndex(String location) {
    if (location == '/') return 0;
    if (location.startsWith('/projects')) return 1;
    if (location.startsWith('/expenses')) return 1;
    if (location.startsWith('/clients')) return 2;
    if (location.startsWith('/quotes')) return 3;
    if (location.startsWith('/invoices')) return 4;
    if (location.startsWith('/payments')) return 5;
    if (location.startsWith('/refunds')) return 6;
    if (location.startsWith('/articles')) return 7;
    return 0;
  }
}

class _ShellDestination {
  final String label;
  final IconData icon;

  const _ShellDestination(this.label, this.icon);
}

class _DesktopSidebar extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _DesktopSidebar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(appLocaleProvider);
    final items = [
      _ShellDestination(l10n.dashboard, Icons.dashboard_rounded),
      _ShellDestination(l10n.projects, Icons.folder_open_rounded),
      _ShellDestination(l10n.clients, Icons.people_rounded),
      _ShellDestination(l10n.quotes, Icons.request_quote_rounded),
      _ShellDestination(l10n.invoices, Icons.description_rounded),
      _ShellDestination(l10n.payments, Icons.payments_rounded),
      _ShellDestination(l10n.refunds, Icons.assignment_return_rounded),
      _ShellDestination(l10n.articles, Icons.inventory_2_rounded),
    ];

    return Container(
      width: 248,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/iconHissabDZ.jpg',
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.appTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: FilledButton.icon(
                onPressed: () => context.pushNamed('global_search'),
                icon: const Icon(Icons.search, size: 18),
                label: Text(l10n.globalSearch),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final selected = selectedIndex == index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: ListTile(
                      selected: selected,
                      selectedColor: AppTheme.primaryIndigo,
                      selectedTileColor: AppTheme.primaryIndigo.withValues(
                        alpha: 0.08,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      leading: Icon(item.icon),
                      title: Text(item.label),
                      onTap: () => onDestinationSelected(index),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text(l10n.expenses),
              onTap: () => context.goNamed('expenses'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(l10n.settings),
              onTap: () => context.pushNamed('settings'),
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
                    )['flag']
                    as String,
                style: const TextStyle(fontSize: 20),
              ),
              onTap: () =>
                  _showLanguageDialog(context, ref, l10n, currentLocale),
            ),
            const SizedBox(height: 8),
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
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
