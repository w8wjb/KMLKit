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

public class KMLGeometry: KMLObject {
    @objc public var altitudeMode = KMLAltitudeMode.clampToGround
    
    public override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "altitudeMode", let altitudeMode = value as? KMLAltitudeMode {
            self.altitudeMode = altitudeMode
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
}

public class KMLPoint: KMLGeometry {
    
    @objc public var extrude = false
    @objc public var location = CLLocation()
    
    public override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "coordinates",
           let coordinates = value as? [CLLocation],
           let location = coordinates.first {
            self.location = location
            
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
    
}

public class KMLTrack: KMLGeometry {

    @objc public var extrude = false
    @objc public var tessellate = false
    @objc public var when: [Date] = []
    @objc public var coordinates: [CLLocation] = []
    @objc public var angles: [String] = []

}

public class KMLMultiTrack: KMLGeometry {
 
    @objc public var interpolate = false

}

public class KMLModel: KMLGeometry {
    
    public class KMLScale: KMLObject {
        @objc public var x: Double = 1.0
        @objc public var y: Double = 1.0
        @objc public var z: Double = 1.0
    }
    
    public class KMLAlias: NSObject {
        @objc public var targetHref: URL?
        @objc public var sourceHref: URL?
    }
    
    @objc public var location = CLLocation()
    @objc public var orientation = KMLOrientation()
    @objc public var scale = KMLScale()
    @objc public var link: KMLLink?
    @objc public var resourceMap: [KMLAlias] = []

}

public class KMLMultiGeometry: KMLGeometry, KMLGeometryCollection {

    @objc public var geometry: [KMLGeometry] = []

    public func add(geometry: KMLGeometry) {
        self.geometry.append(geometry)
    }
}

public class KMLLineString: KMLGeometry {
    @objc public var extrude = false
    @objc public var tessellate = false
    @objc public var coordinates: [CLLocation] = []
}

public class KMLLinearRing: KMLGeometry {
    @objc public var extrude = false
    @objc public var tessellate = false
    @objc public var coordinates: [CLLocation] = []
}

public class KMLBoundary: NSObject {
    @objc public var linearRing = KMLLinearRing()
}

public class KMLPolygon: KMLGeometry {

    @objc public var extrude = false
    @objc public var tessellate = false
    @objc public var outerBoundaryIs = KMLBoundary()
    @objc public var innerBoundaryIs: [KMLBoundary] = []
}
