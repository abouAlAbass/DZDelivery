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
import '../../features/articles/presentation/pages/article_details_screen.dart';
import '../../features/articles/presentation/pages/add_edit_article_screen.dart';
import '../../features/pos/presentation/pages/pos_home_screen.dart';
import '../../features/pos/presentation/pages/delivery_route_screen.dart';
import '../../features/purchases/presentation/pages/create_purchase_screen.dart';
import '../../features/purchases/presentation/pages/purchase_detail_screen.dart';
import '../../features/purchases/presentation/pages/purchase_list_screen.dart';
import '../../features/sales/presentation/pages/daily_pos_report_screen.dart';
import '../../features/sales/presentation/pages/quick_sale_screen.dart';
import '../../features/sales/presentation/pages/sale_detail_screen.dart';
import '../../features/sales/presentation/pages/sale_list_screen.dart';
import '../../features/sales/presentation/pages/sale_return_screen.dart';
import '../../features/stock/presentation/pages/stock_overview_screen.dart';
import '../../features/stock/presentation/pages/stock_transfer_detail_screen.dart';
import '../../features/stock/presentation/pages/stock_transfer_form_screen.dart';
import '../../features/stock/presentation/pages/stock_transfer_list_screen.dart';
import '../../features/suppliers/presentation/pages/supplier_list_screen.dart';
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
            path: '/pos',
            name: 'pos_home',
            builder: (context, state) => const PosHomeScreen(),
          ),
          GoRoute(
            path: '/purchases',
            name: 'purchases',
            builder: (context, state) => const PurchaseListScreen(),
          ),
          GoRoute(
            path: '/suppliers',
            name: 'suppliers',
            builder: (context, state) => const SupplierListScreen(),
          ),
          GoRoute(
            path: '/pos/stock',
            name: 'stock_overview',
            builder: (context, state) => const StockOverviewScreen(),
          ),
          GoRoute(
            path: '/pos/sales',
            name: 'sales',
            builder: (context, state) => const SaleListScreen(),
          ),
          GoRoute(
            path: '/pos/quick-sale',
            name: 'quick_sale',
            builder: (context, state) => const QuickSaleScreen(),
          ),
          GoRoute(
            path: '/pos/truck-loading',
            name: 'stock_transfers',
            builder: (context, state) => const StockTransferListScreen(),
          ),
          GoRoute(
            path: '/pos/daily-report',
            name: 'daily_pos_report',
            builder: (context, state) => const DailyPosReportScreen(),
          ),
          GoRoute(
            path: '/pos/delivery-route',
            name: 'delivery_route',
            builder: (context, state) => const DeliveryRouteScreen(),
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
        path: '/articles/:id',
        name: 'article_details',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final idString = state.pathParameters['id'];
          final id = int.tryParse(idString ?? '') ?? 0;
          return ArticleDetailsScreen(articleId: id);
        },
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
      GoRoute(
        path: '/purchases/create',
        name: 'create_purchase',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CreatePurchaseScreen(),
      ),
      GoRoute(
        path: '/purchases/:id',
        name: 'purchase_details',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final idString = state.pathParameters['id'];
          final id = int.tryParse(idString ?? '') ?? 0;
          return PurchaseDetailScreen(purchaseId: id);
        },
      ),
      GoRoute(
        path: '/pos/sales/:id',
        name: 'sale_details',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final idString = state.pathParameters['id'];
          final id = int.tryParse(idString ?? '') ?? 0;
          return SaleDetailScreen(saleId: id);
        },
      ),
      GoRoute(
        path: '/pos/sales/:id/return',
        name: 'sale_return',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final idString = state.pathParameters['id'];
          final id = int.tryParse(idString ?? '') ?? 0;
          return SaleReturnScreen(saleId: id);
        },
      ),
      GoRoute(
        path: '/pos/truck-loading/create',
        name: 'create_stock_transfer',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const StockTransferFormScreen(),
      ),
      GoRoute(
        path: '/pos/truck-loading/:id',
        name: 'stock_transfer_details',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final idString = state.pathParameters['id'];
          final id = int.tryParse(idString ?? '') ?? 0;
          return StockTransferDetailScreen(transferId: id);
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
            _DesktopSidebar(
              selectedIndex: selectedIndex,
              width: 220,
              onDestinationSelected: (index) => _goToIndex(context, index),
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
              context.goNamed('delivery_route');
              break;
            case 1:
              context.goNamed('quick_sale');
              break;
            case 2:
              context.goNamed('stock_transfers');
              break;
            case 3:
              context.goNamed('stock_overview');
              break;
            case 4:
              context.goNamed('sales');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.route_rounded),
            label: l10n.localeName == 'ar' ? 'الجولة' : 'Tournée',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.point_of_sale_rounded),
            label: l10n.quickSale,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.local_shipping_rounded),
            label: l10n.truckLoading,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.warehouse_rounded),
            label: l10n.stockPos,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_rounded),
            label: l10n.sales,
          ),
        ],
      ),
    );
  }

  void _goToIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.goNamed('dashboard');
        break;
      case 1:
        context.goNamed('pos_home');
        break;
      case 2:
        context.goNamed('quick_sale');
        break;
      case 3:
        context.goNamed('sales');
        break;
      case 4:
        context.goNamed('daily_pos_report');
        break;
      case 5:
        context.goNamed('stock_overview');
        break;
      case 6:
        context.goNamed('purchases');
        break;
      case 7:
        context.goNamed('stock_transfers');
        break;
      case 8:
        context.goNamed('articles');
        break;
      case 9:
        context.goNamed('suppliers');
        break;
      case 10:
        context.goNamed('clients');
        break;
      case 11:
        context.goNamed('quotes');
        break;
      case 12:
        context.goNamed('invoices');
        break;
      case 13:
        context.goNamed('payments');
        break;
      case 14:
        context.goNamed('refunds');
        break;
      case 15:
        context.goNamed('projects');
        break;
      case 16:
        context.goNamed('expenses');
        break;
      case 17:
        context.goNamed('delivery_route');
        break;
    }
  }

  int _mobileSelectedIndex(String location) {
    if (location.startsWith('/pos/delivery-route') || location == '/pos') {
      return 0;
    }
    if (location.startsWith('/pos/quick-sale')) return 1;
    if (location.startsWith('/pos/truck-loading')) return 2;
    if (location.startsWith('/pos/stock')) return 3;
    if (location.startsWith('/pos/sales')) return 4;
    return 0;
  }

  int _calculateSelectedIndex(String location) {
    if (location == '/') return 0;
    if (location == '/pos') return 1;
    if (location.startsWith('/pos/delivery-route')) return 17;
    if (location.startsWith('/pos/quick-sale')) return 2;
    if (location.startsWith('/pos/sales')) return 3;
    if (location.startsWith('/pos/daily-report')) return 4;
    if (location.startsWith('/pos/stock')) return 5;
    if (location.startsWith('/purchases')) return 6;
    if (location.startsWith('/pos/truck-loading')) return 7;
    if (location.startsWith('/articles')) return 8;
    if (location.startsWith('/suppliers')) return 9;
    if (location.startsWith('/clients')) return 10;
    if (location.startsWith('/quotes')) return 11;
    if (location.startsWith('/invoices')) return 12;
    if (location.startsWith('/payments')) return 13;
    if (location.startsWith('/refunds')) return 14;
    if (location.startsWith('/projects')) return 15;
    if (location.startsWith('/expenses')) return 16;
    return 0;
  }
}

