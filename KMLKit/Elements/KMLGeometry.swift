//
//  Geometry.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import MapKit

public class KMLGeometry: KMLObject {
    public var altitudeMode = KMLAltitudeMode.clampToGround
}

public class KMLPoint: KMLGeometry {
    
    public var extrude = false
    public var location = CLLocation()
    
}

public class KMLTrack: KMLGeometry {

    public var extrude = false
    public var tessellate = false
    public var when: [Date] = []
    public var coordinates: [CLLocation] = []
    public var angles: [String] = []

}

public class KMLMultiTrack: KMLGeometry {
 
    public var interpolate = false

}

public class KMLModel: KMLGeometry {
    
    public class KMLScale: KMLObject {
        public var x: Double = 1.0
        public var y: Double = 1.0
        public var z: Double = 1.0
    }
    
    public class KMLAlias: NSObject {
        public var targetHref: URL?
        public var sourceHref: URL?
    }
    
    public var location = CLLocation()
    public var orientation = KMLOrientation()
    public var scale = KMLScale()
    public var link: KMLLink?
    public var resourceMap: [KMLAlias] = []

}

public class KMLMultiGeometry: KMLGeometry {

    public var geometry: [KMLGeometry] = []

}

public class KMLLineString: KMLGeometry {
    public var extrude = false
    public var tessellate = false
    public var coordinates: [CLLocation] = []
}

public class KMLLinearRing: KMLGeometry {
    public var extrude = false
    public var tessellate = false
    public var coordinates: [CLLocation] = []
}

public class KMLBoundary: NSObject {
    public var linearRing = KMLLinearRing()
}

public class KMLPolygon: KMLGeometry {

    public var extrude = false
    public var tessellate = false
    public var outerBoundaryIs = KMLBoundary()
    public var innerBoundaryIs: [KMLBoundary] = []
}
