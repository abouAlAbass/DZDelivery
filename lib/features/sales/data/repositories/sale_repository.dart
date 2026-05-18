import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hissab_dz/core/database/database.dart';
import 'package:hissab_dz/core/database/database_provider.dart';
import 'package:hissab_dz/features/invoices/domain/entities/invoice_status.dart';
import 'package:hissab_dz/features/sales/domain/entities/sale.dart';
import 'package:hissab_dz/features/stock/domain/entities/stock_movement_type.dart';

abstract class SaleRepository {
  Stream<List<Sale>> watchSales();
  Future<Sale?> getSaleById(int saleId);
  Stream<List<SalePayment>> watchPaymentsForSale(int saleId);
  Stream<List<SaleReturn>> watchReturnsForSale(int saleId);
  Future<String> generateNextSaleNumber({DateTime? date});
  Future<int> createSale(Sale sale);
  Future<void> confirmSale(int saleId);
  Future<int> createAndConfirmSale(Sale sale);
  Future<void> addSalePayment({
    required int saleId,
    required double amount,
    required String method,
    String? note,
    int? routeId,
  });
  Future<int> createSaleReturn(SaleReturn saleReturn);
  Future<void> confirmSaleReturn(int returnId);
  Future<int> generateInvoiceFromSale(int saleId);
  Future<PosDailyReport> getDailyReport(DateTime date, {int? warehouseId});
}

class SaleRepositoryImpl implements SaleRepository {
  final AppDatabase _db;

  SaleRepositoryImpl(this._db);

  @override
  Stream<List<Sale>> watchSales() {
    final query = _db.select(_db.sales)
      ..orderBy([(row) => OrderingTerm.desc(row.date)]);

    return query.watch().asyncMap(
      (rows) => Future.wait(rows.map((row) => _mapSale(row))),
    );
  }

  @override
  Future<Sale?> getSaleById(int saleId) async {
    final row = await (_db.select(
      _db.sales,
    )..where((sale) => sale.id.equals(saleId))).getSingleOrNull();
    if (row == null) return null;
    return _mapSale(row);
  }

  @override
  Stream<List<SalePayment>> watchPaymentsForSale(int saleId) {
    final query = _db.select(_db.salePayments)
      ..where((payment) => payment.saleId.equals(saleId))
      ..orderBy([(payment) => OrderingTerm.desc(payment.date)]);

    return query.watch().map((rows) => rows.map(_mapPayment).toList());
  }

  @override
  Stream<List<SaleReturn>> watchReturnsForSale(int saleId) {
    final query = _db.select(_db.saleReturns)
      ..where((row) => row.saleId.equals(saleId))
      ..orderBy([(row) => OrderingTerm.desc(row.date)]);

    return query.watch().asyncMap(
      (rows) => Future.wait(rows.map((row) => _mapSaleReturn(row))),
    );
  }

  @override
  Future<String> generateNextSaleNumber({DateTime? date}) async {
    final target = date ?? DateTime.now();
    final prefix = 'V-${target.year}-';
    final query = _db.select(_db.sales)
      ..where((row) => row.saleNumber.like('$prefix%'))
      ..orderBy([(row) => OrderingTerm.desc(row.saleNumber)])
      ..limit(1);
    final lastSale = await query.getSingleOrNull();
    final lastNumber = lastSale == null
        ? 0
        : int.tryParse(lastSale.saleNumber.split('-').last) ?? 0;

    return '$prefix${(lastNumber + 1).toString().padLeft(4, '0')}';
  }

  @override
  Future<int> createAndConfirmSale(Sale sale) {
    return _db.transaction(() async {
      final saleId = await _insertSale(sale);
      await _confirmSaleInsideTransaction(saleId);
      return saleId;
    });
  }

  @override
  Future<int> createSale(Sale sale) {
    return _db.transaction(() => _insertSale(sale));
  }

  @override
  Future<void> confirmSale(int saleId) {
    return _db.transaction(() => _confirmSaleInsideTransaction(saleId));
  }

