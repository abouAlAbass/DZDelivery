import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hissab_dz/core/database/database.dart';
import 'package:hissab_dz/core/database/database_provider.dart';
import 'package:hissab_dz/features/purchases/data/repositories/purchase_repository.dart';
import 'package:hissab_dz/features/purchases/domain/entities/purchase.dart';

part 'purchase_providers.g.dart';

@riverpod
Stream<List<Purchase>> purchasesList(PurchasesListRef ref) {
  final repository = ref.watch(purchaseRepositoryProvider);
  return repository.watchPurchases();
}

@riverpod
Stream<List<WarehouseData>> depotWarehouses(DepotWarehousesRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(
    db.warehouses,
  )..where((warehouse) => warehouse.type.equals('depot'))).watch();
}

@riverpod
Stream<List<SupplierData>> suppliersList(SuppliersListRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(
    db.suppliers,
  )..where((supplier) => supplier.deletedAt.isNull())).watch();
}
