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
- [x] **custom date format (--format)** - Eigenes Date-Format beim Scannen des Dateinamens "14.05.2026 DSC134.jpg" ✓
- [x] **recursive (-r / --recursive)** - Es werden alle Unterverzeichnisse durch gegangen ✓
- [ ] **custom new filename format (--new-filename-format)** - Eigenes Date-Format beim Verändern des Dateinames "yyyy.MM.dd"
  - Wenn die Datei ein anderes oder gar-kein Date-Format im Filenamen hatte, wird eins basierend auf creation-Date links eingefügt.
- [ ] **GitHub OpenSource** - Mein Portfolio und Nutzen für die Welt.
- [ ] **HomeBrew install** - App soll über home brew installierbar sein.

## Edge Cases & Clarifications
- [ ] **Verzeichnis-Timestamps** — Werden Directory-Attribute (created/modified) angepasst oder nicht?
  - Requirement unklar: nur Dateien oder auch Ordner?
- [x] **Timestamp Optimization** — Vermeide redundante Timestamp-Setzungen bei bereits korrekten Werten ✓
- [x] **Directory Processing Order** — Verzeichnisse und Dateien alphabetisch sortieren beim Verarbeiten ✓
- [x] **Hidden Files Handling** — Versteckte Dateien per default ignorieren ✓

## Notes
- All tasks related to realdate project
- Priorität: Bugs → Features (in dieser Reihenfolge)
- Features sind durch Unittests bewiesen
