//
//  KMLWriterTest.swift
//  KMLKitTests
//
//  Created by Weston Bustraan on 3/3/21.
//

import XCTest
@testable import KMLKit

class KMLWriterTest: XCTestCase {

    func testWrite() throws {
        
        let kml = KMLRoot()
        kml.name = "root name"
        kml.hint = "root hint"
        
        let networkLinkControl = KMLNetworkLinkControl()
        kml.networkLinkControl = networkLinkControl
        
        let doc = KMLDocument()
        kml.feature = doc
        doc.id = "root-document"
        
        let writer = KMLWriter()
        
        writer.write(kml: kml, to: URL(fileURLWithPath: "~/tmp/test.kml"))
        
    }

}
