import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_shell.dart';
import 'core/providers/settings_provider.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const ManhwaToonApp(),
    ),
  );
}

class ManhwaToonApp extends ConsumerWidget {
  const ManhwaToonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final seed = settings.accentColor;
    final dynamicColor = settings.dynamicColor;

    final ThemeData light = AppTheme.light(seed, dynamicColor: dynamicColor);
    final ThemeData dark = AppTheme.dark(seed, dynamicColor: dynamicColor);
    final ThemeData amoled = AppTheme.amoled(seed, dynamicColor: dynamicColor);

    return MaterialApp(
      title: 'ManhwaToon',
      debugShowCheckedModeBanner: false,
      theme: light,
      darkTheme: switch (settings.themeMode) {
        AppThemeMode.amoled => amoled,
        _ => dark,
      },
      themeMode: switch (settings.themeMode) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark || AppThemeMode.amoled => ThemeMode.dark,
      },
      home: const AppShell(),
    );
  }
}
