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
    case unsupportedElement(elementName: String, line: Int)
    case unsupportedRelationship(parent: Any?, child: Any?, elementName: String, line: Int)
    case unexpectedElement(expected: String, line: Int? = nil)
    case missingAttribute(_ name: String)
    case missingElement(_ name: String, line: Int)
    case unexpectedError(exception: NSException)
}

extension ParsingError: @unchecked Sendable {}
