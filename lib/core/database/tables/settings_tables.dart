import 'package:drift/drift.dart';

class BusinessSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get companyName => text().withLength(min: 1, max: 100)();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get website => text().nullable()();
  TextColumn get logoPath => text().nullable()(); // path to logo image file
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('UserPreferenceData')
class UserPreferences extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get language => text().withDefault(const Constant('en'))();
  TextColumn get themeMode =>
      text().withDefault(const Constant('system'))(); // light, dark, system
}
