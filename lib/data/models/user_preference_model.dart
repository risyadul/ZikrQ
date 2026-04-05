import 'package:isar/isar.dart';

part 'user_preference_model.g.dart';

@Collection()
class UserPreferenceModel {
  Id id = Isar.autoIncrement;

  late bool onboardingCompleted;
  late bool notificationsPermissionRequested;
  late bool notificationsPermissionGranted;
  late bool soundEnabled;
  late bool vibrationEnabled;
  late int snoozeMinutes;
  late int defaultQuickAction;
  int? lastUsedStatusAction;
  late bool hapticEnabled;
  late DateTime updatedAt;
  late int localChangeVersion;
}
