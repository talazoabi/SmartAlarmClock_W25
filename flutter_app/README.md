# WiseRise Flutter App - A Smart Alarm Clock
This directory contains the source code for the WiseRise app, built using Flutter. The app integrates with Firebase and the ESP32-based physical clock.

## 📌 Features
- ⏰ **Smart Alarm Clock** – Add and track alarms within the app.
- 📅 **Google Calendar Integration** – Sync tasks for better organization.
- ✅ **Manual Task Management** – Add and track tasks within the app.
- 🔗 **Firebase Connectivity** – Sync data and monitor connection status.
- ⚠️ **WiFi Connectivity Alert** – Displays a warning if the clock disconnects.
- 🎛 **User-Friendly Interface** – Settings and an info page for easy configuration.

## 📂 Directory Structure
```
app/
├── android/                # Android-specific files
├── lib/                    # Main Dart source code
├── test/                   # Unit and widget tests
├── pubspec.yaml            # Flutter project dependencies
├── firebase.json           # Firebase configuration
└── README.md               # This README file
```

## 🔧 Prerequisites
Ensure the following before running the app:

### 🛠 Install Flutter SDK
Follow the [official guide](https://flutter.dev/docs/get-started/install).

### 🔥 Firebase & Google Cloud Setup
1. Add `google-services.json` to `android/app/`.
2. Set up a Firebase project and enable Authentication.
3. Go to [Google Cloud Console](https://console.cloud.google.com/).
4. Enable the **Google Calendar API** for your project.
5. Create OAuth credentials and configure the necessary scopes for Google Calendar synchronization.

### 📦 Install Dependencies
```sh
flutter pub get
```

## ⚠️ Notes
- Do **not** commit `google-services.json`.
- Manually add these files before building.
