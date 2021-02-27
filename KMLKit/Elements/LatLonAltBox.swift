//
//  LatLonBox.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/26/21.
//

import Foundation
import CoreLocation

public class AbstractExtent: KmlObject {
    
}

public class AbstractLatLonBox: AbstractExtent {
    public var north: CLLocationDegrees = 0
    public var south: CLLocationDegrees = 0
    public var east: CLLocationDegrees = 0
    public var west: CLLocationDegrees = 0
}

public class LatLonBox: AbstractLatLonBox {
    public var rotation: CLLocationDegrees = 0.0
}

public class LatLonAltBox: AbstractLatLonBox {
    
    public var minAltitude: CLLocationDistance = 0.0
    public var maxAltitude: CLLocationDegrees = 0.0
    public var altitudeMode = AltitudeMode.clampToGround
    public var seaFloorAltitudeMode = SeaFloorAltitudeMode.clampToSeaFloor
    
}

public class LatLonQuad: AbstractExtent {
    public var coordinates: [CLLocation] = []
}
