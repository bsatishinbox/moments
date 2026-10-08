# Moment

A simple life countdown for iPhone, iPad, Android, and Apple Watch. Starts at age 37 with a target age of 60. The target is a personal milestone, not a prediction of lifespan.

## What is included

| Platform | Implementation | Status |
| --- | --- | --- |
| iPhone / iPad | Native SwiftUI | Source, icon, privacy manifest, and XcodeGen specification provided; not compiled or signed here |
| Apple Watch | Native SwiftUI watchOS app | Source and paired iPhone settings sync provided; not tested on a watch here |
| Android | Native Kotlin / Jetpack Compose | Gradle project, wrapper, adaptive icon, and model tests provided; not compiled or signed here |

The interactive [web preview](https://moment-life-counter.satish5.chatgpt.site) is published separately. It is not a store build. Native apps run locally without a server or account. There is no cloud synchronization between Android, web, and Apple devices. A paired iPhone and Apple Watch exchange the latest settings through WatchConnectivity.

## Product behavior

- One screen shows total remaining days, hours, and minutes. Tap a unit to make it the main count.
- Settings include current age, target age, and an optional exact birthday on phones.
- The default 37 → 60 interval is 23 calendar years, including leap days.
- Age-only setup starts as if the user just turned that age. Its birth anchor is saved once, so reopening the app never restarts the countdown.
- Changing only the target age preserves the anchor. Changing the age creates a new approximate anchor. Supplying a birthday uses that date instead.
- Dates use Gregorian calendar anniversaries. A February 29 birthday clamps to February 28 in a non-leap year.
- Counts are total elapsed-time units rounded down: a day is 24 hours, an hour is 60 minutes. The three values are alternate views of the same interval, not a days/hours/minutes remainder breakdown. Calendar dates respect the device time zone when created; the saved target instant is retained until settings are edited.
- Counts derive from the current clock, so they catch up after sleep or app backgrounding. Watch updates are minute-granular while visible and remain subject to watchOS scheduling.
- Reaching the target clamps values to zero. The phone offers a message to choose a new milestone.
- Phone and watch keep their own saved copy. Newer settings win using an update timestamp with a deterministic tie-breaker. Delivery occurs when WatchConnectivity can communicate; it is not guaranteed to be immediate. No cloud backend is involved.

## Build iOS and Apple Watch

Requires a Mac with a current Xcode, its iOS/watchOS SDKs, and XcodeGen. The source deployment targets are iOS 17 and watchOS 10; use the SDK versions currently required by App Store Connect when releasing.

```sh
brew install xcodegen
cd native/apple
sh generate-project.sh
open Moment.xcodeproj
```

The proposed identifiers are `io.github.bsatishinbox.moment` and `io.github.bsatishinbox.moment.watchkitapp`. Register them in your Apple Developer account or replace them with identifiers you own. Set `DEVELOPMENT_TEAM` to your team ID and regenerate. The watch's `WKCompanionAppBundleIdentifier` must match the phone's identifier.

Run the **Moment** scheme for iPhone and the **MomentWatch** scheme for Apple Watch. Use a paired simulator or physical iPhone and Apple Watch to test synchronization. The watch can also configure its own age and milestone without first opening the phone app.

The iOS target embeds the watch app. Create an archive using a generic iOS device destination, then validate and distribute it through Xcode Organizer. Inspect the archive to confirm the watch app is embedded before uploading. Native compilation, archive validation, and store upload have not been performed in this environment.

Pure Swift model tests:

```sh
swift test --package-path native/apple
```

## Build Android

Open `native/android` in Android Studio. Install Android SDK 36 and use JDK 17. The project pins Android Gradle Plugin 8.9.2, Kotlin 2.1.20, Compose BOM 2025.04.01, and Gradle 8.11.1. The Gradle wrapper is included.

```sh
cd native/android
./gradlew testDebugUnitTest assembleDebug
./gradlew bundleRelease
```

The Android package is `io.github.bsatishinbox.moment`; confirm availability in your Play Console before release. Set up your release keystore in Android Studio's **Generate Signed App Bundle** flow. Release signing credentials are intentionally not included. The unsigned release task alone is not a distributable Play Store submission.

## What still needs to happen before store release

1. Compile both projects with their platform SDKs. Resolve any SDK or signing issues and run the supplied native model tests.
2. Test on iPhone, Android, and Apple Watch: save/relaunch; 60 → 70; exact birthday; invalid input; small screens; large text; VoiceOver/TalkBack; background/resume; offline operation; and watch pairing/reconnection.
3. Choose the final app name and owned bundle/package identifiers. Check name availability in the stores.
4. Use your Apple Developer and Google Play Console accounts, set signing, and create the store records.
5. Capture screenshots from the actual native builds, supply store descriptions and support/contact information, complete store privacy and age-rating forms, and provide a public privacy-policy URL.
6. Distribute to TestFlight and Google Play testing first. Complete any testing requirements your accounts are subject to, then submit for review.

Store availability depends on successful native builds, account access, and review. This package does not claim store approval or publication.

## Data behavior

The app stores the chosen age/birthday, target date, and selected unit in local device preferences. The Apple companion apps exchange these settings with the paired device. There are no analytics, advertising SDKs, backend requests, or account registration. Android disables OS backup in its manifest. Apple preferences may be included in the user's OS-managed device backup; this app does not implement its own cloud backup. The included Apple privacy manifest declares UserDefaults usage for app-owned preferences.

## Validation performed

- The separately published web version passed eight countdown model tests and DOM interaction checks for settings, target presets, persistence, unit selection, invalid values, and the optional agent action.
- Android resource XML and the Apple privacy plist parsed successfully. XcodeGen source paths were checked.
- Native tests are provided but were not run here: the environment has no Xcode, Swift compiler, Android SDK, simulator, or connected devices.
- A real browser visual check was unavailable. DOM simulation does not validate native layout, native compilation, accessibility rendering, store compliance, or watch connectivity.

## Implementation references

- Apple WatchConnectivity: https://developer.apple.com/documentation/watchconnectivity/transferring-data-with-watch-connectivity
- XcodeGen project specifications: https://github.com/yonaskolb/XcodeGen/blob/master/Docs/ProjectSpec.md
- Android Gradle Plugin 8.9: https://developer.android.com/build/releases/agp-8-9-0-release-notes
- Compose / Kotlin compatibility: https://developer.android.com/jetpack/androidx/releases/compose-kotlin
- Apple distribution: https://developer.apple.com/help/app-store-connect/
- Google Play release help: https://support.google.com/googleplay/android-developer/

The Gradle wrapper files originate from Gradle v8.11.1 (Apache 2.0). See `THIRD_PARTY_NOTICES.txt`.

## GitHub and Apple publishing preparation

Repository: [bsatishinbox/moments](https://github.com/bsatishinbox/moments).

[Native build checks](https://github.com/bsatishinbox/moments/actions/workflows/native-checks.yml) builds iPhone, Apple Watch, and Android and runs the native model tests on pushes to `main`. Check the workflow for the current build result and downloadable simulator apps / Android debug APK. Apple listing drafts and remaining steps are in `release/apple-submission.md`. Apple submission has not completed.
