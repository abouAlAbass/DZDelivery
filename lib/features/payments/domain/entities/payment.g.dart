// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentImpl _$$PaymentImplFromJson(Map<String, dynamic> json) =>
    _$PaymentImpl(
      id: (json['id'] as num?)?.toInt(),
      invoiceId: (json['invoiceId'] as num).toInt(),
      clientId: (json['clientId'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      method: json['method'] as String?,
      notes: json['notes'] as String?,
      client: json['client'] == null
          ? null
          : Client.fromJson(json['client'] as Map<String, dynamic>),
      invoice: json['invoice'] == null
          ? null
          : Invoice.fromJson(json['invoice'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PaymentImplToJson(_$PaymentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoiceId': instance.invoiceId,
      'clientId': instance.clientId,
      'amount': instance.amount,
      'date': instance.date.toIso8601String(),
      'method': instance.method,
      'notes': instance.notes,
      'client': instance.client,
      'invoice': instance.invoice,
    };
