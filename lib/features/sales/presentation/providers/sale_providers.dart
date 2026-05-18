import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hissab_dz/features/sales/data/repositories/sale_repository.dart';
import 'package:hissab_dz/features/sales/domain/entities/sale.dart';

final salesListProvider = StreamProvider.autoDispose<List<Sale>>((ref) {
  return ref.watch(saleRepositoryProvider).watchSales();
});

final saleDetailsProvider = FutureProvider.autoDispose.family<Sale?, int>((
  ref,
  saleId,
) {
  return ref.watch(saleRepositoryProvider).getSaleById(saleId);
});

final salePaymentsProvider = StreamProvider.autoDispose
    .family<List<SalePayment>, int>((ref, saleId) {
      return ref.watch(saleRepositoryProvider).watchPaymentsForSale(saleId);
    });

final saleReturnsProvider = StreamProvider.autoDispose
    .family<List<SaleReturn>, int>((ref, saleId) {
      return ref.watch(saleRepositoryProvider).watchReturnsForSale(saleId);
    });

final posDailyReportProvider = FutureProvider.autoDispose
    .family<PosDailyReport, PosDailyReportRequest>((ref, request) {
      return ref
          .watch(saleRepositoryProvider)
          .getDailyReport(request.date, warehouseId: request.warehouseId);
    });

class PosDailyReportRequest {
  final DateTime date;
  final int? warehouseId;

  const PosDailyReportRequest({required this.date, this.warehouseId});

  DateTime get _day => DateTime(date.year, date.month, date.day);

  @override
  bool operator ==(Object other) {
    return other is PosDailyReportRequest &&
        other._day == _day &&
        other.warehouseId == warehouseId;
  }

  @override
  int get hashCode => Object.hash(_day, warehouseId);
}
