import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hissab_dz/core/database/database.dart';
import 'package:hissab_dz/features/pos/data/repositories/delivery_route_repository.dart';
import 'package:hissab_dz/features/sales/data/repositories/sale_repository.dart';
import 'package:hissab_dz/features/sales/domain/entities/sale.dart';
import 'package:hissab_dz/features/stock/data/repositories/stock_transfer_repository.dart';
import 'package:hissab_dz/features/stock/domain/entities/stock_transfer.dart';

void main() {
  late AppDatabase db;
  late DeliveryRouteRepositoryImpl routeRepository;
  late SaleRepositoryImpl saleRepository;
  late StockTransferRepositoryImpl transferRepository;
  late int depotId;
  late int truckId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    routeRepository = DeliveryRouteRepositoryImpl(db);
    saleRepository = SaleRepositoryImpl(db);
    transferRepository = StockTransferRepositoryImpl(db);
    depotId = await _warehouseId(db, 'depot');
    truckId = await _warehouseId(db, 'truck');
  });

  tearDown(() async {
    await db.close();
  });

  test('startRoute cree une tournee active', () async {
    final routeId = await routeRepository.startRoute(
      warehouseId: truckId,
      driverName: 'Chauffeur A',
      startKm: 10000,
      startCash: 5000,
      note: 'Start notes',
    );
    expect(routeId, isNotNull);
    
    final route = await routeRepository.getRouteById(routeId);
    expect(route, isNotNull);
    expect(route!.status, 'open');
    expect(route.driverName, 'Chauffeur A');
    expect(route.startKm, 10000);
    expect(route.startCash, 5000);
  });

  test('Une tournee active peut etre recuperee par getActiveRoute', () async {
    expect(await routeRepository.getActiveRoute(), isNull);
    
    final routeId = await routeRepository.startRoute(
      warehouseId: truckId,
      driverName: 'Chauffeur A',
    );
    
    final active = await routeRepository.getActiveRoute();
    expect(active, isNotNull);
    expect(active!.id, routeId);
  });

  test('closeRoute ferme la tournee et renseigne closedAt', () async {
    final routeId = await routeRepository.startRoute(
      warehouseId: truckId,
      driverName: 'Chauffeur A',
    );
    
    await routeRepository.closeRoute(
      routeId: routeId,
      endKm: 10200,
      endCash: 12000,
      note: 'End notes',
    );
    
    final closed = await routeRepository.getRouteById(routeId);
    expect(closed!.status, 'closed');
    expect(closed.endKm, 10200);
    expect(closed.endCash, 12000);
    expect(closed.closedAt, isNotNull);
  });

  test('Une tournee fermee n\'est plus retournee comme active', () async {
    final routeId = await routeRepository.startRoute(
      warehouseId: truckId,
      driverName: 'Chauffeur A',
    );
    
    expect(await routeRepository.getActiveRoute(), isNotNull);
    
    await routeRepository.closeRoute(routeId: routeId);
    
    expect(await routeRepository.getActiveRoute(), isNull);
  });

  test('Une vente creee pendant une tournee conserve routeId', () async {
    final routeId = await routeRepository.startRoute(
      warehouseId: truckId,
      driverName: 'Chauffeur A',
    );
    
    final articleId = await _insertArticle(db, salePrice: 100);
    await _loadTruckDirect(db, articleId, truckId, 10);
    
    final saleId = await saleRepository.createAndConfirmSale(
      Sale(
        saleNumber: 'S-ROUTE-001',
        warehouseId: truckId,
        date: DateTime.now(),
        subtotal: 500,
        total: 500,
        routeId: routeId,
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
    
    final sale = await saleRepository.getSaleById(saleId);
    expect(sale, isNotNull);
    expect(sale!.routeId, routeId);
  });

  test('Un paiement ajoute avec routeId est compte dans le rapport de tournee', () async {
    final routeId = await routeRepository.startRoute(
      warehouseId: truckId,
      driverName: 'Chauffeur A',
    );
    
    final articleId = await _insertArticle(db, salePrice: 100);
    await _loadTruckDirect(db, articleId, truckId, 10);
    
    final saleId = await saleRepository.createAndConfirmSale(
      Sale(
        saleNumber: 'S-ROUTE-002',
        warehouseId: truckId,
        date: DateTime.now(),
        subtotal: 500,
        total: 500,
        routeId: routeId,
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
    
    await saleRepository.addSalePayment(
      saleId: saleId,
      amount: 300,
      method: 'cash',
      routeId: routeId,
    );
    
    final report = await routeRepository.getRouteReport(routeId);
    expect(report.cashTotal, 300);
  });

  test('Un retour vente confirme avec routeId est compte dans le rapport de tournee', () async {
    final routeId = await routeRepository.startRoute(
      warehouseId: truckId,
      driverName: 'Chauffeur A',
    );
    
    final articleId = await _insertArticle(db, salePrice: 100);
    await _loadTruckDirect(db, articleId, truckId, 10);
    
    final saleId = await saleRepository.createAndConfirmSale(
      Sale(
        saleNumber: 'S-ROUTE-003',
        warehouseId: truckId,
        date: DateTime.now(),
        subtotal: 500,
        total: 500,
        routeId: routeId,
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
    
    final returnId = await saleRepository.createSaleReturn(
      SaleReturn(
        saleId: saleId,
        warehouseId: truckId,
        date: DateTime.now(),
        total: 200,
        routeId: routeId,
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
    
    final report = await routeRepository.getRouteReport(routeId);
    expect(report.returnsTotal, 200);
  });

  test('Un chargement camion avec routeId est compte dans le rapport de tournee', () async {
    final routeId = await routeRepository.startRoute(
      warehouseId: truckId,
      driverName: 'Chauffeur A',
    );
    
    final articleId = await _insertArticle(db);
    // load depot stock
    await db.into(db.stockMovements).insert(
      StockMovementsCompanion.insert(
        articleId: articleId,
        warehouseId: Value(depotId),
        type: 'purchase',
        quantity: 100,
        unitPrice: const Value(50),
      ),
    );
    
    final transferId = await transferRepository.addTransfer(
      StockTransfer(
        fromWarehouseId: depotId,
        toWarehouseId: truckId,
        date: DateTime.now(),
        routeId: routeId,
        items: [
          StockTransferItem(articleId: articleId, quantity: 40),
        ],
      ),
    );
    await transferRepository.confirmStockTransfer(transferId);
    
    final report = await routeRepository.getRouteReport(routeId);
    expect(report.loadedQuantity, 40);
  });

  test('Le rapport calcule correctement tous les KPIs de la tournee', () async {
    final routeId = await routeRepository.startRoute(
      warehouseId: truckId,
      driverName: 'Chauffeur A',
      startCash: 5000,
    );
    
    final articleId = await _insertArticle(db, salePrice: 100);
    
    // 1. Loaded Quantity: 50 items
    await db.into(db.stockMovements).insert(
      StockMovementsCompanion.insert(
        articleId: articleId,
        warehouseId: Value(depotId),
        type: 'purchase',
        quantity: 100,
        unitPrice: const Value(50),
      ),
    );
    final transferId = await transferRepository.addTransfer(
      StockTransfer(
        fromWarehouseId: depotId,
        toWarehouseId: truckId,
        date: DateTime.now(),
        routeId: routeId,
        items: [
          StockTransferItem(articleId: articleId, quantity: 50),
        ],
      ),
    );
    await transferRepository.confirmStockTransfer(transferId);
    
    // 2. Sales: 20 items (Total = 2000, Paid = 1200, Credit = 800)
    final saleId = await saleRepository.createAndConfirmSale(
      Sale(
        saleNumber: 'S-REPORT-KPI-001',
        warehouseId: truckId,
        date: DateTime.now(),
        subtotal: 2000,
        total: 2000,
        paidAmount: 1200,
        routeId: routeId,
        items: [
          SaleItem(
            articleId: articleId,
            quantity: 20,
            unitPrice: 100,
            total: 2000,
          ),
        ],
        payment: SalePayment(
          amount: 1200,
          method: 'cash',
          date: DateTime.now(),
        ),
      ),
    );
    
    // 3. Returns: 5 items (Total = 500)
    final returnId = await saleRepository.createSaleReturn(
      SaleReturn(
        saleId: saleId,
        warehouseId: truckId,
        date: DateTime.now(),
        total: 500,
        routeId: routeId,
        items: [
          SaleReturnItem(
            articleId: articleId,
            quantity: 5,
            unitPrice: 100,
            total: 500,
          ),
        ],
      ),
    );
    await saleRepository.confirmSaleReturn(returnId);
    
    final report = await routeRepository.getRouteReport(routeId);
    
    expect(report.salesTotal, 2000.0);
    expect(report.cashTotal, 1200.0);
    expect(report.creditTotal, 800.0);
    expect(report.returnsTotal, 500.0);
    expect(report.loadedQuantity, 50.0);
    expect(report.soldQuantity, 20.0);
    
    // Stock camion restant: 50 (loaded) - 20 (sold) + 5 (returned) = 35
    expect(report.truckStock[articleId], 35.0);
  });
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

Future<void> _loadTruckDirect(
  AppDatabase db,
  int articleId,
  int warehouseId,
  double quantity,
) async {
  await db.into(db.stockMovements).insert(
        StockMovementsCompanion.insert(
          articleId: articleId,
          warehouseId: Value(warehouseId),
          type: 'purchase',
          quantity: quantity,
          unitPrice: const Value(50),
        ),
      );
}

Future<int> _warehouseId(AppDatabase db, String type) async {
  final warehouse = await (db.select(
    db.warehouses,
  )..where((row) => row.type.equals(type))).getSingle();
  return warehouse.id;
}
