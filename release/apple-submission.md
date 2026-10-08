# Apple submission — prepared, not submitted

## Repository and app identity

- GitHub repository: https://github.com/bsatishinbox/moments (public; created by the owner).
- Proposed app name: **Moment — Life Counter**. App Store availability must be checked before creating the record.
- Proposed iOS identifier: `io.github.bsatishinbox.moment`.
- Proposed watch identifier: `io.github.bsatishinbox.moment.watchkitapp`.
- Developer Team ID: not yet available.
- App Store Connect numeric app ID: not yet created or verified.
- Availability, price, release timing, and content-rating answers: not yet entered.

The code is prepared with the proposed identifiers. They have not been registered with Apple.

## Ready now

- Native iPhone/iPad and Apple Watch source, icons, and privacy manifest.
- GitHub Actions workflow to compile both simulator apps and run model tests.
- Android test/build job and downloadable debug APK once the workflow runs.
- Draft App Store name, subtitle, description, keywords, and release notes in `release/app-store/en-US/`.

See [Native build checks](https://github.com/bsatishinbox/moments/actions/workflows/native-checks.yml) for the latest build results and artifacts. A passing simulator build is a compilation check, not device testing or a signed store build.

## Required to continue

1. Confirm **Native build checks** passes for the latest source. Fix compiler failures before attempting release.
2. Download the simulator app / Android debug APK from the workflow for initial testing.
3. Access an active Apple Developer membership and App Store Connect with permission to manage this app. Register the bundle identifiers and create the app record.
4. Select the developer team in `native/apple/project.yml`, regenerate the Xcode project, and configure distribution signing for both phone and watch targets.
5. Run and test the native apps on devices, including phone/watch synchronization and accessibility. Capture real iPhone/iPad/Watch screenshots required for the chosen supported devices.
6. Build an archive in Xcode with a store-supported SDK, validate it, and upload it to App Store Connect. Apple currently requires Xcode 26 or later with the relevant SDK version 26 or later for new uploads.
7. Complete store metadata, public privacy-policy and support URLs, pricing/availability, review contact, privacy disclosures, export-compliance questions, and age rating. These must reflect the actual final build and the account holder's answers.
8. Select the processed build and submit for App Review. Release occurs only after Apple's approval and the configured release action.

No Apple passwords, API keys, signing certificates, or provisioning profiles belong in this repository. Use Apple's sign-in flow and secure signing configuration; do not send secrets in chat.

## Sources

- Upload requirements: https://developer.apple.com/news/upcoming-requirements/?id=04282026a
- Uploading builds: https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/
- GitHub macOS runners: https://docs.github.com/en/actions/reference/runners/github-hosted-runners
