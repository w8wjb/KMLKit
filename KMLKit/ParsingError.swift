//
//  ParsingError.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

enum ParsingError: Error {
    case unsupportedFormat(_ extension: String)
    case unsupportedDateFormat(_ dateString: String)
    case failedToReadFile(_ url: URL)
    case unsupportedElement(elementName: String, line: Int = #line)
    case unsupportedRelationship(parent: Any?, child: Any?, elementName: String, line: Int = #line)
    case unexpectedElement(expected: String, line: Int = #line)
    case missingAttribute(_ name: String)
    case missingElement(_ name: String)
}
