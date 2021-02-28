//
//  Camera.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import CoreLocation

public class KMLCamera: KMLAbstractView {
    
    @objc public var longitude = CLLocationDegrees()
    @objc public var latitude = CLLocationDegrees()
    @objc public var altitude = CLLocationDistance()
    @objc public var heading = CLLocationDirection()
    @objc public var tilt: Double = 0
    @objc public var roll: Double = 0
    @objc public var altitudeMode = KMLAltitudeMode.clampToGround
}
