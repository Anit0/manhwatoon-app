import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/reader_models.dart';
import '../downloads/download_manager.dart';
import '../stats/stats_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Header('Appearance'),
          ListTile(
            leading: const Icon(Icons.palette_rounded),
            title: const Text('Theme'),
            subtitle: Text(settings.themeMode.label),
            onTap: () async {
              final mode = await showModalBottomSheet<AppThemeMode>(
                context: context,
                showDragHandle: true,
                builder: (ctx) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: AppThemeMode.values
                        .map((m) => RadioListTile<AppThemeMode>(
                              value: m,
                              groupValue: settings.themeMode,
                              title: Text(m.label),
                              onChanged: (v) => Navigator.pop(ctx, v),
                            ))
                        .toList(),
                  ),
                ),
              );
              if (mode != null) {
                await ref.read(settingsProvider.notifier).setThemeMode(mode);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: const Text('Accent color'),
            subtitle: const Text('Personalize the app color'),
            onTap: () => _pickAccent(context, ref, settings),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.auto_awesome_rounded),
            title: const Text('Material You (dynamic color)'),
            subtitle: const Text('Match your wallpaper colors'),
            value: settings.dynamicColor,
            onChanged: (v) => ref.read(settingsProvider.notifier).setDynamicColor(v),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.visibility_off_rounded),
            title: const Text('Hide adult content'),
            value: settings.hideAdult,
            onChanged: (v) => ref.read(settingsProvider.notifier).setHideAdult(v),
          ),

          const Divider(height: 24),
          _Header('Reader'),
          ListTile(
            leading: const Icon(Icons.import_contacts_rounded),
            title: const Text('Default reading mode'),
            subtitle: Text(settings.readerMode),
            onTap: () => _pickReaderMode(context, ref),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.screen_lock_portrait_rounded),
            title: const Text('Keep screen on'),
            value: settings.readerKeepScreenOn,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setReaderKeepScreenOn(v),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.download_done_rounded),
            title: const Text('Auto-download next chapter'),
            value: settings.autoDownloadNext,
            onChanged: (v) => ref.read(settingsProvider.notifier).setAutoDownloadNext(v),
          ),

          const Divider(height: 24),
          _Header('Home screen'),
          ListTile(
            leading: const Icon(Icons.home_rounded),
            title: const Text('Home sections'),
            subtitle: Text('${settings.homeSections.length} sections enabled'),
            onTap: () => _editHomeSections(context, ref, settings),
          ),

          const Divider(height: 24),
          _Header('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_rounded),
            title: const Text('Notifications'),
            value: settings.notificationsEnabled,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setNotificationsEnabled(v),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.alarm_rounded),
            title: const Text('Reading reminder'),
            value: settings.readingReminderEnabled,
            onChanged: (v) => ref
                .read(settingsProvider.notifier)
                .setReadingReminder(v, settings.readingReminderTime),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.local_fire_department_rounded),
            title: const Text('Streak reminder'),
            value: settings.streakReminderEnabled,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setStreakReminder(v),
          ),

          const Divider(height: 24),
          _Header('Data & storage'),
          ListTile(
            leading: const Icon(Icons.insights_rounded),
            title: const Text('Reading statistics'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.storage_rounded),
            title: const Text('Manage downloads'),
            subtitle: const Text('View storage usage, clear downloads'),
            onTap: () => _clearDownloads(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services_rounded),
            title: const Text('Clear search history'),
            onTap: () async {
              await ref.read(repositoryProvider).clearSearchHistory();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search history cleared')),
                );
              }
            },
          ),

          const Divider(height: 24),
          _Header('About'),
          const ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text('ManhwaToon'),
            subtitle: Text('v1.0.0 • A premium manga reader'),
          ),
          ListTile(
            leading: const Icon(Icons.copyright_rounded),
            title: const Text('© ManhwaToon'),
            subtitle: const Text('Manga content is provided by manhwatoon.me'),
          ),
          ListTile(
            leading: const Icon(Icons.open_in_new_rounded),
            title: const Text('Visit manhwatoon.me'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => launchUrl(
              Uri.parse(AppConstants.siteBaseUrl),
              mode: LaunchMode.externalApplication,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _pickAccent(BuildContext context, WidgetRef ref, AppSettings settings) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Accent color', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: List.generate(accentColors.length, (i) {
                final color = accentColors[i];
                final selected = settings.accentIndex == i;
                return InkWell(
                  onTap: () {
                    ref.read(settingsProvider.notifier).setAccent(i);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.seed,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: Theme.of(ctx).colorScheme.onSurface, width: 3)
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check_rounded, color: Colors.white)
                        : null,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _pickReaderMode(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final mode in ReaderMode.values)
              RadioListTile<String>(
                value: mode.value,
                groupValue: settings.readerMode,
                title: Text(mode.label),
                onChanged: (v) {
                  ref.read(settingsProvider.notifier).setReaderMode(v!);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _editHomeSections(
      BuildContext context, WidgetRef ref, AppSettings settings) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final selected = settings.homeSections;
          void toggle(String id) {
            final next = selected.contains(id)
                ? selected.where((s) => s != id).toList()
                : [...selected, id];
            ref.read(settingsProvider.notifier).setHomeSections(next);
            setSheetState(() {});
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Home sections', style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 12),
                for (final section in _homeSectionOptions)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(section.label),
                    value: selected.contains(section.id),
                    onChanged: (_) => toggle(section.id),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _clearDownloads(BuildContext context, WidgetRef ref) async {
    final manager = ref.read(downloadManagerProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear completed downloads'),
        content: const Text('This removes all finished chapter downloads from the device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await manager.clearCompleted();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completed downloads cleared')),
        );
      }
    }
  }
}

class _Header extends StatelessWidget {
  const _Header(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800),
      ),
    );
  }
}

const _homeSectionOptions = [
  (id: 'continueReading', label: 'Continue Reading'),
  (id: 'trending', label: 'Trending Today'),
  (id: 'hiddenGems', label: 'Hidden Gems'),
  (id: 'popular', label: 'Most Popular'),
  (id: 'dailySuggestions', label: 'Daily Suggestions'),
  (id: 'latest', label: 'Latest Updates'),
];
