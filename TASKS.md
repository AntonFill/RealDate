---
created: 2026-06-07
---

# realdate — Open Tasks

## Bugs & Fixes
- [ ] **README.md:39** — Korrigiere Beispiel: `16-30 Email.eml` sollte `Email.eml` sein (nach Time-Parsing-Fix)
- [ ] **Time-Parsing-Logik** — HH-mm wird aus Dateinamen nicht korrekt entfernt (Regex-Range-Issue beheben)
- [ ] **processFile() Return-Value (realdate.swift:112)** — Return-Wert wird nirgendwo ausgewertet. 
  - In `processDirectory()` wird `_ = processFile()` aufgerufen (Return wird ignoriert)
  - Entscheiden: Return behalten oder entfernen? Oder für Statistik nutzen?

## Features
- [ ] **Verbose Mode (-v / --verbose)** — Zeige pro Datei:
  - Before-Name → After-Name (wenn erfolgreich)
  - "ignoriert" (wenn keine Zeit erkannt)
  - Fehlermeldung (bei Problemen)

- [ ] **Default Path Handling** — Wenn kein Path angegeben:
  - Soll `realdate` ohne Argumente aktuelles Verzeichnis verarbeiten (wie `ls`)
  - Aktuell: bricht ab mit "No paths specified"

## Edge Cases & Clarifications
- [ ] **Verzeichnis-Timestamps** — Werden Directory-Attribute (created/modified) angepasst oder nicht?
  - Requirement unklar: nur Dateien oder auch Ordner?

## Notes
- All tasks related to realdate project
- Priorität: Bugs → Features (in dieser Reihenfolge)
