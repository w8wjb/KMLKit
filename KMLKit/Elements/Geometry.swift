//
//  Geometry.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import MapKit

public class Geometry: KmlObject {
    public var altitudeMode = AltitudeMode.clampToGround
}

public class Point: Geometry {
    
    public var extrude = false
    public var location = CLLocation()
    
}

public class Track: Geometry {

    public var extrude = false
    public var tessellate = false
    public var when: [Date] = []
    public var coordinates: [CLLocation] = []
    public var angles: [String] = []

}

public class MultiTrack: Geometry {
 
    public var interpolate = false

}

public class Model: Geometry {
    
    public class Scale: KmlObject {
        public var x: Double = 1.0
        public var y: Double = 1.0
        public var z: Double = 1.0
    }
    
    public class Alias {
        public var targetHref: URL?
        public var sourceHref: URL?
    }
    
    public var location = CLLocation()
    public var orientation = Orientation()
    public var scale = Scale()
    public var link: Link?
    public var resourceMap: [Alias] = []

}

public class MultiGeometry: Geometry {

    public var geometry: [Geometry] = []

}

public class LineString: Geometry {
    public var extrude = false
    public var tessellate = false
    public var coordinates: [CLLocation] = []
}

public class LinearRing: Geometry {
    public var extrude = false
    public var tessellate = false
    public var coordinates: [CLLocation] = []
}

public class Boundary {
    public var linearRing = LinearRing()
}

public class Polygon: Geometry {

    public var extrude = false
    public var tessellate = false
    public var outerBoundaryIs = Boundary()
    public var innerBoundaryIs: [Boundary] = []
}
