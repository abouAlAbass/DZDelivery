import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hissab_dz/core/database/database.dart';
import 'package:hissab_dz/core/database/database_provider.dart';
import 'package:hissab_dz/features/sales/domain/entities/sale.dart';

abstract class DeliveryRouteRepository {
  Stream<List<DeliveryRouteData>> watchRoutes();
  Stream<DeliveryRouteData?> watchActiveRoute();
  Future<DeliveryRouteData?> getActiveRoute();
  Future<DeliveryRouteData?> getRouteById(int id);
  Future<int> startRoute({
    required int warehouseId,
    int? depotWarehouseId,
    int? truckWarehouseId,
    String? routeNumber,
    String? driverName,
    double? startKm,
    double? startCash,
    String? note,
    String status = 'open',
  });
  Future<void> closeRoute({
    required int routeId,
    double? endKm,
    double? endCash,
    String? note,
  });
  Future<PosDailyReport> getRouteReport(int routeId);
}

class DeliveryRouteRepositoryImpl implements DeliveryRouteRepository {
  final AppDatabase _db;

  DeliveryRouteRepositoryImpl(this._db);

  @override
  Stream<List<DeliveryRouteData>> watchRoutes() {
    final query = _db.select(_db.deliveryRoutes)
      ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]);
    return query.watch();
  }

  @override
  Stream<DeliveryRouteData?> watchActiveRoute() {
    final query = _db.select(_db.deliveryRoutes)
      ..where((row) => row.status.equals('open'))
      ..limit(1);
    return query.watchSingleOrNull();
  }

  @override
  Future<DeliveryRouteData?> getActiveRoute() async {
    final query = _db.select(_db.deliveryRoutes)
      ..where((row) => row.status.equals('open'))
      ..limit(1);
    return query.getSingleOrNull();
  }

  @override
  Future<DeliveryRouteData?> getRouteById(int id) async {
    final query = _db.select(_db.deliveryRoutes)
      ..where((row) => row.id.equals(id));
    return query.getSingleOrNull();
  }

  @override
  Future<int> startRoute({
    required int warehouseId,
    int? depotWarehouseId,
    int? truckWarehouseId,
    String? routeNumber,
    String? driverName,
    double? startKm,
    double? startCash,
    String? note,
    String status = 'open',
  }) async {
    return _db.transaction(() async {
      final targetTruck = truckWarehouseId ?? warehouseId;

      // Guard: Une tournée ouverte par camion maximum
      final existingOpenRoute = await (_db.select(_db.deliveryRoutes)
            ..where((row) =>
                row.status.equals('open') &
                (row.warehouseId.equals(targetTruck) | row.truckWarehouseId.equals(targetTruck))))
          .getSingleOrNull();
      if (existingOpenRoute != null) {
        throw StateError('Une tournée est déjà ouverte pour ce camion.');
      }

      final now = DateTime.now();
      final year = now.year;
      final query = _db.select(_db.deliveryRoutes)
        ..where((row) => row.date.year.equals(year));
      final count = (await query.get()).length + 1;
      final generatedNumber = routeNumber ?? 'T-$year-${count.toString().padLeft(4, '0')}';

      return _db.into(_db.deliveryRoutes).insert(
            DeliveryRoutesCompanion.insert(
              warehouseId: targetTruck,
              depotWarehouseId: Value(depotWarehouseId),
              truckWarehouseId: Value(targetTruck),
              routeNumber: Value(generatedNumber),
              date: now,
              driverName: Value(driverName),
              status: Value(status),
              startKm: Value(startKm),
              startCash: Value(startCash ?? 0.0),
              note: Value(note),
              createdAt: Value(now),
              openedAt: Value(now),
            ),
          );
    });
  }

  @override
  Future<void> closeRoute({
    required int routeId,
    double? endKm,
    double? endCash,
    String? note,
  }) async {
    return _db.transaction(() async {
      final route = await getRouteById(routeId);
      if (route == null) {
        throw StateError('Route with ID $routeId not found.');
      }
      if (route.status == 'closed') {
        return; // Already closed
      }

      await (_db.update(_db.deliveryRoutes)
            ..where((row) => row.id.equals(routeId)))
          .write(
        DeliveryRoutesCompanion(
          status: const Value('closed'),
          endKm: Value(endKm),
          endCash: Value(endCash),
          note: Value(note),
          closedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  @override
  Future<PosDailyReport> getRouteReport(int routeId) async {
    final route = await getRouteById(routeId);
    if (route == null) {
      throw StateError('Route with ID $routeId not found.');
    }

    final warehouse = await (_db.select(_db.warehouses)
          ..where((row) => row.id.equals(route.warehouseId)))
        .getSingleOrNull();

    final warehouseName = warehouse?.name ?? 'Camion inconnu';

    // 1. Validated Sales
    final sales = await (_db.select(_db.sales)
          ..where((sale) =>
              sale.routeId.equals(routeId) & sale.status.equals('validated')))
        .get();

    // 2. Quantities loaded
    final loadedQuantity = await _readDouble(
      '''
      SELECT COALESCE(SUM(sti.quantity), 0) AS value
      FROM stock_transfer_items sti
      INNER JOIN stock_transfers st ON st.id = sti.transfer_id
      WHERE st.route_id = ?
        AND st.status = 'confirmed'
        AND st.deleted_at IS NULL
        AND sti.deleted_at IS NULL
      ''',
      [Variable.withInt(routeId)],
    );

    // 3. Quantities sold
    final soldQuantity = await _readDouble(
      '''
      SELECT COALESCE(SUM(si.quantity), 0) AS value
      FROM sale_items si
      INNER JOIN sales s ON s.id = si.sale_id
      WHERE s.route_id = ?
        AND s.status = 'validated'
        AND s.deleted_at IS NULL
        AND si.deleted_at IS NULL
      ''',
      [Variable.withInt(routeId)],
    );

    // 4. Returns Total
    final returnsTotal = await _readDouble(
      '''
      SELECT COALESCE(SUM(total), 0) AS value
      FROM sale_returns
      WHERE route_id = ?
        AND status = 'confirmed'
        AND deleted_at IS NULL
      ''',
      [Variable.withInt(routeId)],
    );

    // 5. Cash Total
    final cashTotal = await _readDouble(
      '''
      SELECT COALESCE(SUM(sp.amount), 0) AS value
      FROM sale_payments sp
      INNER JOIN sales s ON s.id = sp.sale_id
      WHERE sp.route_id = ?
        AND sp.deleted_at IS NULL
        AND s.deleted_at IS NULL
      ''',
      [Variable.withInt(routeId)],
    );

    // 6. Truck stock return (total stock in the truck)
    final truckReturnQuantity = await _readDouble(
      '''
      SELECT COALESCE(SUM(quantity), 0) AS value
      FROM stock_movements
      WHERE warehouse_id = ?
        AND deleted_at IS NULL
      ''',
      [Variable.withInt(route.warehouseId)],
    );

    final truckRows = await _db
        .customSelect(
          '''
          SELECT article_id, COALESCE(SUM(quantity), 0) AS quantity
          FROM stock_movements
          WHERE warehouse_id = ?
            AND deleted_at IS NULL
          GROUP BY article_id
          ''',
          variables: [Variable.withInt(route.warehouseId)],
          readsFrom: {_db.stockMovements},
        )
        .get();

    final salesTotal = sales.fold(0.0, (sum, sale) => sum + sale.total);
    final creditTotal = sales.fold(
      0.0,
      (sum, sale) => sum + (sale.total - sale.paidAmount).clamp(0, double.infinity),
    );

    return PosDailyReport(
      date: route.date,
      warehouseId: route.warehouseId,
      warehouseName: warehouseName,
      saleCount: sales.length,
      loadedQuantity: loadedQuantity,
      soldQuantity: soldQuantity,
      truckReturnQuantity: truckReturnQuantity,
      salesTotal: salesTotal,
      cashTotal: cashTotal,
      creditTotal: creditTotal,
      returnsTotal: returnsTotal,
      unpaidTotal: sales
          .where((sale) => sale.paymentStatus == 'unpaid')
          .fold(0.0, (sum, sale) => sum + sale.total),
      partialTotal: sales
          .where((sale) => sale.paymentStatus == 'partial')
          .fold(0.0, (sum, sale) => sum + (sale.total - sale.paidAmount)),
      truckStock: {
        for (final row in truckRows)
          row.read<int>('article_id'): (row.data['quantity'] as num).toDouble(),
      },
    );
  }

  Future<double> _readDouble(String sql, List<Variable> variables) async {
    final rows = await _db.customSelect(sql, variables: variables).get();
    if (rows.isEmpty || rows.first.data['value'] == null) return 0.0;
    return (rows.first.data['value'] as num).toDouble();
  }
}

final deliveryRouteRepositoryProvider = Provider<DeliveryRouteRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DeliveryRouteRepositoryImpl(db);
});
