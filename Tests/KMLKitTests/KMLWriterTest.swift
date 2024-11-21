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
    

    func getFile(_ resource: String, type: String) throws -> URL {        
        let path = try XCTUnwrap(Bundle.module.resourceURL?
            .appendingPathComponent("Resources")
            .appendingPathComponent("\(resource).\(type)")
            .path)

        return URL(fileURLWithPath: path)
    }
    
    func validateFile(_ fileToValidate: URL) throws {
        let ogckml22File = try getFile("ogckml22", type: "xsd")
        
        let doc = try XMLDocument(contentsOf: fileToValidate, options: [])
        
        let namespaceLocations = ["http://www.opengis.net/kml/2.2", ogckml22File.description]
        
        let namespaceLocation = XMLNode.attribute(withName: "xsi:schemaLocation", stringValue: namespaceLocations.joined(separator: " ")) as! XMLNode
        
        let root = doc.rootElement()!
        root.addAttribute(namespaceLocation)
        
        try doc.validate()
    }
    
    func testWrite_KML_Samples() throws {
        
        let kmlFile = try getFile("KML_Samples", type: "kml")
        let kml = try KMLParser.parse(file: kmlFile)
        
        let writer = KMLWriter()
        
        let outFile = FileManager.default.temporaryDirectory.appendingPathComponent("KML_Samples.out.kml")
        try writer.write(kml: kml, to: outFile)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: outFile.path))

        do {
            try validateFile(outFile)
        } catch {
            print(try String(contentsOf: outFile, encoding: .utf8))
            throw error
        }
        
        try FileManager.default.removeItem(at: outFile)
    }

}
