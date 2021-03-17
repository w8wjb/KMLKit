//
//  KmlColor.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

import MapKit
#if os(iOS)
import UIKit
public typealias KMLColor = UIColor

#elseif os(macOS)

import AppKit
public typealias KMLColor = NSColor


#endif

extension KMLColor {
    
    var rgbComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        #if os(macOS)
        usingColorSpace(.sRGB)!.getRed(&r, green: &g, blue: &b, alpha: &a)
        #else
        getRed(&r, green: &g, blue: &b, alpha: &a)
        #endif
        return (r,g,b,a)
    }
    
    var hexRGBColor: String {
        return String(format: "%02x%02x%02x",
                      Int(rgbComponents.red * 255),
                      Int(rgbComponents.green * 255),
                      Int(rgbComponents.blue * 255))
    }
    
    var hexRGBaColor: String {
        return String(format: "%02x%02x%02x%02x",
                      Int(rgbComponents.red * 255),
                      Int(rgbComponents.green * 255),
                      Int(rgbComponents.blue * 255),
                      Int(rgbComponents.alpha * 255))
    }
    
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b, a) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, 255)
        case 6: // RGB (24-bit)
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: // ARGB (32-bit)
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (1, 1, 1, 1)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    
}


