// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$articlesListHash() => r'29ef9845f6782f89fc2b5333402c75876ca91e9b';

/// See also [articlesList].
@ProviderFor(articlesList)
final articlesListProvider = AutoDisposeStreamProvider<List<Article>>.internal(
  articlesList,
  name: r'articlesListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$articlesListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ArticlesListRef = AutoDisposeStreamProviderRef<List<Article>>;
String _$filteredArticlesHash() => r'b915960985f290c200c00de2d0cf0b752344067f';

/// See also [filteredArticles].
@ProviderFor(filteredArticles)
final filteredArticlesProvider =
    AutoDisposeStreamProvider<List<Article>>.internal(
      filteredArticles,
      name: r'filteredArticlesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filteredArticlesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredArticlesRef = AutoDisposeStreamProviderRef<List<Article>>;
String _$articleStockSummariesHash() =>
    r'd6975dbdbe1614ff3b30736099226207ac60e894';

/// See also [articleStockSummaries].
@ProviderFor(articleStockSummaries)
final articleStockSummariesProvider =
    AutoDisposeStreamProvider<Map<int, ArticleStockSummary>>.internal(
      articleStockSummaries,
      name: r'articleStockSummariesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$articleStockSummariesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ArticleStockSummariesRef =
    AutoDisposeStreamProviderRef<Map<int, ArticleStockSummary>>;
String _$articleStockMovementsHash() =>
    r'cf87cc492bdfd3cdde1d89afcd079c76a658ae88';

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

/// See also [articleStockMovements].
@ProviderFor(articleStockMovements)
const articleStockMovementsProvider = ArticleStockMovementsFamily();

/// See also [articleStockMovements].
class ArticleStockMovementsFamily
    extends Family<AsyncValue<List<EnrichedStockMovement>>> {
  /// See also [articleStockMovements].
  const ArticleStockMovementsFamily();

  /// See also [articleStockMovements].
  ArticleStockMovementsProvider call(int articleId) {
    return ArticleStockMovementsProvider(articleId);
  }

  @override
  ArticleStockMovementsProvider getProviderOverride(
    covariant ArticleStockMovementsProvider provider,
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
  String? get name => r'articleStockMovementsProvider';
}

/// See also [articleStockMovements].
class ArticleStockMovementsProvider
    extends AutoDisposeStreamProvider<List<EnrichedStockMovement>> {
  /// See also [articleStockMovements].
  ArticleStockMovementsProvider(int articleId)
    : this._internal(
        (ref) =>
            articleStockMovements(ref as ArticleStockMovementsRef, articleId),
        from: articleStockMovementsProvider,
        name: r'articleStockMovementsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$articleStockMovementsHash,
        dependencies: ArticleStockMovementsFamily._dependencies,
        allTransitiveDependencies:
            ArticleStockMovementsFamily._allTransitiveDependencies,
        articleId: articleId,
      );

  ArticleStockMovementsProvider._internal(
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
      ArticleStockMovementsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ArticleStockMovementsProvider._internal(
        (ref) => create(ref as ArticleStockMovementsRef),
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
    return _ArticleStockMovementsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ArticleStockMovementsProvider &&
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
mixin ArticleStockMovementsRef
    on AutoDisposeStreamProviderRef<List<EnrichedStockMovement>> {
  /// The parameter `articleId` of this provider.
  int get articleId;
}

class _ArticleStockMovementsProviderElement
    extends AutoDisposeStreamProviderElement<List<EnrichedStockMovement>>
    with ArticleStockMovementsRef {
  _ArticleStockMovementsProviderElement(super.provider);

  @override
  int get articleId => (origin as ArticleStockMovementsProvider).articleId;
}

String _$articleSearchQueryHash() =>
    r'720df2fb968fdcd95770dc1435458531776576ba';

/// See also [ArticleSearchQuery].
@ProviderFor(ArticleSearchQuery)
final articleSearchQueryProvider =
    AutoDisposeNotifierProvider<ArticleSearchQuery, String>.internal(
      ArticleSearchQuery.new,
      name: r'articleSearchQueryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$articleSearchQueryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ArticleSearchQuery = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
