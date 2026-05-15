import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hissab_dz/features/clients/domain/entities/client.dart';
import 'package:hissab_dz/features/invoices/domain/entities/invoice.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

@freezed
class Payment with _$Payment {
  const factory Payment({
    int? id,
    required int invoiceId,
    required int clientId,
    required double amount,
    required DateTime date,
    String? method,
    String? notes,
    // Joined data
    Client? client,
    Invoice? invoice,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
}
