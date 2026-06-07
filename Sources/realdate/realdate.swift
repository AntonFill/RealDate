import Foundation

struct DateTimeInfo {
    let date: Date
    let hasExplicitTime: Bool
}

struct ParsedFilename {
    let dateTime: DateTimeInfo
    let newName: String
}

func parseDateFromFilename(_ filename: String) -> ParsedFilename? {
    let components = filename.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
    guard components.count >= 1 else { return nil }

    let possibleDate = String(components[0])
    let rest = components.count > 1 ? String(components[1]) : ""

    // Try to parse date: YYYY.MM.DD
    let datePattern = #"^\d{4}\.\d{2}\.\d{2}$"#
    guard possibleDate.range(of: datePattern, options: .regularExpression) != nil else {
        return nil
    }

    let parts = possibleDate.split(separator: ".")
    guard parts.count == 3,
          let year = Int(parts[0]),
          let month = Int(parts[1]),
          let day = Int(parts[2]) else {
        return nil
    }

    var dateComponents = DateComponents()
    dateComponents.year = year
    dateComponents.month = month
    dateComponents.day = day
    dateComponents.hour = 10
    dateComponents.minute = 0
    dateComponents.second = 0

    var hasExplicitTime = false

    // Check if there's a time in rest: HH-mm format
    if rest.count > 0 {
        let timePattern = #"^(\d{2})-(\d{2})"#
        if let match = rest.range(of: timePattern, options: .regularExpression) {
            let timeStr = String(rest[match])
            let timeParts = timeStr.split(separator: "-")
            if timeParts.count == 2,
               let hour = Int(timeParts[0]),
               let minute = Int(timeParts[1]) {
                dateComponents.hour = hour
                dateComponents.minute = minute
                hasExplicitTime = true
            }
        }
    }

    let calendar = Calendar.current
    guard let date = calendar.date(from: dateComponents) else {
        return nil
    }

    let newName = rest.trimmingCharacters(in: .whitespaces)
    guard !newName.isEmpty else {
        return nil
    }

    return ParsedFilename(
        dateTime: DateTimeInfo(date: date, hasExplicitTime: hasExplicitTime),
        newName: newName
    )
}

func processFile(_ filePath: String) -> Bool {
    let fileManager = FileManager.default
    var isDir: ObjCBool = false

    guard fileManager.fileExists(atPath: filePath, isDirectory: &isDir) else {
        return false
    }

    // Skip directories
    if isDir.boolValue {
        return false
    }

    let filename = URL(fileURLWithPath: filePath).lastPathComponent

    guard let parsed = parseDateFromFilename(filename) else {
        return false
    }

    let directory = URL(fileURLWithPath: filePath).deletingLastPathComponent().path
    let newPath = (directory as NSString).appendingPathComponent(parsed.newName)

    do {
        // Rename file
        try fileManager.moveItem(atPath: filePath, toPath: newPath)

        // Set timestamps
        let attributes: [FileAttributeKey: Any] = [
            .creationDate: parsed.dateTime.date,
            .modificationDate: parsed.dateTime.date
        ]
        try fileManager.setAttributes(attributes, ofItemAtPath: newPath)

        print("✓ \(filename) → \(parsed.newName)")
        return true
    } catch {
        print("✗ \(filename): \(error.localizedDescription)")
        return false
    }
}

func processDirectory(_ dirPath: String, recursive: Bool) {
    let fileManager = FileManager.default

    do {
        let contents = try fileManager.contentsOfDirectory(atPath: dirPath)
        var processed = 0

        for item in contents {
            let fullPath = (dirPath as NSString).appendingPathComponent(item)
            var isDir: ObjCBool = false

            guard fileManager.fileExists(atPath: fullPath, isDirectory: &isDir) else {
                continue
            }

            if isDir.boolValue {
                if recursive {
                    processDirectory(fullPath, recursive: true)
                }
            } else {
                if processFile(fullPath) {
                    processed += 1
                }
            }
        }
    } catch {
        print("Error reading directory: \(error.localizedDescription)")
    }
}

@main
struct realdate {
    static func main() {
        let arguments = CommandLine.arguments.dropFirst()

        guard !arguments.isEmpty else {
            print("Usage: realdate [OPTIONS] [PATH...]")
            print("Options:")
            print("  -r    Recursive (process subdirectories)")
            print("Examples:")
            print("  realdate \"2026.06.07 file.pdf\"")
            print("  realdate *.pdf")
            print("  realdate -r *")
            return
        }

        var recursive = false
        var paths: [String] = []

        for arg in arguments {
            if arg == "-r" {
                recursive = true
            } else {
                paths.append(arg)
            }
        }

        guard !paths.isEmpty else {
            print("No paths specified")
            return
        }

        for path in paths {
            let fileManager = FileManager.default
            var isDir: ObjCBool = false

            guard fileManager.fileExists(atPath: path, isDirectory: &isDir) else {
                print("✗ Path not found: \(path)")
                continue
            }

            if isDir.boolValue {
                processDirectory(path, recursive: recursive)
            } else {
                _ = processFile(path)
            }
        }
    }
}
