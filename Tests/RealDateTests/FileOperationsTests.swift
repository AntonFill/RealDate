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
    
    @Test("Process single file")
    func processSingleFile() throws {
        let tempDir = try createTestDirectory()
        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }
        
        let curTestURL = tempDir.appendingPathComponent("2026.06.07 TestDocument.txt")
        let newTestURL = tempDir.appendingPathComponent("TestDocument.txt")
        try "Test content".write(to: curTestURL, atomically: true, encoding: .utf8)
        
        var realDate = RealDate()
        realDate.format = ["yyyy.MM.dd.HH.mm", "yyyy.MM.dd"]
        realDate.recursive = false
        realDate.rename = true
        realDate.verbose = false
        realDate.path = curTestURL.path(percentEncoded: false)
        try realDate.run()
        
        #expect(FileManager.default.fileExists(atPath: curTestURL.path(percentEncoded: false)) == false)
        #expect(FileManager.default.fileExists(atPath: newTestURL.path(percentEncoded: false)))
        
        let formatters = realDate.format.map { $0.customDateFormatter() }
        let date = try #require( realDate.parseDateFromFilename(curTestURL.lastPathComponent, dateFormatters: formatters)?.date )
        let attributes = try FileManager.default.attributesOfItem(atPath: newTestURL.path(percentEncoded: false))
        #expect(attributes[.creationDate] as? Date == date)
        #expect(attributes[.modificationDate] as? Date == date)
    }
    
    @Test("Skip file with no date")
    func skipFileWithNoDate() throws {
        let tempDir = try createTestDirectory()
        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }
                
        let oldTestURL = tempDir.appendingPathComponent("NoDatFile.txt")
        try "Content".write(to: oldTestURL, atomically: true, encoding: .utf8)
        
        let oldAttributes = try FileManager.default.attributesOfItem(atPath: oldTestURL.path(percentEncoded: false))
        let oldCreatedDate = try #require( oldAttributes[.creationDate] as? Date )
        let oldModifiedDate = try #require( oldAttributes[.modificationDate] as? Date )

        var realDate = RealDate()
        realDate.format = ["yyyy.MM.dd.HH.mm", "yyyy.MM.dd"]
        realDate.recursive = false
        realDate.rename = true
        realDate.verbose = false
        realDate.path = oldTestURL.path(percentEncoded: false)
        try realDate.run()
        
        #expect(FileManager.default.fileExists(atPath: oldTestURL.path(percentEncoded: false)))
        
        let newAttributes = try FileManager.default.attributesOfItem(atPath: oldTestURL.path(percentEncoded: false))
        #expect(newAttributes[.creationDate] as? Date == oldCreatedDate)
        #expect(newAttributes[.modificationDate] as? Date == oldModifiedDate)
    }
    
    @Test("Skip file with same date")
    func skipFileWithSameCreationDate() throws {
        let tempDir = try createTestDirectory()
        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }
                
        let oldTest1URL = tempDir.appendingPathComponent("2026.05.14 10-10 MyDoc.pdf")
        let midTest1URL = tempDir.appendingPathComponent("10-10 MyDoc.pdf")
        let newTest1URL = tempDir.appendingPathComponent("MyDoc.pdf")
        try "Content".write(to: oldTest1URL, atomically: true, encoding: .utf8)
        
        let oldTest1Attributes = try FileManager.default.attributesOfItem(atPath: oldTest1URL.path(percentEncoded: false))
        let oldTest1CreatedDate = try #require( oldTest1Attributes[.creationDate] as? Date )
        
        let oldTest2URL = tempDir.appendingPathComponent("2026.05.15 MyImage.img")
        let newTest2URL = tempDir.appendingPathComponent("MyImage.img")
        try "Image".write(to: oldTest2URL, atomically: true, encoding: .utf8)
        
        let oldTest2Attributes = try FileManager.default.attributesOfItem(atPath: oldTest2URL.path(percentEncoded: false))
        let oldTest2CreatedDate = try #require( oldTest2Attributes[.creationDate] as? Date )
        
        var realDate = RealDate()
        realDate.format = ["yyyy.MM.dd.HH.mm", "yyyy.MM.dd"]
        realDate.recursive = false
        realDate.rename = false // Forcing not-to-rename.
        realDate.verbose = false
        realDate.path = tempDir.path(percentEncoded: false)
        try realDate.run()
        
        #expect(FileManager.default.fileExists(atPath: oldTest1URL.path(percentEncoded: false)))
        #expect(FileManager.default.fileExists(atPath: newTest1URL.path(percentEncoded: false)) == false)
        
        let midTest1Attributes = try FileManager.default.attributesOfItem(atPath: oldTest1URL.path(percentEncoded: false))
        let midTest1CreatedDate = try #require( midTest1Attributes[.creationDate] as? Date )
        #expect(midTest1CreatedDate != oldTest1CreatedDate)
        
        #expect(FileManager.default.fileExists(atPath: oldTest2URL.path(percentEncoded: false)))
        #expect(FileManager.default.fileExists(atPath: newTest2URL.path(percentEncoded: false)) == false)
        
        let midTest2Attributes = try FileManager.default.attributesOfItem(atPath: oldTest2URL.path(percentEncoded: false))
        let midTest2CreatedDate = try #require( midTest2Attributes[.creationDate] as? Date )
        #expect(midTest2CreatedDate != oldTest2CreatedDate)
        
        realDate.format = ["yyyy.MM.dd"] // Forcing to ignore time.
        realDate.rename = true // Forcing to rename, usualy creation-date-time would be set to 00:00.
        try realDate.run()
        
        #expect(FileManager.default.fileExists(atPath: oldTest1URL.path(percentEncoded: false)) == false)
        #expect(FileManager.default.fileExists(atPath: midTest1URL.path(percentEncoded: false)))
        #expect(FileManager.default.fileExists(atPath: newTest1URL.path(percentEncoded: false)) == false)
        
        let newTest1Attributes = try FileManager.default.attributesOfItem(atPath: midTest1URL.path(percentEncoded: false))
        #expect(newTest1Attributes[.creationDate] as? Date == midTest1CreatedDate) // Skipping works "2026.05.14 10-10" == "2026.05.14 10-10"
        
        #expect(FileManager.default.fileExists(atPath: oldTest2URL.path(percentEncoded: false)) == false)
        #expect(FileManager.default.fileExists(atPath: newTest2URL.path(percentEncoded: false)))
        
        let newTest2Attributes = try FileManager.default.attributesOfItem(atPath: newTest2URL.path(percentEncoded: false))
        #expect(newTest2Attributes[.creationDate] as? Date == midTest2CreatedDate) // "2026.05.15 00-00" == "2026.05.15 00-00"
    }

    @Test("Skip directories")
    func skipDirectories() throws {
        let tempDir = try createTestDirectory()
        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }
        
        let testDir = tempDir.appendingPathComponent("2026.06.07 TestDir")
        try FileManager.default.createDirectory(at: testDir, withIntermediateDirectories: true)

        var realDate = RealDate()
        realDate.format = ["yyyy.MM.dd.HH.mm", "yyyy.MM.dd"]
        realDate.recursive = false
        realDate.rename = true
        realDate.verbose = false
        realDate.path = testDir.path(percentEncoded: false)
        try realDate.run()
        
        #expect(FileManager.default.fileExists(atPath: testDir.path(percentEncoded: false)))
    }

    @Test("Handle duplicate filenames")
    func handleDuplicateFilenames() throws {
        let tempDir = try createTestDirectory()
        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }
        
        // Create two files with different dates but same target name
        let oldTest1URL = tempDir.appendingPathComponent("2026.06.06 Document.txt")
        let newTest1URL = tempDir.appendingPathComponent("Document.txt")
        try "Content 1".write(to: oldTest1URL, atomically: true, encoding: .utf8)
        
        let oldTest2URL = tempDir.appendingPathComponent("2026.06.07 Document.txt")
        let newTest2URL = tempDir.appendingPathComponent("Document 2.txt")
        try "Content 2".write(to: oldTest2URL, atomically: true, encoding: .utf8)
        
        let oldTest3URL = tempDir.appendingPathComponent("2026.06.08 Document.txt")
        let newTest3URL = tempDir.appendingPathComponent("Document 3.txt")
        try "Content 3".write(to: oldTest3URL, atomically: true, encoding: .utf8)

        var realDate = RealDate()
        realDate.format = ["yyyy.MM.dd.HH.mm", "yyyy.MM.dd"]
        realDate.recursive = false
        realDate.rename = true
        realDate.verbose = false
        realDate.path = tempDir.path(percentEncoded: false)
        try realDate.run()
        
        #expect(FileManager.default.fileExists(atPath: oldTest1URL.path(percentEncoded: false)) == false)
        #expect(FileManager.default.fileExists(atPath: newTest1URL.path(percentEncoded: false)))
        
        #expect(FileManager.default.fileExists(atPath: oldTest2URL.path(percentEncoded: false)) == false)
        #expect(FileManager.default.fileExists(atPath: newTest2URL.path(percentEncoded: false)))
        
        #expect(FileManager.default.fileExists(atPath: oldTest3URL.path(percentEncoded: false)) == false)
        #expect(FileManager.default.fileExists(atPath: newTest3URL.path(percentEncoded: false)))
    }

    @Test("Time removed from filename")
    func timeRemovedFromFilename() throws {
        let tempDir = try createTestDirectory()
        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }
        
        let oldTestURL = tempDir.appendingPathComponent("2026.06.07 14-30 Email.eml")
        let newTestURL = tempDir.appendingPathComponent("Email.eml")
        try "Email content".write(to: oldTestURL, atomically: true, encoding: .utf8)

        var realDate = RealDate()
        realDate.format = ["yyyy.MM.dd.HH.mm", "yyyy.MM.dd"]
        realDate.recursive = false
        realDate.rename = true
        realDate.verbose = false
        realDate.path = tempDir.path(percentEncoded: false)
        try realDate.run()
        
        #expect(FileManager.default.fileExists(atPath: oldTestURL.path(percentEncoded: false)) == false)
        #expect(FileManager.default.fileExists(atPath: newTestURL.path(percentEncoded: false)))
        
        let formatters = realDate.format.map { $0.customDateFormatter() }
        let date = try #require( realDate.parseDateFromFilename(oldTestURL.lastPathComponent, dateFormatters: formatters)?.date )
        let attributes = try FileManager.default.attributesOfItem(atPath: newTestURL.path(percentEncoded: false))
        #expect(attributes[.creationDate] as? Date == date)
        #expect(attributes[.modificationDate] as? Date == date)
    }
}
