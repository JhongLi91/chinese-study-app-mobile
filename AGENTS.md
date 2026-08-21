# Agent Memory: Chinese Study Mobile

## 🚨 PRIME DIRECTIVE: NEVER ASSUME OR GUESS
* **Technical / API uncertainty:** Research online and check official docs (Skip, Apple, Android) before writing code. Never hallucinate APIs.
* **Requirements / Design ambiguity:** Stop and ask the user for clarification with clear options and a recommendation.
* **Log decisions:** Record all approved choices in [`.agents/decisions.md`](./.agents/decisions.md).

---

## 1. Project & Stack
* **App:** Offline-first Chinese study app (3,000 Hanzi, 120 lessons, stories, flashcards, match game).
* **Language & Core:** Developed 100% in **Swift 5.10 / 6** + **SwiftUI**.
* **Primary Target:** Compiling Swift to native Android via **Skip.tools** (`skip.tools`) to run directly on an Android device via APK / ADB (as well as iOS).
* **Database:** Pre-compiled SQLite (`Sources/ChineseStudyApp/Resources/hanzi_db.sqlite`) via SkipSQL.
* **Audio:** Native Mandarin TTS (`AVSpeechSynthesizer` with `zh-CN` / Android TTS) + sound effects.
* **Deployment:** Direct APK installation / ADB sideloading on Android phone (no App Store / Google Play requirements).

---

## 2. Directory Structure
```
chinese-study-mobile/
├── AGENTS.md                  # This memory file
├── .agents/
│   ├── plan.md                # Master task tracker & WBS
│   ├── implementation-plan.md # Full technical specification
│   └── decisions.md           # Architecture Decision Records (ADRs)
├── scripts/seed_database.py   # Pre-compiles JSON data into binary SQLite DB
├── Sources/ChineseStudyApp/   # App, Models, Database, Services, ViewModels, Views, Resources
├── Darwin/                    # iOS app wrapper & Xcode project
└── Android/                   # Skip build & Gradle config
```

---

## 3. Strict Coding & Architecture Rules
1. **Swift Concurrency:** Mark ViewModels with `@MainActor`. Ensure models conform to `Sendable`.
2. **Layering:** Never write raw SQL in Views. Route all queries through `DatabaseManager`.
3. **Transactions:** Wrap batch status updates in `BEGIN TRANSACTION` / `COMMIT`.
4. **Offline Guarantee:** Zero network dependencies. All data, audio, and stories must work offline.
5. **Mobile Gestures:** Tap = 3D flip card, Swipe Right = Learned, Swipe Left = In-Progress.
6. **Task Discipline:** Check and update task status in [`.agents/plan.md`](./.agents/plan.md) upon completion.

---

## 4. Key Commands
```bash
# Rebuild binary SQLite database
python3 scripts/seed_database.py

# Verify SQLite database
sqlite3 Sources/ChineseStudyApp/Resources/hanzi_db.sqlite "SELECT count(*) FROM characters;"

# Check Skip toolchain
skip checkup
```
