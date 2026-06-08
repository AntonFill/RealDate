//
//  FileOperationsTests.swift
//  realdate
//
//  Created by Anton Fillmann on 08.06.2026.
//

import Testing
@testable import realdate
import Foundation

@Suite("File Operations")
struct FileOperationsTests {
    let tempDir = FileManager.default.temporaryDirectory
    
    @Test("Process single file")
    func processSingleFile() throws {
        let testFilename = "2026.06.07 TestDocument.txt"
        let testPath = tempDir.appendingPathComponent(testFilename).path

        try "Test content".write(toFile: testPath, atomically: true, encoding: .utf8)

        defer {
            try? FileManager.default.removeItem(atPath: testPath)
            try? FileManager.default.removeItem(atPath: tempDir.appendingPathComponent("TestDocument.txt").path)
        }

        let result = processFile(testPath)
        #expect(result == true)

        let newPath = tempDir.appendingPathComponent("TestDocument.txt").path
        #expect(FileManager.default.fileExists(atPath: newPath))
    }

    @Test("Skip file with no date")
    func skipFileWithNoDate() throws {
        let testPath = tempDir.appendingPathComponent("NoDatFile.txt").path

        try "Content".write(toFile: testPath, atomically: true, encoding: .utf8)

        defer {
            try? FileManager.default.removeItem(atPath: testPath)
        }

        let result = processFile(testPath)
        #expect(result == false)
    }

    @Test("Skip directories")
    func skipDirectories() throws {
        let testDir = tempDir.appendingPathComponent("2026.06.07 TestDir")

        try FileManager.default.createDirectory(atPath: testDir.path, withIntermediateDirectories: true, attributes: nil)

        defer {
            try? FileManager.default.removeItem(atPath: testDir.path)
        }

        let result = processFile(testDir.path)
        #expect(result == false)
    }

    @Test("Handle duplicate filenames")
    func handleDuplicateFilenames() throws {
        let testPath1 = tempDir.appendingPathComponent("2026.06.07 Document.txt").path
        let testPath2 = tempDir.appendingPathComponent("2026.06.07 Document.txt").path

        try "Content 1".write(toFile: testPath1, atomically: true, encoding: .utf8)
        try "Content 2".write(toFile: testPath2, atomically: true, encoding: .utf8)

        defer {
            try? FileManager.default.removeItem(atPath: tempDir.appendingPathComponent("Document.txt").path)
            try? FileManager.default.removeItem(atPath: tempDir.appendingPathComponent("Document 2.txt").path)
        }

        let result1 = processFile(testPath1)
        #expect(result1 == true)

        let result2 = processFile(testPath2)
        #expect(result2 == true)

        let newPath1 = tempDir.appendingPathComponent("Document.txt").path
        let newPath2 = tempDir.appendingPathComponent("Document 2.txt").path
        #expect(FileManager.default.fileExists(atPath: newPath1))
        #expect(FileManager.default.fileExists(atPath: newPath2))
    }

    @Test("Time removed from filename")
    func timeRemovedFromFilename() throws {
        let testFilename = "2026.06.07 14-30 Email.eml"
        let testPath = tempDir.appendingPathComponent(testFilename).path

        try "Email content".write(toFile: testPath, atomically: true, encoding: .utf8)

        defer {
            try? FileManager.default.removeItem(atPath: testPath)
            try? FileManager.default.removeItem(atPath: tempDir.appendingPathComponent("Email.eml").path)
        }

        let result = processFile(testPath)
        #expect(result == true)

        let newPath = tempDir.appendingPathComponent("Email.eml").path
        #expect(FileManager.default.fileExists(atPath: newPath))
    }
}
