//
//  NoRenameTests.swift
//  realdate
//
//  Created by Anton Fillmann on 09.06.2026.
//

import Testing
import Foundation
@testable import realdate

@Suite("No-Rename Tests")
struct NoRenameTests {

    @Test("Process file with no-rename flag and check attributes are set")
    func processFileWithNoRename() throws {
        let tempDir = try createTestDirectory()
        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }
        
        let oldTestURL = tempDir.appendingPathComponent("2026.06.07 TestDocument.txt")
        let newTestURL = tempDir.appendingPathComponent("TestDocument.txt")
        try "Test content".write(to: oldTestURL, atomically: true, encoding: .utf8)

        processFile(oldTestURL.path(percentEncoded: false), noRename: true)
        #expect(FileManager.default.fileExists(atPath: oldTestURL.path(percentEncoded: false)))
        #expect(FileManager.default.fileExists(atPath: newTestURL.path(percentEncoded: false)) == false)

        let date = try #require( parseDateFromFilename(oldTestURL.lastPathComponent)?.date )
        let attributes = try FileManager.default.attributesOfItem(atPath: oldTestURL.path(percentEncoded: false)) // There is no newTestURL
        #expect(attributes[.creationDate] as? Date == date)
        #expect(attributes[.modificationDate] as? Date == date)
    }
}
