import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';
import '../theme/app_theme.dart';

/// Immutable snapshot of user preferences.
class AppSettings {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.accentIndex = 0,
    this.dynamicColor = true,
    this.homeSections = const [
      'continueReading',
      'trending',
      'hiddenGems',
      'popular',
      'dailySuggestions',
      'latest',
    ],
    this.readerMode = 'webtoon',
    this.readerBrightness = 1.0,
    this.readerKeepScreenOn = true,
    this.readerAutoScroll = false,
    this.readerAutoScrollSpeed = 1.0,
    this.readerInvertImages = false,
    this.libraryViewMode = 'grid',
    this.autoDownloadNext = false,
    this.hideAdult = true,
    this.notificationsEnabled = true,
    this.readingReminderEnabled = false,
    this.readingReminderTime = '20:00',
    this.dailyRecommendationEnabled = true,
    this.streakReminderEnabled = false,
    this.cacheMaxBytes = 512 * 1024 * 1024,
    this.adultVerified = false,
  });

  final AppThemeMode themeMode;
  final int accentIndex;
  final bool dynamicColor;
  final List<String> homeSections;
  final String readerMode;
  final double readerBrightness;
  final bool readerKeepScreenOn;
  final bool readerAutoScroll;
  final double readerAutoScrollSpeed;
  final bool readerInvertImages;
  final String libraryViewMode;
  final bool autoDownloadNext;
  final bool hideAdult;
  final bool notificationsEnabled;
  final bool readingReminderEnabled;
  final String readingReminderTime;
  final bool dailyRecommendationEnabled;
  final bool streakReminderEnabled;
  final int cacheMaxBytes;
  final bool adultVerified;

  Color get accentColor => accentColors[accentIndex.clamp(0, accentColors.length - 1)].seed;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    int? accentIndex,
    bool? dynamicColor,
    List<String>? homeSections,
    String? readerMode,
    double? readerBrightness,
    bool? readerKeepScreenOn,
    bool? readerAutoScroll,
    double? readerAutoScrollSpeed,
    bool? readerInvertImages,
    String? libraryViewMode,
    bool? autoDownloadNext,
    bool? hideAdult,
    bool? notificationsEnabled,
    bool? readingReminderEnabled,
    String? readingReminderTime,
    bool? dailyRecommendationEnabled,
    bool? streakReminderEnabled,
    int? cacheMaxBytes,
    bool? adultVerified,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      accentIndex: accentIndex ?? this.accentIndex,
      dynamicColor: dynamicColor ?? this.dynamicColor,
      homeSections: homeSections ?? this.homeSections,
      readerMode: readerMode ?? this.readerMode,
      readerBrightness: readerBrightness ?? this.readerBrightness,
      readerKeepScreenOn: readerKeepScreenOn ?? this.readerKeepScreenOn,
      readerAutoScroll: readerAutoScroll ?? this.readerAutoScroll,
      readerAutoScrollSpeed: readerAutoScrollSpeed ?? this.readerAutoScrollSpeed,
      readerInvertImages: readerInvertImages ?? this.readerInvertImages,
      libraryViewMode: libraryViewMode ?? this.libraryViewMode,
      autoDownloadNext: autoDownloadNext ?? this.autoDownloadNext,
      hideAdult: hideAdult ?? this.hideAdult,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      readingReminderEnabled: readingReminderEnabled ?? this.readingReminderEnabled,
      readingReminderTime: readingReminderTime ?? this.readingReminderTime,
      dailyRecommendationEnabled:
          dailyRecommendationEnabled ?? this.dailyRecommendationEnabled,
      streakReminderEnabled: streakReminderEnabled ?? this.streakReminderEnabled,
      cacheMaxBytes: cacheMaxBytes ?? this.cacheMaxBytes,
      adultVerified: adultVerified ?? this.adultVerified,
    );
  }

  static const _homeSectionsKey = 'home_sections_list';

  /// Builds [AppSettings] from already-loaded [SharedPreferences].
  /// All getters on [SharedPreferences] are synchronous, so this is safe to
  /// use inside a `Notifier.build`.
  static AppSettings fromPrefs(SharedPreferences prefs) {
    List<String> homeSections =
        prefs.getStringList(_homeSectionsKey) ??
        const [
          'continueReading',
          'trending',
          'hiddenGems',
          'popular',
          'dailySuggestions',
          'latest',
        ];
    if (homeSections.isEmpty) {
      homeSections = const ['continueReading', 'trending', 'hiddenGems', 'popular', 'dailySuggestions', 'latest'];
    }
    return AppSettings(
      themeMode: AppThemeMode.fromValue(prefs.getString(StorageKeys.themeMode)),
      accentIndex: prefs.getInt(StorageKeys.accentColor) ?? 0,
      dynamicColor: prefs.getBool(StorageKeys.dynamicColor) ?? true,
      homeSections: homeSections,
      readerMode: prefs.getString(StorageKeys.readerMode) ?? 'webtoon',
      readerBrightness: prefs.getDouble(StorageKeys.readerBrightness) ?? 1.0,
      readerKeepScreenOn: prefs.getBool(StorageKeys.readerKeepScreenOn) ?? true,
      readerAutoScroll: prefs.getBool(StorageKeys.readerAutoScroll) ?? false,
      readerAutoScrollSpeed: prefs.getDouble(StorageKeys.readerAutoScrollSpeed) ?? 1.0,
      readerInvertImages: prefs.getBool(StorageKeys.readerInvertImages) ?? false,
      libraryViewMode: prefs.getString(StorageKeys.libraryViewMode) ?? 'grid',
      autoDownloadNext: prefs.getBool(StorageKeys.autoDownloadNext) ?? false,
      hideAdult: prefs.getBool(StorageKeys.hideAdult) ?? true,
      notificationsEnabled: prefs.getBool(StorageKeys.notificationEnabled) ?? true,
      readingReminderEnabled: prefs.getBool(StorageKeys.readingReminderEnabled) ?? false,
      readingReminderTime: prefs.getString(StorageKeys.readingReminderTime) ?? '20:00',
      dailyRecommendationEnabled:
          prefs.getBool(StorageKeys.dailyRecommendationEnabled) ?? true,
      streakReminderEnabled: prefs.getBool(StorageKeys.streakReminderEnabled) ?? false,
      cacheMaxBytes: prefs.getInt(StorageKeys.cacheMaxBytes) ?? 512 * 1024 * 1024,
      adultVerified: prefs.getBool(StorageKeys.adultVerified) ?? false,
    );
  }

  /// Persists the settings to [SharedPreferences].
  Future<void> save(SharedPreferences prefs) async {
    await prefs.setString(StorageKeys.themeMode, themeMode.value);
    await prefs.setInt(StorageKeys.accentColor, accentIndex);
    await prefs.setBool(StorageKeys.dynamicColor, dynamicColor);
    await prefs.setStringList(_homeSectionsKey, homeSections);
    await prefs.setString(StorageKeys.readerMode, readerMode);
    await prefs.setDouble(StorageKeys.readerBrightness, readerBrightness);
    await prefs.setBool(StorageKeys.readerKeepScreenOn, readerKeepScreenOn);
    await prefs.setBool(StorageKeys.readerAutoScroll, readerAutoScroll);
    await prefs.setDouble(StorageKeys.readerAutoScrollSpeed, readerAutoScrollSpeed);
    await prefs.setBool(StorageKeys.readerInvertImages, readerInvertImages);
    await prefs.setString(StorageKeys.libraryViewMode, libraryViewMode);
    await prefs.setBool(StorageKeys.autoDownloadNext, autoDownloadNext);
    await prefs.setBool(StorageKeys.hideAdult, hideAdult);
    await prefs.setBool(StorageKeys.notificationEnabled, notificationsEnabled);
    await prefs.setBool(StorageKeys.readingReminderEnabled, readingReminderEnabled);
    await prefs.setString(StorageKeys.readingReminderTime, readingReminderTime);
    await prefs.setBool(StorageKeys.dailyRecommendationEnabled, dailyRecommendationEnabled);
    await prefs.setBool(StorageKeys.streakReminderEnabled, streakReminderEnabled);
    await prefs.setInt(StorageKeys.cacheMaxBytes, cacheMaxBytes);
    await prefs.setBool(StorageKeys.adultVerified, adultVerified);
  }
}

