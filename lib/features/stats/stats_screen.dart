import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/loaders.dart';
import 'stats_data_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reading Statistics')),
      body: stats.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Could not load statistics',
          message: '$e',
        ),
        data: (s) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('This month', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatCard(
                  icon: Icons.menu_book_rounded,
                  label: 'Pages',
                  value: '${s.monthlyPages}',
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.timer_rounded,
                  label: 'Reading time',
                  value: _formatDuration(s.monthlyDuration),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('All time', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatCard(
                  icon: Icons.auto_stories_rounded,
                  label: 'Chapters read',
                  value: '${s.chaptersRead}',
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.menu_book_rounded,
                  label: 'Pages read',
                  value: '${s.pagesRead}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatCard(
                  icon: Icons.schedule_rounded,
                  label: 'Total time',
                  value: _formatDuration(s.totalDuration),
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.check_circle_rounded,
                  label: 'Completed',
                  value: '${s.completedManga}',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Streaks', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatCard(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Current streak',
                  value: '${s.currentStreak} days',
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.emoji_events_rounded,
                  label: 'Best streak',
                  value: '${s.longestStreak} days',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatCard(
                  icon: Icons.calendar_month_rounded,
                  label: 'Active days',
                  value: '${s.totalReadDays}',
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.auto_awesome_rounded,
                  label: 'Top genre',
                  value: s.favoriteGenre ?? '—',
                ),
              ],
            ),
            if (s.favoriteAuthor != null) ...[
              const SizedBox(height: 12),
              _StatCard(
                icon: Icons.person_rounded,
                label: 'Favorite author',
                value: s.favoriteAuthor!,
              ),
            ],
            const SizedBox(height: 24),
            Text('Reading calendar', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            _ReadingCalendar(pagesByDay: s.calendar),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: scheme.primary, size: 22),
              const SizedBox(height: 10),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Last ~26 weeks GitHub-style heatmap of daily reading activity.
class _ReadingCalendar extends StatelessWidget {
  const _ReadingCalendar({required this.pagesByDay});

  final Map<DateTime, int> pagesByDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 26 weeks back, 7 columns (weeks) x 7 rows (days).
    const weeks = 26;
    final endOffset = 6 - today.weekday; // fill to end of week
    final end = today.add(Duration(days: endOffset));
    final start = end.subtract(Duration(days: weeks * 7 - 1));

    final maxPages = pagesByDay.values.fold<int>(0, (m, v) => v > m ? v : m);

    Widget cell(DateTime day) {
      final pages = pagesByDay[day] ?? 0;
      final intensity = maxPages == 0 ? 0.0 : (pages / maxPages).clamp(0.0, 1.0);
      final color = pages == 0
          ? scheme.surfaceContainerHigh
          : Color.lerp(scheme.primaryContainer, scheme.primary, intensity)!;
      return Tooltip(
        message: '${day.month}/${day.day}${pages > 0 ? ' • $pages pages' : ''}',
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      );
    }

    final columns = <Widget>[];
    for (var w = 0; w < weeks; w++) {
      final col = <Widget>[];
      for (var d = 0; d < 7; d++) {
        final day = start.add(Duration(days: w * 7 + d));
        col.add(cell(day));
      }
      columns.add(Column(
        children: [
          for (var d = 0; d < 7; d++)
            Padding(
              padding: const EdgeInsets.all(1.5),
              child: cell(start.add(Duration(days: w * 7 + d))),
            ),
        ],
      ));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Column(
                children: [
                  for (var d = 0; d < 7; d++)
                    SizedBox(
                      height: 12 + 3,
                      child: Padding(
                        padding: const EdgeInsets.all(1.5),
                        child: Text(
                          ['M', 'T', 'W', 'T', 'F', 'S', 'S'][d],
                          style: TextStyle(fontSize: 8, color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 4),
              for (var w = 0; w < weeks; w++) ...[
                for (var d = 0; d < 7; d++)
                  Padding(
                    padding: const EdgeInsets.all(1.5),
                    child: SizedBox(
                      width: 12,
                      height: 12,
                      child: cell(start.add(Duration(days: w * 7 + d))),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
