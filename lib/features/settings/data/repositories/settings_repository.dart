import 'package:drift/drift.dart';
import '../../../../core/database/database.dart';
import '../../domain/entities/business_profile.dart';

abstract class SettingsRepository {
  Future<BusinessProfile?> getBusinessProfile();
  Future<void> saveBusinessProfile(BusinessProfile profile);
  Stream<BusinessProfile?> watchBusinessProfile();

  // User Preferences
  Future<UserPreferenceData?> getUserPreferences();
  Future<void> saveLanguage(String language);
  Future<void> saveThemeMode(String themeMode);
}

class SettingsRepositoryImpl implements SettingsRepository {
  final AppDatabase _db;

  SettingsRepositoryImpl(this._db);

  @override
  Future<BusinessProfile?> getBusinessProfile() async {
    final row = await _db.select(_db.businessSettings).getSingleOrNull();
    return row != null ? _mapToEntity(row) : null;
  }

  @override
  Future<void> saveBusinessProfile(BusinessProfile profile) async {
    final companion = BusinessSettingsCompanion(
      companyName: Value(profile.companyName),
      address: Value(profile.address),
      phone: Value(profile.phone),
      email: Value(profile.email),
      website: Value(profile.website),
      logoPath: Value(profile.logoPath),
    );

    final existing = await _db.select(_db.businessSettings).getSingleOrNull();
    if (existing != null) {
      await (_db.update(_db.businessSettings)
            ..where((t) => t.id.equals(existing.id)))
          .write(companion);
    } else {
      await _db.into(_db.businessSettings).insert(companion);
    }
  }

  @override
  Stream<BusinessProfile?> watchBusinessProfile() {
    return _db
        .select(_db.businessSettings)
        .watchSingleOrNull()
        .map((row) => row != null ? _mapToEntity(row) : null);
  }

  @override
  Future<UserPreferenceData?> getUserPreferences() async {
    return await _db.select(_db.userPreferences).getSingleOrNull();
  }

  @override
  Future<void> saveLanguage(String language) async {
    final existing = await getUserPreferences();
    if (existing != null) {
      await (_db.update(_db.userPreferences)
            ..where((t) => t.id.equals(existing.id)))
          .write(UserPreferencesCompanion(language: Value(language)));
    } else {
      await _db
          .into(_db.userPreferences)
          .insert(UserPreferencesCompanion.insert(language: Value(language)));
    }
  }

  @override
  Future<void> saveThemeMode(String themeMode) async {
    final existing = await getUserPreferences();
    if (existing != null) {
      await (_db.update(_db.userPreferences)
            ..where((t) => t.id.equals(existing.id)))
          .write(UserPreferencesCompanion(themeMode: Value(themeMode)));
    } else {
      await _db
          .into(_db.userPreferences)
          .insert(UserPreferencesCompanion.insert(themeMode: Value(themeMode)));
    }
  }

  BusinessProfile _mapToEntity(BusinessSetting row) {
    return BusinessProfile(
      id: row.id,
      companyName: row.companyName,
      address: row.address,
      phone: row.phone,
      email: row.email,
      website: row.website,
      logoPath: row.logoPath,
    );
  }
}
