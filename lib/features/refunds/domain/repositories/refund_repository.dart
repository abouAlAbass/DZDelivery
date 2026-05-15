import '../entities/refund.dart';

abstract class RefundRepository {
  Future<int> createRefund(Refund refund);
  Future<Refund?> getRefundById(int id);
  Future<List<Refund>> getRefundsByInvoiceId(int invoiceId);
  Future<List<Refund>> getRefundsByProjectId(int projectId);
  Future<List<Refund>> getAllRefunds();
  Future<double> getRefundedQuantityByInvoiceItemId(int invoiceItemId);
  Future<void> validateRefund(int refundId);
  Future<String> generateNextRefundNumber();
  Future<double> calculateInvoiceNetAmount(int invoiceId);
  Future<double> calculateProjectProfitability(int projectId);
}
