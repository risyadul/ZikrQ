import 'package:meta/meta.dart';

@immutable
class UserPreference {
  const UserPreference({
    required this.onboardingCompleted,
    required this.notificationsPermissionRequested,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.updatedAt,
    required this.localChangeVersion,
  });

  final bool onboardingCompleted;
  final bool notificationsPermissionRequested;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final DateTime updatedAt;
  final int localChangeVersion;

  UserPreference copyWith({
    bool? onboardingCompleted,
    bool? notificationsPermissionRequested,
    bool? soundEnabled,
    bool? vibrationEnabled,
    DateTime? updatedAt,
    int? localChangeVersion,
  }) => UserPreference(
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    notificationsPermissionRequested:
        notificationsPermissionRequested ??
        this.notificationsPermissionRequested,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    updatedAt: updatedAt ?? this.updatedAt,
    localChangeVersion: localChangeVersion ?? this.localChangeVersion,
  );

  @override
  bool operator ==(Object other) =>
      other is UserPreference &&
      other.onboardingCompleted == onboardingCompleted &&
      other.notificationsPermissionRequested ==
          notificationsPermissionRequested &&
      other.soundEnabled == soundEnabled &&
      other.vibrationEnabled == vibrationEnabled &&
      other.updatedAt == updatedAt &&
      other.localChangeVersion == localChangeVersion;

  @override
  int get hashCode => Object.hash(
    onboardingCompleted,
    notificationsPermissionRequested,
    soundEnabled,
    vibrationEnabled,
    updatedAt,
    localChangeVersion,
  );
}
