// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$articleStockOverviewHash() =>
    r'ad5e252c275f6e82cc1535311b55fa1f5c7b6630';

/// See also [articleStockOverview].
@ProviderFor(articleStockOverview)
final articleStockOverviewProvider =
    AutoDisposeStreamProvider<List<ArticleStockOverview>>.internal(
      articleStockOverview,
      name: r'articleStockOverviewProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$articleStockOverviewHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ArticleStockOverviewRef =
    AutoDisposeStreamProviderRef<List<ArticleStockOverview>>;
String _$stockTransfersListHash() =>
    r'86db9a44df34f8c8ac50f7b4548b8d1953cdc08a';

/// See also [stockTransfersList].
@ProviderFor(stockTransfersList)
final stockTransfersListProvider =
    AutoDisposeStreamProvider<List<StockTransfer>>.internal(
      stockTransfersList,
      name: r'stockTransfersListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$stockTransfersListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StockTransfersListRef =
    AutoDisposeStreamProviderRef<List<StockTransfer>>;
String _$depotWarehousesHash() => r'4ba4dec62cc9d337374b1c01a427ec3ae85fd3b3';

/// See also [depotWarehouses].
@ProviderFor(depotWarehouses)
final depotWarehousesProvider =
    AutoDisposeStreamProvider<List<WarehouseData>>.internal(
      depotWarehouses,
      name: r'depotWarehousesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$depotWarehousesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DepotWarehousesRef = AutoDisposeStreamProviderRef<List<WarehouseData>>;
String _$truckWarehousesHash() => r'18478b52acaf3dfde74871eb03c48ef48dc7b6c3';

/// See also [truckWarehouses].
@ProviderFor(truckWarehouses)
final truckWarehousesProvider =
    AutoDisposeStreamProvider<List<WarehouseData>>.internal(
      truckWarehouses,
      name: r'truckWarehousesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$truckWarehousesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TruckWarehousesRef = AutoDisposeStreamProviderRef<List<WarehouseData>>;
String _$warehouseArticleStockHash() =>
    r'f3d2fadfda943220babadd2faad63bce99bc3542';

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

/// See also [warehouseArticleStock].
@ProviderFor(warehouseArticleStock)
const warehouseArticleStockProvider = WarehouseArticleStockFamily();

/// See also [warehouseArticleStock].
class WarehouseArticleStockFamily extends Family<AsyncValue<Map<int, double>>> {
  /// See also [warehouseArticleStock].
  const WarehouseArticleStockFamily();

  /// See also [warehouseArticleStock].
  WarehouseArticleStockProvider call(int warehouseId) {
    return WarehouseArticleStockProvider(warehouseId);
  }

  @override
  WarehouseArticleStockProvider getProviderOverride(
    covariant WarehouseArticleStockProvider provider,
  ) {
    return call(provider.warehouseId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'warehouseArticleStockProvider';
}

/// See also [warehouseArticleStock].
class WarehouseArticleStockProvider
    extends AutoDisposeStreamProvider<Map<int, double>> {
  /// See also [warehouseArticleStock].
  WarehouseArticleStockProvider(int warehouseId)
    : this._internal(
        (ref) =>
            warehouseArticleStock(ref as WarehouseArticleStockRef, warehouseId),
        from: warehouseArticleStockProvider,
        name: r'warehouseArticleStockProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$warehouseArticleStockHash,
        dependencies: WarehouseArticleStockFamily._dependencies,
        allTransitiveDependencies:
            WarehouseArticleStockFamily._allTransitiveDependencies,
        warehouseId: warehouseId,
      );

  WarehouseArticleStockProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.warehouseId,
  }) : super.internal();

  final int warehouseId;

  @override
  Override overrideWith(
    Stream<Map<int, double>> Function(WarehouseArticleStockRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WarehouseArticleStockProvider._internal(
        (ref) => create(ref as WarehouseArticleStockRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        warehouseId: warehouseId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Map<int, double>> createElement() {
    return _WarehouseArticleStockProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WarehouseArticleStockProvider &&
        other.warehouseId == warehouseId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, warehouseId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WarehouseArticleStockRef
    on AutoDisposeStreamProviderRef<Map<int, double>> {
  /// The parameter `warehouseId` of this provider.
  int get warehouseId;
}

class _WarehouseArticleStockProviderElement
    extends AutoDisposeStreamProviderElement<Map<int, double>>
    with WarehouseArticleStockRef {
  _WarehouseArticleStockProviderElement(super.provider);

  @override
  int get warehouseId => (origin as WarehouseArticleStockProvider).warehouseId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