  @override
  Future<void> addSalePayment({
    required int saleId,
    required double amount,
    required String method,
    String? note,
    int? routeId,
  }) {
    return _db.transaction(() async {
      if (amount <= 0) {
        throw StateError('Payment amount must be greater than zero');
      }

      final sale = await (_db.select(
        _db.sales,
      )..where((row) => row.id.equals(saleId))).getSingle();
      final currentPaid = await _getPaidAmount(saleId);
      final nextPaid = currentPaid + amount;
      if (nextPaid > sale.total) {
        throw StateError('Payment amount cannot exceed total');
      }

      if (routeId != null) {
        final route = await (_db.select(_db.deliveryRoutes)
              ..where((row) => row.id.equals(routeId)))
            .getSingleOrNull();
        if (route != null && route.status == 'closed') {
          throw StateError('Impossible d\'ajouter un paiement à une tournée fermée.');
        }
      }

      await _db
          .into(_db.salePayments)
          .insert(
            SalePaymentsCompanion.insert(
              saleId: saleId,
              amount: amount,
              method: method,
              date: Value(DateTime.now()),
              note: Value(note),
              routeId: Value(routeId),
            ),
          );

      await (_db.update(
        _db.sales,
      )..where((row) => row.id.equals(saleId))).write(
        SalesCompanion(
          paidAmount: Value(nextPaid),
          paymentStatus: Value(_paymentStatusFor(nextPaid, sale.total)),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  @override
  Future<int> createSaleReturn(SaleReturn saleReturn) {
    return _db.transaction(() async {
      _validateSaleReturn(saleReturn);

      if (saleReturn.routeId != null) {
        final route = await (_db.select(_db.deliveryRoutes)
              ..where((row) => row.id.equals(saleReturn.routeId!)))
            .getSingleOrNull();
        if (route != null && route.status == 'closed') {
          throw StateError('Impossible de créer un retour sur une tournée fermée.');
        }
      }

      final returnId = await _db
          .into(_db.saleReturns)
          .insert(
            SaleReturnsCompanion.insert(
              saleId: Value(saleReturn.saleId),
              clientId: Value(saleReturn.clientId),
              warehouseId: saleReturn.warehouseId,
              date: saleReturn.date,
              total: Value(saleReturn.total),
              status: Value(saleReturn.status),
              confirmedAt: Value(saleReturn.confirmedAt),
              note: Value(saleReturn.note),
              routeId: Value(saleReturn.routeId),
            ),
          );

      for (final item in saleReturn.items) {
        await _db
            .into(_db.saleReturnItems)
            .insert(
              SaleReturnItemsCompanion.insert(
                returnId: returnId,
                articleId: item.articleId,
                quantity: item.quantity,
                unitPrice: Value(item.unitPrice),
                total: Value(item.total),
              ),
            );
      }

      return returnId;
    });
  }

  @override
  Future<void> confirmSaleReturn(int returnId) {
    return _db.transaction(() async {
      final saleReturn = await (_db.select(
        _db.saleReturns,
      )..where((row) => row.id.equals(returnId))).getSingle();

      if (saleReturn.status == 'confirmed') return;

      final existingMovements =
          await (_db.select(_db.stockMovements)..where(
                (movement) =>
                    movement.sourceType.equals(
                      StockMovementSourceTypes.saleReturn,
                    ) &
                    movement.sourceId.equals(returnId),
              ))
              .get();
      if (existingMovements.isNotEmpty) {
        await _markReturnConfirmed(returnId);
        return;
      }

      final items = await (_db.select(
        _db.saleReturnItems,
      )..where((item) => item.returnId.equals(returnId))).get();

      if (saleReturn.saleId != null) {
        for (final item in items) {
          final sold = await _getSoldQuantity(
            saleId: saleReturn.saleId!,
            articleId: item.articleId,
          );
          final previouslyReturned = await _getReturnedQuantity(
            saleId: saleReturn.saleId!,
            articleId: item.articleId,
          );
          if (item.quantity > sold - previouslyReturned) {
            throw StateError('Returned quantity exceeds sold quantity');
          }
        }
      }

      for (final item in items) {
        if (!await _isStockTrackedArticle(item.articleId)) continue;

        await _db
            .into(_db.stockMovements)
            .insert(
              StockMovementsCompanion.insert(
                articleId: item.articleId,
                warehouseId: Value(saleReturn.warehouseId),
                type: StockMovementTypes.returnType,
                quantity: item.quantity,
                unitPrice: Value(item.unitPrice),
                sourceType: const Value(StockMovementSourceTypes.saleReturn),
                sourceId: Value(returnId),
              ),
            );
      }

      await _markReturnConfirmed(returnId);
    });
  }

  @override
  Future<int> generateInvoiceFromSale(int saleId) {
    return _db.transaction(() async {
      final existingInvoice =
          await (_db.select(_db.invoices)
                ..where((invoice) => invoice.saleId.equals(saleId))
                ..limit(1))
              .getSingleOrNull();
      if (existingInvoice != null) return existingInvoice.id;

      final sale = await (_db.select(
        _db.sales,
      )..where((row) => row.id.equals(saleId))).getSingle();
      final items = await (_db.select(
        _db.saleItems,
      )..where((item) => item.saleId.equals(saleId))).get();
      final clientId = sale.clientId ?? await _getOrCreatePosClientId();
      final invoiceNumber = await _generateNextInvoiceNumber();

      final invoiceId = await _db
          .into(_db.invoices)
          .insert(
            InvoicesCompanion.insert(
              clientId: clientId,
              saleId: Value(saleId),
              invoiceNumber: invoiceNumber,
              status: InvoiceStatus.draft,
              issueDate: sale.date,
              subtotal: Value(sale.subtotal),
              discountAmount: Value(sale.discountAmount),
              total: Value(sale.total),
              notes: Value('Generee depuis vente ${sale.saleNumber}'),
            ),
          );

      for (final item in items) {
        final article = await (_db.select(
          _db.articles,
        )..where((row) => row.id.equals(item.articleId))).getSingleOrNull();
        await _db
            .into(_db.invoiceItems)
            .insert(
              InvoiceItemsCompanion.insert(
                invoiceId: invoiceId,
                description: article?.name ?? 'Article ${item.articleId}',
                quantity: Value(item.quantity),
                unitPrice: Value(item.unitPrice),
                amount: Value(item.total),
              ),
            );
      }

      return invoiceId;
    });
  }

  @override
  Future<PosDailyReport> getDailyReport(
    DateTime date, {
    int? warehouseId,
  }) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final warehouse = warehouseId == null
        ? await (_db.select(_db.warehouses)
                ..where((row) => row.type.equals('truck'))
                ..limit(1))
              .getSingleOrNull()
        : await (_db.select(
            _db.warehouses,
          )..where((row) => row.id.equals(warehouseId))).getSingleOrNull();

    if (warehouse == null) {
      return PosDailyReport(
        date: start,
        warehouseName: 'Aucun camion',
        saleCount: 0,
        loadedQuantity: 0,
        soldQuantity: 0,
        truckReturnQuantity: 0,
        salesTotal: 0,
        cashTotal: 0,
        creditTotal: 0,
        returnsTotal: 0,
        unpaidTotal: 0,
        partialTotal: 0,
        truckStock: const {},
      );
    }

    final sales =
        await (_db.select(_db.sales)..where(
              (sale) =>
                  sale.date.isBiggerOrEqualValue(start) &
                  sale.date.isSmallerThanValue(end) &
                  sale.warehouseId.equals(warehouse.id) &
                  sale.status.equals('validated'),
            ))
            .get();

    final loadedQuantity = await _readDouble(
      '''
      SELECT COALESCE(SUM(sti.quantity), 0) AS value
      FROM stock_transfer_items sti
      INNER JOIN stock_transfers st ON st.id = sti.transfer_id
      WHERE st.to_warehouse_id = ?
        AND st.status = 'confirmed'
        AND st.date >= ?
        AND st.date < ?
        AND st.deleted_at IS NULL
        AND sti.deleted_at IS NULL
      ''',
      [
        Variable.withInt(warehouse.id),
        Variable.withDateTime(start),
        Variable.withDateTime(end),
      ],
    );

    final soldQuantity = await _readDouble(
      '''
      SELECT COALESCE(SUM(si.quantity), 0) AS value
      FROM sale_items si
      INNER JOIN sales s ON s.id = si.sale_id
      WHERE s.warehouse_id = ?
        AND s.status = 'validated'
        AND s.date >= ?
        AND s.date < ?
        AND s.deleted_at IS NULL
        AND si.deleted_at IS NULL
      ''',
      [
        Variable.withInt(warehouse.id),
        Variable.withDateTime(start),
        Variable.withDateTime(end),
      ],
    );

    final returnsTotal = await _readDouble(
      '''
      SELECT COALESCE(SUM(total), 0) AS value
      FROM sale_returns
      WHERE warehouse_id = ?
        AND status = 'confirmed'
        AND date >= ?
        AND date < ?
        AND deleted_at IS NULL
      ''',
      [
        Variable.withInt(warehouse.id),
        Variable.withDateTime(start),
        Variable.withDateTime(end),
      ],
    );

    final cashTotal = await _readDouble(
      '''
      SELECT COALESCE(SUM(sp.amount), 0) AS value
      FROM sale_payments sp
      INNER JOIN sales s ON s.id = sp.sale_id
      WHERE s.warehouse_id = ?
        AND sp.date >= ?
        AND sp.date < ?
        AND sp.deleted_at IS NULL
        AND s.deleted_at IS NULL
      ''',
      [
        Variable.withInt(warehouse.id),
        Variable.withDateTime(start),
        Variable.withDateTime(end),
      ],
    );

    final truckReturnQuantity = await _readDouble(
      '''
      SELECT COALESCE(SUM(quantity), 0) AS value
      FROM stock_movements
      WHERE warehouse_id = ?
        AND deleted_at IS NULL
      ''',
      [Variable.withInt(warehouse.id)],
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
          variables: [Variable.withInt(warehouse.id)],
          readsFrom: {_db.stockMovements},
        )
        .get();

    final salesTotal = sales.fold(0.0, (sum, sale) => sum + sale.total);
    final creditTotal = sales.fold(
      0.0,
      (sum, sale) =>
          sum + (sale.total - sale.paidAmount).clamp(0, double.infinity),
    );

    return PosDailyReport(
      date: start,
      warehouseId: warehouse.id,
      warehouseName: warehouse.name,
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
    return (rows.single.data['value'] as num).toDouble();
  }

  Future<int> _insertSale(Sale sale) async {
    _validateSale(sale);

    final warehouse = await (_db.select(_db.warehouses)
          ..where((row) => row.id.equals(sale.warehouseId)))
        .getSingleOrNull();

    if (warehouse != null && warehouse.type == 'truck') {
      final activeRoute = await (_db.select(_db.deliveryRoutes)
            ..where((row) => row.status.equals('open'))
            ..limit(1))
          .getSingleOrNull();

      if (activeRoute == null) {
        final hasAnyRoute = await (_db.select(_db.deliveryRoutes)..limit(1)).get();
        if (hasAnyRoute.isNotEmpty) {
          throw StateError('Une vente POS depuis camion nécessite une tournée active.');
        }
      } else {
        if (activeRoute.warehouseId != sale.warehouseId) {
          throw StateError('Le dépôt/camion de la vente doit correspondre à celui de la tournée active.');
        }
      }
    }

    if (sale.routeId != null) {
      final route = await (_db.select(_db.deliveryRoutes)
            ..where((row) => row.id.equals(sale.routeId!)))
          .getSingleOrNull();
      if (route != null && route.status == 'closed') {
        throw StateError('Impossible d\'associer une vente à une tournée fermée.');
      }
    }

    final saleId = await _db
        .into(_db.sales)
        .insert(
          SalesCompanion.insert(
            saleNumber: sale.saleNumber,
            clientId: Value(sale.clientId),
            warehouseId: sale.warehouseId,
            date: sale.date,
            subtotal: Value(sale.subtotal),
            discountAmount: Value(sale.discountAmount),
            total: Value(sale.total),
            paidAmount: Value(sale.paidAmount),
            paymentStatus: Value(
              _paymentStatusFor(sale.paidAmount, sale.total),
            ),
            status: Value(sale.status),
            note: Value(sale.note),
            routeId: Value(sale.routeId),
          ),
        );

    for (final item in sale.items) {
      await _db
          .into(_db.saleItems)
          .insert(
            SaleItemsCompanion.insert(
              saleId: saleId,
              articleId: item.articleId,
              quantity: item.quantity,
              unitPrice: Value(item.unitPrice),
              discountAmount: Value(item.discountAmount),
              total: Value(item.total),
            ),
          );
    }

    final payment = sale.payment;
    if (payment != null && payment.amount > 0) {
      await _db
          .into(_db.salePayments)
          .insert(
            SalePaymentsCompanion.insert(
              saleId: saleId,
              amount: payment.amount,
              method: payment.method,
              date: Value(payment.date),
              note: Value(payment.note),
              routeId: Value(sale.routeId),
            ),
          );
    }

    return saleId;
  }

  Future<void> _confirmSaleInsideTransaction(int saleId) async {
    final sale = await (_db.select(
      _db.sales,
    )..where((row) => row.id.equals(saleId))).getSingle();

    if (sale.status == 'validated') return;

    final existingMovements =
        await (_db.select(_db.stockMovements)..where(
              (movement) =>
                  movement.sourceType.equals(StockMovementSourceTypes.sale) &
                  movement.sourceId.equals(saleId),
            ))
            .get();

    if (existingMovements.isNotEmpty) {
      await _markValidated(saleId);
      return;
    }

    final items = await (_db.select(
      _db.saleItems,
    )..where((item) => item.saleId.equals(saleId))).get();

    final requestedByArticle = <int, double>{};
    for (final item in items) {
      if (!await _isStockTrackedArticle(item.articleId)) continue;

      requestedByArticle[item.articleId] =
          (requestedByArticle[item.articleId] ?? 0) + item.quantity;
    }

    for (final entry in requestedByArticle.entries) {
      final available = await _getAvailableStock(
        articleId: entry.key,
        warehouseId: sale.warehouseId,
      );
      if (entry.value > available) {
        throw StateError(
          'Insufficient stock for article ${entry.key}: requested ${entry.value}, available $available',
        );
      }
    }

    for (final item in items) {
      if (!await _isStockTrackedArticle(item.articleId)) continue;

      await _db
          .into(_db.stockMovements)
          .insert(
            StockMovementsCompanion.insert(
              articleId: item.articleId,
              warehouseId: Value(sale.warehouseId),
              type: StockMovementTypes.sale,
              quantity: -item.quantity,
              unitPrice: Value(item.unitPrice),
              sourceType: const Value(StockMovementSourceTypes.sale),
              sourceId: Value(saleId),
            ),
          );
    }

    await _markValidated(saleId);
  }

  void _validateSale(Sale sale) {
    if (sale.warehouseId <= 0) {
      throw StateError('Warehouse is required');
    }
    if (sale.items.isEmpty) {
      throw StateError('Sale must contain at least one item');
    }
    if (sale.subtotal < 0 || sale.total < 0) {
      throw StateError('Sale totals cannot be negative');
    }
    if (sale.discountAmount < 0 || sale.discountAmount > sale.subtotal) {
      throw StateError('Discount cannot exceed subtotal');
    }
    if (sale.paidAmount < 0) {
      throw StateError('Payment amount cannot be negative');
    }
    if (sale.paidAmount > sale.total) {
      throw StateError('Payment amount cannot exceed total');
    }
    final payment = sale.payment;
    if (payment != null) {
      if (payment.amount < 0) {
        throw StateError('Payment amount cannot be negative');
      }
      if (payment.amount > sale.total) {
        throw StateError('Payment amount cannot exceed total');
      }
      if (payment.amount != sale.paidAmount) {
        throw StateError('Payment amount must match sale paid amount');
      }
    }

    for (final item in sale.items) {
      if (item.articleId <= 0) {
        throw StateError('Article is required');
      }
      if (item.quantity <= 0) {
        throw StateError('Sale item quantity must be greater than zero');
      }
      if (item.unitPrice < 0 || item.total < 0) {
        throw StateError('Sale item price cannot be negative');
      }
    }
  }

  String _paymentStatusFor(double paidAmount, double total) {
    if (paidAmount <= 0) return 'unpaid';
    if (paidAmount >= total) return 'paid';
    return 'partial';
  }

  Future<bool> _isStockTrackedArticle(int articleId) async {
    final article = await (_db.select(
      _db.articles,
    )..where((row) => row.id.equals(articleId))).getSingleOrNull();

    if (article == null) return false;
    if (article.deletedAt != null || !article.isActive) return false;
    return article.type != 'service';
  }

  Future<Sale> _mapSale(SaleData row) async {
    final items = await (_db.select(
      _db.saleItems,
    )..where((item) => item.saleId.equals(row.id))).get();
    return Sale(
      id: row.id,
      saleNumber: row.saleNumber,
      clientId: row.clientId,
      warehouseId: row.warehouseId,
      date: row.date,
      subtotal: row.subtotal,
      discountAmount: row.discountAmount,
      total: row.total,
      paidAmount: row.paidAmount,
      paymentStatus: row.paymentStatus,
      status: row.status,
      note: row.note,
      routeId: row.routeId,
      items: items
          .map(
            (item) => SaleItem(
              id: item.id,
              saleId: item.saleId,
              articleId: item.articleId,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
              discountAmount: item.discountAmount,
              total: item.total,
            ),
          )
          .toList(),
    );
  }

  SalePayment _mapPayment(SalePaymentData row) {
    return SalePayment(
      id: row.id,
      saleId: row.saleId,
      amount: row.amount,
      method: row.method,
      date: row.date,
      note: row.note,
      routeId: row.routeId,
    );
  }

  Future<SaleReturn> _mapSaleReturn(SaleReturnData row) async {
    final items = await (_db.select(
      _db.saleReturnItems,
    )..where((item) => item.returnId.equals(row.id))).get();
    return SaleReturn(
      id: row.id,
      saleId: row.saleId,
      clientId: row.clientId,
      warehouseId: row.warehouseId,
      date: row.date,
      total: row.total,
      status: row.status,
      confirmedAt: row.confirmedAt,
      note: row.note,
      routeId: row.routeId,
      items: items
          .map(
            (item) => SaleReturnItem(
              id: item.id,
              returnId: item.returnId,
              articleId: item.articleId,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
              total: item.total,
            ),
          )
          .toList(),
    );
  }

  void _validateSaleReturn(SaleReturn saleReturn) {
    if (saleReturn.warehouseId <= 0) throw StateError('Warehouse is required');
    if (saleReturn.items.isEmpty) {
      throw StateError('Sale return must contain at least one item');
    }
    for (final item in saleReturn.items) {
      if (item.quantity <= 0) {
        throw StateError('Return item quantity must be greater than zero');
      }
      if (item.unitPrice < 0 || item.total < 0) {
        throw StateError('Return item price cannot be negative');
      }
    }
  }

  Future<double> _getPaidAmount(int saleId) async {
    final rows = await _db
        .customSelect(
          '''
          SELECT COALESCE(SUM(amount), 0) AS amount
          FROM sale_payments
          WHERE sale_id = ?
          ''',
          variables: [Variable.withInt(saleId)],
          readsFrom: {_db.salePayments},
        )
        .get();
    return rows.single.read<double>('amount');
  }

  Future<double> _getSoldQuantity({
    required int saleId,
    required int articleId,
  }) async {
    final rows = await _db
        .customSelect(
          '''
          SELECT COALESCE(SUM(quantity), 0) AS quantity
          FROM sale_items
          WHERE sale_id = ?
            AND article_id = ?
          ''',
          variables: [Variable.withInt(saleId), Variable.withInt(articleId)],
          readsFrom: {_db.saleItems},
        )
        .get();
    return rows.single.read<double>('quantity');
  }

  Future<double> _getReturnedQuantity({
    required int saleId,
    required int articleId,
  }) async {
    final rows = await _db
        .customSelect(
          '''
          SELECT COALESCE(SUM(sri.quantity), 0) AS quantity
          FROM sale_return_items sri
          INNER JOIN sale_returns sr ON sr.id = sri.return_id
          WHERE sr.sale_id = ?
            AND sri.article_id = ?
            AND EXISTS (
              SELECT 1
              FROM stock_movements sm
              WHERE sm.source_type = ?
                AND sm.source_id = sr.id
                AND sm.deleted_at IS NULL
            )
          ''',
          variables: [
            Variable.withInt(saleId),
            Variable.withInt(articleId),
            Variable.withString(StockMovementSourceTypes.saleReturn),
          ],
          readsFrom: {_db.saleReturnItems, _db.saleReturns, _db.stockMovements},
        )
        .get();
    return rows.single.read<double>('quantity');
  }

  Future<int> _getOrCreatePosClientId() async {
    final client =
        await (_db.select(_db.clients)
              ..where((row) => row.name.equals('Client POS'))
              ..limit(1))
            .getSingleOrNull();
    if (client != null) return client.id;

    return _db
        .into(_db.clients)
        .insert(ClientsCompanion.insert(name: 'Client POS'));
  }

  Future<String> _generateNextInvoiceNumber() async {
    final query = _db.select(_db.invoices)
      ..orderBy([(row) => OrderingTerm.desc(row.id)])
      ..limit(1);
    final lastInvoice = await query.getSingleOrNull();
    if (lastInvoice == null) return 'INV-0001';

    final lastNumber =
        int.tryParse(lastInvoice.invoiceNumber.split('-').last) ?? 0;
    return 'INV-${(lastNumber + 1).toString().padLeft(4, '0')}';
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

  Future<void> _markValidated(int saleId) {
    return (_db.update(_db.sales)..where((row) => row.id.equals(saleId))).write(
      SalesCompanion(
        status: const Value('validated'),
        validatedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> _markReturnConfirmed(int returnId) {
    return (_db.update(
      _db.saleReturns,
    )..where((row) => row.id.equals(returnId))).write(
      SaleReturnsCompanion(
        status: const Value('confirmed'),
        confirmedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SaleRepositoryImpl(db);
});
