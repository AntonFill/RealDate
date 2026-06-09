# realdate

A Swift CLI tool that extracts dates from filenames, sets macOS file timestamps, and cleans up filenames for better file system sorting.

## Problem

When organizing documents (PDFs, scans, notes) with embedded dates in filenames like `2026.06.07 MyDocument.pdf`, the Finder sorts by filename rather than actual file modification date. This tool moves the date from the filename into the file's metadata attributes.

## Features

- **Extract dates** from filename prefix (flexible format: `YYYY.MM.DD`, `YYYY-MM-DD`, `YYYY_MM_DD`)
- **Parse optional time** (format: `YYYY.MM.DD.HH.mm` for emails, etc.)
- **Set macOS timestamps** (both creation and modification dates)
- **Clean filenames** by removing the date prefix
- **Duplicate handling** with automatic counter (`Document.txt`, `Document 2.txt`, `Document 3.txt`)
- **Recursive processing** with `-r` flag
- **Verbose mode** with `-v` flag for detailed output
- **Skip files** without leading dates (safe to run on mixed directories)

## Usage

```bash
# Process single file
./realdate "2026.06.07 MyDocument.pdf"

# Process directory
./realdate ~/Documents

# Process recursively
./realdate -r ~/Paperless

# Verbose output
./realdate -v -r .

# Show help
./realdate --help
```

## Filename Format

### Supported Date Formats
- **Dots:** `2026.06.07 MyDocument.pdf` → `MyDocument.pdf`
- **Dashes:** `2026-06-07 MyDocument.pdf` → `MyDocument.pdf`
- **Underscores:** `2026_06_08 MyDocument.pdf` → `MyDocument.pdf`

### With Time
- **Time format:** `2026.06.07.14.30 Email.eml` → `Email.eml` (time: 14:30)
- Time is optional; if missing, defaults to 00:00

### Edge Cases
- **Multiple spaces:** `2026.06.07 My Important Doc.pdf` → `My Important Doc.pdf`
- **No date:** `MyDocument.pdf` → skipped silently (or with message in verbose mode)
- **Trailing dates:** `2026.06.07 Document 2025.05.10.pdf` → `Document 2025.05.10.pdf` (only first date processed)
- **Duplicates:** Automatic counter added (`Document.txt`, `Document 2.txt`, etc.)

## Options

```
OPTIONS:
  -f, --format <format>   Das Datumsformat (z.B. YYYY-MM-DD). (default: YYYY.MM.DD)
  -r, --recursive         Suche rekursiv in Unterordnern.
  -v, --verbose           Zeige detaillierte Informationen an.
  --no-rename             Setze Zeitstempel, aber ändere Dateinamen nicht.
  --include-hidden        Versteckte Dateien und Verzeichnisse verarbeiten.
  --version               Show the version.
  -h, --help              Show help information.

ARGUMENTS:
  <path>                  Der Pfad zur Datei(en) oder zum Verzeichnis.
```

## Building

```bash
swift build -c release
# Binary: .build/release/realdate
```

## Testing

```bash
swift test
```

## Use Cases

- **Paperless Office**: Organize scanned documents by actual scan date, not archive date
- **Obsidian Vault**: Sort markdown notes by creation date stored in filename
- **Email Archives**: Extract emails with timestamps intact
- **Bulk Organization**: Rename and timestamp entire directories recursively

## Implementation Details

- **Date parsing:** Two-pass approach with `DateFormatter` (tries time format first, then date-only)
- **Flexible separators:** Normalizes `-`, `_`, `:`, and spaces to `.` for parsing
- **Duplicate handling:** Incremental counter like macOS Finder
- **Verbose mode:** Shows skipped files, ignored files, duplicate handling, and timestamp details

## Compatibility

- macOS 10.15+ (uses macOS-specific timestamp APIs)
- Swift 6.0+
- Requires file system write permissions
