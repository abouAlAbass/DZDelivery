import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/entities/business_profile.dart';

part 'settings_providers.g.dart';

@riverpod
SettingsRepository settingsRepository(SettingsRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return SettingsRepositoryImpl(db);
}

@riverpod
Stream<BusinessProfile?> businessProfile(BusinessProfileRef ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.watchBusinessProfile();
}
