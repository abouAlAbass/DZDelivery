// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_details_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$articleDetailsHash() => r'62042027759ca6b0afa42fd98f014e2c857e2c1d';

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

/// See also [articleDetails].
@ProviderFor(articleDetails)
const articleDetailsProvider = ArticleDetailsFamily();

/// See also [articleDetails].
class ArticleDetailsFamily extends Family<AsyncValue<Article?>> {
  /// See also [articleDetails].
  const ArticleDetailsFamily();

  /// See also [articleDetails].
  ArticleDetailsProvider call(int articleId) {
    return ArticleDetailsProvider(articleId);
  }

  @override
  ArticleDetailsProvider getProviderOverride(
    covariant ArticleDetailsProvider provider,
  ) {
    return call(provider.articleId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'articleDetailsProvider';
}

/// See also [articleDetails].
class ArticleDetailsProvider extends AutoDisposeFutureProvider<Article?> {
  /// See also [articleDetails].
  ArticleDetailsProvider(int articleId)
    : this._internal(
        (ref) => articleDetails(ref as ArticleDetailsRef, articleId),
        from: articleDetailsProvider,
        name: r'articleDetailsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$articleDetailsHash,
        dependencies: ArticleDetailsFamily._dependencies,
        allTransitiveDependencies:
            ArticleDetailsFamily._allTransitiveDependencies,
        articleId: articleId,
      );

  ArticleDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.articleId,
  }) : super.internal();

  final int articleId;

