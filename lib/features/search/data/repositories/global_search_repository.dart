import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hissab_dz/core/database/database.dart';
import 'package:hissab_dz/core/database/database_provider.dart';
import 'package:hissab_dz/features/search/domain/entities/global_search_result.dart';

abstract class GlobalSearchRepository {
  Future<List<GlobalSearchResult>> search(String query);
}

class GlobalSearchRepositoryImpl implements GlobalSearchRepository {
  final AppDatabase _db;

  GlobalSearchRepositoryImpl(this._db);

  @override
  Future<List<GlobalSearchResult>> search(String query) async {
    final normalized = query.trim();
    if (normalized.length < 2) return const [];
    final pattern = '%$normalized%';
    final results = <GlobalSearchResult>[];

    final clients =
        await (_db.select(_db.clients)
              ..where(
                (t) =>
                    t.name.like(pattern) |
                    t.email.like(pattern) |
                    t.phone.like(pattern) |
                    t.address.like(pattern),
              )
              ..limit(8))
            .get();
    results.addAll(
      clients.map(
        (client) => GlobalSearchResult(
          type: GlobalSearchType.client,
          id: client.id,
          title: client.name,
          subtitle: [
            client.phone,
            client.email,
            client.address,
          ].whereType<String>().where((value) => value.isNotEmpty).join(' - '),
        ),
      ),
    );

    final invoiceRows =
        await (_db.select(_db.invoices).join([
                leftOuterJoin(
                  _db.clients,
                  _db.clients.id.equalsExp(_db.invoices.clientId),
                ),
              ])
              ..where(
                _db.invoices.invoiceNumber.like(pattern) |
                    _db.invoices.notes.like(pattern) |
                    _db.clients.name.like(pattern),
              )
              ..limit(8))
            .get();
    results.addAll(
      invoiceRows.map((row) {
        final invoice = row.readTable(_db.invoices);
        final client = row.readTableOrNull(_db.clients);
        return GlobalSearchResult(
          type: GlobalSearchType.invoice,
          id: invoice.id,
          title: invoice.invoiceNumber,
          subtitle: client?.name ?? '',
          amount: invoice.total,
          date: invoice.issueDate,
        );
      }),
    );

    final projectRows =
        await (_db.select(_db.projects).join([
                leftOuterJoin(
                  _db.clients,
                  _db.clients.id.equalsExp(_db.projects.clientId),
                ),
              ])
              ..where(
                _db.projects.name.like(pattern) |
                    _db.projects.siteAddress.like(pattern) |
                    _db.projects.description.like(pattern) |
                    _db.clients.name.like(pattern),
              )
              ..limit(8))
            .get();
    results.addAll(
      projectRows.map((row) {
        final project = row.readTable(_db.projects);
        final client = row.readTableOrNull(_db.clients);
        return GlobalSearchResult(
          type: GlobalSearchType.project,
          id: project.id,
          title: project.name,
          subtitle: [
            client?.name,
            project.siteAddress,
          ].whereType<String>().where((value) => value.isNotEmpty).join(' - '),
        );
      }),
    );

    final articles =
        await (_db.select(_db.articles)
              ..where(
                (t) =>
                    t.name.like(pattern) |
                    t.code.like(pattern) |
                    t.unit.like(pattern) |
                    t.category.like(pattern),
              )
              ..limit(8))
            .get();
    results.addAll(
      articles.map(
        (article) => GlobalSearchResult(
          type: GlobalSearchType.article,
          id: article.id,
          title: article.name,
          subtitle: [
            article.code,
            article.unit,
            article.category,
          ].whereType<String>().where((value) => value.isNotEmpty).join(' - '),
          amount: article.price,
          date: article.createdAt,
        ),
      ),
    );

    final paymentRows =
        await (_db.select(_db.payments).join([
                leftOuterJoin(
                  _db.clients,
                  _db.clients.id.equalsExp(_db.payments.clientId),
                ),
                leftOuterJoin(
                  _db.invoices,
                  _db.invoices.id.equalsExp(_db.payments.invoiceId),
                ),
              ])
              ..where(
                _db.payments.method.like(pattern) |
                    _db.payments.notes.like(pattern) |
                    _db.clients.name.like(pattern) |
                    _db.invoices.invoiceNumber.like(pattern),
              )
              ..limit(8))
            .get();
    results.addAll(
      paymentRows.map((row) {
        final payment = row.readTable(_db.payments);
        final client = row.readTableOrNull(_db.clients);
        final invoice = row.readTableOrNull(_db.invoices);
        return GlobalSearchResult(
          type: GlobalSearchType.payment,
          id: payment.invoiceId,
          title: client?.name ?? invoice?.invoiceNumber ?? '',
          subtitle: [
            invoice?.invoiceNumber,
            payment.method,
            payment.notes,
          ].whereType<String>().where((value) => value.isNotEmpty).join(' - '),
          amount: payment.amount,
          date: payment.date,
        );
      }),
    );

    results.sort((a, b) {
      final aDate = a.date ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.date ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return results;
  }
}

final globalSearchRepositoryProvider = Provider<GlobalSearchRepository>((ref) {
  return GlobalSearchRepositoryImpl(ref.watch(appDatabaseProvider));
});
