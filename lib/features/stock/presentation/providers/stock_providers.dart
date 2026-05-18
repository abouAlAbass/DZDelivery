import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';
import 'package:hissab_dz/core/database/database.dart';
import 'package:hissab_dz/core/database/database_provider.dart';
import 'package:hissab_dz/features/stock/data/repositories/stock_repository.dart';
import 'package:hissab_dz/features/stock/data/repositories/stock_transfer_repository.dart';
import 'package:hissab_dz/features/stock/domain/entities/stock_overview.dart';
import 'package:hissab_dz/features/stock/domain/entities/stock_transfer.dart';

part 'stock_providers.g.dart';

@riverpod
Stream<List<ArticleStockOverview>> articleStockOverview(
  ArticleStockOverviewRef ref,
) {
  final repository = ref.watch(stockRepositoryProvider);
  return repository.getArticleStockOverview();
}

@riverpod
Stream<List<StockTransfer>> stockTransfersList(StockTransfersListRef ref) {
  final repository = ref.watch(stockTransferRepositoryProvider);
  return repository.watchTransfers();
}

@riverpod
Stream<List<WarehouseData>> depotWarehouses(DepotWarehousesRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(
    db.warehouses,
  )..where((warehouse) => warehouse.type.equals('depot'))).watch();
}

@riverpod
Stream<List<WarehouseData>> truckWarehouses(TruckWarehousesRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(
    db.warehouses,
  )..where((warehouse) => warehouse.type.equals('truck'))).watch();
}

@riverpod
Stream<Map<int, double>> warehouseArticleStock(
  WarehouseArticleStockRef ref,
  int warehouseId,
) {
  final db = ref.watch(appDatabaseProvider);
  return db
      .customSelect(
        '''
        SELECT article_id, COALESCE(SUM(quantity), 0) AS quantity
        FROM stock_movements
        WHERE warehouse_id = ?
          AND deleted_at IS NULL
        GROUP BY article_id
        ''',
        variables: [Variable.withInt(warehouseId)],
        readsFrom: {db.stockMovements},
      )
      .watch()
      .map(
        (rows) => {
          for (final row in rows)
            row.read<int>('article_id'): row.read<double>('quantity'),
        },
      );
}
