//
//  Camera.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import CoreLocation

public class KMLCamera: KMLAbstractView {
    
    public var longitude = CLLocationDegrees()
    public var latitude = CLLocationDegrees()
    public var altitude = CLLocationDistance()
    public var heading = CLLocationDirection()
    public var tilt: Double = 0
    public var roll: Double = 0
    public var altitudeMode = KMLAltitudeMode.clampToGround
}
