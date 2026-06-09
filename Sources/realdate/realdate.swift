//
//  RealDate.swift
//  RealDate
//
//  Created by Anton Fillmann on 07.06.2026.
//

import Foundation
import ArgumentParser

struct DateFilenameTuple {
    let date: Date
    let name: String
}

extension DateFormatter {
    
    static var yyyyMMdd: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    static var yyyyMMdd_HHmm: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd.HH.mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    static var mediumDateShortTime: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    static var yyyyMMddFormatters: [DateFormatter] {
        [.yyyyMMdd_HHmm, yyyyMMdd]
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

func printIf(_ condition: Bool, _ message: @autoclosure () -> String) {
    if condition {
        print(message())
    }
}

func parseDateFromFilename(_ filename: String) -> DateFilenameTuple? {
    for formatter in DateFormatter.yyyyMMddFormatters {
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

func processFile(_ filePath: String, verbose: Bool = false, noRename: Bool = false) {
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

    guard let tuple = parseDateFromFilename(filename) else {
        printIf(verbose, "realdate: \(filename): No date prefix found, skipping")
        return
    }

    do {
        if noRename {
            // Only set timestamps, keep filename as-is
            let attributes: [FileAttributeKey: Any] = [
                .creationDate: tuple.date,
                .modificationDate: tuple.date
            ]
            try fileManager.setAttributes(attributes, ofItemAtPath: filePath)

            let dateFormatter = DateFormatter.mediumDateShortTime
            printIf(verbose, "realdate: \(filename): Date set to \(dateFormatter.string(from: tuple.date)) (filename unchanged)")
        } else {
            // Rename file and set timestamps
            let directory = URL(fileURLWithPath: filePath).deletingLastPathComponent().path
            var newPath = (directory as NSString).appendingPathComponent(tuple.name)

            // Handle duplicates
            if fileManager.fileExists(atPath: newPath) && newPath != filePath {
                newPath = findAvailablePath(newPath)
                let newFilename = URL(fileURLWithPath: newPath).lastPathComponent
                printIf(verbose, "realdate: \(filename): Duplicate found, renamed to \(newFilename)")
            }

            // Rename file
            try fileManager.moveItem(atPath: filePath, toPath: newPath)

            // Set timestamps
            let attributes: [FileAttributeKey: Any] = [
                .creationDate: tuple.date,
                .modificationDate: tuple.date
            ]
            try fileManager.setAttributes(attributes, ofItemAtPath: newPath)

            let newFilename = URL(fileURLWithPath: newPath).lastPathComponent
            let dateFormatter = DateFormatter.mediumDateShortTime
            printIf(verbose, "realdate: \(filename): now \(newFilename): Date set to \(dateFormatter.string(from: tuple.date))")
        }
    }
    catch {
        print("realdate: \(filename): \(error.localizedDescription)")
    }
}

func processDirectory(_ dirPath: String, recursive: Bool, verbose: Bool = false, noRename: Bool = false, includeHidden: Bool = false) {
    let fileManager = FileManager.default

    printIf(verbose, "realdate: Processing directory: \(dirPath)")

    do {
        // Get directory contents and sort them alphabetically
        let contents = try fileManager.contentsOfDirectory(atPath: dirPath)
            .sorted { $0.localizedStandardCompare($1) == .orderedAscending }

        for item in contents {
            // Skip hidden files/directories unless includeHidden is true
            if !includeHidden && item.hasPrefix(".") {
                printIf(verbose, "realdate: \(item): Skipping hidden item")
                continue
            }

            let fullPath = (dirPath as NSString).appendingPathComponent(item)
            var isDir: ObjCBool = false

            guard fileManager.fileExists(atPath: fullPath, isDirectory: &isDir) else {
                continue
            }

            if isDir.boolValue {
                if recursive {
                    processDirectory(fullPath, recursive: true, verbose: verbose, noRename: noRename, includeHidden: includeHidden)
                } else {
                    printIf(verbose, "realdate: \(item): Skipping subdirectory (use -r for recursive)")
                }
            } else {
                processFile(fullPath, verbose: verbose, noRename: noRename)
            }
        }
    } catch {
        print("realdate: \(dirPath): \(error.localizedDescription)")
    }
}

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

    @Option(name: .shortAndLong, help: "Date custom format (e.g. dd-MM-yyyy).")
    var format: String? = nil

    @Flag(name: .shortAndLong, help: "Search recursively in subdirectories.")
    var recursive = false

    @Flag(name: .shortAndLong, help: "Show detailed information.")
    var verbose = false

    @Flag(name: .long, help: "Set timestamps only, do not rename files.")
    var noRename = false

    @Flag(name: .long, help: "Include hidden files and directories (starting with .).")
    var includeHidden = false

    @Argument(help: "Path to file(s) or directory.")
    var path: String
    
    mutating func run() throws {
        if let format = self.format {
            DateFormatter.yyyyMMddFormatters.forEach { formatter in
                formatter.dateFormat = format
            }
        }
        
        let fileManager = FileManager.default
        var isDir: ObjCBool = false

        guard fileManager.fileExists(atPath: self.path, isDirectory: &isDir) else {
            print("realdate: \(self.path): No such file or directory")
            return
        }

        if isDir.boolValue {
            processDirectory(self.path, recursive: recursive, verbose: verbose, noRename: noRename, includeHidden: includeHidden)
        } else {
            processFile(self.path, verbose: verbose, noRename: noRename)
        }
    }
}