/// Override-able handle to preloaded [SharedPreferences]. Populated in
/// `main()` before `runApp` so settings load synchronously.
final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);

/// Riverpod notifier owning the application settings.
class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs != null ? AppSettings.fromPrefs(prefs) : const AppSettings();
  }

  Future<SharedPreferences> _shared() async {
    return ref.read(sharedPreferencesProvider) ?? await SharedPreferences.getInstance();
  }

  Future<void> update(AppSettings Function(AppSettings) transform) async {
    final prefs = await _shared();
    final next = transform(state);
    await next.save(prefs);
    state = next;
  }

  Future<void> setThemeMode(AppThemeMode mode) =>
      update((s) => s.copyWith(themeMode: mode));

  Future<void> setAccent(int index) => update((s) => s.copyWith(accentIndex: index));

  Future<void> setDynamicColor(bool value) =>
      update((s) => s.copyWith(dynamicColor: value));

  Future<void> setHomeSections(List<String> sections) =>
      update((s) => s.copyWith(homeSections: sections));

  Future<void> setReaderMode(String mode) => update((s) => s.copyWith(readerMode: mode));

  Future<void> setReaderBrightness(double value) =>
      update((s) => s.copyWith(readerBrightness: value));

  Future<void> setReaderKeepScreenOn(bool value) =>
      update((s) => s.copyWith(readerKeepScreenOn: value));

  Future<void> setReaderAutoScroll(bool value) =>
      update((s) => s.copyWith(readerAutoScroll: value));

  Future<void> setReaderAutoScrollSpeed(double value) =>
      update((s) => s.copyWith(readerAutoScrollSpeed: value));

  Future<void> setReaderInvertImages(bool value) =>
      update((s) => s.copyWith(readerInvertImages: value));

  Future<void> setLibraryViewMode(String value) =>
      update((s) => s.copyWith(libraryViewMode: value));

  Future<void> setAutoDownloadNext(bool value) =>
      update((s) => s.copyWith(autoDownloadNext: value));

  Future<void> setHideAdult(bool value) => update((s) => s.copyWith(hideAdult: value));

  Future<void> setNotificationsEnabled(bool value) =>
      update((s) => s.copyWith(notificationsEnabled: value));

  Future<void> setReadingReminder(bool enabled, String time) =>
      update((s) => s.copyWith(readingReminderEnabled: enabled, readingReminderTime: time));

  Future<void> setDailyRecommendation(bool value) =>
      update((s) => s.copyWith(dailyRecommendationEnabled: value));

  Future<void> setStreakReminder(bool value) =>
      update((s) => s.copyWith(streakReminderEnabled: value));

  Future<void> setAdultVerified(bool value) =>
      update((s) => s.copyWith(adultVerified: value));
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
