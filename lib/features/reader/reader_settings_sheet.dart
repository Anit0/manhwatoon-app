import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/settings_provider.dart';
import '../../models/reader_models.dart';
import 'reader_controller.dart';

class ReaderSettingsSheet extends ConsumerWidget {
  const ReaderSettingsSheet({super.key, required this.controller});

  final ReaderController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reader settings', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),

            Text('Reading mode', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ReaderMode.values.map((m) {
                return ChoiceChip(
                  label: Text(m.label),
                  selected: controller.mode == m,
                  showCheckmark: false,
                  onSelected: (_) {
                    controller.mode = m;
                    ref
                        .read(settingsProvider.notifier)
                        .setReaderMode(m.value);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.brightness_6_rounded),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Brightness', style: theme.textTheme.titleSmall),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: controller.brightness,
                    min: 0.2,
                    max: 1.0,
                    onChanged: (v) {
                      controller.brightness = v;
                      ref.read(settingsProvider.notifier).setReaderBrightness(v);
                    },
                  ),
                ),
                Text('${(controller.brightness * 100).round()}%'),
              ],
            ),
            const SizedBox(height: 8),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Keep screen on'),
              value: controller.keepScreenOn,
              onChanged: (v) {
                controller.keepScreenOn = v;
                ref.read(settingsProvider.notifier).setReaderKeepScreenOn(v);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto-scroll'),
              value: controller.autoScroll,
              onChanged: (v) {
                controller.autoScroll = v;
                ref.read(settingsProvider.notifier).setReaderAutoScroll(v);
              },
            ),
            if (controller.autoScroll) ...[
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: controller.autoScrollSpeed,
                      min: 0.2,
                      max: 3.0,
                      divisions: 28,
                      label: '${controller.autoScrollSpeed.toStringAsFixed(1)}x',
                      onChanged: (v) {
                        controller.autoScrollSpeed = v;
                        ref
                            .read(settingsProvider.notifier)
                            .setReaderAutoScrollSpeed(v);
                      },
                    ),
                  ),
                  Text('${controller.autoScrollSpeed.toStringAsFixed(1)}x'),
                ],
              ),
            ],
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Invert images (night mode)'),
              value: controller.invertImages,
              onChanged: (v) {
                controller.invertImages = v;
                ref.read(settingsProvider.notifier).setReaderInvertImages(v);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto-download next chapter'),
              subtitle: const Text('Queue the following chapter for offline reading'),
              value: settings.autoDownloadNext,
              onChanged: (v) => ref.read(settingsProvider.notifier).setAutoDownloadNext(v),
            ),
            const SizedBox(height: 8),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.timer_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Session',
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    Text(_formatDuration(controller.elapsed)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }
}
