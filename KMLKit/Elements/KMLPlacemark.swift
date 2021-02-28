//
//  Placemark.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public class KMLPlacemark: KMLFeature, KMLGeometryCollection {
    @objc public var geometry: KMLGeometry?
    
    public func add(geometry: KMLGeometry) {
        self.geometry = geometry
    }
}
