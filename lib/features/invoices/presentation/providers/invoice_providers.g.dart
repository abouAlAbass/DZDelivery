// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$invoiceRepositoryHash() => r'1e3886ea0b3996b372e0f3818ffe6413c5cda73b';

/// See also [invoiceRepository].
@ProviderFor(invoiceRepository)
final invoiceRepositoryProvider =
    AutoDisposeProvider<InvoiceRepository>.internal(
      invoiceRepository,
      name: r'invoiceRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$invoiceRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InvoiceRepositoryRef = AutoDisposeProviderRef<InvoiceRepository>;
String _$invoicesListHash() => r'fa87ebe132f09548c56fe72b0e686bbff15c0b57';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [invoicesList].
@ProviderFor(invoicesList)
const invoicesListProvider = InvoicesListFamily();

/// See also [invoicesList].
class InvoicesListFamily extends Family<AsyncValue<List<Invoice>>> {
  /// See also [invoicesList].
  const InvoicesListFamily();

  /// See also [invoicesList].
  InvoicesListProvider call({InvoiceStatus? status}) {
    return InvoicesListProvider(status: status);
  }

  @override
  InvoicesListProvider getProviderOverride(
    covariant InvoicesListProvider provider,
  ) {
    return call(status: provider.status);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'invoicesListProvider';
}

/// See also [invoicesList].
class InvoicesListProvider extends AutoDisposeStreamProvider<List<Invoice>> {
  /// See also [invoicesList].
  InvoicesListProvider({InvoiceStatus? status})
    : this._internal(
        (ref) => invoicesList(ref as InvoicesListRef, status: status),
        from: invoicesListProvider,
        name: r'invoicesListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$invoicesListHash,
        dependencies: InvoicesListFamily._dependencies,
        allTransitiveDependencies:
            InvoicesListFamily._allTransitiveDependencies,
        status: status,
      );

  InvoicesListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final InvoiceStatus? status;

  @override
  Override overrideWith(
    Stream<List<Invoice>> Function(InvoicesListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InvoicesListProvider._internal(
        (ref) => create(ref as InvoicesListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Invoice>> createElement() {
    return _InvoicesListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InvoicesListProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin InvoicesListRef on AutoDisposeStreamProviderRef<List<Invoice>> {
  /// The parameter `status` of this provider.
  InvoiceStatus? get status;
}

class _InvoicesListProviderElement
    extends AutoDisposeStreamProviderElement<List<Invoice>>
    with InvoicesListRef {
  _InvoicesListProviderElement(super.provider);

  @override
  InvoiceStatus? get status => (origin as InvoicesListProvider).status;
}

String _$filteredInvoicesHash() => r'b258f7082e08bdf6ebe102781b4fcb3fcebeb912';

/// See also [filteredInvoices].
@ProviderFor(filteredInvoices)
final filteredInvoicesProvider =
    AutoDisposeFutureProvider<List<Invoice>>.internal(
      filteredInvoices,
      name: r'filteredInvoicesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filteredInvoicesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredInvoicesRef = AutoDisposeFutureProviderRef<List<Invoice>>;
String _$invoiceByIdHash() => r'ab9e6377bb958a9598013386802c12dd56e7a2a4';

/// See also [invoiceById].
@ProviderFor(invoiceById)
const invoiceByIdProvider = InvoiceByIdFamily();

/// See also [invoiceById].
class InvoiceByIdFamily extends Family<AsyncValue<Invoice?>> {
  /// See also [invoiceById].
  const InvoiceByIdFamily();

  /// See also [invoiceById].
  InvoiceByIdProvider call(int id) {
    return InvoiceByIdProvider(id);
  }

  @override
  InvoiceByIdProvider getProviderOverride(
    covariant InvoiceByIdProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'invoiceByIdProvider';
}

/// See also [invoiceById].
class InvoiceByIdProvider extends AutoDisposeFutureProvider<Invoice?> {
  /// See also [invoiceById].
  InvoiceByIdProvider(int id)
    : this._internal(
        (ref) => invoiceById(ref as InvoiceByIdRef, id),
        from: invoiceByIdProvider,
        name: r'invoiceByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$invoiceByIdHash,
        dependencies: InvoiceByIdFamily._dependencies,
        allTransitiveDependencies: InvoiceByIdFamily._allTransitiveDependencies,
        id: id,
      );

  InvoiceByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    FutureOr<Invoice?> Function(InvoiceByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InvoiceByIdProvider._internal(
        (ref) => create(ref as InvoiceByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Invoice?> createElement() {
    return _InvoiceByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InvoiceByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin InvoiceByIdRef on AutoDisposeFutureProviderRef<Invoice?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _InvoiceByIdProviderElement
    extends AutoDisposeFutureProviderElement<Invoice?>
    with InvoiceByIdRef {
  _InvoiceByIdProviderElement(super.provider);

  @override
  int get id => (origin as InvoiceByIdProvider).id;
}

String _$invoiceFilterStatusHash() =>
    r'7d266ed96ea5a631a648a7e32f8f8bb14579607d';

/// See also [InvoiceFilterStatus].
@ProviderFor(InvoiceFilterStatus)
final invoiceFilterStatusProvider =
    AutoDisposeNotifierProvider<InvoiceFilterStatus, InvoiceStatus?>.internal(
      InvoiceFilterStatus.new,
      name: r'invoiceFilterStatusProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$invoiceFilterStatusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$InvoiceFilterStatus = AutoDisposeNotifier<InvoiceStatus?>;
String _$invoiceSearchQueryHash() =>
    r'b909eb04442662a8e6a0343d8c0c27369527edfd';

/// See also [InvoiceSearchQuery].
@ProviderFor(InvoiceSearchQuery)
final invoiceSearchQueryProvider =
    AutoDisposeNotifierProvider<InvoiceSearchQuery, String>.internal(
      InvoiceSearchQuery.new,
      name: r'invoiceSearchQueryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$invoiceSearchQueryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$InvoiceSearchQuery = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
