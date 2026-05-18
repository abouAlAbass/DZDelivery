import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hissab_dz/core/database/database.dart';
import 'package:hissab_dz/features/purchases/data/repositories/purchase_repository.dart';
import 'package:hissab_dz/features/purchases/domain/entities/purchase.dart';
import 'package:hissab_dz/features/sales/data/repositories/sale_repository.dart';
import 'package:hissab_dz/features/sales/domain/entities/sale.dart';
import 'package:hissab_dz/features/stock/data/repositories/stock_transfer_repository.dart';
import 'package:hissab_dz/features/stock/domain/entities/stock_movement_type.dart';
import 'package:hissab_dz/features/stock/domain/entities/stock_transfer.dart';

void main() {
  late AppDatabase db;
  late PurchaseRepositoryImpl purchaseRepository;
  late StockTransferRepositoryImpl transferRepository;
  late SaleRepositoryImpl saleRepository;
  late int depotId;
  late int truckId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    purchaseRepository = PurchaseRepositoryImpl(db);
    transferRepository = StockTransferRepositoryImpl(db);
    saleRepository = SaleRepositoryImpl(db);
    depotId = await _warehouseId(db, 'depot');
    truckId = await _warehouseId(db, 'truck');
  });

  tearDown(() async {
    await db.close();
  });

  test('Achat confirme augmente stock depot', () async {
    final articleId = await _insertArticle(db);

    final purchaseId = await purchaseRepository.addPurchase(
      Purchase(
        date: DateTime(2026, 5, 15),
        total: 450,
        items: [
          PurchaseItem(articleId: articleId, quantity: 10, purchasePrice: 45),
        ],
      ),
    );

    await purchaseRepository.confirmPurchase(purchaseId, warehouseId: depotId);

    expect(await _stock(db, articleId, depotId), 10);
    expect(
      await _movementCount(db, StockMovementSourceTypes.purchase, purchaseId),
      1,
    );
  });

  test('Confirmer achat deux fois ne double pas stock', () async {
    final articleId = await _insertArticle(db);
    final purchaseId = await purchaseRepository.addPurchase(
      Purchase(
        date: DateTime(2026, 5, 15),
        total: 450,
        items: [
          PurchaseItem(articleId: articleId, quantity: 10, purchasePrice: 45),
        ],
      ),
    );

    await purchaseRepository.confirmPurchase(purchaseId, warehouseId: depotId);
    await purchaseRepository.confirmPurchase(purchaseId, warehouseId: depotId);

    expect(await _stock(db, articleId, depotId), 10);
    expect(
      await _movementCount(db, StockMovementSourceTypes.purchase, purchaseId),
      1,
    );
  });

  test(
    'Transfert depot vers camion diminue depot et augmente camion',
    () async {
      final articleId = await _insertArticle(db);
      await _purchaseStock(purchaseRepository, articleId, depotId, 100);

      final transferId = await transferRepository.addTransfer(
        StockTransfer(
          fromWarehouseId: depotId,
          toWarehouseId: truckId,
          date: DateTime(2026, 5, 15),
          items: [StockTransferItem(articleId: articleId, quantity: 30)],
        ),
      );

      await transferRepository.confirmStockTransfer(transferId);

      expect(await _stock(db, articleId, depotId), 70);
      expect(await _stock(db, articleId, truckId), 30);
      expect(
        await _movementCount(
          db,
          StockMovementSourceTypes.stockTransfer,
          transferId,
        ),
        2,
      );
    },
  );

  test('Transfert impossible si stock source insuffisant', () async {
    final articleId = await _insertArticle(db);
    await _purchaseStock(purchaseRepository, articleId, depotId, 2);

    final transferId = await transferRepository.addTransfer(
      StockTransfer(
        fromWarehouseId: depotId,
        toWarehouseId: truckId,
        date: DateTime(2026, 5, 15),
        items: [StockTransferItem(articleId: articleId, quantity: 5)],
      ),
    );

    expect(
      () => transferRepository.confirmStockTransfer(transferId),
      throwsA(isA<StateError>()),
    );

    expect(await _stock(db, articleId, depotId), 2);
    expect(await _stock(db, articleId, truckId), 0);
    expect(
      await _movementCount(
        db,
        StockMovementSourceTypes.stockTransfer,
        transferId,
      ),
      0,
    );
  });

  test('Vente camion diminue stock camion', () async {
    final articleId = await _insertArticle(db, salePrice: 100);
    await _loadTruck(
      purchaseRepository,
      transferRepository,
      articleId,
      depotId,
      truckId,
      30,
    );

    final saleId = await saleRepository.createAndConfirmSale(
      Sale(
        saleNumber: 'S-TEST-001',
        warehouseId: truckId,
        date: DateTime(2026, 5, 15),
        subtotal: 500,
        total: 500,
        items: [
          SaleItem(
            articleId: articleId,
            quantity: 5,
            unitPrice: 100,
            total: 500,
          ),
        ],
      ),
    );

    await saleRepository.confirmSale(saleId);

    expect(await _stock(db, articleId, truckId), 25);
    expect(await _movementCount(db, StockMovementSourceTypes.sale, saleId), 1);
  });

  test('Vente impossible si stock insuffisant', () async {
    final articleId = await _insertArticle(db, salePrice: 100);
    await _loadTruck(
      purchaseRepository,
      transferRepository,
      articleId,
      depotId,
      truckId,
      2,
    );

    expect(
      () => saleRepository.createAndConfirmSale(
        Sale(
          saleNumber: 'S-TEST-002',
          warehouseId: truckId,
          date: DateTime(2026, 5, 15),
          subtotal: 500,
          total: 500,
          items: [
            SaleItem(
              articleId: articleId,
              quantity: 5,
              unitPrice: 100,
              total: 500,
            ),
          ],
        ),
      ),
      throwsA(isA<StateError>()),
    );

    expect(await _stock(db, articleId, truckId), 2);
    expect(await _movementCount(db, StockMovementSourceTypes.sale, null), 0);
  });

  test('Article service ne change pas le stock', () async {
    final serviceId = await _insertArticle(db, type: 'service', salePrice: 100);

    final purchaseId = await purchaseRepository.addPurchase(
      Purchase(
        date: DateTime(2026, 5, 15),
        total: 300,
        items: [
          PurchaseItem(articleId: serviceId, quantity: 3, purchasePrice: 100),
        ],
      ),
    );
    await purchaseRepository.confirmPurchase(purchaseId, warehouseId: depotId);

    await saleRepository.createAndConfirmSale(
      Sale(
        saleNumber: 'S-SERVICE-001',
        warehouseId: truckId,
        date: DateTime(2026, 5, 15),
        subtotal: 100,
        total: 100,
        items: [
          SaleItem(
            articleId: serviceId,
            quantity: 1,
            unitPrice: 100,
            total: 100,
          ),
        ],
      ),
    );

    expect(await _stock(db, serviceId, depotId), 0);
    expect(await _stock(db, serviceId, truckId), 0);
    expect(await _articleMovementCount(db, serviceId), 0);
  });

  test('Retour vente augmente stock', () async {
    final articleId = await _insertArticle(db, salePrice: 100);
    await _loadTruck(
      purchaseRepository,
      transferRepository,
      articleId,
      depotId,
      truckId,
      10,
    );
    final saleId = await saleRepository.createAndConfirmSale(
      Sale(
        saleNumber: 'S-RETURN-001',
        warehouseId: truckId,
        date: DateTime(2026, 5, 15),
        subtotal: 400,
        total: 400,
        items: [
          SaleItem(
            articleId: articleId,
            quantity: 4,
            unitPrice: 100,
            total: 400,
          ),
        ],
      ),
    );

    final returnId = await saleRepository.createSaleReturn(
      SaleReturn(
        saleId: saleId,
        warehouseId: truckId,
        date: DateTime(2026, 5, 15),
        total: 200,
        items: [
          SaleReturnItem(
            articleId: articleId,
            quantity: 2,
            unitPrice: 100,
            total: 200,
          ),
        ],
      ),
    );

    await saleRepository.confirmSaleReturn(returnId);
    await saleRepository.confirmSaleReturn(returnId);
    final saleReturn =
        (await saleRepository.watchReturnsForSale(saleId).first).single;

    expect(await _stock(db, articleId, truckId), 8);
    expect(saleReturn.status, 'confirmed');
    expect(saleReturn.confirmedAt, isA<DateTime>());
    expect(
      await _movementCount(db, StockMovementSourceTypes.saleReturn, returnId),
      1,
    );
  });

  test('Facture depuis vente ne touche pas le stock', () async {
    final articleId = await _insertArticle(db, salePrice: 100);
    await _loadTruck(
      purchaseRepository,
      transferRepository,
      articleId,
      depotId,
      truckId,
      10,
    );
    final saleId = await saleRepository.createAndConfirmSale(
      Sale(
        saleNumber: 'S-INVOICE-001',
        warehouseId: truckId,
        date: DateTime(2026, 5, 15),
        subtotal: 300,
        total: 300,
        items: [
          SaleItem(
            articleId: articleId,
            quantity: 3,
            unitPrice: 100,
            total: 300,
          ),
        ],
      ),
    );
    final stockAfterSale = await _stock(db, articleId, truckId);

    final invoiceId = await saleRepository.generateInvoiceFromSale(saleId);
    final secondInvoiceId = await saleRepository.generateInvoiceFromSale(
      saleId,
    );

    expect(await _stock(db, articleId, truckId), stockAfterSale);
    expect(invoiceId, secondInvoiceId);
    expect(await _movementCount(db, StockMovementSourceTypes.sale, saleId), 1);
  });

  test(
    'Paiement vente refuse montants invalides et met a jour le statut',
    () async {
      final articleId = await _insertArticle(db, salePrice: 100);
      await _loadTruck(
        purchaseRepository,
        transferRepository,
        articleId,
        depotId,
        truckId,
        1,
      );

      final saleId = await saleRepository.createAndConfirmSale(
        Sale(
          saleNumber: 'S-PAYMENT-001',
          warehouseId: truckId,
          date: DateTime(2026, 5, 15),
          subtotal: 100,
          total: 100,
          items: [
            SaleItem(
              articleId: articleId,
              quantity: 1,
              unitPrice: 100,
              total: 100,
            ),
          ],
        ),
      );

      expect(
        (await saleRepository.getSaleById(saleId))!.paymentStatus,
        'unpaid',
      );
      expect(
        () => saleRepository.addSalePayment(
          saleId: saleId,
          amount: -1,
          method: 'cash',
        ),
        throwsA(isA<StateError>()),
      );

      await saleRepository.addSalePayment(
        saleId: saleId,
        amount: 40,
        method: 'cash',
      );
      final partialSale = await saleRepository.getSaleById(saleId);
      expect(partialSale!.paidAmount, 40);
      expect(partialSale.paymentStatus, 'partial');

      expect(
        () => saleRepository.addSalePayment(
          saleId: saleId,
          amount: 61,
          method: 'cash',
        ),
        throwsA(isA<StateError>()),
      );

      await saleRepository.addSalePayment(
        saleId: saleId,
        amount: 60,
        method: 'cash',
      );
      final paidSale = await saleRepository.getSaleById(saleId);
      expect(paidSale!.paidAmount, 100);
      expect(paidSale.paymentStatus, 'paid');
    },
  );

  test('Numerotation vente lisible et sequentielle par annee', () async {
    final date = DateTime(2026, 5, 15);
    final serviceId = await _insertArticle(
      db,
      name: 'Service livraison',
      type: 'service',
      salePrice: 100,
    );

    expect(
      await saleRepository.generateNextSaleNumber(date: date),
      'V-2026-0001',
    );

    final firstNumber = await saleRepository.generateNextSaleNumber(date: date);
    await saleRepository.createAndConfirmSale(
      Sale(
        saleNumber: firstNumber,
        warehouseId: truckId,
        date: date,
        subtotal: 100,
        total: 100,
        items: [
          SaleItem(
            articleId: serviceId,
            quantity: 1,
            unitPrice: 100,
            total: 100,
          ),
        ],
      ),
    );

    expect(
      await saleRepository.generateNextSaleNumber(date: date),
      'V-2026-0002',
    );
    expect(
      await saleRepository.generateNextSaleNumber(date: DateTime(2027, 1, 1)),
      'V-2027-0001',
    );
  });

  test(
    'Rapport fin de journee calcule camion charge vendu cash credit retours',
    () async {
      final reportDate = DateTime(2026, 5, 15, 9);
      final articleId = await _insertArticle(db, salePrice: 500);
      await _loadTruck(
        purchaseRepository,
        transferRepository,
        articleId,
        depotId,
        truckId,
        120,
        date: reportDate,
      );

      final saleId = await saleRepository.createAndConfirmSale(
        Sale(
          saleNumber: 'S-REPORT-001',
          warehouseId: truckId,
          date: reportDate,
          subtotal: 42500,
          total: 42500,
          paidAmount: 38000,
          items: [
            SaleItem(
              articleId: articleId,
              quantity: 85,
              unitPrice: 500,
              total: 42500,
            ),
          ],
          payment: SalePayment(amount: 38000, method: 'cash', date: reportDate),
        ),
      );

      final returnId = await saleRepository.createSaleReturn(
        SaleReturn(
          saleId: saleId,
          warehouseId: truckId,
          date: reportDate,
          total: 2500,
          items: [
            SaleReturnItem(
              articleId: articleId,
              quantity: 5,
              unitPrice: 500,
              total: 2500,
            ),
          ],
        ),
      );
      await saleRepository.confirmSaleReturn(returnId);

      final report = await saleRepository.getDailyReport(
        reportDate,
        warehouseId: truckId,
      );

      expect(report.loadedQuantity, 120);
      expect(report.soldQuantity, 85);
      expect(report.truckReturnQuantity, 40);
      expect(report.salesTotal, 42500);
      expect(report.cashTotal, 38000);
      expect(report.creditTotal, 4500);
      expect(report.returnsTotal, 2500);
    },
  );
}

