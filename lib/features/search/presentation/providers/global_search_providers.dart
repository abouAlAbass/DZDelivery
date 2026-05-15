import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hissab_dz/features/search/data/repositories/global_search_repository.dart';
import 'package:hissab_dz/features/search/domain/entities/global_search_result.dart';

final globalSearchQueryProvider = StateProvider<String>((ref) => '');

final globalSearchResultsProvider =
    FutureProvider.autoDispose<List<GlobalSearchResult>>((ref) {
      final query = ref.watch(globalSearchQueryProvider);
      return ref.watch(globalSearchRepositoryProvider).search(query);
    });
