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
    @objc public var north: CLLocationDegrees = 0
    @objc public var south: CLLocationDegrees = 0
    @objc public var east: CLLocationDegrees = 0
    @objc public var west: CLLocationDegrees = 0
}

public class KMLLatLonBox: KMLAbstractLatLonBox {
    @objc public var rotation: CLLocationDegrees = 0.0
}

public class KMLLatLonAltBox: KMLAbstractLatLonBox {
    
    @objc public var minAltitude: CLLocationDistance = 0.0
    @objc public var maxAltitude: CLLocationDegrees = 0.0
    @objc public var altitudeMode = KMLAltitudeMode.clampToGround
    @objc public var seaFloorAltitudeMode = KMLSeaFloorAltitudeMode.clampToSeaFloor
    
    public override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "altitudeMode", let altitudeMode = value as? KMLAltitudeMode {
            self.altitudeMode = altitudeMode
        } else if key == "seaFloorAltitudeMode", let seaFloorAltitudeMode = value as? KMLSeaFloorAltitudeMode {
                self.seaFloorAltitudeMode = seaFloorAltitudeMode
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
    
}

public class KMLLatLonQuad: KMLAbstractExtent {
    @objc public var coordinates: [CLLocation] = []
}
