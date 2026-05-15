// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$clientRepositoryHash() => r'923a5fb88d54b7ea7fc22294c25e7241740eb1df';

/// See also [clientRepository].
@ProviderFor(clientRepository)
final clientRepositoryProvider = AutoDisposeProvider<ClientRepository>.internal(
  clientRepository,
  name: r'clientRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$clientRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ClientRepositoryRef = AutoDisposeProviderRef<ClientRepository>;
String _$clientsListHash() => r'4a588064ec4993307707a56422d3f04a9f5d3d9b';

/// See also [clientsList].
@ProviderFor(clientsList)
final clientsListProvider = AutoDisposeStreamProvider<List<Client>>.internal(
  clientsList,
  name: r'clientsListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$clientsListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ClientsListRef = AutoDisposeStreamProviderRef<List<Client>>;
String _$searchedClientsHash() => r'e468ce7e21798b752a9dff84b7f73b27793a5330';

/// See also [searchedClients].
@ProviderFor(searchedClients)
final searchedClientsProvider =
    AutoDisposeFutureProvider<List<Client>>.internal(
      searchedClients,
      name: r'searchedClientsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$searchedClientsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SearchedClientsRef = AutoDisposeFutureProviderRef<List<Client>>;
String _$clientSearchHash() => r'ce1df0b96d42a5c62adc7a7bb6e430e2b1c7b0c5';

/// See also [ClientSearch].
@ProviderFor(ClientSearch)
final clientSearchProvider =
    AutoDisposeNotifierProvider<ClientSearch, String>.internal(
      ClientSearch.new,
      name: r'clientSearchProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$clientSearchHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ClientSearch = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
