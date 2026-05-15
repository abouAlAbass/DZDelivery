import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hissab_dz/core/utils/app_formatters.dart';
import '../providers/refund_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/app_drawer.dart';

class RefundListScreen extends ConsumerWidget {
  const RefundListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final refundsAsync = ref.watch(allRefundsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.refunds),
      ),
      drawer: const AppDrawer(),
      body: refundsAsync.when(
        data: (refunds) {
          if (refunds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assignment_return_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noRefundsYet,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: refunds.length,
            itemBuilder: (context, index) {
              final refund = refunds[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () => context.pushNamed(
                    'refund_details',
                    pathParameters: {'id': refund.id!.toString()},
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orangeAccent,
                    child: Icon(Icons.assignment_return, color: Colors.white),
                  ),
                  title: Text(
                    refund.refundNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    l10n.localeName == 'ar'
                        ? DateFormat('dd/MM/yyyy', 'en').format(refund.date)
                        : DateFormat.yMMMd(l10n.localeName).format(refund.date),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '- ${AppFormatters.formatCurrency(refund.totalAmount, l10n)}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (refund.isValidated)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withAlpha(20),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l10n.validated,
                            style: const TextStyle(color: Colors.green, fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('${l10n.error}: $e')),
      ),
    );
  }
}
