//
//  FileOperationsTests.swift
//  realdate
//
//  Created by Anton Fillmann on 08.06.2026.
//

import Testing
@testable import realdate
import Foundation

@Suite("Date Parsing")
struct DateParsingTests {
    let calendar = Calendar.current
    
    @Test("Parse valid date with dots")
    func parseValidDateWithDots() throws {
        let result = try #require( parseDateFromFilename("2026.06.07 MyDocument.pdf") )
        #expect(result.name == "MyDocument.pdf")

        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: result.date)
        #expect(comps.year == 2026)
        #expect(comps.month == 6)
        #expect(comps.day == 7)
        #expect(comps.hour == 0)
        #expect(comps.minute == 0)
    }

    @Test("Parse valid date with dashes")
    func parseValidDateWithDashes() throws {
        let result = try #require( parseDateFromFilename("2026-06-07 MyDocument.pdf") )
        #expect(result.name == "MyDocument.pdf")
        
        let comps = calendar.dateComponents([.year, .month, .day], from: result.date)
        #expect(comps.year == 2026)
        #expect(comps.month == 6)
        #expect(comps.day == 7)
    }

    @Test("Parse date with time - time removed from filename")
    func parseDateWithTimeRemoved() throws {
        let result = try #require( parseDateFromFilename("2026.02.12 16-30 AW_ Subject.eml") )
        #expect(result.name == "AW_ Subject.eml")

        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: result.date)
        #expect(comps.year == 2026)
        #expect(comps.month == 2)
        #expect(comps.day == 12)
        #expect(comps.hour == 16)
        #expect(comps.minute == 30)
    }

    @Test("Parse date with multiple spaces in filename")
    func parseDateWithMultipleSpaces() throws {
        let result = try #require( parseDateFromFilename("2026.06.07 My Important Document.pdf") )
        #expect(result.name == "My Important Document.pdf")
    }

    @Test("Reject no date prefix")
    func rejectNoDatePrefix() throws {
        let result = parseDateFromFilename("MyDocument.pdf")
        #expect(result == nil)
    }

    @Test("Reject invalid date format")
    func rejectInvalidDateFormat() throws {
        let result = parseDateFromFilename("06-07-2026 MyDocument.pdf")
        #expect(result == nil)
    }

    @Test("Reject date only, no filename")
    func rejectDateOnly() throws {
        let result = parseDateFromFilename("2026.06.07")
        #expect(result == nil)
    }

    @Test("Reject invalid month")
    func rejectInvalidMonth() throws {
        let result = parseDateFromFilename("2026.13.07 MyDocument.pdf")
        #expect(result == nil)
    }

    @Test("Reject invalid day")
    func rejectInvalidDay() throws {
        let result = parseDateFromFilename("2026.06.32 MyDocument.pdf")
        #expect(result == nil)
    }

    @Test("Parse time with leading zeros")
    func parseTimeWithLeadingZeros() throws {
        let result = try #require( parseDateFromFilename("2026.01.01 09-05 Document.txt") )

        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: result.date)
        #expect(comps.year == 2026)
        #expect(comps.month == 1)
        #expect(comps.day == 1)
        #expect(comps.hour == 9)
        #expect(comps.minute == 5)
    }

    @Test("Parse date and ignore invalid hour in time")
    func rejectInvalidHour() throws {
        let result = try #require( parseDateFromFilename("2026.06.07 25-30 Document.pdf") )
        
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: result.date)
        #expect(comps.year == 2026)
        #expect(comps.month == 6)
        #expect(comps.day == 7)
        #expect(comps.hour == 0)
        #expect(comps.minute == 0)
    }

    @Test("Parse date and ignore invalid minute in time")
    func rejectInvalidMinute() throws {
        let result = try #require( parseDateFromFilename("2026.06.07 12-99 Document.pdf") )
        
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: result.date)
        #expect(comps.year == 2026)
        #expect(comps.month == 6)
        #expect(comps.day == 7)
        #expect(comps.hour == 0)
        #expect(comps.minute == 0)
    }

    @Test("Date with trailing date ignored")
    func dateWithTrailingDateIgnored() throws {
        let result = try #require( parseDateFromFilename("2026.06.07 Document 2025.05.10.pdf") )
        #expect(result.name == "Document 2025.05.10.pdf")
    }

    @Test("Reject mismatched date separators")
    func rejectMismatchedSeparators() throws {
        let result = try #require( parseDateFromFilename("2026.06-07 MyDocument.pdf") )
        
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: result.date)
        #expect(comps.year == 2026)
        #expect(comps.month == 6)
        #expect(comps.day == 7)
        #expect(comps.hour == 0)
        #expect(comps.minute == 0)
    }
}


