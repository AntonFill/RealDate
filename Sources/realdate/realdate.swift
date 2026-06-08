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
    
    static var yyyymmdd: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
    
    static var yyyyMMdd_HHmm: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd.HH.mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
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

func printIf(_ condition: Bool, _ message: @autoclosure () -> String) {
    if condition {
        print(message())
    }
}

func parseDateFromFilename(_ filename: String) -> DateFilenameTuple? {
    let formatters = [
        DateFormatter.yyyyMMdd_HHmm,
        DateFormatter.yyyymmdd
    ]
    for formatter in formatters {
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

    guard let tuple = parseDateFromFilename(filename) else {
        return false
    }

    let directory = URL(fileURLWithPath: filePath).deletingLastPathComponent().path
    var newPath = (directory as NSString).appendingPathComponent(tuple.name)

    // Handle duplicates
    if fileManager.fileExists(atPath: newPath) && newPath != filePath {
        newPath = findAvailablePath(newPath)
    }

    do {
        // Rename file
        try fileManager.moveItem(atPath: filePath, toPath: newPath)

        // Set timestamps
        let attributes: [FileAttributeKey: Any] = [
            .creationDate: tuple.date,
            .modificationDate: tuple.date
        ]
        try fileManager.setAttributes(attributes, ofItemAtPath: newPath)

        print("✓ \(filename) → \(URL(fileURLWithPath: newPath).lastPathComponent)")
        return true
    }
    catch {
        print("✗ \(filename): \(error.localizedDescription)")
        return false
    }
}

func processDirectory(_ dirPath: String, recursive: Bool) {
    let fileManager = FileManager.default

    do {
        let contents = try fileManager.contentsOfDirectory(atPath: dirPath)

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
                _ = processFile(fullPath)
            }
        }
    } catch {
        print("Error reading directory: \(error.localizedDescription)")
    }
}

@main
struct RealDate: ParsableCommand {
    static let appname = "realdate"
    static let abstract = "Sucht nach dem vorangehenden Datum im Dateinamen, entfernt diesen aus dem Dateinamen und weist ihn als created- & modified-Datum dieser Datei zu."
    static let version = "0.1.0"
    
    static let configuration = CommandConfiguration(
        commandName: Self.appname,
        abstract: Self.abstract,
        version: Self.version
    )
    
    @Option(name: .shortAndLong, help: "Das Datumsformat (z.B. YYYY-MM-DD).")
    var format: String = "YYYY.MM.DD"
    
    @Flag(name: .shortAndLong, help: "Suche rekursiv in Unterordnern.")
    var recursive = false
    
    @Flag(name: .shortAndLong, help: "Zeige detaillierte Informationen an.")
    var verbose = false
    
    @Argument(help: "Der Pfad zur Datei(en) oder zum Verzeichnis.")
    var path: String
    
    mutating func run() throws {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false

        guard fileManager.fileExists(atPath: self.path, isDirectory: &isDir) else {
            print("\(self.path) not found. Stop here!")
            return
        }

        if isDir.boolValue {
            processDirectory(self.path, recursive: recursive)
        } else {
            _ = processFile(self.path)
        }
        
//        guard let date = formatter.date(from: dateString) else {
//            printIf(self.verbose, "\(filename) \thas no prefix date, will be ignored.")
//            exit(0)
//        }
//        
//        printIf(self.verbose, "\(filename) \tfound date: \(date)")
    }
}
