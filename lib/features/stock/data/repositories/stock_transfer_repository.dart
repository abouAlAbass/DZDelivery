import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hissab_dz/core/database/database.dart';
import 'package:hissab_dz/core/database/database_provider.dart';
import 'package:hissab_dz/features/stock/domain/entities/stock_movement_type.dart';
import 'package:hissab_dz/features/stock/domain/entities/stock_transfer.dart';

abstract class StockTransferRepository {
  Stream<List<StockTransfer>> watchTransfers();
  Future<StockTransfer?> getTransferById(int id);
  Future<int> addTransfer(StockTransfer transfer);
  Future<void> confirmStockTransfer(int transferId);
  Future<void> validateTransfer(int transferId);
  Future<void> deleteTransfer(int id);
}

class StockTransferRepositoryImpl implements StockTransferRepository {
  final AppDatabase _db;

  StockTransferRepositoryImpl(this._db);

  @override
  Stream<List<StockTransfer>> watchTransfers() {
    final query = _db.select(_db.stockTransfers)
      ..orderBy([(transfer) => OrderingTerm.desc(transfer.date)]);

    return query.watch().asyncMap((rows) async {
      final transfers = <StockTransfer>[];

      for (final transfer in rows) {
        final itemRows = await (_db.select(
          _db.stockTransferItems,
        )..where((item) => item.transferId.equals(transfer.id))).get();

        transfers.add(
          StockTransfer(
            id: transfer.id,
            fromWarehouseId: transfer.fromWarehouseId,
            toWarehouseId: transfer.toWarehouseId,
            date: transfer.date,
            status: transfer.status,
            confirmedAt: transfer.confirmedAt,
            note: transfer.note,
            routeId: transfer.routeId,
            items: itemRows.map(_mapItem).toList(),
          ),
        );
      }

      return transfers;
    });
  }

