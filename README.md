# realdate

A Swift CLI tool that extracts dates from filenames, sets macOS file timestamps, and cleans up filenames for better file system sorting.

## Problem

When organizing documents (PDFs, scans, notes) with embedded dates in filenames like `2026.06.07 MyDocument.pdf`, the Finder sorts by filename rather than actual file modification date. This tool moves the date from the filename into the file's metadata attributes.

## Features

- **Extract dates** from filename prefix (`YYYY.MM.DD` format)
- **Parse optional time** (`HH-mm` format for emails, etc.)
- **Set macOS timestamps** (both creation and modification dates)
- **Clean filenames** by removing the date prefix
- **Recursive processing** with `-r` flag
- **Skip files** without leading dates (safe to run on mixed directories)
- **Default time handling** (10:00 if no time specified)

## Usage

```bash
# Process single file
./realdate "2026.06.07 MyDocument.pdf"
# Result: MyDocument.pdf with timestamps set to 2026-06-07 10:00

# Process all PDFs in current directory
./realdate *.pdf

# Process all files recursively
./realdate -r .

# Glob patterns work too
./realdate -r ~/Paperless/**/*.pdf
```

## Filename Format

- **Standard:** `2026.06.07 MyDocument.pdf` → `MyDocument.pdf`
- **With time:** `2026.02.12 16-30 Email.eml` → `16-30 Email.eml`
- **Multiple spaces:** `2026.06.07 My Important Doc.pdf` → `My Important Doc.pdf`
- **No date:** `MyDocument.pdf` → skipped silently
- **Trailing dates:** `2026.06.07 Document 2025.05.10.pdf` → `Document 2025.05.10.pdf` (first date only)

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

## macOS API

Uses standard Foundation APIs:
- `FileManager` for file operations
- `DateComponents` and `Calendar` for date parsing
- File attributes for timestamp manipulation

## Compatibility

- macOS only (uses macOS-specific timestamp APIs)
- Swift 6.0+
- Requires file system write permissions
