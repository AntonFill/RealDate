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

        processFile(testPath)

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

        processFile(testPath)

        // File should still exist with original name (not renamed)
        #expect(FileManager.default.fileExists(atPath: testPath))
    }

    @Test("Skip directories")
    func skipDirectories() throws {
        let testDir = tempDir.appendingPathComponent("2026.06.07 TestDir")

        try FileManager.default.createDirectory(atPath: testDir.path, withIntermediateDirectories: true, attributes: nil)

        defer {
            try? FileManager.default.removeItem(atPath: testDir.path)
        }

        processFile(testDir.path)

        // Directory should still exist with original name
        #expect(FileManager.default.fileExists(atPath: testDir.path))
    }

    @Test("Handle duplicate filenames")
    func handleDuplicateFilenames() throws {
        // Create two files with different dates but same target name
        let testPath1 = tempDir.appendingPathComponent("2026.06.06 Document.txt").path
        let testPath2 = tempDir.appendingPathComponent("2026.06.07 Document.txt").path
        let testPath3 = tempDir.appendingPathComponent("2026.06.08 Document.txt").path

        try "Content 1".write(toFile: testPath1, atomically: true, encoding: .utf8)
        try "Content 2".write(toFile: testPath2, atomically: true, encoding: .utf8)
        try "Content 3".write(toFile: testPath3, atomically: true, encoding: .utf8)

        defer {
            try? FileManager.default.removeItem(atPath: tempDir.appendingPathComponent("Document.txt").path)
            try? FileManager.default.removeItem(atPath: tempDir.appendingPathComponent("Document 2.txt").path)
            try? FileManager.default.removeItem(atPath: tempDir.appendingPathComponent("Document 3.txt").path)
        }

        processFile(testPath1)
        processFile(testPath2)
        processFile(testPath3)

        let newPath1 = tempDir.appendingPathComponent("Document.txt").path
        let newPath2 = tempDir.appendingPathComponent("Document 2.txt").path
        let newPath3 = tempDir.appendingPathComponent("Document 3.txt").path
        #expect(FileManager.default.fileExists(atPath: newPath1))
        #expect(FileManager.default.fileExists(atPath: newPath2))
        #expect(FileManager.default.fileExists(atPath: newPath3))
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

        processFile(testPath)

        let newPath = tempDir.appendingPathComponent("Email.eml").path
        #expect(FileManager.default.fileExists(atPath: newPath))
    }
}
