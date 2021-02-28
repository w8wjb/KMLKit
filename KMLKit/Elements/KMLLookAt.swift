//
//  LookAt.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import CoreLocation

public class KMLLookAt: KMLAbstractView {
    @objc public var longitude = CLLocationDegrees()
    @objc public var latitude = CLLocationDegrees()
    @objc public var altitude = CLLocationDistance()
    @objc public var heading = CLLocationDirection()
    @objc public var tilt: Double = 0
    @objc public var range: Double = 0
    @objc public var altitudeMode = KMLAltitudeMode.clampToGround
    
    public override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "altitudeMode", let altitudeMode = value as? KMLAltitudeMode {
            self.altitudeMode = altitudeMode
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
    
}
