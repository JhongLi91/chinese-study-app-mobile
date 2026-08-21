# Master Execution Plan: Chinese Study Mobile

## Overview & Delegation Strategy

This document defines the high-level work breakdown structure (WBS) for building and shipping the **Chinese Study Mobile** application (iOS in Swift/SwiftUI + Android via Skip). 

Each task is structured as a self-contained work package designed for direct assignment to specialized subagents.

---

## Task Progress Tracker

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  Phase 1: Project Scaffolding & Database Bundling          [x] 100% (2/2)  │
│  Phase 2: Data Models & SQLite Storage Engine              [x] 100% (3/3)  │
│  Phase 3: Core Mobile Services (Audio, Haptics, Backup)    [x] 100% (3/3)  │
│  Phase 4: Domain ViewModels & State Management             [x] 100% (4/4)  │
│  Phase 5: SwiftUI Presentation Views & Gestures            [ ] 12% (1/8)   │
│  Phase 6: Android Build & Dual-Platform Verification       [ ] 0% (0/2)    │
│  Phase 7: Direct Device Deployment & APK Sideloading       [ ] 0% (0/3)    │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Project Scaffolding & Database Pipeline

- [x] **TASK-101: Skip / Xcode Project Scaffolding**
  * **Objective:** Scaffold the dual-platform Swift Package / Xcode project using the Skip toolchain targeting iOS 17+ and Android API 34+.
  * **Key Deliverables:** `Package.swift`, `ChineseStudyApp.xcodeproj` or Skip module structure, bundle identifiers (`com.jhli.chinesestudy`).
  * **Dependencies:** Skip CLI, Xcode, OpenJDK.
  * **Acceptance Criteria:** `skip checkup` passes cleanly and an empty SwiftUI "Hello World" builds and runs.
  * **Delegation Target:** Infrastructure / Setup Agent.

- [x] **TASK-102: Binary Database Pipeline & Asset Bundling**
  * **Objective:** Verify and bundle the pre-compiled `hanzi_db.sqlite` database (containing 3,000 characters, 8,868 word associations, and 6 HSK stories) into the app bundle resources.
  * **Key Deliverables:** `Sources/ChineseStudyApp/Resources/hanzi_db.sqlite`, asset catalogs for colors and tone markers.
  * **Dependencies:** `scripts/seed_database.py`.
  * **Acceptance Criteria:** The bundled `.sqlite` file is under 2.5 MB and queryable from app bundle resources.
  * **Delegation Target:** Data Agent.

---

## Phase 2: Data Models & SQLite Storage Engine

- [x] **TASK-201: Swift Domain Models Definition**
  * **Objective:** Create complete Swift models conforming to `Identifiable`, `Codable`, `Hashable`, and `Sendable`.
  * **Key Deliverables:** 
    * `Models/Character.swift` (Hanzi, Pinyin, Definition, Radical, HSK Level, StudyStatus)
    * `Models/LessonInfo.swift` (120 lessons, card count, mastery metrics)
    * `Models/Story.swift` (Stories, paragraphs, sentences, comprehension questions)
    * `Models/WordAssociation.swift` (Compound words, matching pairs)
    * `Models/StudySession.swift` (Session duration, cards reviewed)
  * **Acceptance Criteria:** All data types from web app are accurately mapped with zero compilation warnings.
  * **Delegation Target:** Core Data Agent.

- [x] **TASK-202: SQLite Database Manager & Connection Layer (SkipSQL)**
  * **Objective:** Implement a thread-safe SQLite connection manager using **SkipSQL** (`skiptools/skip-sql`) / SQLite3 that copies the pre-seeded `hanzi_db.sqlite` from app bundle to app sandbox on first run, enabling unified read/write capabilities across iOS and Android.
  * **Key Deliverables:** `Database/DatabaseManager.swift`.
  * **Dependencies:** TASK-102, TASK-201.
  * **Acceptance Criteria:** Reads 3,000 characters in <15ms; persists updates without data loss across app relaunches on both iOS and Android.
  * **Delegation Target:** Core Data Agent.

