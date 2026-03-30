import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Gagal memuat pengaturan: $error')),
        data: (formState) {
          _draft ??= formState;
          final draft = _draft!;
          final selectedSnoozeMinutes = normalizeSnoozeMinutes(
            draft.snoozeMinutes,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionTitle('Target Ayat Harian'),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: draft.dailyTargetAyat > 1
                        ? () => _update(
                            draft.copyWith(
                              dailyTargetAyat: draft.dailyTargetAyat - 1,
                            ),
                          )
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Expanded(
                    child: Text(
                      '${draft.dailyTargetAyat} ayat / hari',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _update(
                      draft.copyWith(
                        dailyTargetAyat: draft.dailyTargetAyat + 1,
                      ),
                    ),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
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
              const Divider(height: 32),
              _buildSectionTitle('Pengingat Harian'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Aktifkan Pengingat'),
                value: draft.reminderEnabled,
                onChanged: (value) =>
                    _update(draft.copyWith(reminderEnabled: value)),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Waktu Pengingat'),
                subtitle: Text(
                  _formatTime(draft.reminderHour, draft.reminderMinute),
                ),
                trailing: const Icon(Icons.schedule),
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
              const Divider(height: 32),
              _buildSectionTitle('Durasi Snooze (menit)'),
              DropdownButtonFormField<int>(
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
              const Divider(height: 32),
              _buildSectionTitle('Aksi Cepat Default'),
              DropdownButtonFormField<MemorizationStatus>(
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
              const Divider(height: 32),
              _buildSectionTitle('Haptic Feedback'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Aktifkan Haptic Feedback'),
                value: draft.hapticEnabled,
                onChanged: (value) =>
                    _update(draft.copyWith(hapticEnabled: value)),
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
                    : const Icon(Icons.save),
                label: const Text('Simpan Pengaturan'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
        final messenger = ScaffoldMessenger.of(context);
        messenger
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
                      .read(localNotificationServiceProvider)
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
