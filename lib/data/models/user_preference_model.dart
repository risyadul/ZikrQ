import 'package:isar/isar.dart';

part 'user_preference_model.g.dart';

@Collection()
class UserPreferenceModel {
  Id id = Isar.autoIncrement;

  late bool onboardingCompleted;
  late bool notificationsPermissionRequested;
  late bool soundEnabled;
  late bool vibrationEnabled;
  late DateTime updatedAt;
  late int localChangeVersion;
}
