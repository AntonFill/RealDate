//
//  RealDate.swift
//  RealDate
//
//  Created by Anton Fillmann on 07.06.2026.
//

import Foundation
import ArgumentParser

@main
struct RealDate: ParsableCommand {
    static let appname = "realdate"
    static let abstract = "Extract date from filename prefix, set file timestamps, and remove date from filename."
    static let version = "1.0.0"

    static let configuration = CommandConfiguration(
        commandName: Self.appname,
        abstract: Self.abstract,
        version: Self.version
    )

    @Option(name: .long, help: "Date custom format (e.g. dd-MM-yyyy, yyyy-MM-dd, yyyy-MM-dd-HH-mm).")
    var format: [String] = ["yyyy.MM.dd.HH.mm", "yyyy.MM.dd"] // Valid preset.

    @Flag(name: .shortAndLong, help: "Search recursively in subdirectories.")
    var recursive = false

    @Flag(name: .shortAndLong, help: "Show detailed information.")
    var verbose = false

    @Flag(name: .long, help: "Set timestamps, and rename files.")
    var rename = false

    @Argument(help: "Path to file(s) or directory.")
    var path: String
    
    mutating func run() throws {
        let dateFormatters = self.format.map { $0.customDateFormatter() }
        
        let fileManager = FileManager.default
        var isDir: ObjCBool = false

        guard fileManager.fileExists(atPath: self.path, isDirectory: &isDir) else {
            print("realdate: \(self.path): No such file or directory")
            return
        }

        if isDir.boolValue {
            self.processDirectory(self.path, dateFormatters: dateFormatters)
        } else {
            self.processFile(self.path, dateFormatters: dateFormatters)
        }
    }
}

// MARK: -
extension RealDate {
        
    struct DateFilenameTuple {
        let date: Date
        let name: String
    }
}

extension RealDate {
    
    func processDirectory(_ dirPath: String, dateFormatters: [DateFormatter]) {
        printIf(self.verbose, "realdate: Processing directory: \(dirPath)")

        do {
            let fileManager = FileManager.default
            
            // Get directory contents and sort them alphabetically
            let contents = try fileManager.contentsOfDirectory(atPath: dirPath)
                .sorted { $0.localizedStandardCompare($1) == .orderedAscending }

            for item in contents {
                // Skip hidden files/directories
                if item.hasPrefix(".") {
                    printIf(self.verbose, "realdate: \(item): Skipping hidden item")
                    continue
                }

                let fullPath = (dirPath as NSString).appendingPathComponent(item)
                var isDir: ObjCBool = false

                guard fileManager.fileExists(atPath: fullPath, isDirectory: &isDir) else {
                    continue
                }

                if isDir.boolValue {
                    if self.recursive {
                        self.processDirectory(fullPath, dateFormatters: dateFormatters)
                    }
                    else {
                        printIf(self.verbose, "realdate: \(item): Skipping subdirectory (use -r for recursive)")
                    }
                }
                else {
                    self.processFile(fullPath, dateFormatters: dateFormatters)
                }
            }
        }
        catch {
            print("realdate: \(dirPath): \(error.localizedDescription)")
        }
    }
    
    func processFile(_ filePath: String, dateFormatters: [DateFormatter]) {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false

        guard fileManager.fileExists(atPath: filePath, isDirectory: &isDir) else {
            printIf(verbose, "realdate: \(filePath): No such file or directory")
            return
        }

        // Skip directories
        if isDir.boolValue {
            printIf(verbose, "realdate: \(filePath): Expecting file, but is a directory. skipping")
            return
        }

        let filename = URL(fileURLWithPath: filePath).lastPathComponent

        guard let tuple = self.parseDateFromFilename(filename, dateFormatters: dateFormatters) else {
            printIf(verbose, "realdate: \(filename): No date prefix found, skipping")
            return
        }

        do {
            let attributes: [FileAttributeKey: Any] = [
                .creationDate: tuple.date,
                .modificationDate: tuple.date
            ]
            try fileManager.setAttributes(attributes, ofItemAtPath: filePath)
            
            let dateString = DateFormatter.mediumDateShortTime.string(from: tuple.date)
            guard self.rename else {
                printIf(verbose, "realdate: \(filename): Date set to \(dateString) (filename unchanged)")
                return
            }
            
            // Rename file and set timestamps
            let directory = URL(fileURLWithPath: filePath).deletingLastPathComponent().path
            var newPath = (directory as NSString).appendingPathComponent(tuple.name)

            // Handle duplicates
            if fileManager.fileExists(atPath: newPath) && newPath != filePath {
                newPath = self.findAvailablePath(newPath)
                let newFilename = URL(fileURLWithPath: newPath).lastPathComponent
                printIf(verbose, "realdate: \(filename): Duplicate found, renamed to \(newFilename)")
            }

            // Rename file
            try fileManager.moveItem(atPath: filePath, toPath: newPath)

            let newFilename = URL(fileURLWithPath: newPath).lastPathComponent
            printIf(verbose, "realdate: \(filename): Renamed to \(newFilename): Date set to \(dateString)")
        }
        catch {
            print("realdate: \(filename): \(error.localizedDescription)")
        }
    }
    
    func parseDateFromFilename(_ filename: String, dateFormatters: [DateFormatter]) -> DateFilenameTuple? {
        for formatter in dateFormatters {
            guard let date = formatter.date(fromFilename: filename) else {
                continue // next formatter.
            }
            let trimmingChars = CharacterSet.whitespaces.union(CharacterSet(charactersIn: "-_."))
            let realFilename = filename
                .dropFirst(formatter.dateFormat.count) // cut away date string.
                .drop(while: { char in
                    char.unicodeScalars.allSatisfy { trimmingChars.contains($0) } // trims left all chars from trimmingChars set.
                })
            
            guard realFilename.count > 0 else {
                return nil // if no name left, to much trimmed away. Cancels for this filename.
            }
            
            return DateFilenameTuple(date: date, name: String(realFilename))
        }
        return nil
    }

    func findAvailablePath(_ filePath: String) -> String {
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: filePath) else {
            return filePath
        }

        let url = URL(fileURLWithPath: filePath)
        let dirPath = url.deletingLastPathComponent().path
        let filename = url.lastPathComponent
        let fileExtension = url.pathExtension
        let baseName = fileExtension.isEmpty ? filename : String(filename.dropLast(fileExtension.count + 1))

        var counter = 2
        while true {
            let newFilename = fileExtension.isEmpty ?
                "\(baseName) \(counter)" :
                "\(baseName) \(counter).\(fileExtension)"
            let newPath = (dirPath as NSString).appendingPathComponent(newFilename)

            if !fileManager.fileExists(atPath: newPath) {
                return newPath
            }
            counter += 1
        }
    }
}

// MARK: - globals
func printIf(_ condition: Bool, _ message: @autoclosure () -> String) {
    if condition {
        print(message())
    }
}

// MARK: - extensions
extension DateFormatter {
    
    static var mediumDateShortTime: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    func date(fromFilename filename: String) -> Date? {
        let dateLength = self.dateFormat.count
        let separators = CharacterSet(charactersIn: "-_: ")
        let dateString = String(filename.prefix(dateLength))
            .components(separatedBy: separators)
            .joined(separator: ".")
        return self.date(from: dateString)
    }
}

extension String {
    
    func customDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = self
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }
}

extension Date {
    static let currentCalendar = Calendar.current
    
    func isSameDay(as otherDate: Date) -> Bool {
        Self.currentCalendar.isDate(self, inSameDayAs: otherDate)
    }
}