  @override
  Future<StockTransfer?> getTransferById(int id) async {
    final transfer = await (_db.select(
      _db.stockTransfers,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
    if (transfer == null) return null;

    final itemRows = await (_db.select(
      _db.stockTransferItems,
    )..where((item) => item.transferId.equals(transfer.id))).get();

    return StockTransfer(
      id: transfer.id,
      fromWarehouseId: transfer.fromWarehouseId,
      toWarehouseId: transfer.toWarehouseId,
      date: transfer.date,
      status: transfer.status,
      confirmedAt: transfer.confirmedAt,
      note: transfer.note,
      routeId: transfer.routeId,
      items: itemRows.map(_mapItem).toList(),
    );
  }

  @override
  Future<int> addTransfer(StockTransfer transfer) {
    return _db.transaction(() async {
      for (final item in transfer.items) {
        if (item.quantity <= 0) {
          throw StateError('Transfer item quantity must be greater than zero');
        }
      }

      final toWarehouse = await (_db.select(_db.warehouses)
            ..where((row) => row.id.equals(transfer.toWarehouseId)))
          .getSingleOrNull();

      if (toWarehouse != null && toWarehouse.type == 'truck') {
        final activeRoute = await (_db.select(_db.deliveryRoutes)
              ..where((row) => row.status.equals('open'))
              ..limit(1))
            .getSingleOrNull();

        if (activeRoute == null) {
          final hasAnyRoute = await (_db.select(_db.deliveryRoutes)..limit(1)).get();
          if (hasAnyRoute.isNotEmpty) {
            throw StateError('Un chargement de camion nécessite une tournée active.');
          }
        } else {
          if (activeRoute.warehouseId != transfer.toWarehouseId) {
            throw StateError('Le camion de destination du transfert doit correspondre à celui de la tournée active.');
          }
        }
      }

      if (transfer.routeId != null) {
        final route = await (_db.select(_db.deliveryRoutes)
              ..where((row) => row.id.equals(transfer.routeId!)))
            .getSingleOrNull();
        if (route != null && route.status == 'closed') {
          throw StateError('Impossible d\'associer un chargement à une tournée fermée.');
        }
      }

      final transferId = await _db
          .into(_db.stockTransfers)
          .insert(
            StockTransfersCompanion.insert(
              fromWarehouseId: transfer.fromWarehouseId,
              toWarehouseId: transfer.toWarehouseId,
              date: transfer.date,
              note: Value(transfer.note),
              routeId: Value(transfer.routeId),
            ),
          );

      for (final item in transfer.items) {
        await _db
            .into(_db.stockTransferItems)
            .insert(
              StockTransferItemsCompanion.insert(
                transferId: transferId,
                articleId: item.articleId,
                quantity: item.quantity,
              ),
            );
      }

      return transferId;
    });
  }

  @override
  Future<void> validateTransfer(int transferId) {
    return confirmStockTransfer(transferId);
  }

  @override
  Future<void> confirmStockTransfer(int transferId) {
    return _db.transaction(() async {
      final transfer = await (_db.select(
        _db.stockTransfers,
      )..where((row) => row.id.equals(transferId))).getSingle();

      if (transfer.status == 'confirmed') return;

      final existingMovements =
          await (_db.select(_db.stockMovements)..where(
                (movement) =>
                    movement.sourceType.equals(
                      StockMovementSourceTypes.stockTransfer,
                    ) &
                    movement.sourceId.equals(transferId),
              ))
              .get();

      if (existingMovements.isNotEmpty) {
        await _markConfirmed(transferId);
        return;
      }

      final items = await (_db.select(
        _db.stockTransferItems,
      )..where((item) => item.transferId.equals(transferId))).get();

      final requestedByArticle = <int, double>{};
      for (final item in items) {
        if (!await _isStockTrackedArticle(item.articleId)) continue;

        requestedByArticle[item.articleId] =
            (requestedByArticle[item.articleId] ?? 0) + item.quantity;
      }

      for (final entry in requestedByArticle.entries) {
        final available = await _getAvailableStock(
          articleId: entry.key,
          warehouseId: transfer.fromWarehouseId,
        );
        if (entry.value > available) {
          throw StateError(
            'Insufficient stock for article ${entry.key}: requested ${entry.value}, available $available',
          );
        }
      }

      for (final item in items) {
        if (!await _isStockTrackedArticle(item.articleId)) continue;

        await _insertTransferMovement(
          articleId: item.articleId,
          warehouseId: transfer.fromWarehouseId,
          type: StockMovementTypes.transferOut,
          quantity: -item.quantity,
          transferId: transferId,
        );
        await _insertTransferMovement(
          articleId: item.articleId,
          warehouseId: transfer.toWarehouseId,
          type: StockMovementTypes.transferIn,
          quantity: item.quantity,
          transferId: transferId,
        );
      }

      await _markConfirmed(transferId);
    });
  }

  @override
  Future<void> deleteTransfer(int id) {
    return (_db.delete(_db.stockTransfers)..where((t) => t.id.equals(id))).go();
  }

  Future<void> _insertTransferMovement({
    required int articleId,
    required int warehouseId,
    required String type,
    required double quantity,
    required int transferId,
  }) {
    return _db
        .into(_db.stockMovements)
        .insert(
          StockMovementsCompanion.insert(
            articleId: articleId,
            warehouseId: Value(warehouseId),
            type: type,
            quantity: quantity,
            sourceType: const Value(StockMovementSourceTypes.stockTransfer),
            sourceId: Value(transferId),
          ),
        );
  }

  Future<double> _getAvailableStock({
    required int articleId,
    required int warehouseId,
  }) async {
    final rows = await _db
        .customSelect(
          '''
      SELECT COALESCE(SUM(quantity), 0) AS quantity
      FROM stock_movements
      WHERE article_id = ?
        AND warehouse_id = ?
        AND deleted_at IS NULL
      ''',
          variables: [
            Variable.withInt(articleId),
            Variable.withInt(warehouseId),
          ],
          readsFrom: {_db.stockMovements},
        )
        .get();

    return rows.single.read<double>('quantity');
  }

  Future<bool> _isStockTrackedArticle(int articleId) async {
    final article = await (_db.select(
      _db.articles,
    )..where((row) => row.id.equals(articleId))).getSingleOrNull();

    if (article == null) return false;
    if (article.deletedAt != null || !article.isActive) return false;
    return article.type != 'service';
  }

  Future<void> _markConfirmed(int transferId) {
    return (_db.update(
      _db.stockTransfers,
    )..where((row) => row.id.equals(transferId))).write(
      StockTransfersCompanion(
        status: const Value('confirmed'),
        confirmedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  StockTransferItem _mapItem(StockTransferItemData data) {
    return StockTransferItem(
      id: data.id,
      transferId: data.transferId,
      articleId: data.articleId,
      quantity: data.quantity,
    );
  }
}

final stockTransferRepositoryProvider = Provider<StockTransferRepository>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  return StockTransferRepositoryImpl(db);
});
