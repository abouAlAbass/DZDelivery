import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hissab_dz/core/database/database.dart';
import 'package:hissab_dz/core/database/database_provider.dart';
import 'package:hissab_dz/features/purchases/domain/entities/purchase.dart';
import 'package:hissab_dz/features/stock/domain/entities/stock_movement_type.dart';

abstract class PurchaseRepository {
  Stream<List<Purchase>> watchPurchases();
  Future<Purchase?> getPurchaseById(int id);
  Future<int> addPurchase(Purchase purchase);
  Future<void> confirmPurchase(int purchaseId, {int? warehouseId});
  Future<void> validatePurchase(int purchaseId, {int? warehouseId});
  Future<void> deletePurchase(int id);
}

class PurchaseRepositoryImpl implements PurchaseRepository {
  final AppDatabase _db;

  PurchaseRepositoryImpl(this._db);

  @override
  Stream<List<Purchase>> watchPurchases() {
    final query = _db.select(_db.purchases)
      ..orderBy([(purchase) => OrderingTerm.desc(purchase.date)]);

    return query.watch().asyncMap((rows) async {
      final purchases = <Purchase>[];

      for (final purchase in rows) {
        final itemRows = await (_db.select(
          _db.purchaseItems,
        )..where((item) => item.purchaseId.equals(purchase.id))).get();

        purchases.add(
          Purchase(
            id: purchase.id,
            supplierId: purchase.supplierId,
            date: purchase.date,
            total: purchase.total,
            status: purchase.status,
            confirmedAt: purchase.confirmedAt,
            note: purchase.note,
            items: itemRows.map(_mapItem).toList(),
          ),
        );
      }

      return purchases;
    });
  }

  @override
  Future<Purchase?> getPurchaseById(int id) async {
    final purchase = await (_db.select(
      _db.purchases,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
    if (purchase == null) return null;

    final itemRows = await (_db.select(
      _db.purchaseItems,
    )..where((item) => item.purchaseId.equals(purchase.id))).get();

    return Purchase(
      id: purchase.id,
      supplierId: purchase.supplierId,
      date: purchase.date,
      total: purchase.total,
      status: purchase.status,
      confirmedAt: purchase.confirmedAt,
      note: purchase.note,
      items: itemRows.map(_mapItem).toList(),
    );
  }

  @override
  Future<int> addPurchase(Purchase purchase) {
    return _db.transaction(() async {
      for (final item in purchase.items) {
        if (item.quantity <= 0) {
          throw StateError('Purchase item quantity must be greater than zero');
        }
        if (item.purchasePrice < 0) {
          throw StateError('Purchase item price cannot be negative');
        }
      }

      final total = purchase.total == 0
          ? purchase.items.fold<double>(0, (sum, item) => sum + item.total)
          : purchase.total;

      final purchaseId = await _db
          .into(_db.purchases)
          .insert(
            PurchasesCompanion.insert(
              supplierId: Value(purchase.supplierId),
              date: purchase.date,
              total: Value(total),
              note: Value(purchase.note),
            ),
          );

      for (final item in purchase.items) {
        await _db
            .into(_db.purchaseItems)
            .insert(
              PurchaseItemsCompanion.insert(
                purchaseId: purchaseId,
                articleId: item.articleId,
                quantity: item.quantity,
                purchasePrice: Value(item.purchasePrice),
              ),
            );
      }

      return purchaseId;
    });
  }

  @override
  Future<void> validatePurchase(int purchaseId, {int? warehouseId}) {
    return confirmPurchase(purchaseId, warehouseId: warehouseId);
  }

  @override
  Future<void> confirmPurchase(int purchaseId, {int? warehouseId}) {
    return _db.transaction(() async {
      final purchase = await (_db.select(
        _db.purchases,
      )..where((row) => row.id.equals(purchaseId))).getSingle();

      if (purchase.status == 'confirmed') return;

      final destinationWarehouseId =
          warehouseId ?? await _getDefaultDepotWarehouseId();

      final existingMovements =
          await (_db.select(_db.stockMovements)..where(
                (movement) =>
                    movement.sourceType.equals(
                      StockMovementSourceTypes.purchase,
                    ) &
                    movement.sourceId.equals(purchaseId),
              ))
              .get();

      if (existingMovements.isNotEmpty) {
        await (_db.update(
          _db.purchases,
        )..where((row) => row.id.equals(purchaseId))).write(
          PurchasesCompanion(
            status: const Value('confirmed'),
            confirmedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
        return;
      }

      final items = await (_db.select(
        _db.purchaseItems,
      )..where((item) => item.purchaseId.equals(purchaseId))).get();

      for (final item in items) {
        if (!await _isStockTrackedArticle(item.articleId)) continue;

        await _db
            .into(_db.stockMovements)
            .insert(
              StockMovementsCompanion.insert(
                articleId: item.articleId,
                warehouseId: Value(destinationWarehouseId),
                type: StockMovementTypes.purchase,
                quantity: item.quantity,
                unitPrice: Value(item.purchasePrice),
                sourceType: const Value(StockMovementSourceTypes.purchase),
                sourceId: Value(purchaseId),
              ),
            );
      }

      await (_db.update(
        _db.purchases,
      )..where((row) => row.id.equals(purchaseId))).write(
        PurchasesCompanion(
          status: const Value('confirmed'),
          confirmedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  @override
  Future<void> deletePurchase(int id) {
    return (_db.delete(_db.purchases)..where((t) => t.id.equals(id))).go();
  }

  PurchaseItem _mapItem(PurchaseItemData data) {
    return PurchaseItem(
      id: data.id,
      purchaseId: data.purchaseId,
      articleId: data.articleId,
      quantity: data.quantity,
      purchasePrice: data.purchasePrice,
    );
  }

  Future<int> _getDefaultDepotWarehouseId() async {
    final depot =
        await (_db.select(_db.warehouses)
              ..where((warehouse) => warehouse.type.equals('depot'))
              ..limit(1))
            .getSingleOrNull();

    if (depot != null) return depot.id;

    return _db
        .into(_db.warehouses)
        .insert(
          WarehousesCompanion.insert(name: 'Depot principal', type: 'depot'),
        );
  }

  Future<bool> _isStockTrackedArticle(int articleId) async {
    final article = await (_db.select(
      _db.articles,
    )..where((row) => row.id.equals(articleId))).getSingleOrNull();

    if (article == null) return false;
    if (article.deletedAt != null || !article.isActive) return false;
    return article.type != 'service';
  }
}

final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PurchaseRepositoryImpl(db);
});
