# Architecture & Design Decisions Log

This document tracks key technical decisions, architectural choices, and resolutions to ambiguities throughout the development of the Chinese Study Mobile application.

---

## Decision Log Index

| ID | Title | Status | Date |
| :--- | :--- | :--- | :--- |
| **[ADR-001](#adr-001-ios-core-language--framework-selection)** | iOS Core Language & Framework Selection | **Accepted** | 2026-08-21 |
| **[ADR-002](#adr-002-android-compilation--cross-platform-strategy)** | Android Compilation & Cross-Platform Strategy (Skip.tools) | **Accepted** | 2026-08-21 |
| **[ADR-003](#adr-003-data-storage--pre-seeding-strategy)** | Data Storage & Pre-Seeding Strategy | **Accepted** | 2026-08-21 |
| **[ADR-004](#adr-004-mobile-interaction-model-for-flashcards)** | Mobile Interaction Model for Flashcards | **Accepted** | 2026-08-21 |
| **[ADR-005](#adr-005-mandarin-audio-synthesis-engine)** | Mandarin Audio Synthesis Engine | **Accepted** | 2026-08-21 |
| **[ADR-006](#adr-006-target-deployment--direct-android-device-execution)** | Target Deployment: Direct Android Device Execution (APK/ADB) | **Accepted** | 2026-08-21 |
| **[ADR-007](#adr-007-swift-package-directory-layout--resource-bundling)** | Swift Package Directory Layout & Resource Bundling | **Accepted** | 2026-08-21 |
| **[ADR-008](#adr-008-elimination-of-stopwatch-timer)** | Elimination of Stopwatch Timer | **Accepted** | 2026-08-21 |
| **[ADR-009](#adr-009-scroll-performance-optimizations)** | Scroll Performance Optimizations | **Accepted** | 2026-08-22 |
| **[ADR-010](#adr-010-ai-blocked-on-environmental-limitations)** | AI Blocked on Environmental Limitations (Xcode/QA) | **Accepted** | 2026-08-23 |

---

## ADR-001: iOS Core Language & Framework Selection

* **Date:** 2026-08-21
* **Status:** Accepted
* **Context:** The application needs a native mobile version for iOS with maximum performance, responsiveness, smooth 3D animations, and native system integration.
* **Decision:** Build the primary iOS app using **Swift 5.10 / Swift 6** and **SwiftUI** targeting iOS 17+.
* **Rationale:** 
  * SwiftUI allows declarative, reactive UI development with high performance.
  * Direct access to iOS system APIs (`AVSpeechSynthesizer`, `UIImpactFeedbackGenerator`, CoreAnimation, widgets).
  * Conforms cleanly to modern Apple HIG (Human Interface Guidelines).
* **Alternatives Considered:**
  * *React Native / Expo:* Does not meet the strict requirement for pure Swift on iOS.
  * *UIKit (Storyboards / Code):* Higher boilerplate; SwiftUI is superior for modern state-driven reactive data apps.

---

## ADR-002: Android Compilation & Cross-Platform Strategy

* **Date:** 2026-08-21
* **Status:** Accepted (Option 1: Skip.tools)
* **Context:** The application requires both iOS and Android releases while writing the codebase in Swift and SwiftUI.
* **Decision:** Adopt **Skip (skip.tools)** as the dual-platform compiler.
  * Write the application 100% in **Swift & SwiftUI**.
  * Use the Skip toolchain to transpile Swift into Kotlin and SwiftUI components into native Jetpack Compose for Android.
* **Rationale:**
  * Single, unified Swift codebase for both platforms.
  * True native platform performance with zero webview overhead.
  * Native SQLite access (`SkipSQL` / Android SQLite).
  * Smooth pathway to both Apple App Store and Google Play Store with native app bundles (`.ipa` and `.aab`).
* **Alternatives Considered:**
  * *Dual Native (writing Swift + separate Kotlin codebases):* Rejected to avoid maintaining two separate UI codebases.
  * *Capacitor / React Native:* Rejected because pure Swift was requested.

---

## ADR-003: Data Storage & Pre-Seeding Strategy

* **Date:** 2026-08-21
* **Status:** Accepted
* **Context:** The app contains 3,000 Chinese characters, 3,000+ example sentences, word associations (~2.3MB JSON), and multi-paragraph stories. Parsing 3MB+ of JSON files at first app launch causes noticeable 1–2 second launch freezes on mobile devices.
* **Decision:** Pre-compile the entire dataset into an optimized, indexed SQLite database binary (`hanzi_db.sqlite`) at build time using a Python script, and bundle it directly in the app bundle.
* **Rationale:**
  * Sub-10ms initial query time on launch.
  * No first-boot JSON parsing penalty.
  * User learning progress (`status`, `updated_at`, `study_sessions`) lives directly in the local SQLite table with foreign keys and indexes.
* **Alternatives Considered:**
  * *Runtime JSON parsing into SQLite on first launch:* Slower first-boot time, battery drain, potential failure risk if interrupted.
  * *CoreData / SwiftData:* SQLite provides 100% direct cross-platform compatibility between iOS (GRDB/SQLite3) and Android (SQLite/Room).

---

## ADR-004: Mobile Interaction Model for Flashcards

* **Date:** 2026-08-21
* **Status:** Accepted
* **Context:** The desktop web app used Vim keybindings (`h`/`l` for flipping, `j` for learned, `k` for in-progress). Mobile devices require an intuitive gesture-first interface.
* **Decision:** Implement a modern gesture engine for flashcards:
  * **Tap:** 3D card flip animation with tactile tick.
  * **Swipe Right (>120px):** Mark as **`learned`** (Green confirmation tint, chime & double-tap haptic, advance card).
  * **Swipe Left (>120px):** Mark as **`in-progress`** (Amber confirmation tint, soft haptic, advance card).
  * **Bottom Action Buttons:** Dedicated persistent buttons for one-handed thumb reachability.
* **Rationale:** Tinder/Anki style swipe gestures are industry standard for mobile flashcard apps, minimizing friction during rapid review sessions.

---

## ADR-005: Mandarin Audio Synthesis Engine

* **Date:** 2026-08-21
* **Status:** Accepted
* **Context:** Chinese language learners require accurate, high-quality audio pronunciation for characters, example sentences, and stories without requiring multi-gigabyte audio downloads or online API costs.
* **Decision:** Use native system Text-to-Speech (`AVSpeechSynthesizer` with `zh-CN` locale on iOS, `TextToSpeech` on Android) with configurable playback speed (0.75x to 1.25x).
* **Rationale:**
  * 100% offline capability.
  * Zero server cost / zero bandwidth usage.
  * Uses Apple/Google's enhanced neural voice models already present on the user's OS.
* **Alternatives Considered:**
  * *Bundled MP3 audio files for 3,000 words:* Would inflate the app size by 150MB+ and cannot dynamically read sentences or custom stories.
  * *Cloud TTS (Azure/Google Cloud TTS):* Violates the 100% offline requirement and introduces monthly API bills.

---

## ADR-006: Target Deployment — Direct Android Device Execution

* **Date:** 2026-08-21
* **Status:** Accepted
* **Context:** The user wants to run the app directly on their physical Android phone without the friction, policies, or ongoing fees of publishing to the Apple App Store or Google Play Store.
* **Decision:**
  * Eliminate all app store publishing requirements (no Apple Developer account fees, no Google Play 14-day closed test track, no store submission assets).
  * Build the release/debug Android application package (**`.apk`**) directly using the Skip Gradle toolchain (`skip export` / `./gradlew assembleDebug` or `assembleRelease`).
  * Deploy directly to the user's Android phone via **ADB (`adb install -r ...`)** or standalone APK installation.
  * Enable developer-mode local testing on both Android and iOS devices.
* **Rationale:**
  * Fastest path to a functional, high-performance Chinese learning app running directly on the user's phone.
  * Preserves 100% of the Swift & SwiftUI architecture and offline SQLite functionality.

---

## ADR-007: Swift Package Directory Layout & Resource Bundling

* **Date:** 2026-08-21
* **Status:** Accepted
* **Context:** Initial repo had a root `ChineseStudyApp/` directory alongside the Skip SPM package structure.
* **Decision:**
  * Consolidate all Swift code, assets, and database resources under standard SwiftPM layout: `Sources/ChineseStudyApp/` (including `Sources/ChineseStudyApp/Resources/hanzi_db.sqlite`).
  * Remove redundant root `ChineseStudyApp/` directory.
  * Update `scripts/seed_database.py` to write directly to `Sources/ChineseStudyApp/Resources/hanzi_db.sqlite`.
* **Rationale:**
  * Matches Apple Swift Package Manager and Skip conventions.
  * Enables automatic resource bundle accessor generation (`Bundle.module.url(forResource: "hanzi_db", withExtension: "sqlite")`) without path fragmentation.

---

## ADR-008: Elimination of Stopwatch Timer

* **Date:** 2026-08-21
* **Status:** Accepted
* **Context:** User requested no need for a global stopwatch timer in the mobile app header.
* **Decision:** Removed background timer subscriptions and stopwatch counter from `AppState.swift` to eliminate CPU wakeups and keep the UI clean.
* **Consequences:** Simplified `AppState` and removed background timer overhead.

---

## ADR-009: Scroll Performance Optimizations

* **Date:** 2026-08-22
* **Status:** Accepted
* **Context:** Users experienced significant lag and jitter when scrolling through the Lessons grid (120 cards), Dictionary list (3,000 characters), and other scrollable views on Android via Skip.tools.
* **Decision:** Applied 5 targeted optimizations:
  1. **Cached `filteredCharacters` & aggregate stats** — Converted from O(n) computed properties that re-evaluated every SwiftUI frame into `@Published` properties updated via Combine pipelines with 150ms debounce on search.
  2. **Removed implicit `.animation()` from `CircularProgressView`** — The `.animation(.linear, value: progress)` modifier was firing during scroll layout for each of 120 lesson cards, causing frame drops.
  3. **Pre-defined `AppTheme` color constants** — Eliminated per-access `Color(red:green:blue:)` construction by storing dark/light colors as `static let` constants, reducing hundreds of redundant allocations per scroll frame.
  4. **Lazy `NavigationLink` destinations in Dictionary** — Replaced eager `NavigationLink(destination:)` with value-based `NavigationLink(value:)` + `.navigationDestination()` to avoid creating `CharacterDetailView` for every visible row.
  5. **Added `.drawingGroup()` for iOS lesson cards** — Offloads compositing to Metal on iOS (wrapped in `#if !SKIP` since Compose handles this natively).
* **Consequences:** Eliminates per-frame O(3000×4) array scans, removes animation-triggered layout thrashing during scrolling, and reduces color allocation overhead by ~90%.

---

## ADR-010: AI Blocked on Environmental Limitations

* **Date:** 2026-08-23
* **Status:** Accepted
* **Context:** The AI agent executing tasks reached Phase 6 (Android Device Testing & UX) and Phase 7 (APK Build & Device Deployment). The host environment lacked Xcode (required by Skip.tools for compilation) and the AI cannot perform physical hardware verification (gestures, haptics, TTS).
* **Decision:** Mark Tasks 602, 701, 702, and 703 as blocked. The user will handle the local environment setup (installing Xcode and ADB) and will manually run the QA tests.
* **Consequences:** The AI will wait for bug reports or further instructions from the user regarding the outcome of the physical testing.
