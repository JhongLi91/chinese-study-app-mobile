# Chinese Study Mobile

An offline-first Chinese study app (3,000 Hanzi, 120 lessons, stories, flashcards, match game) developed entirely in Swift and SwiftUI.

This project uses [Skip](https://skip.tools/) to compile the Swift codebase into a native Android app, allowing a single Swift codebase to run on both iOS and Android natively.

## Features

- **Offline-First**: Zero network dependencies; all data, audio, and stories work completely offline.
- **Embedded Database**: Pre-compiled SQLite database via SkipSQL.
- **Native Audio**: Mandarin TTS (Text-to-Speech) and sound effects.
- **Cross-Platform**: Builds native iOS (Swift/SwiftUI) and native Android (Kotlin/Compose via Skip).

## Prerequisites

- macOS with **Xcode** installed.
- **Skip CLI** installed.
- **Python 3** (for database seeding scripts).
- **Android Studio** or Android SDK (for Android deployment).

## Setup

1. **Verify Skip Installation:**
   ```bash
   skip checkup
   ```

2. **Initialize the Database:**
   Rebuild the binary SQLite database using the provided Python script before running the app:
   ```bash
   python3 scripts/seed_database.py
   ```

## Build and Run

### iOS
1. Open [`Project.xcworkspace`](./Project.xcworkspace) in Xcode.
2. Select an iOS Simulator or connected iOS device as the run destination.
3. Click the **Run** button (`Cmd + R`).

### Android
Ensure you have an Android device connected via ADB or an Android Emulator running.

**Option 1: Using Android Studio**
1. Open Android Studio.
2. Select **Open** and choose the [`Android/`](./Android/) directory in this project.
3. Sync the Gradle project if prompted.
4. Select your Android device/emulator and click the **Run** button.

**Option 2: Command Line**
1. Open a terminal and navigate to the `Android` directory:
   ```bash
   cd Android
   ```
2. Build the APK and install it to your connected device:
   ```bash
   ./gradlew installDebug
   ```
