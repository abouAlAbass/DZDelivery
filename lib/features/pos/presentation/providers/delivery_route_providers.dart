import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hissab_dz/core/database/database.dart';
import 'package:hissab_dz/features/pos/data/repositories/delivery_route_repository.dart';
import 'package:hissab_dz/features/sales/domain/entities/sale.dart';

final activeDeliveryRouteProvider = StreamProvider.autoDispose<DeliveryRouteData?>((ref) {
  return ref.watch(deliveryRouteRepositoryProvider).watchActiveRoute();
});

final deliveryRouteHistoryProvider = StreamProvider.autoDispose<List<DeliveryRouteData>>((ref) {
  return ref.watch(deliveryRouteRepositoryProvider).watchRoutes();
});

final deliveryRouteReportProvider = FutureProvider.autoDispose.family<PosDailyReport, int>((ref, routeId) {
  return ref.watch(deliveryRouteRepositoryProvider).getRouteReport(routeId);
});
