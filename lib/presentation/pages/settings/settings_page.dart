import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/core/theme/app_text_styles.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/presentation/providers/core_providers.dart';
import 'package:zikrq/presentation/providers/habit_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  static const _weekdayLabels = <int, String>{
    1: 'Sen',
    2: 'Sel',
    3: 'Rab',
    4: 'Kam',
    5: 'Jum',
    6: 'Sab',
    7: 'Min',
  };

  SettingsFormState? _draft;

  @override
  Widget build(BuildContext context) {
    final formAsync = ref.watch(settingsFormStateProvider);
    final saveState = ref.watch(settingsSaveControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: formAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) =>
            Center(child: Text('Gagal memuat pengaturan: $error')),
        data: (formState) {
          _draft ??= formState;
          final draft = _draft!;
          final selectedSnoozeMinutes = normalizeSnoozeMinutes(
            draft.snoozeMinutes,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _SettingsHero(
                dailyTargetAyat: draft.dailyTargetAyat,
                activeDaysCount: draft.activeDays.length,
                reminderEnabled: draft.reminderEnabled,
              ),
              const SizedBox(height: 20),
              _SettingsCard(
                title: 'Target Ayat Harian',
                subtitle: 'Atur ritme murojaah yang realistis dan konsisten.',
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Row(
                        children: [
                          _StepperButton(
                            icon: Icons.remove_rounded,
                            enabled: draft.dailyTargetAyat > 1,
                            onTap: () => _update(
                              draft.copyWith(
                                dailyTargetAyat: draft.dailyTargetAyat - 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '${draft.dailyTargetAyat}',
                                  style: AppTextStyles.titleLarge.copyWith(
                                    color: AppColors.primary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${draft.dailyTargetAyat} ayat / hari',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.translation,
                                ),
                              ],
                            ),
                          ),
                          _StepperButton(
                            icon: Icons.add_rounded,
                            onTap: () => _update(
                              draft.copyWith(
                                dailyTargetAyat: draft.dailyTargetAyat + 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Hari Aktif',
                        style: AppTextStyles.surahName.copyWith(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _weekdayLabels.entries.map((entry) {
                        final isSelected = draft.activeDays.contains(entry.key);
                        return FilterChip(
                          label: Text(entry.value),
                          selected: isSelected,
                          onSelected: (_) {
                            final days = Set<int>.from(draft.activeDays);
                            if (isSelected) {
                              if (days.length == 1) {
                                return;
                              }
                              days.remove(entry.key);
                            } else {
                              days.add(entry.key);
                            }
                            _update(draft.copyWith(activeDays: days));
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'Pengingat Harian',
                subtitle:
                    'Tetap aktif tanpa membuat alur penggunaan terasa berat.',
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.notifications_active_rounded,
                      title: 'Aktifkan Pengingat',
                      trailing: Switch(
                        value: draft.reminderEnabled,
                        onChanged: (value) =>
                            _update(draft.copyWith(reminderEnabled: value)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SettingsTile(
                      icon: Icons.schedule_rounded,
                      title: 'Waktu Pengingat',
                      subtitle: _formatTime(
                        draft.reminderHour,
                        draft.reminderMinute,
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: draft.reminderHour,
                            minute: draft.reminderMinute,
                          ),
                        );
                        if (picked == null || !mounted) {
                          return;
                        }
                        _update(
                          draft.copyWith(
                            reminderHour: picked.hour,
                            reminderMinute: picked.minute,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'Durasi Snooze (menit)',
                subtitle: 'Beri jeda pendek sebelum pengingat diulang lagi.',
                child: DropdownButtonFormField<int>(
                  initialValue: selectedSnoozeMinutes,
                  items: const [5, 10, 15]
                      .map(
                        (value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value menit'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _update(draft.copyWith(snoozeMinutes: value));
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'Aksi Cepat Default',
                subtitle:
                    'Pilih status yang paling sering dipakai di quick action.',
                child: DropdownButtonFormField<MemorizationStatus>(
                  initialValue: draft.defaultQuickAction,
                  items: MemorizationStatus.values
                      .map(
                        (status) => DropdownMenuItem<MemorizationStatus>(
                          value: status,
                          child: Text(status.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _update(draft.copyWith(defaultQuickAction: value));
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'Haptic Feedback',
                subtitle: 'Tambahkan umpan balik kecil saat interaksi penting.',
                child: _SettingsTile(
                  icon: Icons.vibration_rounded,
                  title: 'Aktifkan Haptic Feedback',
                  trailing: Switch(
                    value: draft.hapticEnabled,
                    onChanged: (value) =>
                        _update(draft.copyWith(hapticEnabled: value)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: saveState.isLoading ? null : () => _save(draft),
                icon: saveState.isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: const Text('Simpan Pengaturan'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _update(SettingsFormState next) {
    setState(() {
      _draft = next;
    });
  }

  Future<void> _save(SettingsFormState draft) async {
    try {
      final result = await ref
          .read(settingsSaveControllerProvider.notifier)
          .save(draft);
      if (!mounted) {
        return;
      }

      if (result == ReminderPermissionRequestResult.deniedCanOpenSettings) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: const Text(
                'Izin notifikasi ditolak. Buka pengaturan sistem untuk mengaktifkannya.',
              ),
              action: SnackBarAction(
                label: 'Buka Pengaturan',
                onPressed: () {
                  ref
                      .read(reminderSchedulerProvider)
                      .openSystemNotificationSettings();
                },
              ),
            ),
          );
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Pengaturan disimpan')));
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Gagal menyimpan: $error')));
    }
  }

  String _formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _SettingsHero extends StatelessWidget {
  const _SettingsHero({
    required this.dailyTargetAyat,
    required this.activeDaysCount,
    required this.reminderEnabled,
  });

  final int dailyTargetAyat;
  final int activeDaysCount;
  final bool reminderEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.16),
            AppColors.surfaceRaised,
            AppColors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rencana & Preferensi', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 8),
          Text(
            'Personalisasi target, reminder, dan interaksi cepat.',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  label: 'Target',
                  value: '$dailyTargetAyat ayat',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroMetric(
                  label: 'Hari aktif',
                  value: '$activeDaysCount hari',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroMetric(
                  label: 'Reminder',
                  value: reminderEnabled ? 'Aktif' : 'Nonaktif',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.surahMeta),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.surahName.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.sectionLabel),
          const SizedBox(height: 6),
          Text(subtitle, style: AppTextStyles.translation),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.surahName.copyWith(fontSize: 14),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle!, style: AppTextStyles.translation),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: enabled ? onTap : null,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surfaceMuted,
        foregroundColor: AppColors.onSurface,
        disabledBackgroundColor: AppColors.surfaceMuted,
      ),
      icon: Icon(icon),
    );
  }
}
