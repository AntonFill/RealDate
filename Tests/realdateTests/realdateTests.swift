import Testing
@testable import realdate
import Foundation

@Suite("Date Parsing")
struct DateParsingTests {
    @Test("Parse valid date only")
    func parseValidDateOnly() {
        let result = parseDateFromFilename("2026.06.07 MyDocument.pdf")
        #expect(result != nil)
        #expect(result?.newName == "MyDocument.pdf")
        #expect(result?.dateTime.hasExplicitTime == false)

        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: result!.dateTime.date)
        #expect(comps.year == 2026)
        #expect(comps.month == 6)
        #expect(comps.day == 7)
        #expect(comps.hour == 10)
        #expect(comps.minute == 0)
    }

    @Test("Parse date with time")
    func parseDateWithTime() {
        let result = parseDateFromFilename("2026.02.12 16-30 AW_ Subject.eml")
        #expect(result != nil)
        #expect(result?.newName == "AW_ Subject.eml")
        #expect(result?.dateTime.hasExplicitTime == true)

        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: result!.dateTime.date)
        #expect(comps.year == 2026)
        #expect(comps.month == 2)
        #expect(comps.day == 12)
        #expect(comps.hour == 16)
        #expect(comps.minute == 30)
    }

    @Test("Parse date with multiple spaces in filename")
    func parseDateWithMultipleSpaces() {
        let result = parseDateFromFilename("2026.06.07 My Important Document.pdf")
        #expect(result != nil)
        #expect(result?.newName == "My Important Document.pdf")
    }

    @Test("Reject no date prefix")
    func rejectNoDatePrefix() {
        let result = parseDateFromFilename("MyDocument.pdf")
        #expect(result == nil)
    }

    @Test("Reject invalid date format")
    func rejectInvalidDateFormat() {
        let result = parseDateFromFilename("06-07-2026 MyDocument.pdf")
        #expect(result == nil)
    }

    @Test("Reject date only, no filename")
    func rejectDateOnly() {
        let result = parseDateFromFilename("2026.06.07")
        #expect(result == nil)
    }

    @Test("Reject invalid month")
    func rejectInvalidMonth() {
        let result = parseDateFromFilename("2026.13.07 MyDocument.pdf")
        #expect(result == nil)
    }

    @Test("Reject invalid day")
    func rejectInvalidDay() {
        let result = parseDateFromFilename("2026.06.32 MyDocument.pdf")
        #expect(result == nil)
    }

    @Test("Parse time with leading zeros")
    func parseTimeWithLeadingZeros() {
        let result = parseDateFromFilename("2026.01.01 09-05 Document.txt")
        #expect(result != nil)
        #expect(result?.dateTime.hasExplicitTime == true)

        let calendar = Calendar.current
        let comps = calendar.dateComponents([.hour, .minute], from: result!.dateTime.date)
        #expect(comps.hour == 9)
        #expect(comps.minute == 5)
    }

    @Test("Ignore malformed time, use default")
    func ignoreMalformedTime() {
        let result = parseDateFromFilename("2026.06.07 25-99 Document.pdf")
        #expect(result != nil)
        #expect(result?.dateTime.hasExplicitTime == false)

        let calendar = Calendar.current
        let comps = calendar.dateComponents([.hour, .minute], from: result!.dateTime.date)
        #expect(comps.hour == 10)
        #expect(comps.minute == 0)
    }

    @Test("Date with trailing date ignored")
    func dateWithTrailingDateIgnored() {
        let result = parseDateFromFilename("2026.06.07 Document 2025.05.10.pdf")
        #expect(result != nil)
        #expect(result?.newName == "Document 2025.05.10.pdf")
    }
}

@Suite("File Operations")
struct FileOperationsTests {
    @Test("Process single file")
    func processSingleFile() throws {
        let tempDir = FileManager.default.temporaryDirectory
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
        let tempDir = FileManager.default.temporaryDirectory
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
        let tempDir = FileManager.default.temporaryDirectory
        let testDir = tempDir.appendingPathComponent("2026.06.07 TestDir")

        try FileManager.default.createDirectory(atPath: testDir.path, withIntermediateDirectories: true, attributes: nil)

        defer {
            try? FileManager.default.removeItem(atPath: testDir.path)
        }

        let result = processFile(testDir.path)
        #expect(result == false)
    }
}
