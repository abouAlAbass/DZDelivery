// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvoiceImpl _$$InvoiceImplFromJson(Map<String, dynamic> json) =>
    _$InvoiceImpl(
      id: (json['id'] as num?)?.toInt(),
      clientId: (json['clientId'] as num).toInt(),
      projectId: (json['projectId'] as num?)?.toInt(),
      invoiceNumber: json['invoiceNumber'] as String,
      status:
          $enumDecodeNullable(_$InvoiceStatusEnumMap, json['status']) ??
          InvoiceStatus.draft,
      issueDate: DateTime.parse(json['issueDate'] as String),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      lastReminderAt: json['lastReminderAt'] == null
          ? null
          : DateTime.parse(json['lastReminderAt'] as String),
      notes: json['notes'] as String?,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      client: json['client'] == null
          ? null
          : Client.fromJson(json['client'] as Map<String, dynamic>),
      projectName: json['projectName'] as String?,
    );

Map<String, dynamic> _$$InvoiceImplToJson(_$InvoiceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clientId': instance.clientId,
      'projectId': instance.projectId,
      'invoiceNumber': instance.invoiceNumber,
      'status': _$InvoiceStatusEnumMap[instance.status]!,
      'issueDate': instance.issueDate.toIso8601String(),
      'dueDate': instance.dueDate?.toIso8601String(),
      'lastReminderAt': instance.lastReminderAt?.toIso8601String(),
      'notes': instance.notes,
      'subtotal': instance.subtotal,
      'taxRate': instance.taxRate,
      'discountAmount': instance.discountAmount,
      'total': instance.total,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'items': instance.items,
      'client': instance.client,
      'projectName': instance.projectName,
    };

const _$InvoiceStatusEnumMap = {
  InvoiceStatus.draft: 'draft',
  InvoiceStatus.sent: 'sent',
  InvoiceStatus.accepted: 'accepted',
  InvoiceStatus.converted: 'converted',
  InvoiceStatus.paid: 'paid',
  InvoiceStatus.unpaid: 'unpaid',
  InvoiceStatus.cancelled: 'cancelled',
  InvoiceStatus.overdue: 'overdue',
};
