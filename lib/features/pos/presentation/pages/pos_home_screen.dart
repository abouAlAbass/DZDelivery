import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hissab_dz/core/theme/theme.dart';
import 'package:hissab_dz/core/widgets/app_drawer.dart';
import 'package:hissab_dz/core/widgets/responsive_content.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';
import 'package:hissab_dz/features/pos/presentation/providers/delivery_route_providers.dart';

class PosHomeScreen extends ConsumerWidget {
  const PosHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final activeRouteAsync = ref.watch(activeDeliveryRouteProvider);
    final activeRoute = activeRouteAsync.value;
    final isAr = l10n.localeName == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.posVente)),
      drawer: MediaQuery.sizeOf(context).width >= 1100 ? null : const AppDrawer(),
      body: ResponsiveContent(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.bottomNavClearance,
          ),
          children: [
            // Active Run Status Banner
            activeRouteAsync.when(
              loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const SizedBox.shrink(),
              data: (route) {
                if (route == null) {
                  return Card(
                    color: Colors.orange.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      side: const BorderSide(color: Colors.orange, width: 0.5),
                    ),
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 40),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr ? 'لم يتم بدء أي جولة اليوم' : 'Aucune tournée démarrée',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  isAr 
                                      ? 'يرجى بدء جولة توزيع لتمكين مبيعات الشاحنة.'
                                      : 'Veuillez démarrer une tournée pour débloquer les ventes du camion.',
                                  style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                            onPressed: () => context.go('/pos/delivery-route'),
                            child: Text(isAr ? 'بدء الجولة' : 'Démarrer'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Card(
                  color: Colors.green.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    side: const BorderSide(color: Colors.green, width: 0.5),
                  ),
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green, size: 40),
                    title: Text(
                      isAr ? 'جولة توزيع نشطة' : 'Tournée active',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    subtitle: Text(
                      isAr 
                          ? 'السائق: ${route.driverName ?? "الموزع"} | عداد الكيلومترات: ${route.startKm ?? "-"}'
                          : 'Chauffeur : ${route.driverName ?? "Livreur"} | KM départ : ${route.startKm ?? "-"}',
                      style: TextStyle(fontSize: 12, color: Colors.green.shade800),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.green.shade700, size: 16),
                    onTap: () => context.go('/pos/delivery-route'),
                  ),
                );
              },
            ),

            // Tiles Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 3 : 2,
              childAspectRatio: 1.25,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              children: [
                _Tile(
                  isAr ? 'جولة اليوم' : 'Tournée du jour',
                  Icons.local_shipping,
                  () => context.go('/pos/delivery-route'),
                  badge: activeRoute != null ? (isAr ? 'نشطة' : 'Active') : null,
                  badgeColor: activeRoute != null ? Colors.green : null,
                ),
                _Tile(
                  l10n.quickSale,
                  Icons.point_of_sale,
                  activeRoute == null
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isAr ? 'يرجى بدء الجولة أولاً!' : 'Veuillez démarrer la tournée d\'abord !'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          context.go('/pos/delivery-route');
                        }
                      : () => context.go('/pos/quick-sale'),
                  disabled: activeRoute == null,
                ),
                _Tile(l10n.sales, Icons.receipt_long, () => context.go('/pos/sales')),
                _Tile(l10n.stock, Icons.warehouse, () => context.go('/pos/stock')),
                _Tile(
                  l10n.purchases,
                  Icons.add_shopping_cart,
                  () => context.go('/purchases'),
                ),
                _Tile(
                  l10n.truckLoading,
                  Icons.local_shipping_outlined,
                  activeRoute == null
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isAr ? 'يرجى بدء الجولة أولاً!' : 'Veuillez démarrer la tournée d\'abord !'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          context.go('/pos/delivery-route');
                        }
                      : () => context.go('/pos/truck-loading'),
                  disabled: activeRoute == null,
                ),
                _Tile(
                  isAr ? 'تقرير ومراقبة الجولة' : 'Rapport de Tournée',
                  Icons.bar_chart,
                  () => context.go('/pos/delivery-route'),
                ),
                _Tile(l10n.suppliers, Icons.store, () => context.go('/suppliers')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? badge;
  final Color? badgeColor;
  final bool disabled;

  const _Tile(
    this.label,
    this.icon,
    this.onTap, {
    this.badge,
    this.badgeColor,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: disabled ? 1 : 2,
      color: disabled ? Theme.of(context).cardColor.withValues(alpha: 0.6) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: disabled ? 0.4 : 1.0,
                    child: Icon(icon, size: 34, color: disabled ? Colors.grey : AppTheme.primaryIndigo),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: disabled ? FontWeight.normal : FontWeight.bold,
                      color: disabled ? Colors.grey : null,
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor ?? AppTheme.primaryIndigo,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
