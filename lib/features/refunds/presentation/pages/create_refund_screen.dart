import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hissab_dz/features/invoices/domain/entities/invoice.dart';
import 'package:hissab_dz/features/invoices/domain/entities/invoice_item.dart';
import 'package:hissab_dz/features/invoices/presentation/providers/invoice_providers.dart';
import 'package:hissab_dz/features/refunds/domain/entities/refund.dart';
import 'package:hissab_dz/features/refunds/domain/entities/refund_item.dart';
import 'package:hissab_dz/features/refunds/presentation/providers/refund_providers.dart';
import 'package:hissab_dz/features/refunds/data/repositories/refund_repository_impl.dart';
import 'package:hissab_dz/features/projects/presentation/providers/project_providers.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';

class CreateRefundScreen extends ConsumerStatefulWidget {
  final int invoiceId;

  const CreateRefundScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<CreateRefundScreen> createState() => _CreateRefundScreenState();
}

class _CreateRefundScreenState extends ConsumerState<CreateRefundScreen> {
  final _reasonController = TextEditingController();
  final Map<int, double> _refundQuantities = {};
  final Map<int, double> _availableQuantities = {};
  bool _isSaving = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final invoiceAsync = ref.watch(invoiceByIdProvider(widget.invoiceId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createRefund),
      ),
      body: invoiceAsync.when(
        data: (invoice) {
          if (invoice == null) return Center(child: Text(l10n.invoiceNotFound));
          return _buildBody(invoice, l10n);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('${l10n.error}: $e')),
      ),
      bottomNavigationBar: invoiceAsync.maybeWhen(
        data: (invoice) => invoice != null ? _buildBottomBar(invoice, l10n) : null,
        orElse: () => null,
      ),
    );
  }

  Widget _buildBody(Invoice invoice, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.invoiceNumberShort} ${invoice.invoiceNumber}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonController,
            decoration: InputDecoration(
              labelText: l10n.refundReason,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.items,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...invoice.items.map((item) => _buildItemRow(item, l10n)),
        ],
      ),
    );
  }

  Widget _buildItemRow(InvoiceItem item, AppLocalizations l10n) {
    final refundedQtyAsync = ref.watch(refundedQuantityProvider(item.id!));
    
    return refundedQtyAsync.when(
      data: (refundedQty) {
        final available = item.quantity - refundedQty;
        _availableQuantities[item.id!] = available;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.quantity}: ${item.quantity} | ${l10n.availableToRefund}: $available',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _refundQuantities[item.id!]?.toString() ?? '0',
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.refundedQuantity,
                          suffixText: '/ $available',
                        ),
                        onChanged: (val) {
                          final qty = double.tryParse(val.replaceAll(',', '.')) ?? 0;
                          if (qty > available) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${l10n.error}: Max $available')),
                            );
                            return;
                          }
                          setState(() {
                            _refundQuantities[item.id!] = qty;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      NumberFormat.currency(symbol: l10n.currencySymbol)
                          .format((_refundQuantities[item.id!] ?? 0) * item.unitPrice),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (e, st) => Text(l10n.error),
    );
  }

  Widget _buildBottomBar(Invoice invoice, AppLocalizations l10n) {
    double totalRefund = 0;
    for (var item in invoice.items) {
      totalRefund += (_refundQuantities[item.id!] ?? 0) * item.unitPrice;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.refundAmount,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '- ${NumberFormat.currency(symbol: l10n.currencySymbol).format(totalRefund)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSaving || totalRefund <= 0 ? null : () => _saveRefund(invoice, totalRefund, l10n),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(l10n.createRefund),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveRefund(Invoice invoice, double totalAmount, AppLocalizations l10n) async {
    setState(() => _isSaving = true);
    try {
      final refundRepo = ref.read(refundRepositoryProvider);
      final refundNumber = await refundRepo.generateNextRefundNumber();
      
      final refundItems = <RefundItem>[];
      _refundQuantities.forEach((itemId, qty) {
        if (qty > 0) {
          final invItem = invoice.items.firstWhere((i) => i.id == itemId);
          refundItems.add(RefundItem(
            invoiceItemId: itemId,
            quantity: qty,
            unitPrice: invItem.unitPrice,
            amount: qty * invItem.unitPrice,
          ));
        }
      });

      final refund = Refund(
        invoiceId: invoice.id!,
        refundNumber: refundNumber,
        date: DateTime.now(),
        reason: _reasonController.text.trim(),
        totalAmount: totalAmount,
        items: refundItems,
        isValidated: true, // Auto-validate for now as requested
      );

      await refundRepo.createRefund(refund);
      
      // Invalidate providers to refresh UI
      ref.invalidate(invoiceRefundsProvider(invoice.id!));
      ref.invalidate(allRefundsProvider); // Refresh global list
      ref.invalidate(invoicesListProvider);
      ref.invalidate(filteredInvoicesProvider);
      ref.invalidate(invoiceByIdProvider(invoice.id!));
      
      if (invoice.projectId != null) {
        ref.invalidate(projectRefundsProvider(invoice.projectId!));
        ref.invalidate(projectDetailsProvider(invoice.projectId!));
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.refundSuccess)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
