//
//  LookAt.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import CoreLocation

open class KMLLookAt: KMLAbstractView {
    @objc open var longitude = CLLocationDegrees()
    @objc open var latitude = CLLocationDegrees()
    @objc open var altitude = CLLocationDistance()
    @objc open var heading = CLLocationDirection()
    @objc open var tilt: Double = 0
    @objc open var range: Double = 0
    @objc open var altitudeMode = KMLAltitudeMode.clampToGround
    @objc open var horizFov: Double = 0

    open override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "altitudeMode", let altitudeMode = value as? KMLAltitudeMode {
            self.altitudeMode = altitudeMode
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
    
}
