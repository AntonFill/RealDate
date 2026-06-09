//
//  HiddenFilesTests.swift
//  realdate
//
//  Created by Anton Fillmann on 09.06.2026.
//

import Testing
import Foundation
@testable import realdate

@Suite("Hidden Files Tests")
struct HiddenFilesTests {
    let tempDir = FileManager.default.temporaryDirectory

    @Test("Skip hidden files by default")
    func skipHiddenFilesByDefault() throws {
        let oldHiddenPath = tempDir.appendingPathComponent(".2026.06.07 HiddenDocument.txt").path
        let newHiddenPath = tempDir.appendingPathComponent("HiddenDocument.txt").path
        let oldNormalPath = tempDir.appendingPathComponent("2026.06.07 NormalDocument.txt").path
        let newNormalPath = tempDir.appendingPathComponent("NormalDocument.txt").path

        try "Hidden content".write(toFile: oldHiddenPath, atomically: true, encoding: .utf8)
        try "Normal content".write(toFile: oldNormalPath, atomically: true, encoding: .utf8)

        defer {
            try? FileManager.default.removeItem(atPath: oldHiddenPath)
            try? FileManager.default.removeItem(atPath: newHiddenPath)
            
            try? FileManager.default.removeItem(atPath: oldNormalPath)
            try? FileManager.default.removeItem(atPath: newNormalPath)
        }

        // Process directory with hidden file
        processDirectory(tempDir.path, recursive: false, verbose: false, noRename: false, includeHidden: false)

        // Hidden file should still exist with original name
        #expect(FileManager.default.fileExists(atPath: oldHiddenPath))
        #expect(FileManager.default.fileExists(atPath: newHiddenPath) == false)
        // Normal file should be processed
        #expect(FileManager.default.fileExists(atPath: oldNormalPath) == false)
        #expect(FileManager.default.fileExists(atPath: newNormalPath))
    }

    @Test("Process hidden files with include-hidden flag")
    func processHiddenFilesWithIncludeHidden() throws {
        let oldHiddenPath = tempDir.appendingPathComponent(".2026.06.07 HiddenDocument.txt").path
        let newHiddenPath = tempDir.appendingPathComponent(".HiddenDocument.txt").path

        try "Hidden content".write(toFile: oldHiddenPath, atomically: true, encoding: .utf8)

        defer {
            try? FileManager.default.removeItem(atPath: oldHiddenPath)
            try? FileManager.default.removeItem(atPath: newHiddenPath)
        }

        processDirectory(tempDir.path, recursive: false, verbose: false, noRename: false, includeHidden: true)

        // Hidden file should be processed (renamed but kept hidden)
        #expect(FileManager.default.fileExists(atPath: oldHiddenPath) == false)
        #expect(FileManager.default.fileExists(atPath: newHiddenPath))
    }

    @Test("Skip hidden directories by default")
    func skipHiddenDirectoriesByDefault() throws {
        let hiddenDir = tempDir.appendingPathComponent(".hidden_subdir")
        let testPath = hiddenDir.appendingPathComponent("2026.06.07 TestInHiddenDir.txt").path

        try FileManager.default.createDirectory(at: hiddenDir, withIntermediateDirectories: true)
        try "Content".write(toFile: testPath, atomically: true, encoding: .utf8)

        defer {
            try? FileManager.default.removeItem(at: hiddenDir)
        }

        processDirectory(tempDir.path, recursive: true, verbose: false, noRename: false, includeHidden: false)

        // File in hidden directory should still exist (not processed)
        #expect(FileManager.default.fileExists(atPath: testPath))
    }
    
    @Test("Process hidden directories with include-hidden flag")
    func processHiddenDirectoriesWithIncludeHidden() throws {
        let hiddenDir = tempDir.appendingPathComponent(".hidden_subdir")
        let oldTest1Path = hiddenDir.appendingPathComponent("2026.06.07 TestInHiddenDir.txt").path
        let newTest1Path = hiddenDir.appendingPathComponent("TestInHiddenDir.txt").path
        let normalDir = tempDir.appendingPathComponent("normal_subdir")
        let oldTest2Path = normalDir.appendingPathComponent("2026.06.07 TestInNormalDir.txt").path
        let newTest2Path = normalDir.appendingPathComponent("TestInNormalDir.txt").path

        try FileManager.default.createDirectory(at: hiddenDir, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: normalDir, withIntermediateDirectories: true)
        try "Content".write(toFile: oldTest1Path, atomically: true, encoding: .utf8)
        try "Content".write(toFile: oldTest2Path, atomically: true, encoding: .utf8)

        defer {
            try? FileManager.default.removeItem(at: hiddenDir)
            try? FileManager.default.removeItem(at: normalDir)
        }

        processDirectory(tempDir.path, recursive: true, verbose: false, noRename: false, includeHidden: true)

        // File in hidden directory should still exist (not processed)
        #expect(FileManager.default.fileExists(atPath: oldTest1Path))
        #expect(FileManager.default.fileExists(atPath: newTest1Path) == false)
        #expect(FileManager.default.fileExists(atPath: oldTest2Path) == false)
        #expect(FileManager.default.fileExists(atPath: newTest2Path))
    }
}
