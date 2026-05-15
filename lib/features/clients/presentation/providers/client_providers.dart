import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/repositories/client_repository_impl.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';

part 'client_providers.g.dart';

@riverpod
ClientRepository clientRepository(ClientRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return ClientRepositoryImpl(db);
}

@riverpod
Stream<List<Client>> clientsList(ClientsListRef ref) {
  final repository = ref.watch(clientRepositoryProvider);
  return repository.watchClients();
}

@riverpod
class ClientSearch extends _$ClientSearch {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@riverpod
Future<List<Client>> searchedClients(SearchedClientsRef ref) {
  final query = ref.watch(clientSearchProvider);
  final repository = ref.watch(clientRepositoryProvider);
  
  if (query.isEmpty) {
    return ref.watch(clientsListProvider.future);
  }
  
  return repository.searchClients(query);
}
