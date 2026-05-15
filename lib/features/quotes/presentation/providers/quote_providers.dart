import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hissab_dz/features/quotes/data/repositories/quote_repository.dart';
import 'package:hissab_dz/features/quotes/domain/entities/quote.dart';

final quotesListProvider = StreamProvider<List<Quote>>((ref) {
  return ref.watch(quoteRepositoryProvider).watchQuotes();
});

final quoteByIdProvider = FutureProvider.family<Quote?, int>((ref, id) {
  return ref.watch(quoteRepositoryProvider).getQuoteById(id);
});