Future<int> _insertArticle(
  AppDatabase db, {
  String name = 'Article test',
  String type = 'physical',
  double salePrice = 60,
  double purchasePrice = 45,
}) {
  return db
      .into(db.articles)
      .insert(
        ArticlesCompanion.insert(
          name: name,
          code: Value('${name.hashCode}'),
          unit: 'pcs',
          type: Value(type),
          price: Value(salePrice),
          salePrice: Value(salePrice),
          purchasePrice: Value(purchasePrice),
        ),
      );
}

Future<void> _purchaseStock(
  PurchaseRepositoryImpl purchaseRepository,
  int articleId,
  int warehouseId,
  double quantity, {
  DateTime? date,
}) async {
  final purchaseId = await purchaseRepository.addPurchase(
    Purchase(
      date: date ?? DateTime(2026, 5, 15),
      total: quantity * 45,
      items: [
        PurchaseItem(
          articleId: articleId,
          quantity: quantity,
          purchasePrice: 45,
        ),
      ],
    ),
  );
  await purchaseRepository.confirmPurchase(
    purchaseId,
    warehouseId: warehouseId,
  );
}

Future<void> _loadTruck(
  PurchaseRepositoryImpl purchaseRepository,
  StockTransferRepositoryImpl transferRepository,
  int articleId,
  int depotId,
  int truckId,
  double quantity, {
  DateTime? date,
}) async {
  await _purchaseStock(
    purchaseRepository,
    articleId,
    depotId,
    quantity,
    date: date,
  );
  final transferId = await transferRepository.addTransfer(
    StockTransfer(
      fromWarehouseId: depotId,
      toWarehouseId: truckId,
      date: date ?? DateTime(2026, 5, 15),
      items: [StockTransferItem(articleId: articleId, quantity: quantity)],
    ),
  );
  await transferRepository.confirmStockTransfer(transferId);
}

