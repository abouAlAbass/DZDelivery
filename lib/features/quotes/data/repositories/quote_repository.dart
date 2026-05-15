import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hissab_dz/core/database/database.dart' as db;
import 'package:hissab_dz/core/database/database_provider.dart';
import 'package:hissab_dz/features/clients/domain/entities/client.dart';
import 'package:hissab_dz/features/invoices/domain/entities/invoice.dart';
import 'package:hissab_dz/features/invoices/domain/entities/invoice_item.dart';
import 'package:hissab_dz/features/invoices/domain/entities/invoice_status.dart';
import 'package:hissab_dz/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:hissab_dz/features/invoices/presentation/providers/invoice_providers.dart';
import 'package:hissab_dz/features/quotes/domain/entities/quote.dart';
import 'package:hissab_dz/features/quotes/domain/entities/quote_item.dart';
import 'package:hissab_dz/features/quotes/domain/entities/quote_status.dart';

abstract class QuoteRepository {
  Stream<List<Quote>> watchQuotes();
  Future<Quote?> getQuoteById(int id);
  Future<int> createQuote(Quote quote);
  Future<void> updateQuote(Quote quote);
  Future<void> updateQuoteStatus(
    int id,
    QuoteStatus status, {
    String? approvalName,
  });
  Future<int> convertToInvoice(int quoteId);
  Future<void> deleteQuote(int id);
  Future<String> generateNextQuoteNumber();
}

class QuoteRepositoryImpl implements QuoteRepository {
  final db.AppDatabase _database;
  final InvoiceRepository _invoiceRepository;

  QuoteRepositoryImpl(this._database, this._invoiceRepository);

  @override
  Stream<List<Quote>> watchQuotes() {
    final query = _database.select(_database.quotes).join([
      leftOuterJoin(
        _database.clients,
        _database.clients.id.equalsExp(_database.quotes.clientId),
      ),
      leftOuterJoin(
        _database.projects,
        _database.projects.id.equalsExp(_database.quotes.projectId),
      ),
    ])..orderBy([OrderingTerm.desc(_database.quotes.createdAt)]);

    return query.watch().asyncMap(
      (rows) => Future.wait(
        rows.map((row) async {
          final quoteRow = row.readTable(_database.quotes);
          final clientRow = row.readTableOrNull(_database.clients);
          final projectRow = row.readTableOrNull(_database.projects);
          final items = await _getQuoteItems(quoteRow.id);
          return _mapToEntity(quoteRow, clientRow, projectRow, items);
        }),
      ),
    );
  }

  @override
  Future<Quote?> getQuoteById(int id) async {
    final query = _database.select(_database.quotes).join([
      leftOuterJoin(
        _database.clients,
        _database.clients.id.equalsExp(_database.quotes.clientId),
      ),
      leftOuterJoin(
        _database.projects,
        _database.projects.id.equalsExp(_database.quotes.projectId),
      ),
    ])..where(_database.quotes.id.equals(id));

    final row = await query.getSingleOrNull();
    if (row == null) return null;

    final quoteRow = row.readTable(_database.quotes);
    final clientRow = row.readTableOrNull(_database.clients);
    final projectRow = row.readTableOrNull(_database.projects);
    final items = await _getQuoteItems(quoteRow.id);
    return _mapToEntity(quoteRow, clientRow, projectRow, items);
  }

  @override
  Future<int> createQuote(Quote quote) {
    final quoteToSave = quote.recalculateTotals();
    return _database.transaction(() async {
      final quoteId = await _database
          .into(_database.quotes)
          .insert(
            db.QuotesCompanion.insert(
              clientId: quoteToSave.clientId,
              projectId: Value(quoteToSave.projectId),
              quoteNumber: quoteToSave.quoteNumber,
              status: quoteToSave.status,
              issueDate: quoteToSave.issueDate,
              validUntil: Value(quoteToSave.validUntil),
              notes: Value(quoteToSave.notes),
              approvalName: Value(quoteToSave.approvalName),
              approvedAt: Value(quoteToSave.approvedAt),
              subtotal: Value(quoteToSave.subtotal),
              taxRate: Value(quoteToSave.taxRate),
              discountAmount: Value(quoteToSave.discountAmount),
              total: Value(quoteToSave.total),
              convertedInvoiceId: Value(quoteToSave.convertedInvoiceId),
            ),
          );

      await _insertItems(quoteId, quoteToSave.items);
      return quoteId;
    });
  }

  @override
  Future<void> updateQuote(Quote quote) {
    final quoteToSave = quote.recalculateTotals();
    return _database.transaction(() async {
      await (_database.update(
        _database.quotes,
      )..where((t) => t.id.equals(quoteToSave.id!))).write(
        db.QuotesCompanion(
          clientId: Value(quoteToSave.clientId),
          projectId: Value(quoteToSave.projectId),
          quoteNumber: Value(quoteToSave.quoteNumber),
          status: Value(quoteToSave.status),
          issueDate: Value(quoteToSave.issueDate),
          validUntil: Value(quoteToSave.validUntil),
          notes: Value(quoteToSave.notes),
          approvalName: Value(quoteToSave.approvalName),
          approvedAt: Value(quoteToSave.approvedAt),
          subtotal: Value(quoteToSave.subtotal),
          taxRate: Value(quoteToSave.taxRate),
          discountAmount: Value(quoteToSave.discountAmount),
          total: Value(quoteToSave.total),
          convertedInvoiceId: Value(quoteToSave.convertedInvoiceId),
          updatedAt: Value(DateTime.now()),
        ),
      );

      await (_database.delete(
        _database.quoteItems,
      )..where((t) => t.quoteId.equals(quoteToSave.id!))).go();
      await _insertItems(quoteToSave.id!, quoteToSave.items);
    });
  }

