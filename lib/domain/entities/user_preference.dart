import 'package:meta/meta.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';

@immutable
class UserPreference {
  const UserPreference({
    required this.onboardingCompleted,
    required this.notificationsPermissionRequested,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.snoozeMinutes,
    required this.defaultQuickAction,
    required this.hapticEnabled,
    required this.updatedAt,
    required this.localChangeVersion,
  });

  final bool onboardingCompleted;
  final bool notificationsPermissionRequested;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final int snoozeMinutes;
  final MemorizationStatus defaultQuickAction;
  final bool hapticEnabled;
  final DateTime updatedAt;
  final int localChangeVersion;

  UserPreference copyWith({
    bool? onboardingCompleted,
    bool? notificationsPermissionRequested,
    bool? soundEnabled,
    bool? vibrationEnabled,
    int? snoozeMinutes,
    MemorizationStatus? defaultQuickAction,
    bool? hapticEnabled,
    DateTime? updatedAt,
    int? localChangeVersion,
  }) => UserPreference(
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    notificationsPermissionRequested:
        notificationsPermissionRequested ??
        this.notificationsPermissionRequested,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
    defaultQuickAction: defaultQuickAction ?? this.defaultQuickAction,
    hapticEnabled: hapticEnabled ?? this.hapticEnabled,
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
      other.snoozeMinutes == snoozeMinutes &&
      other.defaultQuickAction == defaultQuickAction &&
      other.hapticEnabled == hapticEnabled &&
      other.updatedAt == updatedAt &&
      other.localChangeVersion == localChangeVersion;

  @override
  int get hashCode => Object.hash(
    onboardingCompleted,
    notificationsPermissionRequested,
    soundEnabled,
    vibrationEnabled,
    snoozeMinutes,
    defaultQuickAction,
    hapticEnabled,
    updatedAt,
    localChangeVersion,
  );
}
