//
//  LatLonBox.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/26/21.
//

import Foundation
import CoreLocation

public class KMLAbstractExtent: KMLObject {
    
}

public class KMLAbstractLatLonBox: KMLAbstractExtent {
    public var north: CLLocationDegrees = 0
    public var south: CLLocationDegrees = 0
    public var east: CLLocationDegrees = 0
    public var west: CLLocationDegrees = 0
}

public class KMLLatLonBox: KMLAbstractLatLonBox {
    public var rotation: CLLocationDegrees = 0.0
}

public class KMLLatLonAltBox: KMLAbstractLatLonBox {
    
    public var minAltitude: CLLocationDistance = 0.0
    public var maxAltitude: CLLocationDegrees = 0.0
    public var altitudeMode = KMLAltitudeMode.clampToGround
    public var seaFloorAltitudeMode = KMLSeaFloorAltitudeMode.clampToSeaFloor
    
}

public class KMLLatLonQuad: KMLAbstractExtent {
    public var coordinates: [CLLocation] = []
}