class _DesktopSidebar extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final double width;

  const _DesktopSidebar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.width = 248,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(appLocaleProvider);
    final groups = [
      _SidebarGroup(l10n.principal, Icons.dashboard_rounded, [
        _SidebarDestination(0, l10n.dashboard, Icons.dashboard_rounded),
      ]),
      _SidebarGroup(l10n.posVente, Icons.point_of_sale_rounded, [
        _SidebarDestination(1, l10n.posHome, Icons.home_rounded),
        _SidebarDestination(
          17,
          l10n.deliveryRoute,
          Icons.local_shipping_rounded,
        ),
        _SidebarDestination(2, l10n.quickSale, Icons.point_of_sale_rounded),
        _SidebarDestination(3, l10n.sales, Icons.receipt_long_rounded),
        _SidebarDestination(4, l10n.dailyReportMenu, Icons.bar_chart_rounded),
      ]),
      _SidebarGroup(l10n.stockAchats, Icons.inventory_2_rounded, [
        _SidebarDestination(5, l10n.stockPos, Icons.warehouse_rounded),
        _SidebarDestination(6, l10n.purchases, Icons.add_shopping_cart_rounded),
        _SidebarDestination(7, l10n.truckLoading, Icons.local_shipping_rounded),
        _SidebarDestination(8, l10n.articles, Icons.inventory_2_rounded),
        _SidebarDestination(9, l10n.suppliers, Icons.store_rounded),
      ]),
      _SidebarGroup(l10n.clientsDocuments, Icons.people_rounded, [
        _SidebarDestination(10, l10n.clients, Icons.people_rounded),
        _SidebarDestination(11, l10n.quotes, Icons.request_quote_rounded),
        _SidebarDestination(12, l10n.invoices, Icons.description_rounded),
        _SidebarDestination(13, l10n.payments, Icons.payments_rounded),
        _SidebarDestination(14, l10n.refunds, Icons.assignment_return_rounded),
      ]),
      _SidebarGroup(l10n.expenses, Icons.receipt_long_rounded, [
        _SidebarDestination(16, l10n.expenses, Icons.receipt_long_rounded),
      ]),
    ];

    return Container(
      width: width,
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
                      'assets/images/logo.png',
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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  for (final group in groups)
                    _SidebarExpansionGroup(
                      group: group,
                      selectedIndex: selectedIndex,
                      onDestinationSelected: onDestinationSelected,
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
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
                    )['native']
                    as String,
                style: const TextStyle(fontWeight: FontWeight.w700),
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

class _SidebarGroup {
  final String label;
  final IconData icon;
  final List<_SidebarDestination> items;

  const _SidebarGroup(this.label, this.icon, this.items);
}

class _SidebarDestination {
  final int index;
  final String label;
  final IconData icon;

  const _SidebarDestination(this.index, this.label, this.icon);
}

class _SidebarExpansionGroup extends StatelessWidget {
  final _SidebarGroup group;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _SidebarExpansionGroup({
    required this.group,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelectedItem = group.items.any(
      (item) => item.index == selectedIndex,
    );
    return ExpansionTile(
      initiallyExpanded: hasSelectedItem,
      leading: Icon(group.icon),
      title: Text(
        group.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: hasSelectedItem ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
      tilePadding: const EdgeInsets.symmetric(horizontal: 12),
      childrenPadding: const EdgeInsets.only(left: 8, right: 4, bottom: 4),
      children: [
        for (final item in group.items)
          _SidebarTile(
            item: item,
            selected: selectedIndex == item.index,
            onTap: () => onDestinationSelected(item.index),
          ),
      ],
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final _SidebarDestination item;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        dense: true,
        selected: selected,
        selectedColor: AppTheme.primaryIndigo,
        selectedTileColor: AppTheme.primaryIndigo.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Icon(item.icon),
        title: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis),
        onTap: onTap,
      ),
    );
  }
}
