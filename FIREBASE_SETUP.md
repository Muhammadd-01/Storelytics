# Firebase Setup Guide - Storelytics

This document will walk you through setting up Firebase for the Storelytics application.

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed
- [Firebase CLI](https://firebase.google.com/docs/cli#install_the_firebase_cli) installed
- A Google account

---

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name: `storelytics` (or your preferred name)
4. Enable/disable Google Analytics as needed
5. Click **"Create project"**

---

## Step 2: Install & Configure FlutterFire CLI

```bash
# Install FlutterFire CLI globally
dart pub global activate flutterfire_cli

# In your project directory, run:
flutterfire configure --project=YOUR_PROJECT_ID
```

This will:
- Create apps for Android, iOS, and Web in your Firebase project
- Generate `lib/firebase_options.dart` automatically

---

## Step 3: Enable Firebase Services

### Authentication
1. Go to **Firebase Console → Authentication → Sign-in method**
2. Enable **"Email/Password"** provider
3. (Optional) Enable **"Email link (passwordless sign-in)"**

### Cloud Firestore
1. Go to **Firebase Console → Firestore Database**
2. Click **"Create database"**
3. Select **"Start in production mode"**
4. Choose a region close to your users (e.g. `us-central1`, `asia-south1`)

### Deploy Firestore Rules
```bash
firebase deploy --only firestore:rules
```

Or copy the rules from `firestore.rules` into the Firebase Console → Firestore → Rules tab.

---

## Step 4: Create Required Firestore Indexes

Some queries require composite indexes. Firestore will log errors with direct links to create them. Alternatively, create these manually:

| Collection   | Fields                                    | Order                  |
|:-------------|:------------------------------------------|:-----------------------|
| `inventory`  | `storeId` (ASC), `name` (ASC)             |                        |
| `inventory`  | `storeId` (ASC), `category` (ASC)         |                        |
| `inventory`  | `storeId` (ASC), `stockQuantity` (ASC)    |                        |
| `inventory`  | `storeId` (ASC), `expiryDate` (ASC)       |                        |
| `sales`      | `storeId` (ASC), `date` (DESC)            |                        |
| `sales`      | `storeId` (ASC), `itemId` (ASC)           |                        |
| `demands`    | `storeId` (ASC), `timesRequested` (DESC)  |                        |
| `demands`    | `storeId` (ASC), `date` (DESC)            |                        |

---

## Step 5: Update `main.dart`

After running `flutterfire configure`, uncomment these lines in `lib/main.dart`:

```dart
import 'firebase_options.dart';

// Inside main():
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

---

## Step 6: Create Admin User

After your first user signs up:

1. Go to **Firebase Console → Firestore → users collection**
2. Find your user document
3. Change the `role` field from `"owner"` to `"admin"`
4. The user will now have admin access to the admin panel

---

## Step 7: Android Configuration

The `google-services.json` file is automatically placed by FlutterFire CLI. Verify:

- File exists at `android/app/google-services.json`
- `android/build.gradle` has the Google Services plugin
- `android/app/build.gradle` applies the plugin

### SHA-1 Certificate (Required for Auth)
```bash
cd android
./gradlew signingReport
```
Add the SHA-1 fingerprint in Firebase Console → Project Settings → Android app.

---

## Step 8: iOS Configuration (Optional)

- `GoogleService-Info.plist` should be at `ios/Runner/GoogleService-Info.plist`
- Open `ios/Runner.xcworkspace` in Xcode and verify the file is in the Runner target

---

## Step 9: Web Configuration (Optional)

FlutterFire CLI automatically configures `web/index.html`. No additional steps needed.

---

## Running the App

```bash
# Get dependencies
flutter pub get

# Generate Freezed models
dart run build_runner build --delete-conflicting-outputs

# Run on device/emulator
flutter run

# Run on Chrome (web)
flutter run -d chrome
```

---

## Troubleshooting

| Issue | Solution |
|:------|:---------|
| `PlatformException(channel-error)` | Ensure `google-services.json` is correct |
| `MissingPluginException` | Run `flutter clean && flutter pub get` |
| `permission-denied` | Check Firestore rules and user authentication |
| Missing index error | Click the link in the error to create the index |
| Build fails | Run `flutter doctor` and fix any issues |

---

## Production Deployment

For production, consider:
- Enabling App Check for security
- Setting up Firebase Crashlytics
- Configuring Firebase Performance Monitoring
- Setting up CI/CD with Firebase App Distribution
