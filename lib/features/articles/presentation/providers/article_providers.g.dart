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