Future<int> _warehouseId(AppDatabase db, String type) async {
  final warehouse = await (db.select(
    db.warehouses,
  )..where((row) => row.type.equals(type))).getSingle();
  return warehouse.id;
}

Future<double> _stock(AppDatabase db, int articleId, int warehouseId) async {
  final rows = await db
      .customSelect(
        '''
        SELECT COALESCE(SUM(quantity), 0) AS quantity
        FROM stock_movements
        WHERE article_id = ?
          AND warehouse_id = ?
          AND deleted_at IS NULL
        ''',
        variables: [Variable.withInt(articleId), Variable.withInt(warehouseId)],
        readsFrom: {db.stockMovements},
      )
      .get();
  return (rows.single.data['quantity'] as num).toDouble();
}

Future<int> _movementCount(
  AppDatabase db,
  String sourceType,
  int? sourceId,
) async {
  final query = db.select(db.stockMovements)
    ..where((row) => row.sourceType.equals(sourceType));
  if (sourceId != null) {
    query.where((row) => row.sourceId.equals(sourceId));
  }
  final rows = await query.get();
  return rows.length;
}

Future<int> _articleMovementCount(AppDatabase db, int articleId) async {
  final rows = await (db.select(
    db.stockMovements,
  )..where((row) => row.articleId.equals(articleId))).get();
  return rows.length;
}