  @override
  Future<void> updateQuoteStatus(
    int id,
    QuoteStatus status, {
    String? approvalName,
  }) {
    return (_database.update(
      _database.quotes,
    )..where((t) => t.id.equals(id))).write(
      db.QuotesCompanion(
        status: Value(status),
        approvalName: Value(approvalName),
        approvedAt: Value(
          status == QuoteStatus.accepted ? DateTime.now() : null,
        ),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<int> convertToInvoice(int quoteId) {
    return _database.transaction(() async {
      final quote = await getQuoteById(quoteId);
      if (quote == null) {
        throw StateError('Quote not found');
      }
      if (quote.convertedInvoiceId != null) return quote.convertedInvoiceId!;

      final invoiceNumber = await _invoiceRepository
          .generateNextInvoiceNumber();
      final invoice = Invoice(
        clientId: quote.clientId,
        projectId: quote.projectId,
        invoiceNumber: invoiceNumber,
        status: InvoiceStatus.draft,
        issueDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 30)),
        notes: quote.notes,
        subtotal: quote.subtotal,
        taxRate: quote.taxRate,
        discountAmount: quote.discountAmount,
        total: quote.total,
        items: quote.items
            .map(
              (item) => InvoiceItem(
                invoiceId: 0,
                description: item.description,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                amount: item.amount,
              ),
            )
            .toList(),
      );

      final invoiceId = await _invoiceRepository.createInvoice(invoice);
      await (_database.update(
        _database.quotes,
      )..where((t) => t.id.equals(quoteId))).write(
        db.QuotesCompanion(
          status: const Value(QuoteStatus.converted),
          convertedInvoiceId: Value(invoiceId),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return invoiceId;
    });
  }

  @override
  Future<void> deleteQuote(int id) {
    return (_database.delete(
      _database.quotes,
    )..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<String> generateNextQuoteNumber() async {
    final query = _database.select(_database.quotes)
      ..orderBy([(t) => OrderingTerm.desc(t.id)])
      ..limit(1);
    final lastQuote = await query.getSingleOrNull();
    if (lastQuote == null) return 'DEV-0001';

    final lastNumber = int.tryParse(lastQuote.quoteNumber.split('-').last) ?? 0;
    return 'DEV-${(lastNumber + 1).toString().padLeft(4, '0')}';
  }

  Future<void> _insertItems(int quoteId, List<QuoteItem> items) async {
    for (final item in items) {
      await _database
          .into(_database.quoteItems)
          .insert(
            db.QuoteItemsCompanion.insert(
              quoteId: quoteId,
              description: item.description,
              quantity: Value(item.quantity),
              unitPrice: Value(item.unitPrice),
              amount: Value(item.amount),
            ),
          );
    }
  }

  Future<List<QuoteItem>> _getQuoteItems(int quoteId) async {
    final rows = await (_database.select(
      _database.quoteItems,
    )..where((t) => t.quoteId.equals(quoteId))).get();
    return rows
        .map(
          (row) => QuoteItem(
            id: row.id,
            quoteId: row.quoteId,
            description: row.description,
            quantity: row.quantity,
            unitPrice: row.unitPrice,
            amount: row.amount,
          ),
        )
        .toList();
  }

  Quote _mapToEntity(
    db.QuoteData quoteRow,
    db.ClientData? clientRow,
    db.ProjectData? projectRow,
    List<QuoteItem> items,
  ) {
    return Quote(
      id: quoteRow.id,
      clientId: quoteRow.clientId,
      projectId: quoteRow.projectId,
      quoteNumber: quoteRow.quoteNumber,
      status: quoteRow.status,
      issueDate: quoteRow.issueDate,
      validUntil: quoteRow.validUntil,
      notes: quoteRow.notes,
      approvalName: quoteRow.approvalName,
      approvedAt: quoteRow.approvedAt,
      subtotal: quoteRow.subtotal,
      taxRate: quoteRow.taxRate,
      discountAmount: quoteRow.discountAmount,
      total: quoteRow.total,
      convertedInvoiceId: quoteRow.convertedInvoiceId,
      createdAt: quoteRow.createdAt,
      updatedAt: quoteRow.updatedAt,
      items: items,
      projectName: projectRow?.name,
      client: clientRow == null
          ? null
          : Client(
              id: clientRow.id,
              name: clientRow.name,
              email: clientRow.email,
              phone: clientRow.phone,
              address: clientRow.address,
            ),
    );
  }
}

final quoteRepositoryProvider = Provider<QuoteRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  final invoiceRepository = ref.watch(invoiceRepositoryProvider);
  return QuoteRepositoryImpl(database, invoiceRepository);
});
