import 'package:drift/drift.dart';
import '../../../../core/database/database.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';

class ClientRepositoryImpl implements ClientRepository {
  final AppDatabase _db;

  ClientRepositoryImpl(this._db);

  @override
  Future<List<Client>> getClients() async {
    final results = await _db.select(_db.clients).get();
    return results.map((row) => _mapToEntity(row)).toList();
  }

  @override
  Stream<List<Client>> watchClients() {
    return (_db.select(_db.clients)).watch().map(
      (rows) => rows.map((row) => _mapToEntity(row)).toList(),
    );
  }

  @override
  Future<Client?> getClientById(int id) async {
    final query = _db.select(_db.clients)..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row != null ? _mapToEntity(row) : null;
  }

  @override
  Future<int> createClient(Client client) {
    return _db.into(_db.clients).insert(
      ClientsCompanion.insert(
        name: client.name,
        email: Value(client.email),
        phone: Value(client.phone),
        address: Value(client.address),
      ),
    );
  }

  @override
  Future<void> updateClient(Client client) {
    return _db.update(_db.clients).replace(
      ClientsCompanion(
        id: Value(client.id!),
        name: Value(client.name),
        email: Value(client.email),
        phone: Value(client.phone),
        address: Value(client.address),
      ),
    );
  }

  @override
  Future<void> deleteClient(int id) async {
    // Check if client has invoices
    final invoicesCount = await (_db.select(_db.invoices)..where((t) => t.clientId.equals(id))).get();
    if (invoicesCount.isNotEmpty) {
      throw Exception('HAS_INVOICES');
    }

    // Check if client has payments
    final paymentsCount = await (_db.select(_db.payments)..where((t) => t.clientId.equals(id))).get();
    if (paymentsCount.isNotEmpty) {
      throw Exception('HAS_PAYMENTS');
    }

    // Delete quotes associated with this client
    // Note: quote_items will be deleted by cascade in database
    await (_db.delete(_db.quotes)..where((t) => t.clientId.equals(id))).go();

    // Finally delete the client
    await (_db.delete(_db.clients)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<Client>> searchClients(String query) async {
    final search = _db.select(_db.clients)..where((t) => t.name.like('%$query%') | t.email.like('%$query%'));
    final results = await search.get();
    return results.map((row) => _mapToEntity(row)).toList();
  }

  Client _mapToEntity(ClientData row) {
    return Client(
      id: row.id,
      name: row.name,
      email: row.email,
      phone: row.phone,
      address: row.address,
      createdAt: row.createdAt,
    );
  }
}
