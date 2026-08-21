#!/usr/bin/env python3
"""
Seed Database Generator for Chinese Study Mobile (iOS & Android)
Compiles 3,000 Hanzi characters, word associations, example sentences, and HSK stories
into a high-performance, pre-indexed binary SQLite database (hanzi_db.sqlite).
"""

import json
import os
import sqlite3
import subprocess
import sys

BASE_WEB_DATA_DIR = "/Users/jhli/Projects/chinese-study/src/data"
OUTPUT_DIR = "/Users/jhli/Projects/chinese-study-mobile/ChineseStudyApp/Database/Resources"
OUTPUT_DB_PATH = os.path.join(OUTPUT_DIR, "hanzi_db.sqlite")

def ensure_dirs():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

def extract_stories():
    stories_ts_path = os.path.join(BASE_WEB_DATA_DIR, "stories.ts")
    node_cmd = f"""
    const fs = require('fs');
    const content = fs.readFileSync('{stories_ts_path}', 'utf8');
    const jsonMatch = content.substring(content.indexOf('export const STORIES: Story[] = ['));
    const jsCode = jsonMatch.replace('export const STORIES: Story[] =', 'const STORIES =') + '\\nconsole.log(JSON.stringify(STORIES));';
    eval(jsCode);
    """
    res = subprocess.run(["node", "-e", node_cmd], capture_output=True, text=True, check=True)
    return json.loads(res.stdout)

