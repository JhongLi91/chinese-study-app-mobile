# Antigravity Rules: Chinese Study Mobile

> See full memory & architecture in [`AGENTS.md`](./AGENTS.md).

## 🚨 Anti-Assumption Protocol
* **Never assume or guess.**
* **Technical ambiguity:** Research online / official docs first.
* **Requirement ambiguity:** Ask the user with options and recommendations.
* **Decisions:** Log all choices in [`.agents/decisions.md`](./.agents/decisions.md).

## Core Rules
* **Stack:** 100% Swift & SwiftUI compiled to native Android via Skip.tools (and iOS).
* **Primary Objective:** Build and run seamlessly on the user's Android phone (direct APK/ADB) without store publishing overhead.
* **Storage:** Offline SQLite at `ChineseStudyApp/Database/Resources/hanzi_db.sqlite` via SkipSQL.
* **Architecture:** MVVM (Views -> ViewModels -> Services -> DatabaseManager).
* **Concurrency:** `@MainActor` on ViewModels, `Sendable` models, Swift 6 safe.
* **Tasks:** Follow and update [`.agents/plan.md`](./.agents/plan.md).
