import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hissab_dz/core/database/database.dart';
import 'package:hissab_dz/core/database/database_provider.dart';
import 'package:hissab_dz/features/stock/domain/entities/stock_overview.dart';

abstract class StockRepository {
  Stream<List<ArticleStockOverview>> getArticleStockOverview();
}

class StockRepositoryImpl implements StockRepository {
  final AppDatabase _db;

  StockRepositoryImpl(this._db);

  @override
  Stream<List<ArticleStockOverview>> getArticleStockOverview() {
    return _db
        .customSelect(
          '''
          SELECT
            a.id AS article_id,
            a.name AS article_name,
            a.code AS article_code,
            CASE WHEN a.sale_price = 0 THEN a.price ELSE a.sale_price END AS sale_price,
            a.purchase_price AS purchase_price,
            w.id AS warehouse_id,
            w.name AS warehouse_name,
            w.type AS warehouse_type,
            COALESCE(SUM(sm.quantity), 0) AS stock_quantity
          FROM articles a
          CROSS JOIN warehouses w
          LEFT JOIN stock_movements sm
            ON sm.article_id = a.id
            AND sm.warehouse_id = w.id
            AND sm.deleted_at IS NULL
          WHERE a.deleted_at IS NULL
            AND w.deleted_at IS NULL
          GROUP BY a.id, w.id
          ORDER BY a.name ASC, w.name ASC
          ''',
          readsFrom: {_db.articles, _db.warehouses, _db.stockMovements},
        )
        .watch()
        .map((rows) {
          final overviewsByArticle = <int, ArticleStockOverview>{};
          final stocksByArticle = <int, List<WarehouseStockQuantity>>{};

          for (final row in rows) {
            final articleId = row.read<int>('article_id');
            final stock = WarehouseStockQuantity(
              warehouseId: row.read<int>('warehouse_id'),
              warehouseName: row.read<String>('warehouse_name'),
              warehouseType: row.read<String>('warehouse_type'),
              quantity: row.read<double>('stock_quantity'),
            );

            stocksByArticle.putIfAbsent(articleId, () => []).add(stock);
            overviewsByArticle.putIfAbsent(
              articleId,
              () => ArticleStockOverview(
                articleId: articleId,
                articleName: row.read<String>('article_name'),
                articleCode: row.readNullable<String>('article_code'),
                salePrice: row.read<double>('sale_price'),
                purchasePrice: row.read<double>('purchase_price'),
                warehouseStocks: stocksByArticle[articleId]!,
              ),
            );
          }

          return overviewsByArticle.values.toList();
        });
  }
}

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return StockRepositoryImpl(db);
});
