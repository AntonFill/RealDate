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
    let tempDir = FileManager.default.temporaryDirectory

    @Test("Process file with no-rename flag and check attributes are set")
    func processFileWithNoRename() throws {
        let oldTestPath = tempDir.appendingPathComponent("2026.06.07 TestDocument.txt").path
        let newTestPath = tempDir.appendingPathComponent("TestDocument.txt").path

        try "Test content".write(toFile: oldTestPath, atomically: true, encoding: .utf8)

        defer {
            try? FileManager.default.removeItem(atPath: oldTestPath)
            try? FileManager.default.removeItem(atPath: newTestPath)
        }

        processFile(oldTestPath, noRename: true)

        #expect(FileManager.default.fileExists(atPath: oldTestPath))
        #expect(FileManager.default.fileExists(atPath: newTestPath) == false)

        let date = try #require( parseDateFromFilename(oldTestPath)?.date )
        let attributes = try FileManager.default.attributesOfItem(atPath: oldTestPath) // oldTestPath! There is no new-one.
        #expect(attributes[.creationDate] as? Date == date)
        #expect(attributes[.modificationDate] as? Date == date)
    }
}
