import '../../domain/entities/client.dart';

abstract class ClientRepository {
  Future<List<Client>> getClients();
  Stream<List<Client>> watchClients();
  Future<Client?> getClientById(int id);
  Future<int> createClient(Client client);
  Future<void> updateClient(Client client);
  Future<void> deleteClient(int id);
  Future<List<Client>> searchClients(String query);
}
