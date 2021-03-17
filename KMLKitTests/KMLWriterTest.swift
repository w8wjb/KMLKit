//
//  KMLWriterTest.swift
//  KMLKitTests
//
//  Created by Weston Bustraan on 3/3/21.
//

import XCTest
@testable import KMLKit

class KMLWriterTest: XCTestCase {

    let bundle = Bundle(for: KMLWriterTest.self)
    
    func getSampleFile(_ resource: String, type: String) throws -> URL {
        let path = bundle.path(forResource: resource, ofType: type)!
        return URL(fileURLWithPath: path)
    }
    
    func testWrite_KML_Samples() throws {
        
        let kmlFile = try getSampleFile("KML_Samples", type: "kml")
        let kml = try KMLParser.parse(file: kmlFile)
        
        let writer = KMLWriter()
        
        writer.write(kml: kml, to: URL(fileURLWithPath: "~/tmp/test.kml"))
        
    }

}
