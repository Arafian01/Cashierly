# Cashierly – Aplikasi Kasir Mobile

Flutter-based inventory management application with Firebase backend and Material 3 UI. Authenticated users can manage product categories, items, and transactions in real time across mobile, web, and desktop targets.

## Contents
- [Overview](#overview)
- [Key Features](#key-features)
- [Tech Stack](#tech-stack)
- [Screens](#screens)
- [Data Model](#data-model)
- [Getting Started](#getting-started)
- [Running the App](#running-the-app)
- [Build & Deployment](#build--deployment)
- [Project Structure](#project-structure)
- [Troubleshooting](#troubleshooting)
- [Additional Documentation](#additional-documentation)

## Overview
The project targets small to medium businesses that need a lightweight inventory workflow. Authentication gates access to the dashboard, where users can monitor inventory, manage categories and items, and review transaction summaries. State is handled with the `provider` package for predictable, reactive updates.

## Key Features
- **Secure authentication** with email/password using `FirebaseAuth`.
- **Dashboard metrics** showing live counts of categories and items via Firestore streams.
- **Category CRUD** flows with loading indicators, success/error feedback, and Indonesian copy.
- **Item CRUD** with price, stock, and category linkage, backed by error handling.
- **Transaction records** with detail collections (`transaksi`, `detail_transaksi`).
- **Cross-platform builds** for Android, iOS, web, Windows, macOS, and Linux.

## Tech Stack
- **Framework**: Flutter (Material 3)
- **Language**: Dart (SDK ^3.6.2)
- **State Management**: `provider`
- **Backend Services**: Firebase (`firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`*)
- **Tooling**: Firebase CLI, Android Studio or VS Code, Git

\* `firebase_storage` is currently unused; keep it for future image uploads or remove it to slim dependencies.

## Screens
- **Splash** (`lib/screens/splash_screen.dart`): Waits for initialization, redirects based on auth state.
- **Login / Register** (`lib/screens/login_screen.dart`, `lib/screens/register_screen.dart`): Validated forms with localized messaging.
- **Dashboard** (`lib/screens/dashboard_screen.dart`): Summary cards and navigation to CRUD flows.
- **Kategori** (`lib/screens/kategori_screen.dart`): Manage category documents with responsive dialogs.
- **Barang** (`lib/screens/barang_screen.dart`): Manage items, pricing, and stock, resolving category references.
- **Transaksi** (`lib/screens/transaksi_screen.dart`): View transaction data and related item details.

## Data Model
Firestore collections used by the app:
- **`kategori`**: `{ nama_kategori }`
- **`barang`**: `{ nama_barang, harga, stok, id_kategori (DocumentReference) }`
- **`transaksi`**: `{ tanggal, total, bayar, sisa, status }`
- **`detail_transaksi`**: `{ jumlah, sub_total, id_transaksi (DocumentReference), id_barang (DocumentReference) }`

## Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Dart SDK ^3.6.2
- Firebase CLI
- Git
- Android/iOS tooling as needed (Android Studio, Xcode)

### Setup
```bash
# Clone the repository
git clone <repository-url>
cd Inventory-App

# Install dependencies
flutter pub get
```

### Firebase Configuration
1. Create a Firebase project (e.g., `inventory-app-f8ff6`).
2. Enable Authentication (Email/Password), Cloud Firestore, and optionally Storage.
3. Add platform configuration files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
   - `web/firebase-config.js`
4. Run `flutterfire configure` or update `lib/firebase_options.dart` with project settings.
5. Confirm Gradle plugins are configured (see `android/app/build.gradle`).

## Running the App
```bash
# Run on connected device or emulator
flutter run

# List available devices
flutter devices

# Target a specific device
flutter run -d <device-id>
```

## Build & Deployment

### Android
```bash
# Debug build
flutter build apk --debug

# Release build (APK)
flutter build apk --release

# Play Store bundle
flutter build appbundle --release
```

### Web
```bash
# Development server
flutter run -d web-server --web-port 8080

# Production build
flutter build web --release
```

Refer to `DEPLOYMENT.md` for hosting options (Firebase Hosting, Netlify, GitHub Pages) and detailed post-deployment checklists.

## Project Structure
```text
Inventory-App/
├── android/                # Native Android project & Google Services config
├── ios/                    # iOS project (requires manual Firebase plist)
├── lib/
│   ├── firebase_options.dart
│   ├── main.dart           # App entry point & Firebase initialization
│   ├── providers/          # Auth, category, item controllers (Provider)
│   ├── screens/            # UI screens with dialogs/forms
│   ├── models/             # Firestore data models
│   └── widgets/            # Reusable UI components
├── web/firebase-config.js  # Web Firebase config
├── SUMMARY.md              # Architectural overview
├── DEPLOYMENT.md           # Release and hosting guide
└── pubspec.yaml            # Project metadata & dependencies
```

## Troubleshooting
- **Build failures**: `flutter clean && flutter pub get`, verify Flutter SDK version.
- **Firebase connection issues**: Ensure config files exist and match Firebase console settings.
- **Android Gradle errors**: Check Google Services plugin versions in `android/build.gradle` and `android/app/build.gradle`.
- **Web caching issues**: Clear browser cache after deploying new builds.

## Additional Documentation
- `SUMMARY.md` — Consolidated architecture and recent enhancements.
- `DEPLOYMENT.md` — End-to-end instructions for releasing the app.
- `pubspec.yaml` — Dependency list and Flutter constraints.

---
Maintained by the Inventory App team. Contributions and issue reports are welcome via GitHub pull requests or issues.
