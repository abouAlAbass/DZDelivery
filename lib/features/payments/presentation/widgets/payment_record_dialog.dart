import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hissab_dz/features/invoices/domain/entities/invoice.dart';
import 'package:hissab_dz/features/invoices/domain/entities/invoice_status.dart';
import 'package:hissab_dz/features/invoices/presentation/providers/invoice_providers.dart';
import 'package:hissab_dz/features/payments/domain/entities/payment.dart';
import 'package:hissab_dz/features/payments/presentation/providers/payment_providers.dart';
import 'package:hissab_dz/features/payments/data/repositories/payment_repository.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';

class PaymentRecordDialog extends ConsumerStatefulWidget {
  final Invoice invoice;

  const PaymentRecordDialog({super.key, required this.invoice});

  @override
  ConsumerState<PaymentRecordDialog> createState() => _PaymentRecordDialogState();
}

class _PaymentRecordDialogState extends ConsumerState<PaymentRecordDialog> {
  late final TextEditingController _amountController;
  final _notesController = TextEditingController();
  String _selectedMethod = 'cash';
  bool _isSaving = false;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(symbol: l10n.currencySymbol);
    final paymentsAsync = ref.watch(invoicePaymentsProvider(widget.invoice.id!));

    return paymentsAsync.when(
      data: (payments) {
        final totalPaid = payments.fold(0.0, (sum, p) => sum + p.amount);
        final remaining = widget.invoice.total - totalPaid;
        final outstanding = remaining < 0 ? 0.0 : remaining;

        if (!_isInitialized) {
          _amountController.text = outstanding.toStringAsFixed(2);
          _isInitialized = true;
        }

        return AlertDialog(
          title: Text(l10n.recordPayment),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${l10n.outstanding}: ${currencyFormat.format(outstanding)}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n.paymentAmount,
                    prefixText: '${l10n.currencySymbol} ',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() => _errorMessage = null);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedMethod,
                  decoration: InputDecoration(
                    labelText: l10n.paymentMethod,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'cash',
                      child: Text(l10n.cash),
                    ),
                    DropdownMenuItem(
                      value: 'transfer',
                      child: Text(l10n.transfer),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedMethod = val;
                        _errorMessage = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: l10n.notesOptional,
                    hintText: l10n.paymentNotesHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(20),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red.withAlpha(100)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: _isSaving ? null : () => _savePayment(outstanding),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.record),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, st) => AlertDialog(
        title: Text(l10n.error),
        content: Text(e.toString()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _savePayment(double maxAmount) async {
    final amountText = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(amountText) ?? 0;
    
    if (amount <= 0) return;

    final l10n = AppLocalizations.of(context)!;

    if (amount > (maxAmount + 0.01)) {
      setState(() => _errorMessage = l10n.errorPaymentExceedsBalance);
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final payment = Payment(
        invoiceId: widget.invoice.id!,
        clientId: widget.invoice.clientId,
        amount: amount,
        date: DateTime.now(),
        method: _selectedMethod,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await ref.read(paymentRepositoryProvider).addPayment(payment);

      final payments = await ref.read(invoicePaymentsProvider(widget.invoice.id!).future);
      final totalPaid = payments.fold(0.0, (sum, p) => sum + p.amount);

      final newStatus =
          totalPaid >= widget.invoice.total ? InvoiceStatus.paid : widget.invoice.status;

      final updatedInvoice = widget.invoice.copyWith(status: newStatus);
      await ref.read(invoiceRepositoryProvider).updateInvoice(updatedInvoice);

      // Invalidate providers to refresh UI
      ref.invalidate(invoicePaymentsProvider(widget.invoice.id!));
      ref.invalidate(invoicesListProvider);
      ref.invalidate(filteredInvoicesProvider);
      ref.invalidate(invoiceByIdProvider(widget.invoice.id!));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${l10n.paymentRecorded}: ${NumberFormat.currency(symbol: l10n.currencySymbol).format(amount)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '${l10n.error}: $e';
          _isSaving = false;
        });
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