- [x] **TASK-203: Learning Progress & Session Repository**
  * **Objective:** Implement CRUD queries for character status transitions (`new` ➔ `in-progress` ➔ `learned`), lesson progress calculations, and study session logging.
  * **Key Deliverables:** `Database/ProgressRepository.swift` or repository methods in `DatabaseManager`.
  * **Dependencies:** TASK-202.
  * **Acceptance Criteria:** Status changes update in SQLite instantly with millisecond timestamps; lesson stats update reactively.
  * **Delegation Target:** Core Data Agent.

---

## Phase 3: Core Mobile Services (Audio, Haptics, Backup)

- [x] **TASK-301: Native Mandarin Audio & Sound Synthesis Engine**
  * **Objective:** Build an audio engine combining native Mandarin Text-To-Speech (`AVSpeechSynthesizer` with `zh-CN` voice) and synthesized tactile UI sound effects (flip, learned chime, in-progress thud, victory chord).
  * **Key Deliverables:** `Services/AudioService.swift`.
  * **Dependencies:** AVFoundation.
  * **Acceptance Criteria:** Speaks Chinese characters and full sentences with adjustable speech rate (0.75x–1.25x); sound effects trigger with <5ms latency.
  * **Delegation Target:** Services Agent.

- [x] **TASK-302: Tactile Haptics Feedback Engine**
  * **Objective:** Build a haptics generator providing distinct tactile feedback for card flipping, marking learned (success chime + medium haptic), marking in-progress, and game streaks.
  * **Key Deliverables:** `Services/HapticService.swift`.
  * **Dependencies:** CoreHaptics / UIKit / Android Vibrator.
  * **Acceptance Criteria:** Provides smooth, non-intrusive haptic feedback matching user gestures on supported devices.
  * **Delegation Target:** Services Agent.

- [x] **TASK-303: Progress Backup & Migration Service**
  * **Objective:** Implement a backup engine to export user learning progress to a portable JSON backup file (shareable via iOS Share Sheet) and restore from an existing backup.
  * **Key Deliverables:** `Services/BackupService.swift`.
  * **Dependencies:** TASK-203.
  * **Acceptance Criteria:** Exports progress snapshot; successfully restores progress with checksum verification.
  * **Delegation Target:** Services Agent.

---

## Phase 4: Domain ViewModels & State Management

- [x] **TASK-401: Global AppState & Study Timer ViewModel**
  * **Objective:** Manage top-level environment state (active tab selection, audio sound toggle, global stopwatch timer, search query state).
  * **Key Deliverables:** `App/AppState.swift`.
  * **Acceptance Criteria:** Stopwatch persists when switching tabs; sound toggle globally enables/mutes audio.
  * **Delegation Target:** ViewModel Agent.

- [x] **TASK-402: StudyDataViewModel (Curriculum & Review Manager)**
  * **Objective:** Coordinate lessons list, card queue for the active lesson, learned list, in-progress list, and batch status mutations.
  * **Key Deliverables:** `ViewModels/StudyDataViewModel.swift`.
  * **Dependencies:** TASK-203.
  * **Acceptance Criteria:** Instant filtering across 3,000 characters; reactive updates to all view subscribers.
  * **Delegation Target:** ViewModel Agent.

- [x] **TASK-403: StoryViewModel (Reading & Comprehension Manager)**
  * **Objective:** Manage story catalog, sentence-by-sentence audio playback, pinyin mode (`ruby`, `line`, `none`), English translation visibility, and quiz score tracking.
  * **Key Deliverables:** `ViewModels/StoryViewModel.swift`.
  * **Dependencies:** TASK-202, TASK-301.
  * **Acceptance Criteria:** Synchronizes audio reading with highlighted sentence; validates quiz answers with explanations.
  * **Delegation Target:** ViewModel Agent.

