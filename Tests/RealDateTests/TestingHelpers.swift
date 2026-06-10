//
//  TestingHelpers.swift
//  realdate
//
//  Created by Anton Fillmann on 10.06.2026.
//

import Foundation
@testable import realdate

func createTestDirectory(_ fileID: String = #fileID) throws -> URL {
    let fileID = fileID.replacingOccurrences(of: "/", with: "_")
    let url = FileManager.default.temporaryDirectory.appending(path: "\(fileID)_\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
}
