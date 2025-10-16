# Toko Kelontong - Inventory Management App

A comprehensive Flutter-based inventory management system designed specifically for grocery stores (toko kelontong). This app provides essential tools for managing products, categories, multiple units per product, stock levels, and transactions with a modern, user-friendly interface.

## Features

### Authentication & Security
- **Firebase Authentication** - Secure user registration and login
- **Secure Data Storage** - All data encrypted and stored securely in Firestore
- **Real-time Sync** - All data synced across devices in real-time

### Product Management
- **Category Management** - Organize products with descriptions
- **Product Catalog** - Add, edit, and delete products with auto-generated codes
- **Multiple Units Support** - Each product can have multiple units (Pcs, Box, Karton) with different prices
- **Stock Tracking** - Real-time inventory levels per unit with automatic calculations
- **Product Search** - Quick search by name or product code
- **Category Relations** - Products properly linked to categories

### Transaction Management
- **Point of Sale (POS)** - Modern transaction interface with expandable product cards
- **Unit Selection** - Choose specific unit and quantity for each item
- **Shopping Cart** - Interactive cart with quantity adjustments and real-time totals
- **Auto Stock Update** - Inventory automatically updated after transactions
- **Transaction Codes** - Auto-generated transaction codes (TRX[YYYYMMDD]001)
- **Transaction History** - Complete sales records with detailed breakdowns

### Analytics & Dashboard
- **Home Dashboard** - Overview of categories, products, transactions, and daily revenue
- **Real-time Statistics** - Live updates of key business metrics
- **Transaction Details** - Complete breakdown showing product, category, unit, and subtotals
- **Stock Monitoring** - Visual indicators for stock levels

### User Experience
- **Modern UI Design** - Clean, Indonesian-localized Material Design 3 interface
- **Responsive Cards** - Beautiful card-based layouts for all modules
- **Intuitive Navigation** - Easy access to all features from home screen
- **Search & Filter** - Consistent search functionality across all modules
- **Visual Feedback** - Color-coded stock levels and transaction status

## Tech Stack
- **Framework**: Flutter (Material 3)
- **Language**: Dart (SDK ^3.6.2)
- **State Management**: `provider`
- **Backend Services**: Firebase (`firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`*)
- **Tooling**: Firebase CLI, Android Studio or VS Code, Git

\* `firebase_storage` is currently unused; keep it for future image uploads or remove it to slim dependencies.

## Screens
- **Splash** (`lib/screens/splash_screen.dart`): App initialization with grocery store branding.
- **Login / Register** (`lib/screens/login_screen.dart`, `lib/screens/register_screen.dart`): Firebase authentication forms.
- **Home Dashboard** (`lib/screens/home_screen.dart`): Statistics overview and main navigation.
- **Category Management** (`lib/screens/kategori_screen.dart`): CRUD operations for product categories.
- **Product Management** (`lib/screens/barang_screen.dart`): Manage products with category relations and unit access.
- **Unit Management** (`lib/screens/manage_units_screen.dart`): Manage product units, prices, and stock per unit.
- **New Transaction** (`lib/screens/transaksi_screen.dart`): Point-of-sale interface with cart functionality.
- **Transaction History** (`lib/screens/transaction_history_screen.dart`): View past transactions with detailed breakdowns.

## Data Model
Firestore collections used by the app:
- **`kategori`**: `{ nama_kategori, deskripsi }`
- **`barang`**: `{ id_kategori, kode_barang, nama_barang, stok_total }`
- **`barang_satuan`**: `{ id_barang, nama_satuan, harga_jual, stok_satuan }`
- **`transaksi`**: `{ kode_transaksi, tanggal_transaksi, total_harga }`
- **`detail_transaksi`**: `{ id_transaksi, id_barang_satuan, jumlah }`

See `DATABASE_STRUCTURE.md` for detailed schema and relationships.

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
