# Kin Care Connect

A Flutter app I built to help families keep an eye on elderly parents. It uses AI and phone sensors to make caregiving a little less stressful.

---

## What it does

**Routine Monitor** — Uses the phone's accelerometer to detect if the parent hasn't moved in 4 hours and sends a notification. Their last active time syncs to Firebase so family members can check in anytime.

**Medical Translator** — Record a doctor's conversation and the app uses Gemini AI to summarize it into 3 simple action items. No more confusing medical jargon.

**Scam Shield** — Paste any suspicious message or call transcript. Gemini analyzes it and shows a green SAFE or red SCAM ALERT with a risk score.

---

## Built with

- Flutter 3.27.0
- Firebase (Firestore + Auth)
- Gemini AI API
- sensors_plus, flutter_sound, flutter_background_service

---

## Setup

1. Clone the repo
2. Run `flutter pub get`
3. Add your `google-services.json` to `android/app/`
4. Add your Gemini API key in the translator and scam shield screens
5. Run `flutter run`

To get the APK, just push to main — GitHub Actions builds it automatically and uploads it as an artifact.

---

Made by Mahamooda
