import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/settings/presentation/providers/settings_providers.dart';

part 'locale_provider.g.dart';

@riverpod
class AppLocale extends _$AppLocale {
  @override
  Locale build() {
    _loadLocale();
    return const Locale('en');
  }

  Future<void> _loadLocale() async {
    final repository = ref.read(settingsRepositoryProvider);
    final prefs = await repository.getUserPreferences();
    if (prefs != null) {
      state = Locale(prefs.language);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final repository = ref.read(settingsRepositoryProvider);
    await repository.saveLanguage(locale.languageCode);
  }
}

const List<Map<String, dynamic>> supportedLocalesInfo = [
  {'locale': Locale('fr'), 'nameKey': 'french', 'native': 'FR'},
  {'locale': Locale('ar'), 'nameKey': 'arabic', 'native': 'AR'},
  {'locale': Locale('en'), 'nameKey': 'english', 'native': 'ENG'},
];
