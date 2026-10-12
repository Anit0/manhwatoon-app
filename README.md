<p align="center">
  <img src="assets/icon/iconlogo.png" alt="ManhwaToon logo" width="112">
</p>

<h1 align="center">ManhwaToon</h1>

<p align="center">
  <strong>Your next chapter, wherever you are.</strong><br>
  Discover manga, manhwa, and manhua. Build your library and read on Android.
</p>

<p align="center">
  <a href="https://github.com/Anit0/manhwatoon-app/releases/tag/manhwatoon-app"><img src="https://img.shields.io/badge/Download-Android_APK-6750A4?style=for-the-badge&amp;logo=android&amp;logoColor=white" alt="Download Android APK"></a>
  <a href="https://github.com/Anit0/manhwatoon-app/releases"><img src="https://img.shields.io/github/downloads/Anit0/manhwatoon-app/total?style=for-the-badge&amp;color=6750A4" alt="GitHub downloads"></a>
  <a href="https://ko-fi.com/anit0"><img src="https://img.shields.io/badge/Support-Ko--fi-FF5E5B?style=for-the-badge&amp;logo=kofi&amp;logoColor=white" alt="Support on Ko-fi"></a>
</p>

<p align="center">
  <a href="#download">Download</a> ·
  <a href="#screenshots">Screenshots</a> ·
  <a href="#features">Features</a> ·
  <a href="#build-from-source">Build</a> ·
  <a href="#feedback--contributing">Feedback</a>
</p>

## About

ManhwaToon is a Flutter-based reader for Android that brings discovery, library management, and offline reading together. Save the series you follow, keep track of your chapters, and adjust the reader to suit how you read.

## Download

**[Download ManhwaToon for Android](https://github.com/Anit0/manhwatoon-app/releases/tag/manhwatoon-app)**

Open the release page and choose the APK for the newest version listed under **Assets**. Release notes describe what is included in each published build; the `main` branch may contain newer changes.

1. Download the APK to your Android device.
2. Open it and, if prompted, allow your browser or file manager to install apps from this source.
3. Complete installation and open **ManhwaToon**.

[View all releases](https://github.com/Anit0/manhwatoon-app/releases)

## Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/9f5c6210-6bd5-4462-a9dc-ec4d90a8396a" alt="ManhwaToon app screenshot 1" width="220">
  <img src="https://github.com/user-attachments/assets/7747875f-130f-4070-ae45-f788908dda12" alt="ManhwaToon app screenshot 2" width="220">
  <img src="https://github.com/user-attachments/assets/c87ef629-d539-45d8-819c-a8a41e5225d2" alt="ManhwaToon app screenshot 3" width="220">
</p>

## Features

### Discover and read

- Browse latest releases, popular titles, and genres, or search for a series.
- Read with webtoon and vertical reading modes, plus auto-scroll.
- Download chapters for offline reading.
- Bookmark chapters directly from the reader.
- Enable incognito mode to avoid saving reading history and progress.

### Keep your library organized

- Save favorites and organize series into collections.
- Switch between list and grid views, apply filters, and see unread badges.
- Follow chapter updates and browse the **Upcoming** tab.
- Add notes, manage chapter bookmarks, and mark chapters as read.
- Mark duplicate chapters as read together.
- Search your library by title, author, genre, unread count, and more.

### Make it yours

- Choose light or dark appearance and customize accent colors.
- Pick from **Nord**, **Catppuccin**, **Tokyo Night**, and **Monochrome** color themes.
- Export and restore library backups, including notes, chapter bookmarks, and read marks.

<details>
<summary><strong>Library search examples</strong></summary>

Combine search terms to find exactly what you want in your saved library.

| Query | Finds |
| --- | --- |
| `title:solo` | Titles containing “solo” |
| `author:kim` | Series whose author field contains “kim” |
| `genre:action unread:>0` | Action series with unread chapters |
| `genre:action \|\| genre:fantasy` | Series tagged action or fantasy |
| `genre:action -genre:horror` | Action series without the horror tag |
| `downloaded:true` | Series with downloaded chapters |

Separate terms with spaces for AND, use `||` for OR, and prefix a term with `-` to exclude it.

</details>

## Build from source

Install [Flutter](https://docs.flutter.dev/get-started/install) and Android Studio with the Flutter and Dart plugins. Use a Flutter version that includes Dart **3.8.1 or compatible newer 3.x**, as required by `pubspec.yaml`.

```bash
git clone https://github.com/Anit0/manhwatoon-app.git
cd manhwatoon-app
flutter doctor
flutter pub get
flutter run
```

For Android Studio, open the project folder containing `pubspec.yaml`, select a connected device or emulator, and run the app.

### Build a release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

The current Android configuration uses the debug signing key for release builds. Configure your own release signing before distributing a production build.

### Development checks

```bash
flutter analyze
flutter test
```

<details>
<summary><strong>Testing the promotional timer</strong></summary>

In `lib/core/constants/app_constants.dart`, temporarily change `adInterval` from `Duration(minutes: 10)` to `Duration(seconds: 10)` for testing. Restore the 10-minute interval before shipping.

</details>

## Feedback & contributing

Found a bug or have a feature idea? Check [existing issues](https://github.com/Anit0/manhwatoon-app/issues) before [opening a new issue](https://github.com/Anit0/manhwatoon-app/issues/new).

For bug reports, include your app version, Android version, steps to reproduce, and what you expected to happen. Add screenshots or relevant logs when useful, with personal information removed.

For a substantial change, open an issue to discuss the approach first. Keep pull requests focused and describe what changed and how you checked it.

## Support

If ManhwaToon is useful to you, consider [supporting the project on Ko-fi](https://ko-fi.com/anit0) or starring this repository.

## Content notice

Reading content is retrieved from external sources. Availability depends on those sources, and rights to manga, manhwa, manhua, and related artwork remain with their respective owners. Please support creators through official releases where available.
