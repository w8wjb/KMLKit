//
//  KmlColorTest.swift
//  KMLKitTests
//
//  Created by Weston Bustraan on 2/26/21.
//

import XCTest
@testable import KMLKit

class KmlColorTest: XCTestCase {

    func testColorHexRoundTrip() throws {
        
        XCTAssertEqual("ffffffff", KMLColor.white.usingColorSpace(.sRGB)!.kmlHex)
        XCTAssertEqual("ff000000", KMLColor.black.usingColorSpace(.sRGB)!.kmlHex)
        
        let color = KMLColor(kmlHex: "78563412")
        XCTAssertEqual(18 / 255, color.redComponent, accuracy: 0.0001)
        XCTAssertEqual(52 / 255, color.greenComponent)
        XCTAssertEqual(86 / 255, color.blueComponent)
        XCTAssertEqual(120 / 255, color.alphaComponent)
        XCTAssertEqual("78563412", color.kmlHex)
        
        XCTAssertEqual("ffa8ff00", KMLColor(kmlHex: "ffa8ff00").kmlHex)
    }

}
