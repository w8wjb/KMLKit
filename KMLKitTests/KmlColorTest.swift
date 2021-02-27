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
        
        XCTAssertEqual("#ffffffff", KMLColor.white.usingColorSpace(.sRGB)!.hexRGBaColor)
        XCTAssertEqual("#000000ff", KMLColor.black.usingColorSpace(.sRGB)!.hexRGBaColor)
        
        let color = KMLColor(hex: "12345678")
        XCTAssertEqual(18 / 255, color.redComponent, accuracy: 0.0001)
        XCTAssertEqual(52 / 255, color.greenComponent)
        XCTAssertEqual(86 / 255, color.blueComponent)
        XCTAssertEqual(120 / 255, color.alphaComponent)
        XCTAssertEqual("#12345678", color.hexRGBaColor)
        
        XCTAssertEqual("#ffa8ff00", KMLColor(hex: "ffa8ff00").hexRGBaColor)
    }

}
