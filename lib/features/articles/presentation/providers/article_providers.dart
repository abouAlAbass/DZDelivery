import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';
import 'package:hissab_dz/core/database/database.dart';
import 'package:hissab_dz/core/database/database_provider.dart';
import 'package:hissab_dz/features/articles/data/repositories/article_repository.dart';
import 'package:hissab_dz/features/articles/domain/entities/article.dart';

part 'article_providers.g.dart';

class ArticleStockSummary {
  final double depotQuantity;
  final double truckQuantity;

  const ArticleStockSummary({this.depotQuantity = 0, this.truckQuantity = 0});
}

class EnrichedStockMovement {
  final StockMovementData movement;
  final WarehouseData? warehouse;
  final String? sourceName;

  const EnrichedStockMovement({
    required this.movement,
    this.warehouse,
    this.sourceName,
  });
}

@riverpod
Stream<List<Article>> articlesList(ArticlesListRef ref) {
  final repository = ref.watch(articleRepositoryProvider);
  return repository.watchArticles();
}

@riverpod
class ArticleSearchQuery extends _$ArticleSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@riverpod
Stream<List<Article>> filteredArticles(FilteredArticlesRef ref) {
  final articles = ref.watch(articlesListProvider).value ?? [];
  final query = ref.watch(articleSearchQueryProvider).toLowerCase();

  if (query.isEmpty) return Stream.value(articles);

  return Stream.value(
    articles.where((article) {
      return article.name.toLowerCase().contains(query) ||
          (article.code?.toLowerCase().contains(query) ?? false);
    }).toList(),
  );
}

@riverpod
Stream<Map<int, ArticleStockSummary>> articleStockSummaries(
  ArticleStockSummariesRef ref,
) {
  final db = ref.watch(appDatabaseProvider);

  return db.select(db.stockMovements).watch().asyncMap((movements) async {
    final warehouses = await db.select(db.warehouses).get();
    final warehousesById = {
      for (final warehouse in warehouses) warehouse.id: warehouse,
    };
    final stockByArticle = <int, ({double depot, double truck})>{};

    for (final movement in movements) {
      final warehouseId = movement.warehouseId;
      if (warehouseId == null) continue;

      final warehouse = warehousesById[warehouseId];
      if (warehouse == null || warehouse.deletedAt != null) continue;

      final current =
          stockByArticle[movement.articleId] ?? (depot: 0.0, truck: 0.0);

      if (warehouse.type == 'depot') {
        stockByArticle[movement.articleId] = (
          depot: current.depot + movement.quantity,
          truck: current.truck,
        );
      } else if (warehouse.type == 'truck') {
        stockByArticle[movement.articleId] = (
          depot: current.depot,
          truck: current.truck + movement.quantity,
        );
      }
    }

    return stockByArticle.map(
      (articleId, stock) => MapEntry(
        articleId,
        ArticleStockSummary(
          depotQuantity: stock.depot,
          truckQuantity: stock.truck,
        ),
      ),
    );
  });
}

@riverpod
Stream<List<EnrichedStockMovement>> articleStockMovements(
  ArticleStockMovementsRef ref,
  int articleId,
) {
  final db = ref.watch(appDatabaseProvider);

  return (db.select(db.stockMovements)
        ..where((movement) => movement.articleId.equals(articleId))
        ..orderBy([(movement) => OrderingTerm.desc(movement.createdAt)]))
      .watch()
      .asyncMap((movements) async {
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