  @override
  Override overrideWith(
    FutureOr<Article?> Function(ArticleDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ArticleDetailsProvider._internal(
        (ref) => create(ref as ArticleDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        articleId: articleId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Article?> createElement() {
    return _ArticleDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ArticleDetailsProvider && other.articleId == articleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, articleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ArticleDetailsRef on AutoDisposeFutureProviderRef<Article?> {
  /// The parameter `articleId` of this provider.
  int get articleId;
}

class _ArticleDetailsProviderElement
    extends AutoDisposeFutureProviderElement<Article?>
    with ArticleDetailsRef {
  _ArticleDetailsProviderElement(super.provider);

  @override
  int get articleId => (origin as ArticleDetailsProvider).articleId;
}

String _$articleSalesFilteredHash() =>
    r'0a39d13bac837644998db5759a6e173e42701447';

/// See also [articleSalesFiltered].
@ProviderFor(articleSalesFiltered)
const articleSalesFilteredProvider = ArticleSalesFilteredFamily();

/// See also [articleSalesFiltered].
class ArticleSalesFilteredFamily
    extends Family<AsyncValue<List<EnrichedSaleItem>>> {
  /// See also [articleSalesFiltered].
  const ArticleSalesFilteredFamily();

  /// See also [articleSalesFiltered].
  ArticleSalesFilteredProvider call(int articleId) {
    return ArticleSalesFilteredProvider(articleId);
  }

  @override
  ArticleSalesFilteredProvider getProviderOverride(
    covariant ArticleSalesFilteredProvider provider,
  ) {
    return call(provider.articleId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'articleSalesFilteredProvider';
}

/// See also [articleSalesFiltered].
class ArticleSalesFilteredProvider
    extends AutoDisposeStreamProvider<List<EnrichedSaleItem>> {
  /// See also [articleSalesFiltered].
  ArticleSalesFilteredProvider(int articleId)
    : this._internal(
        (ref) =>
            articleSalesFiltered(ref as ArticleSalesFilteredRef, articleId),
        from: articleSalesFilteredProvider,
        name: r'articleSalesFilteredProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$articleSalesFilteredHash,
        dependencies: ArticleSalesFilteredFamily._dependencies,
        allTransitiveDependencies:
            ArticleSalesFilteredFamily._allTransitiveDependencies,
        articleId: articleId,
      );

  ArticleSalesFilteredProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.articleId,
  }) : super.internal();

  final int articleId;

  @override
  Override overrideWith(
    Stream<List<EnrichedSaleItem>> Function(ArticleSalesFilteredRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ArticleSalesFilteredProvider._internal(
        (ref) => create(ref as ArticleSalesFilteredRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        articleId: articleId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<EnrichedSaleItem>> createElement() {
    return _ArticleSalesFilteredProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ArticleSalesFilteredProvider &&
        other.articleId == articleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, articleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ArticleSalesFilteredRef
    on AutoDisposeStreamProviderRef<List<EnrichedSaleItem>> {
  /// The parameter `articleId` of this provider.
  int get articleId;
}

class _ArticleSalesFilteredProviderElement
    extends AutoDisposeStreamProviderElement<List<EnrichedSaleItem>>
    with ArticleSalesFilteredRef {
  _ArticleSalesFilteredProviderElement(super.provider);

  @override
  int get articleId => (origin as ArticleSalesFilteredProvider).articleId;
}

String _$articlePurchasesFilteredHash() =>
    r'aeecf0ed85bd1453aa5ee593d89890b76f0ffab7';

/// See also [articlePurchasesFiltered].
@ProviderFor(articlePurchasesFiltered)
const articlePurchasesFilteredProvider = ArticlePurchasesFilteredFamily();

/// See also [articlePurchasesFiltered].
class ArticlePurchasesFilteredFamily
    extends Family<AsyncValue<List<EnrichedPurchaseItem>>> {
  /// See also [articlePurchasesFiltered].
  const ArticlePurchasesFilteredFamily();

  /// See also [articlePurchasesFiltered].
  ArticlePurchasesFilteredProvider call(int articleId) {
    return ArticlePurchasesFilteredProvider(articleId);
  }

  @override
  ArticlePurchasesFilteredProvider getProviderOverride(
    covariant ArticlePurchasesFilteredProvider provider,
  ) {
    return call(provider.articleId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'articlePurchasesFilteredProvider';
}

/// See also [articlePurchasesFiltered].
class ArticlePurchasesFilteredProvider
    extends AutoDisposeStreamProvider<List<EnrichedPurchaseItem>> {
  /// See also [articlePurchasesFiltered].
  ArticlePurchasesFilteredProvider(int articleId)
    : this._internal(
        (ref) => articlePurchasesFiltered(
          ref as ArticlePurchasesFilteredRef,
          articleId,
        ),
        from: articlePurchasesFilteredProvider,
        name: r'articlePurchasesFilteredProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$articlePurchasesFilteredHash,
        dependencies: ArticlePurchasesFilteredFamily._dependencies,
        allTransitiveDependencies:
            ArticlePurchasesFilteredFamily._allTransitiveDependencies,
        articleId: articleId,
      );

  ArticlePurchasesFilteredProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.articleId,
  }) : super.internal();

  final int articleId;

  @override
  Override overrideWith(
    Stream<List<EnrichedPurchaseItem>> Function(
      ArticlePurchasesFilteredRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ArticlePurchasesFilteredProvider._internal(
        (ref) => create(ref as ArticlePurchasesFilteredRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        articleId: articleId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<EnrichedPurchaseItem>> createElement() {
    return _ArticlePurchasesFilteredProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ArticlePurchasesFilteredProvider &&
        other.articleId == articleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, articleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ArticlePurchasesFilteredRef
    on AutoDisposeStreamProviderRef<List<EnrichedPurchaseItem>> {
  /// The parameter `articleId` of this provider.
  int get articleId;
}

class _ArticlePurchasesFilteredProviderElement
    extends AutoDisposeStreamProviderElement<List<EnrichedPurchaseItem>>
    with ArticlePurchasesFilteredRef {
  _ArticlePurchasesFilteredProviderElement(super.provider);

  @override
  int get articleId => (origin as ArticlePurchasesFilteredProvider).articleId;
}

String _$articleStockMovementsFilteredHash() =>
    r'6f6c36ff4e12c7b642d38332e699287ba3bd1cbe';

/// See also [articleStockMovementsFiltered].
@ProviderFor(articleStockMovementsFiltered)
const articleStockMovementsFilteredProvider =
    ArticleStockMovementsFilteredFamily();

/// See also [articleStockMovementsFiltered].
class ArticleStockMovementsFilteredFamily
    extends Family<AsyncValue<List<EnrichedStockMovement>>> {
  /// See also [articleStockMovementsFiltered].
  const ArticleStockMovementsFilteredFamily();

  /// See also [articleStockMovementsFiltered].
  ArticleStockMovementsFilteredProvider call(int articleId) {
    return ArticleStockMovementsFilteredProvider(articleId);
  }

  @override
  ArticleStockMovementsFilteredProvider getProviderOverride(
    covariant ArticleStockMovementsFilteredProvider provider,
  ) {
    return call(provider.articleId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'articleStockMovementsFilteredProvider';
}

/// See also [articleStockMovementsFiltered].
class ArticleStockMovementsFilteredProvider
    extends AutoDisposeStreamProvider<List<EnrichedStockMovement>> {
  /// See also [articleStockMovementsFiltered].
  ArticleStockMovementsFilteredProvider(int articleId)
    : this._internal(
        (ref) => articleStockMovementsFiltered(
          ref as ArticleStockMovementsFilteredRef,
          articleId,
        ),
        from: articleStockMovementsFilteredProvider,
        name: r'articleStockMovementsFilteredProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$articleStockMovementsFilteredHash,
        dependencies: ArticleStockMovementsFilteredFamily._dependencies,
        allTransitiveDependencies:
            ArticleStockMovementsFilteredFamily._allTransitiveDependencies,
        articleId: articleId,
      );

  ArticleStockMovementsFilteredProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.articleId,
  }) : super.internal();

  final int articleId;

  @override
  Override overrideWith(
    Stream<List<EnrichedStockMovement>> Function(
      ArticleStockMovementsFilteredRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ArticleStockMovementsFilteredProvider._internal(
        (ref) => create(ref as ArticleStockMovementsFilteredRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        articleId: articleId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<EnrichedStockMovement>>
  createElement() {
    return _ArticleStockMovementsFilteredProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ArticleStockMovementsFilteredProvider &&
        other.articleId == articleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, articleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ArticleStockMovementsFilteredRef
    on AutoDisposeStreamProviderRef<List<EnrichedStockMovement>> {
  /// The parameter `articleId` of this provider.
  int get articleId;
}

class _ArticleStockMovementsFilteredProviderElement
    extends AutoDisposeStreamProviderElement<List<EnrichedStockMovement>>
    with ArticleStockMovementsFilteredRef {
  _ArticleStockMovementsFilteredProviderElement(super.provider);

  @override
  int get articleId =>
      (origin as ArticleStockMovementsFilteredProvider).articleId;
}

String _$articleDetailsDateFilterHash() =>
    r'2992db2a06160d7311072aba1d2014d855481fd9';

/// See also [ArticleDetailsDateFilter].
@ProviderFor(ArticleDetailsDateFilter)
final articleDetailsDateFilterProvider =
    AutoDisposeNotifierProvider<
      ArticleDetailsDateFilter,
      DateTimeRange?
    >.internal(
      ArticleDetailsDateFilter.new,
      name: r'articleDetailsDateFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$articleDetailsDateFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ArticleDetailsDateFilter = AutoDisposeNotifier<DateTimeRange?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
