//
//  Placemark.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

open class KMLPlacemark: KMLFeature, KMLGeometryCollection {
    @objc open var geometry: KMLGeometry?
    
    open func add(geometry: KMLGeometry) {
        self.geometry = geometry
    }
}
