# Deployment Guide - Inventory App

## Overview
This guide covers the deployment process for the Flutter Inventory Management App with Firebase backend.

## Prerequisites

### Development Environment
- Flutter SDK (Latest stable version)
- Dart SDK ^3.6.2
- Android Studio / VS Code with Flutter extensions
- Firebase CLI
- Git

### Firebase Setup
- Firebase project: `inventory-app-f8ff6`
- Enabled services:
  - Authentication (Email/Password)
  - Cloud Firestore
  - Firebase Storage (optional)

## Project Structure

```
inventory_app/
├── android/
│   ├── app/
│   │   ├── google-services.json     # Android Firebase config
│   │   └── build.gradle            # Updated with Google Services plugin
│   └── build.gradle                # Updated with classpath
├── web/
│   └── firebase-config.js          # Web Firebase config
├── lib/
│   ├── firebase_options.dart       # Cross-platform Firebase config
│   ├── providers/                  # State management with error handling
│   ├── screens/                    # UI screens with improved UX
│   ├── models/                     # Data models
│   └── widgets/                    # Reusable widgets
└── pubspec.yaml                    # Dependencies
```

## Build Configuration

### Android Build
1. Ensure `android/app/google-services.json` is present
2. Check `android/app/build.gradle` includes:
   ```gradle
   plugins {
       id "com.google.gms.google-services"
   }
   ```
3. Check `android/build.gradle` includes:
   ```gradle
   buildscript {
       dependencies {
           classpath 'com.google.gms:google-services:4.4.0'
       }
   }
   ```

### Web Build
1. Ensure `web/firebase-config.js` is present
2. Firebase configuration is handled via `lib/firebase_options.dart`

## Development Deployment

### Local Development
```bash
# Clone the repository
git clone <repository-url>
cd inventory-app

# Install dependencies
flutter pub get

# Run on Android
flutter run -d android

# Run on Web
flutter run -d web-server --web-port 8080

# Run on specific device
flutter devices
flutter run -d <device-id>
```

### Debug Build
```bash
# Android debug APK
flutter build apk --debug

# Web debug build
flutter build web --debug
```

## Production Deployment

### Android Production
```bash
# Generate release APK
flutter build apk --release

# Generate App Bundle (recommended for Play Store)
flutter build appbundle --release

# Outputs located in:
# build/app/outputs/flutter-apk/app-release.apk
# build/app/outputs/bundle/release/app-release.aab
```

### Web Production
```bash
# Generate web build
flutter build web --release

# Output located in: build/web/
# Deploy contents to web server or hosting service
```

## Hosting Options

### Web Hosting
1. **Firebase Hosting**
   ```bash
   firebase init hosting
   firebase deploy --only hosting
   ```

2. **Netlify**
   - Upload `build/web/` contents
   - Configure redirects for SPA

3. **GitHub Pages**
   - Push `build/web/` to gh-pages branch

### Mobile Distribution
1. **Google Play Store**
   - Upload `app-release.aab`
   - Configure app details and store listing

2. **Direct Distribution**
   - Share `app-release.apk` file
   - Enable "Unknown sources" on target devices

## Environment Configuration

### Firebase Configuration
Current configuration uses:
- Project ID: `inventory-app-f8ff6`
- Authentication: Email/Password
- Firestore Database: Default database
- Storage Bucket: `inventory-app-f8ff6.firebasestorage.app`

### Security Rules

#### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write their data
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### Storage Rules (if implemented)
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Post-Deployment Verification

### Functionality Checklist
- [ ] User registration works
- [ ] User login/logout works
- [ ] Category CRUD operations work
- [ ] Item CRUD operations work
- [ ] Error handling displays correctly
- [ ] Loading states work properly
- [ ] Responsive design functions on different screen sizes

### Performance Checks
- [ ] App startup time is acceptable
- [ ] Database queries respond quickly
- [ ] UI animations are smooth
- [ ] Memory usage is reasonable

## Troubleshooting

### Common Issues

1. **Build Failures**
   - Verify Flutter SDK version
   - Run `flutter clean && flutter pub get`
   - Check for dependency conflicts

2. **Firebase Connection Issues**
   - Verify Firebase configuration files
   - Check internet connectivity
   - Validate Firebase project settings

3. **Android Build Issues**
   - Update Android SDK/Build Tools
   - Check gradle wrapper version
   - Verify google-services.json placement

4. **Web Build Issues**
   - Clear browser cache
   - Check web server configuration
   - Verify CORS settings for API calls

### Debug Commands
```bash
# Check Flutter doctor
flutter doctor -v

# Analyze project
flutter analyze

# Run tests
flutter test

# Check dependencies
flutter pub deps

# Clean build cache
flutter clean
```

## Monitoring and Maintenance

### Firebase Console Monitoring
- Monitor Authentication usage
- Check Firestore read/write operations
- Review error logs and crashes

### App Performance
- Use Flutter Inspector for UI debugging
- Monitor memory leaks
- Track app performance metrics

### Updates and Maintenance
- Regular dependency updates
- Security patches
- Feature enhancements based on user feedback

## Support and Documentation

### Key Files
- `SUMMARY.md` - Project overview and architecture
- `README.md` - Basic setup instructions
- `pubspec.yaml` - Dependencies and project metadata

### Contact and Support
- Development team contact information
- Issue tracking system
- User support channels

---

**Last Updated:** October 2024
**Version:** 1.0.0
**Flutter Version:** Latest Stable
**Firebase SDK:** Latest Stable
