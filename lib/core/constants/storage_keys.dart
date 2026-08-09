/// SharedPreferences storage keys used by the app.
library;

class StorageKeys {
  StorageKeys._();

  static const String adultVerified = 'adult_verified';
  static const String onboardingDone = 'onboarding_done';

  static const String themeMode = 'theme_mode'; // system | light | dark | amoled
  static const String accentColor = 'accent_color'; // seed color index
  static const String dynamicColor = 'dynamic_color'; // bool
  static const String homeSections = 'home_sections'; // json list of ids
  static const String readerMode = 'reader_mode'; // webtoon | paged | rtl | ltr
  static const String readerTapZones = 'reader_tap_zones';
  static const String readerAutoScroll = 'reader_auto_scroll';
  static const String readerAutoScrollSpeed = 'reader_auto_scroll_speed';
  static const String readerBrightness = 'reader_brightness'; // double 0..1
  static const String readerKeepScreenOn = 'reader_keep_screen_on';
  static const String readerDefaultZoom = 'reader_default_zoom';
  static const String readerFontScale = 'reader_font_scale';
  static const String readerInvertImages = 'reader_invert_images';
  static const String libraryViewMode = 'library_view_mode'; // grid | list
  static const String browsingSort = 'browsing_sort';
  static const String autoDownloadNext = 'auto_download_next';
  static const String hideAdult = 'hide_adult';
  static const String notificationEnabled = 'notification_enabled';
  static const String readingReminderEnabled = 'reading_reminder_enabled';
  static const String readingReminderTime = 'reading_reminder_time';
  static const String dailyRecommendationEnabled = 'daily_recommendation_enabled';
  static const String streakReminderEnabled = 'streak_reminder_enabled';
  static const String cacheMaxBytes = 'cache_max_bytes';
  static const String recentSearchCount = 'recent_search_count';
  static const String activeSourceId = 'active_source_id';

  /// Per-manga key remembering the last "seen" latest chapter URL, used by the
  /// new-chapter update detection. Value: latest chapter URL.
  static String ackLatestChapter(String mangaUrl) => 'ack_latest_chapter_$mangaUrl';
}
