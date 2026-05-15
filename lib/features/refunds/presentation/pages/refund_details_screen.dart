import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hissab_dz/core/utils/app_formatters.dart';
import 'package:share_plus/share_plus.dart';
import '../../../invoices/presentation/providers/invoice_providers.dart';
import '../../domain/entities/refund.dart';
import '../../data/repositories/refund_repository_impl.dart';
import '../../services/pdf_refund_service.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../../l10n/app_localizations.dart';

class RefundDetailsScreen extends ConsumerWidget {
  final int refundId;

  const RefundDetailsScreen({super.key, required this.refundId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final refundRepo = ref.watch(refundRepositoryProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.refundDetails),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _shareRefundPdf(context, ref, refundId, l10n),
          ),
        ],
      ),
      body: FutureBuilder<Refund?>(
        future: refundRepo.getRefundById(refundId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text(l10n.error));
          }
          
          final refund = snapshot.data!;
          return _buildBody(context, ref, refund, l10n);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, Refund refund, AppLocalizations l10n) {
    final dateFormat = l10n.localeName == 'ar'
        ? DateFormat('dd/MM/yyyy', 'en')
        : DateFormat.yMMMd(l10n.localeName);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow(l10n.refundNumber, refund.refundNumber),
                  const Divider(),
                  _buildDetailRow(l10n.refundDate, dateFormat.format(refund.date)),
                  const Divider(),
                  _buildDetailRow(l10n.refundAmount, '- ${AppFormatters.formatCurrency(refund.totalAmount, l10n)}', isNegative: true),
                ],
              ),
            ),
          ),
          if (refund.reason?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Text(l10n.refundReason, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(refund.reason!),
          ],
          const SizedBox(height: 24),
          Text(l10n.items, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...refund.items.map((item) => ListTile(
            title: Text(item.description ?? ''),
            subtitle: Text(
              l10n.localeName == 'ar'
                  ? '\u200F${l10n.quantity}: ${item.quantity} x ${AppFormatters.formatCurrency(item.unitPrice, l10n)}'
                  : '${l10n.quantity}: ${item.quantity} x ${AppFormatters.formatCurrency(item.unitPrice, l10n)}',
            ),
            trailing: Text('- ${AppFormatters.formatCurrency(item.amount, l10n)}', style: const TextStyle(color: Colors.red)),
          )),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isNegative ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareRefundPdf(BuildContext context, WidgetRef ref, int refundId, AppLocalizations l10n) async {
    try {
      final refundRepo = ref.read(refundRepositoryProvider);
      final refund = await refundRepo.getRefundById(refundId);
      if (refund == null) return;

      final invoice = await ref.read(invoiceByIdProvider(refund.invoiceId).future);
      if (invoice == null) return;

      final profile = await ref.read(businessProfileProvider.future);

      final file = await PdfRefundService.generateRefundPdf(
        refund: refund,
        invoice: invoice,
        profile: profile,
        l10n: l10n,
      );

      await Share.shareXFiles([XFile(file.path)], text: '${l10n.refund} ${refund.refundNumber}');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e')),
        );
      }
    }
  }
}
