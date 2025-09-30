# Troubleshooting Guide - Inventory App

## LocalDataException: local data has not been initialized

### Problem
Error terjadi pada halaman transaksi: "localdataException: local data has not been initialized, call initializeD"

### Root Cause
Error ini disebabkan oleh:
1. Firestore offline persistence belum terinisialisasi dengan benar
2. Konflik antara cache lokal dan data server
3. Settings Firestore yang dipanggil lebih dari sekali

### Solutions Applied

#### 1. Fixed Firestore Initialization (main.dart)
```dart
// Added proper Firestore settings configuration
try {
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
} catch (e) {
  // Firestore settings can only be set once, ignore subsequent calls
  debugPrint('Firestore settings already configured: $e');
}
```

#### 2. Enhanced Error Handling (TransaksiProvider)
- Added proper error handling for streams
- Added metadata changes listening
- Added debug prints for troubleshooting

#### 3. Updated UI Error Display (TransaksiScreen)
- Added error message display
- Added retry functionality
- Added proper loading states

### Additional Troubleshooting Steps

#### Method 1: Clear App Cache
```bash
# Stop the app
flutter clean
flutter pub get

# Clear emulator data
# Android Studio > AVD Manager > Wipe Data

# Restart app
flutter run
```

#### Method 2: Disable Offline Persistence (if issue persists)
In `main.dart`, modify Firestore settings:
```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: false,  // Disable offline persistence
);
```

#### Method 3: Use Server-Only Data Source
In `TransaksiProvider.getTransaksi()`:
```dart
// Force server data only
return _transaksiRef
    .orderBy('tanggal', descending: true)
    .snapshots(source: Source.server)  // Force server data
    .map((snapshot) => {
      // ... rest of code
    });
```

#### Method 4: Cold Restart
```bash
# In IDE terminal or command line
flutter run --hot-restart
```

### Prevention
1. Always initialize Firebase before any Firestore operations
2. Set Firestore settings only once during app initialization
3. Use proper error handling for all database operations
4. Test offline scenarios during development

### Verification Steps
1. ✅ Firebase initialization works
2. ✅ Error handling displays properly
3. ✅ Loading states work correctly
4. ✅ Retry functionality works
5. ✅ Data loads from server

### Common Error Messages & Solutions

| Error | Solution |
|-------|----------|
| "local data has not been initialized" | Apply Firestore settings fix |
| "FirebaseException: FAILED_PRECONDITION" | Clear app cache |
| "Stream error in getTransaksi" | Check internet connection |
| "Settings have already been set" | Ignore - this is expected |

---

**Status**: Fixed with Firestore initialization and error handling improvements
**Last Updated**: October 2024
