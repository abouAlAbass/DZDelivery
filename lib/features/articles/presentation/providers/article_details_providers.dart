import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hissab_dz/core/database/database.dart';
import 'package:hissab_dz/core/database/database_provider.dart';
import 'package:hissab_dz/features/articles/domain/entities/article.dart';

import 'package:drift/drift.dart';
import 'article_providers.dart';

part 'article_details_providers.g.dart';

@riverpod
class ArticleDetailsDateFilter extends _$ArticleDetailsDateFilter {
  @override
  DateTimeRange? build() => null;
  
  void setFilter(DateTimeRange? range) => state = range;
}

class EnrichedSaleItem {
  final SaleItemData item;
  final SaleData sale;
  final ClientData? client;
  
  const EnrichedSaleItem({
    required this.item,
    required this.sale,
    this.client,
  });
}

class EnrichedPurchaseItem {
  final PurchaseItemData item;
  final PurchaseData purchase;
  final SupplierData? supplier;
  
  const EnrichedPurchaseItem({
    required this.item,
    required this.purchase,
    this.supplier,
  });
}

@riverpod
Future<Article?> articleDetails(ArticleDetailsRef ref, int articleId) async {
  final db = ref.watch(appDatabaseProvider);
  final data = await (db.select(db.articles)..where((a) => a.id.equals(articleId))).getSingleOrNull();
  if (data == null) return null;
  return Article(
    id: data.id,
    name: data.name,
    code: data.code,
    barcode: data.barcode,
    price: data.price,
    salePrice: data.salePrice,
    purchasePrice: data.purchasePrice,
    minStock: data.minStock,
    isActive: data.isActive,
    unit: data.unit,
    type: data.type,
    category: data.category,
    taxRate: data.taxRate,
    marginRate: data.marginRate,
    quickTemplate: data.quickTemplate,
    defaultQuantity: data.defaultQuantity,
    quickTemplateOrder: data.quickTemplateOrder,
    createdAt: data.createdAt,
    updatedAt: data.updatedAt,
    deletedAt: data.deletedAt,
  );
}

@riverpod
Stream<List<EnrichedSaleItem>> articleSalesFiltered(ArticleSalesFilteredRef ref, int articleId) {
  final db = ref.watch(appDatabaseProvider);
  final dateFilter = ref.watch(articleDetailsDateFilterProvider);
  
  final query = db.select(db.saleItems).join([
    innerJoin(db.sales, db.sales.id.equalsExp(db.saleItems.saleId)),
    leftOuterJoin(db.clients, db.clients.id.equalsExp(db.sales.clientId)),
  ])
  ..where(db.saleItems.articleId.equals(articleId))
  ..orderBy([OrderingTerm.desc(db.sales.date)]);
  
  if (dateFilter != null) {
    query.where(
      db.sales.date.isBetweenValues(dateFilter.start, dateFilter.end),
    );
  }
  
  return query.watch().map((rows) {
    return rows.map((row) {
      return EnrichedSaleItem(
        item: row.readTable(db.saleItems),
        sale: row.readTable(db.sales),
        client: row.readTableOrNull(db.clients),
      );
    }).toList();
  });
}

@riverpod
Stream<List<EnrichedPurchaseItem>> articlePurchasesFiltered(ArticlePurchasesFilteredRef ref, int articleId) {
  final db = ref.watch(appDatabaseProvider);
  final dateFilter = ref.watch(articleDetailsDateFilterProvider);
  
  final query = db.select(db.purchaseItems).join([
    innerJoin(db.purchases, db.purchases.id.equalsExp(db.purchaseItems.purchaseId)),
    leftOuterJoin(db.suppliers, db.suppliers.id.equalsExp(db.purchases.supplierId)),
  ])
  ..where(db.purchaseItems.articleId.equals(articleId))
  ..orderBy([OrderingTerm.desc(db.purchases.date)]);
  
  if (dateFilter != null) {
    query.where(
      db.purchases.date.isBetweenValues(dateFilter.start, dateFilter.end),
    );
  }
  
  return query.watch().map((rows) {
    return rows.map((row) {
      return EnrichedPurchaseItem(
        item: row.readTable(db.purchaseItems),
        purchase: row.readTable(db.purchases),
        supplier: row.readTableOrNull(db.suppliers),
      );
    }).toList();
  });
}

@riverpod
Stream<List<EnrichedStockMovement>> articleStockMovementsFiltered(
  ArticleStockMovementsFilteredRef ref,
  int articleId,
) {
  final db = ref.watch(appDatabaseProvider);
  final dateFilter = ref.watch(articleDetailsDateFilterProvider);

  final query = db.select(db.stockMovements)
    ..where((movement) => movement.articleId.equals(articleId))
    ..orderBy([(movement) => OrderingTerm.desc(movement.createdAt)]);

  if (dateFilter != null) {
    query.where(
      (movement) => movement.createdAt.isBetweenValues(dateFilter.start, dateFilter.end),
    );
  }

  return query.watch().asyncMap((movements) async {
    final warehouses = await db.select(db.warehouses).get();
    final warehousesById = {for (final w in warehouses) w.id: w};

    final enriched = <EnrichedStockMovement>[];
    for (final movement in movements) {
      String? sourceName;
      if (movement.sourceType == 'purchase' && movement.sourceId != null) {
        final purchase = await (db.select(db.purchases)
              ..where((p) => p.id.equals(movement.sourceId!)))
            .getSingleOrNull();
        if (purchase?.supplierId != null) {
          final supplier = await (db.select(db.suppliers)
                ..where((s) => s.id.equals(purchase!.supplierId!)))
              .getSingleOrNull();
          if (supplier != null) {
            sourceName = 'Fournisseur: ${supplier.name}';
          }
        }
      } else if (movement.sourceType == 'sale' && movement.sourceId != null) {
        final sale = await (db.select(db.sales)
              ..where((s) => s.id.equals(movement.sourceId!)))
            .getSingleOrNull();
        if (sale?.clientId != null) {
          final client = await (db.select(db.clients)
                ..where((c) => c.id.equals(sale!.clientId!)))
              .getSingleOrNull();
          if (client != null) {
            sourceName = 'Client: ${client.name}';
          }
        }
      } else if (movement.sourceType == 'sale_return' &&
          movement.sourceId != null) {
        final saleReturn = await (db.select(db.saleReturns)
              ..where((s) => s.id.equals(movement.sourceId!)))
            .getSingleOrNull();
        if (saleReturn?.clientId != null) {
          final client = await (db.select(db.clients)
                ..where((c) => c.id.equals(saleReturn!.clientId!)))
              .getSingleOrNull();
          if (client != null) {
            sourceName = 'Retour client: ${client.name}';
          }
        }
      } else if (movement.sourceType == 'stock_transfer' &&
          movement.sourceId != null) {
        final transfer = await (db.select(db.stockTransfers)
              ..where((t) => t.id.equals(movement.sourceId!)))
            .getSingleOrNull();
        if (transfer != null) {
          final fromW = warehousesById[transfer.fromWarehouseId];
          final toW = warehousesById[transfer.toWarehouseId];
          if (fromW != null && toW != null) {
            sourceName = 'Transfert: ${fromW.name} ➔ ${toW.name}';
          }
        }
      }

      enriched.add(
        EnrichedStockMovement(
          movement: movement,
          warehouse: movement.warehouseId != null
              ? warehousesById[movement.warehouseId!]
              : null,
          sourceName: sourceName,
        ),
      );
    }
    return enriched;
  });
}