def main():
    print("🚀 Initializing Chinese Study SQLite database compilation...")
    ensure_dirs()

    if os.path.exists(OUTPUT_DB_PATH):
        os.remove(OUTPUT_DB_PATH)

    conn = sqlite3.connect(OUTPUT_DB_PATH)
    cursor = conn.cursor()

    # Enable WAL mode and synchronous settings for performance
    cursor.execute("PRAGMA journal_mode = WAL;")

    # 1. Create Tables
    cursor.executescript("""
    CREATE TABLE IF NOT EXISTS characters (
        frequency_rank INTEGER PRIMARY KEY,
        character TEXT NOT NULL,
        pinyin TEXT NOT NULL,
        definition TEXT NOT NULL,
        radical TEXT,
        radical_code TEXT,
        stroke_count INTEGER,
        hsk_level INTEGER,
        lesson_number INTEGER NOT NULL,
        example_zh TEXT,
        example_py TEXT,
        example_en TEXT
    );

    CREATE TABLE IF NOT EXISTS progress (
        character_id INTEGER PRIMARY KEY,
        status TEXT NOT NULL CHECK(status IN ('new', 'in-progress', 'learned')),
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (character_id) REFERENCES characters(frequency_rank) ON DELETE CASCADE
    );

    CREATE TABLE IF NOT EXISTS word_associations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        character_id INTEGER NOT NULL,
        character_char TEXT NOT NULL,
        word TEXT NOT NULL,
        pinyin TEXT NOT NULL,
        meaning TEXT NOT NULL,
        FOREIGN KEY (character_id) REFERENCES characters(frequency_rank)
    );

    CREATE TABLE IF NOT EXISTS stories (
        id TEXT PRIMARY KEY,
        title_zh TEXT NOT NULL,
        title_py TEXT NOT NULL,
        title_en TEXT NOT NULL,
        level TEXT NOT NULL,
        source TEXT NOT NULL,
        lesson_target TEXT NOT NULL,
        description TEXT NOT NULL,
        data_json TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS study_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_type TEXT NOT NULL,
        start_time INTEGER NOT NULL,
        duration_seconds INTEGER NOT NULL,
        cards_reviewed INTEGER NOT NULL,
        created_at INTEGER NOT NULL
    );

    CREATE INDEX IF NOT EXISTS idx_characters_lesson ON characters(lesson_number);
    CREATE INDEX IF NOT EXISTS idx_characters_char ON characters(character);
    CREATE INDEX IF NOT EXISTS idx_characters_hsk ON characters(hsk_level);
    CREATE INDEX IF NOT EXISTS idx_progress_status ON progress(status);
    CREATE INDEX IF NOT EXISTS idx_word_assoc_char_id ON word_associations(character_id);
    CREATE INDEX IF NOT EXISTS idx_word_assoc_word ON word_associations(word);
    """)

    # 2. Load Hanzi 3,000 Data
    hanzi_path = os.path.join(BASE_WEB_DATA_DIR, "hanzi_3000.json")
    with open(hanzi_path, "r", encoding="utf-8") as f:
        hanzi_list = json.load(f)

    # 3. Load Example Sentences (examples_1000.json & examples_2000.json)
    examples_map = {}
    for ex_file in ["examples_1000.json", "examples_2000.json"]:
        ex_path = os.path.join(BASE_WEB_DATA_DIR, ex_file)
        if os.path.exists(ex_path):
            with open(ex_path, "r", encoding="utf-8") as f:
                examples_map.update(json.load(f))

    # Insert Characters
    print(f"📖 Seeding {len(hanzi_list)} characters...")
    for item in hanzi_list:
        rank = item["frequency_rank"]
        char = item["character"]
        ex = examples_map.get(str(rank))
        
        ex_zh, ex_py, ex_en = None, None, None
        if ex:
            ex_zh = ex.get("zh")
            ex_py = ex.get("py")
            ex_en = ex.get("en")
        else:
            # Fallback generated example
            clean_def = item.get("definition", "").split(";")[0].split(",")[0].strip() or "concept"
            ex_zh = f"掌握“{char}”对提高中文阅读能力很有帮助。"
            ex_py = f"Zhǎngwò \"{char}\" duì tígāo zhōngwén yuèdú nénglì hěn yǒu bāngzhù."
            ex_en = f"Mastering \"{char}\" ({clean_def}) is very helpful for improving Chinese reading ability."

        cursor.execute("""
            INSERT INTO characters (
                frequency_rank, character, pinyin, definition, radical, radical_code, stroke_count, hsk_level, lesson_number, example_zh, example_py, example_en
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            rank,
            char,
            item.get("pinyin", ""),
            item.get("definition", ""),
            item.get("radical"),
            item.get("radical_code"),
            item.get("stroke_count"),
            item.get("hsk_level"),
            item.get("lesson_number", (rank - 1) // 25 + 1),
            ex_zh,
            ex_py,
            ex_en
        ))

    # 4. Load Word Associations
    assoc_path = os.path.join(BASE_WEB_DATA_DIR, "word_associations.json")
    if os.path.exists(assoc_path):
        with open(assoc_path, "r", encoding="utf-8") as f:
            assoc_data = json.load(f)
        
        by_rank = assoc_data.get("by_rank", {})
        by_char = assoc_data.get("by_char", {})
        
        print("🔗 Seeding word associations...")
        assoc_rows = []
        # Build character to rank map
        char_to_rank = {item["character"]: item["frequency_rank"] for item in hanzi_list}

        seen_pairs = set()

        for rank_str, words in by_rank.items():
            rank_int = int(rank_str)
            char_str = hanzi_list[rank_int - 1]["character"] if 1 <= rank_int <= len(hanzi_list) else ""
            for w in words:
                key = (rank_int, w.get("word"))
                if key not in seen_pairs:
                    seen_pairs.add(key)
                    assoc_rows.append((rank_int, char_str, w.get("word"), w.get("pinyin"), w.get("meaning")))

        for char_str, words in by_char.items():
            rank_int = char_to_rank.get(char_str, 0)
            for w in words:
                key = (rank_int, w.get("word"))
                if key not in seen_pairs:
                    seen_pairs.add(key)
                    assoc_rows.append((rank_int, char_str, w.get("word"), w.get("pinyin"), w.get("meaning")))

        cursor.executemany("""
            INSERT INTO word_associations (character_id, character_char, word, pinyin, meaning)
            VALUES (?, ?, ?, ?, ?)
        """, assoc_rows)
        print(f"✅ Seeded {len(assoc_rows)} word associations.")

    # 5. Load Stories
    print("📚 Seeding HSK stories...")
    stories = extract_stories()
    for s in stories:
        cursor.execute("""
            INSERT INTO stories (id, title_zh, title_py, title_en, level, source, lesson_target, description, data_json)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            s["id"],
            s["titleZh"],
            s["titlePy"],
            s["titleEn"],
            s["level"],
            s["source"],
            s["lessonTarget"],
            s["description"],
            json.dumps(s, ensure_ascii=False)
        ))
    print(f"✅ Seeded {len(stories)} stories.")

    conn.commit()
    conn.close()

    db_size_mb = os.path.getsize(OUTPUT_DB_PATH) / (1024 * 1024)
    print(f"🎉 Database generation complete! Location: {OUTPUT_DB_PATH} ({db_size_mb:.2f} MB)")

if __name__ == "__main__":
    main()