- [x] **TASK-404: WordMatchViewModel (Mini-Game Logic)**
  * **Objective:** Handle 4x4 / 6x6 / 8x8 pairing grid generation from studied characters, selection state, match validation, streak multipliers, and high score calculation.
  * **Key Deliverables:** `ViewModels/WordMatchViewModel.swift`.
  * **Dependencies:** TASK-201, TASK-301.
  * **Acceptance Criteria:** Pairs match correctly; wrong matches flash red; round completion triggers victory sound and confetti state.
  * **Delegation Target:** ViewModel Agent.

---

## Phase 5: SwiftUI Presentation Views & Gestures

- [x] **TASK-501: Navigation Shell & Bottom Tab Bar**
  * **Objective:** Create the main mobile navigation framework (`TabView`) with tabs: 📚 Lessons, 🃏 Flashcards, 📖 Stories, 🎮 Match, 📊 Review & Settings.
  * **Key Deliverables:** `Views/MainTabView.swift`, `Components/StopwatchHeaderView.swift`.
  * **Dependencies:** TASK-401.
  * **Acceptance Criteria:** Smooth tab switching, persistent stopwatch banner in navigation bar.
  * **Delegation Target:** UI Agent.

- [ ] **TASK-502: Lessons Grid & Progress View**
  * **Objective:** Build the 120-lesson grid with circular progress indicators, status badges (Learned / In-Progress / New), and quick start action.
  * **Key Deliverables:** `Views/Lessons/LessonsGridView.swift`, `Views/Lessons/LessonCardItemView.swift`, `Components/CircularProgressView.swift`.
  * **Dependencies:** TASK-402.
  * **Acceptance Criteria:** Fluid scrolling across 120 lessons, accurate percentage completion rings.
  * **Delegation Target:** UI Agent.

- [ ] **TASK-503: Interactive Flashcard Study Deck with Touch Gestures**
  * **Objective:** Build the interactive flashcard deck replacing Vim keybindings with mobile touch gestures:
    * Tap to 3D flip card (`rotation3DEffect`)
    * Swipe Right (>120px) to mark **Learned**
    * Swipe Left (>120px) to mark **In-Progress**
    * Bottom thumbnail scrubber to jump between cards
    * Pronunciation speaker button
  * **Key Deliverables:** `Views/Flashcards/FlashcardStudyView.swift`, `Views/Flashcards/FlashcardView.swift`, `Views/Flashcards/ExampleSentenceSheet.swift`, `Views/Flashcards/CardScrubberView.swift`.
  * **Dependencies:** TASK-301, TASK-302, TASK-402.
  * **Acceptance Criteria:** 60/120fps spring animation on swipes; interactive example sentence sheet with native Mandarin audio playback.
  * **Delegation Target:** UI Agent.

- [ ] **TASK-504: Graded Story Reader & Character Inspector**
  * **Objective:** Implement the story reader with ruby pinyin annotations, paragraph translation toggles, continuous narration controls, and interactive Hanzi tap-to-inspect dictionary sheet.
  * **Key Deliverables:** `Views/Stories/StoryCatalogView.swift`, `Views/Stories/StoryDetailReaderView.swift`, `Views/Stories/CharacterInspectorSheet.swift`, `Views/Stories/StoryQuizView.swift`.
  * **Dependencies:** TASK-403.
  * **Acceptance Criteria:** Tapping any Hanzi inside the story text displays definition, rank, and study status in a bottom sheet.
  * **Delegation Target:** UI Agent.

- [ ] **TASK-505: Word Match Mini-Game View**
  * **Objective:** Build the interactive matching game UI with animated card tiles, streak counter, combo multipliers, and celebration screen.
  * **Key Deliverables:** `Views/WordMatch/WordMatchGameView.swift`, `Views/WordMatch/MatchCardTile.swift`.
  * **Dependencies:** TASK-404.
  * **Acceptance Criteria:** Grid scales gracefully on iPhone and iPad/tablet screens; haptics on selection and match.
  * **Delegation Target:** UI Agent.

