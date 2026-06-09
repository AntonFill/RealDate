//
//  FileOperationsTests.swift
//  realdate
//
//  Created by Anton Fillmann on 08.06.2026.
//

import Testing
import Foundation
@testable import realdate

@Suite("File Operations")
struct FileOperationsTests {
    let tempDir = FileManager.default.temporaryDirectory
    
    @Test("Process single file")
    func processSingleFile() throws {
        let oldTestPath = tempDir.appendingPathComponent("2026.06.07 TestDocument.txt").path
        let newTestPath = tempDir.appendingPathComponent("TestDocument.txt").path

        try "Test content".write(toFile: oldTestPath, atomically: true, encoding: .utf8)

        defer {
            try? FileManager.default.removeItem(atPath: oldTestPath)
            try? FileManager.default.removeItem(atPath: newTestPath)
        }

        processFile(oldTestPath)

        #expect(FileManager.default.fileExists(atPath: oldTestPath) == false)
        #expect(FileManager.default.fileExists(atPath: newTestPath))
        
        let date = try #require( parseDateFromFilename(oldTestPath)?.date )
        let attributes = try FileManager.default.attributesOfItem(atPath: newTestPath)
        #expect(attributes[.creationDate] as? Date == date)
        #expect(attributes[.modificationDate] as? Date == date)
    }

    @Test("Skip file with no date")
    func skipFileWithNoDate() throws {
        let oldTestPath = tempDir.appendingPathComponent("NoDatFile.txt").path

        try "Content".write(toFile: oldTestPath, atomically: true, encoding: .utf8)
        let oldAttributes = try FileManager.default.attributesOfItem(atPath: oldTestPath)
        let createdDate = try #require( oldAttributes[.creationDate] as? Date )
        let modifiedDate = try #require( oldAttributes[.modificationDate] as? Date )

        defer {
            try? FileManager.default.removeItem(atPath: oldTestPath)
        }

        processFile(oldTestPath)

        #expect(FileManager.default.fileExists(atPath: oldTestPath))
        let date = try #require( parseDateFromFilename(oldTestPath)?.date )
        let attributes = try FileManager.default.attributesOfItem(atPath: oldTestPath)
        #expect(attributes[.creationDate] as? Date == createdDate)
        #expect(attributes[.modificationDate] as? Date == modifiedDate)
    }

    @Test("Skip directories")
    func skipDirectories() throws {
        let testDir = tempDir.appendingPathComponent("2026.06.07 TestDir")

        try FileManager.default.createDirectory(atPath: testDir.path, withIntermediateDirectories: true, attributes: nil)

        defer {
            try? FileManager.default.removeItem(atPath: testDir.path)
        }

        processFile(testDir.path)

        #expect(FileManager.default.fileExists(atPath: testDir.path))
    }

    @Test("Handle duplicate filenames")
    func handleDuplicateFilenames() throws {
        // Create two files with different dates but same target name
        let oldTestPath1 = tempDir.appendingPathComponent("2026.06.06 Document.txt").path
        let newTestPath1 = tempDir.appendingPathComponent("Document.txt").path
        let oldTestPath2 = tempDir.appendingPathComponent("2026.06.07 Document.txt").path
        let newTestPath2 = tempDir.appendingPathComponent("Document 2.txt").path
        let oldTestPath3 = tempDir.appendingPathComponent("2026.06.08 Document.txt").path
        let newTestPath3 = tempDir.appendingPathComponent("Document 3.txt").path

        try "Content 1".write(toFile: oldTestPath1, atomically: true, encoding: .utf8)
        try "Content 2".write(toFile: oldTestPath2, atomically: true, encoding: .utf8)
        try "Content 3".write(toFile: oldTestPath3, atomically: true, encoding: .utf8)

        defer {
            try? FileManager.default.removeItem(atPath: oldTestPath1)
            try? FileManager.default.removeItem(atPath: oldTestPath2)
            try? FileManager.default.removeItem(atPath: oldTestPath3)
            
            try? FileManager.default.removeItem(atPath: newTestPath1)
            try? FileManager.default.removeItem(atPath: newTestPath2)
            try? FileManager.default.removeItem(atPath: newTestPath3)
        }

        processFile(oldTestPath1)
        processFile(oldTestPath2)
        processFile(oldTestPath3)

        #expect(FileManager.default.fileExists(atPath: oldTestPath1) == false)
        #expect(FileManager.default.fileExists(atPath: oldTestPath2) == false)
        #expect(FileManager.default.fileExists(atPath: oldTestPath3) == false)
        #expect(FileManager.default.fileExists(atPath: newTestPath1))
        #expect(FileManager.default.fileExists(atPath: newTestPath2))
        #expect(FileManager.default.fileExists(atPath: newTestPath3))
    }

    @Test("Time removed from filename")
    func timeRemovedFromFilename() throws {
        let oldTestPath = tempDir.appendingPathComponent("2026.06.07 14-30 Email.eml").path
        let newTestPath = tempDir.appendingPathComponent("Email.eml").path

        try "Email content".write(toFile: oldTestPath, atomically: true, encoding: .utf8)

        defer {
            try? FileManager.default.removeItem(atPath: oldTestPath)
            try? FileManager.default.removeItem(atPath: newTestPath)
        }

        processFile(oldTestPath)

        #expect(FileManager.default.fileExists(atPath: oldTestPath) == false)
        #expect(FileManager.default.fileExists(atPath: newTestPath))
        
        let date = try #require( parseDateFromFilename(oldTestPath)?.date )
        let attributes = try FileManager.default.attributesOfItem(atPath: newTestPath)
        #expect(attributes[.creationDate] as? Date == date)
        #expect(attributes[.modificationDate] as? Date == date)
    }
}
