import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hissab_dz/features/articles/data/repositories/article_repository.dart';
import 'package:hissab_dz/features/articles/domain/entities/article.dart';

part 'article_providers.g.dart';

@riverpod
Stream<List<Article>> articlesList(ArticlesListRef ref) {
  final repository = ref.watch(articleRepositoryProvider);
  return repository.watchArticles();
}

@riverpod
class ArticleSearchQuery extends _$ArticleSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@riverpod
Stream<List<Article>> filteredArticles(FilteredArticlesRef ref) {
  final articles = ref.watch(articlesListProvider).value ?? [];
  final query = ref.watch(articleSearchQueryProvider).toLowerCase();

  if (query.isEmpty) return Stream.value(articles);

  return Stream.value(articles.where((article) {
    return article.name.toLowerCase().contains(query) ||
        (article.code?.toLowerCase().contains(query) ?? false);
  }).toList());
}
