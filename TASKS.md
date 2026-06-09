---
created: 2026-06-07
---

# realdate — Open Tasks

## Bugs & Fixes
- [x] **README.md:39** — Korrigiere Beispiel: `16-30 Email.eml` sollte `Email.eml` sein (nach Time-Parsing-Fix) ✓
- [x] **Time-Parsing-Logik** — HH-mm wird aus Dateinamen nicht korrekt entfernt (Regex-Range-Issue beheben) ✓
- [x] **processFile() Return-Value (realdate.swift:112)** — Return-Wert wird nirgendwo ausgewertet ✓

## Features
- [x] **Verbose Mode (-v / --verbose)** — Zeige pro Datei: Before-Name → After-Name, ignoriert, Fehlermeldungen ✓
- [x] **Default Path Handling** — Wenn kein Path angegeben: aktuelles Verzeichnis verarbeiten ✓
- [x] **No-Rename Mode (--no-rename)** — Timestamps setzen ohne Dateinamen zu ändern ✓
- [x] **Hidden Files Handling (--include-hidden)** — Versteckte Dateien per default ignorieren ✓

## Edge Cases & Clarifications
- [ ] **Verzeichnis-Timestamps** — Werden Directory-Attribute (created/modified) angepasst oder nicht?
  - Requirement unklar: nur Dateien oder auch Ordner?
- [ ] **Timestamp Optimization** — Vermeide redundante Timestamp-Setzungen bei bereits korrekten Werten
- [ ] **Directory Processing Order** — Verzeichnisse und Dateien alphabetisch sortieren beim Verarbeiten

## Notes
- All tasks related to realdate project
- Priorität: Bugs → Features (in dieser Reihenfolge)