- [ ] **TASK-506: Searchable Vocabulary Lists & Batch Operations**
  * **Objective:** Build filterable vocabulary tables for Learned, In-Progress, and All 3,000 characters with real-time search (by Hanzi, Pinyin, English) and HSK filters.
  * **Key Deliverables:** `Views/Vocab/VocabListView.swift`, `Views/Vocab/VocabRowView.swift`.
  * **Dependencies:** TASK-402.
  * **Acceptance Criteria:** Instant debounced search; swipe actions on list rows to change status.
  * **Delegation Target:** UI Agent.

- [ ] **TASK-507: Randomized Flashcard Quiz Modal**
  * **Objective:** Implement customizable flashcard quizzes launched from any word list or lesson.
  * **Key Deliverables:** `Views/Quiz/QuickQuizModalView.swift`.
  * **Dependencies:** TASK-402, TASK-503.
  * **Acceptance Criteria:** Shuffles cards randomly; presents score summary and review breakdown at end of quiz.
  * **Delegation Target:** UI Agent.

- [ ] **TASK-508: Settings & Backup View**
  * **Objective:** Create the Settings view for audio speed adjustments, sound effects toggle, data backup/restore, and HSK curriculum information.
  * **Key Deliverables:** `Views/Settings/SettingsView.swift`, `Views/Settings/DatabaseBackupView.swift`.
  * **Dependencies:** TASK-303, TASK-401.
  * **Acceptance Criteria:** Backups export and import smoothly via system share sheets.
  * **Delegation Target:** UI Agent.

---

## Phase 6: Android Build & Dual-Platform Verification

- [ ] **TASK-601: Skip Android Transpilation & Gradle Configuration**
  * **Objective:** Configure Skip toolchain to transpile the Swift/SwiftUI components into Kotlin/Jetpack Compose and configure `build.gradle.kts` for Android target.
  * **Key Deliverables:** `Android/build.gradle.kts`, Skip bridge configuration.
  * **Dependencies:** Phase 1 through Phase 5.
  * **Acceptance Criteria:** `skip build --android` succeeds without transpilation errors.
  * **Delegation Target:** Android / Multiplatform Agent.

- [ ] **TASK-602: Android Device / Emulator Testing & UX Verification**
  * **Objective:** Run the Android build on an Android emulator/device to verify touch gestures, audio TTS, SQLite performance, and layout responsiveness.
  * **Key Deliverables:** QA report and platform compatibility adjustments.
  * **Acceptance Criteria:** App runs smoothly at 60fps on Android with zero crashes.
  * **Delegation Target:** QA / Multiplatform Agent.

---

## Phase 7: Direct Device Deployment & APK Sideloading

- [ ] **TASK-701: Standalone APK Packaging & Release Build**
  * **Objective:** Configure Gradle release/debug signing and generate a standalone installable `.apk` package using Skip export (`skip export --android`).
  * **Key Deliverables:** `Android/app/build/outputs/apk/debug/app-debug.apk` or release `.apk`.
  * **Dependencies:** TASK-601.
  * **Acceptance Criteria:** Produces a valid, signed `.apk` file ready for manual installation or distribution.
  * **Delegation Target:** Build / Release Agent.

- [ ] **TASK-702: Direct ADB Deployment & Phone Verification**
  * **Objective:** Connect user's Android phone via USB/Wi-Fi ADB and install the app (`adb install -r ...`), verifying app launch and SQLite loading on hardware.
  * **Key Deliverables:** Deployment scripts (`scripts/deploy_android.sh`), installation guide.
  * **Dependencies:** TASK-701.
  * **Acceptance Criteria:** App launches instantly on user's physical Android phone with full 3,000 character database.
  * **Delegation Target:** Deployment Agent.

- [ ] **TASK-703: Hardware Audio & Touch Gesture Validation on Physical Phone**
  * **Objective:** Test native Mandarin Text-To-Speech audio pronunciation, card swipe gestures, and haptic engine on the physical Android hardware.
  * **Key Deliverables:** Device verification checklist & performance report.
  * **Dependencies:** TASK-702.
  * **Acceptance Criteria:** Mandarin TTS speaks sentences clearly, touch gestures feel responsive with 60fps animations.
  * **Delegation Target:** QA Agent.
