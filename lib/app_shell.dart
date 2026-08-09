import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/network/scraper_health.dart';
import 'core/providers/connectivity_provider.dart';
import 'core/providers/settings_provider.dart';
import 'features/discover/discover_data_provider.dart';
import 'features/discover/discover_screen.dart';
import 'features/home/home_data_provider.dart';
import 'features/home/home_screen.dart';
import 'features/library/library_screen.dart';
import 'features/library/library_updates_provider.dart';
import 'features/search/search_screen.dart';

/// Root scaffold hosting the bottom navigation and tab screens.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Opportunistically diff library items for new chapters shortly after
    // launch, so the Library "Updates" tab is ready when the user opens it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(libraryUpdatesProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hideAdult = ref.watch(settingsProvider.select((s) => s.hideAdult));
    final adultVerified = ref.watch(settingsProvider.select((s) => s.adultVerified));
    if (hideAdult && !adultVerified) {
      return const _AdultGate();
    }

    // When the connection comes back, refresh the home/discover feeds that
    // may have failed while offline.
    ref.listen(connectivityProvider, (previous, next) {
      final wasOnline = previous?.value ?? true;
      final isOnline = next.value ?? true;
      if (!wasOnline && isOnline) {
        ref.invalidate(homeDataProvider);
        ref.invalidate(discoverDataProvider);
      }
    });

    final online = ref.watch(connectivityProvider).value ?? true;

    return Scaffold(
      body: Column(
        children: [
          if (!online) const _OfflineBanner(),
          if (kDebugMode) const _ScraperBanner(),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: const [
                HomeScreen(),
                DiscoverScreen(),
                SearchScreen(),
                LibraryScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.collections_bookmark_outlined),
            selectedIcon: Icon(Icons.collections_bookmark_rounded),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}

/// Slim banner shown while the device has no network connectivity.
class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.errorContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.cloud_off_rounded, size: 18, color: scheme.onErrorContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You are offline. Retrying when the connection returns.',
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Debug-only banner that surfaces scraper sanity warnings, so an upstream
/// markup change shows up in dev instead of as silent empty screens.
class _ScraperBanner extends StatelessWidget {
  const _ScraperBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<String?>(
      valueListenable: ScraperHealth.lastWarning,
      builder: (context, warning, _) {
        if (warning == null) return const SizedBox.shrink();
        return Material(
          color: scheme.tertiaryContainer,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.bug_report_rounded,
                      size: 18, color: scheme.onTertiaryContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Scraper warning: $warning',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: scheme.onTertiaryContainer),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Dismiss',
                    visualDensity: VisualDensity.compact,
                    onPressed: ScraperHealth.clear,
                    icon: Icon(Icons.close_rounded,
                        size: 18, color: scheme.onTertiaryContainer),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Content warning gate shown when adult content is hidden.
class _AdultGate extends ConsumerWidget {
  const _AdultGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user_rounded,
                    size: 72, color: scheme.primary),
                const SizedBox(height: 20),
                Text(
                  'Content notice',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Text(
                  'This app may contain mature or adult content. '
                  'Please confirm you are at least 18 years old to continue.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () =>
                      ref.read(settingsProvider.notifier).setAdultVerified(true),
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('I am 18 years or older'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {},
                  child: const Text('Leave'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
