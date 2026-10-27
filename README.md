# Kin Care Connect

Kin Care Connect is a Flutter MVP concept for family caregiving support.

## Current MVP status

- **Account access:** Email/password sign-up and sign-in use Firebase Authentication. Firebase must be configured and Email/Password sign-in enabled in the Firebase Console.
- **Routine Monitor:** Displays local accelerometer activity while the screen is open. It is not continuous monitoring, does not currently sync family status, and must not be relied on for emergencies.
- **Scam Shield:** Uses a small offline set of warning phrases. It is not an AI system and cannot prove a message is safe.
- **Medical Translator:** Recording is available with permission. Secure AI transcription and summarization are not implemented yet; the screen explains this limitation.
- **AI credentials:** No AI API key should be embedded in the mobile client. AI functionality must be routed through a secured backend before being re-enabled.

## Stack

- Flutter 3.27.0
- Firebase Core, Authentication, and Cloud Firestore dependencies
- sensors_plus
- record and path_provider
- flutter_local_notifications

## Local setup

1. Install Flutter 3.27.0 and Android tooling.
2. Clone this repository and check out the branch you want to test.
3. Run `flutter pub get`.
4. Configure Firebase for Android using the Firebase Console / FlutterFire setup. Enable Email/Password under Firebase Authentication.
5. Place your local `google-services.json` in `android/app/`. Do not commit it unless you have deliberately reviewed the file and your repository policy allows it.
6. Run `flutter analyze`, `flutter test`, and then `flutter run`.

## GitHub Actions

The workflow validates Dart code and runs tests. To enable its Android test APK job, add a repository Actions secret named `GOOGLE_SERVICES_JSON_BASE64` containing the base64-encoded contents of your Firebase Android `google-services.json`.

The generated APK is for testing only. The current Gradle release configuration uses the debug signing key; it is **not a Play Store release artifact**. Configure a private upload keystore and protected GitHub Actions secrets before producing a signed Play Store Android App Bundle.

## Before public launch

- Rotate any AI API key that was previously committed to Git history.
- Configure Firebase Authentication and review Firestore security rules.
- Implement and security-test a backend for AI requests before re-enabling medical summaries or AI scam analysis.
- Test on real Android devices, including permission denial, no network, backgrounding, and notification behavior.
- Complete privacy policy, data safety disclosures, app signing, Play Console testing, and release checks.
- Do not describe movement status or scam screening as guaranteed detection or emergency protection.
