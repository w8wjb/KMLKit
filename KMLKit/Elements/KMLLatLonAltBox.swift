//
//  LatLonBox.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/26/21.
//

import Foundation
import CoreLocation

open class KMLAbstractExtent: KMLObject {
    
}

open class KMLAbstractLatLonBox: KMLAbstractExtent {
    @objc open var north: CLLocationDegrees = 0
    @objc open var south: CLLocationDegrees = 0
    @objc open var east: CLLocationDegrees = 0
    @objc open var west: CLLocationDegrees = 0
}

open class KMLLatLonBox: KMLAbstractLatLonBox {
    @objc open var rotation: CLLocationDegrees = 0.0
}

open class KMLLatLonAltBox: KMLAbstractLatLonBox {
    
    @objc open var minAltitude: CLLocationDistance = 0.0
    @objc open var maxAltitude: CLLocationDegrees = 0.0
    @objc open var altitudeMode = KMLAltitudeMode.clampToGround
    @objc open var seaFloorAltitudeMode = KMLSeaFloorAltitudeMode.clampToSeaFloor
    
    open override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "altitudeMode", let altitudeMode = value as? KMLAltitudeMode {
            self.altitudeMode = altitudeMode
        } else if key == "seaFloorAltitudeMode", let seaFloorAltitudeMode = value as? KMLSeaFloorAltitudeMode {
                self.seaFloorAltitudeMode = seaFloorAltitudeMode
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
    
}

open class KMLLatLonQuad: KMLAbstractExtent {
    @objc open var coordinates: [CLLocation] = []
}
