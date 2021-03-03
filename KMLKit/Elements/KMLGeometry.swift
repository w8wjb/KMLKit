//
//  Geometry.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import MapKit

public protocol KMLGeometryCollection {
    func add(geometry: KMLGeometry)
}

open class KMLGeometry: KMLObject {
    @objc open var altitudeMode = KMLAltitudeMode.clampToGround
    
    open override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "altitudeMode", let altitudeMode = value as? KMLAltitudeMode {
            self.altitudeMode = altitudeMode
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
}

open class KMLPoint: KMLGeometry {
    
    @objc open var extrude = false
    @objc open var location = CLLocation()
    
    open override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "coordinates",
           let coordinates = value as? [CLLocation],
           let location = coordinates.first {
            self.location = location
            
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
    
}

open class KMLModel: KMLGeometry {
    
    open class KMLScale: KMLObject {
        @objc open var x: Double = 1.0
        @objc open var y: Double = 1.0
        @objc open var z: Double = 1.0
    }

    @objc open var location = CLLocation()
    @objc open var orientation = KMLOrientation()
    
    @objc open var scale = KMLScale()
    @objc open var link: KMLLink?
    @objc open var resourceMap: [String:String] = [:]

}

open class KMLMultiGeometry: KMLGeometry, KMLGeometryCollection {

    @objc open var geometry: [KMLGeometry] = []

    open func add(geometry: KMLGeometry) {
        self.geometry.append(geometry)
    }
}

open class KMLLineString: KMLGeometry {
    @objc open var extrude = false
    @objc open var tessellate = false
    @objc open var coordinates: [CLLocation] = []
    @objc open var altitudeOffset: Double = 0.0
}

open class KMLLinearRing: KMLGeometry {
    @objc open var extrude = false
    @objc open var tessellate = false
    @objc open var coordinates: [CLLocation] = []
}

open class KMLBoundary: NSObject {
    @objc open var linearRing = KMLLinearRing()
}

open class KMLPolygon: KMLGeometry {

    @objc open var extrude = false
    @objc open var tessellate = false
    @objc open var outerBoundaryIs = KMLBoundary()
    @objc open var innerBoundaryIs: [KMLBoundary] = []
}
